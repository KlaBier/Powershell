# Quick delete the entire RG with the associated SCU

Connect-AzAccount -Tenant 'YOUR TENANT ID' -SubscriptionId 'YOUR SUBSCRIPTION ID'

Remove-AzResourceGroup -Name "SecurityCopilotRG" -force
