# For details check
# "Security Copilot - quickly turned on and off"
# https://nothingbutcloud.net/2025-01-16-SCU_ON_OFF/

# Connect to the correct tenant and subscription
Connect-AzAccount -Tenant 'YOUR TENANT ID' -SubscriptionId 'YOUR SUBSCRIPTION ID'

# Resource Group for Security Copilot capacity
New-AzResourceGroup -Name "SecurityCopilotRG" -Location "WestEurope"

# One-time operation per subscription
# Depending on Tenant rollout stage, either Microsoft.Security OR Microsoft.SecurityCopilot may be required
#Register-AzResourceProvider -ProviderNamespace "Microsoft.Security"
#Register-AzResourceProvider -ProviderNamespace "Microsoft.SecurityCopilot"

# Create a Security Copilot capacity (SCU)

New-AzResource -ResourceName "SecurityCopilotSCU" `
    -ResourceType "Microsoft.SecurityCopilot/capacities" `
    -ResourceGroupName "SecurityCopilotRG" `
    -Location "westeurope" `
    -ApiVersion "2023-12-01-preview" `
    -Properties @{numberOfUnits=2; crossGeoCompute="NotAllowed"; geo="EU"}`
    -force

# Important: delete the SCU or the entire resource group afterwards to avoid costs
# DeleteSecCopilotSCU.ps1
