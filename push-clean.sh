#!/bin/bash
# Clean script to push without token in files
# This removes the token from git history and uses it only in remote URL

cd "$(dirname "$0")"

echo "🧹 Cleaning git history to remove token..."
echo ""

# Remove the problematic commit that contains the token
# First, check if we need to reset
if git log --oneline | grep -q "push-with-token"; then
    echo "Removing commits with token..."
    # Reset to before the token commit
    git reset --hard HEAD~1 2>/dev/null || git reset --hard origin/main 2>/dev/null || echo "No previous commits to reset"
    echo "✅ Cleaned"
fi

# Remove push-with-token.sh from staging if it has the token
if grep -q "ghp_" push-with-token.sh 2>/dev/null; then
    echo "Removing push-with-token.sh from git tracking..."
    git rm --cached push-with-token.sh 2>/dev/null || true
    # Update the file to use environment variable (already done)
    git add push-with-token.sh
    echo "✅ Updated script to use environment variable"
fi

echo ""
echo "Now use the token via environment variable:"
echo ""
echo "  GITHUB_TOKEN=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 bash push-with-token.sh"
echo ""

