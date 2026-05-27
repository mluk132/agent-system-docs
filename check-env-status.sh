#!/bin/bash
# Check environment variable status across all projects

echo "🔍 Checking Environment Variables Across All Projects"
echo "======================================================"
echo ""

# Backend services
BACKENDS=(
  "diaperstops-backend/backend:8082"
  "mixflow-backend/backend:8083"
  "propai-backend/backend:8081"
  "healthflow-backend/backend:8084"
  "hypnotic-backend/backend:8085"
  "finder-backend/backend:8086"
)

echo "📊 Backend Services Status:"
echo ""

for backend in "${BACKENDS[@]}"; do
  IFS=':' read -r path port <<< "$backend"
  name=$(basename $(dirname "$path"))
  
  echo "  $name (Port $port)"
  
  if [ -f "$path/.env" ]; then
    echo "    ✅ .env file exists"
    
    # Check for required variables
    if grep -q "DATABASE_URL=" "$path/.env" 2>/dev/null; then
      echo "    ✅ DATABASE_URL configured"
    else
      echo "    ❌ DATABASE_URL missing"
    fi
    
    if grep -q "OPENAI_API_KEY=" "$path/.env" 2>/dev/null; then
      echo "    ✅ OPENAI_API_KEY configured"
    else
      echo "    ❌ OPENAI_API_KEY missing"
    fi
    
    if grep -q "JWT_SECRET=" "$path/.env" 2>/dev/null; then
      echo "    ✅ JWT_SECRET configured"
    else
      echo "    ❌ JWT_SECRET missing"
    fi
  else
    echo "    ❌ .env file missing (copy from .env.example)"
  fi
  
  echo ""
done

# Frontend services
FRONTENDS=(
  "diaperstops-frontend"
  "mixflow-frontend"
)

echo "🌐 Frontend Services Status:"
echo ""

for frontend in "${FRONTENDS[@]}"; do
  echo "  $frontend"
  
  if [ -f "$frontend/.env.local" ] || [ -f "$frontend/.env" ]; then
    echo "    ✅ Environment file exists"
    
    if grep -q "NEXT_PUBLIC_API_URL=" "$frontend/.env.local" 2>/dev/null || grep -q "NEXT_PUBLIC_API_URL=" "$frontend/.env" 2>/dev/null; then
      echo "    ✅ NEXT_PUBLIC_API_URL configured"
    else
      echo "    ❌ NEXT_PUBLIC_API_URL missing"
    fi
  else
    echo "    ❌ Environment file missing (create .env.local)"
  fi
  
  echo ""
done

# Broker system
echo "🤖 Broker System Status:"
echo ""

echo "  simple-broker-system/vercel-ui"
if [ -f "simple-broker-system/vercel-ui/.env.local" ] || [ -f "simple-broker-system/vercel-ui/.env" ]; then
  echo "    ✅ Environment file exists"
else
  echo "    ❌ Environment file missing"
fi
echo ""

echo "  simple-broker-system/mac-worker"
if [ -f "simple-broker-system/mac-worker/.env" ]; then
  echo "    ✅ .env file exists"
else
  echo "    ❌ .env file missing"
fi
echo ""

# Summary
echo "======================================================"
echo "📋 Summary:"
echo ""
echo "To set up environment variables:"
echo "1. Copy .env.example to .env in each backend"
echo "2. Fill in DATABASE_URL from Neon PostgreSQL"
echo "3. Fill in OPENAI_API_KEY from OpenAI"
echo "4. Generate JWT_SECRET with: openssl rand -base64 32"
echo ""
echo "Or use Doppler to pull all secrets at once:"
echo "  doppler login"
echo "  doppler secrets download --no-file --format env > .env"
echo ""
