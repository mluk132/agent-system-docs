#!/bin/bash

echo "🌐 Deploying Frontends to Vercel"
echo "================================="
echo ""

# Set up PATH
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# Check if Vercel is installed
if ! command -v vercel &> /dev/null; then
    echo "❌ Vercel CLI not found. Installing..."
    pnpm add -g vercel
fi

echo "📋 Vercel CLI version: $(vercel --version)"
echo ""

# Check if logged in
echo "🔐 Checking Vercel authentication..."
if ! vercel whoami &> /dev/null; then
    echo "⚠️  Not logged in to Vercel. Please authenticate:"
    echo ""
    vercel login
    echo ""
fi

echo "✅ Authenticated to Vercel"
echo ""

# Deploy Mixflow Frontend
echo "📦 Deploying Mixflow Frontend..."
cd mixflow.io/web/mixflow.io
if [ -f "package.json" ]; then
    echo "Installing dependencies..."
    npm install --legacy-peer-deps
    echo "Deploying to Vercel..."
    vercel --prod --yes || vercel deploy --prod
    echo "✅ Mixflow frontend deployed!"
else
    echo "⚠️  No package.json found, skipping..."
fi
cd ../../..

echo ""

# Deploy DiaperStops Frontend
echo "📦 Deploying DiaperStops Frontend..."
cd diaperstops.com/web/diaperstops.com
if [ -f "package.json" ]; then
    echo "Installing dependencies..."
    npm install --legacy-peer-deps
    echo "Deploying to Vercel..."
    vercel --prod --yes || vercel deploy --prod
    echo "✅ DiaperStops frontend deployed!"
else
    echo "⚠️  No package.json found, skipping..."
fi
cd ../../..

echo ""
echo "🎉 Frontend Deployment Complete!"
echo ""
echo "📝 Environment variables are already set in .env.production files:"
echo "   - Mixflow: VITE_API_URL=https://mixflow-backend.fly.dev"
echo "   - DiaperStops: VITE_API_URL=https://diaperstops-backend.fly.dev"
echo ""
echo "2. View your deployments:"
echo "   vercel ls"

