# Einige Beispiele wie sich über die Microsoft Graph Geräte Informationen auslesen lassen
# 
# Zur Veranschaulichung die Cmdlets einzeln markieren und ausführen
#
# Für Ausgabe der Benutzer in Excel wird das Modul "ImportExcel" von Doug Finke benutzt  

# Install-Module -name microsoft.graph
# Install-Module -Name ImportExcel

################################################################################
# Die Cmdlets unten markieren und ausführen.
# Zuvor den Connect-MgGraph und die Variablen initialisieren
################################################################################

# Login/Connect
# Import-Module Microsoft.Graph
Connect-MgGraph -Scopes Device.Read.All

# Excel File
$xlsFile = Join-Path (Get-Location) 'UnusedObjects.xlsx'

# Zeitraum
$LastUsed = (Get-Date).AddDays(-90)

################################################################################
# Liste alle Geräte 
Get-MgDevice -All:$true

################################################################################
# Nur bestimmte Eigenschaften
# Get-MgDevice -All:$true `
#    | select-object -Property DisplayName, ApproximateLastSignInDateTime, DeviceId, DeviceOSType, DeviceOSVersion `
#    | Format-Table 


################################################################################
# ... gleiche Liste, aber Ausgabe diesmal direkt nach Excel 
#Get-MgDevice -All:$true `
#    | select-object -Property DisplayName, DeviceId, DeviceOSType, DeviceOSVersion, ApproximateLastSignInDateTime `
#    | Export-Excel $xlsFile -WorksheetName "Devices" -ClearSheet -AutoSize


################################################################################
#Get-MgDevice -All:$true | Where-Object {$_.ApproximateLastSignInDateTime -le $LastUsed} `
#    | select-object -Property DisplayName, DeviceId, DeviceOSType, DeviceOSVersion, DeviceTrustType, ApproximateLastSignInDateTime `
#    | Format-Table 


################################################################################
# ... diesmal das Ganze in ein Excelfile
Get-MgDevice -All:$true | Where-Object {$_.ApproximateLastSignInDateTime -le $LastUsed} `
    | select-object -Property DisplayName, DeviceId, DeviceOSType, DeviceOSVersion, DeviceTrustType, ApproximateLastSignInDateTime `
    | Export-Excel $xlsFile -WorksheetName "Devices" -ClearSheet -AutoSize 


################################################################################
Disconnect-MgGraph