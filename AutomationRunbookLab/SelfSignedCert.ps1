
# Certificate and export self cert certificate
# Details are shown here: https://learn.microsoft.com/en-us/azure/active-directory/develop/howto-create-self-signed-certificate

$certname = "Automation"
$cert = New-SelfSignedCertificate -Subject "CN=$certname" -CertStoreLocation "Cert:\CurrentUser\My"`
    -KeyExportPolicy Exportable -KeySpec Signature -KeyLength 2048 -KeyAlgorithm RSA -HashAlgorithm SHA256

Export-Certificate -Cert $cert -FilePath ".\$certname.cer"

$mypwd = ConvertTo-SecureString -String "password" -Force -AsPlainText

Export-PfxCertificate -Cert $cert -FilePath ".\$certname.pfx" -Password $mypwd

#$cert | ft Thumbprint
