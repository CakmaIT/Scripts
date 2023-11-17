
$topsenders1000=Get-TransportService | Get-MessageTrackingLog -Start (get-date).AddDays(-1) -EventID "SENDEXTERNAL" -ResultSize Unlimited | Group-Object -Property Sender | Sort-Object -Descending Count | Where-Object {$_.Count -gt 1000}| Select Name
$arrayspam = @()
if ($topsenders1000 -ne $Null) {
foreach ($Spammer in $topsenders1000){
        $rowspam = new-object psobject
        $rowspam | add-member -type NoteProperty -name 'MailSender' -Value $Spammer
        $SamNamei= Get-user $Spammer.Name -ResultSize 1 | Select SamAccountName
        $Statusu=""
        $Statusu= Get-aduser $SamNamei.SamAccountName | select enabled
        $rowspam | add-member -type NoteProperty -name 'SamAccountAdi' -Value $SamNamei.SamAccountName
        $rowspam | add-member -type NoteProperty -name 'AccountEnable' -Value $Statusu.enabled
        $arrayspam += $rowspam
}}
Else {
$arrayspam="1000 Spam mail gönderimi tespit edilemedi"
}
$TimeLine= get-date -Format dd_MM_yy_HH
$arrayspam | Export-Csv -NoTypeInformation -Encoding UTF8 C:\tools\Script\Actions_$TimeLine.csv
$arrayspamsenderbefore= $arrayspam | ConvertTo-Html -Head $style
$LogicControl= $arrayspam | where {$_.SamAccountAdi -ne $Null} | where {$_.SamAccountAdi -ne "Administrator"} | where {$_.AccountEnable -eq $True}
$LogicControl | Export-Csv -NoTypeInformation -Encoding UTF8 -Append C:\tools\Script\Actions_$TimeLine.csv
if ($LogicControl -ne $Null) {
foreach ($Spammercheck in $LogicControl){
Disable-ADAccount -Identity $Spammercheck.SamAccountAdi
Add-ADGroupMember -Identity "ASG_SPAM_OUTBOUND_DENY-127246211" -Members $Spammercheck.SamAccountAdi
Get-TransportService | Get-Queue | Get-Message -ResultSize unlimited | Where {$_.FromAddress -eq "$Spammercheck.MailSender"} | Suspend-Message -Confirm:$False
Get-TransportService | Get-Queue | Get-Message -ResultSize unlimited | Where {$_.FromAddress -eq "$Spammercheck.MailSender"} | Remove-Message -WithNDR $False -Confirm:$False
Get-aduser $Spammercheck.SamAccountAdi | select Name,enabled | Export-Csv -NoTypeInformation -Encoding UTF8 -Append C:\tools\Script\Actions_$TimeLine.csv
}
}
Else {
$LogicControl="1000 üzerinde Spam gönderimi tespit edilemedi ve/veya Enable account bulunamadı"
$LogicControl | Export-Csv -NoTypeInformation -Encoding UTF8 -Append C:\tools\Script\Actions_$TimeLine.csv
}

1000 den fazla dışarıya e-mail gönderen kullanıcıların account kontrolleri sonrası bilgileri aşağıdaki gibidir.
$arrayspamsenderbefore 




$Topspamsenders= $arrayspam | ConvertTo-Html -Head $style }

#Get-user sytest00 | Select SamAccountName
#$topsenders1001= "SYTEST00@acibadem.com"


Get-TransportService | Get-Queue | Get-Message -ResultSize unlimited | ? {$_.FromAddress -eq "berna.bulut@acibadem.com"} | Suspend-Message -Confirm:$False
Get-TransportService | Get-Queue | Get-Message -ResultSize unlimited | Where {$_.FromAddress -eq "berna.bulut@acibadem.com"} | Remove-Message -WithNDR $False -Confirm:$False

Get-TransportService | Get-Queue 

Get-TransportService | Get-MessageTrackingLog -Start (get-date).AddHours(-2) -ResultSize Unlimited | Where {$_.FromAddress -eq "berna.bulut@acibadem.com"} 





$a=Get-TransportService | Get-MessageTrackingLog -Start (get-date).AddDays(-1) -EventID "SENDEXTERNAL" -ResultSize Unlimited | Group-Object -Property Sender,MessageSubject,Count | Sort-Object -Descending Count | Where-Object {$_.Count -gt 25} | ft Count,Name
$b=$a 
-Sender "berna.bulut@acibadem.com" 


en
$a | ft Name,Count
 Select-Object @{n='Count1';e={$a.Count}},@{n='Date';e={$_.Group[0].Date}}, Count
Get-TransportService | Get-MessageTrackingLog -Start (get-date).AddDays(-1) -EventID "SENDEXTERNAL" -ResultSize Unlimited | Group-Object -Property Sender,MessageSubject | Sort-Object -Descending Count | Where-Object {$_.Count -gt 1000}| Select Name


