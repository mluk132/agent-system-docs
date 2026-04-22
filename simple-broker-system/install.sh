#!/bin/bash
# One-line installer for simple-broker-system
# Usage: curl -fsSL https://raw.githubusercontent.com/mluk132/agent-system-docs/main/simple-broker-system/install.sh | bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "║     🤖 Simple Broker System Installer                    ║"
echo "║                                                           ║"
echo "║     Resource-limited agent system with usage reporting   ║"
echo "║     Cost: \$2/month | Setup: 5 minutes                    ║"
echo "║                                                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Check prerequisites
echo -e "${BLUE}📋 Checking prerequisites...${NC}"
echo ""

# Check Python
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 not found${NC}"
    echo "Install Python 3: https://www.python.org/downloads/"
    exit 1
fi
echo -e "${GREEN}✅ Python 3: $(python3 --version)${NC}"

# Check pip
if ! command -v pip3 &> /dev/null; then
    echo -e "${RED}❌ pip3 not found${NC}"
    echo "Install pip3: python3 -m ensurepip"
    exit 1
fi
echo -e "${GREEN}✅ pip3: $(pip3 --version | cut -d' ' -f2)${NC}"

# Check git
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ git not found${NC}"
    echo "Install git: https://git-scm.com/downloads"
    exit 1
fi
echo -e "${GREEN}✅ git: $(git --version | cut -d' ' -f3)${NC}"

echo ""

# Clone repo
echo -e "${BLUE}📦 Cloning repository...${NC}"
INSTALL_DIR="${HOME}/simple-broker-system"

if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}⚠️  Directory exists: $INSTALL_DIR${NC}"
    read -p "Remove and reinstall? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$INSTALL_DIR"
    else
        echo -e "${RED}❌ Installation cancelled${NC}"
        exit 1
    fi
fi

git clone --depth 1 https://github.com/mluk132/agent-system-docs.git "$INSTALL_DIR/temp" 2>&1 | grep -v "Cloning into" || true
mv "$INSTALL_DIR/temp/simple-broker-system/"* "$INSTALL_DIR/"
rm -rf "$INSTALL_DIR/temp"

echo -e "${GREEN}✅ Repository cloned to: $INSTALL_DIR${NC}"
echo ""

# Install Python dependencies
echo -e "${BLUE}📦 Installing Python dependencies...${NC}"
cd "$INSTALL_DIR/mac-worker"
pip3 install -q -r requirements.txt
echo -e "${GREEN}✅ Dependencies installed (psutil, requests)${NC}"
echo ""

# Make scripts executable
chmod +x start-worker.sh
echo -e "${GREEN}✅ Scripts made executable${NC}"
echo ""

# Configuration
echo -e "${BLUE}⚙️  Configuration${NC}"
echo ""
echo "The worker needs to connect to your Fly.io broker."
echo ""
read -p "Enter your Fly.io broker URL (e.g., https://agent-broker.fly.dev): " BROKER_URL

if [ -z "$BROKER_URL" ]; then
    BROKER_URL="https://agent-broker.fly.dev"
    echo -e "${YELLOW}Using default: $BROKER_URL${NC}"
fi

read -p "CPU limit percentage (default: 40): " CPU_LIMIT
CPU_LIMIT=${CPU_LIMIT:-40}

read -p "RAM limit percentage (default: 40): " RAM_LIMIT
RAM_LIMIT=${RAM_LIMIT:-40}

# Create .env file
cat > .env << EOF
BROKER_URL=$BROKER_URL
CPU_LIMIT=$CPU_LIMIT
RAM_LIMIT=$RAM_LIMIT
POLL_INTERVAL=5
EOF

echo -e "${GREEN}✅ Configuration saved to .env${NC}"
echo ""

# Check if agent servers are available
echo -e "${BLUE}🔍 Checking for agent servers...${NC}"
AGENT_CONTROL="$HOME/projects/agent-control.sh"

if [ -f "$AGENT_CONTROL" ]; then
    echo -e "${GREEN}✅ Found agent-control.sh${NC}"
    echo ""
    echo -e "${YELLOW}Starting agent servers...${NC}"
    bash "$AGENT_CONTROL" start-all || echo -e "${YELLOW}⚠️  Some servers may already be running${NC}"
else
    echo -e "${YELLOW}⚠️  agent-control.sh not found at $AGENT_CONTROL${NC}"
    echo "You'll need to start agent servers manually before running the worker."
fi
echo ""

# Summary
echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "║     ✅ Installation Complete!                             ║"
echo "║                                                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "${GREEN}📁 Installed to: $INSTALL_DIR${NC}"
echo ""
echo -e "${BLUE}📊 Configuration:${NC}"
echo "   Broker URL: $BROKER_URL"
echo "   CPU Limit:  $CPU_LIMIT%"
echo "   RAM Limit:  $RAM_LIMIT%"
echo ""
echo -e "${BLUE}🚀 Next Steps:${NC}"
echo ""
echo "1. Deploy Fly.io broker (if not done):"
echo -e "   ${CYAN}cd $INSTALL_DIR/fly-broker${NC}"
echo -e "   ${CYAN}flyctl launch --name agent-broker${NC}"
echo -e "   ${CYAN}flyctl deploy${NC}"
echo ""
echo "2. Deploy Vercel UI (if not done):"
echo -e "   ${CYAN}cd $INSTALL_DIR/vercel-ui${NC}"
echo -e "   ${CYAN}vercel${NC}"
echo -e "   ${CYAN}vercel env add BROKER_URL${NC}"
echo -e "   ${CYAN}vercel --prod${NC}"
echo ""
echo "3. Start the worker:"
echo -e "   ${CYAN}cd $INSTALL_DIR/mac-worker${NC}"
echo -e "   ${CYAN}./start-worker.sh${NC}"
echo ""
echo -e "${BLUE}📚 Documentation:${NC}"
echo -e "   ${CYAN}cat $INSTALL_DIR/START_HERE.md${NC}"
echo -e "   ${CYAN}cat $INSTALL_DIR/QUICK_START.md${NC}"
echo ""
echo -e "${GREEN}🎉 Ready to go! Start the worker when your broker is deployed.${NC}"
echo ""

# Offer to start worker now
if [ -f "$AGENT_CONTROL" ]; then
    echo -e "${YELLOW}Would you like to start the worker now?${NC}"
    read -p "Start worker? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${BLUE}🚀 Starting worker...${NC}"
        cd "$INSTALL_DIR/mac-worker"
        ./start-worker.sh
    fi
fi
