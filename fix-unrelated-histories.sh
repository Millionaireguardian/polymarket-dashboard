#!/bin/bash
# Fix "unrelated histories" error by allowing merge of unrelated histories

cd "$(dirname "$0")"

# Load token from .bashrc if not already set
if [ -z "$GITHUB_TOKEN" ]; then
    if [ -f ~/.bashrc ]; then
        source ~/.bashrc
    fi
fi

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ GITHUB_TOKEN not set. Run: bash setup-github.sh"
    exit 1
fi

REMOTE_URL="https://${GITHUB_TOKEN}@github.com/Millionaireguardian/polymarket-dashboard.git"

echo "🔧 Fixing unrelated histories issue..."
echo ""

# Fetch remote
echo "Fetching remote changes..."
git fetch "$REMOTE_URL" main

# Pull with allow-unrelated-histories
echo "Merging unrelated histories..."
if git pull "$REMOTE_URL" main --allow-unrelated-histories --no-edit; then
    echo ""
    echo "✅ Successfully merged unrelated histories!"
    echo ""
    echo "Now you can push:"
    echo "   bash push-github.sh"
    echo ""
else
    echo ""
    echo "❌ Merge failed. You may have conflicts to resolve."
    echo "   Check git status and resolve conflicts manually."
    exit 1
fi

