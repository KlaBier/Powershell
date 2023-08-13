###############################################################################################
# Die Beispiele unten zeigen wie sich anhand der "ApproximateLastLogonTimestamp"
# ermitteln lässt, wann ein Gerät im AAD zuletzt verwendet wurde, also wann es zuletzt zum Zugriff
# auf die MS Cloud benutzt worden ist
# 
# Das Script ist nicht als Ganzes lauffähig. Das sind Beispiele, die als Anregung für eigene 
# Entwicklungen dienen sollen.
#
# HINWEIS:
# Das Cmdlet "Get-AzureADDevice" ist aus dem Powershell Module "AzureAD"
# Dieses ist von Microsoft abgekündigt. Es funktioniert zwar noch,
# aber es ist besser die Befehle aus den Microsoft Graph Modulen zu benutzen.
# Siehe separates Beispiel in "FindStaledDevices_ModuleMSGraph.ps1"
#
# Allgemeine Beschreibung hierzu:
# https://learn.microsoft.com/en-us/azure/active-directory/fundamentals/what-is-deprecated
#
# Informationen zur Migration:
# https://learn.microsoft.com/en-us/powershell/microsoftgraph/migration-steps?view=graph-powershell-1.0
#
# Gegenüberstellung von Cmdlets aus dem Module AzureAD zu einem Equivalent in der Microsoft Graph Powershell
# https://learn.microsoft.com/en-us/powershell/microsoftgraph/azuread-msoline-cmdlet-map?view=graph-powershell-1.0
###############################################################################################

# Connnect to tenant
Connect-AzureAD

# Liste alle Geräte 
Get-AzureADDevice -All:$true `
    | select-object -Property DisplayName, DeviceId, DeviceOSType, DeviceOSVersion, ApproximateLastLogonTimestamp `
    | Format-Table 

# ... gleiche Liste, aber Ausgabe in eine CSV
Get-AzureADDevice -All:$true `
    | select-object -Property DisplayName, DeviceId, DeviceOSType, DeviceOSVersion, ApproximateLastLogonTimestamp `
    | export-csv .\UnusedDevices.csv -NoTypeInformation


# ... gleiche Liste, aber Ausgabe diesmal direkt in eine Excel Tabelle mit den Excel Powershell Module von Doug Finke
Install-Module -Name ImportExcel

Get-AzureADDevice -All:$true `
    | select-object -Property DisplayName, DeviceId, DeviceOSType, DeviceOSVersion, ApproximateLastLogonTimestamp `
    | Export-Excel .\UnusedDevices.xlsx -WorksheetName "Devices" -AutoSize

# Erstelle eine Liste mit Geräten die in den letzte 90 Tagen nicht benutzt wurden
# und schreibe die Ausgabe direkt in eine Excel Tabelle
$LastUsed = (Get-Date).AddDays(-90)

Get-AzureADDevice -All:$true | Where-Object {$_.ApproximateLastLogonTimeStamp -le $LastUsed} `
    | select-object -Property DisplayName, DeviceId, DeviceOSType, DeviceOSVersion, DeviceTrustType, ApproximateLastLogonTimestamp `
    | Format-Table 

Get-AzureADDevice -All:$true | Where-Object {$_.ApproximateLastLogonTimeStamp -le $LastUsed} `
    | select-object -Property DisplayName, DeviceId, DeviceOSType, DeviceOSVersion, DeviceTrustType, ApproximateLastLogonTimestamp `
    | Export-Excel .\UnusedDevices.xlsx -WorksheetName "Devices" -AutoSize
