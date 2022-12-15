#$WarningPreference = 'SilentlyContinue'
$CertName="www.ws2-2223-ube.hogent"
$Signature = '$Windows NT$' 
$INF = @"
    [Version]
    Signature= "$Signature" 
    [NewRequest]
    Subject = "CN=$CertName"
    KeySpec = 1
    KeyLength = 2048
    Exportable = TRUE
    MachineKeySet = TRUE
    SMIME = False
    PrivateKeyArchive = FALSE
    UserProtected = FALSE
    UseExistingKeySet = FALSE
    ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
    ProviderType = 12
    RequestType = PKCS10
    [Extensions]
    2.5.29.17 = "{text}dns=www.ws2-2223-ube.hogent"
    [RequestAttributes]
    CertificateTemplate=WebServer
    [EnhancedKeyUsageExtension]
    OID=1.3.6.1.5.5.7.3.1 
"@

$credential = New-object -TypeName System.Management.Automation.PSCredential -ArgumentList "Administrator", (ConvertTo-SecureString -AsPlainText "Admin2021" -Force)

$CertFolder = "C:\certs"
$CSRPath = "$CertFolder\$($CertName).csr"
$INFPath = "$CertFolder\$($CertName).inf"
$certPath = "$CertFolder\$($CertName).cer"

try {

    Write-Host "-------------------------" -ForegroundColor yellow
    Write-Host "  Generating certificate " -ForegroundColor yellow
    Write-Host "-------------------------" -ForegroundColor yellow
    Write-Host "Requesting certificate" -ForegroundColor yellow
    if (!(Test-Path $CertFolder)) {
        New-Item -Path $CertFolder -Type Directory | out-null
    }
    if (!(test-path $CSRPath)) {
    $INF | out-file -filepath $INFPath -force
    & certreq.exe -new $INFPath $CSRPath
    }

    certreq.exe -submit $CSRPath $certPath
    Import-certificate -filepath $certPath -certstorelocation Cert:\Localmachine\My
    $cert = Get-ChildItem -path Cert:\LocalMachine\My | where {$_.Subject -like "*$CertName*"}
    $thumbprint = $cert.thumbprint
    

    Write-Host "-------------------------" -ForegroundColor yellow
    Write-Host "  Configuring webserver  " -ForegroundColor yellow
    Write-Host "-------------------------" -ForegroundColor yellow
    Write-Host "Removing default website" -ForegroundColor yellow
    stop-IISSite -name "Default Web Site" -ErrorAction Stop | out-null
    Remove-IISSite -Name 'Default Web Site' -Confirm:$false -ErrorAction Stop | out-null

    Write-Host "Copying webpage to destination" -ForegroundColor yellow
    Copy-Item 'C:\scripts\web\webpage' -Destination 'C:\inetpub\wwwroot\webpage' -Recurse -ErrorAction Stop | out-null

    #Write-Host "Creating WebAppPool" -ForegroundColor yellow
    #New-WebAppPool -Name webpage -force -ErrorAction Stop | out-null

    Write-Host "Creating Website" -ForegroundColor yellow
    New-IISSite -Name "webpage" -PhysicalPath "C:\inetpub\wwwroot\webpage" -BindingInformation "*:443:" -CertificateThumbPrint $thumbprint -CertStoreLocation "Cert:\Localmachine\My" -Protocol https
    start-IISSite -name "webpage" -ErrorAction Stop

    #Write-Host "Configuring binding" -ForegroundColor yellow
    #New-IISSiteBinding -Name "webpage" -BindingInformation "*:443:" -CertificateThumbPrint $thumbprint -CertStoreLocation Cert:\Localmachine\My -Protocol https
}
catch {
    Write-Warning -Message $("(Task failed: "+ $_.Exception.Message)
}

