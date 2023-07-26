install-Module -Name azuread

Connect-AzureAD

Get-AzureADApplication -All:$true | Where-Object { $_.PublicClient -ne $true } | FT

Get-AzureADApplication -All:$true | fl

