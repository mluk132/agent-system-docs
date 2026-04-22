# Agent Queue UI

Mobile-optimized Vercel UI for submitting tasks to Mac workers.

## Features

- 📱 Mobile-first design
- 📊 Real-time worker status with CPU/RAM usage
- 🚀 Task submission with live progress
- 📈 Usage statistics display
- ⚡ Auto-polling for updates

## Deploy

```bash
# Install dependencies
npm install

# Deploy to Vercel
vercel

# Set environment variable
vercel env add BROKER_URL production
# Enter: https://agent-broker.fly.dev

# Deploy production
vercel --prod
```

## Environment Variables

Create `.env.local` for local development:

```bash
BROKER_URL=http://localhost:8080
```

Or set in Vercel dashboard:

```bash
BROKER_URL=https://agent-broker.fly.dev
```

## Local Development

```bash
npm install
npm run dev
```

Open http://localhost:3000

## Usage

1. Open on phone
2. See worker status with live CPU/RAM
3. Select project
4. Enter task
5. Submit and watch progress
6. See final usage stats

## API Routes

- `POST /api/submit` - Submit task to broker
- `GET /api/status/:taskId` - Get task status
- `GET /api/health` - Get worker health

All routes proxy to the Fly.io broker.
