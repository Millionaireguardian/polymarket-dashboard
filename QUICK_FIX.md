# Quick Fix for Deploy Errors

## Current Issue

You're getting errors because:
1. The parent directory (`polymarket-trading-bot`) has a git repository
2. The `public/` directory needs its own separate git repository for GitHub Pages

## Solution

Run these commands from the `polymarket-trading-bot` directory:

```bash
# Navigate to public directory
cd public

# Remove any existing git in public (if it exists)
rm -rf .git

# Initialize new git repository
git init

# Add remote (this will work even if it says "already exists" - just update it)
git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/millionaireguardian/polymarket-dashboard.git

# Set branch to main
git branch -M main

# Add all files
git add .

# Make initial commit
git commit -m "Initial dashboard commit"

# Push to GitHub (you may need to authenticate)
git push -u origin main
```

## After Setup

Once the above is done, you can deploy updates with:

```bash
npm run deploy-dashboard
```

## Alternative: Use the Fix Script

```bash
cd polymarket-trading-bot/public
bash fix-git-setup.sh
```

This script will:
- Check current git status
- Fix remote if needed
- Set branch to main
- Guide you through any issues

## Verify Setup

Check that everything is correct:

```bash
cd public
git remote -v
# Should show: origin  https://github.com/millionaireguardian/polymarket-dashboard.git

git branch
# Should show: * main
```

If both are correct, you're ready to deploy!

