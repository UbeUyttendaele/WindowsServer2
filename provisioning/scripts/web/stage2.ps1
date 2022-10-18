try {
    Write-Host "Authorezing DHCP in domain" -ForegroundColor Green
    Add-DhcpServerInDC -ErrorAction Stop 
}
catch {
    Write-Warning -Message $("Task failed: "+ $_.Exception.Message)
}


