# 🚀 Deployment Guide

Complete guide to deploy the agent system with resource limits and usage reporting.

## 📋 Overview

- **Phone**: Vercel UI (mobile-optimized)
- **Broker**: Fly.io ($1.94/month spot instance)
- **Worker**: Mac (40% CPU/RAM limit)
- **Real-time**: Usage reporting to phone

## 1️⃣ Deploy Fly.io Broker

```bash
cd fly-broker

# Install Fly CLI (if needed)
curl -L https://fly.io/install.sh | sh

# Login
flyctl auth login

# Launch (creates app)
flyctl launch --name agent-broker --region iad

# Deploy
flyctl deploy

# Get URL
flyctl info
# Note the hostname: agent-broker.fly.dev
```

## 2️⃣ Deploy Vercel UI

```bash
cd vercel-ui

# Install Vercel CLI (if needed)
npm i -g vercel

# Login
vercel login

# Deploy
vercel

# Set environment variable
vercel env add BROKER_URL
# Enter: https://agent-broker.fly.dev

# Deploy production
vercel --prod
```

## 3️⃣ Start Mac Worker

```bash
cd mac-worker

# Create .env file
cat > .env << EOF
BROKER_URL=https://agent-broker.fly.dev
CPU_LIMIT=40
RAM_LIMIT=40
POLL_INTERVAL=5
EOF

# Start worker
./start-worker.sh
```

## 🎯 Usage

### From Phone

1. Open Vercel URL: `https://your-app.vercel.app`
2. See worker status with real-time CPU/RAM usage
3. Select project and enter task
4. Submit and watch progress
5. See final usage stats when complete

### Worker Status Display

```
Workers: 1 online

mac-abc123
  CPU: 15.2% / 40% | RAM: 28.5% / 40%
  4.2GB / 16GB
```

### Task Result Display

```
Task ID: task-1234567890
Status: completed
Worker: mac-abc123
  CPU: 18.5% | RAM: 32.1%
Duration: 12.3s
Final Usage: CPU 22.1%, RAM 35.8%
```

## 🔒 Resource Limits

Worker automatically limits itself to:
- **40% CPU**: Prevents system slowdown
- **40% RAM**: Leaves room for other apps

Limits are enforced using:
- `psutil` for monitoring
- `resource.setrlimit()` for RAM limits
- Process-level restrictions

## 📊 Monitoring

### Check Broker Health

```bash
curl https://agent-broker.fly.dev/api/health
```

### Check Task Status

```bash
curl https://agent-broker.fly.dev/api/status/task-123
```

### Worker Logs

```bash
# On Mac
tail -f mac-worker/worker.log
```

### Broker Logs

```bash
flyctl logs
```

## 💰 Cost Breakdown

- Fly.io Broker: $1.94/month (spot instance)
- Vercel UI: $0 (hobby plan)
- Mac Worker: $0 (local)
- **Total: $2/month**

## 🔧 Configuration

### Adjust Resource Limits

Edit `.env`:
```bash
CPU_LIMIT=30  # Use only 30% CPU
RAM_LIMIT=50  # Use up to 50% RAM
```

### Change Poll Interval

```bash
POLL_INTERVAL=10  # Poll every 10 seconds
```

### Add More Workers

On another machine:
```bash
export BROKER_URL=https://agent-broker.fly.dev
export WORKER_ID=mac-office
./start-worker.sh
```

## 🐛 Troubleshooting

### Worker not connecting

```bash
# Check broker is running
curl https://agent-broker.fly.dev/api/health

# Check network
ping agent-broker.fly.dev

# Check worker logs
tail -f worker.log
```

### High resource usage

```bash
# Lower limits
export CPU_LIMIT=20
export RAM_LIMIT=20
./start-worker.sh
```

### Tasks not executing

```bash
# Check agent servers are running
cd ../../
./agent-control.sh status

# Restart agent servers
./agent-control.sh restart-all
```

## 🎉 Done!

You now have:
- ✅ Mobile-optimized UI on Vercel
- ✅ Broker on Fly.io ($2/month)
- ✅ Mac worker with 40% resource limits
- ✅ Real-time usage reporting to phone
- ✅ Complete task execution system

Submit tasks from your phone and watch them execute on your Mac with live resource monitoring!
