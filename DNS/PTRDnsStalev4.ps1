$recently = [DateTime]::Today.AddDays(-10)
$Tar=(get-date -Format dd-MM-yyyy-hhmm)
$revZones= (Get-DnsServerZone -ComputerName 10.5.0.17 | Where-Object {$_.isReverseLookupZone -eq $true}).ZoneName
$Output2=@()
$records=@()
$list = New-Object -TypeName PSObject
foreach ($zone in $revZones){
$records+= Get-DnsServerResourceRecord -ComputerName 10.5.0.17 -ZoneName $zone -RRType Ptr | Where {($_.Timestamp -ne $null)} | Where {($_.Timestamp -lt $recently)} | Where {($_.RecordData.PtrDomainName -ne "@")} | Where {($_.RecordData.PtrDomainName -match "^[0-9][0-9][NP]") -or ($_.RecordData.PtrDomainName -match "^[B][S][-]")} | Select Hostname,@{name='RecordData';Expression={$_.RecordData.PtrDomainName}},DistinguishedName,Timestamp | Add-Member -PassThru NoteProperty "ZoneName" $zone 
    foreach ($record in $records){
$Output = @{
'Server' = $record.Hostname
'Zone' = $record.ZoneName
'DistinguishedName' = $record.DistinguishedName
'PtrDomainName' = $record.RecordData.PtrDomainName
'Timestamp' = $record.Timestamp}
Remove-DnsServerResourceRecord -ZoneName $Output.Zone -ComputerName gmasgdc03 -Name $Output.Server -RRType Ptr -Force
$Output2+= $Output
}
}
$records.Count
$records | Export-Csv -Path C:\test\Calisma\$Tar"_PTRRecords.csv" -NoTypeInformation
$Output2 | Export-Csv -Path C:\test\Calisma\$Tar"_PTROutputs.csv" -NoTypeInformation
#$records | Out-GridView
#$Output2 | Out-GridView | FT






