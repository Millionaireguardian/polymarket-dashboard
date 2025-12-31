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
export GITHUB_TOKEN=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
bash push-with-token.sh
```

## Troubleshooting

### Token not found
If you get "GITHUB_TOKEN not set", run:
```bash
bash setup-github.sh
source ~/.bashrc
```

### Push fails
1. Verify your token has `repo` permissions
2. Check token is valid at: https://github.com/settings/tokens
3. Ensure you're in the correct directory: `polymarket-trading-bot/public`

### Git user not configured
Run:
```bash
git config user.name "Nuke Rewards Dev"
git config user.email "Millionaireguardian@users.noreply.github.com"
```

## Security Notes

- ✅ Token is stored in `~/.bashrc` (local to your WSL environment)
- ✅ Token is NOT hardcoded in any script files
- ✅ Token is only used via environment variable
- ⚠️  Keep your `~/.bashrc` file secure and don't share it

