# https://suryendub.github.io/2024-02-08-directory-extension-attribute/

Connect-MgGraph 

# Add Application
$ExtensionApp = New-MgApplication -DisplayName "Schema School Extension App"
New-MgServicePrincipal -AppId $ExtensionApp.AppId

$ExtensionProperty1 = New-MgApplicationExtensionProperty -Name "Lehrer" -DataType "String" -TargetObjects "User" -ApplicationId $ExtensionApp.Id
$ExtensionProperty2 = New-MgApplicationExtensionProperty -Name "Klasse" -DataType "String" -TargetObjects "User" -ApplicationId $ExtensionApp.Id

# get Attributes
Get-MgApplicationExtensionProperty -ApplicationId $ExtensionApp.Id | Format-Table Name, DataType, TargetObjects

# store userdata to the attributes
$UserID = "{b0c716a9-8c3d-413b-b4ae-0e05f748ca6a}"
$BodyParam = @{
    extension_b866c2c8096d4dcc9074852f531cefb1_Lehrer = "Ja"
    extension_b866c2c8096d4dcc9074852f531cefb1_Klasse = "8a"
}
Update-MgUser -UserId $UserID -BodyParameter $BodyParam 

$UserID = "{72eea6f6-8c47-49e3-86cc-1493d92a2c18}"
$BodyParam = @{
    extension_b866c2c8096d4dcc9074852f531cefb1_Lehrer = "Nein"
    extension_b866c2c8096d4dcc9074852f531cefb1_Klasse = "8a"
}
Update-MgUser -UserId $UserID -BodyParameter $BodyParam 


Disconnect-Graph
