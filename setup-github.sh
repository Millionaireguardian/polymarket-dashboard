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

# Check if token is provided as environment variable or in .bashrc
if [ -n "$GITHUB_TOKEN" ]; then
    GITHUB_TOKEN_INPUT="$GITHUB_TOKEN"
    echo "Using GITHUB_TOKEN from environment"
elif [ -f ~/.bashrc ] && grep -q "export GITHUB_TOKEN=" ~/.bashrc; then
    # Extract token from .bashrc
    GITHUB_TOKEN_INPUT=$(grep "export GITHUB_TOKEN=" ~/.bashrc | head -1 | sed 's/.*GITHUB_TOKEN=//' | tr -d '"' | tr -d "'")
    if [ -n "$GITHUB_TOKEN_INPUT" ]; then
        echo "Using GITHUB_TOKEN from ~/.bashrc"
        export GITHUB_TOKEN="$GITHUB_TOKEN_INPUT"
    fi
fi

# If still not set, use default token or prompt for it
if [ -z "$GITHUB_TOKEN_INPUT" ]; then
    # Default token (can be overridden)
    DEFAULT_TOKEN="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"
    
    echo "Using default GitHub token..."
    GITHUB_TOKEN_INPUT="$DEFAULT_TOKEN"
fi

if [ -z "$GITHUB_TOKEN_INPUT" ]; then
    echo "⚠️  No token provided. You can set it later with:"
    echo "   export GITHUB_TOKEN=your_token_here"
    echo "   Or run: bash update-token.sh"
else
    export GITHUB_TOKEN="$GITHUB_TOKEN_INPUT"
    
    # Add to .bashrc for persistence (WSL)
    if [ -f ~/.bashrc ]; then
        # Remove old token lines if exists
        sed -i '/^export GITHUB_TOKEN=ghp_/d' ~/.bashrc
        sed -i '/# GitHub Personal Access Token for polymarket-dashboard/d' ~/.bashrc
        
        # Add new token
        if ! grep -q "GITHUB_TOKEN=$GITHUB_TOKEN_INPUT" ~/.bashrc; then
            echo "" >> ~/.bashrc
            echo "# GitHub Personal Access Token for polymarket-dashboard" >> ~/.bashrc
            echo "export GITHUB_TOKEN=$GITHUB_TOKEN_INPUT" >> ~/.bashrc
            echo "✅ Token added to ~/.bashrc for persistence"
        else
            echo "✅ Token already in ~/.bashrc"
        fi
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

