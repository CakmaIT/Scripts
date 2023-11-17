$results = Get-DnsServerZone -ComputerName 10.5.0.17 | % {
    $zone = $_.zonename
    Get-DnsServerResourceRecord $zone -ComputerName 10.5.0.17 | select @{n='ZoneName';e={$zone}}, HostName, RecordType, @{n='RecordData';e={if ($_.RecordData.IPv4Address.IPAddressToString) {$_.RecordData.IPv4Address.IPAddressToString} else {$_.RecordData.NameServer.ToUpper()}}}
}

$results | Export-Csv -NoTypeInformation c:\tools\dns\DNSRecords.csv -Append