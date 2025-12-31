# GitHub Token Setup - Permanent Configuration

## Current Token
**Token**: `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`

This token is now configured permanently in:
- `~/.bashrc` (loaded automatically)
- `setup-github.sh` (default token)
- `push-github.sh` (fallback token)

## Quick Update

To update the token in the future:

```bash
cd ~/Polymarket/polymarket-trading-bot/public
bash update-token.sh
```

Or manually edit `~/.bashrc`:
```bash
nano ~/.bashrc
# Find: export GITHUB_TOKEN=...
# Replace with: export GITHUB_TOKEN=your_new_token
source ~/.bashrc
```

## Verification

Test the token:
```bash
bash test-token.sh
```

## Token Permissions Required

- ✅ `repo` - Full control of private repositories
- ✅ `workflow` - Update GitHub Action workflows (optional)

## Security Notes

- Token is stored in `~/.bashrc` (local to your WSL environment)
- Token is NOT committed to git repository
- Token is used via environment variable only
- Keep `~/.bashrc` secure and don't share it

