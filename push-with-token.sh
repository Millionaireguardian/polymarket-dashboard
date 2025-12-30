#!/bin/bash
# Push dashboard to GitHub using Personal Access Token
# Usage: GITHUB_TOKEN=your_token bash push-with-token.sh

cd "$(dirname "$0")"

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Error: GITHUB_TOKEN environment variable not set"
    echo ""
    echo "Usage:"
    echo "  export GITHUB_TOKEN=your_github_token"
    echo "  bash push-with-token.sh"
    echo ""
    echo "Or:"
    echo "  GITHUB_TOKEN=your_github_token bash push-with-token.sh"
    exit 1
fi

echo "🚀 Pushing dashboard to GitHub with token..."
echo ""

# Ensure required files
touch .nojekyll
mkdir -p data

# Add all files
git add .

# Commit if there are changes
if ! git diff --staged --quiet; then
    git commit -m "Update dashboard - $(date +%Y-%m-%d\ %H:%M:%S)"
    echo "✅ Committed changes"
fi

# Push with token
echo "Pushing to GitHub..."
if git push https://${GITHUB_TOKEN}@github.com/Millionaireguardian/polymarket-dashboard.git main; then
    echo ""
    echo "✅ Successfully pushed to GitHub!"
    echo ""
    echo "🌐 Dashboard available at:"
    echo "   https://Millionaireguardian.github.io/polymarket-dashboard/"
    echo ""
else
    echo ""
    echo "❌ Push failed. Check your token has 'repo' permissions."
    exit 1
fi

