# The following script backs up all Conditional Access policies into a local Git repository
# and adds a timestamp to each commit.
#
# It demonstrates a simple way to create a versioned, local backup of Entra configuration
# data by storing EntraExporter output under Git version control.


# Local Git repository that stores the EntraExporter output
$repoFolder    = "C:\Git\Entra-Config"
$exportFolder  = "$repoFolder\exports\entra"
$commitMessage = "Automated Entra Config Export $(Get-Date -Format 'yyyy-MM-dd HH:mm')"

# If the folder is not yet a Git repository, initialize it
if (-not (Test-Path "$repoFolder\.git")) {
    Write-Host "Initializing local Git repository..."
    git init $repoFolder
}

# Work inside the Git repository
Set-Location $repoFolder

# Run EntraExporter and export Conditional Access policies
Write-Host "Starting EntraExporter..."
Connect-EntraExporter
Export-Entra -Path $exportFolder -Type ConditionalAccess
# Export-Entra -Path $exportFolder -All   # optional full export

# Stage all changes (new or modified files)
git add .

# Check if the export resulted in any changes
$changes = git status --porcelain

# If changes exist, create a commit with a timestamp
if ($changes) {
    Write-Host "Changes detected. Creating commit..."
    git commit -m "$commitMessage"

    # Optional: push to a remote repository
    # git push origin main
}
# If nothing changed, skip the commit
else {
    Write-Host "No changes detected - nothing to commit." -ForegroundColor Green
}