
# get Graph ready
Import-Module Microsoft.Graph

# ... use Excel stuff from Doug Finke
Install-Module -Name ImportExcel

# Login
Connect-MgGraph -Scopes "RoleManagement.Read.All"

# Get all roles
$roles = Get-MgRoleManagementDirectoryRoleDefinition

# ... and write it to excel
$roles | select-object -property DisplayName, Description | Export-Excel .\Coding4Fun\roles2.xlsx -WorksheetName "Roles" -AutoSize

Install-Module EntraExporter

Connect-EntraExporter
Export-Entra -Path 'C:\EntraBackup\'

Export-Entra -Path 'C:\EntraBackup\' -All
