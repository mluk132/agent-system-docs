# 🏗️ Architecture: Resource-Limited Agent System

## 📊 System Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         PHONE (User)                            │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │              Vercel UI (Next.js)                          │ │
│  │  ┌─────────────────────────────────────────────────────┐  │ │
│  │  │  Worker Status (Real-time)                          │  │ │
│  │  │  ┌─────────────────────────────────────────────┐    │  │ │
│  │  │  │  mac-abc123                                 │    │  │ │
│  │  │  │  CPU: 15.2% / 40% | RAM: 28.5% / 40%      │    │  │ │
│  │  │  │  4.2GB / 16GB                              │    │  │ │
│  │  │  └─────────────────────────────────────────────┘    │  │ │
│  │  │                                                      │  │ │
│  │  │  Task Submission                                    │  │ │
│  │  │  [Project: diaperstops ▼]                          │  │ │
│  │  │  [Task: ___________________________]               │  │ │
│  │  │  [Submit Task]                                     │  │ │
│  │  │                                                      │  │ │
│  │  │  Task Status                                        │  │ │
│  │  │  Status: completed (12.3s)                         │  │ │
│  │  │  Worker: mac-abc123                                │  │ │
│  │  │  Final Usage: CPU 22.1%, RAM 35.8%                │  │ │
│  │  └─────────────────────────────────────────────────────┘  │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ HTTPS
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    FLY.IO BROKER ($2/month)                     │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │              Express API Server                           │ │
│  │                                                            │ │
│  │  Endpoints:                                               │ │
│  │  • POST /api/submit        (from phone)                  │ │
│  │  • GET  /api/status/:id    (to phone)                   │ │
│  │  • GET  /api/health        (to phone)                   │ │
│  │  • POST /api/worker/register (from worker)              │ │
│  │  • POST /api/worker/poll     (from worker)              │ │
│  │  • POST /api/worker/result   (from worker)              │ │
│  │                                                            │ │
│  │  In-Memory Storage:                                       │ │
│  │  ┌──────────────────────────────────────────────────┐    │ │
│  │  │  Tasks Map                                       │    │ │
│  │  │  task-123: {                                     │    │ │
│  │  │    status: "running",                            │    │ │
│  │  │    workerId: "mac-abc123",                       │    │ │
│  │  │    duration: 12.3,                               │    │ │
│  │  │    usage: {cpu: 22.1, ram: 35.8}                │    │ │
│  │  │  }                                               │    │ │
│  │  └──────────────────────────────────────────────────┘    │ │
│  │  ┌──────────────────────────────────────────────────┐    │ │
│  │  │  Workers Map                                     │    │ │
│  │  │  mac-abc123: {                                   │    │ │
│  │  │    usage: {cpu: 15.2, ram: 28.5},               │    │ │
│  │  │    limits: {cpu: 40, ram: 40},                  │    │ │
│  │  │    lastSeen: 2025-04-22T10:30:00Z               │    │ │
│  │  │  }                                               │    │ │
│  │  └──────────────────────────────────────────────────┘    │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ HTTP Polling (every 5s)
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      MAC WORKER (Local)                         │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │              worker.py (Python)                           │ │
│  │                                                            │ │
│  │  Resource Limits:                                         │ │
│  │  • CPU_LIMIT = 40%                                        │ │
│  │  • RAM_LIMIT = 40%                                        │ │
│  │                                                            │ │
│  │  Monitoring (psutil):                                     │ │
│  │  ┌──────────────────────────────────────────────────┐    │ │
│  │  │  get_system_usage()                              │    │ │
│  │  │  • cpu_percent: 15.2%                            │    │ │
│  │  │  • ram_percent: 28.5%                            │    │ │
│  │  │  • ram_used_gb: 4.2                              │    │ │
│  │  │  • ram_total_gb: 16                              │    │ │
│  │  └──────────────────────────────────────────────────┘    │ │
│  │                                                            │ │
│  │  Enforcement:                                             │ │
│  │  ┌──────────────────────────────────────────────────┐    │ │
│  │  │  set_resource_limits()                           │    │ │
│  │  │  • RAM: resource.setrlimit()                     │    │ │
│  │  │  • CPU: Process-level monitoring                 │    │ │
│  │  └──────────────────────────────────────────────────┘    │ │
│  │                                                            │ │
│  │  Main Loop:                                               │ │
│  │  1. Register with broker (send usage + limits)           │ │
│  │  2. Poll for tasks (send current usage)                  │ │
│  │  3. Execute task (monitor usage)                         │ │
│  │  4. Report result (send final usage)                     │ │
│  │  5. Sleep 5s, repeat                                     │ │
│  └───────────────────────────────────────────────────────────┘ │
│                              │                                  │
│                              │ HTTP (localhost)                 │
│                              ▼                                  │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │              Agent Servers (5 projects)                   │ │
│  │                                                            │ │
│  │  • localhost:8001  diaperstops                           │ │
│  │  • localhost:8002  reno-app                              │ │
│  │  • localhost:8003  climate                               │ │
│  │  • localhost:8004  translator                            │ │
│  │  • localhost:8005  android                               │ │
│  │                                                            │ │
│  │  Each server:                                             │ │
│  │  POST /execute {"task": "..."}                           │ │
│  │  → Executes: kiro execute "$TASK"                        │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## 🔄 Data Flow

### 1. Worker Registration
```
Mac Worker                    Broker
    │                           │
    │  POST /api/worker/register│
    │  {                        │
    │    workerId: "mac-abc123",│
    │    usage: {cpu: 10, ram: 25},
    │    limits: {cpu: 40, ram: 40}
    │  }                        │
    ├──────────────────────────>│
    │                           │
    │  {success: true}          │
    │<──────────────────────────┤
    │                           │
```

### 2. Task Submission (Phone)
```
Phone                         Broker
    │                           │
    │  POST /api/submit         │
    │  {                        │
    │    project: "diaperstops",│
    │    task: "echo hello"     │
    │  }                        │
    ├──────────────────────────>│
    │                           │
    │  {                        │
    │    taskId: "task-123",    │
    │    status: "pending"      │
    │  }                        │
    │<──────────────────────────┤
    │                           │
```

### 3. Worker Polling
```
Mac Worker                    Broker
    │                           │
    │  POST /api/worker/poll    │
    │  ?workerId=mac-abc123     │
    │  {                        │
    │    usage: {cpu: 15, ram: 28}
    │  }                        │
    ├──────────────────────────>│
    │                           │
    │  {                        │
    │    task: {                │
    │      id: "task-123",      │
    │      project: "diaperstops",
    │      task: "echo hello"   │
    │    }                      │
    │  }                        │
    │<──────────────────────────┤
    │                           │
```

### 4. Task Execution
```
Mac Worker              Agent Server
    │                        │
    │  POST /execute         │
    │  {task: "echo hello"}  │
    ├───────────────────────>│
    │                        │
    │  Monitor CPU/RAM       │
    │  • Before: 15%/28%     │
    │  • During: 22%/35%     │
    │  • After: 18%/32%      │
    │                        │
    │  {                     │
    │    output: "hello",    │
    │    status: "success"   │
    │  }                     │
    │<───────────────────────┤
    │                        │
```

### 5. Result Reporting
```
Mac Worker                    Broker
    │                           │
    │  POST /api/worker/result  │
    │  {                        │
    │    taskId: "task-123",    │
    │    result: {...},         │
    │    duration: 12.3,        │
    │    usage: {cpu: 22, ram: 35}
    │  }                        │
    ├──────────────────────────>│
    │                           │
    │  {success: true}          │
    │<──────────────────────────┤
    │                           │
```

### 6. Status Check (Phone)
```
Phone                         Broker
    │                           │
    │  GET /api/status/task-123 │
    ├──────────────────────────>│
    │                           │
    │  {                        │
    │    status: "completed",   │
    │    duration: 12.3,        │
    │    usage: {cpu: 22, ram: 35},
    │    worker: {              │
    │      id: "mac-abc123",    │
    │      usage: {cpu: 18, ram: 32}
    │    }                      │
    │  }                        │
    │<──────────────────────────┤
    │                           │
```

## 🔒 Resource Limiting Flow

```
┌─────────────────────────────────────────────────────────┐
│                    Worker Startup                       │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│              set_resource_limits()                      │
│  • Get total RAM: 16GB                                  │
│  • Calculate limit: 16GB * 40% = 6.4GB                  │
│  • Set hard limit: resource.setrlimit(6.4GB)            │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│                  Main Loop                              │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│              get_system_usage()                         │
│  • CPU: psutil.cpu_percent() = 15.2%                    │
│  • RAM: psutil.virtual_memory().percent = 28.5%         │
│  • Check: 15.2% < 40% ✓, 28.5% < 40% ✓                 │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│              Send to Broker                             │
│  • Registration: Initial usage + limits                 │
│  • Polling: Current usage                               │
│  • Result: Final usage                                  │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│              Display on Phone                           │
│  • Worker card: 15.2% / 40% CPU                         │
│  • Worker card: 28.5% / 40% RAM                         │
│  • Task result: Final usage stats                       │
└─────────────────────────────────────────────────────────┘
```

## 🎯 Component Responsibilities

### Phone (Vercel UI)
- ✅ Display worker status with usage
- ✅ Submit tasks to broker
- ✅ Poll for task status
- ✅ Show real-time updates
- ✅ Display final usage stats

### Broker (Fly.io)
- ✅ Queue tasks from phone
- ✅ Track worker registration
- ✅ Store worker usage data
- ✅ Assign tasks to workers
- ✅ Store task results + usage
- ✅ Provide status to phone

### Worker (Mac)
- ✅ Set resource limits (40% CPU/RAM)
- ✅ Monitor system usage
- ✅ Register with broker
- ✅ Poll for tasks
- ✅ Execute on agent servers
- ✅ Report results + usage

### Agent Servers (Mac)
- ✅ Listen on ports 8001-8005
- ✅ Execute tasks via Kiro
- ✅ Return results

## 💰 Cost Analysis

```
Component          Cost/Month    Resources
─────────────────────────────────────────────
Fly.io Broker      $1.94        256MB RAM, 1 CPU
Vercel UI          $0           Hobby plan
Mac Worker         $0           Local
Agent Servers      $0           Local
─────────────────────────────────────────────
TOTAL              $1.94/month
```

## 🚀 Deployment Order

```
1. Fly.io Broker
   ├─ flyctl launch
   ├─ flyctl deploy
   └─ Get URL: agent-broker.fly.dev

2. Vercel UI
   ├─ vercel
   ├─ Set BROKER_URL env var
   ├─ vercel --prod
   └─ Get URL: your-app.vercel.app

3. Mac Worker
   ├─ Create .env with BROKER_URL
   ├─ Set CPU_LIMIT=40, RAM_LIMIT=40
   └─ ./start-worker.sh
```

## 📊 Monitoring Points

```
Level          Metric              Source          Frequency
──────────────────────────────────────────────────────────────
Worker         CPU/RAM usage       psutil          Every 1s
Worker→Broker  Usage report        HTTP POST       Every 5s
Broker→Phone   Worker status       HTTP GET        Every 5s
Phone          Task status         HTTP GET        Every 2s
Broker         Task queue          In-memory       Real-time
```

## ✨ Key Features

1. **Resource Protection**: Hard limits prevent system overload
2. **Real-Time Monitoring**: Live usage on phone
3. **Simple Architecture**: No complex orchestration
4. **Low Cost**: $2/month total
5. **Mobile First**: Optimized for phone
6. **Flexible**: Configurable limits
7. **Transparent**: Complete visibility

This architecture provides a simple, cost-effective, and resource-conscious agent system! 🎉
