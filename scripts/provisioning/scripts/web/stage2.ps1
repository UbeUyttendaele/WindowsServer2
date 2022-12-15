#$WarningPreference = 'SilentlyContinue'
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
    DnsServer = "192.168.22.1", "192.168.22.2"
}
try {

    Write-Host "-------------------------" -ForegroundColor yellow
    Write-Host "     Configuring DNS     " -ForegroundColor yellow
    Write-Host "-------------------------" -ForegroundColor yellow
    write-host "Setting up DNS server" -ForegroundColor yellow
    Add-DnsServerSecondaryZone -MasterServers 192.168.22.1 -Name "ws2-2223-ube.hogent" -ZoneFile ws2-2223-ube.hogent -ErrorAction Stop | out-null


    Write-Host "-------------------------" -ForegroundColor yellow
    Write-Host "     Configuring DHCP    " -ForegroundColor yellow
    Write-Host "-------------------------" -ForegroundColor yellow
    Write-Host "Authorizing DHCP Server" -ForegroundColor yellow
    Add-DhcpServerInDC -DnsName "web.ws2-2223-ube.hogent" -IPAddress 192.168.22.1
    Write-Host "Creating a DHCP Scope" -ForegroundColor yellow
    Add-DhcpServerV4Scope @Scope -ErrorAction Stop | out-null
    Set-DhcpServerV4OptionValue @GatewayOption -ErrorAction Stop | out-null
    Set-DhcpServerV4OptionValue @DNSOption -ErrorAction Stop | out-null
}
catch {
    Write-Warning -Message $("(Task failed: "+ $_.Exception.Message)
}

