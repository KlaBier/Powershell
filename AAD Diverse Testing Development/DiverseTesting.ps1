# Some examples how Graph and PS can be used together
# Additional infos are given here
# https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.users/get-mguser?source=recommendations&view=graph-powershell-1.0


#Install-Module ImportExcel

# Get list with all users
#Connect-MgGraph -Scopes 'User.Read.All', "Auditlog.Read.All"
#Get-MgUser -All | Format-Table  ID, DisplayName, Mail, UserPrincipalName

# Find specific user 
Get-MgUser -ConsistencyLevel eventual -Count userCount -Filter "startsWith(DisplayName, 'B')" 

Get-MgUser -ConsistencyLevel eventual -Count userCount -Search '"DisplayName:Ad"'

# The good old SQL days... order by :-)
Get-MgUser -ConsistencyLevel eventual -Count userCount -Filter "startsWith(DisplayName, 'A')" -OrderBy UserPrincipalName

https://graph.microsoft.com/beta/users?$select=displayName,userPrincipalName,signInActivity&$filter=signInActivity/lastSignInDateTime le 2023-02-01T00:00:00Z


Select-MgProfile beta

$props = @( 
     # Basic metadata
    'Id','DisplayName','Mail','UserPrincipalName','Department','JobTitle'     
    # Account Status    
    'AccountEnabled',     
    # Password last set     
    'LastPasswordChangeDateTime',     
    # Last logon     
    'SignInActivity'     
)

Get-MgUser -All -Property $props | Select-Object $props

$mgUsers = Get-MgUser -All -Property $props | Select-Object $props
$userOutput = foreach ($user in $mgUsers) {     
    # Get the last logon date     
    $lastLogon = $user.SignInActivity.LastSignInDateTime     
    # Add the new properties     
    $user | Add-Member -MemberType NoteProperty -Name LastLogonDateTime -Value $lastLogon     
    
    # Remove the unneeded ones     
    $user | Select-Object -ExcludeProperty SignInActivity 
}
 
$useroutput | Export-Excel C:Users.xlsx -TableName User -AutoSize

Install-Module -name azureadpreview
get-azureadauditsigninlogs

Connect-AzureAD

Get-AzureADAuditSignInLogs -Filter "startsWith(userPrincipalName,'Klaus')"




connect-azuread

Write-output "UserDisplayname, UserPrincipalname, DeviceID, ClientAppUsed, AppDisplayname" | Out-File -filepath c:\temp\secrets.txt

Write-output "UserDisplayname, UserPrincipalname, DeviceID, ClientAppUsed, AppDisplayname"

#
# Read Signin Log and list user with all device IDs
Connect-AzureAD

Get-AzureADAuditSignInLogs -Filter UserDisplayName like 'Klaus' -Top 10

Get-AzureADAuditSignInLogs -All:$true | Where {$_.UserDisplayname -Contains "Klaus"}

Get-AzureADAuditSignInLogs -filter "contains(UserDisplayname, 'Klaus')"

Write-output "UserDisplayname, UserPrincipalname, DeviceID, ClientAppUsed, AppDisplayname" | Out-File -filepath c:\temp\secrets.txt

Get-AzureADAuditSignInLogs -Filter "contains(UserDisplayname, 'k')" | select CreatedDateTime, UserDisplayName, UserPrincipalName, {$_.DeviceDetail.DeviceID}, ClientAppUsed, AppDisplayName | FT | Out-File -FilePath c:\temp\User_DeviceID.txt

Get-AzureADAuditSignInLogs -Filter "contains(UserDisplayname, 'k')" | select CreatedDateTime, UserDisplayName, UserPrincipalName, {$_.DeviceDetail.DeviceID}, ClientAppUsed, AppDisplayName | FT


