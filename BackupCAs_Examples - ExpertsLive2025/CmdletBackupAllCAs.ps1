
# scripting example on how to make a CA-Policy Backup - very quick!
Write-Host 'Starting backup...'

# === Konfiguration ===
$baseFolder = "C:\CA-Backups"

# === Timestamp for Foldername
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$backupFolder = Join-Path -Path $baseFolder -ChildPath $timestamp

# === Create Folder
if (-not (Test-Path $backupFolder)) {
    New-Item -Path $backupFolder -ItemType Directory | Out-Null
}

Connect-MgGraph -NoWelcome

$AllPolicies = Get-MgIdentityConditionalAccessPolicy -All

foreach ($Policy in $AllPolicies) {
        # Get the display name of the policy
        $PolicyName = $Policy.DisplayName
    
        # Convert the policy object to JSON with a depth of 6
        $PolicyJSON = $Policy | ConvertTo-Json -Depth 10
    
        # Write the JSON to a file in the export path
        $PolicyJSON | Out-File "$BackupFolder\$PolicyName.json" -Force
    
        # Print a success message for the policy backup
        Write-Host "Successfully backed up CA policy: $($PolicyName)" -ForegroundColor Green
    }

Write-host "`nFiles stored in" $($BackupFolder) "`n" -ForegroundColor Green

