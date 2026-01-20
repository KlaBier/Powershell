# Cmdlets below are mentioned in my blogpost: 
# "Security Copilot - quickly turned on and off"
# https://nothingbutcloud.net/2025-01-16-SCU_ON_OFF/

# The module needs to be imported beforehand ...

#Install-Module -Name Az -Scope CurrentUser
#Import-Module Az

Connect-AzAccount -Tenant 'YOUR TENANT ID' -SubscriptionId 'YOUR SUBSCRIPTION ID'

New-AzResourceGroup -Name "SecurityCopilotRG" -Location "WestEurope"

#This is a one time job
#Register-AzResourceProvider -ProviderNamespace "Microsoft.Security"

New-AzResource -ResourceName "SecurityCopilotSCU" `
    -ResourceType "Microsoft.SecurityCopilot/capacities" `
    -ResourceGroupName "SecurityCopilotRG" `
    -Location "westeurope" `
    -ApiVersion "2023-12-01-preview" `
    -Properties @{numberOfUnits=2; crossGeoCompute="NotAllowed"; geo="EU"}`
    -force
