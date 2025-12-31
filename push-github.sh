#!/bin/bash
# Convenient script to push dashboard updates to GitHub
# Uses the configured GitHub token from environment

cd "$(dirname "$0")"

# Load token from .bashrc if not already set
if [ -z "$GITHUB_TOKEN" ]; then
    if [ -f ~/.bashrc ]; then
        # Extract token directly from bashrc (more reliable than sourcing)
        TOKEN_LINE=$(grep "^export GITHUB_TOKEN=" ~/.bashrc | head -1)
        if [ -n "$TOKEN_LINE" ]; then
            # Extract token value (handles quotes and spaces)
            GITHUB_TOKEN=$(echo "$TOKEN_LINE" | sed 's/^export GITHUB_TOKEN=//' | sed 's/^["'\'']//' | sed 's/["'\'']$//' | xargs)
            export GITHUB_TOKEN
        fi
    fi
fi

# If still not set, use default token
if [ -z "$GITHUB_TOKEN" ]; then
    # Default token (fallback)
    DEFAULT_TOKEN="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"
    export GITHUB_TOKEN="$DEFAULT_TOKEN"
    echo "⚠️  Using default token. Run 'bash update-token.sh' to update permanently."
fi

# Debug: Show token status (first 10 chars only)
if [ -n "$GITHUB_TOKEN" ]; then
    echo "Using token: ${GITHUB_TOKEN:0:10}..."
else
    echo "⚠️  No token found!"
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

# Test token first
echo "Verifying token..."
TOKEN_TEST=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user)
if echo "$TOKEN_TEST" | grep -q '"login"'; then
    username=$(echo "$TOKEN_TEST" | grep '"login"' | head -1 | sed 's/.*"login": "\([^"]*\)".*/\1/')
    echo "✅ Token verified (authenticated as: $username)"
else
    echo "❌ Token verification failed!"
    echo "Response: $TOKEN_TEST"
    echo ""
    echo "Trying to reload token from ~/.bashrc..."
    if [ -f ~/.bashrc ]; then
        source ~/.bashrc
        # Try again
        TOKEN_TEST=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user)
        if echo "$TOKEN_TEST" | grep -q '"login"'; then
            echo "✅ Token verified after reload"
        else
            echo "❌ Token is still invalid!"
            echo "Please run: bash update-token.sh"
            exit 1
        fi
    else
        echo "Please run: bash update-token.sh"
        exit 1
    fi
fi

# Use git credential helper to store token temporarily
echo "https://${GITHUB_TOKEN}@github.com" > /tmp/git-credentials-$$
git config --global credential.helper "store --file=/tmp/git-credentials-$$"

# Set remote URL
git remote set-url origin https://github.com/Millionaireguardian/polymarket-dashboard.git

# REMOTE_URL already defined above with token - using it here
# This ensures we use the token, not cached credentials for imgprotocoldev

if git push "$REMOTE_URL" main 2>&1; then
    # Clean up
    rm -f /tmp/git-credentials-$$
    git config --global --unset credential.helper
    echo ""
    echo "✅ Successfully pushed to GitHub!"
    echo ""
    echo "🌐 Dashboard available at:"
    echo "   https://Millionaireguardian.github.io/polymarket-dashboard/"
    echo ""
    exit 0
else
    # Clean up
    rm -f /tmp/git-credentials-$$
    git config --global --unset credential.helper
    
    echo ""
    echo "❌ Push failed. Please check:"
    echo "   1. Your GitHub token is valid and has 'repo' permissions"
    echo "   2. Token: ${GITHUB_TOKEN:0:10}... (first 10 chars)"
    echo "   3. Test token: bash test-token.sh"
    echo "   4. Create new token: https://github.com/settings/tokens/new"
    echo ""
    exit 1
fi

