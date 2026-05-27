#!/bin/bash
# CI/CD Pipeline Test - Verify all services and integrations

set -e

echo "🔄 CI/CD Pipeline Test"
echo "======================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASSWORD="FindMe123!"

# Test 1: Health Checks
echo -e "${BLUE}Test 1: Health Checks${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━"

BACKENDS=(
  "diaperstops-api"
  "mixflow-api"
  "propai-api"
  "healthflow-api"
  "hypnotic-api"
  "finder-api"
)

for backend in "${BACKENDS[@]}"; do
  echo -n "  Testing $backend... "
  response=$(curl -s "https://$backend.fly.dev/health" 2>/dev/null || echo "failed")
  
  if echo "$response" | grep -q "ok"; then
    echo -e "${GREEN}✅${NC}"
  else
    echo -e "${RED}❌ (not ready yet)${NC}"
  fi
done

echo ""

# Test 2: Swagger Documentation Protection
echo -e "${BLUE}Test 2: Swagger Documentation Protection${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for backend in "${BACKENDS[@]}"; do
  echo "  Testing $backend..."
  
  # Test without auth
  echo -n "    Without auth: "
  http_code=$(curl -s -w "%{http_code}" -o /dev/null "https://$backend.fly.dev/backend-docs" 2>/dev/null || echo "000")
  
  if [ "$http_code" == "401" ]; then
    echo -e "${GREEN}✅ Protected${NC}"
  else
    echo -e "${YELLOW}⚠️  HTTP $http_code${NC}"
  fi
  
  # Test with auth
  echo -n "    With auth: "
  http_code=$(curl -s -w "%{http_code}" -o /dev/null -H "Authorization: Bearer $PASSWORD" "https://$backend.fly.dev/backend-docs" 2>/dev/null || echo "000")
  
  if [ "$http_code" == "200" ]; then
    echo -e "${GREEN}✅ Accessible${NC}"
  else
    echo -e "${YELLOW}⚠️  HTTP $http_code${NC}"
  fi
done

echo ""

# Test 3: API Endpoints
echo -e "${BLUE}Test 3: API Endpoints${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━"

for backend in "${BACKENDS[@]}"; do
  echo -n "  Testing $backend API... "
  response=$(curl -s "https://$backend.fly.dev/" 2>/dev/null || echo "failed")
  
  if echo "$response" | grep -q "API\|endpoints\|message"; then
    echo -e "${GREEN}✅${NC}"
  else
    echo -e "${YELLOW}⚠️${NC}"
  fi
done

echo ""

# Test 4: Frontend Accessibility
echo -e "${BLUE}Test 4: Frontend Accessibility${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

FRONTENDS=(
  "diaperstops-frontend"
  "mixflow-frontend"
)

for frontend in "${FRONTENDS[@]}"; do
  echo -n "  Testing $frontend... "
  http_code=$(curl -s -w "%{http_code}" -o /dev/null "https://$frontend.vercel.app" 2>/dev/null || echo "000")
  
  if [ "$http_code" == "200" ]; then
    echo -e "${GREEN}✅${NC}"
  else
    echo -e "${RED}❌ HTTP $http_code${NC}"
  fi
done

echo ""

# Test 5: Database Connectivity
echo -e "${BLUE}Test 5: Database Connectivity${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for backend in "${BACKENDS[@]}"; do
  echo -n "  Testing $backend database... "
  response=$(curl -s "https://$backend.fly.dev/health" 2>/dev/null || echo "failed")
  
  if echo "$response" | grep -q "configured"; then
    echo -e "${GREEN}✅ Connected${NC}"
  else
    echo -e "${YELLOW}⚠️  Not configured${NC}"
  fi
done

echo ""

# Test 6: CORS Configuration
echo -e "${BLUE}Test 6: CORS Configuration${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for backend in "${BACKENDS[@]}"; do
  echo -n "  Testing $backend CORS... "
  response=$(curl -s -H "Origin: https://diaperstops-frontend.vercel.app" -I "https://$backend.fly.dev/health" 2>/dev/null | grep -i "access-control" || echo "")
  
  if [ -n "$response" ]; then
    echo -e "${GREEN}✅ Configured${NC}"
  else
    echo -e "${YELLOW}⚠️  May need configuration${NC}"
  fi
done

echo ""

# Summary
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                           ║${NC}"
echo -e "${BLUE}║     📊 Pipeline Test Complete                            ║${NC}"
echo -e "${BLUE}║                                                           ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

echo "Next steps:"
echo "1. Wait for all deployments to complete"
echo "2. Run full integration tests: ./test-all-services.sh"
echo "3. Verify Swagger docs: ./verify-swagger-docs.sh"
echo ""
