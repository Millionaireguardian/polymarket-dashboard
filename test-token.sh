#!/bin/bash
# Test if GitHub token is valid

cd "$(dirname "$0")"

# Load token
if [ -z "$GITHUB_TOKEN" ]; then
    if [ -f ~/.bashrc ]; then
        source ~/.bashrc
    fi
fi

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ GITHUB_TOKEN not set"
    exit 1
fi

echo "Testing GitHub token..."
echo "Token: ${GITHUB_TOKEN:0:10}... (first 10 chars)"
echo ""

# Test token with GitHub API
response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user)

if echo "$response" | grep -q '"login"'; then
    username=$(echo "$response" | grep '"login"' | head -1 | sed 's/.*"login": "\([^"]*\)".*/\1/')
    echo "✅ Token is VALID!"
    echo "   Authenticated as: $username"
    echo ""
    
    # Test repo access
    repo_response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        https://api.github.com/repos/Millionaireguardian/polymarket-dashboard)
    
    if echo "$repo_response" | grep -q '"name"'; then
        echo "✅ Repository access: OK"
        echo "   Repository: Millionaireguardian/polymarket-dashboard"
    else
        echo "⚠️  Repository access: FAILED"
        echo "   Token might not have 'repo' permissions"
    fi
else
    echo "❌ Token is INVALID or EXPIRED"
    echo ""
    echo "Response: $response"
    echo ""
    echo "Please:"
    echo "1. Check token at: https://github.com/settings/tokens"
    echo "2. Verify token has 'repo' scope"
    echo "3. Create new token if needed"
    exit 1
fi

