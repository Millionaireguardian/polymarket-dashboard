#!/bin/bash
# Convenient script to push dashboard updates to GitHub
# Uses the configured GitHub token from environment

cd "$(dirname "$0")"

# Load token from .bashrc if not already set
if [ -z "$GITHUB_TOKEN" ]; then
    if [ -f ~/.bashrc ]; then
        source ~/.bashrc
    fi
fi

# If still not set, try to get it from setup
if [ -z "$GITHUB_TOKEN" ]; then
    echo "⚠️  GITHUB_TOKEN not found in environment"
    echo "   Running setup-github.sh to configure..."
    bash setup-github.sh
    source ~/.bashrc 2>/dev/null || true
fi

# Ensure git user is configured
if [ -z "$(git config user.name)" ]; then
    git config user.name "Nuke Rewards Dev"
    git config user.email "Millionaireguardian@users.noreply.github.com"
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
    COMMIT_MSG="Update dashboard - $(date +%Y-%m-%d\ %H:%M:%S)"
    git commit -m "$COMMIT_MSG"
    echo "✅ Committed: $COMMIT_MSG"
else
    echo "ℹ️  No changes to commit"
fi

# Check if we need to pull first
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ GITHUB_TOKEN not set. Run: bash setup-github.sh"
    exit 1
fi

# Use full URL with token to bypass any cached credentials
# This ensures we use the token, not cached credentials for imgprotocoldev
REMOTE_URL="https://${GITHUB_TOKEN}@github.com/Millionaireguardian/polymarket-dashboard.git"

echo "Checking remote status..."

# Fetch remote changes
if git fetch "$REMOTE_URL" main 2>/dev/null; then
    LOCAL=$(git rev-parse HEAD)
    REMOTE=$(git rev-parse FETCH_HEAD 2>/dev/null || echo "")
    
    if [ -n "$REMOTE" ] && [ "$LOCAL" != "$REMOTE" ]; then
        # Check if we're behind
        if git merge-base --is-ancestor "$LOCAL" "$REMOTE" 2>/dev/null; then
            echo "⚠️  Remote has new commits. Pulling and merging..."
            # Pull with token to avoid credential issues
            if git pull "$REMOTE_URL" main --no-edit; then
                echo "✅ Successfully pulled and merged remote changes"
            else
                echo "⚠️  Merge conflict or pull failed. Attempting to pull with merge strategy..."
                git pull "$REMOTE_URL" main --no-rebase --no-edit || {
                    echo "❌ Could not automatically merge. Please resolve conflicts manually."
                    echo "   You can try: git pull $REMOTE_URL main"
                    exit 1
                }
            fi
        else
            echo "⚠️  Local and remote have diverged. Attempting to merge..."
            if git pull "$REMOTE_URL" main --no-rebase --no-edit; then
                echo "✅ Successfully merged remote changes"
            else
                echo "❌ Could not automatically merge diverged branches."
                echo "   You may need to resolve conflicts manually or use:"
                echo "   git pull $REMOTE_URL main --rebase"
                exit 1
            fi
        fi
    else
        echo "✅ Local is up to date with remote"
    fi
else
    echo "⚠️  Could not fetch from remote (this is OK if repo is new)"
fi

# Push with token (using full URL to bypass credential cache)
echo ""
echo "Pushing to GitHub..."
# REMOTE_URL already defined above with token - using it here
# This ensures we use the token, not cached credentials for imgprotocoldev

if git push "$REMOTE_URL" main; then
    echo ""
    echo "✅ Successfully pushed to GitHub!"
    echo ""
    echo "🌐 Dashboard available at:"
    echo "   https://Millionaireguardian.github.io/polymarket-dashboard/"
    echo ""
    exit 0
else
    echo ""
    echo "❌ Push failed. Please check:"
    echo "   1. Your GitHub token is valid and has 'repo' permissions"
    echo "   2. Token: ${GITHUB_TOKEN:0:10}... (first 10 chars)"
    echo "   3. Run: bash setup-github.sh"
    echo ""
    exit 1
fi

