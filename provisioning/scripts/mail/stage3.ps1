# Imports
try { 
    Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn -ErrorAction Stop | out-null
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "        Enabling mailbox        " -ForegroundColor yellow
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "enabling mailbox" -ForegroundColor yellow
    Enable-Mailbox
}
catch {
    Write-Host $("(Task failed: "+ $_.Exception.Message) -ForegroundColor red
}