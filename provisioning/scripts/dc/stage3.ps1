
try {
    Write-Host "Configuring NAT" -ForegroundColor yellow
    new-netnat -name "NAT" -internalipinterfaceaddressprefix "192.168.22.0/24" -ErrorAction Stop | out-null
}
catch {
    Write-Host -Message $("Task failed:"+ $_.Exception.Message) -ForegroundColor red
}




    

