const express = require('express');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

// In-memory task queue (use PostgreSQL for production)
const tasks = new Map();
const workers = new Map();

// Business logic: validate task
function validateTask(project, task) {
  const validProjects = ['diaperstops', 'reno-app', 'climate', 'translator', 'android'];
  
  if (!validProjects.includes(project)) {
    return { valid: false, error: 'Invalid project' };
  }
  
  if (!task || task.length > 10000) {
    return { valid: false, error: 'Invalid task' };
  }
  
  return { valid: true };
}

// Submit task (from phone)
app.post('/api/submit', (req, res) => {
  const { project, task, priority = 'normal', tags = [] } = req.body;
  
  // Validate
  const validation = validateTask(project, task);
  if (!validation.valid) {
    return res.status(400).json({ error: validation.error });
  }
  
  // Validate priority
  const validPriorities = ['low', 'normal', 'high', 'urgent'];
  const taskPriority = validPriorities.includes(priority) ? priority : 'normal';
  
  // Create task
  const taskId = `task-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  
  tasks.set(taskId, {
    id: taskId,
    project,
    task,
    priority: taskPriority,
    tags,
    status: 'pending',
    createdAt: new Date(),
    result: null,
    retries: 0,
    maxRetries: 3
  });
  
  console.log(`[BROKER] Task created: ${taskId} for ${project} (priority: ${taskPriority})`);
  
  res.json({
    success: true,
    taskId,
    project,
    priority: taskPriority,
    message: 'Task queued'
  });
});

// Worker registration (Mac opts in)
app.post('/api/worker/register', (req, res) => {
  const { workerId, projects, usage, limits } = req.body;
  
  workers.set(workerId, {
    id: workerId,
    projects: projects || ['*'],
    lastSeen: new Date(),
    usage: usage || {},
    limits: limits || {}
  });
  
  console.log(`[BROKER] Worker registered: ${workerId} (CPU: ${usage?.cpu_percent}%, RAM: ${usage?.ram_percent}%)`);
  
  res.json({
    success: true,
    workerId,
    message: 'Worker registered'
  });
});

// Worker polls for tasks
app.post('/api/worker/poll', (req, res) => {
  const { workerId, projects } = req.query;
  const { usage } = req.body;
  
  // Update last seen and usage
  if (workers.has(workerId)) {
    const worker = workers.get(workerId);
    worker.lastSeen = new Date();
    worker.usage = usage || worker.usage;
    workers.set(workerId, worker);
  }
  
  // Find pending task for this worker (priority order)
  const workerProjects = projects ? projects.split(',') : ['*'];
  
  // Priority order: urgent > high > normal > low
  const priorityOrder = ['urgent', 'high', 'normal', 'low'];
  
  for (const priority of priorityOrder) {
    for (const [taskId, task] of tasks.entries()) {
      if (task.status === 'pending' && task.priority === priority) {
        if (workerProjects.includes('*') || workerProjects.includes(task.project)) {
          // Assign task to worker
          task.status = 'running';
          task.workerId = workerId;
          task.startedAt = new Date();
          tasks.set(taskId, task);
          
          console.log(`[BROKER] Task ${taskId} (${priority}) assigned to ${workerId}`);
          
          return res.json({
            success: true,
            task: {
              id: task.id,
              project: task.project,
              task: task.task,
              priority: task.priority,
              tags: task.tags
            }
          });
        }
      }
    }
  }
  
  // No tasks available
  res.json({
    success: true,
    task: null
  });
});

// Worker reports result
app.post('/api/worker/result', (req, res) => {
  const { taskId, result, error, duration, usage } = req.body;
  
  if (!tasks.has(taskId)) {
    return res.status(404).json({ error: 'Task not found' });
  }
  
  const task = tasks.get(taskId);
  
  // Handle failure with retry
  if (error && task.retries < task.maxRetries) {
    task.retries++;
    task.status = 'pending';  // Retry
    task.workerId = null;
    task.lastError = error;
    tasks.set(taskId, task);
    
    console.log(`[BROKER] Task ${taskId} failed, retrying (${task.retries}/${task.maxRetries})`);
    
    return res.json({
      success: true,
      message: 'Task will be retried',
      retries: task.retries
    });
  }
  
  // Final result (success or max retries reached)
  task.status = error ? 'failed' : 'completed';
  task.result = result;
  task.error = error;
  task.duration = duration;
  task.usage = usage;
  task.completedAt = new Date();
  tasks.set(taskId, task);
  
  console.log(`[BROKER] Task ${taskId} ${task.status} (${duration}s, CPU: ${usage?.cpu_percent}%)`);
  
  res.json({
    success: true,
    message: 'Result recorded'
  });
});

// Check task status (from phone)
app.get('/api/status/:taskId', (req, res) => {
  const { taskId } = req.params;
  
  if (!tasks.has(taskId)) {
    return res.status(404).json({ error: 'Task not found' });
  }
  
  const task = tasks.get(taskId);
  
  // Get worker info if available
  let workerInfo = null;
  if (task.workerId && workers.has(task.workerId)) {
    const worker = workers.get(task.workerId);
    workerInfo = {
      id: worker.id,
      usage: worker.usage,
      limits: worker.limits
    };
  }
  
  res.json({
    taskId: task.id,
    project: task.project,
    status: task.status,
    priority: task.priority,
    tags: task.tags,
    result: task.result,
    error: task.error,
    duration: task.duration,
    usage: task.usage,
    worker: workerInfo,
    retries: task.retries,
    maxRetries: task.maxRetries,
    createdAt: task.createdAt,
    completedAt: task.completedAt
  });
});

// Cancel task
app.post('/api/cancel/:taskId', (req, res) => {
  const { taskId } = req.params;
  
  if (!tasks.has(taskId)) {
    return res.status(404).json({ error: 'Task not found' });
  }
  
  const task = tasks.get(taskId);
  
  if (task.status === 'completed' || task.status === 'failed') {
    return res.status(400).json({ error: 'Task already finished' });
  }
  
  task.status = 'cancelled';
  task.completedAt = new Date();
  tasks.set(taskId, task);
  
  console.log(`[BROKER] Task ${taskId} cancelled`);
  
  res.json({
    success: true,
    message: 'Task cancelled'
  });
});

// Health check
app.get('/api/health', (req, res) => {
  const workerList = Array.from(workers.values()).map(w => ({
    id: w.id,
    projects: w.projects,
    usage: w.usage,
    limits: w.limits,
    lastSeen: w.lastSeen
  }));
  
  res.json({
    status: 'ok',
    workers: {
      count: workers.size,
      list: workerList
    },
    tasks: {
      pending: Array.from(tasks.values()).filter(t => t.status === 'pending').length,
      running: Array.from(tasks.values()).filter(t => t.status === 'running').length,
      completed: Array.from(tasks.values()).filter(t => t.status === 'completed').length
    }
  });
});

// Cleanup old tasks (every 5 minutes)
setInterval(() => {
  const now = new Date();
  for (const [taskId, task] of tasks.entries()) {
    const age = now - task.createdAt;
    if (age > 24 * 60 * 60 * 1000) { // 24 hours
      tasks.delete(taskId);
      console.log(`[BROKER] Cleaned up old task: ${taskId}`);
    }
  }
}, 5 * 60 * 1000);

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`Broker running on port ${PORT}`);
});
