#!/bin/bash
# Clear git credential cache to force using token

echo "🧹 Clearing git credential cache..."
echo ""

# Clear credential helper cache
git config --global --unset credential.helper 2>/dev/null || true
git credential-cache exit 2>/dev/null || true
git credential reject <<EOF
protocol=https
host=github.com
EOF

# Also clear from credential store if it exists
if [ -f ~/.git-credentials ]; then
    echo "⚠️  Found ~/.git-credentials file"
    echo "   You may want to manually edit it to remove old credentials"
fi

echo "✅ Git credential cache cleared"
echo ""
echo "💡 Now use the token via:"
echo "   export GITHUB_TOKEN=your_token_here"
echo "   bash push-github.sh"
echo ""
echo "   Or if token is in ~/.bashrc:"
echo "   source ~/.bashrc"
echo "   bash push-github.sh"
echo ""

