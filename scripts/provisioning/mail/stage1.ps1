#-----------------------
#   Variables
#-----------------------
$WarningPreference = 'SilentlyContinue'
$dnsConfig = @{
    InterfaceAlias = "Ethernet"
    ServerAddresses = @("192.168.22.1")
}

$InterfaceConfig = @{
    InterfaceAlias = "Ethernet"
    IPAddress = "192.168.22.3"
    PrefixLength = "24"
    DefaultGateway = "192.168.22.1"
}
$credential = New-object -TypeName System.Management.Automation.PSCredential -ArgumentList "Administrator", (ConvertTo-SecureString -AsPlainText "Admin2021" -Force)

$features=@(
    'Server-Media-Foundation', 
    'NET-Framework-45-Features',
    'RPC-over-HTTP-proxy',
    'RSAT-Clustering',
    'RSAT-Clustering-CmdInterface',
    'RSAT-Clustering-PowerShell',
    'WAS-Process-Model',
    'Web-Asp-Net45',
    'Web-Basic-Auth',
    'Web-Client-Auth',
    'Web-Digest-Auth',
    'Web-Dir-Browsing',
    'Web-Dyn-Compression',
    'Web-Http-Errors',
    'Web-Http-Logging',
    'Web-Http-Redirect',
    'Web-Http-Tracing',
    'Web-ISAPI-Ext',
    'Web-ISAPI-Filter',
    'Web-Metabase',
    'Web-Mgmt-Service',
    'Web-Net-Ext45',
    'Web-Request-Monitor',
    'Web-Server',
    'Web-Stat-Compression',
    'Web-Static-Content',
    'Web-Windows-Auth',
    'Web-WMI',
    'RSAT-ADDS',
    'ADLDS'
)

try {
    
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "    Configuring network settings   " -ForegroundColor yellow
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "Creating NetIpAdress" -ForegroundColor yellow
    New-NetIPAddress @InterfaceConfig -ErrorAction Stop | out-null
    Write-Host "Setting DNS options" -ForegroundColor yellow
    Set-DnsClientServerAddress @dnsConfig -ErrorAction Stop | out-null
    Write-Host "Configuring firewall" -ForegroundColor yellow
    sleep 5
    
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "    Installing dependencies     " -ForegroundColor yellow
    Write-Host "-----------------------------------" -ForegroundColor yellow
    
    write-host "Installing windows features" -ForegroundColor yellow
    Install-WindowsFeature $features -includeManagementTools -ErrorAction Stop | out-null
    write-host "Installing .NET 4.8" -ForegroundColor yellow
    curl https://download.visualstudio.microsoft.com/download/pr/014120d7-d689-4305-befd-3cb711108212/0fd66638cde16859462a6243a4629a50/ndp48-x86-x64-allos-enu.exe -o ndp48-x86-x64-allos-enu.exe 
    Start-Process "ndp48-x86-x64-allos-enu.exe" -argumentlist "/install /quiet /norestart" -wait
    
    write-host "Installing Visual c++ 2013" -ForegroundColor yellow
    curl https://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x64.exe -o 2013setup.exe
    Start-Process "2013setup.exe" -argumentlist "/install /quiet /norestart" -wait
    
    write-host "Installing Visual c++ 2012" -ForegroundColor yellow
    curl https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe -o 2012setup.exe
    Start-Process "2012setup.exe" -argumentlist "/install /quiet /norestart" -wait

    write-host "Installing rewrite module" -ForegroundColor yellow
    curl https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi -o rewrite_amd64_en-US.msi
    Start-Process msiexec -argumentlist "/i rewrite_amd64_en-US.msi /norestart" -wait

    write-host "Preparing exchange" -ForegroundColor yellow
    F:\ucmaredist\Setup.exe -q -wait

    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "        Configuring domain         " -ForegroundColor yellow
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "Joining domain" -ForegroundColor yellow
    Add-Computer -Domain "ws2-2223-ube.hogent" -Credential $credential -Force | out-null
}
catch {
    Write-Host $("(Task failed: "+ $_.Exception.Message) -ForegroundColor red
}