#!/bin/bash
# Setup environment variables for all projects

set -e

echo "🔧 Setting Up Environment Variables for All Projects"
echo "====================================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to generate JWT secret
generate_jwt_secret() {
  openssl rand -base64 32
}

# Function to copy .env.example to .env if not exists
setup_backend_env() {
  local backend_path=$1
  local port=$2
  local app_name=$3
  
  echo "Setting up $app_name..."
  
  if [ ! -f "$backend_path/.env" ]; then
    if [ -f "$backend_path/.env.example" ]; then
      cp "$backend_path/.env.example" "$backend_path/.env"
      
      # Generate unique JWT secret
      jwt_secret=$(generate_jwt_secret)
      
      # Update the .env file with port and JWT secret
      sed -i "s/PORT=.*/PORT=$port/" "$backend_path/.env"
      sed -i "s|JWT_SECRET=.*|JWT_SECRET=$jwt_secret|" "$backend_path/.env"
      
      echo -e "  ${GREEN}✅${NC} Created .env file with unique JWT secret"
      echo -e "  ${YELLOW}⚠️${NC}  Still need to add:"
      echo "     - DATABASE_URL (from Neon PostgreSQL)"
      echo "     - OPENAI_API_KEY (from OpenAI)"
    else
      echo -e "  ${RED}❌${NC} No .env.example found"
    fi
  else
    echo -e "  ${GREEN}✅${NC} .env file already exists"
  fi
  
  echo ""
}

# Setup backend services
echo "📊 Setting up Backend Services:"
echo ""

setup_backend_env "propai-backend/backend" 8081 "propai"
setup_backend_env "diaperstops-backend/backend" 8082 "diaperstops"
setup_backend_env "mixflow-backend/backend" 8083 "mixflow"
setup_backend_env "healthflow-backend/backend" 8084 "healthflow"
setup_backend_env "hypnotic-backend/backend" 8085 "hypnotic"
setup_backend_env "finder-backend/backend" 8086 "finder"

# Setup frontend services
echo "🌐 Setting up Frontend Services:"
echo ""

# diaperstops-frontend
echo "Setting up diaperstops-frontend..."
if [ ! -f "diaperstops-frontend/.env.local" ]; then
  cat > "diaperstops-frontend/.env.local" << 'EOF'
# DiaperStops Frontend Configuration
NEXT_PUBLIC_API_URL=http://localhost:8082
NEXT_PUBLIC_DEMO_USER_ID=00000000-0000-0000-0000-000000000000
EOF
  echo -e "  ${GREEN}✅${NC} Created .env.local"
else
  echo -e "  ${GREEN}✅${NC} .env.local already exists"
fi
echo ""

# mixflow-frontend
echo "Setting up mixflow-frontend..."
if [ ! -f "mixflow-frontend/.env.local" ]; then
  cat > "mixflow-frontend/.env.local" << 'EOF'
# MixFlow Frontend Configuration
NEXT_PUBLIC_API_URL=http://localhost:8083
NEXT_PUBLIC_DEMO_USER_ID=00000000-0000-0000-0000-000000000000
EOF
  echo -e "  ${GREEN}✅${NC} Created .env.local"
else
  echo -e "  ${GREEN}✅${NC} .env.local already exists"
fi
echo ""

# Setup broker system
echo "🤖 Setting up Broker System:"
echo ""

# Broker UI
echo "Setting up simple-broker-system/vercel-ui..."
if [ ! -f "simple-broker-system/vercel-ui/.env.local" ]; then
  cat > "simple-broker-system/vercel-ui/.env.local" << 'EOF'
# Broker URL (update after deploying to Fly.io)
BROKER_URL=http://localhost:3001
EOF
  echo -e "  ${GREEN}✅${NC} Created .env.local"
  echo -e "  ${YELLOW}⚠️${NC}  Update BROKER_URL after deploying broker to Fly.io"
else
  echo -e "  ${GREEN}✅${NC} .env.local already exists"
fi
echo ""

# Worker
echo "Setting up simple-broker-system/mac-worker..."
if [ ! -f "simple-broker-system/mac-worker/.env" ]; then
  cat > "simple-broker-system/mac-worker/.env" << 'EOF'
# Worker Configuration
BROKER_URL=http://localhost:3001
CPU_LIMIT=40
RAM_LIMIT=40
POLL_INTERVAL=5
WORKER_ID=linux-droid
EOF
  echo -e "  ${GREEN}✅${NC} Created .env"
  echo -e "  ${YELLOW}⚠️${NC}  Update BROKER_URL after deploying broker to Fly.io"
else
  echo -e "  ${GREEN}✅${NC} .env already exists"
fi
echo ""

# Summary
echo "====================================================="
echo "📋 Setup Complete!"
echo ""
echo "✅ Created .env files for all services"
echo "✅ Generated unique JWT secrets for each backend"
echo "✅ Configured local development URLs"
echo ""
echo -e "${YELLOW}⚠️  Still Required:${NC}"
echo ""
echo "1. DATABASE_URL for each backend service"
echo "   - Sign up at: https://console.neon.tech"
echo "   - Create 6 databases (one per backend)"
echo "   - Enable pgvector extension"
echo "   - Copy connection strings to each .env file"
echo ""
echo "2. OPENAI_API_KEY (shared across all services)"
echo "   - Get from: https://platform.openai.com/api-keys"
echo "   - Add to each backend .env file"
echo ""
echo "3. Update BROKER_URL after deploying to Fly.io"
echo "   - Deploy broker: cd simple-broker-system/fly-broker && flyctl deploy"
echo "   - Update vercel-ui/.env.local and mac-worker/.env"
echo ""
echo "📖 See ENVIRONMENT_VARIABLES_NEEDED.md for full details"
echo ""
echo "🚀 To test a backend locally:"
echo "   cd diaperstops-backend/backend"
echo "   npm install"
echo "   npm run dev"
echo ""
