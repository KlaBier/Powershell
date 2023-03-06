
Install-Module microsoft.graph.identity.signins

Connect-MgGraph -scopes UserAuthenticationMethod.ReadWrite.All

Select-MgProfile -name beta
Get-MgUserAuthenticationEmailMethod -userid wolf@kbcorp.de

# Set Phonenumber and skip initial MFA Registration
New-MgUserAuthenticationPhoneMethod -userid wolf@kbcorp.de -phoneType "mobile" -phonenumber "+4915209197024"

# Create a Temporary Access Pass for a user
$properties = @{}
$properties.isUsableOnce = $True
#$properties.startDateTime = '2022-10-18 06:00:00'
#$properties.TemporaryAccessPass = "-TAJKr4$%!+"
$propertiesJSON = $properties | ConvertTo-Json

New-MgUserAuthenticationTemporaryAccessPassMethod -UserId wolf@kbcorp.de -TemporaryAccessPass "TAPRocky" -BodyParameter $propertiesJSON | fl *


# Get a user's Temporary Access Pass
Get-MgUserAuthenticationTemporaryAccessPassMethod -UserId wolf@kbcorp.de | fl *
