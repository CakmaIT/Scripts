﻿$recently = [DateTime]::Today.AddDays(-180)
$revZones= (Get-DnsServerZone -ComputerName 10.5.0.17 | Where-Object {$_.isReverseLookupZone -eq $true}).ZoneName
#$revZones
#$records=$Null
$list=@()
$records=@()
#$Object=New-Object PSObject
foreach ($zone in $revZones){
#$records=Get-DnsServerResourceRecord -ComputerName 10.5.0.17 -ZoneName $zone -RRType Ptr | Where {($_.Timestamp -ne $null)} | Where {($_.Timestamp -lt $recently)} | Where {($_.RecordData.PtrDomainName -ne "@")} | Where {($_.RecordData.PtrDomainName -match "^[0-9][0-9][NP]") -or ($_.RecordData.PtrDomainName -match "^[B][S][-]")} | Select Hostname,RecordType,DistinguishedName,Timestamp,@{name='RecordData';Expression={$_.RecordData.PtrDomainName}}
$records+= Get-DnsServerResourceRecord -ComputerName 10.5.0.17 -ZoneName $zone -RRType Ptr | Where {($_.Timestamp -ne $null)} | Where {($_.Timestamp -lt $recently)} | Where {($_.RecordData.PtrDomainName -ne "@")} | Where {($_.RecordData.PtrDomainName -match "^[0-9][0-9][NP]") -or ($_.RecordData.PtrDomainName -match "^[B][S][-]")} | Select Hostname,RecordData,DistinguishedName,Timestamp | Add-Member -PassThru NoteProperty "ZoneName" $zone
foreach ($record in $records){
#Write-Host $Zone
#Write-Host $records.GetType()
$list = New-Object -TypeName PSObject
$list | Add-Member -PassThru NoteProperty "Hostname" $record.Hostname
$list | Add-Member -PassThru NoteProperty "PtrDomainName" $record.RecordData.PtrDomainName
$list | Add-Member -PassThru NoteProperty "TimeStamp" $record.TimeStamp
$list | Add-Member -PassThru NoteProperty "ZoneName" $record.ZoneName
##$records | Add-Member -Name "Zonu" -MemberType "NoteProperty" -Value $zone
#$records | Add-Member -MemberType Properties -Name "Zonu" -Value $zone
##$list+=$records
}
}
$list | Out-GridView

#$records | Out-GridView
$list | Export-Csv -Path "C:\DNSCalisma\ZonesPTR7.csv" -NoTypeInformation 



Write-Host $list.ToString(


foreach ($liste in $list){
Write-Host "$liste"
}

#C:\DNSCalisma
h