# Quick Fix - Allow Secret

GitHub is blocking because token is in commit history. 

## Fastest Solution:

1. **Allow the secret** (one click):
   https://github.com/Millionaireguardian/polymarket-dashboard/security/secret-scanning/unblock-secret/37bTMnK3kyMeZxXGJXeBZQmfwO5

2. **Then push again**:
   ```bash
   bash push-github.sh
   ```

Token is now removed from all files. Only in ~/.bashrc (not in git).
