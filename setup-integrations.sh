#!/bin/bash

# Jira and Slack Integration Setup Script

echo "=== Jira & Slack Integration Setup ==="
echo ""

# Jira Configuration
echo "📋 JIRA SETUP:"
echo "1. Install 'Git Integration for Jira' from Atlassian Marketplace"
echo "2. Connect your GitHub account in Jira Settings > Apps > Git Integration"
echo "3. Enable Smart Commits for automatic ticket updates"
echo ""
echo "Smart Commit Examples:"
echo "  git commit -m 'PROJ-123 #comment Fixed login bug'"
echo "  git commit -m 'PROJ-456 #close Completed feature'"
echo "  git commit -m 'PROJ-789 #time 2h 30m Working on API'"
echo ""

# Slack Configuration
echo "📢 SLACK SETUP:"
echo "Create channels for each project:"
echo ""

PROJECTS=(
  "mixflow-io"
  "diaperstops-com"
  "renovation-workflow"
  "thriveinterview"
  "reno-app"
  "hynoticworld"
  "android-app-template"
  "templates"
  "climate-wardrobe"
  "translator"
)

for project in "${PROJECTS[@]}"; do
  echo "  #$project"
done

echo ""
echo "Slack Integration Steps:"
echo "1. Go to Slack workspace settings"
echo "2. Add GitHub app to Slack"
echo "3. Subscribe channels: /github subscribe owner/repo"
echo "4. Add Jira app to Slack for ticket notifications"
echo ""

# Git Hooks for Smart Commits
echo "🔗 GIT HOOKS SETUP:"
echo "Creating commit-msg hook template..."

cat > /tmp/commit-msg-template << 'EOF'
#!/bin/bash
# Jira Smart Commit Hook
# Validates commit messages include Jira ticket reference

commit_msg=$(cat "$1")

# Check if commit message contains Jira ticket pattern (PROJ-123)
if ! echo "$commit_msg" | grep -qE '[A-Z]+-[0-9]+'; then
  echo "⚠️  Warning: No Jira ticket reference found (e.g., PROJ-123)"
  echo "Consider adding ticket reference for automatic Jira updates"
fi
EOF

echo "Template created at /tmp/commit-msg-template"
echo "To install in a repo: cp /tmp/commit-msg-template .git/hooks/commit-msg && chmod +x .git/hooks/commit-msg"
echo ""

# GitHub CLI Jira Integration
echo "🔧 GITHUB CLI JIRA INTEGRATION:"
echo "Link commits to Jira using branch naming:"
echo "  git checkout -b PROJ-123-feature-name"
echo "  git commit -m 'PROJ-123 Implement feature'"
echo ""

echo "✅ Setup guide complete!"
echo ""
echo "Next steps:"
echo "1. Configure Jira Git Integration app"
echo "2. Create Slack channels listed above"
echo "3. Install git hooks in each project"
echo "4. Test with a smart commit"
