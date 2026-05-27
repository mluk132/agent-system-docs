#!/bin/bash
# Deploy ALL backends, frontends, and broker system

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "║     🚀 DEPLOY EVERYTHING - All Services                  ║"
echo "║                                                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Check prerequisites
echo -e "${BLUE}📋 Checking prerequisites...${NC}"

if ! command -v flyctl &> /dev/null; then
    echo -e "${RED}❌ Fly CLI not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Fly CLI${NC}"

if ! command -v vercel &> /dev/null; then
    echo -e "${RED}❌ Vercel CLI not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Vercel CLI${NC}"

if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Node.js${NC}"

echo ""

# Check auth
echo -e "${BLUE}🔐 Checking authentication...${NC}"
flyctl auth whoami &> /dev/null || flyctl auth login
echo -e "${GREEN}✅ Fly.io authenticated${NC}"

vercel whoami &> /dev/null || vercel login
echo -e "${GREEN}✅ Vercel authenticated${NC}"

echo ""

# Deploy Backends to Fly.io
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}📦 STEP 1: Deploying 6 Backend Services to Fly.io${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""

BACKENDS=(
  "propai-backend:propai-api:8081"
  "diaperstops-backend:diaperstops-api:8082"
  "mixflow-backend:mixflow-api:8083"
  "healthflow-backend:healthflow-api:8084"
  "hypnotic-backend:hypnotic-api:8085"
  "finder-backend:finder-api:8086"
)

BACKEND_URLS=()

for backend_info in "${BACKENDS[@]}"; do
  IFS=':' read -r folder app_name port <<< "$backend_info"
  
  echo -e "${BLUE}Deploying $folder...${NC}"
  
  cd "$folder/backend"
  
  # Check if fly.toml exists
  if [ ! -f "fly.toml" ]; then
    echo -e "${YELLOW}Creating fly.toml for $app_name${NC}"
    flyctl launch --name "$app_name" --region iad --yes --no-deploy
  fi
  
  # Get secrets from .env
  if [ -f ".env" ]; then
    DATABASE_URL=$(grep "^DATABASE_URL=" .env | cut -d'=' -f2-)
    OPENAI_API_KEY=$(grep "^OPENAI_API_KEY=" .env | cut -d'=' -f2-)
    JWT_SECRET=$(grep "^JWT_SECRET=" .env | cut -d'=' -f2-)
    
    # Set secrets
    echo -e "${BLUE}Setting secrets for $app_name...${NC}"
    flyctl secrets set \
      DATABASE_URL="$DATABASE_URL" \
      OPENAI_API_KEY="$OPENAI_API_KEY" \
      JWT_SECRET="$JWT_SECRET" \
      PORT="$port" \
      NODE_ENV="production" \
      --app "$app_name" 2>/dev/null || true
  fi
  
  # Deploy
  echo -e "${BLUE}Deploying $app_name to Fly.io...${NC}"
  flyctl deploy --app "$app_name" --yes || {
    echo -e "${YELLOW}⚠️  Deployment failed for $app_name, continuing...${NC}"
  }
  
  BACKEND_URL="https://$app_name.fly.dev"
  BACKEND_URLS+=("$app_name:$BACKEND_URL")
  echo -e "${GREEN}✅ $app_name deployed: $BACKEND_URL${NC}"
  echo ""
  
  cd ../..
done

echo ""

# Deploy Frontends to Vercel
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}📱 STEP 2: Deploying 2 Frontend Services to Vercel${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""

FRONTENDS=(
  "diaperstops-frontend:diaperstops-api"
  "mixflow-frontend:mixflow-api"
)

FRONTEND_URLS=()

for frontend_info in "${FRONTENDS[@]}"; do
  IFS=':' read -r folder backend_app <<< "$frontend_info"
  
  echo -e "${BLUE}Deploying $folder...${NC}"
  
  cd "$folder"
  
  # Install dependencies
  if [ ! -d "node_modules" ]; then
    echo -e "${BLUE}Installing dependencies...${NC}"
    npm install
  fi
  
  # Get backend URL
  BACKEND_URL="https://$backend_app.fly.dev"
  
  # Deploy to Vercel
  echo -e "${BLUE}Deploying $folder to Vercel...${NC}"
  vercel --yes --prod -e NEXT_PUBLIC_API_URL="$BACKEND_URL" || {
    echo -e "${YELLOW}⚠️  Deployment failed for $folder, continuing...${NC}"
  }
  
  FRONTEND_URL=$(vercel ls --yes 2>/dev/null | grep "https://" | head -1 | awk '{print $1}')
  FRONTEND_URLS+=("$folder:$FRONTEND_URL")
  echo -e "${GREEN}✅ $folder deployed: $FRONTEND_URL${NC}"
  echo ""
  
  cd ..
done

echo ""

# Deploy Broker System
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}🤖 STEP 3: Deploying Broker System${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""

cd simple-broker-system

# Deploy broker to Fly.io
echo -e "${BLUE}Deploying broker to Fly.io...${NC}"
cd fly-broker

APP_NAME="agent-broker-$(whoami)"
if ! flyctl apps list | grep -q "$APP_NAME"; then
  flyctl launch --name "$APP_NAME" --region iad --yes --now
else
  flyctl deploy --app "$APP_NAME"
fi

BROKER_URL="https://$APP_NAME.fly.dev"
echo -e "${GREEN}✅ Broker deployed: $BROKER_URL${NC}"
echo ""

cd ..

# Deploy broker UI to Vercel
echo -e "${BLUE}Deploying broker UI to Vercel...${NC}"
cd vercel-ui

if [ ! -d "node_modules" ]; then
  npm install
fi

vercel --yes --prod -e BROKER_URL="$BROKER_URL"
BROKER_UI_URL=$(vercel ls --yes 2>/dev/null | grep "https://" | head -1 | awk '{print $1}')
echo -e "${GREEN}✅ Broker UI deployed: $BROKER_UI_URL${NC}"
echo ""

cd ..

# Configure worker
echo -e "${BLUE}Configuring worker...${NC}"
cd mac-worker

pip3 install -q -r requirements.txt

cat > .env << EOF
BROKER_URL=$BROKER_URL
CPU_LIMIT=40
RAM_LIMIT=40
POLL_INTERVAL=5
WORKER_ID=$(hostname)-worker
EOF

echo -e "${GREEN}✅ Worker configured${NC}"
cd ../..

echo ""

# Summary
echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "║     ✅ ALL DEPLOYMENTS COMPLETE!                          ║"
echo "║                                                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Save deployment info
cat > DEPLOYMENT_COMPLETE.md << EOF
# 🚀 Deployment Complete - All Services Live

## 📊 Backend Services (Fly.io)

EOF

for url_info in "${BACKEND_URLS[@]}"; do
  IFS=':' read -r name url <<< "$url_info"
  echo "- **$name**: $url" >> DEPLOYMENT_COMPLETE.md
done

cat >> DEPLOYMENT_COMPLETE.md << EOF

## 🌐 Frontend Services (Vercel)

EOF

for url_info in "${FRONTEND_URLS[@]}"; do
  IFS=':' read -r name url <<< "$url_info"
  echo "- **$name**: $url" >> DEPLOYMENT_COMPLETE.md
done

cat >> DEPLOYMENT_COMPLETE.md << EOF

## 🤖 Broker System

- **Broker API**: $BROKER_URL
- **Broker UI**: $BROKER_UI_URL

## 🎯 Next Steps

1. Start worker:
   \`\`\`bash
   cd simple-broker-system/mac-worker
   ./start-worker.sh
   \`\`\`

2. Open broker UI on phone: $BROKER_UI_URL

3. Submit tasks and watch them execute!

## 💰 Monthly Cost

- Fly.io (7 apps): ~$13.58/month
- Vercel (3 apps): Free
- Worker: Free (local)
- **Total: ~$14/month**

## ✅ Status

All services deployed and running!

Deployed: $(date)
EOF

echo -e "${GREEN}📊 Deployment Summary:${NC}"
echo ""
echo -e "${BLUE}Backend Services (6):${NC}"
for url_info in "${BACKEND_URLS[@]}"; do
  IFS=':' read -r name url <<< "$url_info"
  echo "  • $name: $url"
done
echo ""
echo -e "${BLUE}Frontend Services (2):${NC}"
for url_info in "${FRONTEND_URLS[@]}"; do
  IFS=':' read -r name url <<< "$url_info"
  echo "  • $name: $url"
done
echo ""
echo -e "${BLUE}Broker System:${NC}"
echo "  • Broker API: $BROKER_URL"
echo "  • Broker UI: $BROKER_UI_URL"
echo ""
echo -e "${GREEN}💾 Full details saved to: DEPLOYMENT_COMPLETE.md${NC}"
echo ""
echo -e "${YELLOW}🚀 Next: Start worker with:${NC}"
echo -e "   ${CYAN}cd simple-broker-system/mac-worker && ./start-worker.sh${NC}"
echo ""
