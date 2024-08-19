# Below cmdlets can be used in module in to illustrate what properties can set and how this can be done


# Login/Connect to MS Graph and import ps cmdlets 
Import-Module Microsoft.Graph.Users
Connect-MgGraph  -Scopes 'User.ReadWrite.All', "Directory.AccessAsUser.All"

$preferredLanguage = 'de-DE'
$userId = Get-MgUser -UserId "DiegoS@kbcorp2021.onmicrosoft.com"

Update-MgUser -UserId $userId.Id -PreferredLanguage $preferredLanguage

Disconnect-Graph


Get-MgServicePrincipal -All -Property ID, notificationEmailAddresses, DisplayName  | select ID, DisplayName, @{Name=’emailaddresses’;Expression={$_.NotificationEmailAddresses -join “;”}} 




