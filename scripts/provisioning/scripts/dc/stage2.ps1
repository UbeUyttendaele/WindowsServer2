#-----------------------
#   Variables
#-----------------------
$WarningPreference = 'SilentlyContinue'
#-----------------------
#   Initializing domain
#-----------------------

try {
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "        Initializing domain  " -ForegroundColor yellow
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "Importing module" -ForegroundColor yellow
    Import-Module ADDSDeployment

    Write-Host "Installing ADDSForest" -ForegroundColor yellow
    
    Install-ADDSForest `
    -CreateDnsDelegation:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainMode "WinThreshold" `
    -DomainName "ws2-2223-ube.hogent" `
    -DomainNetbiosName "WS2-2223-UBE" `
    -SafeModeAdministratorPassword (ConvertTo-SecureString -AsPlainText "Admin2021" -Force) `
    -ForestMode "WinThreshold" `
    -InstallDns:$true `
    -LogPath "C:\Windows\NTDS" `
    -NoRebootOnCompletion:$true `
    -SysvolPath "C:\Windows\SYSVOL" `
    -Force:$true
    Write-Host " " -ForegroundColor yellow
    Write-Host " " -ForegroundColor yellow
    Write-Host " " -ForegroundColor yellow
    Write-Host " " -ForegroundColor yellow

}
catch {
    Write-Host $("Task failed: "+ $_.Exception.Message) -ForegroundColor red
}

    

