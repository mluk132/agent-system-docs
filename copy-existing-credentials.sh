#!/bin/bash
# Copy existing credentials from .env.neon files to new backend services

set -e

echo "🔄 Copying Existing Credentials to Backend Services"
echo "===================================================="
echo ""

# Get existing database URLs
MIXFLOW_DB=$(grep "^DATABASE_URL=" mixflow.io/backend/.env.neon 2>/dev/null | cut -d'=' -f2-)
DIAPERSTOPS_DB=$(grep "^DATABASE_URL=" diaperstops.com/backend/.env.neon 2>/dev/null | cut -d'=' -f2-)

if [ -z "$MIXFLOW_DB" ]; then
  echo "❌ Could not find mixflow database URL"
  exit 1
fi

if [ -z "$DIAPERSTOPS_DB" ]; then
  echo "❌ Could not find diaperstops database URL"
  exit 1
fi

echo "✅ Found existing database credentials"
echo ""

# Function to update backend .env
update_backend() {
  local backend_path=$1
  local db_url=$2
  local name=$3
  
  if [ -f "$backend_path/.env" ]; then
    # Update DATABASE_URL
    sed -i "s|DATABASE_URL=.*|DATABASE_URL=$db_url|" "$backend_path/.env"
    echo "✅ Updated $name with database URL"
  else
    echo "❌ $backend_path/.env not found"
  fi
}

# Update backends with appropriate database
echo "📊 Updating Backend Services:"
echo ""

# Use mixflow DB for mixflow-related services
update_backend "mixflow-backend/backend" "$MIXFLOW_DB" "mixflow-backend"
update_backend "healthflow-backend/backend" "$MIXFLOW_DB" "healthflow-backend"
update_backend "hypnotic-backend/backend" "$MIXFLOW_DB" "hypnotic-backend"

# Use diaperstops DB for diaperstops-related services
update_backend "diaperstops-backend/backend" "$DIAPERSTOPS_DB" "diaperstops-backend"
update_backend "propai-backend/backend" "$DIAPERSTOPS_DB" "propai-backend"
update_backend "finder-backend/backend" "$DIAPERSTOPS_DB" "finder-backend"

echo ""
echo "===================================================="
echo "✅ Database URLs copied to all backends!"
echo ""
echo "⚠️  Still need to add OPENAI_API_KEY to each .env file"
echo ""
echo "To add OpenAI key to all backends:"
echo '  export OPENAI_KEY="sk-proj-your-key-here"'
echo '  for backend in propai-backend diaperstops-backend mixflow-backend healthflow-backend hypnotic-backend finder-backend; do'
echo '    sed -i "s|OPENAI_API_KEY=.*|OPENAI_API_KEY=$OPENAI_KEY|" "$backend/backend/.env"'
echo '  done'
echo ""
echo "🧪 Test a backend:"
echo "  cd diaperstops-backend/backend"
echo "  npm run dev"
echo ""
