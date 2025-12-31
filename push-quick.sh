#!/bin/bash
# Quick push script that handles password prompt automatically

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

# Disable credential prompts
export GIT_TERMINAL_PROMPT=0

# Add and commit changes
git add .
if ! git diff --staged --quiet; then
    git commit -m "Update dashboard - $(date +%Y-%m-%d\ %H:%M:%S)"
fi

# Push using token (just press Enter if prompted for password)
echo "Pushing to GitHub..."
echo "If prompted for password, just press ENTER (token is in URL)"
echo ""

REMOTE_URL="https://${GITHUB_TOKEN}@github.com/Millionaireguardian/polymarket-dashboard.git"

# Use GIT_ASKPASS to automatically provide empty password
GIT_ASKPASS=true git push "$REMOTE_URL" main 2>&1 || {
    # If that fails, try with credential helper disabled
    GIT_TERMINAL_PROMPT=0 git -c credential.helper= push "$REMOTE_URL" main
}

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Successfully pushed to GitHub!"
    echo ""
    echo "🌐 Dashboard available at:"
    echo "   https://Millionaireguardian.github.io/polymarket-dashboard/"
    echo ""
else
    echo ""
    echo "❌ Push failed. Try running:"
    echo "   git push $REMOTE_URL main"
    echo "   (When prompted for password, just press ENTER)"
    echo ""
fi

