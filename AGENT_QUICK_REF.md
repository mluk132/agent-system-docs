# Agent Server Quick Reference

## 🚀 Start/Stop

```bash
# Start all
./agent-control.sh start-all

# Start one
./agent-control.sh start diaperstops

# Stop all
./agent-control.sh stop-all

# Status
./agent-control.sh status
```

## 📋 Projects & Ports

| Project | Port | Command |
|---------|------|---------|
| diaperstops | 8001 | `./agent-control.sh start diaperstops` |
| reno-app | 8002 | `./agent-control.sh start reno-app` |
| ClimateWardrobe | 8003 | `./agent-control.sh start climate` |
| translator | 8004 | `./agent-control.sh start translator` |
| android-app-template | 8005 | `./agent-control.sh start android` |

## 📡 API Calls

```bash
# Execute task
curl -X POST http://localhost:8001/execute \
  -H "Content-Type: application/json" \
  -d '{"task":"your task here"}'

# List processes
curl http://localhost:8001/processes

# Kill process
curl -X POST http://localhost:8001/kill -d '{"pid":12345}'

# Server info
curl http://localhost:8001/
```

## 🔧 Manual Start

```bash
cd projects/diaperstops.com
./start-agent-server.sh
```

## 🐛 Debug

```bash
# Check if running
lsof -i:8001

# View logs
tail -f projects/diaperstops.com/agent-server.log

# Kill stuck server
kill $(lsof -ti:8001)
```

## 📱 From Mobile

```bash
# Replace with your machine's IP
curl -X POST http://192.168.15.211:8001/execute \
  -d '{"task":"deploy frontend"}'
```

## 🎯 Common Tasks

```bash
# Test a server
./agent-control.sh test diaperstops

# Restart a server
./agent-control.sh restart diaperstops

# List all projects
./agent-control.sh list
```
