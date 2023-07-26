
Install-Module microsoft.graph.identity.signins

Connect-MgGraph -scopes UserAuthenticationMethod.ReadWrite.All

Select-MgProfile -name beta
Get-MgUserAuthenticationEmailMethod -userid AdeleV@kbcorp2021.onmicrosoft.com

# Set Phonenumber and skip initial MFA Registration
New-MgUserAuthenticationPhoneMethod -userid AdeleV@kbcorp2021.onmicrosoft.com -phoneType "mobile" -phonenumber "+4915209197024"

# Create a Temporary Access Pass for a user
$properties = @{}
$properties.isUsableOnce = $True
#$properties.startDateTime = '2022-10-18 06:00:00'
#$properties.TemporaryAccessPass = "-TAJKr4$%!+"
$propertiesJSON = $properties | ConvertTo-Json

New-MgUserAuthenticationTemporaryAccessPassMethod -UserId AdeleV@kbcorp2021.onmicrosoft.com -TemporaryAccessPass "TAPRocky" -BodyParameter $propertiesJSON | Format-List *


# Get a user's Temporary Access Pass
Get-MgUserAuthenticationTemporaryAccessPassMethod -UserId AdeleV@kbcorp2021.onmicrosoft.com | format-list *
