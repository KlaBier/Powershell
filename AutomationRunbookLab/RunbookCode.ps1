$ClientId = Get-AutomationVariable -Name 'ClientId'
$TenantId = Get-AutomationVariable -Name 'TenantId'
$StorageAccountName = Get-AutomationVariable -Name 'storagename'
$StorageContainerName = Get-AutomationVariable -Name 'storagecontainer'
$StorageKey = Get-AutomationVariable -Name 'storagekey'


# Get the certificate which is stored in automation
$certificateName = "automationcert"
$certificate = Get-AutomationCertificate -Name $certificateName

Connect-MgGraph -clientId $ClientId -tenantId $TenantId -certificatethumbprint $certificate.Thumbprint

$date = (Get-Date (Get-Date).AddDays(-90) -Format u).Replace(' ','T')

$currentDateTime = get-date
$ExcelFile = (get-date).ToString("yyyy-MM-dd_HH-mm-ss") + "-UnusedObjects.xlsx"

# ... und das ganze selektiert vor einem Zeitpunkt
Get-MgUser -Filter "signInActivity/lastSignInDateTime le $date" `
    -Property UserprincipalName,Displayname,CreatedDateTime, SignInActivity `
    | Select-Object DisplayName, 
            @{N="Last SignIn";E={$_.SignInActivity.LastSignInDateTime}}, `
            UserPrincipalName,`
            CreatedDateTime `
    | Export-Excel $ExcelFile -WorksheetName "Unused user" -AutoSize

$LastUsed = (Get-Date).AddDays(-90)

Get-MgDevice -All:$true | Where-Object {$_.ApproximateLastSignInDateTime -le $LastUsed} `
    | select-object -Property DisplayName, DeviceId, DeviceOSType, DeviceOSVersion, DeviceTrustType, ApproximateLastSignInDateTime `
    | Export-Excel $ExcelFile -WorksheetName "Stale devices" -AutoSize

Connect-AzAccount -ServicePrincipal -TenantId $tenantid -ApplicationId $clientid -CertificateThumbprint $certificate.Thumbprint

$context = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $StorageKey

$storageContext = New-AzStorageContext -StorageAccountName $storageAccountName -UseConnectedAccount

Set-AzStorageBlobContent -Context $context -Container $StorageContainerName -Blob $ExcelFile -File $ExcelFile -StandardBlobTier cool -Force

Disconnect-AzAccount -Scope Process

Disconnect-Graph
