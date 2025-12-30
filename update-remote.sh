#!/bin/bash
# Quick script to update the git remote URL

cd "$(dirname "$0")"

echo "Updating git remote URL..."
git remote set-url origin https://github.com/Millionaireguardian/polymarket-dashboard.git

echo "✅ Remote updated!"
echo ""
echo "Current remote:"
git remote -v
echo ""
echo "Test with: npm run deploy-dashboard"

