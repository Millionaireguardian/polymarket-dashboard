#!/bin/bash
# Script to help remove tokens from git history
# This creates a new commit that removes tokens from tracked files

cd "$(dirname "$0")"

echo "🧹 Removing tokens from current files..."
echo ""

# Files that should not contain tokens
FILES_TO_CHECK=(
    "setup-github.sh"
    "clear-git-creds.sh"
    "GITHUB_SETUP.md"
    "push-clean.sh"
    "fix-token-issue.sh"
)

HAS_TOKENS=false

for file in "${FILES_TO_CHECK[@]}"; do
    if [ -f "$file" ] && grep -q "ghp_" "$file" 2>/dev/null; then
        echo "⚠️  Found token in $file"
        HAS_TOKENS=true
    fi
done

if [ "$HAS_TOKENS" = true ]; then
    echo ""
    echo "❌ Tokens still found in files. Please remove them manually."
    echo "   Search for 'ghp_' in the files above and replace with placeholders."
    exit 1
else
    echo "✅ No tokens found in tracked files"
    echo ""
    echo "💡 Note: Tokens in git history need to be removed separately."
    echo "   The current files are clean, but old commits may still contain tokens."
    echo "   You may need to use git filter-branch or BFG Repo-Cleaner to clean history."
fi

