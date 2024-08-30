
# KBRUN Tenant section
$Tenant = 'f5c07476-f2f0-45bf-8745-34a90b6a2a1d'
$ServicePrincipal = '5313c5fc-4e46-4d5a-b9ed-1c2065e1093b'
# $ClientID = '5313c5fc-4e46-4d5a-b9ed-1c2065e1093b'
$UserCSV = '.\SCIMAPIDemo\UserList.csv'  

# Test Tenant section
# $Tenant             = '70eae874-1a2f-43ce-992e-389698a0ee0a'
# $ServicePrincipal   = 'e1a66fb9-7675-4a70-a6a1-8aef893a085f'
 
##############################################################################################
### STEP 1: Load Attribute Mapping Definitions for each Data Source
$KBAccountAttributeMapping = Import-PowerShellDataFile '.\SCIMAPIDemo\AttributeMapping.psd1'

##############################################################################################
### STEP 2: Test SCIM Bulk Payload Generation
.\CSV2SCIM\src\CSV2SCIM.ps1 -Path $UserCSV `
-AttributeMapping $KBAccountAttributeMapping `
-ValidateAttributeMapping

##############################################################################################
## Generate SCIM Bulk Payloads for Employee Data Using Employee Attribute Mapping Definition
.\CSV2SCIM\src\CSV2SCIM.ps1 -Path $UserCSV `
  -AttributeMapping $KBAccountAttributeMapping

# Ausgabe in ein File schreiben
.\CSV2SCIM\src\CSV2SCIM.ps1 -Path $UserCSV -AttributeMapping $KBAccountAttributeMapping > BulkRequestPayload.json

## Update Schema // funktioniert aktuell noch nicht
#.\CSV2SCIM\src\CSV2SCIM.ps1 -Path $UserCSV `
#    -ScimSchemaNamespace 'urn:ietf:params:scim:schemas:extension:kbrun:1.0:User' `
#    -TenantId $Tenant `
#    -ServicePrincipalId $ServicePrincipal `
#    -UpdateSchema

#.\CSV2SCIM\src\CSV2SCIM.ps1 -Path $UserCSV -AttributeMapping $KBAccountAttributeMapping `
#    -TenantId $Tenant -ServicePrincipalId $ServicePrincipal 
#    -ClientId $ClientID `
#    -ClientCertificate $cert 

.\CSV2SCIM\src\CSV2SCIM.ps1 -Path $UserCSV -AttributeMapping $KBAccountAttributeMapping `
    -TenantId $Tenant -ServicePrincipalId $ServicePrincipal

# Logs
.\CSV2SCIM\src\CSV2SCIM.ps1 -ServicePrincipalId $ServicePrincipal `
  -TenantId $Tenant `
  -GetPreviousCycleLogs -NumberOfCycles 1

# Certificate Stuff
$ClientCertificate = New-SelfSignedCertificate -Subject 'CN=CSV2SCIM' -KeyExportPolicy 'NonExportable' -CertStoreLocation Cert:\CurrentUser\My
$ThumbPrint = $ClientCertificate.ThumbPrint

Connect-MgGraph -Scopes "Application.ReadWrite.All"
Update-MgApplication -ApplicationId 'a15600d8-0302-44d6-9077-9ada46d6f527' -KeyCredentials @{
   Type = "AsymmetricX509Cert"
   Usage = "Verify"
   Key = $ClientCertificate.RawData
}

# and to get the certificate
$cert = Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object { $_.Subject -like "CN=CSV2SCIM" }


Connect-MgGraph

Disconnect-MgGraph

Install-Module Microsoft.Graph -Scope AllUsers -Repository PSGallery -Force

Install-Module Microsoft.Graph 

Install-Module -Name Microsoft.Graph.Authentication

Get-InstalledModule Microsoft.Graph

Update-MAodule Microsoft.Graph



$upnPrefix = "EMP"

# Abrufen der Benutzer, deren UPN mit der definierten Zeichenkette beginnt
$users = Get-MgUser -Filter "startswith(userPrincipalName, '$upnPrefix')"

# Löschen der gefundenen Benutzer
foreach ($user in $users) {
    Remove-MgUser -UserId $user.Id
}


Connect-MgGraph -Scopes 'User.Read.All'
Get-MgUser -ConsistencyLevel eventual -Count userCount `
  -Filter "startsWith(DisplayName, 'Cecil')" `
  -OrderBy UserPrincipalName | 
Format-List  ID, DisplayName, Mail, UserPrincipalName, employeehiredate, employeeLeaveDateTime 

Get-MgUser -ConsistencyLevel eventual -Count userCount `
  -Filter "startsWith(DisplayName, 'Cecil')" |` 
  Select-Object ID, DisplayName, Mail, UserPrincipalName, @{Name="employeehiredate";Expression={$_.employeehiredate.ToString("dd.MM.yyyy")}}, employeeLeaveDateTime |
  Format-List



