# 🔐 Environment Variables Needed Across All Projects

## 📊 Summary

All backend services follow the same pattern and need:
1. **Database URL** (Neon PostgreSQL with pgvector)
2. **OpenAI API Key**
3. **JWT Secret** (for authentication)
4. **Port** (unique per service)

## 🗄️ Backend Services (6 services)

### Common Variables for All Backends:
```bash
# Database - Neon PostgreSQL
DATABASE_URL=postgresql://user:password@host.neon.tech/dbname?sslmode=require

# OpenAI API
OPENAI_API_KEY=sk-proj-...
OPENAI_MODEL=gpt-4o-mini
EMBEDDING_MODEL=text-embedding-3-small

# Authentication
JWT_SECRET=<generate with: openssl rand -base64 32>

# Rate Limits
DAILY_CALL_LIMIT=100
MONTHLY_TOKEN_LIMIT=1000000

# Demo Mode
DEMO_USER_ID=00000000-0000-0000-0000-000000000000
```

### Service-Specific Ports:

| Service | Port | App Name | Fly.io URL |
|---------|------|----------|------------|
| propai-backend | 8081 | propai | finance-api-divine-frost-6922.fly.dev |
| diaperstops-backend | 8082 | diaperstops | diaperstops-api.fly.dev |
| mixflow-backend | 8083 | mixflow | mixflow-api.fly.dev |
| healthflow-backend | 8084 | healthflow | health-fit-api.fly.dev |
| hypnotic-backend | 8085 | hypnotic | hypermedia-oasis-api.fly.dev |
| finder-backend | 8086 | finder | lush-playground-api.fly.dev |

## 🌐 Frontend Services (2 services)

### diaperstops-frontend
```bash
NEXT_PUBLIC_API_URL=https://diaperstops-api.fly.dev
NEXT_PUBLIC_DEMO_USER_ID=00000000-0000-0000-0000-000000000000
```

### mixflow-frontend
```bash
NEXT_PUBLIC_API_URL=https://mixflow-api.fly.dev
NEXT_PUBLIC_DEMO_USER_ID=00000000-0000-0000-0000-000000000000
```

## 🚀 Broker System

### simple-broker-system/vercel-ui
```bash
BROKER_URL=https://your-broker.fly.dev
```

### simple-broker-system/mac-worker
```bash
BROKER_URL=https://your-broker.fly.dev
CPU_LIMIT=40
RAM_LIMIT=40
POLL_INTERVAL=5
WORKER_ID=linux-droid
```

## 📱 Full-Stack Projects

### diaperstops.com
- Backend: Java/Spring Boot (needs separate configuration)
- Frontend: Next.js (see diaperstops-frontend above)
- Location: `projects/diaperstops.com/backend/java-pipeline/`

### mixflow.io
- Backend: Python/Flask (AWS Lambda or Fly.io)
- Frontend: Next.js
- Android: Kotlin/Jetpack Compose
- iOS: Swift/SwiftUI

### reno-app
- React Native mobile app
- Needs backend API configuration

## 🔑 Required Credentials to Obtain

### 1. Neon PostgreSQL Database URLs
- Sign up at: https://console.neon.tech
- Create databases for each service:
  - propai-db
  - diaperstops-db
  - mixflow-db
  - healthflow-db
  - hypnotic-db
  - finder-db
- Enable pgvector extension on each database
- Copy connection strings

### 2. OpenAI API Key
- Get from: https://platform.openai.com/api-keys
- One key can be shared across all services
- Recommended model: gpt-4o-mini (cost-effective)

### 3. JWT Secrets
- Generate unique secret for each service:
```bash
openssl rand -base64 32
```
- Store securely (use Doppler or similar)

### 4. Fly.io Deployment
- Each backend needs Fly.io app created
- Set secrets with:
```bash
fly secrets set DATABASE_URL=... OPENAI_API_KEY=... JWT_SECRET=... --app <app-name>
```

## 🎯 Next Steps

### Option 1: Use Doppler (Recommended)
Since Doppler is already configured on GitHub:
1. Install Doppler CLI: `curl -Ls https://cli.doppler.com/install.sh | sh`
2. Login: `doppler login`
3. Pull secrets: `doppler secrets download --no-file --format env > .env`
4. Secrets automatically available in all projects

### Option 2: Manual Setup
1. Create `.env` files in each project from `.env.example`
2. Fill in real values for:
   - DATABASE_URL (from Neon)
   - OPENAI_API_KEY (from OpenAI)
   - JWT_SECRET (generate with openssl)
3. Never commit `.env` files (already in .gitignore)

### Option 3: GitHub Secrets
Since Doppler is configured on GitHub:
1. Go to each repo's Settings → Secrets
2. Secrets should already be synced from Doppler
3. Use in GitHub Actions workflows

## 🧪 Testing Locally

### Test a Backend Service:
```bash
cd projects/diaperstops-backend/backend
npm install
# Create .env file with required variables
npm run dev
# Should start on http://localhost:8082
```

### Test a Frontend:
```bash
cd projects/diaperstops-frontend
npm install
# Create .env.local with NEXT_PUBLIC_API_URL
npm run dev
# Should start on http://localhost:3000
```

## 🤖 Agentic Worker Integration

Once environment variables are set, the worker can:
- ✅ Run any project locally
- ✅ Execute tasks with proper credentials
- ✅ Test changes before deployment
- ✅ Deploy to Fly.io/Vercel with secrets

## 💡 Pro Tips

1. **Use Doppler** - Already configured, just need to pull secrets
2. **One OpenAI key** - Share across all services to save costs
3. **Unique JWT secrets** - Each service should have its own
4. **Demo mode** - Use DEMO_USER_ID for local testing without auth
5. **Port conflicts** - Each backend uses different port (8081-8086)

## 🔒 Security Notes

- Never commit `.env` files
- Never commit API keys or secrets
- Use Doppler or similar for production secrets
- Rotate JWT secrets periodically
- Use strong database passwords
- Enable SSL for all database connections

## 📊 Cost Estimate

- **Neon PostgreSQL**: Free tier (6 databases) or $19/month for all
- **OpenAI API**: ~$0.50-$5/month (depending on usage)
- **Fly.io**: $1.94/month per backend = $11.64/month for 6 backends
- **Vercel**: Free for frontends
- **Total**: ~$13-$35/month for all services

## ✅ Ready to Deploy

Once environment variables are configured:
```bash
cd ~/projects/simple-broker-system
./deploy-all.sh
```

This will deploy the broker system and configure this computer as a worker that can execute tasks on any of the 33 projects!
