#!/bin/bash
# Simple script to fix remote URL and push

cd "$(dirname "$0")"

echo "🔧 Fixing remote URL and pushing..."
echo ""

# Force remove and re-add remote
echo "Step 1: Removing old remote..."
git remote remove origin 2>/dev/null || true
sleep 1

echo "Step 2: Adding correct remote..."
git remote add origin https://github.com/Millionaireguardian/polymarket-dashboard.git

echo "Step 3: Verifying remote..."
git remote -v
echo ""

# Check if URL is correct
ACTUAL=$(git remote get-url origin)
if [[ "$ACTUAL" == *"140.82.121.4"* ]] || [[ "$ACTUAL" != *"github.com"* ]]; then
    echo "⚠️  Remote URL still incorrect: $ACTUAL"
    echo "Trying alternative method..."
    git remote set-url origin https://github.com/Millionaireguardian/polymarket-dashboard.git
    echo "New URL: $(git remote get-url origin)"
    echo ""
fi

# Make sure we have files to commit
echo "Step 4: Checking files..."
if [ ! -f .nojekyll ]; then
    touch .nojekyll
    echo "Created .nojekyll"
fi

if [ ! -f data/trades.json ]; then
    mkdir -p data
    echo "[]" > data/trades.json
    echo "Created data/trades.json"
fi

git add .
echo ""

# Commit if needed
if ! git diff --staged --quiet || [ -z "$(git log --oneline 2>/dev/null)" ]; then
    echo "Step 5: Committing..."
    git commit -m "Initial dashboard commit" --allow-empty
    echo "✅ Committed"
else
    echo "Step 5: Already committed"
fi

echo ""
echo "Step 6: Pushing to GitHub..."
echo "Repository: $(git remote get-url origin)"
echo "Branch: $(git branch --show-current)"
echo ""

# Test access first
echo "Testing repository access..."
if git ls-remote origin >/dev/null 2>&1; then
    echo "✅ Repository accessible"
    echo ""
    git push -u origin main
else
    echo "❌ Cannot access repository"
    echo ""
    echo "The repository might not exist yet."
    echo "Create it at: https://github.com/new"
    echo "  - Name: polymarket-dashboard"
    echo "  - Make it PUBLIC"
    echo "  - Don't initialize with README"
    echo ""
    echo "Then run this script again."
    exit 1
fi

