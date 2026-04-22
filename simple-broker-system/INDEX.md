# 📚 Documentation Index

Complete guide to the resource-limited agent system.

## 🚀 Getting Started

Start here if you're new:

1. **[README.md](README.md)** - Overview and architecture
2. **[QUICK_START.md](QUICK_START.md)** - 5-minute setup guide
3. **[CHECKLIST.md](CHECKLIST.md)** - Step-by-step deployment checklist

## 📖 Core Documentation

### Architecture & Design
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System diagrams and data flow
- **[SUMMARY.md](SUMMARY.md)** - What was built and why
- **[COMPLETE.md](COMPLETE.md)** - Comprehensive reference

### Deployment
- **[DEPLOY.md](DEPLOY.md)** - Full deployment guide
- **[CHECKLIST.md](CHECKLIST.md)** - Deployment checklist

## 📁 Component Documentation

### Fly.io Broker
- **Location**: `fly-broker/`
- **Files**:
  - `server.js` - Express API with usage tracking
  - `fly.toml` - Fly.io configuration
  - `Dockerfile` - Container setup
  - `package.json` - Dependencies
- **Purpose**: Queue tasks and track worker usage
- **Cost**: $1.94/month (spot instance)

### Mac Worker
- **Location**: `mac-worker/`
- **Files**:
  - `worker.py` - Python worker with resource limits
  - `requirements.txt` - Dependencies (psutil, requests)
  - `start-worker.sh` - Startup script
- **Purpose**: Execute tasks with 40% CPU/RAM limits
- **Cost**: $0 (local)

### Vercel UI
- **Location**: `vercel-ui/`
- **Files**:
  - `app/page.tsx` - Main UI with usage display
  - `app/api/` - API routes (submit, status, health)
  - `package.json` - Next.js dependencies
- **Purpose**: Mobile-optimized task submission
- **Cost**: $0 (hobby plan)

## 🎯 Quick Reference

### Key Features
- ✅ 40% CPU/RAM limits (configurable)
- ✅ Real-time usage reporting to phone
- ✅ Mobile-optimized UI
- ✅ $2/month total cost
- ✅ No Temporal needed
- ✅ Simple HTTP polling

### Configuration
```bash
# mac-worker/.env
BROKER_URL=https://agent-broker.fly.dev
CPU_LIMIT=40
RAM_LIMIT=40
POLL_INTERVAL=5
```

### API Endpoints
```
Broker (Fly.io):
  POST /api/submit              - Submit task
  GET  /api/status/:taskId      - Get status
  GET  /api/health              - Worker health
  POST /api/worker/register     - Register worker
  POST /api/worker/poll         - Poll for tasks
  POST /api/worker/result       - Report result

Vercel UI:
  POST /api/submit              - Proxy to broker
  GET  /api/status/:taskId      - Proxy to broker
  GET  /api/health              - Proxy to broker
```

## 🔍 Find What You Need

### I want to...

**Deploy the system**
→ Start with [QUICK_START.md](QUICK_START.md)
→ Use [CHECKLIST.md](CHECKLIST.md) for step-by-step

**Understand the architecture**
→ Read [ARCHITECTURE.md](ARCHITECTURE.md)
→ See [README.md](README.md) for overview

**Configure resource limits**
→ See [DEPLOY.md](DEPLOY.md) Configuration section
→ Check [COMPLETE.md](COMPLETE.md) for details

**Troubleshoot issues**
→ Check [DEPLOY.md](DEPLOY.md) Troubleshooting section
→ See [CHECKLIST.md](CHECKLIST.md) Step 8

**Understand what was built**
→ Read [SUMMARY.md](SUMMARY.md)
→ See [COMPLETE.md](COMPLETE.md)

**Monitor the system**
→ See [DEPLOY.md](DEPLOY.md) Monitoring section
→ Check [ARCHITECTURE.md](ARCHITECTURE.md) for monitoring points

**Adjust costs**
→ See [COMPLETE.md](COMPLETE.md) Cost Breakdown
→ Check [ARCHITECTURE.md](ARCHITECTURE.md) Cost Analysis

## 📊 Documentation Map

```
simple-broker-system/
│
├── 🚀 Getting Started
│   ├── README.md           (Start here)
│   ├── QUICK_START.md      (5-minute setup)
│   └── CHECKLIST.md        (Deployment steps)
│
├── 📖 Reference
│   ├── ARCHITECTURE.md     (System design)
│   ├── DEPLOY.md          (Full deployment)
│   ├── COMPLETE.md        (Comprehensive guide)
│   └── SUMMARY.md         (What was built)
│
├── 🔧 Components
│   ├── fly-broker/        (Fly.io broker)
│   ├── mac-worker/        (Mac worker)
│   └── vercel-ui/         (Phone UI)
│
└── 📚 This File
    └── INDEX.md           (You are here)
```

## 🎓 Learning Path

### Beginner
1. Read [README.md](README.md) - Understand what it does
2. Follow [QUICK_START.md](QUICK_START.md) - Deploy in 5 minutes
3. Use [CHECKLIST.md](CHECKLIST.md) - Verify everything works

### Intermediate
1. Read [ARCHITECTURE.md](ARCHITECTURE.md) - Understand how it works
2. Read [DEPLOY.md](DEPLOY.md) - Learn deployment details
3. Experiment with configuration options

### Advanced
1. Read [COMPLETE.md](COMPLETE.md) - Deep dive into implementation
2. Read [SUMMARY.md](SUMMARY.md) - Understand design decisions
3. Modify and extend the system

## 🔗 External Resources

### Fly.io
- Docs: https://fly.io/docs/
- Pricing: https://fly.io/docs/about/pricing/
- CLI: https://fly.io/docs/hands-on/install-flyctl/

### Vercel
- Docs: https://vercel.com/docs
- Next.js: https://nextjs.org/docs
- Deployment: https://vercel.com/docs/deployments/overview

### Python
- psutil: https://psutil.readthedocs.io/
- requests: https://requests.readthedocs.io/
- resource: https://docs.python.org/3/library/resource.html

## 💡 Tips

### For Quick Deployment
→ Use [QUICK_START.md](QUICK_START.md)

### For Understanding
→ Start with [README.md](README.md), then [ARCHITECTURE.md](ARCHITECTURE.md)

### For Troubleshooting
→ Check [DEPLOY.md](DEPLOY.md) Troubleshooting section

### For Reference
→ Bookmark [COMPLETE.md](COMPLETE.md)

## 📞 Support

### Common Issues

**Worker not connecting**
→ See [DEPLOY.md](DEPLOY.md) Troubleshooting

**High resource usage**
→ See [COMPLETE.md](COMPLETE.md) Configuration Options

**Tasks not executing**
→ See [CHECKLIST.md](CHECKLIST.md) Step 8

**Deployment errors**
→ Follow [CHECKLIST.md](CHECKLIST.md) step-by-step

## ✅ Checklist

Before you start:
- [ ] Read [README.md](README.md)
- [ ] Follow [QUICK_START.md](QUICK_START.md)
- [ ] Complete [CHECKLIST.md](CHECKLIST.md)

After deployment:
- [ ] Bookmark [COMPLETE.md](COMPLETE.md) for reference
- [ ] Save [ARCHITECTURE.md](ARCHITECTURE.md) for understanding
- [ ] Keep [DEPLOY.md](DEPLOY.md) for troubleshooting

## 🎉 Ready to Start?

1. **New user?** → Start with [README.md](README.md)
2. **Want to deploy?** → Go to [QUICK_START.md](QUICK_START.md)
3. **Need details?** → Check [COMPLETE.md](COMPLETE.md)
4. **Have issues?** → See [DEPLOY.md](DEPLOY.md)

---

**Total Cost**: $2/month
**Setup Time**: 5 minutes
**Complexity**: Simple (no Temporal, no Docker)
**Features**: Resource limits + usage reporting

Let's build! 🚀
