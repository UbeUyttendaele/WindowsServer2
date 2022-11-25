#-----------------------
#   Imports
#-----------------------
Import-Module DnsServer
#-----------------------
#   Variables
#-----------------------
$WarningPreference = 'SilentlyContinue'
 try {
    Write-Host "-------------------------" -ForegroundColor yellow
    Write-Host "     Configuring DNS     " -ForegroundColor yellow
    Write-Host "-------------------------" -ForegroundColor yellow
    #Add-DnsServerResourceRecord -ComputerName dc -ZoneName ws2-2223-ube.hogent -NS -NameServer web -name web.ws2-2223-ube.hogent
    #Set-DnsServerPrimaryZone -ComputerName dc -ZoneName ws2-2223-ube.hogent -SecureSecondaries TransferToZoneNameServer -Notify Notify
    Add-DnsServerResourceRecordCName -Name "www" -HostNameAlias "web.ws2-2223-ube.hogent" -ZoneName ws2-2223-ube.hogent

    # Aanmaken Reverse Lookup Zone
    Add-DnsServerPrimaryZone -networkID "192.168.22.0/24" -ReplicationScope "Domain" -DynamicUpdate "Secure"
    
    # Omzetten A records naar PTR records.
    $computerName = 'dc'; 
    
    # Get all the DNS A Records.
    $records = Get-DnsServerResourceRecord -ZoneName 'ws2-2223-ube.hogent' -RRType A -ComputerName $computerName; 
    foreach ($record in $records) 
    { 
        # The reverse lookup domain name.  This is the PTR Response.
        $ptrDomain = $record.HostName + '.WS2-2223-ube.hogent'; 
    
        # Reverse the IP Address for the name record.
        $name = ($record.RecordData.IPv4Address.ToString() -replace '^(\d+)\.(\d+)\.(\d+).(\d+)$','$4.$3.$2');
        
        # Add the new PTR record.
        Add-DnsServerResourceRecordPtr -Name $name -ZoneName '22.168.192.in-addr.arpa' -ComputerName $computerName -PtrDomainName $ptrDomain; 
    }
 }
 catch {
    Write-Host $("(Task failed: "+ $_.Exception.Message) -ForegroundColor red
 }
