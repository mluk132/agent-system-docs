#!/bin/bash
# Integration tests for all deployed services

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                           ║${NC}"
echo -e "${BLUE}║     🧪 Integration Tests - All Services                  ║${NC}"
echo -e "${BLUE}║                                                           ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

PASSWORD="FindMe123!"
PASS_COUNT=0
FAIL_COUNT=0

# Test function
test_service() {
  local name=$1
  local url=$2
  local test_type=$3
  
  echo -e "${YELLOW}Testing $name - $test_type...${NC}"
  
  if [ "$test_type" == "health" ]; then
    response=$(curl -s -w "\n%{http_code}" "$url/health" 2>/dev/null)
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n-1)
    
    if [ "$http_code" == "200" ] && echo "$body" | grep -q "ok"; then
      echo -e "${GREEN}✅ PASS${NC} - Health check successful"
      echo "   Response: $body"
      ((PASS_COUNT++))
      return 0
    else
      echo -e "${RED}❌ FAIL${NC} - Health check failed (HTTP $http_code)"
      echo "   Response: $body"
      ((FAIL_COUNT++))
      return 1
    fi
    
  elif [ "$test_type" == "backend-docs-protected" ]; then
    # Test without password (should fail)
    response=$(curl -s -w "\n%{http_code}" "$url/backend-docs" 2>/dev/null)
    http_code=$(echo "$response" | tail -n1)
    
    if [ "$http_code" == "401" ]; then
      echo -e "${GREEN}✅ PASS${NC} - Backend docs properly protected (401 without auth)"
      ((PASS_COUNT++))
    else
      echo -e "${RED}❌ FAIL${NC} - Backend docs not protected (HTTP $http_code)"
      ((FAIL_COUNT++))
      return 1
    fi
    
    # Test with password (should succeed)
    response=$(curl -s -w "\n%{http_code}" -H "Authorization: Bearer $PASSWORD" "$url/backend-docs" 2>/dev/null)
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n-1)
    
    if [ "$http_code" == "200" ] && echo "$body" | grep -q "swagger"; then
      echo -e "${GREEN}✅ PASS${NC} - Backend docs accessible with password"
      ((PASS_COUNT++))
      return 0
    else
      echo -e "${RED}❌ FAIL${NC} - Backend docs not accessible with password (HTTP $http_code)"
      ((FAIL_COUNT++))
      return 1
    fi
    
  elif [ "$test_type" == "api-endpoint" ]; then
    response=$(curl -s -w "\n%{http_code}" "$url/" 2>/dev/null)
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n-1)
    
    if [ "$http_code" == "200" ]; then
      echo -e "${GREEN}✅ PASS${NC} - API endpoint accessible"
      echo "   Response: $(echo $body | head -c 100)..."
      ((PASS_COUNT++))
      return 0
    else
      echo -e "${RED}❌ FAIL${NC} - API endpoint failed (HTTP $http_code)"
      ((FAIL_COUNT++))
      return 1
    fi
  fi
  
  echo ""
}

# Test frontends
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}📱 Testing Frontend Services${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

test_service "DiaperStops Frontend" "https://diaperstops-frontend.vercel.app" "api-endpoint"
test_service "MixFlow Frontend" "https://mixflow-frontend.vercel.app" "api-endpoint"

echo ""

# Test backends
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}📦 Testing Backend Services${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

BACKENDS=(
  "DiaperStops:https://diaperstops-api.fly.dev"
  "MixFlow:https://mixflow-api.fly.dev"
  "PropAI:https://propai-api.fly.dev"
  "HealthFlow:https://healthflow-api.fly.dev"
  "Hypnotic:https://hypnotic-api.fly.dev"
  "Finder:https://finder-search-api.fly.dev"
)

for backend in "${BACKENDS[@]}"; do
  IFS=':' read -r name url <<< "$backend"
  
  echo -e "${YELLOW}━━━ $name Backend ━━━${NC}"
  test_service "$name" "$url" "health"
  test_service "$name" "$url" "api-endpoint"
  test_service "$name" "$url" "backend-docs-protected"
  echo ""
done

# Summary
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}📊 Test Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

TOTAL=$((PASS_COUNT + FAIL_COUNT))
PASS_PERCENT=$((PASS_COUNT * 100 / TOTAL))

echo -e "Total Tests: $TOTAL"
echo -e "${GREEN}Passed: $PASS_COUNT${NC}"
echo -e "${RED}Failed: $FAIL_COUNT${NC}"
echo -e "Success Rate: $PASS_PERCENT%"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
  echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║                                                           ║${NC}"
  echo -e "${GREEN}║     ✅ ALL TESTS PASSED!                                  ║${NC}"
  echo -e "${GREEN}║                                                           ║${NC}"
  echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
  exit 0
else
  echo -e "${RED}╔═══════════════════════════════════════════════════════════╗${NC}"
  echo -e "${RED}║                                                           ║${NC}"
  echo -e "${RED}║     ⚠️  SOME TESTS FAILED                                 ║${NC}"
  echo -e "${RED}║                                                           ║${NC}"
  echo -e "${RED}╚═══════════════════════════════════════════════════════════╝${NC}"
  exit 1
fi
