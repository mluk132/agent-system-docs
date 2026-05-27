#!/bin/bash
# Deploy all frontends to Fly.io with minimal cost configuration

set -e

cd "$(dirname "$0")"

FRONTENDS=(
  "diaperstops-frontend:diaperstops"
  "propai-frontend:propai"
  "finder-frontend:finder"
  "hypnotic-frontend:hypnotic"
  "healthflow-frontend:healthflow"
  "mixflow-frontend:mixflow"
)

echo "========================================="
echo "Deploying Frontends (Minimal Cost)"
echo "========================================="
echo ""

for entry in "${FRONTENDS[@]}"; do
  IFS=':' read -r frontend appname <<< "$entry"
  
  echo ">>> Processing $frontend..."
  
  if [ ! -d "$frontend" ]; then
    echo "⚠️  Directory $frontend not found, skipping..."
    continue
  fi
  
  cd "$frontend"
  
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
  
  # Create Dockerfile for Next.js
  cat > Dockerfile <<'EOF'
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV production
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs
EXPOSE 3000
ENV PORT 3000

CMD ["node", "server.js"]
EOF

  # Update next.config.ts to enable standalone output
  if [ -f "next.config.ts" ]; then
    if ! grep -q "output.*standalone" next.config.ts; then
      echo "Updating next.config.ts for standalone build..."
      cat > next.config.ts <<'EOF'
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: 'standalone',
};

export default nextConfig;
EOF
    fi
  fi
  
  echo "✅ Created deployment files for $frontend"
  
  # Check if app exists
  if ! fly apps list 2>&1 | grep -q "${appname}-web"; then
    echo "Creating Fly.io app: ${appname}-web..."
    fly apps create "${appname}-web" --org personal || true
  fi
  
  # Deploy
  echo "Deploying ${appname}-web..."
  if fly deploy --ha=false --remote-only; then
    echo "✅ Deployed $frontend successfully"
  else
    echo "⚠️  Deployment failed for $frontend"
  fi
  
  cd ..
  echo ""
done

echo "========================================="
echo "Deployment Complete!"
echo "========================================="
echo ""
echo "Frontend URLs:"
for entry in "${FRONTENDS[@]}"; do
  IFS=':' read -r frontend appname <<< "$entry"
  echo "  $appname: https://${appname}-web.fly.dev"
done
echo ""
echo "Cost estimate: ~$0-2/month (auto-stop when idle)"
