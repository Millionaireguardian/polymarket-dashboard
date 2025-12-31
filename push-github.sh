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
            if git pull "$REMOTE_URL" main --no-edit 2>/dev/null; then
                echo "✅ Successfully pulled and merged remote changes"
            else
                echo "⚠️  Merge conflict or pull failed. Attempting with allow-unrelated-histories..."
                # Try with allow-unrelated-histories for unrelated histories
                if git pull "$REMOTE_URL" main --allow-unrelated-histories --no-edit; then
                    echo "✅ Successfully merged unrelated histories"
                else
                    echo "⚠️  Still failed. Attempting with no-edit flag..."
                    git pull "$REMOTE_URL" main --allow-unrelated-histories --no-rebase || {
                        echo "❌ Could not automatically merge. Please resolve conflicts manually."
                        echo "   You can try: git pull $REMOTE_URL main --allow-unrelated-histories"
                        exit 1
                    }
                fi
            fi
        else
            echo "⚠️  Local and remote have diverged. Attempting to merge..."
            # Configure git to use merge strategy
            git config pull.rebase false 2>/dev/null || true
            
            # Try normal merge first
            if git pull "$REMOTE_URL" main --no-rebase --no-edit --allow-unrelated-histories 2>/dev/null; then
                echo "✅ Successfully merged remote changes"
            else
                # Check if we have conflicts
                if [ -f .git/MERGE_HEAD ]; then
                    echo "⚠️  Merge conflicts detected. Attempting to resolve..."
                    # Try to resolve conflicts automatically
                    if bash resolve-conflict.sh 2>/dev/null; then
                        echo "✅ Conflicts resolved automatically"
                    else
                        echo "❌ Could not automatically resolve conflicts."
                        echo ""
                        echo "💡 Run this to resolve conflicts:"
                        echo "   bash resolve-conflict.sh"
                        echo ""
                        echo "Or manually resolve conflicts in:"
                        git diff --name-only --diff-filter=U
                        echo ""
                        echo "Then: git add . && git commit"
                        exit 1
                    fi
                else
                    echo "❌ Could not merge. Please check the error above."
                    exit 1
                fi
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

# Configure git to not prompt for credentials
export GIT_TERMINAL_PROMPT=0
git config --global credential.helper store

# REMOTE_URL already defined above with token - using it here
# This ensures we use the token, not cached credentials for imgprotocoldev

if git push "$REMOTE_URL" main 2>&1; then
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

