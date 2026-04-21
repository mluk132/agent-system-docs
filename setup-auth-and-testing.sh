#!/bin/bash

echo "🔐 Setting up Authentication & Testing for All Projects"
echo "========================================================"
echo ""

# Projects to set up
PROJECTS=(
  "mixflow.io/web/mixflow.io"
  "diaperstops.com/web/diaperstops.com"
  "hynoticworld"
)

# Function to add auth to a project
setup_auth() {
  local project=$1
  echo "📦 Setting up authentication for $project..."
  
  cd "$project" || return
  
  # Check if package.json exists
  if [ ! -f "package.json" ]; then
    echo "⚠️  No package.json found, skipping..."
    cd - > /dev/null
    return
  fi
  
  # Install auth dependencies
  echo "Installing auth dependencies..."
  npm install --legacy-peer-deps \
    jsonwebtoken \
    bcryptjs \
    axios \
    react-router-dom \
    @types/jsonwebtoken \
    @types/bcryptjs 2>&1 | tail -5
  
  cd - > /dev/null
}

# Function to setup Cypress
setup_cypress() {
  local project=$1
  echo "🧪 Setting up Cypress for $project..."
  
  cd "$project" || return
  
  if [ ! -f "package.json" ]; then
    echo "⚠️  No package.json found, skipping..."
    cd - > /dev/null
    return
  fi
  
  # Create Cypress config
  cat > cypress.config.ts << 'EOF'
import { defineConfig } from 'cypress'

export default defineConfig({
  e2e: {
    baseUrl: process.env.CYPRESS_BASE_URL || 'http://localhost:3000',
    setupNodeEvents(on, config) {},
  },
  env: {
    apiUrl: process.env.CYPRESS_API_URL || 'http://localhost:8080'
  }
})
EOF

  # Create test directory
  mkdir -p cypress/e2e
  
  # Create basic auth test
  cat > cypress/e2e/auth.cy.ts << 'EOF'
describe('Authentication', () => {
  it('should load the homepage', () => {
    cy.visit('/')
    cy.contains('Sign').should('exist')
  })

  it('should navigate to signup', () => {
    cy.visit('/')
    cy.contains('Sign Up').click()
    cy.url().should('include', '/signup')
  })

  it('should navigate to login', () => {
    cy.visit('/')
    cy.contains('Login').click()
    cy.url().should('include', '/login')
  })
})
EOF

  echo "✅ Cypress configured for $project"
  cd - > /dev/null
}

# Setup each project
for project in "${PROJECTS[@]}"; do
  echo ""
  echo "=== Processing $project ==="
  
  if [ -d "$project" ]; then
    setup_auth "$project"
    setup_cypress "$project"
  else
    echo "⚠️  Directory not found: $project"
  fi
done

echo ""
echo "✅ Setup Complete!"
echo ""
echo "📝 Next Steps:"
echo "1. Run Cypress tests: cd <project> && npx cypress open"
echo "2. Or run headless: cd <project> && npx cypress run"
echo "3. Deploy updates: cd projects && ./deploy-frontends.sh"
