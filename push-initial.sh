#!/bin/bash
# Script to push initial content to GitHub repository

cd "$(dirname "$0")"

echo "🚀 Pushing initial dashboard content to GitHub..."
echo ""

# Initialize git if not already done
if [ ! -d .git ]; then
    echo "Initializing git repository..."
    git init
    echo "✅ Git initialized"
fi

# Set correct remote URL (force update)
echo "Setting remote URL to GitHub..."
git remote remove origin 2>/dev/null || true
git remote remove origin 2>/dev/null || true  # Try twice to be sure
git remote add origin https://github.com/Millionaireguardian/polymarket-dashboard.git

# Force update URL in case it was cached
git remote set-url origin https://github.com/Millionaireguardian/polymarket-dashboard.git

echo "✅ Remote set to: https://github.com/Millionaireguardian/polymarket-dashboard.git"
echo ""

# Verify remote
echo "Current remote:"
git remote -v
echo ""

# Double-check the URL is correct
ACTUAL_URL=$(git remote get-url origin)
if [[ "$ACTUAL_URL" != "https://github.com/Millionaireguardian/polymarket-dashboard.git" ]]; then
    echo "⚠️  Warning: Remote URL mismatch!"
    echo "   Expected: https://github.com/Millionaireguardian/polymarket-dashboard.git"
    echo "   Actual: $ACTUAL_URL"
    echo "   Forcing update..."
    git remote set-url origin https://github.com/Millionaireguardian/polymarket-dashboard.git
    echo "   Updated. New URL: $(git remote get-url origin)"
    echo ""
fi

# Set branch to main
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")
if [ -z "$CURRENT_BRANCH" ]; then
    echo "Creating main branch..."
    git checkout -b main 2>/dev/null || git branch -M main
    CURRENT_BRANCH="main"
else
    if [ "$CURRENT_BRANCH" != "main" ]; then
        echo "Renaming branch to main..."
        git branch -M main
        CURRENT_BRANCH="main"
    fi
fi

echo "Current branch: $CURRENT_BRANCH"
echo ""

# Ensure .nojekyll exists
if [ ! -f .nojekyll ]; then
    echo "Creating .nojekyll file..."
    touch .nojekyll
    echo "✅ .nojekyll created"
fi

# Ensure data directory and trades.json exist
if [ ! -d data ]; then
    mkdir -p data
    echo "✅ data/ directory created"
fi

if [ ! -f data/trades.json ]; then
    echo "[]" > data/trades.json
    echo "✅ data/trades.json created"
fi

# Add all files
echo "Adding all files..."
git add .

# Show what will be committed
echo ""
echo "Files to be committed:"
git status --short
echo ""

# Commit changes (force commit even if nothing changed, to ensure initial push)
if git diff --staged --quiet && [ -z "$(git log --oneline 2>/dev/null)" ]; then
    echo "Making initial commit..."
    git commit -m "Initial dashboard commit - Polymarket Arbitrage Bot Tracker" --allow-empty
    echo "✅ Initial commit created"
elif ! git diff --staged --quiet; then
    echo "Committing changes..."
    git commit -m "Update dashboard - $(date +%Y-%m-%d)"
    echo "✅ Changes committed"
else
    echo "⚠️  No changes to commit, but will attempt to push existing commits..."
fi

# Push to GitHub
echo ""
echo "Pushing to GitHub..."
FINAL_URL=$(git remote get-url origin)
echo "Repository URL: $FINAL_URL"
echo "Branch: $CURRENT_BRANCH"
echo "You may be prompted for authentication..."
echo ""

# Check if repository exists by trying to fetch first
echo "Verifying repository access..."
if git ls-remote origin >/dev/null 2>&1; then
    echo "✅ Repository is accessible"
else
    echo "❌ Cannot access repository. Possible issues:"
    echo "   1. Repository doesn't exist at: https://github.com/Millionaireguardian/polymarket-dashboard"
    echo "   2. You don't have access to it"
    echo "   3. Authentication required"
    echo ""
    echo "Please:"
    echo "   1. Verify the repository exists: https://github.com/Millionaireguardian/polymarket-dashboard"
    echo "   2. If it doesn't exist, create it at: https://github.com/new"
    echo "      - Name: polymarket-dashboard"
    echo "      - Make it PUBLIC"
    echo "      - Don't initialize with README"
    echo "   3. Then run this script again"
    exit 1
fi

echo ""

# Try to push
PUSH_OUTPUT=$(git push -u origin $CURRENT_BRANCH 2>&1)
PUSH_EXIT=$?

if [ $PUSH_EXIT -eq 0 ]; then
    echo ""
    echo "✅ Successfully pushed to GitHub!"
    echo ""
    echo "🌐 Your dashboard will be available at:"
    echo "   https://Millionaireguardian.github.io/polymarket-dashboard/"
    echo ""
    echo "📝 Next steps:"
    echo "   1. Go to https://github.com/Millionaireguardian/polymarket-dashboard/settings/pages"
    echo "   2. Enable GitHub Pages:"
    echo "      - Source: Deploy from a branch"
    echo "      - Branch: main"
    echo "      - Folder: / (root)"
    echo "   3. Save and wait a few minutes for the site to build"
    echo ""
else
    echo ""
    echo "❌ Push failed (exit code: $PUSH_EXIT)"
    echo ""
    echo "Common issues and solutions:"
    echo ""
    echo "1. Authentication required:"
    echo "   - Use GitHub CLI: gh auth login"
    echo "   - Or use a Personal Access Token:"
    echo "     git push https://<TOKEN>@github.com/Millionaireguardian/polymarket-dashboard.git main"
    echo ""
    echo "2. Repository doesn't exist:"
    echo "   - Go to https://github.com/new"
    echo "   - Repository name: polymarket-dashboard"
    echo "   - Make it PUBLIC (required for free GitHub Pages)"
    echo "   - Don't initialize with README"
    echo "   - Create repository, then run this script again"
    echo ""
    echo "3. Permission denied:"
    echo "   - Make sure you have push access to the repository"
    echo "   - Check repository settings at:"
    echo "     https://github.com/Millionaireguardian/polymarket-dashboard/settings"
    echo ""
    exit $EXIT_CODE
fi

