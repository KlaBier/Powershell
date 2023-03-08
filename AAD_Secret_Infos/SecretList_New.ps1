
connect-azuread

$ExportPath = ".\AAD_Secret_Infos"

# Get Azure AD Apps
$AzureADApps =Get-AzureADApplication -All $true

Write-output "Displayname, AppID, Owner, Secret ID, Secret Startdate, Secret expire" | Out-File -FilePath ($ExportPath+"\AllAppOwnerAllSecrets.txt")

# run through all Azure AD Apps
Foreach ($App in $AzureADApps)
{
    # Get Owner
    $AppObjectID = $App.ObjectID
    $AppOwners = Get-AzureADApplicationOwner -ObjectId $AppObjectID
    
    # Write all owner to file
    Foreach ($AppOwner in $AppOwners)
    {
        Foreach ($PasswordCredential in $App.PasswordCredentials)
        {
               Write-Output "$($App.DisplayName), $($App.AppID), $($AppOwner.UserPrincipalName), $($PasswordCredential.KeyId), $($PasswordCredential.startdate.ToString('yyyy-MM-dd')), $($PasswordCredential.enddate.ToString('yyyy-MM-dd'))" | Out-File -FilePath ($ExportPath+"\AllAppOwnerAllSecrets.txt") -Append
        }
    }
 }     


Write-output "Displayname, AppID, Owner, Secret Startdate, Secret expire" | Out-File -filepath ($ExportPath+"\OneAppOwnerAllSecrets.txt")

#Loop through Azure AD Apps
Foreach ($App in $AzureADApps)
{
    #Show App Owner UPN/Mail
    $AppObjectID = $App.ObjectID
    $AppOwners = Get-AzureADApplicationOwner -ObjectId $AppObjectID
        
    Foreach ($PasswordCredential in $App.PasswordCredentials)
    {
      Write-Output "$($App.DisplayName), $($App.AppID), $($AppOwners[0].UserPrincipalName), $($PasswordCredential.startdate.ToString('yyyy-MM-dd')), $($PasswordCredential.enddate.ToString('yyyy-MM-dd'))" | Out-File -FilePath ($ExportPath+"\OneAppOwnerAllSecrets.txt") -Append
    }
 }     
 