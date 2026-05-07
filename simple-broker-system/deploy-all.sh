#!/bin/bash
# Auto-deploy everything: Broker + UI + Worker
# Usage: ./deploy-all.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "║     🚀 Auto-Deploy: Broker + UI + Worker                 ║"
echo "║                                                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Check if we're in the right directory
if [ ! -f "deploy-all.sh" ]; then
    echo -e "${RED}❌ Run this from simple-broker-system directory${NC}"
    exit 1
fi

# Check prerequisites
echo -e "${BLUE}📋 Checking prerequisites...${NC}"

if ! command -v flyctl &> /dev/null; then
    echo -e "${RED}❌ Fly CLI not installed${NC}"
    echo "Install: curl -L https://fly.io/install.sh | sh"
    exit 1
fi
echo -e "${GREEN}✅ Fly CLI installed${NC}"

if ! command -v vercel &> /dev/null; then
    echo -e "${RED}❌ Vercel CLI not installed${NC}"
    echo "Install: npm i -g vercel"
    exit 1
fi
echo -e "${GREEN}✅ Vercel CLI installed${NC}"

if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Python 3 installed${NC}"

echo ""

# Check auth
echo -e "${BLUE}🔐 Checking authentication...${NC}"

flyctl auth whoami &> /dev/null || {
    echo -e "${YELLOW}⚠️  Not logged into Fly.io${NC}"
    flyctl auth login
}
echo -e "${GREEN}✅ Fly.io authenticated${NC}"

vercel whoami &> /dev/null || {
    echo -e "${YELLOW}⚠️  Not logged into Vercel${NC}"
    vercel login
}
echo -e "${GREEN}✅ Vercel authenticated${NC}"

echo ""

# Deploy Fly.io Broker
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}📦 Step 1/3: Deploying Fly.io Broker${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""

cd fly-broker

# Check if app exists
APP_NAME="agent-broker-$(whoami)"
if flyctl apps list | grep -q "$APP_NAME"; then
    echo -e "${YELLOW}⚠️  App $APP_NAME already exists${NC}"
    read -p "Redeploy? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Skipping broker deployment${NC}"
        BROKER_URL=$(flyctl apps list | grep "$APP_NAME" | awk '{print "https://"$1".fly.dev"}')
    else
        echo -e "${BLUE}Deploying broker...${NC}"
        flyctl deploy
        BROKER_URL="https://$APP_NAME.fly.dev"
    fi
else
    echo -e "${BLUE}Creating new app: $APP_NAME${NC}"
    flyctl launch --name "$APP_NAME" --region iad --yes --now
    BROKER_URL="https://$APP_NAME.fly.dev"
fi

echo ""
echo -e "${GREEN}✅ Broker deployed: $BROKER_URL${NC}"
echo ""

# Test broker
echo -e "${BLUE}🧪 Testing broker...${NC}"
sleep 3
if curl -s "$BROKER_URL/api/health" | grep -q "ok"; then
    echo -e "${GREEN}✅ Broker is healthy${NC}"
else
    echo -e "${RED}❌ Broker health check failed${NC}"
    exit 1
fi

cd ..
echo ""

# Deploy Vercel UI
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}📱 Step 2/3: Deploying Vercel UI${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""

cd vercel-ui

# Install dependencies
if [ ! -d "node_modules" ]; then
    echo -e "${BLUE}📦 Installing dependencies...${NC}"
    npm install
fi

# Deploy
echo -e "${BLUE}Deploying to Vercel...${NC}"
vercel --yes --prod -e BROKER_URL="$BROKER_URL"

VERCEL_URL=$(vercel ls --yes 2>/dev/null | grep "https://" | head -1 | awk '{print $1}')

echo ""
echo -e "${GREEN}✅ UI deployed: $VERCEL_URL${NC}"
echo ""

cd ..

# Configure Worker
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}🖥️  Step 3/3: Configuring Worker${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""

cd mac-worker

# Install dependencies
echo -e "${BLUE}📦 Installing Python dependencies...${NC}"
pip3 install -q -r requirements.txt

# Create .env
cat > .env << EOF
BROKER_URL=$BROKER_URL
CPU_LIMIT=40
RAM_LIMIT=40
POLL_INTERVAL=5
WORKER_ID=$(hostname)-worker
EOF

echo -e "${GREEN}✅ Worker configured${NC}"
echo ""

cd ..

# Summary
echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "║     ✅ Deployment Complete!                               ║"
echo "║                                                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "${GREEN}📊 Deployment Summary:${NC}"
echo ""
echo -e "${BLUE}Broker:${NC}  $BROKER_URL"
echo -e "${BLUE}UI:${NC}      $VERCEL_URL"
echo -e "${BLUE}Worker:${NC}  Configured (not started)"
echo ""
echo -e "${YELLOW}📝 Save these URLs:${NC}"
echo ""
echo "export BROKER_URL=\"$BROKER_URL\""
echo "export VERCEL_URL=\"$VERCEL_URL\""
echo ""
echo -e "${BLUE}🚀 Next Steps:${NC}"
echo ""
echo "1. Start agent servers:"
echo -e "   ${CYAN}cd ~/projects && ./agent-control.sh start-all${NC}"
echo ""
echo "2. Start worker:"
echo -e "   ${CYAN}cd mac-worker && ./start-worker.sh${NC}"
echo ""
echo "3. Open UI on phone:"
echo -e "   ${CYAN}$VERCEL_URL${NC}"
echo ""
echo -e "${GREEN}🎉 Ready to submit tasks!${NC}"
echo ""

# Save URLs to file
cat > deployment-urls.txt << EOF
Broker URL: $BROKER_URL
Vercel URL: $VERCEL_URL
Deployed: $(date)
EOF

echo -e "${BLUE}💾 URLs saved to: deployment-urls.txt${NC}"
echo ""
