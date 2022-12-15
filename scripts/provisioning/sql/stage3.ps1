#-----------------------
#   Variables
#-----------------------
$WarningPreference = 'SilentlyContinue'
$configfile = 'C:\scripts\sql\config\config'
$query = "CREATE DATABASE temp ON ( name = 'temp', filename = 'C:\database\temp.mdf' ) log on ( name = 'temp_log', filename = 'C:\database\temp_log.ldf' )"

try {
    Write-Host "-----------------------------------" -ForegroundColor yellow    
    Write-Host "             SQL setup            " -ForegroundColor yellow
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "Configuring remote access" -ForegroundColor yellow
    sqlcmd -i $configfile
    Write-Host "Starting sqlbrowser" -ForegroundColor yellow
    Set-service sqlbrowser -StartupType Auto
    Start-service sqlbrowser

    import-module SQLPS 
    $smo = 'Microsoft.SqlServer.Management.Smo.'  
    $wmi = new-object ($smo + 'Wmi.ManagedComputer')  
    $uri = "ManagedComputer[@Name='" + (get-item env:\computername).Value + "']/ServerInstance[@Name='MSSQLSERVER']/ServerProtocol[@Name='Tcp']"  
    $Tcp = $wmi.GetSmoObject($uri)  
    $Tcp.IsEnabled = $true  
    $Tcp.Alter()  
    $Tcp  

    Write-Host "Creating database" -ForegroundColor yellow
    mkdir "C:\database"
    sqlcmd -Q $query
}
catch {
    Write-Host $("(Task failed: "+ $_.Exception.Message) -ForegroundColor red
}