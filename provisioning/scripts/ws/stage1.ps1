$domain   = "ws2-2223-ube.hogent"
$username = "$domain\Admin" 
$password = "Admin2021" | ConvertTo-SecureString -asPlainText -Force
$user2    = "admin"
$pass2    = "Admin2021" | ConvertTo-SecureString -asPlainText -Force

$lcred      = New-Object System.Management.Automation.PsCredential($user2, $pass2)
$credential = New-Object System.Management.Automation.PSCredential($username, $password)

try {
    Write-Host "Joining domain" -ForegroundColor Green
    Add-Computer -DomainName $domain -Credential $credential -LocalCredential $lcred -Restart | out-null
}
catch {
    Write-Warning -Message $("(┛◉Д◉) ┛彡┻━┻: "+ $_.Exception.Message)
}