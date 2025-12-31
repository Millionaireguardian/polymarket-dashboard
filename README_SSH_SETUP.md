# Permanent GitHub Setup - SSH Authentication

## Why SSH Instead of Tokens?

✅ **No expiration** - SSH keys don't expire  
✅ **No secret scanning issues** - SSH keys aren't detected as secrets  
✅ **More secure** - Standard authentication method  
✅ **One-time setup** - Works forever  

## Quick Setup (5 minutes)

### Step 1: Run Setup Script
```bash
cd ~/Polymarket/polymarket-trading-bot/public
bash setup-ssh-auth.sh
```

This will:
- Create an SSH key (if you don't have one)
- Show your public key
- Guide you to add it to GitHub

### Step 2: Add Key to GitHub
1. Copy the public key shown by the script
2. Go to: https://github.com/settings/ssh/new
3. Paste the key
4. Title: "Polymarket Dashboard WSL"
5. Click "Add SSH key"

### Step 3: Test Push
```bash
bash push-github.sh
# or
npm run push-github
```

## That's It!

Now you can push anytime without tokens:
- `bash push-github.sh` - Auto-detects SSH
- `git push origin main` - Works directly
- No tokens needed ever again!

## Troubleshooting

**SSH key not working?**
```bash
# Test connection
ssh -T git@github.com

# Should see: "Hi Millionaireguardian! You've successfully authenticated..."
```

**Need to regenerate key?**
```bash
bash setup-ssh-auth.sh
```

