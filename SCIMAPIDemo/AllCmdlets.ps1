
$Tenant = 'f5c07476-f2f0-45bf-8745-34a90b6a2a1d'
$ServicePrincipal = '81109b0c-ed2d-45d2-93f7-9509e023ee87'

# Test Tenant
$Tenant             = '70eae874-1a2f-43ce-992e-389698a0ee0a'
$ServicePrincipal   = 'e1a66fb9-7675-4a70-a6a1-8aef893a085f'
$UserCSV            = '.\PowerShell\SCIMAPIDemo\UserList1.csv'

### Load Attribute Mapping Definitions for each Data Source
$KBAccountAttributeMapping = Import-PowerShellDataFile '.\PowerShell\SCIMAPIDemo\AttributeMapping.psd1'


### Test SCIM Bulk Payload Generation
.\Powershell\CSV2SCIM\src\CSV2SCIM.ps1 -Path $UserCSV -AttributeMapping $KBAccountAttributeMapping -ValidateAttributeMapping

## Generate SCIM Bulk Payloads for Employee Data Using Employee Attribute Mapping Definition
.\Powershell\CSV2SCIM\src\CSV2SCIM.ps1 -Path $UserCSV -AttributeMapping $KBAccountAttributeMapping -Verbose

## Update Schema // funktioniert aktguell noch nicht
.\Powershell\CSV2SCIM\src\CSV2SCIM.ps1 -Path $UserCSV `
    -ScimSchemaNamespace 'urn:ietf:params:scim:schemas:extension:csv:2.0:User' `
    -TenantId $Tenant `
    -ServicePrincipalId $ServicePrincipal -UpdateSchema


### Send Requests to Azure AD
## Generate SCIM Bulk Payloads for Contractor Data Using Contractor Attribute Mapping Definition and Send Requests to Azure AD
.\Powershell\CSV2SCIM\src\CSV2SCIM.ps1 -Path $UserCSV -AttributeMapping $KBAccountAttributeMapping `
    -TenantId $Tenant -ServicePrincipalId $ServicePrincipal


# create Payload File
.\Powershell\CSV2SCIM\src\CSV2SCIM.ps1 -Path $UserCSV -AttributeMapping $KBAccountAttributeMapping > BulkRequestPayload.json


Connect-MgGraph

Disconnect-MgGraph

Install-Module Microsoft.Graph -Scope AllUsers -Repository PSGallery -Force

UnInstall-Module Microsoft.Graph 


Update-MAodule Microsoft.Graph
