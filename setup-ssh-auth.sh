#!/bin/bash
# Setup SSH authentication for GitHub (permanent solution)

cd "$(dirname "$0")"

echo "🔐 Setting up SSH authentication for GitHub..."
echo ""

# Check if SSH key exists
if [ ! -f ~/.ssh/id_ed25519 ] && [ ! -f ~/.ssh/id_rsa ]; then
    echo "No SSH key found. Creating new one..."
    echo ""
    echo "Press Enter to use default location (~/.ssh/id_ed25519)"
    echo "Or specify a custom path"
    read -p "SSH key path [~/.ssh/id_ed25519]: " key_path
    key_path=${key_path:-~/.ssh/id_ed25519}
    
    # Get email for key
    read -p "Your GitHub email [Millionaireguardian@users.noreply.github.com]: " email
    email=${email:-Millionaireguardian@users.noreply.github.com}
    
    echo ""
    echo "Creating SSH key (press Enter when prompted for passphrase, or set one for security)..."
    ssh-keygen -t ed25519 -C "$email" -f "$key_path" -N ""
    
    if [ $? -eq 0 ]; then
        echo "✅ SSH key created!"
    else
        echo "❌ Failed to create SSH key"
        exit 1
    fi
else
    echo "✅ Using existing SSH key (already configured for GitHub)"
    if [ -f ~/.ssh/id_ed25519.pub ]; then
        key_path=~/.ssh/id_ed25519.pub
    else
        key_path=~/.ssh/id_rsa.pub
    fi
fi

# Test if key is already on GitHub
echo ""
echo "Testing if SSH key is already configured on GitHub..."
SSH_TEST=$(ssh -T git@github.com 2>&1)

if echo "$SSH_TEST" | grep -q "successfully authenticated" || echo "$SSH_TEST" | grep -q "Hi Millionaireguardian"; then
    echo "✅ Your existing SSH key is already working with GitHub!"
    echo "   No need to add it again - it's already configured."
    SKIP_KEY_ADD=true
else
    echo "⚠️  Key not yet added to GitHub or not working"
    SKIP_KEY_ADD=false
    
    # Display public key
    echo ""
    echo "📋 Your public SSH key:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat "${key_path%.*}.pub"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📝 If key is not on GitHub, add it:"
    echo "1. Copy the public key above"
    echo "2. Go to: https://github.com/settings/ssh/new"
    echo "3. Paste the key"
    echo "4. Give it a title: 'Polymarket Dashboard WSL'"
    echo "5. Click 'Add SSH key'"
    echo ""
    read -p "Press Enter to continue..."
fi

# Add to SSH agent
echo ""
echo "Adding key to SSH agent..."
eval "$(ssh-agent -s)" > /dev/null 2>&1
ssh-add "${key_path%.*}" 2>/dev/null || true

# Test SSH connection
echo ""
echo "Testing SSH connection to GitHub..."
SSH_TEST=$(ssh -T git@github.com 2>&1)
if echo "$SSH_TEST" | grep -q "successfully authenticated" || echo "$SSH_TEST" | grep -q "Hi Millionaireguardian"; then
    echo "✅ SSH authentication working!"
    echo "   $SSH_TEST"
else
    echo "⚠️  SSH test output:"
    echo "$SSH_TEST"
    echo ""
    echo "If authentication failed, make sure your SSH key is added to GitHub:"
    echo "   https://github.com/settings/ssh"
fi

# Configure git remote to use SSH
echo ""
echo "Configuring git remote to use SSH..."
git remote set-url origin git@github.com:Millionaireguardian/polymarket-dashboard.git

# Verify
echo ""
echo "Current remote URL:"
git remote get-url origin

echo ""
echo "✅ SSH setup complete!"
echo ""
echo "You can now push without tokens:"
echo "   git push origin main"
echo "   or"
echo "   bash push-github.sh"
echo ""

