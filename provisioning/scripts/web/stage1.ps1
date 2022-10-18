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

$FirewallRule = @{
    Name = "Allow RDP"
    DisplayName = "Allow RDP"
    Description = "Allow inbound ICMPv4"
    Direction = "Inbound"
    Action = "Allow"
    Protocol = "ICMPv4"
    IcmpType = 8
}

$Scope = @{
    Name = 'DHCP'
    StartRange = '192.168.22.101'
    EndRange = '192.168.22.150'
    subnetmask = '255.255.255.0'
    State = 'Active'
    LeaseDuration = '1.00:00:00'
}
$GatewayOption = @{
    ScopeID = "192.168.22.0"
    OptionID = 3
    Value = "192.168.22.1"
}
$DNSOption = @{
    ScopeID = "192.168.22.0"
    DnsDomain = "ws2-2223-ube.hogent"
    DnsServer = "192.168.22.1"#, "192.168.22.2"
}


try {
    Write-Host "Configuring network settings." -ForegroundColor Green
    New-NetFirewallRule @firewallRule -ErrorAction Stop | out-null
    New-NetIPAddress @InterfaceConfig -ErrorAction Stop | out-null
    Set-DnsClientServerAddress @dnsConfig -ErrorAction Stop | out-null
    sleep 5
}
catch {
    Write-Warning -Message $("Task failed: "+ $_.Exception.Message)
}

try {
    Write-Host "Copying scripts to C drive" -ForegroundColor Green
    Copy-Item -Path "Z:\Scripts" -Destination "C:\Scripts" -Recurse -ErrorAction Stop
}
catch {
    Write-Warning -Message $("Task failed: "+ $_.Exception.Message)
}

try {
    Write-Host "Configuring DHCP" -ForegroundColor Green
    Install-WindowsFeature -Name 'DHCP' -IncludeManagementTools -ErrorAction Stop
    netsh dhcp add securitygroups
    Restart-Service -Name 'dhcpserver'
    Add-DhcpServerV4Scope @Scope -ErrorAction Stop
    Set-DhcpServerV4OptionValue @GatewayOption -ErrorAction Stop
    Set-DhcpServerV4OptionValue @DNSOption -ErrorAction Stop
}
catch {
    Write-Warning -Message $("Task failed: "+ $_.Exception.Message)
}

try {
    Write-Host "Joining domain" -ForegroundColor Green
    $credential = New-object -TypeName System.Management.Automation.PSCredential -ArgumentList "admin", (ConvertTo-SecureString -AsPlainText "Admin2021" -Force)
    Add-Computer -Domain "ws2-2223-ube.hogent" -Credential $credential -Restart -Force
}
catch {
    Write-Warning -Message $("Task failed: "+ $_.Exception.Message)
}