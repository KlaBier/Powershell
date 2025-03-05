$tenantPath = './TenantBackup'
$tenantId = 'f5c07476-f2f0-45bf-8745-34a90b6a2a1d'
Write-Host 'git checkout main...'
# git config --global core.longpaths true #needed for Windows
# git checkout main

Write-Host 'Clean git folder...'
# Remove-Item $tenantPath -Force -Recurse

Write-Host 'Installing modules...'
Install-Module Microsoft.Graph.Authentication -Scope CurrentUser -Force
Install-Module EntraExporter -Scope CurrentUser -Force

Write-Host 'Connecting...'
Connect-EntraExporter -TenantId $tenantId

Write-Host 'Starting backup...'
Export-Entra $tenantPath -All