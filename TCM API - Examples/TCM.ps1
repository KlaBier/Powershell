
Connect-Graph

import-module C:\TCM-Utility\

#region 1. Check and set permissions 
# App ID: 03b07b79-c5bc-4b5e-9bfa-13acf4a99998
$result = Test-TCMConfigurationTemplate -ResourceNames @(
            'microsoft.entra.conditionalaccesspolicy', 
            'microsoft.entra.grouplifecyclepolicy')

$result = Test-TCMConfigurationTemplate -ResourceNames @(
            'microsoft.entra.conditionalaccesspolicy')

Add-TCMServicePrincipalPermissions -Permissions $result.Read.Permissions
#endregion

#region 2. Create new snapshot 
$uri = "https://graph.microsoft.com/beta/admin/configurationManagement/configurationSnapshots/createSnapshot"
$body = @"
{
"displayName": "Snapshot Blog Post CA Only", 
    "description": "Snapshot Description", 
    "resources": 
    [
            "microsoft.entra.conditionalaccesspolicy"
    ] 
}
"@

$NewSnapShot = Invoke-MgGraphRequest -Uri $uri -Method Post -Body $body
$NewSnapshot
#endregion

#region 3.Snapshot Job holen (ID) 
$uri = "https://graph.microsoft.com/beta/admin/configurationManagement/configurationSnapshotJobs('bd7609e6-1052-4fa0-9beb-bd52c33889dc')"
$job = Invoke-MgGraphRequest -Uri $uri -Method GET

$snapshotUri = $job.resourceLocation
$snapshot = Invoke-MgGraphRequest -Uri $snapshotUri -Method GET
$snapshot

# Zeigen ob Snapshot fertig
$job.status

# JSON mit Snaphot holen
$snapshot | ConvertTo-Json -Depth 10
#endregion

#region 4. Verschiedenes
# 2. Infos from specific snapshot #######################################################
$uri= "https://graph.microsoft.com/beta/admin/configurationManagement/configurationMonitors('761c398a-edee-4c0f-bd25-65d5511480d9')"

Invoke-MgGraphRequest -Uri $uri -Method GET



# Show all snapshots only ##########################################################
$uri = "https://graph.microsoft.com/beta/admin/configurationManagement/configurationSnapshotJobs"
$jobs = Invoke-MgGraphRequest -Uri $uri -Method GET

$jobs.value | ForEach-Object {
    $snapshot = Invoke-MgGraphRequest -Uri $_.resourceLocation
    [PSCustomObject]@{
        DisplayName       = $snapshot.displayName
        Description       = $snapshot.description
        Status            = $snapshot.status
        CreatedDateTime   = $snapshot.createdDateTime
        CompletedDateTime = $snapshot.completedDateTime
        Id                = $snapshot.id
        Resources         = $snapshot.resources
    }
    $_.resourceLocation
}


$uri= "https://graph.microsoft.com/beta/admin/configurationManagement/configurationSnapshots"

Invoke-MgGraphRequest -Uri $uri

#region List all JSON Content from Snapshot e.g. CA Policies
$uri = "https://graph.microsoft.com/beta/admin/configurationManagement/configurationSnapshots('84475ce7-a950-40c3-8f62-1f1e6faea5c5')"
$Result = Invoke-MgGraphRequest -Uri $uri -Method GET
#endregion

#region Get information from a former created shanshot
$uri = "https://graph.microsoft.com/beta/admin/configurationManagement/configurationSnapshotJobs('84475ce7-a950-40c3-8f62-1f1e6faea5c5')"
$Result = Invoke-MgGraphRequest -Uri $uri -Method GET
#endregion




$body = @{
    displayName = "Monitor CA Policies"
    description = "Monitor for CA Policy drift"
    baseline = @{
        displayName = "Baseline CA Policies"
        description = "Baseline for CA Policy monitoring"
        parameters = @()
        resources = @(
            @{
                displayName = "TestPolicy"
                resourceType = "microsoft.entra.conditionalaccesspolicy"
                properties = @{
                    Ensure = "Present"
                    DisplayName = "CA003-Global-BaseProtection-AllApps-AnyPlatform-MFA"
                    State = "enabled"
                }
            }
        )
    }
} | ConvertTo-Json -Depth 10

$uri = "https://graph.microsoft.com/beta/admin/configurationManagement/configurationMonitors"
Invoke-MgGraphRequest -Uri $uri -Method POST -Body $body -ContentType "application/json"
#endregion
