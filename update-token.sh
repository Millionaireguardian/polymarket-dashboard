#!/bin/bash
# Update GitHub token permanently

cd "$(dirname "$0")"

# Get token from environment or prompt
if [ -z "$1" ]; then
    if [ -n "$GITHUB_TOKEN" ]; then
        NEW_TOKEN="$GITHUB_TOKEN"
    else
        echo "Please provide token: bash update-token.sh YOUR_TOKEN"
        echo "Or set: export GITHUB_TOKEN=your_token && bash update-token.sh"
        exit 1
    fi
else
    NEW_TOKEN="$1"
fi

echo "🔧 Updating GitHub Personal Access Token..."
echo ""

# Update ~/.bashrc
if [ -f ~/.bashrc ]; then
    # Remove old token lines
    sed -i '/^export GITHUB_TOKEN=ghp_/d' ~/.bashrc
    sed -i '/# GitHub Personal Access Token for polymarket-dashboard/d' ~/.bashrc
    
    # Add new token
    if ! grep -q "GITHUB_TOKEN=$NEW_TOKEN" ~/.bashrc; then
        echo "" >> ~/.bashrc
        echo "# GitHub Personal Access Token for polymarket-dashboard" >> ~/.bashrc
        echo "export GITHUB_TOKEN=$NEW_TOKEN" >> ~/.bashrc
        echo "✅ Token updated in ~/.bashrc"
    else
        echo "✅ Token already in ~/.bashrc"
    fi
else
    echo "⚠️  ~/.bashrc not found, creating it..."
    echo "" > ~/.bashrc
    echo "# GitHub Personal Access Token for polymarket-dashboard" >> ~/.bashrc
    echo "export GITHUB_TOKEN=$NEW_TOKEN" >> ~/.bashrc
    echo "✅ Created ~/.bashrc with token"
fi

# Export token for current session
export GITHUB_TOKEN="$NEW_TOKEN"

# Test the token
echo ""
echo "Testing new token..."
response=$(curl -s -H "Authorization: token $NEW_TOKEN" https://api.github.com/user)

if echo "$response" | grep -q '"login"'; then
    username=$(echo "$response" | grep '"login"' | head -1 | sed 's/.*"login": "\([^"]*\)".*/\1/')
    echo "✅ Token is VALID!"
    echo "   Authenticated as: $username"
    echo ""
    
    # Test repo access
    repo_response=$(curl -s -H "Authorization: token $NEW_TOKEN" \
        https://api.github.com/repos/Millionaireguardian/polymarket-dashboard)
    
    if echo "$repo_response" | grep -q '"name"'; then
        echo "✅ Repository access: OK"
    else
        echo "⚠️  Repository access: Checking permissions..."
    fi
else
    echo "❌ Token test failed"
    echo "Response: $response"
    exit 1
fi

# Reload bashrc
source ~/.bashrc 2>/dev/null || true

echo ""
echo "✅ Token updated permanently!"
echo ""
echo "📝 Next steps:"
echo "   1. Token is now in ~/.bashrc (will load automatically)"
echo "   2. Test push: bash push-github.sh"
echo ""

