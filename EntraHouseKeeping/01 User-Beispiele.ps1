# Einige Beispiele wie sich über die Microsoft Graph Benutzerinformationen auslesen lassen
# Das ganze hier mit dem Fokus länger nicht benutzte Konten zu identifizieren
# 
# Die Cmdlets mit Kommentar sind hier Beispiele gedacht 
#
# Für Ausgabe der Benutzer in Excel wird das Modul "ImportExcel" von Doug Finke benutzt  

# Installiere Powershell Module, wenn noch nicht geschehen
#Install-Module -name ImportExcel
#Install-Module -name microsoft.graph

# Excel File
$xlsFile = Join-Path (Get-Location) 'UnusedObjects.xlsx'

# Login/Connect to MS Graph
Connect-MgGraph -Scopes 'User.Read.All', "Auditlog.Read.All"

# Liste aller Benutzer mit einigen Eigenschaften
#Get-MgUser -All | Format-Table  ID, DisplayName, Mail, UserPrincipalName

# Liste mit Filterkriterien
#Get-MgUser -ConsistencyLevel eventual -Filter "startsWith(DisplayName, 'B')" 

# Ebenfalls gefiltert, nur andere Syntax
#Get-MgUser -ConsistencyLevel eventual -Search '"DisplayName:Ad"'

# The good old SQL days... order by :-)
#Get-MgUser -ConsistencyLevel eventual -Count userCount -Filter "startsWith(DisplayName, 'A')" -OrderBy UserPrincipalName

# Bestimmte Eigenschaften einschließlich des Datums der letzten Anmeldung
#Get-MgUser -All -Property UserprincipalName, Displayname, CreatedDateTime, SignInActivity `
#    | Select-Object DisplayName, UserPrincipalName, @{N="Last SignIn";E={$_.SignInActivity.LastSignInDateTime}}, CreatedDateTime 

# Liste der Benutzer mit Anmeldung vor einem spezifischem Anmeldedatum
#Get-MgUser -Filter "signInActivity/lastSignInDateTime le 2025-12-31T00:00:00Z"

# Liste aller Geräte die länger als 90 Tage nicht benutzt wurden
$date = (Get-Date (Get-Date).AddDays(-90) -Format u).Replace(' ','T')

# ... und das ganze selektiert vor einem Zeitpunkt
Get-MgUser -Filter "signInActivity/lastSignInDateTime le $date" `
    -Property UserprincipalName,Displayname,CreatedDateTime, SignInActivity `
    | Select-Object DisplayName, 
            @{N="Last SignIn";E={$_.SignInActivity.LastSignInDateTime}}, `
            UserPrincipalName,
            CreatedDateTime `
    | Export-Excel $xlsFile -WorksheetName "Internal User" -ClearSheet -AutoSize

# Liste mit unbenutzten Gastusern erstellen. Entweder länger 60 Tage oder noch nie angemeldet
$date = (Get-Date).AddDays(-60)
Get-MgUser -All `
  -Property DisplayName,UserPrincipalName,UserType,CreatedDateTime,SignInActivity `
  -ConsistencyLevel eventual |
Where-Object {
    $_.UserType -eq 'Guest' -and
    (
      $_.SignInActivity.LastSignInDateTime -eq $null -or
      $_.SignInActivity.LastSignInDateTime -le $date
    )
} |
Select-Object DisplayName,
    UserType,
    @{N="LastSignIn";E={$_.SignInActivity.LastSignInDateTime}},
    UserPrincipalName,
    CreatedDateTime |
Export-Excel $xlsFile -WorksheetName "Guest User" -ClearSheet -AutoSize

# Liste mit Benutzer ohne Manager
$users = Get-MgUser -All `
  -Property Id,DisplayName,UserPrincipalName,UserType,CreatedDateTime `
  -ConsistencyLevel eventual

$usersWithoutManager = foreach ($u in $users) {
  try {
    $null = Get-MgUserManager -UserId $u.Id -ErrorAction Stop
  }
  catch {
    if ($_.Exception.Message -match "Request_ResourceNotFound|ResourceNotFound|404") {
        [pscustomobject]@{
            DisplayName       = $u.DisplayName
            UserPrincipalName = $u.UserPrincipalName
            UserType          = $u.UserType
            CreatedDateTime   = $u.CreatedDateTime
        }
    }
  }
}

$usersWithoutManager |
  Export-Excel $xlsFile -WorksheetName "NoManagerUser" -ClearSheet -AutoSize



Disconnect-Graph
