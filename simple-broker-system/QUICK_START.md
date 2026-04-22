# ⚡ Quick Start

Get up and running in 5 minutes!

## 1️⃣ Deploy Broker (2 min)

```bash
cd fly-broker

# Login to Fly.io
flyctl auth login

# Deploy
flyctl launch --name agent-broker --region iad --yes
flyctl deploy

# Get URL
flyctl info | grep Hostname
# Copy: agent-broker.fly.dev
```

## 2️⃣ Deploy UI (2 min)

```bash
cd vercel-ui

# Login to Vercel
vercel login

# Deploy
vercel --yes

# Add broker URL
vercel env add BROKER_URL production
# Paste: https://agent-broker.fly.dev

# Deploy production
vercel --prod

# Get URL
vercel ls
# Copy your URL
```

## 3️⃣ Start Worker (1 min)

```bash
cd mac-worker

# Configure
cat > .env << EOF
BROKER_URL=https://agent-broker.fly.dev
CPU_LIMIT=40
RAM_LIMIT=40
EOF

# Start
chmod +x start-worker.sh
./start-worker.sh
```

## 🎉 Done!

Open your Vercel URL on your phone and submit a task!

You'll see:
- ✅ Worker online with CPU/RAM usage
- ✅ Task submission form
- ✅ Real-time progress updates
- ✅ Final usage statistics

## 🧪 Test It

### From Phone
1. Open `https://your-app.vercel.app`
2. Select "Diaper Stops"
3. Enter task: "echo Hello from my phone!"
4. Submit and watch

### From Terminal
```bash
# Submit task
curl https://agent-broker.fly.dev/api/submit \
  -H "Content-Type: application/json" \
  -d '{"project":"diaperstops","task":"echo test"}'

# Check status
curl https://agent-broker.fly.dev/api/health
```

## 🔧 Adjust Limits

Want to use less resources?

```bash
# Edit .env
CPU_LIMIT=20
RAM_LIMIT=20

# Restart
./start-worker.sh
```

## 📊 Monitor

### Worker Logs
```bash
tail -f worker.log
```

### Broker Logs
```bash
flyctl logs
```

### Health Check
```bash
curl https://agent-broker.fly.dev/api/health | jq
```

## 🐛 Issues?

### Worker not connecting
```bash
# Check broker
curl https://agent-broker.fly.dev/api/health

# Check worker logs
tail -f worker.log
```

### Agent servers not running
```bash
cd ../../
./agent-control.sh status
./agent-control.sh start-all
```

## 💡 Tips

- **Coffee shop mode**: Worker automatically reconnects when Mac wakes
- **Multiple workers**: Run on multiple Macs with different WORKER_ID
- **Lower costs**: Fly.io spot instances auto-scale to zero when idle
- **Mobile first**: UI is optimized for phone screens

## 📱 Bookmark

Add your Vercel URL to your phone home screen for quick access!

That's it! You now have a complete agent system with resource limits and usage reporting for $2/month.
