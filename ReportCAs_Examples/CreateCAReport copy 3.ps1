Connect-MgGraph -Scopes "Policy.Read.All", "Directory.Read.All", "Application.Read.All"

# Daten laden
$allUsers = Get-MgUser -All
$allGroups = Get-MgGroup -All
$allRoles = Get-MgDirectoryRoleTemplate -All
$allApps = Get-MgServicePrincipal -All

# Lookup-Maps
$userMap = @{}
$groupMap = @{}
$roleMap = @{}
$appMap = @{}

$allUsers | ForEach-Object { $userMap[$_.Id] = $_.DisplayName }
$allGroups | ForEach-Object { $groupMap[$_.Id] = "[Gruppe] $($_.DisplayName)" }
$allRoles | ForEach-Object { $roleMap[$_.Id] = "[Rolle] $($_.DisplayName)" }
$allApps | ForEach-Object { if ($_.AppId -and $_.DisplayName) { $appMap[$_.AppId] = $_.DisplayName } }

function Resolve-IdentityName($id) {
    if ($userMap.ContainsKey($id)) { return $userMap[$id] }
    elseif ($groupMap.ContainsKey($id)) { return $groupMap[$id] }
    elseif ($roleMap.ContainsKey($id)) { return $roleMap[$id] }
    else { return "[Unbekannt] $id" }
}

function Resolve-AppId($id) {
    if ($appMap.ContainsKey($id)) { return $appMap[$id] }
    else { return "[App-ID] $id" }
}

# Policies analysieren
$report = Get-MgIdentityConditionalAccessPolicy | ForEach-Object {
    $p = $_

    # Identities
    $included = ($p.Conditions.Users.IncludeUsers + $p.Conditions.Users.IncludeGroups + $p.Conditions.Users.IncludeRoles) | ForEach-Object { Resolve-IdentityName $_ }
    $excluded = ($p.Conditions.Users.ExcludeUsers + $p.Conditions.Users.ExcludeGroups + $p.Conditions.Users.ExcludeRoles) | ForEach-Object { Resolve-IdentityName $_ }

    $includedExternal = $p.Conditions.Users.IncludeGuestsOrExternalUsers?.GuestOrExternalUserTypes | ForEach-Object { "[Extern] $_" }
    $excludedExternal = $p.Conditions.Users.ExcludeGuestsOrExternalUsers?.GuestOrExternalUserTypes | ForEach-Object { "[Extern] $_" }

    # Apps
    $appsIncluded = $p.Conditions.Applications.IncludeApplications | ForEach-Object { Resolve-AppId $_ }
    $appsExcluded = $p.Conditions.Applications.ExcludeApplications | ForEach-Object { Resolve-AppId $_ }
    $userActions  = $p.Conditions.Applications.IncludeUserActions -join ", "

    # Risk Levels
    $signInRisk = @()
    if ($p.Conditions.SignInRiskLevels) {
        $signInRisk += "Include: " + ($p.Conditions.SignInRiskLevels -join ", ")
    }
    if ($p.Conditions.ExcludeSignInRiskLevels) {
        $signInRisk += "Exclude: " + ($p.Conditions.ExcludeSignInRiskLevels -join ", ")
    }

    $userRisk = @()
    if ($p.Conditions.UserRiskLevels) {
        $userRisk += "Include: " + ($p.Conditions.UserRiskLevels -join ", ")
    }
    if ($p.Conditions.ExcludeUserRiskLevels) {
        $userRisk += "Exclude: " + ($p.Conditions.ExcludeUserRiskLevels -join ", ")
    }

    # Device Conditions
    $platforms = @()
    if ($p.Conditions.Platforms.IncludePlatforms) { $platforms += "Include: " + ($p.Conditions.Platforms.IncludePlatforms -join ", ") }
    if ($p.Conditions.Platforms.ExcludePlatforms) { $platforms += "Exclude: " + ($p.Conditions.Platforms.ExcludePlatforms -join ", ") }

    $deviceStates = @()
    if ($p.Conditions.DeviceStates.IncludeStates) { $deviceStates += "Include: " + ($p.Conditions.DeviceStates.IncludeStates -join ", ") }
    if ($p.Conditions.DeviceStates.ExcludeStates) { $deviceStates += "Exclude: " + ($p.Conditions.DeviceStates.ExcludeStates -join ", ") }

    $locations = @()
    if ($p.Conditions.Locations.IncludeLocations) { $locations += "Include: " + ($p.Conditions.Locations.IncludeLocations -join ", ") }
    if ($p.Conditions.Locations.ExcludeLocations) { $locations += "Exclude: " + ($p.Conditions.Locations.ExcludeLocations -join ", ") }

    # Grant Controls
    $grantControls = @()
    if ($p.GrantControls.BuiltInControls) { $grantControls += $p.GrantControls.BuiltInControls }
    if ($p.GrantControls.TermsOfUse) { $grantControls += "[ToU]" }
    if ($p.GrantControls.Operators) { $grantControls += "Operator: " + ($p.GrantControls.Operators -join ", ") }

    # Session Controls
    $sessionControls = @()
    if ($p.SessionControls.ApplicationEnforcedRestrictions -eq $true) { $sessionControls += "App Enforced Restrictions" }
    if ($p.SessionControls.PersistentBrowser?.Mode) { $sessionControls += "Persistent Browser: $($p.SessionControls.PersistentBrowser.Mode)" }
    if ($p.SessionControls.SignInFrequencyValue -or $p.SessionControls.SignInFrequencyType) {
        $sessionControls += "Sign-in Frequency: $($p.SessionControls.SignInFrequencyValue) $($p.SessionControls.SignInFrequencyType)"
    }

    # Ergebnisobjekt
    [PSCustomObject]@{
        PolicyName               = $p.DisplayName
        State                    = $p.State

        Included_Identities      = ($included + $includedExternal) -join ", "
        Excluded_Identities      = ($excluded + $excludedExternal) -join ", "

        Targeted_Applications    = $appsIncluded -join ", "
        Excluded_Applications    = $appsExcluded -join ", "
        User_Actions             = $userActions

        SignIn_Risk_Levels       = $signInRisk -join " | "
        User_Risk_Levels         = $userRisk -join " | "
        Device_Platforms         = $platforms -join " | "
        Device_States            = $deviceStates -join " | "
        Named_Locations          = $locations -join " | "

        Grant_Controls           = $grantControls -join ", "
        Session_Controls         = $sessionControls -join " | "
    }
}

# Excel-Export
$report | Export-Excel .\CA-Policy-Report-Final.xlsx -WorksheetName "Policies" -AutoSize