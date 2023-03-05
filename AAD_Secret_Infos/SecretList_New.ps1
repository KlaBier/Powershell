
connect-azuread

#Get Azure AD Apps
$AzureADApps =Get-AzureADApplication -All $true

Write-output "Displayname, AppID, Secret Startdate, Secret expire" | Out-File -filepath .\SecretsOnly.txt

#Loop through Azure AD Apps
Foreach ($App in $AzureADApps)
{
    #Show App Owner UPN/Mail
    $AppObjectID = $App.ObjectID
    $AppOwners = Get-AzureADApplicationOwner -ObjectId $AppObjectID
        
    Foreach ($AppOwner in $AppOwners)
    {
        Foreach ($PasswordCredential in $App.PasswordCredentials)
        {
               Write-Output "$($App.DisplayName), $($App.AppID), $($PasswordCredential.startdate.ToString('yyyy-MM-dd')), $($PasswordCredential.enddate.ToString('yyyy-MM-dd'))" | Out-File ".\SecretsOnly.txt" -Append
        }
    }
 }     


Write-output "Displayname, AppID, Owner, Secret Startdate, Secret expire" | Out-File -filepath .\SecretsOneOwner.txt

#Loop through Azure AD Apps
Foreach ($App in $AzureADApps)
{
    #Show App Owner UPN/Mail
    $AppObjectID = $App.ObjectID
    $AppOwners = Get-AzureADApplicationOwner -ObjectId $AppObjectID
        
    Foreach ($PasswordCredential in $App.PasswordCredentials)
    {
      Write-Output "$($App.DisplayName), $($App.AppID), $($AppOwner.UserPrincipalName), $($PasswordCredential.startdate.ToString('yyyy-MM-dd')), $($PasswordCredential.enddate.ToString('yyyy-MM-dd'))" | Out-File ".\SecretsOneOwner.txt" -Append
    }
 }     