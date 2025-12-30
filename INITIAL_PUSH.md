# Initial Push to GitHub - Step by Step

Since your GitHub repository is empty, you need to push all the dashboard files for the first time.

## Quick Solution

Run this command from the `polymarket-trading-bot` directory:

```bash
cd public
bash push-initial.sh
```

## Manual Steps (if script doesn't work)

### 1. Fix Git Ownership (if needed)

If you see "dubious ownership" error:

```bash
cd polymarket-trading-bot/public
git config --global --add safe.directory '%(prefix)///wsl.localhost/Ubuntu-20.04/home/van/Polymarket/polymarket-trading-bot/public'
```

### 2. Set Correct Remote URL

```bash
cd polymarket-trading-bot/public

# Remove old remote (if exists)
git remote remove origin 2>/dev/null || true

# Add correct GitHub remote
git remote add origin https://github.com/Millionaireguardian/polymarket-dashboard.git

# Verify
git remote -v
```

Should show:
```
origin  https://github.com/Millionaireguardian/polymarket-dashboard.git (fetch)
origin  https://github.com/Millionaireguardian/polymarket-dashboard.git (push)
```

### 3. Ensure All Files Are Present

```bash
# Make sure .nojekyll exists
touch .nojekyll

# Make sure data/trades.json exists
mkdir -p data
echo "[]" > data/trades.json
```

### 4. Add, Commit, and Push

```bash
# Add all files
git add .

# Commit
git commit -m "Initial dashboard commit - Polymarket Arbitrage Bot Tracker"

# Push to GitHub
git push -u origin main
```

### 5. Enable GitHub Pages

After pushing:

1. Go to: https://github.com/Millionaireguardian/polymarket-dashboard/settings/pages
2. Under "Source":
   - Select: **Deploy from a branch**
   - Branch: **main**
   - Folder: **/ (root)**
3. Click **Save**
4. Wait 2-3 minutes for GitHub Pages to build

Your dashboard will be live at:
**https://Millionaireguardian.github.io/polymarket-dashboard/**

## Troubleshooting

### "Repository not found"
- Make sure the repository exists at: https://github.com/Millionaireguardian/polymarket-dashboard
- Check that you have push access
- Verify the repository name is exactly: `polymarket-dashboard`

### "Permission denied" or "Authentication failed"
- Use GitHub CLI: `gh auth login`
- Or use a Personal Access Token:
  ```bash
  git push https://<YOUR_TOKEN>@github.com/Millionaireguardian/polymarket-dashboard.git main
  ```
- Get token from: https://github.com/settings/tokens

### "fatal: no upstream branch"
- Make sure you're on main branch: `git branch -M main`
- Then push: `git push -u origin main`

### Remote shows internal IP (140.82.121.4)
- This is normal if you're behind a proxy
- The script will update it to github.com
- Or manually: `git remote set-url origin https://github.com/Millionaireguardian/polymarket-dashboard.git`

