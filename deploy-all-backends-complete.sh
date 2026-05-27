#!/bin/bash
# Deploy all 6 backends with app creation

echo "🚀 Deploying All 6 Backends to Fly.io"
echo "======================================"
echo ""

BACKENDS=(
  "propai-backend:propai-api"
  "healthflow-backend:healthflow-api"
  "hypnotic-backend:hypnotic-api"
  "finder-backend:finder-api"
)

for backend_info in "${BACKENDS[@]}"; do
  IFS=':' read -r folder app_name <<< "$backend_info"
  
  echo "📦 Deploying $app_name..."
  cd "$folder/backend"
  
  # Check if app exists
  if ! flyctl apps list | grep -q "$app_name"; then
    echo "  Creating app $app_name..."
    flyctl apps create "$app_name" --org personal 2>&1 | grep -v "Error"
  fi
  
  # Get secrets
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
    --app "$app_name" 2>&1 | grep -E "(set|Secrets)" || true
  
  # Deploy
  echo "  Deploying..."
  flyctl deploy --app "$app_name" --yes 2>&1 | tail -5
  
  echo "✅ $app_name: https://$app_name.fly.dev"
  echo ""
  
  cd ../..
done

echo ""
echo "✅ All backends deployed!"
echo ""
echo "Test them:"
for backend_info in "${BACKENDS[@]}"; do
  IFS=':' read -r folder app_name <<< "$backend_info"
  echo "curl https://$app_name.fly.dev/health"
done
