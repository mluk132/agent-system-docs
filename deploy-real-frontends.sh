#!/bin/bash
# Deploy the REAL React frontends from backend repos to Fly.io

set -e

cd "$(dirname "$0")"

FRONTENDS=(
  "propai-backend/frontend:propai:finance-frontend"
  "healthflow-backend/frontend:healthflow:health-fit-frontend"
  "finder-backend/frontend:finder:lush-playground-frontend"
  "hypnotic-backend/frontend:hypnotic:hypermedia-oasis-frontend"
  "mixflow-backend/frontend:mixflow:mixflow-frontend"
  "diaperstops-backend/frontend:diaperstops:diaperstops-frontend"
)

echo "========================================="
echo "Deploying REAL React Frontends"
echo "========================================="
echo ""

for entry in "${FRONTENDS[@]}"; do
  IFS=':' read -r frontend_path appname original_name <<< "$entry"
  
  echo ">>> Processing $appname ($frontend_path)..."
  
  if [ ! -d "$frontend_path" ]; then
    echo "⚠️  Directory $frontend_path not found, skipping..."
    continue
  fi
  
  cd "$frontend_path"
  
  # Create fly.toml with minimal cost settings
  cat > fly.toml <<EOF
app = "${appname}-web"
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
  memory = "256mb"
  cpu_kind = "shared"
  cpus = 1
EOF
  
  # Create Dockerfile for Create React App
  cat > Dockerfile <<'EOF'
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install --legacy-peer-deps

COPY . .
RUN npm run build

FROM nginx:alpine AS runner

COPY --from=builder /app/build /usr/share/nginx/html

# Create nginx config for SPA routing
RUN echo 'server { \
    listen 3000; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html; \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]
EOF

  echo "✅ Created deployment files for $appname"
  
  # Check if app exists
  APP_NAME="${appname}-web"
  if [ "$appname" = "finder" ]; then
    APP_NAME="finder-app-web"
  fi
  
  if ! fly apps list 2>&1 | grep -q "$APP_NAME"; then
    echo "Creating Fly.io app: $APP_NAME..."
    fly apps create "$APP_NAME" --org personal || true
  fi
  
  # Update fly.toml with correct app name
  sed -i "s/app = \"${appname}-web\"/app = \"$APP_NAME\"/" fly.toml
  
  # Deploy
  echo "Deploying $APP_NAME..."
  if fly deploy --ha=false --remote-only; then
    echo "✅ Deployed $appname successfully"
  else
    echo "⚠️  Deployment failed for $appname"
  fi
  
  cd ../..
  echo ""
done

echo "========================================="
echo "Deployment Complete!"
echo "========================================="
echo ""
echo "Frontend URLs:"
echo "  PropAI: https://propai-web.fly.dev"
echo "  HealthFlow: https://healthflow-web.fly.dev"
echo "  Finder: https://finder-app-web.fly.dev"
echo "  Hypnotic: https://hypnotic-web.fly.dev"
echo "  MixFlow: https://mixflow-web.fly.dev"
echo "  DiaperStops: https://diaperstops-web.fly.dev"
echo ""
echo "Cost estimate: ~$0-2/month per frontend (auto-stop when idle)"
