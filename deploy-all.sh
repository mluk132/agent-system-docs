#!/bin/bash

set -e

echo "🚀 Deploying All Projects to Fly.io and Vercel"
echo "=============================================="
echo ""

# Check if CLIs are installed
check_cli() {
    if ! command -v $1 &> /dev/null; then
        echo "❌ $1 not found. Please install it first."
        echo "   Install: $2"
        exit 1
    fi
}

echo "📋 Checking prerequisites..."
check_cli "fly" "curl -L https://fly.io/install.sh | sh"
check_cli "vercel" "npm install -g vercel"
echo "✅ All CLIs installed"
echo ""

# Deploy Backends to Fly.io
echo "🐳 Deploying Backends to Fly.io..."
echo ""

# Mixflow Backend
echo "📦 Deploying Mixflow Backend..."
cd mixflow.io/backend
if [ ! -f "fly.toml" ]; then
    echo "⚠️  No fly.toml found, skipping..."
else
    fly deploy --ha=false || echo "⚠️  Mixflow backend deployment failed"
fi
cd ../..

# DiaperStops Backend
echo "📦 Deploying DiaperStops Backend..."
cd diaperstops.com/backend
if [ ! -f "fly.toml" ]; then
    echo "⚠️  No fly.toml found, skipping..."
else
    fly deploy --ha=false || echo "⚠️  DiaperStops backend deployment failed"
fi
cd ../..

# Hynoticworld Backend
echo "📦 Deploying Hynoticworld Backend..."
cd hynoticworld
if [ ! -f "fly.toml" ]; then
    echo "⚠️  No fly.toml found, skipping..."
else
    npm install
    fly deploy --ha=false || echo "⚠️  Hynoticworld deployment failed"
fi
cd ..

echo ""
echo "🌐 Deploying Frontends to Vercel..."
echo ""

# Mixflow Frontend
echo "📦 Deploying Mixflow Frontend..."
cd mixflow.io/web/mixflow.io
if [ -f "package.json" ]; then
    npm install
    vercel --prod --yes || echo "⚠️  Mixflow frontend deployment failed"
else
    echo "⚠️  No package.json found, skipping..."
fi
cd ../../..

# DiaperStops Frontend
echo "📦 Deploying DiaperStops Frontend..."
cd diaperstops.com/web
if [ -f "package.json" ]; then
    npm install
    vercel --prod --yes || echo "⚠️  DiaperStops frontend deployment failed"
else
    echo "⚠️  No package.json found, skipping..."
fi
cd ../..

echo ""
echo "✅ Deployment Complete!"
echo ""
echo "📊 Check Status:"
echo "  Fly.io:  fly status"
echo "  Vercel:  vercel ls"
echo ""
echo "📝 View Logs:"
echo "  Fly.io:  fly logs"
echo "  Vercel:  vercel logs <url>"
