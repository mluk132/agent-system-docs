#!/bin/bash
# Redeploy all backends without Doppler

echo "🚀 Redeploying All Backends (No Doppler)"
echo "=========================================="
echo ""

BACKENDS=(
  "diaperstops-backend:diaperstops-api"
  "mixflow-backend:mixflow-api"
  "propai-backend:propai-api"
  "healthflow-backend:healthflow-api"
  "hypnotic-backend:hypnotic-api"
  "finder-backend:finder-api"
)

for backend_info in "${BACKENDS[@]}"; do
  IFS=':' read -r folder app_name <<< "$backend_info"
  
  echo "📦 Deploying $app_name..."
  cd "$folder/backend"
  
  # Deploy
  flyctl deploy --app "$app_name" --yes 2>&1 | tail -3
  
  echo "✅ $app_name: https://$app_name.fly.dev"
  echo ""
  
  cd ../..
done

echo "✅ All backends redeployed!"
