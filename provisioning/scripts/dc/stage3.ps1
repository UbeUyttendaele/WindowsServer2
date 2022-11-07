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

 try {
    Write-Host "-------------------------" -ForegroundColor yellow
    Write-Host "   Configuring Domain    " -ForegroundColor yellow
    Write-Host "-------------------------" -ForegroundColor yellow
    Write-Host "Creating OU" -ForegroundColor yellow
    New-ADOrganizationalUnit -Name "operation-users" -Path "DC=ws2-2223-ube,DC=hogent" -Server "dc" -ErrorAction Stop | out-null
    Write-Host "Creating user 'bob'" -ForegroundColor yellow
    New-ADuser @bobUser -Server "dc" -ErrorAction Stop | out-null
    Write-Host "Creating user 'sofie'" -ForegroundColor yellow
    New-ADuser @sofieUser -Server "dc" -ErrorAction Stop | out-null

    Write-Host "-------------------------" -ForegroundColor yellow
    Write-Host "     Configuring NAT     " -ForegroundColor yellow
    Write-Host "-------------------------" -ForegroundColor yellow
    Write-Host "Setting NAT inside address" -ForegroundColor yellow
    new-netnat -name "NAT" -internalipinterfaceaddressprefix "192.168.22.0/24" -ErrorAction Stop | out-null

    Write-Host "-------------------------" -ForegroundColor yellow
    Write-Host "     Configuring DNS     " -ForegroundColor yellow
    Write-Host "-------------------------" -ForegroundColor yellow
    #Write-Host "TODO" -ForegroundColor red
    Add-DnsServerResourceRecord -ComputerName dc -ZoneName ws2-2223-ube.hogent -NS -NameServer web -name web.ws2-2223-ube.hogent
    Set-DnsServerPrimaryZone -ComputerName dc -ZoneName ws2-2223-ube.hogent -SecureSecondaries TransferToZoneNameServer -Notify Notify
    Add-DnsServerResourceRecordA -Name www -ZoneName ws2-2223-ube.hogent -AllowUpdateAny -IPv4Address 192.168.22.2

    Write-Host "-------------------------" -ForegroundColor yellow
    Write-Host "     Configuring DNS     " -ForegroundColor yellow
    Write-Host "-------------------------" -ForegroundColor yellow
    Install-AdcsCertificationAuthority -CACommonName dc -CAType EnterpriseRootCa -HashAlgorithmName SHA256 -KeyLength 2048 
 }
 catch {
    Write-Host $("(┛◉Д◉) ┛彡┻━┻: "+ $_.Exception.Message) -ForegroundColor red
 }
