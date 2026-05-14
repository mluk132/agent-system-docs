# 🚀 Deploy Now - Quick Guide

## Current Status
✅ Worker files copied to `~/worker/`
✅ All code pushed to GitHub
✅ Ready to deploy

## Step 1: Install pip3 (if needed)

```bash
# Try to install pip3
sudo apt-get install python3-pip

# Or download get-pip.py
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py --user
```

## Step 2: Install Worker Dependencies

```bash
cd ~/worker
pip3 install -r requirements.txt
# or
python3 -m pip install -r requirements.txt --user
```

This installs:
- `requests` - For HTTP communication
- `psutil` - For resource monitoring

## Step 3: Deploy Broker to Fly.io

```bash
cd ~/projects/simple-broker-system/fly-broker

# Login to Fly.io
flyctl auth login

# Deploy
flyctl launch --name agent-broker-$(whoami) --region iad --yes
flyctl deploy

# Get URL
flyctl info
# Note the hostname: agent-broker-droid.fly.dev
```

## Step 4: Deploy UI to Vercel

```bash
cd ~/projects/simple-broker-system/vercel-ui

# Login to Vercel
vercel login

# Deploy
vercel --yes

# Set broker URL
vercel env add BROKER_URL production
# Enter: https://agent-broker-droid.fly.dev

# Deploy production
vercel --prod

# Get URL from output
```

## Step 5: Configure Worker

```bash
cd ~/worker

# Create .env file
cat > .env << 'EOF'
BROKER_URL=https://agent-broker-droid.fly.dev
CPU_LIMIT=40
RAM_LIMIT=40
POLL_INTERVAL=5
WORKER_ID=linux-droid
EOF
```

## Step 6: Start Agent Servers

```bash
cd ~/projects
./agent-control.sh start-all

# Verify they're running
./agent-control.sh status
```

## Step 7: Start Worker

```bash
cd ~/worker
./start-worker.sh
```

## What Happens Now

This computer becomes a worker that:

1. **Polls broker** every 5 seconds for tasks
2. **Routes tasks** to specialized queues (code-generation, testing, etc.)
3. **Applies guidelines** based on project (diaperstops, reno-app, etc.)
4. **Uses Kiro locally** to execute tasks
5. **Generates tests** automatically (pytest, Jest, JUnit)
6. **Generates docs** automatically (docstrings, JSDoc, JavaDoc)
7. **Reports results** back to broker with usage stats
8. **Limits resources** to 40% CPU/RAM

## Submit Tasks from Phone

Once deployed, open the Vercel URL on your phone:

1. Select project (diaperstops, reno-app, climate, etc.)
2. Toggle "🤖 Agentic Mode" for auto tests/docs
3. Set priority (low, normal, high, urgent)
4. Enter task: "Create user login endpoint"
5. Submit

The worker will:
- Route to code-generation queue
- Apply Java/Spring Boot guidelines
- Generate JUnit tests
- Generate JavaDoc
- Execute with Kiro
- Report back with results

## Monitor

### Check worker logs:
```bash
tail -f ~/worker/worker.log
```

### Check broker health:
```bash
curl https://agent-broker-droid.fly.dev/api/health | jq
```

### Check queue stats:
```bash
curl https://agent-broker-droid.fly.dev/api/agentic/stats | jq
```

## Quick Deploy Script

Or use the auto-deploy script:

```bash
cd ~/projects/simple-broker-system
./deploy-all.sh
```

This will:
1. Deploy broker to Fly.io
2. Deploy UI to Vercel
3. Configure worker
4. Save all URLs

## Architecture

```
Phone (Vercel UI)
    ↓
Fly.io Broker (Agentic Queues)
    ↓
This Computer (Worker)
    ↓
Kiro (Local Execution)
    ↓
Projects (diaperstops, reno-app, etc.)
```

## Cost

- Fly.io: $1.94/month
- Vercel: $0
- Worker: $0 (local)
- **Total: $2/month**

## Features Active

✅ Priority queues
✅ Task cancellation
✅ Automatic retries
✅ 40% CPU/RAM limits
✅ Real-time usage reporting
✅ **Agentic mode**
✅ **Auto test generation**
✅ **Auto documentation**
✅ **Guidelines enforcement**
✅ **8 specialized queues**

## Ready to Go! 🚀

Follow the steps above and you'll have a complete agentic system running on this computer, taking commands from your phone and improving any project with Kiro!
