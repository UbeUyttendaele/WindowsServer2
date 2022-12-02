#-----------------------
#   Variables
#-----------------------
$WarningPreference = 'SilentlyContinue'
$dnsConfig = @{
    InterfaceAlias = "Ethernet"
    ServerAddresses = @("192.168.22.1", "192.168.22.2")
}

$InterfaceConfig = @{
    InterfaceAlias = "Ethernet"
    IPAddress = "192.168.22.3"
    PrefixLength = "24"
    DefaultGateway = "192.168.22.1"
}
$credential = New-object -TypeName System.Management.Automation.PSCredential -ArgumentList "Administrator", (ConvertTo-SecureString -AsPlainText "Admin2021" -Force)

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
    Write-Host "        Configuring domain         " -ForegroundColor yellow
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "Joining domain" -ForegroundColor yellow
    Add-Computer -Domain "ws2-2223-ube.hogent" -Credential $credential -Force | out-null
}
catch {
    Write-Host $("(Task failed: "+ $_.Exception.Message) -ForegroundColor red
}