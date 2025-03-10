
# get Graph ready
Import-Module Microsoft.Graph

# ... use Excel stuff from Doug Finke
Install-Module -Name ImportExcel

# Login
Connect-MgGraph -Scopes "RoleManagement.Read.All"
# Get all roles
$roles = Get-MgRoleManagementDirectoryRoleDefinition
Connect-AzAccount
$azroles = Get-AzRoleDefinition

# ... and write it to excel
$roles | select-object -property DisplayName, Description | Export-Excel .\Coding4Fun\roles2.xlsx -WorksheetName "Roles" -AutoSize

$azroles | select-object -property Name, Description | Export-Excel .\Coding4Fun\roles2.xlsx -WorksheetName "AZRoles" -AutoSize

$azroles | select-object -property Name, Description