#!/usr/bin/env python3
"""
Simple Mac Worker
Polls Fly.io broker and executes tasks with resource limits
"""
import os
import time
import requests
import logging
import uuid
import psutil
import resource
import subprocess

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Configuration
BROKER_URL = os.getenv('BROKER_URL', 'http://localhost:8080')
WORKER_ID = os.getenv('WORKER_ID', f'mac-{uuid.uuid4().hex[:8]}')
POLL_INTERVAL = int(os.getenv('POLL_INTERVAL', '5'))  # seconds
CPU_LIMIT = float(os.getenv('CPU_LIMIT', '40'))  # 40% CPU
RAM_LIMIT = float(os.getenv('RAM_LIMIT', '40'))  # 40% RAM

# Project port mapping
PROJECT_PORTS = {
    'diaperstops': 8001,
    'reno-app': 8002,
    'climate': 8003,
    'translator': 8004,
    'android': 8005
}

def get_system_usage():
    """Get current CPU and RAM usage"""
    cpu_percent = psutil.cpu_percent(interval=1)
    ram = psutil.virtual_memory()
    ram_percent = ram.percent
    
    return {
        'cpu_percent': round(cpu_percent, 1),
        'ram_percent': round(ram_percent, 1),
        'ram_used_gb': round(ram.used / (1024**3), 2),
        'ram_total_gb': round(ram.total / (1024**3), 2)
    }

def register_worker():
    """Register with broker"""
    try:
        usage = get_system_usage()
        
        response = requests.post(
            f'{BROKER_URL}/api/worker/register',
            json={
                'workerId': WORKER_ID,
                'projects': list(PROJECT_PORTS.keys()),
                'usage': usage,
                'limits': {
                    'cpu_percent': CPU_LIMIT,
                    'ram_percent': RAM_LIMIT
                }
            },
            timeout=10
        )
        
        if response.status_code == 200:
            logger.info(f"✅ Registered as worker: {WORKER_ID}")
            logger.info(f"   CPU: {usage['cpu_percent']}% (limit: {CPU_LIMIT}%)")
            logger.info(f"   RAM: {usage['ram_percent']}% (limit: {RAM_LIMIT}%)")
            return True
        else:
            logger.error(f"❌ Registration failed: {response.status_code}")
            return False
    
    except Exception as e:
        logger.error(f"❌ Registration error: {e}")
        return False

def poll_for_task():
    """Poll broker for tasks with usage reporting"""
    try:
        usage = get_system_usage()
        
        response = requests.get(
            f'{BROKER_URL}/api/worker/poll',
            params={
                'workerId': WORKER_ID,
                'projects': ','.join(PROJECT_PORTS.keys())
            },
            json={'usage': usage},  # Send current usage
            timeout=10
        )
        
        if response.status_code == 200:
            data = response.json()
            if data.get('task'):
                return data['task']
        
        return None
    
    except Exception as e:
        logger.error(f"❌ Poll error: {e}")
        return None

def set_resource_limits():
    """Set CPU and RAM limits for child processes"""
    try:
        # Get total system RAM
        total_ram = psutil.virtual_memory().total
        ram_limit_bytes = int(total_ram * (RAM_LIMIT / 100))
        
        # Set memory limit (soft and hard)
        resource.setrlimit(resource.RLIMIT_AS, (ram_limit_bytes, ram_limit_bytes))
        
        logger.info(f"🔒 Resource limits set: {RAM_LIMIT}% RAM ({ram_limit_bytes / (1024**3):.2f} GB)")
    except Exception as e:
        logger.warning(f"⚠️  Could not set resource limits: {e}")

def execute_task(task):
    """Execute task on local agent server with resource limits"""
    task_id = task['id']
    project = task['project']
    task_text = task['task']
    
    logger.info(f"🚀 Executing task {task_id} for {project}")
    
    # Check current usage before starting
    usage_before = get_system_usage()
    logger.info(f"   CPU: {usage_before['cpu_percent']}%, RAM: {usage_before['ram_percent']}%")
    
    port = PROJECT_PORTS.get(project, 8001)
    
    try:
        # Use cpulimit to restrict CPU usage
        # Call local agent API with resource monitoring
        start_time = time.time()
        
        response = requests.post(
            f'http://localhost:{port}/execute',
            json={'task': task_text, 'background': False},
            timeout=300
        )
        
        duration = time.time() - start_time
        usage_after = get_system_usage()
        
        if response.status_code == 200:
            result = response.json()
            logger.info(f"✅ Task {task_id} completed in {duration:.1f}s")
            logger.info(f"   CPU: {usage_after['cpu_percent']}%, RAM: {usage_after['ram_percent']}%")
            
            return {
                'success': True,
                'result': result,
                'duration': duration,
                'usage': usage_after
            }
        else:
            logger.error(f"❌ Task {task_id} failed: {response.status_code}")
            return {'success': False, 'error': f"HTTP {response.status_code}"}
    
    except Exception as e:
        logger.error(f"❌ Task {task_id} error: {e}")
        return {'success': False, 'error': str(e)}

def report_result(task_id, result):
    """Report result back to broker with usage stats"""
    try:
        response = requests.post(
            f'{BROKER_URL}/api/worker/result',
            json={
                'taskId': task_id,
                'result': result.get('result') if result.get('success') else None,
                'error': result.get('error') if not result.get('success') else None,
                'duration': result.get('duration'),
                'usage': result.get('usage')
            },
            timeout=10
        )
        
        if response.status_code == 200:
            logger.info(f"📤 Result reported for {task_id}")
        else:
            logger.error(f"❌ Failed to report result: {response.status_code}")
    
    except Exception as e:
        logger.error(f"❌ Report error: {e}")

def main():
    """Main worker loop"""
    logger.info("🤖 Starting Mac Worker")
    logger.info(f"   Broker: {BROKER_URL}")
    logger.info(f"   Worker ID: {WORKER_ID}")
    logger.info(f"   Poll Interval: {POLL_INTERVAL}s")
    logger.info(f"   CPU Limit: {CPU_LIMIT}%")
    logger.info(f"   RAM Limit: {RAM_LIMIT}%")
    logger.info("")
    
    # Set resource limits
    set_resource_limits()
    
    # Register with broker
    if not register_worker():
        logger.error("Failed to register, exiting")
        return
    
    logger.info("📡 Polling for tasks...")
    logger.info("")
    
    # Main loop
    while True:
        try:
            # Poll for task
            task = poll_for_task()
            
            if task:
                # Execute task
                result = execute_task(task)
                
                # Report result
                report_result(task['id'], result)
            
            # Wait before next poll
            time.sleep(POLL_INTERVAL)
        
        except KeyboardInterrupt:
            logger.info("\n👋 Worker stopped by user")
            break
        
        except Exception as e:
            logger.error(f"❌ Worker error: {e}")
            time.sleep(POLL_INTERVAL)

if __name__ == '__main__':
    main()
