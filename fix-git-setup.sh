#!/bin/bash
# Fix script for dashboard git repository setup
# Use this if you're having issues with the deploy script

echo "🔧 Fixing dashboard git repository setup..."
echo ""

# Navigate to public directory
cd "$(dirname "$0")"

# Check current status
echo "Current directory: $(pwd)"
echo ""

if [ -d .git ]; then
    echo "📁 Git repository found"
    echo "Current remote:"
    git remote -v 2>/dev/null || echo "  No remote configured"
    echo ""
    
    # Remove existing remote if wrong
    if git remote get-url origin >/dev/null 2>&1; then
        CURRENT_REMOTE=$(git remote get-url origin)
        EXPECTED_REMOTE="https://github.com/millionaireguardian/polymarket-dashboard.git"
        
        if [ "$CURRENT_REMOTE" != "$EXPECTED_REMOTE" ]; then
            echo "⚠️  Remote mismatch detected"
            echo "   Current: $CURRENT_REMOTE"
            echo "   Expected: $EXPECTED_REMOTE"
            echo ""
            read -p "Update remote? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                git remote remove origin
                git remote add origin "$EXPECTED_REMOTE"
                echo "✅ Remote updated"
            fi
        else
            echo "✅ Remote is correct"
        fi
    else
        echo "➕ Adding remote origin..."
        git remote add origin https://github.com/millionaireguardian/polymarket-dashboard.git
        echo "✅ Remote added"
    fi
    
    # Check branch
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "none")
    echo "Current branch: $CURRENT_BRANCH"
    
    if [ "$CURRENT_BRANCH" != "main" ]; then
        echo "🌿 Setting branch to main..."
        git branch -M main 2>/dev/null || git checkout -b main
        echo "✅ Branch set to main"
    fi
    
    echo ""
    echo "✅ Git repository is properly configured!"
    echo ""
    echo "Test deployment with:"
    echo "  npm run deploy-dashboard"
    echo ""
    
else
    echo "❌ No git repository found in public/ directory"
    echo ""
    echo "Run the setup script first:"
    echo "  npm run setup-dashboard-git"
    echo ""
    echo "Or manually:"
    echo "  cd public"
    echo "  git init"
    echo "  git remote add origin https://github.com/millionaireguardian/polymarket-dashboard.git"
    echo "  git branch -M main"
    echo "  git add ."
    echo "  git commit -m 'Initial dashboard commit'"
    echo "  git push -u origin main"
    echo ""
fi

