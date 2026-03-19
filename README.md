# Use Anthropic Models in OpenCode with Your Claude Pro/Max Subscription

Use Claude models in [OpenCode](https://opencode.ai) using your existing Claude Pro or Max subscription — no API key needed. This works by syncing the OAuth token from Claude Code (CLI) into OpenCode.

## Prerequisites

- **macOS** or **Linux**
- **[OpenCode](https://opencode.ai)** installed (desktop app or CLI)
- **[Claude Code](https://docs.anthropic.com/en/docs/claude-code)** (CLI) installed and logged in
- An active **Claude Pro or Max** subscription
- **python3** available in your PATH

## Setup

### 1. Make sure Claude Code is logged in

```bash
claude auth status
```

You should see something like:

```json
{
  "loggedIn": true,
  "authMethod": "claude.ai",
  "subscriptionType": "max"
}
```

If not logged in, run `claude` and follow the login flow.

### 2. Clone this repo

```bash
git clone https://github.com/9clg6/sync-claude-code-token-in-open-code.git
cd sync-claude-code-token-in-open-code
chmod +x sync-token.sh
```

### 3. Run the sync script

```bash
./sync-token.sh
```

Expected output:

```
Done! Anthropic token synced to OpenCode.
Expires: Fri Mar 20 05:22:36 CET 2026
```

### 4. Verify

```bash
# macOS desktop app:
/Applications/OpenCode.app/Contents/MacOS/opencode-cli providers list

# Or if installed via npm/homebrew:
opencode providers list
```

You should see:

```
●  Anthropic  oauth
└  1 credentials
```

### 5. Open OpenCode

Launch the OpenCode app. Anthropic models (Claude Sonnet, Opus, Haiku) should now appear in the model selector.

## Token Renewal

The OAuth token expires approximately every **6 hours**. When Anthropic models stop working in OpenCode:

1. Use Claude Code in your terminal (any command) — this automatically refreshes the token
2. Run the sync script again:

```bash
./sync-token.sh
```

3. Restart OpenCode

### Automate with cron (optional)

To automatically sync the token every 5 hours:

```bash
crontab -e
```

Add this line (replace the path with where you cloned the repo):

```
0 */5 * * * /path/to/sync-token.sh
```

> **Note:** The cron job syncs the token, but Claude Code must have been used recently enough for the token to still be valid. If both tokens expire, just open Claude Code once to trigger a refresh, then run the script.

## How It Works

The script auto-detects your OS:

- **macOS**: reads the OAuth token from the **macOS Keychain** (where Claude Code stores it under `Claude Code-credentials`)
- **Linux**: reads the token from **`~/.claude/.credentials.json`** (thanks [@minivolk](https://github.com/minivolk))

It then writes the token to `~/.local/share/opencode/auth.json` in the OAuth format that OpenCode expects:

```json
{
  "anthropic": {
    "type": "oauth",
    "access": "sk-ant-oat01-...",
    "refresh": "sk-ant-ort01-...",
    "expires": 1773980556114
  }
}
```

OpenCode recognizes Anthropic as an authenticated provider and exposes Claude models.

## Troubleshooting

**"No Claude Code credentials found in macOS Keychain"** (macOS)
- Make sure Claude Code is installed and you've logged in at least once
- Run `claude auth status` to check

**"~/.claude/.credentials.json not found"** (Linux)
- Make sure Claude Code is installed and you've logged in at least once
- Run `claude auth status` to check

**OpenCode doesn't show Anthropic models**
- Run `opencode providers list` to verify the credential is detected
- Make sure the token hasn't expired — re-run `./sync-token.sh`
- Restart OpenCode after syncing

**Token expires too quickly**
- The token lasts ~6 hours. Use the cron automation or re-run the script manually when needed

## OpenCode Desktop v1.2.27 Backup

Starting with OpenCode v1.3.0, Anthropic is no longer a built-in provider. A backup of v1.2.27 (the last version with Anthropic built-in) is available in the [Releases](https://github.com/9clg6/sync-claude-code-token-in-open-code/releases/tag/v1.2.27) section.
