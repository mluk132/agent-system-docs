#!/bin/bash
# Deploy frontends to Vercel

set -e

echo "🌐 Deploying 2 Frontend Services to Vercel"
echo "==========================================="
echo ""

# DiaperStops Frontend
echo "📱 Deploying diaperstops-frontend..."
cd diaperstops-frontend

if [ ! -d "node_modules" ]; then
  echo "  Installing dependencies..."
  npm install --silent
fi

echo "  Deploying to Vercel..."
vercel --yes --prod -e NEXT_PUBLIC_API_URL="https://diaperstops-api.fly.dev" 2>&1 | grep -E "(Deployed|https://)" || true

DIAPERSTOPS_URL=$(vercel ls --yes 2>/dev/null | grep "https://" | head -1 | awk '{print $1}')
echo "✅ diaperstops-frontend: $DIAPERSTOPS_URL"
echo ""

cd ..

# MixFlow Frontend
echo "📱 Deploying mixflow-frontend..."
cd mixflow-frontend

if [ ! -d "node_modules" ]; then
  echo "  Installing dependencies..."
  npm install --silent
fi

echo "  Deploying to Vercel..."
vercel --yes --prod -e NEXT_PUBLIC_API_URL="https://mixflow-api.fly.dev" 2>&1 | grep -E "(Deployed|https://)" || true

MIXFLOW_URL=$(vercel ls --yes 2>/dev/null | grep "https://" | head -1 | awk '{print $1}')
echo "✅ mixflow-frontend: $MIXFLOW_URL"
echo ""

cd ..

echo ""
echo "✅ All frontends deployed!"
echo ""
echo "URLs:"
echo "  • diaperstops-frontend: $DIAPERSTOPS_URL"
echo "  • mixflow-frontend: $MIXFLOW_URL"
