#!/bin/bash
# Convenient script to push dashboard updates to GitHub
# Uses the configured GitHub token from environment

cd "$(dirname "$0")"

# Load token from .bashrc if not already set
if [ -z "$GITHUB_TOKEN" ]; then
    if [ -f ~/.bashrc ]; then
        source ~/.bashrc
    fi
fi

# If still not set, try to get it from setup
if [ -z "$GITHUB_TOKEN" ]; then
    echo "⚠️  GITHUB_TOKEN not found in environment"
    echo "   Running setup-github.sh to configure..."
    bash setup-github.sh
    source ~/.bashrc 2>/dev/null || true
fi

# Ensure git user is configured
if [ -z "$(git config user.name)" ]; then
    git config user.name "Nuke Rewards Dev"
    git config user.email "Millionaireguardian@users.noreply.github.com"
fi

echo "🚀 Pushing dashboard updates to GitHub..."
echo ""

# Ensure required files
touch .nojekyll
mkdir -p data
if [ ! -f data/trades.json ]; then
    echo "[]" > data/trades.json
fi

# Add all files
git add .

# Commit if there are changes
if ! git diff --staged --quiet; then
    COMMIT_MSG="Update dashboard - $(date +%Y-%m-%d\ %H:%M:%S)"
    git commit -m "$COMMIT_MSG"
    echo "✅ Committed: $COMMIT_MSG"
else
    echo "ℹ️  No changes to commit"
fi

# Push with token
echo ""
echo "Pushing to GitHub..."
if [ -n "$GITHUB_TOKEN" ]; then
    if git push https://${GITHUB_TOKEN}@github.com/Millionaireguardian/polymarket-dashboard.git main; then
        echo ""
        echo "✅ Successfully pushed to GitHub!"
        echo ""
        echo "🌐 Dashboard available at:"
        echo "   https://Millionaireguardian.github.io/polymarket-dashboard/"
        echo ""
        exit 0
    else
        echo "❌ Push failed with token, trying regular push..."
    fi
fi

# Fallback to regular push
if git push origin main; then
    echo ""
    echo "✅ Successfully pushed to GitHub!"
    echo ""
    echo "🌐 Dashboard available at:"
    echo "   https://Millionaireguardian.github.io/polymarket-dashboard/"
    echo ""
else
    echo ""
    echo "❌ Push failed. Please check:"
    echo "   1. Your GitHub token is valid and has 'repo' permissions"
    echo "   2. Run: bash setup-github.sh"
    echo ""
    exit 1
fi

