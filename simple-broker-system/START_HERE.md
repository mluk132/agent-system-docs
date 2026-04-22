# 🚀 START HERE

Welcome to the Resource-Limited Agent System!

## 🎯 What Is This?

A complete agent task system that lets you:
- 📱 Submit tasks from your phone
- 🖥️ Execute on your Mac (with 40% CPU/RAM limits)
- 📊 See real-time resource usage
- 💰 Pay only $2/month

## ⚡ One-Line Install

```bash
curl -fsSL https://raw.githubusercontent.com/mluk132/agent-system-docs/main/simple-broker-system/install.sh | bash
```

This will:
- Clone the repo
- Install dependencies (psutil, requests)
- Configure the worker
- Start agent servers
- Optionally start the worker

## 📋 Manual Setup (5 minutes)

### 1. Deploy Broker
```bash
cd fly-broker
flyctl auth login
flyctl launch --name agent-broker --region iad
flyctl deploy
```

### 2. Deploy UI
```bash
cd vercel-ui
vercel login
vercel
vercel env add BROKER_URL  # Enter: https://agent-broker.fly.dev
vercel --prod
```

### 3. Start Worker
```bash
cd mac-worker
echo "BROKER_URL=https://agent-broker.fly.dev
CPU_LIMIT=40
RAM_LIMIT=40" > .env
./start-worker.sh
```

### 4. Test
Open your Vercel URL on your phone and submit a task!

## 📚 Documentation

### New to this project?
1. Read [README.md](README.md) - Overview
2. Follow [QUICK_START.md](QUICK_START.md) - Setup
3. Use [CHECKLIST.md](CHECKLIST.md) - Verify

### Want to understand how it works?
→ Read [ARCHITECTURE.md](ARCHITECTURE.md)

### Need deployment help?
→ Follow [DEPLOY.md](DEPLOY.md)

### Want complete reference?
→ Check [COMPLETE.md](COMPLETE.md)

### Lost?
→ See [INDEX.md](INDEX.md) for navigation

## 🔒 Key Features

- **Resource Limits**: 40% CPU/RAM max (configurable)
- **Usage Reporting**: Real-time stats on phone
- **Mobile First**: Optimized for phone screens
- **Low Cost**: $2/month total
- **Simple**: No Temporal, just HTTP polling

## 💡 What You'll Get

```
Phone UI:
  Workers: 1 online
  
  mac-abc123
    CPU: 15.2% / 40% | RAM: 28.5% / 40%
    4.2GB / 16GB
  
  [Submit Task] → Watch it execute → See results
```

## 🎉 Ready?

Choose your path:

**I want to deploy now**
→ [QUICK_START.md](QUICK_START.md)

**I want to understand first**
→ [README.md](README.md) then [ARCHITECTURE.md](ARCHITECTURE.md)

**I want step-by-step**
→ [CHECKLIST.md](CHECKLIST.md)

**I want everything**
→ [COMPLETE.md](COMPLETE.md)

---

**Cost**: $2/month | **Time**: 5 minutes | **Complexity**: Simple

Let's go! 🚀
