#!/bin/bash
# Verify SSH is working with existing key

cd "$(dirname "$0")"

echo "🔍 Verifying SSH setup..."
echo ""

# Check if SSH key exists
if [ -f ~/.ssh/id_ed25519 ] || [ -f ~/.ssh/id_rsa ]; then
    echo "✅ SSH key found"
    if [ -f ~/.ssh/id_ed25519.pub ]; then
        echo "   Key: ~/.ssh/id_ed25519"
        echo "   Public key:"
        cat ~/.ssh/id_ed25519.pub
    elif [ -f ~/.ssh/id_rsa.pub ]; then
        echo "   Key: ~/.ssh/id_rsa"
        echo "   Public key:"
        cat ~/.ssh/id_rsa.pub
    fi
else
    echo "❌ No SSH key found"
    exit 1
fi

echo ""
echo "Testing SSH connection to GitHub..."
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "✅ SSH authentication working!"
    echo ""
    echo "Your existing SSH key is working perfectly!"
else
    SSH_OUTPUT=$(ssh -T git@github.com 2>&1)
    if echo "$SSH_OUTPUT" | grep -q "Hi Millionaireguardian"; then
        echo "✅ SSH authentication working!"
        echo "   $SSH_OUTPUT"
    else
        echo "⚠️  SSH test output:"
        echo "$SSH_OUTPUT"
    fi
fi

echo ""
echo "Configuring git remote to use SSH..."
git remote set-url origin git@github.com:Millionaireguardian/polymarket-dashboard.git

echo ""
echo "Current remote URL:"
git remote get-url origin

echo ""
echo "✅ Setup complete! Your existing SSH key will work for this project."
echo ""
echo "You can now push with:"
echo "   bash push-github.sh"
echo "   or"
echo "   git push origin main"
echo ""

