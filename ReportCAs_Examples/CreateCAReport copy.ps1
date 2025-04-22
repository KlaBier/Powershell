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

# CA-Policies abrufen und Zielobjekte (User, Gruppen, Rollen, externe Typen) anzeigen
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
    }},
    @{Name='Included ExternalUserTypes'; Expression={
        if ($_.Conditions.Users.IncludeGuestsOrExternalUsers -and $_.Conditions.Users.IncludeGuestsOrExternalUsers.GuestOrExternalUserTypes) {
            ($_.Conditions.Users.IncludeGuestsOrExternalUsers.GuestOrExternalUserTypes -join ', ')
        } else {
            ''
        }
    }},
    @{Name='Excluded ExternalUserTypes'; Expression={
        if ($_.Conditions.Users.ExcludeGuestsOrExternalUsers -and $_.Conditions.Users.ExcludeGuestsOrExternalUsers.GuestOrExternalUserTypes) {
            ($_.Conditions.Users.ExcludeGuestsOrExternalUsers.GuestOrExternalUserTypes -join ', ')
        } else {
            ''
        }
    }} |
Export-Excel .\CA-Policy-Report-Final.xlsx -WorksheetName "Policies" -AutoSize











Connect-MgGraph

# Benutzer, Gruppen, Rollenvorlagen abrufen
$allUsers = Get-MgUser -All
$allGroups = Get-MgGroup -All
$allRoleTemplates = Get-MgDirectoryRoleTemplate -All

# Hash-Maps
$userMap = @{}
$groupMap = @{}
$roleMap = @{}

$allUsers | ForEach-Object { $userMap[$_.Id] = $_.DisplayName }
$allGroups | ForEach-Object { $groupMap[$_.Id] = "[Gruppe] $($_.DisplayName)" }
$allRoleTemplates | ForEach-Object {
    if ($_.Id -and $_.DisplayName) {
        $roleMap[$_.Id] = "[Rolle] $($_.DisplayName)"
    } elseif ($_.Id) {
        $roleMap[$_.Id] = "[Rolle] (Unbenannt)"
    }
}

# ID-Resolver
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

# CA-Policies analysieren
Get-MgIdentityConditionalAccessPolicy | Select-Object `
    DisplayName,
    State,
    @{Name='Included Identities'; Expression={
        $resolved = ($_.Conditions.Users.IncludeUsers + $_.Conditions.Users.IncludeGroups + $_.Conditions.Users.IncludeRoles) |
            ForEach-Object { Resolve-IdentityName $_ }

        $externalTypes = $_.Conditions.Users.IncludeGuestsOrExternalUsers?.GuestOrExternalUserTypes
        if ($externalTypes) {
            $resolved += ($externalTypes | ForEach-Object { "[Extern] $_" })
        }

        $resolved -join ', '
    }},
    @{Name='Excluded Identities'; Expression={
        $resolved = ($_.Conditions.Users.ExcludeUsers + $_.Conditions.Users.ExcludeGroups + $_.Conditions.Users.ExcludeRoles) |
            ForEach-Object { Resolve-IdentityName $_ }

        $externalTypes = $_.Conditions.Users.ExcludeGuestsOrExternalUsers?.GuestOrExternalUserTypes
        if ($externalTypes) {
            $resolved += ($externalTypes | ForEach-Object { "[Extern] $_" })
        }

        $resolved -join ', '
    }} |
Export-Excel .\CA-Policy-Report-Combined.xlsx -WorksheetName "Policies" -AutoSize