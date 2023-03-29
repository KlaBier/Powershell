# Please find the script below not as a single script which can run entirely
# it is rather a set of individual cmdlets that serve as an example

# Connnect to tenant
Connect-AzureAD

# create list with all devices 
Get-AzureADDevice -All:$true | select-object -Property AccountEnabled, DeviceId, DeviceOSType, DeviceOSVersion, DisplayName, DeviceTrustType, ApproximateLastLogonTimestamp | Format-Table 

# ... same list, but output to CSV
Get-AzureADDevice -All:$true | select-object -Property AccountEnabled, DeviceId, DeviceOSType, DeviceOSVersion, DisplayName, DeviceTrustType, ApproximateLastLogonTimestamp | export-csv .\UnusedDevices.csv -NoTypeInformation


# ... same list, but output directly to Excel Spreadsheet, using the Excel Powershedll Module Cmdlets from Doug Finke
Install-Module -Name ImportExcel
Get-AzureADDevice -All:$true | select-object -Property AccountEnabled, DeviceId, DeviceOSType, DeviceOSVersion, DisplayName, DeviceTrustType, ApproximateLastLogonTimestamp | Export-Excel .\UnusedDevices.xlsx -TableName Devices -AutoSize


# Obtain a list of devices that has not been used for a specific timeframe (e.g. 90 days)
# and put it into an Excel Spreadsheet
$LastUsed = (Get-Date).AddDays(90)

Get-AzureADDevice -All:$true | Where {$_.ApproximateLastLogonTimeStamp -le $LastUsed} `
| select-object -Property AccountEnabled, DeviceId, DeviceOSType, DeviceOSVersion, DisplayName, DeviceTrustType, ApproximateLastLogonTimestamp `
| Export-Excel .\UnusedDevices.xlsx -TableName Devices -AutoSize
