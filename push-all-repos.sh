#!/bin/bash

# Push all git repositories in the projects directory
# Date: June 3, 2026

REPOS=(
    "."
    "agent-platform-e2e"
    "agent-queue"
    "android-app-template"
    "ClimateWardrobe"
    "diaperstops-backend"
    "diaperstops.com"
    "diaperstops-frontend"
    "finance"
    "finder-backend"
    "health-fit"
    "healthflow-backend"
    "hynoticworld"
    "hypermedia-oasis"
    "hypnotic-backend"
    "land-dev-agent"
    "lush-playground"
    "mixflow-backend"
    "mixflow-frontend"
    "mixflow.io"
    "mobile-prompt-server"
    "propai-backend"
    "reno-app"
    "renovation-workflow"
    "simple-cloud-agent"
    "templates"
    "thriveinterview"
    "translator"
)

SUCCESS=0
FAILED=0
SKIPPED=0

echo "========================================"
echo "Pushing all repositories"
echo "========================================"
echo ""

for repo in "${REPOS[@]}"; do
    echo "----------------------------------------"
    echo "Repository: $repo"
    echo "----------------------------------------"
    
    cd "$repo" || continue
    
    # Check if there are any changes
    if git status --porcelain | grep -q .; then
        echo "✓ Changes detected, committing..."
        git add -A
        git commit -m "Auto-commit: Push all repos - $(date '+%Y-%m-%d %H:%M:%S')" || true
    else
        echo "• No uncommitted changes"
    fi
    
    # Check if we're ahead of remote
    LOCAL=$(git rev-parse @ 2>/dev/null)
    REMOTE=$(git rev-parse @{u} 2>/dev/null)
    
    if [ "$LOCAL" != "$REMOTE" ] 2>/dev/null; then
        echo "⬆ Pushing to remote..."
        
        # Get current remote URL
        REMOTE_URL=$(git remote get-url origin 2>/dev/null)
        
        # Convert HTTPS to SSH if needed
        if [[ $REMOTE_URL == https://github.com/* ]]; then
            SSH_URL=$(echo "$REMOTE_URL" | sed -E 's|https://.*@github.com/|git@github.com:|' | sed -E 's|https://github.com/|git@github.com:|')
            echo "  Converting to SSH: $SSH_URL"
            git remote set-url origin "$SSH_URL"
        fi
        
        if git push 2>&1; then
            echo "✅ Successfully pushed: $repo"
            ((SUCCESS++))
        else
            echo "❌ Failed to push: $repo"
            ((FAILED++))
        fi
    else
        echo "✓ Already up to date"
        ((SKIPPED++))
    fi
    
    cd - > /dev/null
    echo ""
done

echo "========================================"
echo "Summary"
echo "========================================"
echo "✅ Successfully pushed: $SUCCESS"
echo "❌ Failed: $FAILED"
echo "✓ Skipped (up to date): $SKIPPED"
echo "========================================"
