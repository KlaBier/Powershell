
# ... gleiche Liste, aber Ausgabe diesmal direkt in eine Excel Tabelle mit dem Excel Powershell Module von Doug Finke
#Install-Module -Name ImportExcel


Connect-MgGraph

# Alle Benutzer, Gruppen und Rollenvorlagen abrufen
$allUsers = Get-MgUser -All
$allGroups = Get-MgGroup -All
$allRoleTemplates = Get-MgDirectoryRoleTemplate -All

# Hash-Maps erstellen
$userMap = @{}
$allUsers | ForEach-Object { $userMap[$_.Id] = $_.DisplayName }

$groupMap = @{}
$allGroups | ForEach-Object { $groupMap[$_.Id] = "[Gruppe] $($_.DisplayName)" }

$roleMap = @{}
$allRoleTemplates | ForEach-Object {
    if ($_.Id -and $_.DisplayName) {
        $roleMap[$_.Id] = "[Rolle] $($_.DisplayName)"
    } elseif ($_.Id) {
        $roleMap[$_.Id] = "[Rolle] (Unbenannt)"
    }
}

# Lookup-Funktion
function Resolve-IdentityName {
    param ($id)
    if ($userMap.ContainsKey($id)) {
        return $userMap[$id]
    } elseif ($groupMap.ContainsKey($id)) {
        return $groupMap[$id]
    } elseif ($roleMap.ContainsKey($id)) {
        return $roleMap[$id]
    } else {
        return "[Unbekannt] $id"
    }
}

# CA-Policies abrufen und Zielobjekte (User, Gruppen, Rollen) anzeigen
Get-MgIdentityConditionalAccessPolicy | Select-Object `
    DisplayName,
    State,
    @{Name='Included Identities'; Expression={
        (
            ($_.Conditions.Users.IncludeUsers + $_.Conditions.Users.IncludeGroups + $_.Conditions.Users.IncludeRoles) |
            ForEach-Object { Resolve-IdentityName $_ }
        ) -join ', '
    }},
    @{Name='Excluded Identities'; Expression={
        (
            ($_.Conditions.Users.ExcludeUsers + $_.Conditions.Users.ExcludeGroups + $_.Conditions.Users.ExcludeRoles) |
            ForEach-Object { Resolve-IdentityName $_ }
        ) -join ', '
    }} |
Export-Excel .\CA-Policy-Report123.xlsx -WorksheetName "Policies"