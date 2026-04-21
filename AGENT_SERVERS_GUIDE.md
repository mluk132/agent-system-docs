# Agent Server System - Complete Guide

All projects now have local agent servers that integrate with Kiro for task execution and process management.

## 🎯 Overview

Each project has:
- **agent-server.py** - Local HTTP API server (Python)
- **start-agent-server.sh** - Startup script with project config
- **.agent-task.sh** - Task handler that calls the local API
- **Unique port** - Each project runs on its own port

## 📋 Project Ports

| Project | Port | Path |
|---------|------|------|
| diaperstops | 8001 | projects/diaperstops.com |
| reno-app | 8002 | projects/reno-app |
| ClimateWardrobe | 8003 | projects/ClimateWardrobe |
| translator | 8004 | projects/translator |
| android-app-template | 8005 | projects/android-app-template |

## 🚀 Quick Start

### Start All Servers
```bash
cd ~/projects
./agent-control.sh start-all
```

### Start Individual Server
```bash
./agent-control.sh start diaperstops
./agent-control.sh start reno-app
./agent-control.sh start climate
```

### Check Status
```bash
./agent-control.sh status
```

### Stop Servers
```bash
./agent-control.sh stop diaperstops
./agent-control.sh stop-all
```

## 🔧 Manual Server Management

### Start a Server Manually
```bash
cd projects/diaperstops.com
./start-agent-server.sh
```

The server will run in the foreground. Press Ctrl+C to stop.

### Run in Background
```bash
cd projects/diaperstops.com
nohup ./start-agent-server.sh > agent-server.log 2>&1 &
```

### Check if Running
```bash
lsof -i:8001  # Check port 8001 (diaperstops)
```

## 📡 API Usage

### Execute a Task
```bash
curl -X POST http://localhost:8001/execute \
  -H "Content-Type: application/json" \
  -d '{"task":"fix the login bug","background":false}'
```

### Execute in Background
```bash
curl -X POST http://localhost:8001/execute \
  -H "Content-Type: application/json" \
  -d '{"task":"run all tests","background":true}'
```

### List Running Processes
```bash
curl http://localhost:8001/processes
```

### Kill a Process
```bash
curl -X POST http://localhost:8001/kill \
  -H "Content-Type: application/json" \
  -d '{"pid":12345}'
```

### Stop All Processes
```bash
curl -X POST http://localhost:8001/stop-all
```

### Server Info
```bash
curl http://localhost:8001/
```

## 🤖 Integration with Kiro

The agent servers use Kiro to execute tasks:

```bash
# When you call the API
curl -X POST http://localhost:8001/execute -d '{"task":"fix bug"}'

# The server internally runs
kiro execute "fix bug"
```

This means:
- ✅ Full Kiro capabilities available
- ✅ Access to all your code and context
- ✅ Can manage processes (start/stop/kill)
- ✅ Works on any machine (Linux, Mac, Windows)

## 📱 Mobile Integration

You can trigger tasks from your mobile device:

```bash
# From your phone's browser or app
curl -X POST http://192.168.15.211:8001/execute \
  -d '{"task":"deploy the frontend"}'
```

Make sure your phone is on the same network.

## 🔄 Task Flow

1. **Task arrives** (from mobile, web, or script)
2. **Agent server receives** it on HTTP API
3. **Kiro executes** the task with full context
4. **Result returned** via API response
5. **Process managed** (can be killed if needed)

## 🛠️ Master Control Script

The `agent-control.sh` script manages all servers:

```bash
# List all projects
./agent-control.sh list

# Start a project
./agent-control.sh start diaperstops

# Stop a project
./agent-control.sh stop diaperstops

# Restart a project
./agent-control.sh restart diaperstops

# Check status
./agent-control.sh status

# Test a server
./agent-control.sh test diaperstops

# Start all
./agent-control.sh start-all

# Stop all
./agent-control.sh stop-all
```

## 📝 Configuration

Each project's `start-agent-server.sh` sets:

```bash
export PROJECT_NAME="diaperstops"
export AGENT_PORT=8001
export KIRO_PATH="kiro"
```

You can customize:
- **PROJECT_NAME** - Display name
- **AGENT_PORT** - Port number (must be unique)
- **KIRO_PATH** - Path to Kiro executable

## 🔍 Troubleshooting

### Server won't start
```bash
# Check if port is already in use
lsof -i:8001

# Kill existing process
kill $(lsof -ti:8001)

# Try starting again
./agent-control.sh start diaperstops
```

### Can't connect to API
```bash
# Check if server is running
./agent-control.sh status

# Check logs
tail -f projects/diaperstops.com/agent-server.log
```

### Kiro not found
```bash
# Check Kiro path
which kiro

# Update KIRO_PATH in start-agent-server.sh
export KIRO_PATH="/full/path/to/kiro"
```

### psutil not installed
```bash
# Install Python dependency
pip3 install psutil
```

## 🌐 Machine-Agnostic Design

The system works on:
- ✅ Linux (your main machine)
- ✅ macOS (your MacBook)
- ✅ Windows (with WSL or native Python)

Just make sure:
1. Python 3 is installed
2. Kiro is installed
3. psutil is installed (`pip3 install psutil`)

## 🎯 Use Cases

### Development Workflow
```bash
# Start your project's agent
./agent-control.sh start diaperstops

# Send tasks from anywhere
curl -X POST http://localhost:8001/execute \
  -d '{"task":"run the test suite"}'
```

### Mobile Development
```bash
# From your phone while away from desk
curl -X POST http://192.168.15.211:8001/execute \
  -d '{"task":"deploy to staging"}'
```

### Automated Tasks
```bash
# Cron job or scheduled task
0 * * * * curl -X POST http://localhost:8001/execute \
  -d '{"task":"check for security updates"}'
```

### Multi-Project Orchestration
```bash
# Start all projects
./agent-control.sh start-all

# Send tasks to different projects
curl -X POST http://localhost:8001/execute -d '{"task":"update backend"}'
curl -X POST http://localhost:8002/execute -d '{"task":"update frontend"}'
```

## 📊 Monitoring

### Check All Servers
```bash
./agent-control.sh status
```

### Monitor Processes
```bash
# For a specific project
curl http://localhost:8001/processes | jq '.'
```

### View Logs
```bash
# Real-time logs
tail -f projects/diaperstops.com/agent-server.log

# All logs
cat projects/*/agent-server.log
```

## 🔐 Security Notes

- Servers run on **localhost only** by default
- No authentication (assumes trusted local network)
- For production, add:
  - API key authentication
  - HTTPS/TLS
  - Rate limiting
  - IP whitelisting

## 💡 Tips

1. **Keep servers running** - Start them once and leave them running
2. **Use background mode** - For long-running tasks
3. **Monitor processes** - Check `/processes` endpoint regularly
4. **Use master script** - `agent-control.sh` is your friend
5. **Check logs** - When things go wrong, logs tell the story

## 🚀 Next Steps

1. Start all servers: `./agent-control.sh start-all`
2. Test one: `./agent-control.sh test diaperstops`
3. Send a real task: `curl -X POST http://localhost:8001/execute -d '{"task":"show me the README"}'`
4. Integrate with your mobile app or web UI
5. Set up automated workflows

## 📚 Related Files

- `projects/templates/agent-server.py` - Server template
- `projects/agent-control.sh` - Master control script
- `projects/*/start-agent-server.sh` - Individual startup scripts
- `projects/*/.agent-task.sh` - Task handlers

---

**Status**: ✅ All projects configured and ready to use

**Cost**: $0 (runs locally, uses Kiro)

**Maintenance**: Minimal (just keep servers running)
