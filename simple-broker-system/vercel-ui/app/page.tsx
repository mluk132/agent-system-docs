'use client';

import { useState, useEffect } from 'react';

export default function Home() {
  const [project, setProject] = useState('diaperstops');
  const [task, setTask] = useState('');
  const [taskId, setTaskId] = useState('');
  const [status, setStatus] = useState<any>(null);
  const [loading, setLoading] = useState(false);
  const [health, setHealth] = useState<any>(null);

  const projects = [
    { id: 'diaperstops', name: 'Diaper Stops' },
    { id: 'reno-app', name: 'Reno App' },
    { id: 'climate', name: 'Climate Wardrobe' },
    { id: 'translator', name: 'Translator' },
    { id: 'android', name: 'Android Template' }
  ];

  // Poll for status updates
  useEffect(() => {
    if (!taskId) return;

    const interval = setInterval(async () => {
      try {
        const res = await fetch(`/api/status/${taskId}`);
        const data = await res.json();
        setStatus(data);

        if (data.status === 'completed' || data.status === 'failed') {
          clearInterval(interval);
        }
      } catch (err) {
        console.error('Status check failed:', err);
      }
    }, 2000);

    return () => clearInterval(interval);
  }, [taskId]);

  // Load health status
  useEffect(() => {
    const loadHealth = async () => {
      try {
        const res = await fetch('/api/health');
        const data = await res.json();
        setHealth(data);
      } catch (err) {
        console.error('Health check failed:', err);
      }
    };

    loadHealth();
    const interval = setInterval(loadHealth, 5000);
    return () => clearInterval(interval);
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setStatus(null);

    try {
      const res = await fetch('/api/submit', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ project, task })
      });

      const data = await res.json();

      if (data.success) {
        setTaskId(data.taskId);
        setTask('');
      } else {
        alert('Failed: ' + data.error);
      }
    } catch (err) {
      alert('Error: ' + err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ 
      maxWidth: '600px', 
      margin: '0 auto', 
      padding: '20px',
      fontFamily: 'system-ui, -apple-system, sans-serif'
    }}>
      <h1 style={{ fontSize: '24px', marginBottom: '10px' }}>🤖 Agent Task Queue</h1>
      
      {/* Health Status */}
      {health && (
        <div style={{ 
          background: '#f0f0f0', 
          padding: '15px', 
          borderRadius: '8px',
          marginBottom: '20px'
        }}>
          <div style={{ fontSize: '14px', marginBottom: '10px' }}>
            <strong>Workers:</strong> {health.workers.count} online
          </div>
          
          {health.workers.list.map((w: any) => (
            <div key={w.id} style={{ 
              background: 'white', 
              padding: '10px', 
              borderRadius: '4px',
              marginBottom: '8px',
              fontSize: '12px'
            }}>
              <div><strong>{w.id}</strong></div>
              <div style={{ color: '#666', marginTop: '4px' }}>
                CPU: {w.usage?.cpu_percent || 0}% / {w.limits?.cpu_percent || 40}% | 
                RAM: {w.usage?.ram_percent || 0}% / {w.limits?.ram_percent || 40}%
              </div>
              <div style={{ color: '#999', fontSize: '11px' }}>
                {w.usage?.ram_used_gb || 0}GB / {w.usage?.ram_total_gb || 0}GB
              </div>
            </div>
          ))}
          
          <div style={{ fontSize: '12px', color: '#666', marginTop: '10px' }}>
            Tasks: {health.tasks.pending} pending, {health.tasks.running} running, {health.tasks.completed} completed
          </div>
        </div>
      )}

      {/* Submit Form */}
      <form onSubmit={handleSubmit} style={{ marginBottom: '30px' }}>
        <div style={{ marginBottom: '15px' }}>
          <label style={{ display: 'block', marginBottom: '5px', fontSize: '14px' }}>
            Project
          </label>
          <select
            value={project}
            onChange={(e) => setProject(e.target.value)}
            style={{
              width: '100%',
              padding: '12px',
              fontSize: '16px',
              borderRadius: '8px',
              border: '1px solid #ddd'
            }}
          >
            {projects.map(p => (
              <option key={p.id} value={p.id}>{p.name}</option>
            ))}
          </select>
        </div>

        <div style={{ marginBottom: '15px' }}>
          <label style={{ display: 'block', marginBottom: '5px', fontSize: '14px' }}>
            Task
          </label>
          <textarea
            value={task}
            onChange={(e) => setTask(e.target.value)}
            placeholder="Enter your task..."
            rows={4}
            style={{
              width: '100%',
              padding: '12px',
              fontSize: '16px',
              borderRadius: '8px',
              border: '1px solid #ddd',
              resize: 'vertical'
            }}
            required
          />
        </div>

        <button
          type="submit"
          disabled={loading || !task}
          style={{
            width: '100%',
            padding: '15px',
            fontSize: '16px',
            fontWeight: 'bold',
            color: 'white',
            background: loading ? '#999' : '#007bff',
            border: 'none',
            borderRadius: '8px',
            cursor: loading ? 'not-allowed' : 'pointer'
          }}
        >
          {loading ? 'Submitting...' : 'Submit Task'}
        </button>
      </form>

      {/* Status Display */}
      {status && (
        <div style={{
          background: status.status === 'completed' ? '#d4edda' : 
                     status.status === 'failed' ? '#f8d7da' : '#fff3cd',
          padding: '15px',
          borderRadius: '8px',
          border: '1px solid ' + (
            status.status === 'completed' ? '#c3e6cb' : 
            status.status === 'failed' ? '#f5c6cb' : '#ffeaa7'
          )
        }}>
          <div style={{ fontSize: '14px', marginBottom: '10px' }}>
            <strong>Task ID:</strong> {status.taskId}
          </div>
          <div style={{ fontSize: '14px', marginBottom: '10px' }}>
            <strong>Status:</strong> {status.status}
          </div>
          
          {status.worker && (
            <div style={{ fontSize: '12px', marginBottom: '10px', color: '#666' }}>
              <strong>Worker:</strong> {status.worker.id}<br/>
              CPU: {status.worker.usage?.cpu_percent}% | RAM: {status.worker.usage?.ram_percent}%
            </div>
          )}
          
          {status.duration && (
            <div style={{ fontSize: '12px', marginBottom: '10px', color: '#666' }}>
              <strong>Duration:</strong> {status.duration}s
            </div>
          )}
          
          {status.usage && (
            <div style={{ fontSize: '12px', marginBottom: '10px', color: '#666' }}>
              <strong>Final Usage:</strong> CPU {status.usage.cpu_percent}%, RAM {status.usage.ram_percent}%
            </div>
          )}

          {status.result && (
            <div style={{ marginTop: '10px' }}>
              <strong>Result:</strong>
              <pre style={{
                background: 'white',
                padding: '10px',
                borderRadius: '4px',
                fontSize: '12px',
                overflow: 'auto',
                marginTop: '5px'
              }}>
                {JSON.stringify(status.result, null, 2)}
              </pre>
            </div>
          )}

          {status.error && (
            <div style={{ marginTop: '10px', color: '#721c24' }}>
              <strong>Error:</strong> {status.error}
            </div>
          )}
        </div>
      )}
    </div>
  );
}
