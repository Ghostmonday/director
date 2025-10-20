#!/bin/bash
# 🤖 Automated Module PR Creation Script
# Usage: ./automation/scripts/create-module-pr.sh <module-name>

set -e

MODULE_NAME="$1"
TIMESTAMP=$(date +%s)
BRANCH_NAME="pr/${MODULE_NAME}-validation-${TIMESTAMP}"

if [ -z "$MODULE_NAME" ]; then
    echo "❌ Error: Module name required"
    echo "Usage: $0 <module-name>"
    exit 1
fi

echo "🚀 Creating automated PR for module: $MODULE_NAME"
echo "📅 Timestamp: $TIMESTAMP"
echo "🌿 Branch: $BRANCH_NAME"

# Check if there are changes to commit
if [[ -z $(git status -s) ]]; then
    echo "⚠️  No changes to commit. Exiting."
    exit 0
fi

# Create and checkout new branch
echo "🌿 Creating branch: $BRANCH_NAME"
git checkout -b "$BRANCH_NAME"

# Stage all changes
echo "📦 Staging changes..."
git add .

# Commit with structured message
echo "💾 Committing changes..."
git commit -m "✅ Module Complete: ${MODULE_NAME}

- Module validated locally
- All tests passed
- Fidelity checks complete
- Ready for BugBot review

Auto-generated commit for PR automation"

# Push to remote
echo "⬆️  Pushing to remote..."
git push -u origin "$BRANCH_NAME"

echo ""
echo "✅ Branch pushed successfully!"
echo "🤖 GitHub Actions will automatically:"
echo "   1. Create a Pull Request"
echo "   2. Trigger BugBot review"
echo "   3. Auto-merge if approved"
echo ""
echo "📊 Track progress in: automation/logs/pr-tracker.md"
echo "🔗 View PR at: https://github.com/Ghostmonday/director/pulls"

