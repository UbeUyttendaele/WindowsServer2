#-----------------------
#   Imports
#-----------------------
Import-Module DnsServer
#-----------------------
#   Variables
#-----------------------
$WarningPreference = 'SilentlyContinue'
$bobUser = @{
    Name = "bob"
    DisplayName = "bob"
    path = "OU=operation-users,DC=ws2-2223-ube,DC=hogent"
    AccountPassword = (ConvertTo-SecureString -AsPlainText "Admin2021" -Force)
    PasswordNeverExpires = $true
    Enabled = $true
    ChangePasswordAtLogon = $false
    UserPrincipalName = "bob@$env:USERDOMAIN.hogent"
}

$sofieUser = @{
    Name = "sofie"
    DisplayName = "sofie"
    path = "OU=operation-users,DC=ws2-2223-ube,DC=hogent"
    AccountPassword = (ConvertTo-SecureString -AsPlainText "Admin2021" -Force)
    PasswordNeverExpires = $true
    Enabled = $true
    ChangePasswordAtLogon = $false
    UserPrincipalName = "sofie@$env:USERDOMAIN.hogent"
}
$features=@(
    'Adcs-Cert-Authority'
)

 try {

    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "        Installing features        " -ForegroundColor yellow
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "Installing, this may take a while..." -ForegroundColor yellow
    Install-WindowsFeature $features -includeManagementTools -ErrorAction Stop | out-null

    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "         Configuring Domain        " -ForegroundColor yellow
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "Creating OU" -ForegroundColor yellow
    New-ADOrganizationalUnit -Name "operation-users" -Path "DC=ws2-2223-ube,DC=hogent" -Server "dc" -ErrorAction Stop | out-null
    Write-Host "Creating user 'bob'" -ForegroundColor yellow
    New-ADuser @bobUser -Server "dc" -ErrorAction Stop | out-null
    Write-Host "Creating user 'sofie'" -ForegroundColor yellow
    New-ADuser @sofieUser -Server "dc" -ErrorAction Stop | out-null

    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "         Configuring NAT           " -ForegroundColor yellow
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "Setting NAT inside address" -ForegroundColor yellow
    new-netnat -name "NAT" -internalipinterfaceaddressprefix "192.168.22.0/24" -ErrorAction Stop | out-null

    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "         Configuring DNS           " -ForegroundColor yellow
    Write-Host "-----------------------------------" -ForegroundColor yellow
    
    Add-DnsServerResourceRecordA -Name "web" -ZoneName "ws2-2223-ube.hogent" -AllowUpdateAny -IPv4Address "192.168.22.2"
    Add-DnsServerResourceRecordA -Name "mail" -ZoneName "ws2-2223-ube.hogent" -AllowUpdateAny -IPv4Address "192.168.22.3"
    Add-DnsServerResourceRecordA -Name "sql" -ZoneName "ws2-2223-ube.hogent" -AllowUpdateAny -IPv4Address "192.168.22.4"

    
    Add-DnsServerResourceRecordCName -Name "www" -HostNameAlias "web.ws2-2223-ube.hogent" -ZoneName ws2-2223-ube.hogent
    Add-DnsServerResourceRecord -ComputerName dc -ZoneName ws2-2223-ube.hogent -NS -NameServer web -name web.ws2-2223-ube.hogent
    Set-DnsServerPrimaryZone -ComputerName dc -ZoneName ws2-2223-ube.hogent -SecureSecondaries TransferToZoneNameServer -Notify Notify
    

    # Aanmaken Reverse Lookup Zone
    Add-DnsServerPrimaryZone -networkID "192.168.22.0/24" -ReplicationScope "Domain" -DynamicUpdate "Secure"
    
    # Omzetten A records naar PTR records.
    $computerName = 'dc'; 
    
    # Get all the DNS A Records.
    $records = Get-DnsServerResourceRecord -ZoneName 'ws2-2223-ube.hogent' -RRType A -ComputerName $computerName; 
    foreach ($record in $records) { 
        # The reverse lookup domain name.  This is the PTR Response.
        $ptrDomain = $record.HostName + '.WS2-2223-ube.hogent'; 
    
        # Reverse the IP Address for the name record.
        $name = ($record.RecordData.IPv4Address.ToString() -replace '^(\d+)\.(\d+)\.(\d+).(\d+)$','$4.$3.$2');
        
        # Add the new PTR record.
        Add-DnsServerResourceRecordPtr -Name $name -ZoneName '22.168.192.in-addr.arpa' -ComputerName $computerName -PtrDomainName $ptrDomain; 
    }

    Write-Host "-------------------------" -ForegroundColor yellow
    Write-Host "     Configuring CA     " -ForegroundColor yellow
    Write-Host "-------------------------" -ForegroundColor yellow
    Install-AdcsCertificationAuthority
 }
 catch {
    Write-Host $("(Task failed: "+ $_.Exception.Message) -ForegroundColor red
 }
