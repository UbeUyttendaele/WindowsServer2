#-----------------------
#   Variables
#-----------------------
$WarningPreference = 'SilentlyContinue'

try { 
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "      Installing exchange server        " -ForegroundColor yellow
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "Starting installer" -ForegroundColor yellow
    F:\Setup.exe /PrepareAD
    F:\Setup.exe /m:install /roles:m /IAcceptExchangeServerLicenseTerms_DiagnosticDataOff /InstallWindowsComponents /on:ws2-2223-ube
}
catch {
    Write-Host $("(Task failed: "+ $_.Exception.Message) -ForegroundColor red
}
