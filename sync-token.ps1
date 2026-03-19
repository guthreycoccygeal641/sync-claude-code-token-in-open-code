# Sync Claude Code OAuth token to OpenCode (Windows)
# Reads token from %USERPROFILE%\.claude\.credentials.json

$ErrorActionPreference = "Stop"

# Read credentials
$credFile = Join-Path $env:USERPROFILE ".claude\.credentials.json"
if (-not (Test-Path $credFile)) {
    Write-Error "$credFile not found. Make sure Claude Code is installed and you are logged in (run: claude auth status)"
    exit 1
}

$creds = Get-Content $credFile -Raw | ConvertFrom-Json
$access = $creds.claudeAiOauth.accessToken
$refresh = $creds.claudeAiOauth.refreshToken
$expires = $creds.claudeAiOauth.expiresAt

if (-not $access -or -not $refresh) {
    Write-Error "Could not extract tokens from credentials."
    exit 1
}

# Write to OpenCode auth.json
$authDir = if ($env:XDG_DATA_HOME) {
    Join-Path $env:XDG_DATA_HOME "opencode"
} else {
    Join-Path $env:LOCALAPPDATA "opencode"
}

if (-not (Test-Path $authDir)) {
    New-Item -ItemType Directory -Path $authDir -Force | Out-Null
}

$authFile = Join-Path $authDir "auth.json"

# Merge with existing auth.json to preserve other providers
$auth = @{}
if (Test-Path $authFile) {
    try {
        $auth = Get-Content $authFile -Raw | ConvertFrom-Json -AsHashtable
    } catch {
        $auth = @{}
    }
}

$auth["anthropic"] = @{
    type    = "oauth"
    access  = $access
    refresh = $refresh
    expires = [long]$expires
}

$auth | ConvertTo-Json -Depth 10 | Set-Content $authFile -Encoding UTF8

$expiresDate = (Get-Date "1970-01-01").AddMilliseconds([long]$expires).ToLocalTime()
Write-Host "Done! Anthropic token synced to OpenCode."
Write-Host "Expires: $expiresDate"
