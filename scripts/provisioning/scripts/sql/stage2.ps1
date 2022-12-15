#-----------------------
#   Variables
#-----------------------

$WarningPreference = 'SilentlyContinue'

try {
    Write-Host "-----------------------------------" -ForegroundColor yellow    
    Write-Host "             SQL server            " -ForegroundColor yellow
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "Installing SQL server" -ForegroundColor yellow
    F:\Setup.exe /qs /ACTION=Install /FEATURES=SQLEngine /INSTANCENAME=MSSQLSERVER /SQLSVCACCOUNT="NT SERVICE\MSSQLSERVER" /SQLSVCPASSWORD="Admin2021" /SQLSYSADMINACCOUNTS="ws2-2223-ube.hogent\Administrator" /AGTSVCACCOUNT="NT AUTHORITY\Network Service" /TCPENABLED=1 /IACCEPTSQLSERVERLICENSETERMS /SUPPRESSPRIVACYSTATEMENTNOTICE
}
catch {
    Write-Host $("(Task failed: "+ $_.Exception.Message) -ForegroundColor red
}