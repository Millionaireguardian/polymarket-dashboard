#!/bin/bash
# Resolve merge conflicts, especially for data/trades.json

cd "$(dirname "$0")"

echo "🔧 Resolving merge conflicts..."
echo ""

# Check if we're in a merge state
if [ ! -f .git/MERGE_HEAD ]; then
    echo "ℹ️  No merge in progress. Nothing to resolve."
    exit 0
fi

# Check for conflicts
if ! git diff --check > /dev/null 2>&1; then
    echo "⚠️  Merge conflicts detected"
    echo ""
    
    # Handle data/trades.json conflict specifically
    if [ -f data/trades.json ] && grep -q "^<<<<<<< " data/trades.json 2>/dev/null; then
        echo "Resolving conflict in data/trades.json..."
        echo "   Strategy: Taking local version (your current trades)"
        
        # Use local version (--ours) for trades.json
        git checkout --ours data/trades.json 2>/dev/null || {
            # If that fails, manually remove conflict markers
            echo "   Removing conflict markers manually..."
            # Remove conflict markers, keeping content between <<<<<<< and =======
            sed -i '/^<<<<<<< /,/^=======/d' data/trades.json
            sed -i '/^>>>>>>> /d' data/trades.json
            # Clean up any duplicate empty lines
            sed -i '/^$/N;/^\n$/d' data/trades.json
        }
        
        # Ensure valid JSON
        if command -v python3 >/dev/null 2>&1; then
            if ! python3 -m json.tool data/trades.json > /dev/null 2>&1; then
                echo "⚠️  JSON invalid after conflict resolution. Using empty array..."
                echo "[]" > data/trades.json
            fi
        fi
        
        echo "✅ Resolved data/trades.json conflict"
    fi
    
    # Add resolved files
    git add data/trades.json 2>/dev/null || true
    
    # Check for other conflicts
    CONFLICTS=$(git diff --name-only --diff-filter=U)
    if [ -n "$CONFLICTS" ]; then
        echo ""
        echo "⚠️  Other conflicts found:"
        echo "$CONFLICTS"
        echo ""
        echo "Resolving by taking local version for other files..."
        for file in $CONFLICTS; do
            if [ "$file" != "data/trades.json" ]; then
                # For other files, take local version
                git checkout --ours "$file" 2>/dev/null || true
                git add "$file" 2>/dev/null || true
            fi
        done
    fi
    
    # Complete the merge
    if git commit --no-edit; then
        echo ""
        echo "✅ Merge conflicts resolved and committed!"
        echo ""
    else
        echo ""
        echo "⚠️  Could not auto-commit. You may need to:"
        echo "   git add ."
        echo "   git commit -m 'Merge remote changes'"
        echo ""
    fi
else
    echo "✅ No conflicts found"
fi

