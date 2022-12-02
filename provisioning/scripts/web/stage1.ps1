$WarningPreference = 'SilentlyContinue'
$dnsConfig = @{
    InterfaceAlias = "Ethernet"
    ServerAddresses = @("192.168.22.1", "192.168.22.2")
}

$InterfaceConfig = @{
    InterfaceAlias = "Ethernet"
    IPAddress = "192.168.22.2"
    PrefixLength = "24"
    DefaultGateway = "192.168.22.1"
}

$ICMP = @{
    Name = "Allow RDP"
    DisplayName = "Allow RDP"
    Description = "Allow inbound ICMPv4"
    Direction = "Inbound"
    Action = "Allow"
    Protocol = "ICMPv4"
    IcmpType = 8
}


$credential = New-object -TypeName System.Management.Automation.PSCredential -ArgumentList "Administrator", (ConvertTo-SecureString -AsPlainText "Admin2021" -Force)

$features=@(
    'DHCP',
    'Web-Server',
    'DNS'
)


try {
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "    Configuring network settings   " -ForegroundColor yellow
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "Configuring firewall" -ForegroundColor yellow
    New-NetFirewallRule @ICMP -ErrorAction Stop | out-null
    Write-Host "Creating NetIpAdress" -ForegroundColor yellow
    New-NetIPAddress @InterfaceConfig -ErrorAction Stop | out-null
    Write-Host "Setting DNS options" -ForegroundColor yellow
    Set-DnsClientServerAddress @dnsConfig -ErrorAction Stop | out-null
    sleep 5
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "        Installing features        " -ForegroundColor yellow
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "Installing, this may take a while..." -ForegroundColor yellow
    Install-WindowsFeature $features -includeManagementTools -ErrorAction Stop | out-null

    Write-Host "-------------------------" -ForegroundColor yellow
    Write-Host "     Configuring domain    " -ForegroundColor yellow
    Write-Host "-------------------------" -ForegroundColor yellow
    Write-Host "Joining domain" -ForegroundColor yellow
    Add-Computer -Domain "ws2-2223-ube.hogent" -Credential $credential -Force | out-null
}
catch {
    Write-Warning $("(Task failed: "+ $_.Exception.Message)
}