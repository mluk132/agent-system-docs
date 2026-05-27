# 🔑 Get Missing Credentials Guide

## Current Status

✅ **Completed:**
- All `.env` files created
- Unique JWT secrets generated for each backend
- Local development URLs configured
- Frontend environment files set up
- Broker system configured

❌ **Still Needed:**
- DATABASE_URL for 6 backend services
- OPENAI_API_KEY (one key for all services)
- Broker URL (after Fly.io deployment)

## 📊 Quick Summary

| Service | Port | .env Status | DATABASE_URL | OPENAI_API_KEY | JWT_SECRET |
|---------|------|-------------|--------------|----------------|------------|
| propai-backend | 8081 | ✅ | ❌ | ❌ | ✅ |
| diaperstops-backend | 8082 | ✅ | ❌ | ❌ | ✅ |
| mixflow-backend | 8083 | ✅ | ❌ | ❌ | ✅ |
| healthflow-backend | 8084 | ✅ | ❌ | ❌ | ✅ |
| hypnotic-backend | 8085 | ✅ | ❌ | ❌ | ✅ |
| finder-backend | 8086 | ✅ | ❌ | ❌ | ✅ |

## 🗄️ Step 1: Get Database URLs from Neon

### Option A: Use Existing Databases (Recommended)

We found existing database credentials in:
- `mixflow.io/backend/.env.neon`
- `diaperstops.com/backend/.env.neon`

These can be reused! Just copy them to the new backend services.

### Option B: Create New Databases

1. Go to: https://console.neon.tech
2. Login with your account
3. Create 6 new databases:
   - `propai-db`
   - `diaperstops-db`
   - `mixflow-db`
   - `healthflow-db`
   - `hypnotic-db`
   - `finder-db`

4. For each database:
   - Click "Connection Details"
   - Copy the connection string
   - Enable pgvector extension:
     ```sql
     CREATE EXTENSION IF NOT EXISTS vector;
     ```

5. Add to each backend's `.env` file:
   ```bash
   DATABASE_URL=postgresql://user:password@host.neon.tech/dbname?sslmode=require
   ```

### Quick Copy Script

If you want to reuse existing database:

```bash
# Copy existing Neon database URL to all backends
EXISTING_DB_URL=$(grep "^DATABASE_URL=" mixflow.io/backend/.env.neon | cut -d'=' -f2-)

# Update all backend .env files
for backend in propai-backend diaperstops-backend mixflow-backend healthflow-backend hypnotic-backend finder-backend; do
  sed -i "s|DATABASE_URL=.*|DATABASE_URL=$EXISTING_DB_URL|" "$backend/backend/.env"
  echo "✅ Updated $backend"
done
```

## 🤖 Step 2: Get OpenAI API Key

### Option A: Use Existing Key

Check if you have an existing OpenAI API key in:
- GitHub Secrets (if Doppler is synced)
- Environment variables on deployed services
- Local `.env` files in other projects

### Option B: Create New Key

1. Go to: https://platform.openai.com/api-keys
2. Login with your OpenAI account
3. Click "Create new secret key"
4. Name it: "Backend Services Key"
5. Copy the key (starts with `sk-proj-...`)
6. Add to all backend `.env` files:
   ```bash
   OPENAI_API_KEY=sk-proj-your-key-here
   ```

### Quick Add Script

```bash
# Add OpenAI key to all backends
read -p "Enter your OpenAI API key: " OPENAI_KEY

for backend in propai-backend diaperstops-backend mixflow-backend healthflow-backend hypnotic-backend finder-backend; do
  sed -i "s|OPENAI_API_KEY=.*|OPENAI_API_KEY=$OPENAI_KEY|" "$backend/backend/.env"
  echo "✅ Updated $backend"
done
```

## 🚀 Step 3: Deploy Broker to Fly.io

Once you have the credentials, deploy the broker:

```bash
cd simple-broker-system/fly-broker

# Login to Fly.io
flyctl auth login

# Deploy
flyctl launch --name agent-broker-droid --region iad --yes
flyctl deploy

# Get the URL
flyctl info
# Note the hostname: agent-broker-droid.fly.dev
```

Then update the broker URL:

```bash
# Update vercel-ui
sed -i 's|BROKER_URL=.*|BROKER_URL=https://agent-broker-droid.fly.dev|' simple-broker-system/vercel-ui/.env.local

# Update worker
sed -i 's|BROKER_URL=.*|BROKER_URL=https://agent-broker-droid.fly.dev|' simple-broker-system/mac-worker/.env
```

## 🧪 Step 4: Test Locally

### Test a Backend:

```bash
cd diaperstops-backend/backend
npm install
npm run dev
```

Should see:
```
DiaperStops API running on port 8082
Swagger UI: http://localhost:8082/api-docs
Database: Connected
```

### Test Health Endpoint:

```bash
curl http://localhost:8082/health
```

Should return:
```json
{
  "status": "ok",
  "project": "DiaperStops",
  "timestamp": "2025-05-23T...",
  "database": "configured"
}
```

### Test Frontend:

```bash
cd diaperstops-frontend
npm install
npm run dev
```

Open: http://localhost:3000

## 🔄 Using Doppler (Alternative)

If Doppler is configured on GitHub:

```bash
# Install Doppler CLI
curl -Ls https://cli.doppler.com/install.sh | sh

# Login
doppler login

# Setup for each project
cd diaperstops-backend/backend
doppler setup

# Pull secrets
doppler secrets download --no-file --format env > .env

# Repeat for other backends
```

## 📊 Verification Checklist

Run this to verify everything is set up:

```bash
cd ~/projects
./check-env-status.sh
```

Should show all ✅ for:
- .env files exist
- DATABASE_URL configured
- OPENAI_API_KEY configured
- JWT_SECRET configured

## 🎯 Next Steps After Setup

Once all credentials are configured:

1. **Test all backends locally:**
   ```bash
   # Terminal 1
   cd diaperstops-backend/backend && npm run dev
   
   # Terminal 2
   cd mixflow-backend/backend && npm run dev
   
   # etc...
   ```

2. **Deploy broker system:**
   ```bash
   cd simple-broker-system
   ./deploy-all.sh
   ```

3. **Start worker:**
   ```bash
   cd simple-broker-system/mac-worker
   ./start-worker.sh
   ```

4. **Submit test task from phone:**
   - Open Vercel UI URL
   - Toggle "🤖 Agentic Mode"
   - Submit: "Create health check endpoint"
   - Watch worker execute with Kiro!

## 💰 Cost Breakdown

- **Neon PostgreSQL**: Free tier (6 databases) or $19/month
- **OpenAI API**: ~$0.50-$5/month (gpt-4o-mini is cheap!)
- **Fly.io Broker**: $1.94/month
- **Vercel**: Free
- **Worker**: Free (runs locally)

**Total: $2-$25/month** depending on database tier

## 🔒 Security Notes

- Never commit `.env` files (already in .gitignore)
- Rotate JWT secrets periodically
- Use strong database passwords
- Enable 2FA on Neon and OpenAI accounts
- Monitor API usage to avoid unexpected charges

## 📞 Need Help?

If you get stuck:

1. Check logs: `tail -f ~/worker/worker.log`
2. Test database connection: `psql $DATABASE_URL -c "SELECT 1"`
3. Test OpenAI key: `curl https://api.openai.com/v1/models -H "Authorization: Bearer $OPENAI_API_KEY"`
4. Check broker health: `curl https://agent-broker-droid.fly.dev/api/health`

## ✅ You're Ready!

Once you complete these steps, you'll have:
- ✅ 6 backend services ready to run
- ✅ 2 frontend services configured
- ✅ Broker system deployed
- ✅ Worker ready to execute tasks
- ✅ Agentic system with auto tests/docs
- ✅ All 33 projects ready for development

🚀 Let's build something amazing!
