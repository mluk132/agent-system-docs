#!/bin/bash
# Deploy all frontends to Fly.io

set -e

FRONTENDS=(
  "diaperstops-frontend"
  "propai-frontend"
  "finder-frontend"
  "hypnotic-frontend"
  "healthflow-frontend"
  "mixflow-frontend"
)

echo "========================================="
echo "Deploying All Frontends to Fly.io"
echo "========================================="
echo ""

for frontend in "${FRONTENDS[@]}"; do
  echo ">>> Deploying $frontend..."
  
  cd "$frontend"
  
  # Create fly.toml if it doesn't exist
  if [ ! -f "fly.toml" ]; then
    echo "Creating fly.toml for $frontend..."
    
    # Extract app name (remove -frontend suffix)
    APP_NAME=$(echo "$frontend" | sed 's/-frontend$//')
    
    cat > fly.toml <<EOF
app = "${APP_NAME}-frontend"
primary_region = "iad"

[build]

[env]
  NODE_ENV = "production"

[http_service]
  internal_port = 3000
  force_https = true
  auto_stop_machines = true
  auto_start_machines = true
  min_machines_running = 0
  processes = ["app"]

[[vm]]
  cpu_kind = "shared"
  cpus = 1
  memory_mb = 256
EOF
  fi
  
  # Create Dockerfile if it doesn't exist
  if [ ! -f "Dockerfile" ]; then
    echo "Creating Dockerfile for $frontend..."
    
    cat > Dockerfile <<'EOF'
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV production

COPY --from=builder /app/package*.json ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules

EXPOSE 3000

CMD ["npm", "start"]
EOF
  fi
  
  # Check if app exists, create if not
  if ! fly apps list 2>&1 | grep -q "${APP_NAME}-frontend"; then
    echo "Creating Fly.io app: ${APP_NAME}-frontend..."
    fly apps create "${APP_NAME}-frontend" --org personal || true
  fi
  
  # Deploy
  echo "Deploying ${APP_NAME}-frontend..."
  fly deploy --ha=false || echo "⚠️  Deployment failed for $frontend, continuing..."
  
  cd ..
  echo ""
done

echo "========================================="
echo "Deployment Complete!"
echo "========================================="
echo ""
echo "Check status:"
for frontend in "${FRONTENDS[@]}"; do
  APP_NAME=$(echo "$frontend" | sed 's/-frontend$//')
  echo "  https://${APP_NAME}-frontend.fly.dev"
done
