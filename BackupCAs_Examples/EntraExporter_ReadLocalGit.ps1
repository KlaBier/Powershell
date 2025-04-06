# This script is the counterpart to creating a dump into a local Git repository
# It reads from the Git repo and offers all available versions for import

# Init
$repoFolder = "C:\Git\Entra-Config"
$restoreTarget = "C:\Temp\RestoredEntraVersion"

# read all Commits
$commits = git log --oneline

if (-not $commits) {
    Write-Host "Nothing found. Canceled" -ForegroundColor Red
    exit
}

git worktree remove "$restoreTarget" --force

Write-Host "`n Available Commits:"
$commitList = $commits -split "`n" | ForEach-Object { $_.Trim() }

for ($i = 0; $i -lt $commitList.Count; $i++) {
    Write-Host "[$i] $($commitList[$i])"
}

# Get selection from user
[int]$selection = Read-Host "`n Please enter number of the Commit you wish to restore"
if ($selection -lt 0 -or $selection -ge $commitList.Count) {
    Write-Host "Invalid, canceled" -ForegroundColor Red
    exit
}

$selectedCommit = $commitList[$selection].Split(" ")[0]
Write-Host "`n Recovering Commit $selectedCommit..."

# create temporary Restore-Tree
git worktree add $restoreTarget $selectedCommit

Write-Host "`n Recovering done"
Write-Host "Files are stored at: $restoreTarget"
Write-Host "`n You can remove them later with the following command:"
Write-Host "   git worktree remove `"$restoreTarget`""

