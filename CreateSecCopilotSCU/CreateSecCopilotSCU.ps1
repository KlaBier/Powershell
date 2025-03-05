# Cmdlets below are mention in my blogpost xyz...

TmpSecCopilot

# if required ...
Install-Module -Name Az -Scope CurrentUser
Import-Module Az

update-Module -Name Az 

Connect-AzAccount

New-AzResourceYGroup -Name "SecurityCopilotRG" -Location "WestEurope"

New-AzResource -ResourceName "SecurityCopilotSKU" `
               -ResourceType "Microsoft.Security/securityCopilot" `
               -ResourceGroupName "SecurityCopilotRG" `
               -Location "WestEurope" `
               -ApiVersion "2023-12-01-preview" `
               -Properties @{
                   "sku" = @{
                       "name" = "SCUStandard"
                   }
               }


New-AzResource -ResourceName "SecurityCopilotSKU" `
    -ResourceType "Microsoft.SecurityCopilot/capacities" `
    -ResourceGroupName "SecurityCopilotRG" `
    -Location "westeurope" `
    -ApiVersion "2023-12-01-preview" `
    -Properties @{numberOfUnits=1; crossGeoCompute="NotAllowed"; geo="EU"}


               Get-AzSubscription

Set-AzContext -SubscriptionId 7588d4c4-8fd2-415f-a62b-cdd52769f9cc


Register-AzProviderFeature -FeatureName "SecurityCopilot" -ProviderNamespace "Microsoft.SecurityCopilot/capacities"
Register-AzResourceProvider -ProviderNamespace "Microsoft.Security"
