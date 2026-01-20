# The following script backs up all Conditional Access Policies into a local Git repository
# and adds a timestamp to the commit message.
#
# It demonstrates how to quickly and simply create a versioned backup of file contents,
# in this case the dump from EntraExporter, stored locally as a backup.

# Initialise
$repoFolder     = "C:\Git\Entra-Config"
$exportFolder   = "$repoFolder\exports\entra"
$commitMessage  = "Automated Entra Config Export $(Get-Date -Format 'yyyy-MM-dd HH:mm')"

# If not already done
Install-Moadule EntraExporter

# === Ensure that the Git repository is initialized ===
if (-not (Test-Path "$repoFolder\.git")) {
    Write-Host "Initialize Git-Repository..."
    git init $repoFolder
} else {
    Write-Host "Git-Repository exists..."
}

# Switch to local Git Folder
Set-Location $repoFolder

# EntraExporter Stuff
Write-Host "Starting EntraExporter..."
Connect-EntraExporter
Export-Entra -Path "$exportFolder" -Type ConditionalAccess

# Alternative option to back up all settings, not just Conditional Access policies
#Export-Entra -Path $exportFolder -All

# Check Git Changes
Write-Host "Check for changes in the Git repository..."
git add .

$changes = git status --porcelain
if ($changes) {
    Write-Host "Modifications detected. Performing commit..."
    git commit -m "$commitMessage"

    # Optional: Push (for Remote)
    # git push origin main
} else {
    Write-Host "No changes - export skipped" -ForegroundColor green
}



$scopes = @(
    "Directory.Read.All",
    "Policy.Read.All",
    "AuditLog.Read.All",
    "PrivilegedEligibilitySchedule.Read.AzureADGroup",
    "PrivilegedAccess.Read.AzureADGroup",
    "RoleManagementPolicy.Read.AzureADGroup"
)

Connect-MgGraph -Scopes $scopes
Select-MgProfile -Name beta   # falls du sowieso mit beta arbeitest

export-entra -path C:\fullbackupV3 -type PIMResources, PIMGroups