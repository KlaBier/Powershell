
# KBRUN Tenant Parameter
# Hier die Parameter aus dem eigenen Tenant eintragen
# Script schrittweise ausführen, wie in den Screencasts gezeigt
$Tenant = 'f5c07476-f2f0-45bf-8745-34a90b6a2a1d'
$ServicePrincipal = '5313c5fc-4e46-4d5a-b9ed-1c2065e1093b'
$UserCSV = '.\SCIMAPIDemo\UserList.csv'  


##############################################################################################
### STEP 1: Load Attribute Mapping Definitions for each Data Source
$KBAccountAttributeMapping = Import-PowerShellDataFile '.\SCIMAPIDemo\AttributeMapping.psd1'

##############################################################################################
### STEP 2: Test SCIM Bulk Payload Generation
.\CSV2SCIM\src\CSV2SCIM.ps1 -Path $UserCSV `
-AttributeMapping $KBAccountAttributeMapping `
-ValidateAttributeMapping

##############################################################################################
## STEP 3 (optional): SCIM Payload output to check what will be send to the endpoint
.\CSV2SCIM\src\CSV2SCIM.ps1 -Path $UserCSV -AttributeMapping $KBAccountAttributeMapping
# ... the same, but written to a file
.\CSV2SCIM\src\CSV2SCIM.ps1 -Path $UserCSV -AttributeMapping $KBAccountAttributeMapping > BulkRequestPayload.json

##############################################################################################
## STEP 4 (optional): Update SCIM Schema

.\CSV2SCIM\src\CSV2SCIM.ps1 -Path $UserCSV `
    -ScimSchemaNamespace 'urn:ietf:params:scim:schemas:extension:kbcorp2021:2.0:User' `
    -TenantId $Tenant `
    -ServicePrincipalId $ServicePrincipal `
    -UpdateSchema

.\CSV2SCIM\src\CSV2SCIM.ps1 -Path $UserCSV -AttributeMapping $KBAccountAttributeMapping `
    -TenantId $Tenant -ServicePrincipalId $ServicePrincipal

  
##############################################################################################
## Diverses

## Ermittle bestimmte Benutzer
Get-MgUser -ConsistencyLevel eventual -Count userCount `
  -Filter "startsWith(DisplayName, 'Cecil')" `
  -OrderBy UserPrincipalName `
  -Select "id,displayName,mail,userPrincipalName,employeeHireDate" | 
Format-List ID, DisplayName, Mail, UserPrincipalName, employeeHireDate

## Lösche Testbenutzer im Tenant
$upnPrefix = "EMP"

# Abrufen der Benutzer, deren UPN mit der definierten Zeichenkette beginnt
$users = Get-MgUser -Filter "startswith(userPrincipalName, '$upnPrefix')"

# Löschen der gefundenen Benutzer
foreach ($user in $users) {
    Remove-MgUser -UserId $user.Id
}





