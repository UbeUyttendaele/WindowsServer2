#-----------------------
#   Variables
#-----------------------
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

#-----------------------
#   Configure network
#-----------------------
try {
    Write-Host "Configuring network settings." -ForegroundColor yellow
    New-NetIPAddress @InterfaceConfig -ErrorAction Stop | out-null
    Set-DnsClientServerAddress @dnsConfig -ErrorAction Stop | out-null
    Set-NetFirewallProfile -Enabled False
}
catch {
    Write-Host -Message $("Task failed:"+ $_.Exception.Message) -ForegroundColor red
}


#-----------------------
#   Install AD
#-----------------------
try {
    Write-Host "Installing the services, this may take a while." -ForegroundColor yellow
    Install-WindowsFeature AD-Domain-Services -IncludeManagementTools -ErrorAction Stop | out-null

    Import-Module ADDSDeployment
    Install-ADDSForest `
    -DomainName "ws2-2223-ube.hogent" `
    -DomainNetbiosName "WS2-2223-UBE" `
    -SafeModeAdministratorPassword (ConvertTo-SecureString -AsPlainText "Admin2021" -Force) `
    -InstallDns:$true `
    -NoRebootOnCompletion:$true `
    -Force:$true | out-null
}
catch {
    Write-Host -Message $("Task failed:"+ $_.Exception.Message) -ForegroundColor red
}