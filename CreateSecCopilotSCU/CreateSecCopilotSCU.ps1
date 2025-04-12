# Cmdlets below are mentioned in my blogpost xyz...

# if not already done ...
#Install-Module -Name Az -Scope CurrentUser
#Import-Module Az

#update-Module -Name Az 

Connect-AzAccount -Tenant 'YOUR TENANT ID' -SubscriptionId 'YOUR SUBSCRIPTION ID'

New-AzResourceGroup -Name "SecurityCopilotRG" -Location "WestEurope"

#This is a one time job
#Register-AzResourceProvider -ProviderNamespace "Microsoft.Security"

New-AzResource -ResourceName "SecurityCopilotSKU" `
    -ResourceType "Microsoft.SecurityCopilot/capacities" `
    -ResourceGroupName "SecurityCopilotRG" `
    -Location "westeurope" `
    -ApiVersion "2023-12-01-preview" `
    -Properties @{numberOfUnits=2; crossGeoCompute="NotAllowed"; geo="EU"}`
    -force
