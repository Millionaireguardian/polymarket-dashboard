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
echo "Now testing push..."
echo ""

# Test push
if bash push-github.sh; then
    echo ""
    echo "🎉 SUCCESS! Token is working and changes are pushed to GitHub!"
else
    echo ""
    echo "⚠️  Push failed. Check the error above."
fi

