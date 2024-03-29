###############################################################################################
# Die Beispiele unten zeigen wie sich anhand der "ApproximateLastSignInDateTime"
# ermitteln lässt, wann ein Gerät im AAD zuletzt verwendet wurde, also wann es zuletzt zum Zugriff
# auf die MS Cloud benutzt worden ist
# 
# Das Script ist nicht als Ganzes lauffähig. Das sind Beispiele, die als Anregung für eigene 
# Entwicklungen dienen sollen.
#
# Es ist sinnvoll nur noch Cmdlets aus dem Microsoft Graph Modul zu benutzen und nicht mehr aus "AzureAD"
# Für eine Migration der Cmdlets aus dem AzureAD- oder dem MSOnline Modul empfiehlt sich folgender Link
# https://learn.microsoft.com/en-us/powershell/microsoftgraph/azuread-msoline-cmdlet-map?view=graph-powershell-1.0
#
# An dem Beispiel für das Ermitteln ungenutzter Geräteobjekte hat sich lediglich das Cmdlet geändert
# und das "Property", das zur Abfrage des Datum der letzten Verwendung dient, ist in der
# Microsoft Graph "ApproximateLastSignInDateTime" und nicht mehr ApproximateLastLogonTimestamp
###############################################################################################

# Install Powershell Modul, wenn noch nicht geschehen (Aadmin Rechte erforderlich) 
Install-Module -name microsoft.graph

# Login/Connect
Connect-MgGraph -Scopes Device.Read.All

# Liste alle Geräte 
Get-MgDevice -All:$true

# Nur bestimmte Eigenschaften
Get-MgDevice -All:$true `
    | select-object -Property DisplayName, ApproximateLastSignInDateTime, DeviceId, DeviceOSType, DeviceOSVersion `
    | Format-Table 

# ... gleiche Liste, aber Ausgabe in eine CSV
Get-MgDevice -All:$true `
    | select-object -Property DisplayName, ApproximateLastSignInDateTime, DeviceId, DeviceOSType, DeviceOSVersion `
    | export-csv .\UnusedDevices.csv -NoTypeInformation

# ... gleiche Liste, aber Ausgabe diesmal direkt in eine Excel Tabelle mit dem Excel Powershell Module von Doug Finke
Install-Module -Name ImportExcel

Get-MgDevice -All:$true `
    | select-object -Property DisplayName, DeviceId, DeviceOSType, DeviceOSVersion, ApproximateLastSignInDateTime `
    | Export-Excel .\UnusedDevices.xlsx -WorksheetName "Devices" -AutoSize

# Erstelle eine Liste mit Geräten die in den letzte 90 Tagen nicht benutzt wurden
$LastUsed = (Get-Date).AddDays(-90)

Get-MgDevice -All:$true | Where-Object {$_.ApproximateLastSignInDateTime -le $LastUsed} `
    | select-object -Property DisplayName, DeviceId, DeviceOSType, DeviceOSVersion, DeviceTrustType, ApproximateLastSignInDateTime `
    | Format-Table 

# ... diesmal das Ganze in ein Excelfile
Get-MgDevice -All:$true | Where-Object {$_.ApproximateLastSignInDateTime -le $LastUsed} `
    | select-object -Property DisplayName, DeviceId, DeviceOSType, DeviceOSVersion, DeviceTrustType, ApproximateLastSignInDateTime `
    | Export-Excel .\UnusedDevices.xlsx -WorksheetName "Devices" -AutoSize
