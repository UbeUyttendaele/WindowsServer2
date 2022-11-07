#-----------------------
#   Variables
#-----------------------
$WarningPreference = 'SilentlyContinue'
#-----------------------
#   Initializing domain
#-----------------------

try {
    Write-Host "-------------------------" -ForegroundColor yellow
    Write-Host "    Initializing domain  " -ForegroundColor yellow
    Write-Host "-------------------------" -ForegroundColor yellow
    Write-Host "Importing module" -ForegroundColor yellow
    Import-Module ADDSDeployment
    Write-Host "Installing ADDSForest" -ForegroundColor yellow
    Install-ADDSForest `
    -DomainName "ws2-2223-ube.hogent" `
    -DomainNetbiosName "WS2-2223-UBE" `
    -SafeModeAdministratorPassword (ConvertTo-SecureString -AsPlainText "Admin2021" -Force) `
    -InstallDns:$true `
    -NoRebootOnCompletion:$true `
    -Force:$true | out-null
}
catch {
    Write-Host $("(┛◉Д◉) ┛彡┻━┻: "+ $_.Exception.Message) -ForegroundColor red
}

    

