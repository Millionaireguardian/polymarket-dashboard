#!/bin/bash
# Clean tokens from files and attempt to push
# If push fails due to history, provides instructions

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

echo "🧹 Ensuring no tokens in current files..."
echo ""

# Verify no tokens in current files
if grep -r "ghp_" . --exclude-dir=.git --exclude="*.json" 2>/dev/null | grep -v "your_token" | grep -v "token_here"; then
    echo "⚠️  WARNING: Tokens found in current files!"
    echo "   Please remove them before pushing."
    exit 1
fi

echo "✅ Current files are clean"
echo ""

# Add and commit any changes
git add .
if ! git diff --staged --quiet; then
    git commit -m "Remove tokens from files - use environment variables only"
    echo "✅ Committed clean files"
fi

# Try to push
echo ""
echo "Attempting to push..."
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
    echo "❌ Push failed due to tokens in git history."
    echo ""
    echo "📋 You have two options:"
    echo ""
    echo "Option 1: Allow the secret (quick fix)"
    echo "   Visit these URLs to allow the secrets:"
    echo "   https://github.com/Millionaireguardian/polymarket-dashboard/security/secret-scanning/unblock-secret/37ZIjiHdfdRtviQ8in5EORlXQbd"
    echo "   https://github.com/Millionaireguardian/polymarket-dashboard/security/secret-scanning/unblock-secret/37bPzRFmfhyxQiZRnVMgZghNZ2g"
    echo ""
    echo "   Then run: bash push-github.sh"
    echo ""
    echo "Option 2: Clean git history (better long-term)"
    echo "   This requires rewriting history. See GITHUB_SETUP.md for details."
    echo ""
fi

