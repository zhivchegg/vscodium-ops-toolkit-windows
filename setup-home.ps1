# Ensure MSYS2 home points to the Windows user profile.
# This makes Git and SSH use the same ~/.ssh and ~/.gitconfig files
# in the VSCodium terminal, Source Control, and standalone Git Bash.

$scriptDir = $PSScriptRoot
$sysHomeDir = Join-Path $scriptDir "msys64\home"
$userHome = Join-Path $sysHomeDir $env:USERNAME
$winProfile = $env:USERPROFILE

if (-not (Test-Path $sysHomeDir)) {
    New-Item -ItemType Directory -Path $sysHomeDir -Force | Out-Null
}

$isJunction = $false
if (Test-Path $userHome) {
    try {
        $item = Get-Item $userHome -ErrorAction Stop
        $isJunction = ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0
    } catch {}
}

if (-not (Test-Path $userHome)) {
    cmd /c "mklink /J `"$userHome`" `"$winProfile`"" | Out-Null
} elseif (-not $isJunction) {
    # Existing regular folder: back it up with a timestamp and replace with a junction.
    $timestamp = Get-Date -Format 'yyyyMMddHHmmss'
    $backup = "$userHome.backup-$timestamp"
    Move-Item -Path $userHome -Destination $backup -Force -ErrorAction SilentlyContinue
    cmd /c "mklink /J `"$userHome`" `"$winProfile`"" | Out-Null
}
