#!/bin/bash
# Add password protection to all backend docs

BACKENDS=(
  "propai-backend"
  "diaperstops-backend"
  "mixflow-backend"
  "healthflow-backend"
  "hypnotic-backend"
  "finder-backend"
)

for backend in "${BACKENDS[@]}"; do
  SERVER_FILE="$backend/backend/src/server.js"
  
  if [ ! -f "$SERVER_FILE" ]; then
    echo "⚠️  $SERVER_FILE not found, skipping..."
    continue
  fi
  
  echo "🔒 Adding password protection to $backend..."
  
  # Check if already has password protection
  if grep -q "backendDocsAuth" "$SERVER_FILE"; then
    echo "  ✅ Already has password protection"
    continue
  fi
  
  # Add password middleware after express.json()
  sed -i '/app.use(express.json());/a\
\
// Password protection middleware for backend docs\
const backendDocsAuth = (req, res, next) => {\
  const authHeader = req.headers.authorization;\
  const password = '\''FindMe123!'\''; // TODO: Move to Doppler\
  \
  if (!authHeader || authHeader !== `Bearer ${password}`) {\
    return res.status(401).json({ \
      error: '\''Unauthorized'\'', \
      message: '\''Please provide valid credentials to access backend documentation'\'' \
    });\
  }\
  next();\
};' "$SERVER_FILE"
  
  # Replace /api-docs with /backend-docs and add auth
  sed -i "s|app.use('/api-docs'|app.use('/backend-docs', backendDocsAuth|" "$SERVER_FILE"
  sed -i "s|app.get('/api-docs.json'|app.get('/backend-docs.json', backendDocsAuth|" "$SERVER_FILE"
  
  echo "  ✅ Password protection added"
done

echo ""
echo "✅ All backends updated with password protection!"
echo ""
echo "Access backend docs at: /backend-docs"
echo "Password: FindMe123!"
