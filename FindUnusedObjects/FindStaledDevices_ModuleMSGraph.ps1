###############################################################################################
# Die Beispiele unten zeigen wie sich anhand der "ApproximateLastSignInDateTime"
# ermitteln lässt, wann ein Gerät im AAD zuletzt verwendet wurde, also wann es zuletzt zum Zugriff
# auf die MS Cloud benutzt worden ist
#
# Es ist sinnvoll nur noch Cmdlets aus dem Microsoft Graph Modul zu benutzen und nicht mehr "AzureAD"
# Für eine Migration der Cmdlets aus dem AzureAD- oder dem MSOnline Modul empfiehlt sich folgender Link
# https://learn.microsoft.com/en-us/powershell/microsoftgraph/azuread-msoline-cmdlet-map?view=graph-powershell-1.0
#
# An dem Beispiel für das Ermitteln ungenutzter Geräteobjekte hat sich lediglich das Cmdlet geändert
# und das "Property", das zur Abfrage des Datum der letzten Verwendung dient, ist in der
# Microsoft Graph "ApproximateLastSignInDateTime" und nicht mehr ApproximateLastLogonTimestamp
###############################################################################################

# Login/Connect
Connect-MgGraph -Scopes 'Device.Read.All'

# Zeige alle Geräte 
Get-MgDevice -All:$true

# Nur bestimmte Eigenschaften
Get-MgDevice -All:$true `
    | select-object -Property DisplayName, DeviceId, DeviceOSType, DeviceOSVersion, ApproximateLastSignInDateTime `
    | Format-Table 

# ... gleiche Liste, aber Ausgabe in eine CSV
Get-MgDevice -All:$true `
    | select-object -Property DisplayName, DeviceId, DeviceOSType, DeviceOSVersion, ApproximateLastSignInDateTime `
    | export-csv .\UnusedDevices.csv -NoTypeInformation


# ... gleiche Liste, aber Ausgabe diesmal direkt in eine Excel Tabelle mit den Excel Powershell Module von Doug Finke
Install-Module -Name ImportExcel

Get-MgDevice -All:$true `
    | select-object -Property DisplayName, DeviceId, DeviceOSType, DeviceOSVersion, ApproximateLastSignInDateTime `
    | Export-Excel .\UnusedDevices.xlsx -WorksheetName "Devices" -AutoSize

# Erstelle eine Liste mit Geräten die in den letzte 90 Tagen nicht benutzt worden sind
# und schreibe die Ausgabe direkt in eine Excel Tabelle
$LastUsed = (Get-Date).AddDays(-90)

Get-MgDevice -All:$true | Where-Object {$_.ApproximateLastSignInDateTime -le $LastUsed} `
    | select-object -Property DisplayName, DeviceId, DeviceOSType, DeviceOSVersion, DeviceTrustType, ApproximateLastSignInDateTime `
    | Format-Table 

Get-MgDevice -All:$true | Where-Object {$_.ApproximateLastSignInDateTime -le $LastUsed} `
    | select-object -Property DisplayName, DeviceId, DeviceOSType, DeviceOSVersion, DeviceTrustType, ApproximateLastSignInDateTime `
    | Export-Excel .\UnusedDevices.xlsx -WorksheetName "Devices" -AutoSize
