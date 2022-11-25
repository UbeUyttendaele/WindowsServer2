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
    Write-Host "     Configuring CA     " -ForegroundColor yellow
    Write-Host "-------------------------" -ForegroundColor yellow
    Install-AdcsCertificationAuthority -CACommonName dc -CAType EnterpriseRootCa -HashAlgorithmName SHA256 -KeyLength 2048 
 }
 catch {
    Write-Host $("(Task failed: "+ $_.Exception.Message) -ForegroundColor red
 }
