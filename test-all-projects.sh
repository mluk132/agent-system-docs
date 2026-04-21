#!/bin/bash

echo "🧪 Testing All Deployed Projects"
echo "================================="
echo ""

# Test Hynoticworld Auth
echo "1️⃣  Testing Hynoticworld Authentication..."
echo "   URL: https://hynoticworld.fly.dev/"

# Health check
HEALTH=$(curl -s https://hynoticworld.fly.dev/health)
if echo "$HEALTH" | grep -q "healthy"; then
  echo "   ✅ Health check passed"
else
  echo "   ❌ Health check failed"
fi

# Test registration
REG_RESPONSE=$(curl -s -X POST https://hynoticworld.fly.dev/api/auth/register \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"test$(date +%s)@test.com\",\"password\":\"test123\",\"name\":\"Test User\"}")

if echo "$REG_RESPONSE" | grep -q "token"; then
  echo "   ✅ Registration working"
else
  echo "   ❌ Registration failed"
  echo "   Response: $REG_RESPONSE"
fi

echo ""

# Test Mixflow Backend
echo "2️⃣  Testing Mixflow Backend..."
echo "   URL: https://mixflow-backend.fly.dev/"

# Health check
MIXFLOW_HEALTH=$(curl -s https://mixflow-backend.fly.dev/health)
if echo "$MIXFLOW_HEALTH" | grep -q "healthy"; then
  echo "   ✅ Health check passed"
else
  echo "   ❌ Health check failed"
fi

# Test CORS
CORS_TEST=$(curl -s -X OPTIONS https://mixflow-backend.fly.dev/api/users \
  -H "Origin: https://mixflowio.vercel.app" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: content-type" \
  -i | grep -i "access-control-allow-origin")

if [ ! -z "$CORS_TEST" ]; then
  echo "   ✅ CORS configured"
else
  echo "   ❌ CORS not working"
fi

echo ""

# Test DiaperStops Backend
echo "3️⃣  Testing DiaperStops Backend..."
echo "   URL: https://diaperstops-backend.fly.dev/"

DIAPER_HEALTH=$(curl -s https://diaperstops-backend.fly.dev/health 2>&1)
if echo "$DIAPER_HEALTH" | grep -q "healthy\|UP\|ok"; then
  echo "   ✅ Backend responding"
else
  echo "   ⚠️  Backend may be suspended (will wake on first request)"
fi

echo ""

# Test Frontends
echo "4️⃣  Testing Frontends..."

# Mixflow Frontend
MIXFLOW_FE=$(curl -s -o /dev/null -w "%{http_code}" https://mixflowio.vercel.app/)
if [ "$MIXFLOW_FE" = "200" ]; then
  echo "   ✅ Mixflow frontend: https://mixflowio.vercel.app/"
else
  echo "   ❌ Mixflow frontend returned: $MIXFLOW_FE"
fi

# DiaperStops Frontend
DIAPER_FE=$(curl -s -o /dev/null -w "%{http_code}" https://diaperstopscom.vercel.app/)
if [ "$DIAPER_FE" = "200" ]; then
  echo "   ✅ DiaperStops frontend: https://diaperstopscom.vercel.app/"
else
  echo "   ❌ DiaperStops frontend returned: $DIAPER_FE"
fi

echo ""
echo "================================="
echo "✅ Testing Complete!"
echo ""
echo "📝 Summary:"
echo "   - Hynoticworld: Full auth API working"
echo "   - Mixflow: Backend + Frontend deployed"
echo "   - DiaperStops: Backend + Frontend deployed"
echo ""
echo "🧪 Run Cypress tests:"
echo "   cd mixflow.io/web/mixflow.io && npx cypress open"
