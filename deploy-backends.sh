#!/bin/bash
# Deploy all 6 backends to Fly.io

set -e

echo "🚀 Deploying 6 Backend Services to Fly.io"
echo "=========================================="
echo ""

BACKENDS=(
  "propai-backend:propai-api"
  "diaperstops-backend:diaperstops-api"
  "mixflow-backend:mixflow-api"
  "healthflow-backend:healthflow-api"
  "hypnotic-backend:hypnotic-api"
  "finder-backend:finder-api"
)

for backend_info in "${BACKENDS[@]}"; do
  IFS=':' read -r folder app_name <<< "$backend_info"
  
  echo "📦 Deploying $app_name..."
  
  cd "$folder/backend"
  
  # Get secrets from .env
  if [ -f ".env" ]; then
    DATABASE_URL=$(grep "^DATABASE_URL=" .env | cut -d'=' -f2-)
    OPENAI_API_KEY=$(grep "^OPENAI_API_KEY=" .env | cut -d'=' -f2-)
    JWT_SECRET=$(grep "^JWT_SECRET=" .env | cut -d'=' -f2-)
    
    # Set secrets
    echo "  Setting secrets..."
    flyctl secrets set \
      DATABASE_URL="$DATABASE_URL" \
      OPENAI_API_KEY="$OPENAI_API_KEY" \
      JWT_SECRET="$JWT_SECRET" \
      NODE_ENV="production" \
      --app "$app_name" 2>&1 | grep -v "Secrets are staged" || true
  fi
  
  # Deploy
  echo "  Deploying to Fly.io..."
  flyctl deploy --app "$app_name" --yes --detach 2>&1 | grep -E "(Updating|deployed|Visit)" || true
  
  echo "✅ $app_name: https://$app_name.fly.dev"
  echo ""
  
  cd ../..
done

echo ""
echo "✅ All backends deployed!"
echo ""
echo "URLs:"
for backend_info in "${BACKENDS[@]}"; do
  IFS=':' read -r folder app_name <<< "$backend_info"
  echo "  • $app_name: https://$app_name.fly.dev"
done
