# Einige Beispiele wie sich über die Microsoft Graph Benutzerinformationen auslesen lassen
# Das ganze hier mit dem Fokus länger nicht benutzte Konten zu identifizieren
# 
# Das SCript ist nicht als Ganzes lauffähig. Das sind Beispiele, die als Anregung für eigene 
# Entwicklungen dienen sollen.
#
#
# Additional infos are given here
# https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.users/get-mguser?source=recommendations&view=graph-powershell-1.0


# Install Excel Powershell Module from Doug Finke 
Install-Module -name ImportExcel
Install-Module -name microsoft.graph

# Login/Connect to MS Graph
Connect-MgGraph -Scopes 'User.Read.All', "Auditlog.Read.All"

# Liste aller Benutzer mit einigen Eigenschaften
Get-MgUser -All | Format-Table  ID, DisplayName, Mail, UserPrincipalName

# Liste mit Filterkriterien
Get-MgUser -ConsistencyLevel eventual -Filter "startsWith(DisplayName, 'B')" 

# Ebenfalls gefiltert
Get-MgUser -ConsistencyLevel eventual -Search '"DisplayName:Ad"'

# The good old SQL days... order by :-)
Get-MgUser -ConsistencyLevel eventual -Count userCount -Filter "startsWith(DisplayName, 'A')" -OrderBy UserPrincipalName

# Liste der Benutzer mit Anmeldung vor einem spezifischem Anmeldedatum
Get-MgUser -Filter "signInActivity/lastSignInDateTime le 2022-04-25T00:00:00Z"

# Bestimmte Eigenschaften einschließlich des Datums der letzten Anmeldung
Get-MgUser -All -Property UserprincipalName, Displayname, CreatedDateTime, SignInActivity `
    | Select-Object DisplayName, UserPrincipalName, @{N="Last SignIn";E={$_.SignInActivity.LastSignInDateTime}}, CreatedDateTime 

# ... und das ganze selektiert vor einem Zeitpunkt
Get-MgUser -Filter "signInActivity/lastSignInDateTime le 2023-04-30T00:00:00Z" `
    -Property UserprincipalName,Displayname,CreatedDateTime, SignInActivity `
    | Select-Object DisplayName, 
             UserPrincipalName,
             CreatedDateTime,
             @{N="Last SignIn";E={$_.SignInActivity.LastSignInDateTime}} `
    | Export-Excel .\UnusedUser.xlsx -WorksheetName "UserList" -AutoSize

Disconnect-Graph                     