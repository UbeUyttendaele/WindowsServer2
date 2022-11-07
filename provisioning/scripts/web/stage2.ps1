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
    Write-Host "-------------------------" -ForegroundColor yellow
    Write-Host "     Configuring DHCP    " -ForegroundColor yellow
    Write-Host "-------------------------" -ForegroundColor yellow
    # Installing DHCP service
    # Authorizing DHCP Server
    Write-Host "Authorizing DHCP Server" -ForegroundColor yellow
    Add-DhcpServerInDC -DnsName "web.ws2-2223-ube.hogent" -IPAddress 192.168.22.1
    # Creating a DHCP Scope
    Write-Host "Creating a DHCP Scope" -ForegroundColor yellow
    Add-DhcpServerV4Scope @Scope -ErrorAction Stop | out-null
    Set-DhcpServerV4OptionValue @GatewayOption -ErrorAction Stop | out-null
    Set-DhcpServerV4OptionValue @DNSOption -ErrorAction Stop | out-null

    Write-Host "-------------------------" -ForegroundColor yellow
    Write-Host "     Configuring DNS     " -ForegroundColor yellow
    Write-Host "-------------------------" -ForegroundColor yellow
    Write-Host "TODO" -ForegroundColor red
    Add-DnsServerSecondaryZone -MasterServers 192.168.22.1 -Name "ws2-2223-ube.hogent" -ZoneFile ws2-2223-ube.hogent -ErrorAction Stop | out-null

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
    New-WebSite -Name "webpage" -Port 80 -HostHeader "www.ws2-2223-ube.hogent" -PhysicalPath "C:\inetpub\wwwroot\webpage" -applicationpool 'webpage' -IPAddress 192.168.22.2 -ErrorAction Stop | out-null
}
catch {
    Write-Warning -Message $("(┛◉Д◉) ┛彡┻━┻: "+ $_.Exception.Message)
}


