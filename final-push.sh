#!/bin/bash
# Final push - using existing SSH key

cd "$(dirname "$0")"

echo "🚀 Final push setup..."
echo ""

# Verify SSH is working
echo "Verifying SSH..."
if ssh -T git@github.com 2>&1 | grep -q "Millionaireguardian"; then
    echo "✅ SSH authentication working with your existing key!"
else
    echo "⚠️  SSH test - continuing anyway"
fi

# Ensure git remote uses SSH
git remote set-url origin git@github.com:Millionaireguardian/polymarket-dashboard.git
echo "✅ Git remote configured for SSH"
echo ""

# Add and commit
git add .
if ! git diff --staged --quiet; then
    git commit -m "Update dashboard - $(date +%Y-%m-%d\ %H:%M:%S)"
    echo "✅ Committed changes"
fi

echo ""
echo "📋 IMPORTANT: Before pushing, allow the secret once:"
echo ""
echo "   👉 https://github.com/Millionaireguardian/polymarket-dashboard/security/secret-scanning/unblock-secret/37bTMnK3kyMeZxXGJXeBZQmfwO5"
echo ""
echo "   Click 'Allow secret' (one-time only)"
echo ""
read -p "Press Enter after you've allowed the secret on GitHub..."

echo ""
echo "Pushing to GitHub..."
if git push origin main; then
    echo ""
    echo "🎉 SUCCESS! Pushed to GitHub!"
    echo ""
    echo "🌐 Dashboard: https://Millionaireguardian.github.io/polymarket-dashboard/"
    echo ""
    echo "✅ Future pushes will work automatically (no more token issues)"
else
    echo ""
    echo "❌ Push failed. Did you allow the secret?"
    echo "   URL: https://github.com/Millionaireguardian/polymarket-dashboard/security/secret-scanning/unblock-secret/37bTMnK3kyMeZxXGJXeBZQmfwO5"
fi

