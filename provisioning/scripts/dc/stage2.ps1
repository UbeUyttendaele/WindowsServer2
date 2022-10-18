
try {
    new-netnat -name "NAT" -internalipinterfaceaddressprefix "192.168.22.0/24"
}
catch {
    Write-Warning -Message $("Task failed: "+ $_.Exception.Message)
}


try {
    Import-Module ADDSDeployment
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
    -NoRebootOnCompletion:$false `
    -SysvolPath "C:\Windows\SYSVOL" `
    -Force:$true
}
catch {
    Write-Warning -Message $("Task failed: "+ $_.Exception.Message)
}

