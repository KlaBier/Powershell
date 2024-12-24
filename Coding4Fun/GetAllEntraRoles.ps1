
# Modul und Verbindung vorbereiten
Import-Module Microsoft.Graph

# ... gleiche Liste, aber Ausgabe diesmal direkt in eine Excel Tabelle mit den Excel Powershell Module von Doug Finke
Install-Module -Name ImportExcel

# Anmeldung bei Microsoft Graph
Connect-MgGraph -Scopes "RoleManagement.Read.All"

# Alle Rollen abrufen
$roles = Get-MgRoleManagementDirectoryRoleDefinition

# Rollen ausgeben
$roles | select-object -property DisplayName, Description | Export-Excel .\Coding4Fun\roles2.xlsx -WorksheetName "Roles" -AutoSize
