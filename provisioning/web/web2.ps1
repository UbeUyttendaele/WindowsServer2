$credential = New-object -TypeName System.Management.Automation.PSCredential -ArgumentList "WS2-2223-UBE\Administrator", (ConvertTo-SecureString -AsPlainText "Admin2021" -Force)
Invoke-Command -ComputerName mycomputer -ScriptBlock { Add-DhcpServerInDC -DnsName "web.ws2-2223-ube.hogent" -ipaddress 192.168.22.2} -credential $credential
#New-PSSession -Credential $Credential | Enter-PSSession
