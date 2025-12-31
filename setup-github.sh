#!/bin/bash
# Setup GitHub configuration for the dashboard
# This configures git user info and sets up the token for easy pushing

cd "$(dirname "$0")"

echo "🔧 Setting up GitHub configuration..."
echo ""

# Configure git user
echo "Setting git user configuration..."
git config user.name "Nuke Rewards Dev"
git config user.email "Millionaireguardian@users.noreply.github.com"
echo "✅ Git user configured: Nuke Rewards Dev (Millionaireguardian)"
echo ""

# Set up the GitHub token
echo "Setting up GitHub Personal Access Token..."
export GITHUB_TOKEN="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"

# Add to .bashrc for persistence (WSL)
if [ -f ~/.bashrc ]; then
    if ! grep -q "GITHUB_TOKEN=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" ~/.bashrc; then
        echo "" >> ~/.bashrc
        echo "# GitHub Personal Access Token for polymarket-dashboard" >> ~/.bashrc
        echo "export GITHUB_TOKEN=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" >> ~/.bashrc
        echo "✅ Token added to ~/.bashrc for persistence"
    else
        echo "✅ Token already in ~/.bashrc"
    fi
fi

# Set up git remote
echo ""
echo "Configuring git remote..."
git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/Millionaireguardian/polymarket-dashboard.git
echo "✅ Remote configured: https://github.com/Millionaireguardian/polymarket-dashboard.git"
echo ""

echo "✅ GitHub setup complete!"
echo ""
echo "📝 You can now push updates using:"
echo "   bash push-dashboard.sh"
echo "   or"
echo "   bash push-with-token.sh"
echo ""
echo "💡 The token is now available in your environment and ~/.bashrc"
echo ""

