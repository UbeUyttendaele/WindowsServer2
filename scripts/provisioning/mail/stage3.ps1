# Imports
try { 
    Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn -ErrorAction Stop | out-null
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "        Enabling mailbox        " -ForegroundColor yellow
    Write-Host "-----------------------------------" -ForegroundColor yellow
    Write-Host "enabling mailbox" -ForegroundColor yellow
    Get-User -OrganizationalUnit "OU=operation-users,DC=ws2-2223-ube,DC=hogent" | foreach-object {Enable-Mailbox}
}
catch {
    Write-Host $("(Task failed: "+ $_.Exception.Message) -ForegroundColor red
}