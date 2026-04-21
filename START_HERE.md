# 🚀 Agent System - START HERE

Welcome! This is your complete guide to the agent system.

## 📖 What Is This?

A local agent server system that makes all your projects machine-agnostic workers with Kiro integration. You can trigger tasks from mobile, web, or command line, and manage processes (start/stop/kill).

## ⚡ Quick Start (30 seconds)

```bash
# 1. Start all agent servers
cd ~/projects
./agent-control.sh start-all

# 2. Check they're running
./agent-control.sh status

# 3. Execute a test task
curl -X POST http://localhost:8001/execute \
  -H "Content-Type: application/json" \
  -d '{"task":"echo Hello from agent system"}'
```

Done! Your agent system is now running.

## 📚 Documentation Guide

Read in this order:

### 1. Quick Reference (5 minutes)
**File**: [AGENT_QUICK_REF.md](AGENT_QUICK_REF.md)

Quick commands and API calls. Perfect for daily use.

### 2. System Diagram (5 minutes)
**File**: [SYSTEM_DIAGRAM.txt](SYSTEM_DIAGRAM.txt)

Visual overview of the entire system architecture.

### 3. Complete Guide (30 minutes)
**File**: [AGENT_SERVERS_GUIDE.md](AGENT_SERVERS_GUIDE.md)

Everything you need to know about the agent servers. 60+ sections covering all features.

### 4. Deployment Details (15 minutes)
**File**: [AGENT_SYSTEM_DEPLOYED.md](AGENT_SYSTEM_DEPLOYED.md)

What was deployed, how it works, and verification steps.

### 5. Integration Guide (20 minutes)
**File**: [CLOUD_LOCAL_INTEGRATION.md](CLOUD_LOCAL_INTEGRATION.md)

How to integrate local servers with cloud queue and mobile access.

### 6. Final Summary (10 minutes)
**File**: [COMPLETE_AGENT_SYSTEM.md](COMPLETE_AGENT_SYSTEM.md)

Complete overview with use cases, troubleshooting, and next steps.

## 🎯 Common Tasks

### Start/Stop Servers
```bash
# Start all
./agent-control.sh start-all

# Start one
./agent-control.sh start diaperstops

# Stop all
./agent-control.sh stop-all

# Check status
./agent-control.sh status
```

### Execute Tasks
```bash
# Local (fastest)
curl -X POST http://localhost:8001/execute \
  -d '{"task":"run the tests"}'

# From mobile (same network)
curl -X POST http://192.168.15.211:8001/execute \
  -d '{"task":"deploy to staging"}'
```

### Manage Processes
```bash
# List processes
curl http://localhost:8001/processes

# Kill a process
curl -X POST http://localhost:8001/kill -d '{"pid":12345}'

# Stop all processes
curl -X POST http://localhost:8001/stop-all
```

## 🏗️ System Overview

```
Mobile/Web → HTTP API → agent-server.py → Kiro → Your Code
```

### Projects & Ports
- diaperstops: 8001
- reno-app: 8002
- ClimateWardrobe: 8003
- translator: 8004
- android-app-template: 8005

### Key Features
- ✅ Machine-agnostic (Linux, Mac, Windows)
- ✅ Kiro integration (full capabilities)
- ✅ Process management (start/stop/kill)
- ✅ Mobile-friendly (HTTP API)
- ✅ Zero cost ($0 to run)

## 🔧 Master Control

The `agent-control.sh` script manages everything:

```bash
./agent-control.sh start <project>     # Start one
./agent-control.sh stop <project>      # Stop one
./agent-control.sh restart <project>   # Restart one
./agent-control.sh status [project]    # Show status
./agent-control.sh test <project>      # Test API
./agent-control.sh start-all           # Start all
./agent-control.sh stop-all            # Stop all
./agent-control.sh list                # List projects
```

## 📱 Mobile Access

### Same Network (Direct)
```bash
# Get your machine's IP
ip addr show | grep "inet 192"

# Call from phone
curl -X POST http://192.168.15.211:8001/execute \
  -d '{"task":"your task here"}'
```

### Remote (Via Cloud)
Use the Vercel UI:
https://web-i83kjfhnn-mluk132s-projects.vercel.app

## 🐛 Troubleshooting

### Server won't start
```bash
# Check if port is in use
lsof -i:8001

# Kill existing process
kill $(lsof -ti:8001)

# Try again
./agent-control.sh start diaperstops
```

### Can't connect
```bash
# Check status
./agent-control.sh status

# Check logs
tail -f projects/diaperstops.com/agent-server.log
```

### Need help?
Read the [Complete Guide](AGENT_SERVERS_GUIDE.md) for detailed troubleshooting.

## 💡 Tips

1. **Keep servers running** - Start once, use all day
2. **Use master script** - `agent-control.sh` is your friend
3. **Check logs** - When things go wrong, logs tell the story
4. **Test first** - Use `./agent-control.sh test <project>`
5. **Read docs** - Everything is documented

## 🎓 Learning Path

1. ✅ Read this file (you're here!)
2. ⏭️ Start servers: `./agent-control.sh start-all`
3. ⏭️ Test one: `./agent-control.sh test diaperstops`
4. ⏭️ Read [Quick Reference](AGENT_QUICK_REF.md)
5. ⏭️ Try mobile access
6. ⏭️ Read [Complete Guide](AGENT_SERVERS_GUIDE.md)
7. ⏭️ Set up cloud integration (optional)

**Total time**: ~2 hours to master everything

## 📊 What You Have

- ✅ 5 projects configured as agent workers
- ✅ Local HTTP API for each project
- ✅ Master control script
- ✅ Complete documentation (6 files)
- ✅ Kiro integration
- ✅ Process management
- ✅ Mobile access
- ✅ Zero cost

## 🚀 Next Steps

1. **Start the system**
   ```bash
   ./agent-control.sh start-all
   ```

2. **Test it**
   ```bash
   ./agent-control.sh test diaperstops
   ```

3. **Try a real task**
   ```bash
   curl -X POST http://localhost:8001/execute \
     -d '{"task":"show me the project structure"}'
   ```

4. **Read the docs**
   - [Quick Reference](AGENT_QUICK_REF.md) - Daily use
   - [Complete Guide](AGENT_SERVERS_GUIDE.md) - Deep dive

5. **Integrate with mobile**
   - Use your machine's IP
   - Call from phone on same network

## 💰 Cost

**Total: $0**

Everything runs locally. No cloud services, no API fees.

## ✅ Status

**COMPLETE AND READY TO USE**

All 5 projects configured, documented, and tested.

---

**Questions?** Read the [Complete Guide](AGENT_SERVERS_GUIDE.md)

**Need help?** Check [Troubleshooting](AGENT_SERVERS_GUIDE.md#troubleshooting)

**Want more?** See [Integration Guide](CLOUD_LOCAL_INTEGRATION.md)

**Ready?** Run: `./agent-control.sh start-all`
