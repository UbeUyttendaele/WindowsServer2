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
    Write-Host "Configuring network settings." -ForegroundColor yellow
    New-NetIPAddress @InterfaceConfig -ErrorAction Stop | out-null
    Set-DnsClientServerAddress @dnsConfig -ErrorAction Stop | out-null
    sleep 5
}
catch {
    Write-Warning -Message $("Task failed:"+ $_.Exception.Message)
}
# Copy scripts to c:\scripts
try {
    Write-Host "Copying scripts to C drive" -ForegroundColor yellow
    Copy-Item -Path "Z:\scripts" -Destination "C:\scripts" -Recurse -ErrorAction Stop
}
catch {
    Write-Warning -Message $("Task failed: "+ $_.Exception.Message)
}


#Install services
try {
    Write-Host "Installing the services, this may take a while." -ForegroundColor yellow
    Add-WindowsFeature AD-Domain-Services -IncludeManagementTools -ErrorAction Stop | out-null
    Add-WindowsFeature RemoteAccess, Routing -ErrorAction Stop | out-null
}
catch {
    Write-Warning -Message $("Task failed: "+ $_.Exception.Message)
}