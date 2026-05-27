#!/bin/bash
# Deploy a single backend to Fly.io

BACKEND=$1
APP_NAME=$2

if [ -z "$BACKEND" ] || [ -z "$APP_NAME" ]; then
  echo "Usage: ./deploy-one-backend.sh <backend-folder> <app-name>"
  exit 1
fi

echo "🚀 Deploying $APP_NAME..."
cd "$BACKEND/backend"

# Get secrets
DATABASE_URL=$(grep "^DATABASE_URL=" .env | cut -d'=' -f2-)
OPENAI_API_KEY=$(grep "^OPENAI_API_KEY=" .env | cut -d'=' -f2-)
JWT_SECRET=$(grep "^JWT_SECRET=" .env | cut -d'=' -f2-)

# Set secrets
echo "Setting secrets..."
flyctl secrets set \
  DATABASE_URL="$DATABASE_URL" \
  OPENAI_API_KEY="$OPENAI_API_KEY" \
  JWT_SECRET="$JWT_SECRET" \
  NODE_ENV="production" \
  --app "$APP_NAME" 2>&1 | grep -v "Secrets are staged"

# Deploy
echo "Deploying..."
flyctl deploy --app "$APP_NAME" --yes --detach

echo "✅ $APP_NAME deployed: https://$APP_NAME.fly.dev"
