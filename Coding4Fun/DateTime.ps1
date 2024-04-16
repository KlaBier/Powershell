# test with d_t
$time = [DateTime]::UtcNow | get-date -Format "yyyy-MM-ddTHH:mm:fZ"

$time

FormatDateTime($time, , "yyyy-MM-ddzzz", "yyyyMMddHHmmss.fZ")

‘20221101010000.0Z’

[DateTime]::UtcNow

[DateTime]

Install-Modulae -name microsoft.graph

# Login/Connect to MS Graph
Connect-MgGraph -Scopes 'Application.Read.All'

Import-Module Microsoft.Graph.Applications

Get-MgUserAppRoleAssignment -UserId 93e77d38-5344-4481-8dd9-4cb19a23bca0

Get-GraphAppRoleAssignment -UserId 93e77d38-5344-4481-8dd9-4cb19a23bca0



