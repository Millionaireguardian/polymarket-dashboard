#!/bin/bash
# Push script using proper GitHub token authentication

cd "$(dirname "$0")"

# Load token
if [ -z "$GITHUB_TOKEN" ]; then
    if [ -f ~/.bashrc ]; then
        source ~/.bashrc
    fi
fi

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ GITHUB_TOKEN not set. Run: bash setup-github.sh"
    exit 1
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
    git commit -m "Update dashboard - $(date +%Y-%m-%d\ %H:%M:%S)"
    echo "✅ Committed changes"
fi

# Set remote URL with token (using username:token format)
echo "Configuring remote with token..."
git remote set-url origin https://${GITHUB_TOKEN}@github.com/Millionaireguardian/polymarket-dashboard.git

# Use git credential helper to store token
echo "https://${GITHUB_TOKEN}@github.com" > ~/.git-credentials
git config --global credential.helper store

# Push
echo "Pushing to GitHub..."
if git push origin main; then
    echo ""
    echo "✅ Successfully pushed to GitHub!"
    echo ""
    echo "🌐 Dashboard available at:"
    echo "   https://Millionaireguardian.github.io/polymarket-dashboard/"
    echo ""
    
    # Clean up credentials file for security
    rm -f ~/.git-credentials
    git config --global --unset credential.helper
    echo "✅ Credentials cleaned up"
else
    echo ""
    echo "❌ Push failed. The token might be invalid or expired."
    echo ""
    echo "Please verify:"
    echo "1. Token is valid at: https://github.com/settings/tokens"
    echo "2. Token has 'repo' permissions"
    echo "3. Token hasn't expired"
    echo ""
    echo "To create a new token:"
    echo "1. Go to: https://github.com/settings/tokens/new"
    echo "2. Name: polymarket-dashboard"
    echo "3. Select 'repo' scope"
    echo "4. Generate token"
    echo "5. Update ~/.bashrc with: export GITHUB_TOKEN=new_token"
    exit 1
fi

