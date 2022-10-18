#Variables
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

# Set ip address of the second interface to 192.168.22.1
try {
    Write-Host "Configuring network settings." -ForegroundColor Green
    New-NetIPAddress @InterfaceConfig -ErrorAction Stop | out-null
    Set-DnsClientServerAddress @dnsConfig -ErrorAction Stop | out-null
    sleep 5
    Write-Host "Configured network settings" -ForegroundColor Green
}
catch {
    Write-Warning -Message $("Task failed:"+ $_.Exception.Message)
}
# Copy scripts to c:\scripts
try {
    Write-Host "Copying scripts to C drive" -ForegroundColor Green
    Copy-Item -Path "Z:\Scripts" -Destination "C:\Scripts" -Recurse -ErrorAction Stop
}
catch {
    Write-Warning -Message $("Task failed: "+ $_.Exception.Message)
}


#Install services
try {
    Write-Host "Installing the services, this may take a while." -ForegroundColor Green
    Add-WindowsFeature AD-Domain-Services -IncludeManagementTools -ErrorAction Stop
    Add-WindowsFeature RemoteAccess, Routing -ErrorAction Stop
    shutdown /r /t 0
}
catch {
    Write-Warning -Message $("Task failed: "+ $_.Exception.Message)
}