# 🚀 One-Line Install

## Install Everything

```bash
curl -fsSL https://raw.githubusercontent.com/mluk132/agent-system-docs/main/simple-broker-system/install.sh | bash
```

## What It Does

1. ✅ Checks prerequisites (Python 3, pip3, git)
2. ✅ Clones the repo to `~/simple-broker-system`
3. ✅ Installs Python dependencies (psutil, requests)
4. ✅ Prompts for configuration (broker URL, CPU/RAM limits)
5. ✅ Creates `.env` file
6. ✅ Starts agent servers (if available)
7. ✅ Optionally starts the worker

## After Install

The script installs to: `~/simple-broker-system`

### If you haven't deployed yet:

**Deploy Broker:**
```bash
cd ~/simple-broker-system/fly-broker
flyctl launch --name agent-broker
flyctl deploy
```

**Deploy UI:**
```bash
cd ~/simple-broker-system/vercel-ui
vercel
vercel env add BROKER_URL  # Enter: https://agent-broker.fly.dev
vercel --prod
```

### If you already deployed:

**Start Worker:**
```bash
cd ~/simple-broker-system/mac-worker
./start-worker.sh
```

## Configuration

Edit `~/simple-broker-system/mac-worker/.env`:
```bash
BROKER_URL=https://agent-broker.fly.dev
CPU_LIMIT=40
RAM_LIMIT=40
POLL_INTERVAL=5
```

## Reinstall

```bash
rm -rf ~/simple-broker-system
curl -fsSL https://raw.githubusercontent.com/mluk132/agent-system-docs/main/simple-broker-system/install.sh | bash
```

## Manual Install

If you prefer manual setup:

```bash
git clone https://github.com/mluk132/agent-system-docs.git
cd agent-system-docs/simple-broker-system
pip3 install -r mac-worker/requirements.txt
cd mac-worker
echo "BROKER_URL=https://agent-broker.fly.dev
CPU_LIMIT=40
RAM_LIMIT=40" > .env
./start-worker.sh
```

## Troubleshooting

**Script fails on prerequisites:**
- Install Python 3: https://www.python.org/downloads/
- Install pip3: `python3 -m ensurepip`
- Install git: https://git-scm.com/downloads

**Can't connect to broker:**
- Check broker URL in `.env`
- Verify broker is deployed: `curl https://agent-broker.fly.dev/api/health`

**Agent servers not found:**
- The script looks for `~/projects/agent-control.sh`
- Start servers manually if needed

## What Gets Installed

```
~/simple-broker-system/
├── fly-broker/          # Fly.io broker code
├── mac-worker/          # Mac worker (installed & configured)
│   ├── worker.py
│   ├── requirements.txt
│   ├── start-worker.sh
│   └── .env            # Your configuration
├── vercel-ui/          # Vercel UI code
└── *.md                # Documentation
```

## Quick Commands

**Start worker:**
```bash
cd ~/simple-broker-system/mac-worker && ./start-worker.sh
```

**Check status:**
```bash
curl https://agent-broker.fly.dev/api/health
```

**View logs:**
```bash
tail -f ~/simple-broker-system/mac-worker/worker.log
```

**Update config:**
```bash
nano ~/simple-broker-system/mac-worker/.env
```

## Copy-Paste Ready

### Full Setup (if nothing deployed yet)
```bash
# Install worker
curl -fsSL https://raw.githubusercontent.com/mluk132/agent-system-docs/main/simple-broker-system/install.sh | bash

# Deploy broker
cd ~/simple-broker-system/fly-broker
flyctl launch --name agent-broker && flyctl deploy

# Deploy UI
cd ~/simple-broker-system/vercel-ui
vercel && vercel env add BROKER_URL && vercel --prod

# Start worker
cd ~/simple-broker-system/mac-worker
./start-worker.sh
```

### Quick Install (if broker/UI already deployed)
```bash
curl -fsSL https://raw.githubusercontent.com/mluk132/agent-system-docs/main/simple-broker-system/install.sh | bash
# Enter your broker URL when prompted
# Worker starts automatically
```

## That's It!

One command to install everything. Then deploy broker + UI, and you're done! 🎉
