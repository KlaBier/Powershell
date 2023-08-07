# Beispiele für den Umgang mit Administrative Units

# Weitere Hinweise finden sich in dem Artikel
# https://learn.microsoft.com/en-us/graph/api/resources/administrativeunit?view=graph-rest-1.0

Import-Module Microsoft.Graph.Identity.DirectoryManagement

$params = @{
	displayName = "Praktikanten3"
	description = "Enthält alle Benutzerkonten der Praktikanten"
	visibility = "HiddenMembership"
}

Connect-MgGraph -scopes "AdministrativeUnit.ReadWrite.All"


New-MgDirectoryAdministrativeUnit -BodyParameter $params

Disconnect-Graph
