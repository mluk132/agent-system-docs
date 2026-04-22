# Simple Broker System (No Temporal)

Direct connection: Phone → Fly.io Broker → Mac Workers

## 🎯 Architecture

```
Phone (Vercel UI) → Fly.io Broker → Mac (40% CPU/RAM) → Workers
   (real-time usage)  (business logic)  (polls every 5s)  (5 projects)
```

## 💡 How It Works

1. **Mac opts in**: Registers with Fly.io broker when available
2. **Phone submits task**: Sends to Fly.io broker via Vercel UI
3. **Broker queues task**: Stores in memory with business logic
4. **Mac polls**: Checks for tasks every 5 seconds
5. **Mac executes**: Runs task on local workers (40% CPU/RAM limit)
6. **Mac reports back**: Sends result + usage stats to broker
7. **Phone sees result**: Real-time updates with CPU/RAM usage

## 🔒 Resource Limits

- **CPU**: 40% maximum usage
- **RAM**: 40% maximum usage
- **Monitoring**: Real-time usage reporting to phone
- **Protection**: Prevents system slowdown

## 💰 Cost

- Fly.io Broker (spot): $1.94/month
- Vercel UI: $0 (hobby plan)
- Mac: $0 (local)
- Workers: $0 (local)
- **Total: $2/month**

## ⚡ One-Line Install

```bash
curl -fsSL https://raw.githubusercontent.com/mluk132/agent-system-docs/main/simple-broker-system/install.sh | bash
```

This installs the worker on your Mac with all dependencies and configuration.

## 🚀 Quick Start

### 1. Deploy Broker

```bash
cd fly-broker
flyctl launch --name agent-broker
flyctl deploy
```

### 2. Deploy UI

```bash
cd vercel-ui
vercel
vercel env add BROKER_URL  # https://agent-broker.fly.dev
vercel --prod
```

### 3. Start Worker

```bash
cd mac-worker
echo "BROKER_URL=https://agent-broker.fly.dev" > .env
./start-worker.sh
```

## 📱 Phone UI Features

- **Worker Status**: See online workers with live CPU/RAM
- **Task Submission**: Select project and enter task
- **Real-time Updates**: Watch task progress
- **Usage Stats**: See final CPU/RAM usage
- **Mobile Optimized**: Works great on phone

## 📊 Usage Reporting

### Worker Display
```
Workers: 1 online

mac-abc123
  CPU: 15.2% / 40% | RAM: 28.5% / 40%
  4.2GB / 16GB
```

### Task Result
```
Status: completed
Duration: 12.3s
Worker: mac-abc123
  CPU: 18.5% | RAM: 32.1%
Final Usage: CPU 22.1%, RAM 35.8%
```

## 🔧 Configuration

Create `mac-worker/.env`:
```bash
BROKER_URL=https://agent-broker.fly.dev
CPU_LIMIT=40
RAM_LIMIT=40
POLL_INTERVAL=5
```

## 📁 Structure

```
simple-broker-system/
├── fly-broker/          # Fly.io broker ($2/month)
│   ├── server.js        # Express API with usage tracking
│   ├── Dockerfile       # Container config
│   ├── fly.toml         # Fly.io config
│   └── package.json
├── mac-worker/          # Mac worker (40% limits)
│   ├── worker.py        # Python worker with psutil
│   ├── requirements.txt # psutil, requests
│   └── start-worker.sh  # Startup script
├── vercel-ui/           # Phone UI (Vercel)
│   ├── app/
│   │   ├── page.tsx     # Main UI with usage display
│   │   └── api/         # Proxy to broker
│   └── package.json
├── README.md            # This file
└── DEPLOY.md            # Deployment guide
```

## 🎯 API Endpoints

### Broker (Fly.io)

- `POST /api/submit` - Submit task
- `GET /api/status/:taskId` - Get task status + usage
- `POST /api/worker/register` - Register worker
- `POST /api/worker/poll` - Poll for tasks (sends usage)
- `POST /api/worker/result` - Report result + usage
- `GET /api/health` - Health check with worker usage

### Vercel UI

- `POST /api/submit` - Proxy to broker
- `GET /api/status/:taskId` - Proxy to broker
- `GET /api/health` - Proxy to broker

## 🐛 Troubleshooting

### Check worker status
```bash
curl https://agent-broker.fly.dev/api/health
```

### Check task status
```bash
curl https://agent-broker.fly.dev/api/status/task-123
```

### Adjust resource limits
```bash
export CPU_LIMIT=30
export RAM_LIMIT=30
./start-worker.sh
```

## 🎉 Features

- ✅ No Temporal (simple HTTP polling)
- ✅ 40% CPU/RAM limits
- ✅ Real-time usage reporting
- ✅ Mobile-optimized UI
- ✅ $2/month total cost
- ✅ Machine-agnostic workers
- ✅ Coffee shop mode (Mac opts in)
- ✅ Business logic in broker
- ✅ Complete monitoring

See [DEPLOY.md](DEPLOY.md) for full deployment guide!
