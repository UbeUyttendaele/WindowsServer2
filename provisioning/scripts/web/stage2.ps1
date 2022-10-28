try {
    Write-Host "Installing roles" -ForegroundColor Green
    Install-WindowsFeature DNS
    Add-DnsServerSecondaryZone -MasterServers 192.168.22.1 -Name "ws2-2223-ube.hogent" -ZoneFile ws2-2223-ube.hogent | out-null
}
catch {
    Write-Warning -Message $("Task failed: "+ $_.Exception.Message)
}


