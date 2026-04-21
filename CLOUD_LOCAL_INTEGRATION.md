# Cloud + Local Agent Integration

How the local agent servers integrate with the cloud-based task queue system.

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     CLOUD LAYER                              │
│                                                              │
│  Mobile/Web → Vercel UI → GitHub Repo (Queue)              │
│  https://web-i83kjfhnn-mluk132s-projects.vercel.app        │
│  https://github.com/mluk132/agent-queue                     │
└─────────────────────────────────────────────────────────────┘
                            ↓
                    (Worker polls)
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                     LOCAL LAYER                              │
│                                                              │
│  Worker → Detects task → Calls local API                   │
│                            ↓                                 │
│           agent-server.py (localhost:800X)                  │
│                            ↓                                 │
│                    Kiro Execute                             │
│                            ↓                                 │
│                    Your Code/Tasks                          │
└─────────────────────────────────────────────────────────────┘
```

## 🔄 Integration Options

### Option 1: Direct Local (Current)
```bash
# Start local servers
./agent-control.sh start-all

# Call directly
curl -X POST http://localhost:8001/execute -d '{"task":"..."}'
```

**Pros:**
- ✅ Zero cost
- ✅ Instant response
- ✅ Full control
- ✅ No internet needed

**Cons:**
- ❌ Must be on same network
- ❌ No remote access

### Option 2: Cloud Queue + Local Execution
```bash
# Start local servers
./agent-control.sh start-all

# Start cloud worker (polls GitHub)
cd projects/simple-cloud-agent/worker
python3 worker-simple.py
```

**Pros:**
- ✅ Remote access (from anywhere)
- ✅ Public URL (Vercel)
- ✅ Task queue (GitHub)
- ✅ Still executes locally

**Cons:**
- ⚠️ Requires internet
- ⚠️ Slight delay (polling)

### Option 3: Hybrid (Best of Both)
```bash
# Start local servers
./agent-control.sh start-all

# Start cloud worker
cd projects/simple-cloud-agent/worker
python3 worker-simple.py

# Now you can:
# 1. Call local API directly (fast)
# 2. Use Vercel UI (remote)
# 3. Both work!
```

## 🔧 Setting Up Hybrid Mode

### 1. Start Local Servers
```bash
cd ~/projects
./agent-control.sh start-all
```

### 2. Update Cloud Worker

The cloud worker needs to call local APIs instead of executing directly.

Edit `projects/simple-cloud-agent/worker/worker-simple.py`:

```python
import requests

def execute_task(task, project):
    """Execute task via local agent API"""
    
    # Map project to port
    ports = {
        'diaperstops': 8001,
        'reno-app': 8002,
        'climate': 8003,
        'translator': 8004,
        'android': 8005
    }
    
    port = ports.get(project, 8001)
    
    # Call local API
    response = requests.post(
        f'http://localhost:{port}/execute',
        json={'task': task, 'background': False}
    )
    
    return response.json()
```

### 3. Start Cloud Worker
```bash
cd projects/simple-cloud-agent/worker
python3 worker-simple.py
```

### 4. Use Vercel UI
Open: https://web-i83kjfhnn-mluk132s-projects.vercel.app

Submit a task → Worker polls GitHub → Calls local API → Executes with Kiro

## 📱 Mobile Access Patterns

### Pattern 1: Same Network (Direct)
```bash
# From phone on same WiFi
curl -X POST http://192.168.15.211:8001/execute \
  -d '{"task":"deploy frontend"}'
```

### Pattern 2: Remote (Via Cloud)
```bash
# From anywhere in the world
# Use Vercel UI or:
curl -X POST https://web-i83kjfhnn-mluk132s-projects.vercel.app/api/submit \
  -d '{"prompt":"deploy frontend","project":"diaperstops"}'
```

### Pattern 3: Mobile Prompt Server (Existing)
```bash
# Start the simple mobile server
cd projects/mobile-prompt-server
python3 simple-server.py

# Access from phone
http://192.168.15.211:5000
```

## 🎯 Recommended Setup

For maximum flexibility:

```bash
# Terminal 1: Start all local agent servers
cd ~/projects
./agent-control.sh start-all

# Terminal 2: Start cloud worker (optional, for remote access)
cd projects/simple-cloud-agent/worker
python3 worker-simple.py

# Terminal 3: Start mobile prompt server (optional, for simple UI)
cd projects/mobile-prompt-server
python3 simple-server.py
```

Now you have:
- ✅ Local API access (fast, direct)
- ✅ Remote access via Vercel (from anywhere)
- ✅ Simple mobile UI (on local network)
- ✅ All options available

## 🔀 Task Routing

### By Network Location

**On same network:**
```bash
# Use local API (fastest)
curl http://192.168.15.211:8001/execute -d '{"task":"..."}'
```

**Remote:**
```bash
# Use Vercel UI (goes through GitHub queue)
curl https://web-i83kjfhnn-mluk132s-projects.vercel.app/api/submit \
  -d '{"prompt":"...","project":"diaperstops"}'
```

### By Project

```bash
# diaperstops
curl http://localhost:8001/execute -d '{"task":"..."}'

# reno-app
curl http://localhost:8002/execute -d '{"task":"..."}'

# ClimateWardrobe
curl http://localhost:8003/execute -d '{"task":"..."}'

# translator
curl http://localhost:8004/execute -d '{"task":"..."}'

# android-app-template
curl http://localhost:8005/execute -d '{"task":"..."}'
```

## 🔄 Data Flow Examples

### Example 1: Local Direct
```
Phone (WiFi) → http://192.168.15.211:8001/execute
                      ↓
              agent-server.py (port 8001)
                      ↓
                 Kiro Execute
                      ↓
              diaperstops.com code
```

### Example 2: Remote via Cloud
```
Phone (4G) → Vercel UI → GitHub Issue
                              ↓
                    Worker polls GitHub
                              ↓
              http://localhost:8001/execute
                              ↓
                      agent-server.py
                              ↓
                         Kiro Execute
                              ↓
                  diaperstops.com code
```

### Example 3: Mobile Prompt Server
```
Phone (WiFi) → http://192.168.15.211:5000
                      ↓
              simple-server.py
                      ↓
         (You choose: local API or cloud)
```

## 🛠️ Configuration

### Local Agent Servers
Each project's `start-agent-server.sh`:
```bash
export PROJECT_NAME="diaperstops"
export AGENT_PORT=8001
export KIRO_PATH="kiro"
```

### Cloud Worker
`projects/simple-cloud-agent/worker/worker-simple.py`:
```python
GITHUB_TOKEN = "YOUR_GITHUB_TOKEN_HERE"
REPO = "mluk132/agent-queue"
```

### Mobile Prompt Server
`projects/mobile-prompt-server/simple-server.py`:
```python
PORT = 5000
HOST = '0.0.0.0'  # Listen on all interfaces
```

## 📊 Comparison

| Feature | Local API | Cloud Queue | Mobile Server |
|---------|-----------|-------------|---------------|
| Speed | ⚡ Instant | 🐌 ~30s delay | ⚡ Instant |
| Remote Access | ❌ No | ✅ Yes | ❌ No |
| Cost | $0 | $0 | $0 |
| Setup | Easy | Medium | Easy |
| Reliability | High | Medium | High |
| Process Control | ✅ Yes | ✅ Yes | ❌ No |

## 🎯 Use Case Recommendations

### Use Local API When:
- On same network as machine
- Need instant response
- Want process control
- Developing/testing

### Use Cloud Queue When:
- Away from home/office
- Need remote access
- Want task history (GitHub issues)
- Multiple machines

### Use Mobile Server When:
- Want simple UI
- On same network
- Don't need process control
- Quick one-off tasks

## 🔐 Security Considerations

### Local API
- Binds to localhost by default
- No authentication
- Trusted local network only

### Cloud Queue
- GitHub token in code (⚠️ keep private)
- Public Vercel URL (anyone can submit)
- Consider adding authentication

### Mobile Server
- Binds to 0.0.0.0 (all interfaces)
- No authentication
- Only use on trusted networks

## 🚀 Getting Started

### Minimal Setup (Local Only)
```bash
./agent-control.sh start-all
```

### Full Setup (All Options)
```bash
# Terminal 1: Local servers
./agent-control.sh start-all

# Terminal 2: Cloud worker
cd projects/simple-cloud-agent/worker
python3 worker-simple.py

# Terminal 3: Mobile server
cd projects/mobile-prompt-server
python3 simple-server.py
```

### Test Everything
```bash
# Test local API
curl http://localhost:8001/

# Test cloud (submit via Vercel UI)
# Open: https://web-i83kjfhnn-mluk132s-projects.vercel.app

# Test mobile server
# Open: http://192.168.15.211:5000
```

## 📚 Related Documentation

- [Agent Servers Guide](AGENT_SERVERS_GUIDE.md) - Local API system
- [Agent Quick Reference](AGENT_QUICK_REF.md) - Quick commands
- [Temporal Agent Orchestrator](temporal-agent-orchestrator/FINAL_SUMMARY.md) - Cloud system
- [Simple Cloud Agent](simple-cloud-agent/README.md) - GitHub queue system
- [Mobile Prompt Server](mobile-prompt-server/README.md) - Simple mobile UI

---

**Recommendation**: Start with local API for development, add cloud queue when you need remote access.

**Cost**: $0 for all options

**Maintenance**: Keep local servers running, cloud worker optional
