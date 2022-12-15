$WarningPreference = 'SilentlyContinue'
$domain   = "ws2-2223-ube.hogent"
$username = "$domain\administrator" 
$password = "Admin2021" | ConvertTo-SecureString -asPlainText -Force
$user2    = "lAdmin"
$lcred      = New-Object System.Management.Automation.PsCredential($user2, $password)
$credential = New-Object System.Management.Automation.PSCredential($username, $password)
$setup = $(get-ChildItem C:\scripts\ws\ -Filter *.exe)

try {
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "    Configuring network settings   " -ForegroundColor yellow
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "Requesting IP from dhcp server" -ForegroundColor yellow
    ipconfig /renew -ErrorAction Stop | out-null


    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "        Installing SSMS            " -ForegroundColor yellow
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "Installing, this may take a while..." -ForegroundColor yellow
    start-process $setup.fullname -ArgumentList "/Passive /Install /Norestart SSMSInstallRoot=C:\SSMS" -wait -ErrorAction Stop

    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "    Installing server manager      " -ForegroundColor yellow
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "Installing, this may take a while..." -ForegroundColor yellow
    Get-WindowsCapability -name rsat* -online | Add-WindowsCapability -Online -ErrorAction Stop | out-null

    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "        Configuring domain         " -ForegroundColor yellow
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "Joining domain" -ForegroundColor yellow
    Add-Computer -DomainName $domain -Credential $credential -LocalCredential $lcred | out-null
}
catch {
    Write-Warning -Message $("Task failed: "+ $_.Exception.Message)
}
