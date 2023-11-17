
$topsenders1000=Get-TransportService | Get-MessageTrackingLog -Start (get-date).AddDays(-1) -EventID "SENDEXTERNAL" -ResultSize Unlimited | Group-Object -Property Sender | Sort-Object -Descending Count | Where-Object {$_.Count -gt 1000}| Select Name

#Get-user sytest00 | Select SamAccountName
#$topsenders1001='SYTEST00@acibadem.com'
$arrayspam = @()
foreach ($Spammer in $topsenders1000){
        $rowspam = new-object psobject
        $rowspam | add-member -type NoteProperty -name 'MailSender' -Value $Spammer
        $SamNamei= Get-user $Spammer.Name | Select SamAccountName
        $Statusu= Get-aduser $SamNamei.SamAccountName | select enabled
        $rowspam | add-member -type NoteProperty -name 'SamAccountAdi' -Value $SamNamei.SamAccountName
        $rowspam | add-member -type NoteProperty -name 'AccountEnable' -Value $Statusu.enabled
        $arrayspam += $rowspam
}
$arrayspam | Export-Csv -NoTypeInformation -Encoding UTF8 C:\tools\Script\Actions.csv -Append

# Disable-ADAccount -Identity $SamNamei.SamAccountName

$LogicControl= $arrayspam | where {$_.SamAccountAdi -ne $Null} | where {$_.AccountEnable -ne $False}

if ($LogicControl -ne $Null) {
foreach ($Spammercheck in $LogicControl){
Write-Host $Spammercheck.SamAccountAdi
#Disable-ADAccount -Identity $Spammercheck.SamAccountAdi
#Add-ADGroupMember -Identity "ASG_SPAM_OUTBOUND_DENY-127246211" -Members $Spammercheck.SamAccountAdi
}
}
Else {
Write-Host "Spam gönderimi tespit edilemedi ve/veya Enable account bulunamadı"
}
$Topspamsenders= $arrayspam | ConvertTo-Html -Head $style }

