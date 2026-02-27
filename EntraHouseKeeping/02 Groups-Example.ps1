# Einige Beispiele wie sich über die Microsoft Graph Gruppeninfos auslesen lassen
# 
# Die Cmdlets sind hier sind Beispiele und das Script ist nicht als ganzes lauffähig
# Zur Veranschaulichung die Cmdlets einzeln markieren und ausführen
#
# Für Ausgabe der Benutzer in Excel wird das Modul "ImportExcel" von Doug Finke benutzt  

# Installiere Powershell Module, wenn noch nicht geschehen
# Install-Module -name ImportExcel
# Install-Module -name microsoft.graph

# Login/Connect
# Import-Module Microsoft.Graph

# Excel File
$xlsFile = Join-Path (Get-Location) 'UnusedObjects.xlsx'

# Login/Connect to MS Graph
Connect-MgGraph -Scopes "Group.Read.All","Directory.Read.All","AuditLog.Read.All"

################################################################################
# Lese alle Gruppen, aber nur bestimmte Eigenschaften
$groups = Get-MgGroup -All -Property `
    Id,DisplayName,GroupTypes,CreatedDateTime,LastModifiedDateTime,MailEnabled,SecurityEnabled,IsAssignableToRole,AssignedLabels,MembershipRule

$result = foreach ($g in $groups) {

    # Owners
    $owners = Get-MgGroupOwner -GroupId $g.Id -All -ErrorAction SilentlyContinue
    $ownerCount = ($owners | Measure-Object).Count

    $enabledOwners = 0
    foreach ($o in $owners) {
        if ($o.AdditionalProperties.accountEnabled -eq $true) {
            $enabledOwners++
        }
    }

    # Members
    $memberCount = (Get-MgGroupMember -GroupId $g.Id -All -ErrorAction SilentlyContinue | Measure-Object).Count

    # Dynamic?
    $isDynamic = if ($g.GroupTypes -contains "DynamicMembership") { $true } else { $false }

    # Label
    $hasLabel = if ($g.AssignedLabels.Count -gt 0) { $true } else { $false }

    [PSCustomObject]@{
        DisplayName            = $g.DisplayName
        GroupId                = $g.Id
        Created                = $g.CreatedDateTime
        Owners                 = $ownerCount
        Members                = $memberCount
        Dynamic                = $isDynamic
        RoleAssignable         = $g.IsAssignableToRole
        HasSensitivityLabel    = $hasLabel
        MailEnabled            = $g.MailEnabled
        SecurityEnabled        = $g.SecurityEnabled
    }
}

$result | Export-Excel $xlsFile -WorksheetName "Groups" -ClearSheet -AutoSize

Disconnect-Graph
