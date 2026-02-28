# Einige Beispiele wie sich über die Microsoft Graph Geräte Informationen auslesen lassen
# 
# Zur Veranschaulichung die Cmdlets einzeln markieren und ausführen.
#
# Für Ausgabe der Benutzer in Excel wird das Modul "ImportExcel" von Doug Finke benutzt  

# Install-Module -name microsoft.graph
# Install-Module -Name ImportExcel

################################################################################
# Die Cmdlets unten markieren und ausführen.
# Zuvor den Connect-MgGraph und die Variablen initialisieren
################################################################################

# Excel File
$xlsFile = Join-Path (Get-Location) 'UnusedObjects.xlsx'

# Login/Connect
Connect-MgGraph -Scopes "Application.Read.All","Directory.Read.All"

$Apps = Get-MgApplication -All -Property Id,AppId,DisplayName,PasswordCredentials

$Results = foreach ($App in $Apps) {

    $OwnerObjects = Get-MgApplicationOwner -ApplicationId $App.Id -All

    if (-not $OwnerObjects) {
        $OwnerValue = "NO OWNER"
    }
    else {
        $OwnerValue = ($OwnerObjects | ForEach-Object {
            if ($_.AdditionalProperties.userPrincipalName) {
                $_.AdditionalProperties.userPrincipalName
            }
            elseif ($_.AdditionalProperties.displayName) {
                $_.AdditionalProperties.displayName
            }
            else {
                "UnknownOwnerType"
            }
        }) -join "; "
    }

    if ($App.PasswordCredentials.Count -gt 0) {
        foreach ($Secret in $App.PasswordCredentials) {
            [pscustomobject]@{
                DisplayName     = $App.DisplayName
                AppId           = $App.AppId
                Owner           = $OwnerValue
                SecretId        = $Secret.KeyId
                SecretStartDate = $Secret.StartDateTime
                SecretEndDate   = $Secret.EndDateTime
            }
        }
    }
    else {
        [pscustomobject]@{
            DisplayName     = $App.DisplayName
            AppId           = $App.AppId
            Owner           = $OwnerValue
            SecretId        = "NO SECRET"
            SecretStartDate = $null
            SecretEndDate   = $null
        }
    }
}

$Results | Export-Excel ".\UnusedObjects.xlsx" -WorksheetName "OwnApps" -AutoSize -ClearSheet

Disconnect-Graph

