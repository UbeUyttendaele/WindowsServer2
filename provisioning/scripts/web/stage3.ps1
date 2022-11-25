#$WarningPreference = 'SilentlyContinue'
$CertName="www.ws2-2223-ube.hogent"
$INF = @"
    [Version]
    Signature= "$Signature" 
    [NewRequest]
    Subject = "CN=$CertName, OU=Hogent-ws, O=Hogent, L=Gent, S=Oost-Vlaanderen, C=Belgie"
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
    KeyUsage = 0xa0
    [EnhancedKeyUsageExtension]
    OID=1.3.6.1.5.5.7.3.1 
"@

$credential = New-object -TypeName System.Management.Automation.PSCredential -ArgumentList "Administrator", (ConvertTo-SecureString -AsPlainText "Admin2021" -Force)

$CertFolder = "cert:\LocalMachine\My"
$CSRPath = "$CertFolder\$($CertName).csr"
$INFPath = "$CertFolder\$($CertName).inf"
$Signature = '$Windows NT$' 

try {

    Write-Host "-------------------------" -ForegroundColor yellow
    Write-Host "  Generating certificate " -ForegroundColor yellow
    Write-Host "-------------------------" -ForegroundColor yellow

    if (!(Test-Path $CertFolder)) {
        New-Item -Path $CertFolder -Type Directory | out-null
    }

    Write-Host "Creating CertificateRequest(CSR) for $CertName" -ForegroundColor yellow
    if (!(test-path $CSRPath)) {
    $INF | out-file -filepath $INFPath -force
    & certreq.exe -new $INFPath $CSRPath
    }
    Write-Host "Certificate Request has been generated" -ForegroundColor yellow

    Write-Host "-------------------------" -ForegroundColor yellow
    Write-Host "  Configuring webserver  " -ForegroundColor yellow
    Write-Host "-------------------------" -ForegroundColor yellow
    Write-Host "Removing default website" -ForegroundColor yellow
    Remove-Website -Name Default* -ErrorAction Stop | out-null
    Remove-WebAppPool -Name Default* -ErrorAction Stop | out-null
    Remove-Item 'C:\inetpub\wwwroot\iis*' -ErrorAction Stop | out-null
    Write-Host "Copying webpage to destination" -ForegroundColor yellow
    Copy-Item 'C:\scripts\web\webpage' -Destination 'C:\inetpub\wwwroot\webpage' -Recurse -ErrorAction Stop | out-null


    Write-Host "Creating WebAppPool" -ForegroundColor yellow
    New-WebAppPool -Name webpage -ErrorAction Stop | out-null
    Write-Host "Creating Website" -ForegroundColor yellow
    New-WebSite -Name "webpage" -port 443 -PhysicalPath "C:\inetpub\wwwroot\webpage" -ErrorAction Stop | out-null

    $binding = Get-WebBinding -Name webpage -Protocol "https"
    $binding.AddSslCertificate($CSRPath.GetCertHashString(), "my")
    #New-WebBinding -Name "webpage" -IP "*" -Port 443 -Protocol https
    #get-item $CSRPath | new-item 0.0.0.0!443
}
catch {
    Write-Warning -Message $("(Task failed: "+ $_.Exception.Message)
}

