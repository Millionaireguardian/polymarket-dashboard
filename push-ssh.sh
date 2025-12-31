#!/bin/bash
# Push using SSH (no tokens needed)

cd "$(dirname "$0")"

echo "🚀 Pushing dashboard updates to GitHub (SSH)..."
echo ""

# Ensure git user is configured
if [ -z "$(git config user.name)" ]; then
    git config user.name "Nuke Rewards Dev"
    git config user.email "Millionaireguardian@users.noreply.github.com"
fi

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
    git commit -m "Update dashboard - $(date +%Y-%m-%d\ %H:%M:%S)"
    echo "✅ Committed changes"
fi

# Check remote URL
REMOTE_URL=$(git remote get-url origin)
if [[ "$REMOTE_URL" != *"git@github.com"* ]]; then
    echo "⚠️  Remote is not using SSH. Configuring..."
    git remote set-url origin git@github.com:Millionaireguardian/polymarket-dashboard.git
fi

# Push using SSH
echo ""
echo "Pushing to GitHub via SSH..."
if git push origin main; then
    echo ""
    echo "✅ Successfully pushed to GitHub!"
    echo ""
    echo "🌐 Dashboard available at:"
    echo "   https://Millionaireguardian.github.io/polymarket-dashboard/"
    echo ""
else
    echo ""
    echo "❌ Push failed."
    echo ""
    echo "If this is your first time using SSH:"
    echo "  1. Run: bash setup-ssh-auth.sh"
    echo "  2. Add your SSH key to GitHub"
    echo "  3. Try again"
    echo ""
    exit 1
fi

