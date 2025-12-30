#!/bin/bash
# Quick script to push dashboard updates to GitHub
# This ensures trades.json and all dashboard files are pushed

cd "$(dirname "$0")"

echo "🚀 Pushing dashboard updates to GitHub..."
echo ""

# Ensure .nojekyll exists (required for GitHub Pages)
if [ ! -f .nojekyll ]; then
    touch .nojekyll
    echo "✅ Created .nojekyll file"
fi

# Ensure data directory exists
if [ ! -d data ]; then
    mkdir -p data
    echo "✅ Created data/ directory"
fi

# Ensure trades.json exists (even if empty)
if [ ! -f data/trades.json ]; then
    echo "[]" > data/trades.json
    echo "✅ Created data/trades.json"
fi

# Check git status
if [ ! -d .git ]; then
    echo "⚠️  Git not initialized. Running setup..."
    bash setup-git.sh
    exit $?
fi

# Set remote if not set
if ! git remote get-url origin >/dev/null 2>&1; then
    echo "Setting remote..."
    git remote add origin https://github.com/Millionaireguardian/polymarket-dashboard.git
fi

# Verify remote URL
CURRENT_URL=$(git remote get-url origin)
if [[ "$CURRENT_URL" != *"Millionaireguardian/polymarket-dashboard"* ]]; then
    echo "Updating remote URL..."
    git remote set-url origin https://github.com/Millionaireguardian/polymarket-dashboard.git
fi

# Add all files (including trades.json)
echo "Adding all files..."
git add .

# Show status
echo ""
echo "Files to be committed:"
git status --short
echo ""

# Commit
COMMIT_MSG="Update dashboard - $(date +%Y-%m-%d\ %H:%M:%S)"
if git diff --staged --quiet; then
    echo "No changes to commit, but will try to push..."
else
    echo "Committing changes..."
    git commit -m "$COMMIT_MSG"
    echo "✅ Committed: $COMMIT_MSG"
fi

# Push
echo ""
echo "Pushing to GitHub..."

# Try to use GITHUB_TOKEN from environment if available
if [ -n "$GITHUB_TOKEN" ]; then
    echo "Using GITHUB_TOKEN from environment..."
    if git push https://${GITHUB_TOKEN}@github.com/Millionaireguardian/polymarket-dashboard.git main; then
        echo ""
        echo "✅ Successfully pushed to GitHub!"
        echo ""
        echo "🌐 Dashboard available at:"
        echo "   https://Millionaireguardian.github.io/polymarket-dashboard/"
        echo ""
        exit 0
    else
        echo "❌ Push with token failed, trying regular push..."
    fi
fi

# Try regular push
if git push origin main; then
    echo ""
    echo "✅ Successfully pushed to GitHub!"
    echo ""
    echo "🌐 Dashboard available at:"
    echo "   https://Millionaireguardian.github.io/polymarket-dashboard/"
    echo ""
else
    echo ""
    echo "❌ Push failed. You need to authenticate."
    echo ""
    echo "Set your GitHub Personal Access Token:"
    echo "   export GITHUB_TOKEN=your_token_here"
    echo ""
    echo "Then run this script again, or push directly:"
    echo "   git push https://\${GITHUB_TOKEN}@github.com/Millionaireguardian/polymarket-dashboard.git main"
    echo ""
    exit 1
fi

