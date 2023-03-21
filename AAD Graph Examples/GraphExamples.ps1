# Some examples how Graph and PS can be used together
# Additional infos are given here
# https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.users/get-mguser?source=recommendations&view=graph-powershell-1.0


# Get list with all users
Connect-MgGraph -Scopes 'User.Read.All', "Auditlog.Read.All"
Get-MgUser -All | Format-Table  ID, DisplayName, Mail, UserPrincipalName

# Find specific user 
Get-MgUser -ConsistencyLevel eventual -Count userCount -Filter "startsWith(DisplayName, 'B')" 

Get-MgUser -ConsistencyLevel eventual -Count userCount -Search '"DisplayName:Ad"'

# The good old SQL days... order by :-)
Get-MgUser -ConsistencyLevel eventual -Count userCount -Filter "startsWith(DisplayName, 'A')" -OrderBy UserPrincipalName


Select-MgProfile beta

$props = @( 
     # Basic metadata
    'Id','DisplayName','Mail','UserPrincipalName','Department','JobTitle'     
    # Account Status    
    'AccountEnabled',     
    # Password last set     
    'LastPasswordChangeDateTime',     
    # Last logon     
    'SignInActivity',     
    # Assigned Licenses     
    'AssignedLicenses' 
)

Get-MgUser -All -Property $props | Select-Object $props
$mgUsers = Get-MgUser -All -Property $props | Select-Object $props

$userOutput = foreach ($user in $mgUsers) {     
    # Resolve the ID to license name     
    #$licenses = foreach($license in $user.AssignedLicenses) {         
    #    $skuHt[$license.SkuId].SkuPartNumber     
    #}     
    
    # Get the last logon date     
    $lastLogon = $user.SignInActivity.LastSignInDateTime     
    # Add the new properties     
    $user | Add-Member -MemberType NoteProperty -Name LastLogonDateTime -Value $lastLogon     
    #$user | Add-Member -MemberType NoteProperty -Name Licenses -Value ($licenses -join ',')     
    
    # Remove the unneeded ones     
    $user | Select-Object -ExcludeProperty SignInActivity 
    #$user | Select-Object -ExcludeProperty SignInActivity,AssignedLicenses 

}
 
$userOutput
