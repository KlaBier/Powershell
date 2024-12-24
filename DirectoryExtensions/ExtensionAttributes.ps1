# Additional infos here:
# https://suryendub.github.io/2024-02-08-directory-extension-attribute/

Connect-MgGraph 

# Add Application
$ExtensionApp = New-MgApplication -DisplayName "Schema School Extension App"
New-MgServicePrincipal -AppId $ExtensionApp.AppId

# Oder Application ermitteln um weitere Attribute hinzuzufügen
$ExtensionApp = Get-MgApplication -Filter "AppId eq 'b866c2c8-096d-4dcc-9074-852f531cefb1'"

$ExtensionProperty1 = New-MgApplicationExtensionProperty -Name "Lehrer" -DataType "String" -TargetObjects "User" -ApplicationId $ExtensionApp.Id
$ExtensionProperty2 = New-MgApplicationExtensionProperty -Name "Klasse" -DataType "String" -TargetObjects "User" -ApplicationId $ExtensionApp.Id
$ExtensionProperty3 = New-MgApplicationExtensionProperty -Name "PERSONA" -DataType "String" -TargetObjects "User" -ApplicationId $ExtensionApp.Id

# Zeige mir zugeordnete Attribute
Get-MgApplicationExtensionProperty -ApplicationId $ExtensionApp.Id | Format-Table Name, DataType, TargetObjects


$user = Get-MgUser -Userid "DiegoS@kbcorp2021.onmicrosoft.com"
$userId = $user.Id

# store userdata to the attributes
#$UserID = "{b0c716a9-8c3d-413b-b4ae-0e05f748ca6a}"
$BodyParam = @{
    extension_b866c2c8096d4dcc9074852f531cefb1_Lehrer = "Ja"
    extension_b866c2c8096d4dcc9074852f531cefb1_Klasse = "8a"
    extension_b866c2c8096d4dcc9074852f531cefb1_PERSONA = "PERSONA_Admin"
}
Update-MgUser -UserId $UserID -BodyParameter $BodyParam 

$user = Get-MgUser -Userid "GradyA@kbcorp2021.onmicrosoft.com"
$userId = $user.Id

#$UserID = "{72eea6f6-8c47-49e3-86cc-1493d92a2c18}"
$BodyParam = @{
    extension_b866c2c8096d4dcc9074852f531cefb1_Lehrer = "Nein"
    extension_b866c2c8096d4dcc9074852f531cefb1_Klasse = "8a"
    extension_b866c2c8096d4dcc9074852f531cefb1_PERSONA = "PERSONA_Admin"    
}
Update-MgUser -UserId $UserID -BodyParameter $BodyParam 


# Extensionattribute auslesen

Disconnect-Graph
