#!/bin/bash
# Fix package-lock.json and deploy real React frontends

set -e

cd "$(dirname "$0")"

FRONTENDS=(
  "propai-backend/frontend:propai"
  "healthflow-backend/frontend:healthflow"
  "finder-backend/frontend:finder"
  "hypnotic-backend/frontend:hypnotic"
  "mixflow-backend/frontend:mixflow"
  "diaperstops-backend/frontend:diaperstops"
)

echo "========================================="
echo "Fixing and Deploying React Frontends"
echo "========================================="
echo ""

for entry in "${FRONTENDS[@]}"; do
  IFS=':' read -r frontend_path appname <<< "$entry"
  
  echo ">>> Processing $appname ($frontend_path)..."
  
  if [ ! -d "$frontend_path" ]; then
    echo "⚠️  Directory $frontend_path not found, skipping..."
    continue
  fi
  
  cd "$frontend_path"
  
  # Fix package-lock.json
  echo "Regenerating package-lock.json..."
  npm install --package-lock-only 2>&1 | grep -v "npm WARN" || true
  
  # Create Dockerfile using npm install instead of npm ci
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

  echo "✅ Files ready for $appname"
  
  cd ../..
  echo ""
done

echo "========================================="
echo "Package lock files fixed!"
echo "========================================="
echo ""
echo "Now deploying with fixed Dockerfiles..."
echo ""

# Now run the deployment
./deploy-real-frontends.sh
