

$recently = [DateTime]::Today.AddDays(-365)
$a=Get-DnsServerResourceRecord -ComputerName gmasgdc03 -ZoneName acibadem.com.tr -RRType A | Where {($_.Timestamp -ne $null)} | Where {($_.Timestamp -lt $recently)} | Where {($_.HostName -ne "@")} | Where {($_.HostName -notlike "*dnszones*")}
$a.Count

$Tar=(get-date -Format dd/MM/yyyy/hhmm)
$a | Select-Object HostName,DistinguishedName,RecordType,Timestamp,TimeToLive,@{label="IP Address";expression={$_.RecordData.ipv4address}} | Export-csv -NoTypeInformation -Path C:\tools\DNS\$Tar.csv


