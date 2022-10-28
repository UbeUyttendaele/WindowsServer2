#-----------------------
#   Imports
#-----------------------
New-PSDrive -Name AD -PSProvider ActiveDirectory -Server "dc.ws2-2223-ube.hogent"
import-module ActiveDirectory
import-module DnsServer
#-----------------------
#   Variables
#-----------------------
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
#$credential = New-object -TypeName System.Management.Automation.PSCredential -ArgumentList "Administrator", (ConvertTo-SecureString -AsPlainText "Admin2021" -Force)
$adminUser = @{
    Name = "dadmin"
    DisplayName = "dadmin"
    path = "OU=users,DC=ws2-2223-ube,DC=hogent"
    AccountPassword = (ConvertTo-SecureString -AsPlainText "Admin2021" -Force)
    PasswordNeverExpires = $true
    Enabled = $true
    ChangePasswordAtLogon = $false
    UserPrincipalName = "dadmin@$env:USERDOMAIN.hogent"
}

$adminUser = @{
    Name = "dadmin"
    DisplayName = "dadmin"
    path = "OU=users,DC=ws2-2223-ube,DC=hogent"
    AccountPassword = (ConvertTo-SecureString -AsPlainText "Admin2021" -Force)
    PasswordNeverExpires = $true
    Enabled = $true
    ChangePasswordAtLogon = $false
    UserPrincipalName = "dadmin@$env:USERDOMAIN.hogent"
}

$bobUser = @{
    Name = "bob"
    DisplayName = "bob"
    path = "OU=users,DC=ws2-2223-ube,DC=hogent"
    AccountPassword = (ConvertTo-SecureString -AsPlainText "Admin2021" -Force)
    PasswordNeverExpires = $true
    Enabled = $true
    ChangePasswordAtLogon = $false
    UserPrincipalName = "bob@$env:USERDOMAIN.hogent"
}

$sofieUser = @{
    Name = "sofie"
    DisplayName = "sofie"
    path = "OU=users,DC=ws2-2223-ube,DC=hogent"
    AccountPassword = (ConvertTo-SecureString -AsPlainText "Admin2021" -Force)
    PasswordNeverExpires = $true
    Enabled = $true
    ChangePasswordAtLogon = $false
    UserPrincipalName = "sofie@$env:USERDOMAIN.hogent"
}

$groepen = @("Administrators", "Domain Admins", "Enterprise Admins", "Group Policy Creator Owners","Schema Admins")

#-----------------------
#   Configuring AD
#-----------------------

 try {
    Write-Host "Configuring domain" -ForegroundColor yellow
    New-ADOrganizationalUnit -Name "users" -Path "DC=ws2-2223-ube,DC=hogent" -ErrorAction Stop | out-null
    New-ADuser @bobUser -ErrorAction Stop | out-null
    New-ADuser @sofieUser -ErrorAction Stop | out-null
    foreach($groep in $groepen) {
        Add-ADGroupmember -Identity "$groep" -Members "ladmin"  
    }   
 }
 catch {
    Write-Host -Message $("Task failed:"+ $_.Exception.Message) -ForegroundColor red
 }

#-----------------------
#   Configuring DHCP
#-----------------------

try {
    Write-Host "Configuring DHCP" -ForegroundColor yellow
    Install-WindowsFeature DHCP -IncludeManagementTools -ErrorAction Stop | out-null
    Add-DhcpServerInDC -DnsName "dc.ws2-2223-ube.hogent" -IPAddress 192.168.22.1

    Restart-Service -Name 'dhcpserver' | out-null
    Add-DhcpServerV4Scope @Scope -ErrorAction Stop | out-null
    Set-DhcpServerV4OptionValue @GatewayOption -ErrorAction Stop | out-null
    Set-DhcpServerV4OptionValue @DNSOption -ErrorAction Stop | out-null
}
catch {
    Write-Host -Message $("Task failed:"+ $_.Exception.Message) -ForegroundColor red
}

try {
    Write-Host "Configuring DNS" -ForegroundColor yellow
    Add-DnsServerResourceRecord -ComputerName dc -ZoneName ws2-2223-ube.hogent -NS -NameServer web -name web.ws2-2223-ube.hogent
    Set-DnsServerPrimaryZone -ComputerName dc -ZoneName ws2-2223-ube.hogent -SecureSecondaries TransferToZoneNameServer -Notify Notify
}
catch {
    Write-Host -Message $("Task failed:"+ $_.Exception.Message) -ForegroundColor red
}

try {
    Write-Host "Installing NAT" -ForegroundColor yellow
    Install-WindowsFeature RemoteAccess, Routing -ErrorAction Stop | out-null
}
catch {
    Write-Host -Message $("Task failed:"+ $_.Exception.Message) -ForegroundColor red
}



<# try {
    Write-Host "Configuring DNS" -ForegroundColor yellow
    Add-DnsServerResourceRecord -ComputerName dc -ZoneName ws2-2223-ube.hogent -NS -NameServer web -name web.ws2-2223-ube.hogent
    Set-DnsServerPrimaryZone -ComputerName dc -ZoneName ws2-2223-ube.hogent -SecureSecondaries TransferToZoneNameServer -Notify Notify
}
catch {
    Write-Warning -Message $("Task failed: "+ $_.Exception.Message)
} #>