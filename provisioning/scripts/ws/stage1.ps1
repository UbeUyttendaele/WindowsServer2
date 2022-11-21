$domain   = "ws2-2223-ube.hogent"
$username = "$domain\administrator" 
$password = "Admin2021" | ConvertTo-SecureString -asPlainText -Force
$user2    = "lAdmin"
$lcred      = New-Object System.Management.Automation.PsCredential($user2, $password)
$credential = New-Object System.Management.Automation.PSCredential($username, $password)

try {
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "    Configuring network settings   " -ForegroundColor yellow
    Write-Host "-----------------------------------" -ForegroundColor yellow
    ipconfig /renew


    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "        Installing SSMS           " -ForegroundColor yellow
    Write-Host "-----------------------------------" -ForegroundColor yellow
    C:\scripts\ws\SSMS_Set.exe /Passive /Install /Norestart SSMSInstallRoot=C:\SSMS


    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "    Installing server manager       " -ForegroundColor yellow
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Get-WindowsCapability -name rsat* -online | Add-WindowsCapability -Online

    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "        Configuring domain         " -ForegroundColor yellow
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "Joining domain" -ForegroundColor yellow
    Add-Computer -DomainName $domain -Credential $credential -LocalCredential $lcred -Restart | out-null
}
catch {
    Write-Warning -Message $("Task failed: "+ $_.Exception.Message)
}
