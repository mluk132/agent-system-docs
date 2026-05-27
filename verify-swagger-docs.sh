#!/bin/bash
# Verify Swagger documentation is working for all backends

echo "🔍 Verifying Swagger Documentation"
echo "===================================="
echo ""

PASSWORD="FindMe123!"

BACKENDS=(
  "diaperstops-api"
  "mixflow-api"
  "propai-api"
  "healthflow-api"
  "hypnotic-api"
  "finder-api"
)

for backend in "${BACKENDS[@]}"; do
  echo "📚 Testing $backend..."
  
  # Test without auth (should fail)
  echo "  Testing without auth..."
  response=$(curl -s -w "%{http_code}" "https://$backend.fly.dev/backend-docs" -o /dev/null)
  
  if [ "$response" == "401" ]; then
    echo "  ✅ Properly protected (401)"
  else
    echo "  ❌ Not protected (HTTP $response)"
  fi
  
  # Test with auth (should succeed)
  echo "  Testing with auth..."
  response=$(curl -s -w "%{http_code}" -H "Authorization: Bearer $PASSWORD" "https://$backend.fly.dev/backend-docs" -o /dev/null)
  
  if [ "$response" == "200" ]; then
    echo "  ✅ Accessible with password (200)"
  else
    echo "  ❌ Not accessible (HTTP $response)"
  fi
  
  # Test JSON endpoint
  echo "  Testing JSON endpoint..."
  response=$(curl -s -H "Authorization: Bearer $PASSWORD" "https://$backend.fly.dev/backend-docs.json" | head -c 50)
  
  if echo "$response" | grep -q "openapi\|swagger"; then
    echo "  ✅ JSON docs available"
  else
    echo "  ⚠️  JSON docs may not be available"
  fi
  
  echo ""
done

echo "✅ Swagger verification complete!"
