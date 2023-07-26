# required module
Install-Module Microsoft.Graph

Connect-MgGraph -Scopes 'User.Read.All'
Get-MgUser -ConsistencyLevel eventual -Count userCount -Filter "startsWith(DisplayName, 'a')" -Top 1

Get-MgUser -ConsistencyLevel eventual -Count userCount


Get-MgUser -UserId "AdeleV@kbcorp2021.onmicrosoft.com"| Select-Object *
