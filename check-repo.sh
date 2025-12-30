#!/bin/bash
# Quick script to check repository status and fix remote URL

cd "$(dirname "$0")"

echo "🔍 Checking repository status..."
echo ""

# Check if git repo exists
if [ ! -d .git ]; then
    echo "❌ Not a git repository"
    echo "Run: git init"
    exit 1
fi

echo "Current remote URLs:"
git remote -v
echo ""

# Get current remote URL
CURRENT_URL=$(git remote get-url origin 2>/dev/null || echo "none")

echo "Current remote URL: $CURRENT_URL"
echo ""

# Check if it's the internal IP
if [[ "$CURRENT_URL" == *"140.82.121.4"* ]]; then
    echo "⚠️  Detected internal IP in remote URL"
    echo "Updating to GitHub URL..."
    git remote set-url origin https://github.com/Millionaireguardian/polymarket-dashboard.git
    echo "✅ Updated"
    echo ""
    echo "New remote URL:"
    git remote -v
    echo ""
fi

# Test repository access
echo "Testing repository access..."
if git ls-remote origin >/dev/null 2>&1; then
    echo "✅ Repository is accessible!"
    echo ""
    echo "You can now push with:"
    echo "  git push -u origin main"
    echo ""
    echo "Or use: npm run push-initial"
else
    echo "❌ Cannot access repository"
    echo ""
    echo "Possible reasons:"
    echo "  1. Repository doesn't exist: https://github.com/Millionaireguardian/polymarket-dashboard"
    echo "  2. Authentication required"
    echo "  3. No access permissions"
    echo ""
    echo "To create the repository:"
    echo "  1. Go to: https://github.com/new"
    echo "  2. Name: polymarket-dashboard"
    echo "  3. Make it PUBLIC"
    echo "  4. Don't initialize with README"
    echo "  5. Create repository"
    exit 1
fi

