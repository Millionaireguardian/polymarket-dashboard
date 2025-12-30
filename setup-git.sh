#!/bin/bash
# Setup script for dashboard git repository
# Run this once to initialize the public/ directory as a git repo

echo "Setting up dashboard git repository..."

# Navigate to public directory
cd "$(dirname "$0")"

# Remove existing git if any
if [ -d .git ]; then
    echo "Removing existing .git directory..."
    rm -rf .git
fi

# Initialize git
echo "Initializing git repository..."
git init

# Add remote
echo "Adding remote origin..."
git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/millionaireguardian/polymarket-dashboard.git

# Set branch to main
echo "Setting branch to main..."
git branch -M main

# Add all files
echo "Adding files..."
git add .

# Make initial commit
echo "Making initial commit..."
git commit -m "Initial dashboard commit" || echo "No changes to commit"

# Push to GitHub
echo "Pushing to GitHub..."
echo "You may need to authenticate..."
git push -u origin main

echo ""
echo "✅ Setup complete!"
echo "You can now use 'npm run deploy-dashboard' to deploy updates."
echo ""

