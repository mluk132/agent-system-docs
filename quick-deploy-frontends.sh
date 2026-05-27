#!/bin/bash
# Quick deploy frontends to Vercel

echo "🌐 Deploying Frontends to Vercel"
echo "================================="
echo ""

# DiaperStops Frontend
echo "📱 Deploying diaperstops-frontend..."
cd diaperstops-frontend
vercel --yes --prod 2>&1 | tail -5
echo ""
cd ..

# MixFlow Frontend  
echo "📱 Deploying mixflow-frontend..."
cd mixflow-frontend
vercel --yes --prod 2>&1 | tail -5
echo ""
cd ..

echo "✅ Frontends deployed!"
echo ""
echo "Get URLs with: vercel ls"
