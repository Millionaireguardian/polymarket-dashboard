#!/bin/bash
# One-time script to apply the new GitHub token permanently

cd "$(dirname "$0")"

echo "🔧 Applying new GitHub token permanently..."
echo ""

# Run the update script
bash update-token.sh

echo ""
echo "✅ Token updated!"
echo ""

# Extract token from bashrc (more reliable than sourcing)
if [ -f ~/.bashrc ]; then
    TOKEN_LINE=$(grep "^export GITHUB_TOKEN=" ~/.bashrc | head -1)
    if [ -n "$TOKEN_LINE" ]; then
        # Extract token value (handles quotes and spaces)
        GITHUB_TOKEN=$(echo "$TOKEN_LINE" | sed 's/^export GITHUB_TOKEN=//' | sed 's/^["'\'']//' | sed 's/["'\'']$//' | xargs)
        export GITHUB_TOKEN
    fi
fi

if [ -n "$GITHUB_TOKEN" ]; then
    echo "Token loaded: ${GITHUB_TOKEN:0:10}..."
else
    echo "⚠️  Token not found in ~/.bashrc"
    exit 1
fi
echo ""
echo "Now testing push..."
echo ""

# Test push (pass token explicitly)
if GITHUB_TOKEN="$GITHUB_TOKEN" bash push-github.sh; then
    echo ""
    echo "🎉 SUCCESS! Token is working and changes are pushed to GitHub!"
else
    echo ""
    echo "⚠️  Push failed. Check the error above."
fi

