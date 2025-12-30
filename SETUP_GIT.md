# Setting Up Dashboard Git Repository

The dashboard needs to be in its own git repository for GitHub Pages deployment.

## Initial Setup (One-time)

Run these commands from the `polymarket-trading-bot` directory:

```bash
# Navigate to public directory
cd public

# Initialize git repository (if not already)
git init

# Add remote (replace with your actual repo URL)
git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/millionaireguardian/polymarket-dashboard.git

# Set branch to main
git branch -M main

# Add all files
git add .

# Make initial commit
git commit -m "Initial dashboard commit"

# Push to GitHub
git push -u origin main
```

## After Initial Setup

Once set up, you can deploy updates with:

```bash
npm run deploy-dashboard
```

## Troubleshooting

**Error: "remote origin already exists"**
- Remove existing remote: `cd public && git remote remove origin`
- Add correct remote: `git remote add origin https://github.com/millionaireguardian/polymarket-dashboard.git`

**Error: "not a git repository"**
- Initialize: `cd public && git init`

**Error: "fatal: no upstream branch"**
- Set upstream: `cd public && git push -u origin main`

