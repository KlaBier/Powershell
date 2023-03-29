
# Additional infos are given here
# https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.users/get-mguser?source=recommendations&view=graph-powershell-1.0


# Install Excel Powershell Module from Doug Finke 
#Install-Module ImportExcel

# Login/Connect
Connect-MgGraph -Scopes 'User.Read.All', "Auditlog.Read.All"

# Get list with all users, some properties
Get-MgUser -All | Format-Table  ID, DisplayName, Mail, UserPrincipalName

# Find specific user or range
Get-MgUser -ConsistencyLevel eventual -Count userCount -Filter "startsWith(DisplayName, 'B')" 

# Search doing the same another way
Get-MgUser -ConsistencyLevel eventual -Count userCount -Search '"DisplayName:Ad"'

# The good old SQL days... order by :-)
Get-MgUser -ConsistencyLevel eventual -Count userCount -Filter "startsWith(DisplayName, 'A')" -OrderBy UserPrincipalName

# Accessing signinactivity requires beta profile
Select-MgProfile beta

Get-MgUser -All -Property $props | Select-Object $props | Format-Table

# Get list with all users
Get-MgUser -All | Format-Table  ID, DisplayName, Mail, UserPrincipalName

Get-MgUser -Filter "signInActivity/lastSignInDateTime le 2022-12-30"

Get-MgUser -All -Property UserprincipalName,Displayname,CreatedDateTime, SignInActivity | select DisplayName, CreatedDateTime, UserPrincipalName, @{N="Last SignIn";E={$_.SignInActivity.LastSignInDateTime}} 

Get-MgUser -Filter "signInActivity/lastSignInDateTime le 2021-12-30" `
    -Property UserprincipalName,Displayname,CreatedDateTime, SignInActivity `
    | select DisplayName, `
             CreatedDateTime,`
             UserPrincipalName,`
             @{N="Last SignIn";E={$_.SignInActivity.LastSignInDateTime}}`
    | Export-Excel .\UnusedUser.xlsx -TableName Userlist -AutoSize

# Graph Statements doing the same
# https://graph.microsoft.com/beta/users?$select=displayName,userPrincipalName,signInActivity&$filter=signInActivity/lastSignInDateTime le 2023-02-01T00:00:00Z
# https://graph.microsoft.com/beta/users?$select=displayName,signInActivity
