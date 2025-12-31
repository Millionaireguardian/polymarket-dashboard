# GitHub Setup Guide

This guide explains how to push dashboard updates to GitHub using your Personal Access Token.

## Quick Start

### 1. Initial Setup (Run Once)

```bash
cd polymarket-trading-bot/public
bash setup-github.sh
```

This will:
- Configure git with your GitHub username: **Millionaireguardian**
- Set your display name: **Nuke Rewards Dev**
- Store your GitHub token in `~/.bashrc` for persistence
- Configure the git remote

### 2. Push Updates

After setup, you can push updates easily:

**Option A: Using the convenient script**
```bash
cd polymarket-trading-bot/public
bash push-github.sh
```

**Option B: Using npm script**
```bash
cd polymarket-trading-bot
npm run push-github
```

**Option C: Using the existing scripts**
```bash
cd polymarket-trading-bot/public
bash push-dashboard.sh
# or
bash push-with-token.sh
```

## GitHub Configuration

- **Username**: Millionaireguardian
- **Display Name**: Nuke Rewards Dev
- **Repository**: https://github.com/Millionaireguardian/polymarket-dashboard
- **Dashboard URL**: https://Millionaireguardian.github.io/polymarket-dashboard/

## Token Storage

Your GitHub Personal Access Token is stored in:
- Environment variable: `GITHUB_TOKEN`
- Persistent storage: `~/.bashrc` (loaded automatically in new WSL sessions)

## Manual Token Usage

If you need to use the token manually:

```bash
# Token should be in ~/.bashrc after running setup-github.sh
source ~/.bashrc
bash push-with-token.sh

# Or set it manually:
export GITHUB_TOKEN=your_token_here
bash push-with-token.sh
```

## Troubleshooting

### Token not found
If you get "GITHUB_TOKEN not set", run:
```bash
bash setup-github.sh
source ~/.bashrc
```

### Push fails with "Permission denied" or wrong user
If you see errors like "Permission denied to imgprotocoldev" or other users, git is using cached credentials. Fix it:

```bash
# Clear git credential cache
bash clear-git-creds.sh

# Then try pushing again
bash push-github.sh
```

The updated `push-github.sh` script now:
- Automatically pulls remote changes before pushing
- Uses the token URL directly to bypass credential cache
- Handles merge conflicts gracefully

### Remote has changes (need to pull first)
The script now automatically handles this! It will:
1. Fetch remote changes
2. Detect if local is behind
3. Pull and merge automatically
4. Then push your changes

If you still get merge conflicts, resolve them manually:
```bash
git pull https://${GITHUB_TOKEN}@github.com/Millionaireguardian/polymarket-dashboard.git main
# Resolve conflicts, then:
git add .
git commit -m "Merge remote changes"
bash push-github.sh
```

### Push fails - other issues
1. Verify your token has `repo` permissions
2. Check token is valid at: https://github.com/settings/tokens
3. Ensure you're in the correct directory: `polymarket-trading-bot/public`
4. Clear credential cache: `bash clear-git-creds.sh`

### Git user not configured
Run:
```bash
git config user.name "Nuke Rewards Dev"
git config user.email "Millionaireguardian@users.noreply.github.com"
```

### Push blocked by GitHub Push Protection
If you see "Repository rule violations - Push cannot contain secrets":

**Quick Fix (Recommended):**
1. Visit the URLs provided in the error message to allow the secrets:
   - https://github.com/Millionaireguardian/polymarket-dashboard/security/secret-scanning/unblock-secret/37ZIjiHdfdRtviQ8in5EORlXQbd
   - https://github.com/Millionaireguardian/polymarket-dashboard/security/secret-scanning/unblock-secret/37bPzRFmfhyxQiZRnVMgZghNZ2g
2. Then push again: `bash push-github.sh`

**Why this happens:**
- Old commits in git history contain tokens
- Current files are clean, but GitHub scans all commits
- Allowing the secret tells GitHub you're aware and it's intentional

**Long-term fix:**
- Rewrite git history to remove tokens (complex, requires force push)
- Or create a fresh repository without the old commits

## Security Notes

- ✅ Token is stored in `~/.bashrc` (local to your WSL environment)
- ✅ Token is NOT hardcoded in any script files (current version)
- ✅ Token is only used via environment variable
- ⚠️  Keep your `~/.bashrc` file secure and don't share it
- ⚠️  Old commits may contain tokens - use GitHub's allow secret feature if needed

