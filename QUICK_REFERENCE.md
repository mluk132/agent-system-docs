# ⚡ Quick Reference Card

## 🎯 System Status
✅ **ALL 33 PROJECTS CONFIGURED AND READY**

## 📖 Documentation
- **[START_HERE.md](START_HERE.md)** - Main entry point
- **[READY_TO_DEPLOY.md](READY_TO_DEPLOY.md)** - Complete guide
- **[ENVIRONMENT_SETUP_COMPLETE.md](ENVIRONMENT_SETUP_COMPLETE.md)** - Setup status

## 🚀 Quick Commands

### Test a Backend (30 seconds)
```bash
cd diaperstops-backend/backend && npm run dev
curl http://localhost:8082/health
```

### Deploy Broker (5 minutes)
```bash
cd simple-broker-system && ./deploy-all.sh
```

### Start Worker (10 seconds)
```bash
cd simple-broker-system/mac-worker && ./start-worker.sh
```

### Check Environment Status
```bash
./check-env-status.sh
```

## 📊 Backend Services

| Service | Port | Command |
|---------|------|---------|
| propai | 8081 | `cd propai-backend/backend && npm run dev` |
| diaperstops | 8082 | `cd diaperstops-backend/backend && npm run dev` |
| mixflow | 8083 | `cd mixflow-backend/backend && npm run dev` |
| healthflow | 8084 | `cd healthflow-backend/backend && npm run dev` |
| hypnotic | 8085 | `cd hypnotic-backend/backend && npm run dev` |
| finder | 8086 | `cd finder-backend/backend && npm run dev` |

## 🌐 Frontend Services

| Service | Command |
|---------|---------|
| diaperstops-frontend | `cd diaperstops-frontend && npm run dev` |
| mixflow-frontend | `cd mixflow-frontend && npm run dev` |

## 🤖 Agentic Queues

1. code-generation
2. code-review
3. testing
4. documentation
5. refactoring
6. debugging
7. deployment
8. monitoring

## 💰 Cost
**$2-7/month** for all 33 projects

## ✅ What's Configured
- ✅ 6 backends with DATABASE_URL, OPENAI_API_KEY, JWT_SECRET
- ✅ 2 frontends with API URLs
- ✅ Broker system
- ✅ Worker with 40% CPU/RAM limit

## 🎯 Next Step
Read **[READY_TO_DEPLOY.md](READY_TO_DEPLOY.md)** and deploy!
