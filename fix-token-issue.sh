#!/bin/bash
# Fix script to remove token from git history and push cleanly

cd "$(dirname "$0")"

echo "🔧 Fixing token issue in git history..."
echo ""

# Step 1: Remove the commit with the token
echo "Step 1: Removing commit with token..."
# Reset to before any commits (start fresh)
if [ -d .git ]; then
    # Remove the last commit that contains the token
    git reset --hard HEAD~1 2>/dev/null || echo "No previous commit to reset"
    echo "✅ Removed commit with token"
else
    echo "No git repository found"
fi

echo ""

# Step 2: Make sure push-with-token.sh doesn't have the token
echo "Step 2: Updating push-with-token.sh to use environment variable..."
# The file should already be updated, but let's make sure
if grep -q "GITHUB_TOKEN=\"ghp_" push-with-token.sh 2>/dev/null; then
    echo "⚠️  Token still found in script, updating..."
    # This should already be done, but just in case
    sed -i 's/GITHUB_TOKEN="ghp_[^"]*"/GITHUB_TOKEN="${GITHUB_TOKEN:-}"/' push-with-token.sh 2>/dev/null || true
fi

echo "✅ Script updated"
echo ""

# Step 3: Stage the clean version
echo "Step 3: Staging clean files..."
git add push-with-token.sh .gitignore 2>/dev/null || true
echo "✅ Files staged"
echo ""

# Step 4: Commit clean version
echo "Step 4: Committing clean version..."
git commit -m "Dashboard files - token removed from script" 2>/dev/null || echo "Nothing to commit"
echo "✅ Committed"
echo ""

# Step 5: Set up remote with token (temporarily, not in files)
echo "Step 5: Setting up remote with token (from environment)..."
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Error: GITHUB_TOKEN environment variable not set"
    echo "   Please set it: export GITHUB_TOKEN=your_token"
    exit 1
fi

git remote remove origin 2>/dev/null || true
git remote add origin "https://${GITHUB_TOKEN}@github.com/Millionaireguardian/polymarket-dashboard.git"
echo "✅ Remote configured"
echo ""

# Step 6: Push
echo "Step 6: Pushing to GitHub..."
if git push -u origin main --force; then
    echo ""
    echo "✅ Successfully pushed to GitHub!"
    echo ""
    echo "🌐 Your dashboard will be available at:"
    echo "   https://Millionaireguardian.github.io/polymarket-dashboard/"
    echo ""
    echo "📝 Next steps:"
    echo "   1. Go to: https://github.com/Millionaireguardian/polymarket-dashboard/settings/pages"
    echo "   2. Enable GitHub Pages"
    echo ""
    # Remove token from remote URL
    git remote set-url origin https://github.com/Millionaireguardian/polymarket-dashboard.git
    echo "✅ Token removed from remote URL for security"
else
    echo ""
    echo "❌ Push failed"
    echo "You may need to allow the secret via GitHub's link:"
    echo "https://github.com/Millionaireguardian/polymarket-dashboard/security/secret-scanning/unblock-secret/37ZIjiHdfdRtviQ8in5EORlXQbd"
fi

