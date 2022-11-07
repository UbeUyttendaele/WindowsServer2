#-----------------------
#   Variables
#-----------------------
$WarningPreference = 'SilentlyContinue'
$dhcpInterface = (Get-NetIpaddress -IpAddress 10.0.2.15).InterfaceAlias

if ($dhcpInterface -like "Ethernet") {
    $interface = "Ethernet 2"
}
else {
    $interface = "Ethernet"
}

$dnsConfig = @{
    InterfaceAlias = $interface
    ServerAddresses = @("192.168.22.1", "192.168.22.2")
}

$InterfaceConfig = @{
    InterfaceAlias = $interface
    IPAddress = "192.168.22.1"
    PrefixLength = "24"
}

$features=@(
    'AD-Domain-Services',
    'RemoteAccess',
    'Routing',
    'Adcs-Cert-Authority'
)

#-----------------------
#   Configure network
#-----------------------
try {
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "    Configuring network settings   " -ForegroundColor yellow
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "Creating NetIpAdress" -ForegroundColor yellow
    New-NetIPAddress @InterfaceConfig -ErrorAction Stop | out-null
    Write-Host "Setting DNS options" -ForegroundColor yellow
    Set-DnsClientServerAddress @dnsConfig -ErrorAction Stop | out-null
    Write-Host "Configuring firewall" -ForegroundColor yellow
    Set-NetFirewallProfile -Enabled False

    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "        Installing features        " -ForegroundColor yellow
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "Installing, this may take a while..." -ForegroundColor yellow
    Install-WindowsFeature $features -includeManagementTools -ErrorAction Stop | out-null
}
catch {
    Write-Host $("(┛◉Д◉) ┛彡┻━┻: "+ $_.Exception.Message) -ForegroundColor red
}