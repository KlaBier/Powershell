# The following script is the counterpart to the CA backup script, which stores
# timestamp-based backups in a local Git repository.
#
# It demonstrates how to read from a locally versioned Git repository and restore
# a selected export into a separate folder. From there, individual Conditional Access
# policies can be imported via the Conditional Access dashboard.

# Configuration: Git repository and restore target
$repoFolder    = "C:\Git\Entra-Config"
$restoreTarget = "C:\Temp\RestoredEntraVersion"

# Switch to the local Git repository
Set-Location $repoFolder

# Read commit history and ensure it is always handled as an array
$commitText = (git log --oneline | Out-String).Trim()
if (-not $commitText) {
    Write-Host "Nothing found. Canceled" -ForegroundColor Red
    exit 1
}

$commitList = @(
    $commitText -split "`r?`n" |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ }
)

# Clean up any existing restore worktree
git worktree remove "$restoreTarget" --force 2>$null | Out-Null
if (Test-Path $restoreTarget) {
    Remove-Item -Recurse -Force $restoreTarget
}

# Display available commits and prompt for selection
Write-Host "`nAvailable commits:"
for ($i = 0; $i -lt $commitList.Count; $i++) {
    Write-Host "[$i] $($commitList[$i])"
}

[int]$selection = Read-Host "`nPlease enter number of the commit you wish to restore"
if ($selection -lt 0 -or $selection -ge $commitList.Count) {
    Write-Host "Invalid, canceled" -ForegroundColor Red
    exit 1
}

# Extract commit hash and restore selected version via Git worktree
$selectedCommit = ($commitList[$selection] -split '\s+')[0]
Write-Host "`nRestoring commit $selectedCommit..."

git worktree add "$restoreTarget" $selectedCommit
if ($LASTEXITCODE -ne 0) {
    Write-Host "Restore failed." -ForegroundColor Red
    exit 1
}

# Final output and cleanup hint
Write-Host "`nRestore done: $restoreTarget"
Write-Host "Remove later: git worktree remove `"$restoreTarget`""