$Credential = New-object -TypeName System.Management.Automation.PSCredential -ArgumentList "WS2-2223-UBE\Administrator", (ConvertTo-SecureString -AsPlainText "Admin2021" -Force)

Add-DhcpServerInDC -DnsName "web.ws2-2223-ube.hogent"
#New-PSSession -Credential $Credential | Enter-PSSession
