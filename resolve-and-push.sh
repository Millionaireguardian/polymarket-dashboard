#!/bin/bash
# Resolve current merge conflict and push

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

echo "🔧 Resolving merge conflict and pushing..."
echo ""

# Resolve conflicts
bash resolve-conflict.sh

# Now push
echo "Pushing to GitHub..."
REMOTE_URL="https://${GITHUB_TOKEN}@github.com/Millionaireguardian/polymarket-dashboard.git"

if git push "$REMOTE_URL" main; then
    echo ""
    echo "✅ Successfully pushed to GitHub!"
    echo ""
    echo "🌐 Dashboard available at:"
    echo "   https://Millionaireguardian.github.io/polymarket-dashboard/"
    echo ""
else
    echo ""
    echo "❌ Push failed. Check the error above."
    exit 1
fi

