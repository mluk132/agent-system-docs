#!/bin/bash

# Force push repos that failed due to remote changes
# Date: June 3, 2026

FAILED_REPOS=(
    "diaperstops-backend"
    "diaperstops-frontend"
    "finder-backend"
    "healthflow-backend"
    "hypnotic-backend"
    "mixflow-backend"
    "mixflow-frontend"
    "propai-backend"
)

SUCCESS=0
FAILED=0

echo "========================================"
echo "Fixing failed pushes (pull + push)"
echo "========================================"
echo ""

for repo in "${FAILED_REPOS[@]}"; do
    echo "----------------------------------------"
    echo "Repository: $repo"
    echo "----------------------------------------"
    
    cd "$repo" || continue
    
    echo "⬇ Pulling remote changes..."
    git pull --rebase || git pull --no-rebase || true
    
    echo "⬆ Pushing to remote..."
    if git push 2>&1; then
        echo "✅ Successfully pushed: $repo"
        ((SUCCESS++))
    else
        echo "❌ Still failed: $repo"
        ((FAILED++))
    fi
    
    cd - > /dev/null
    echo ""
done

echo "========================================"
echo "Summary"
echo "========================================"
echo "✅ Successfully pushed: $SUCCESS"
echo "❌ Failed: $FAILED"
echo "========================================"
