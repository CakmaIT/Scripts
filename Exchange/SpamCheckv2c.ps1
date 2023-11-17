$style = "<style>BODY{font-family: Tahoma; font-size: 10pt;}"
$style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}"
$style = $style + "TH{border: 1px solid black; background: #dddddd; padding: 5px; }"
$style = $style + "TD{border: 1px solid black; padding: 5px; }"
$style = $style + "</style>"

Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;

$topsenders=Get-ExchangeServer | Get-MessageTrackingLog -Start (get-date).AddDays(-1) -EventID "SENDEXTERNAL" -ResultSize Unlimited | Group-Object -Property Sender | Sort-Object -Descending Count | Where-Object {$_.Count -gt 50}
$array = @()
foreach ($Sendur in $topsenders){
$row = new-object psobject
        $row | add-member -type NoteProperty -name 'Mail Count' -Value $Sendur.Count
        $row | add-member -type NoteProperty -name 'Mail Address' -Value $Sendur.Name
        $array += $row
}
if ($topsenders -ne $Null) {
$arraytopsenders= $array | ConvertTo-Html -Head $style }
Else{$arraytopsenders = "50'nin üzerinde kurum dışına mail atan kullanıcıya rastlanmamıştır."}
#$topsendersout = [string]::Join([Environment]::NewLine,$topsendersout);
$topsender= $topsenders | Select -First 1 | Select Name
if ($topsender -ne $Null) {
$Kullanici=$topsender.Name }
Else{$Kullanici="Yok"}
$array2 = @()

if ($topsender -ne $Null) {
$Last100Mailout=Get-ExchangeServer | Get-MessageTrackingLog -Start (get-date).AddDays(-1) -EventID "SENDEXTERNAL" -Sender ($topsender.Name) -ResultSize Unlimited | Select Sender,MessageSubject,Timestamp,@{Name='Alici' ; Expression={$_.Recipients}} | Sort-Object -Descending TimeStamp | select -First 20}
Else {$Last100Mailout =""}
if ($Kullanici -ne "Yok") {
foreach ($Send100 in $Last100Mailout){
$row2 = new-object psobject
        $row2 | add-member -type NoteProperty -name 'MailSender' -Value $Send100.Sender
        $row2 | add-member -type NoteProperty -name 'MailSubject' -Value $Send100.MessageSubject
        $row2 | add-member -type NoteProperty -name 'MailTime' -Value $Send100.Timestamp
        $row2 | add-member -type NoteProperty -name 'MailSendto' -Value $Send100.Alici
        $array2 += $row2
}
$arraytopsender100 = $array2 | ConvertTo-Html -Head $style
}
Else{$arraytopsender100 = ""}

$SubjectTable = @()
$SubjectOrder=Get-ExchangeServer | Get-MessageTrackingLog -Start (get-date).AddDays(-1) -EventID "SENDEXTERNAL" -ResultSize Unlimited | Group-Object -Property Sender,MessageSubject,Count | Sort-Object -Descending Count | Where-Object {$_.Count -gt 15} 
if ($SubjectOrder -ne $Null ) {
$SubjectTable = $SubjectOrder | Select Name,Count | Convertto-Html -Fragment -As Table
}
Else{$SubjectTable = "Aynı subject ile 15'in üzerinde kurum dışına mail atan kullanıcıya rastlanmamıştır."}

##Son geliştirme 1

$topsenders1000=Get-ExchangeServer | Get-MessageTrackingLog -Start (get-date).AddDays(-1) -EventID "SENDEXTERNAL" -ResultSize Unlimited | Group-Object -Property Sender | Sort-Object -Descending Count | Where-Object {$_.Count -gt 1000}| Select Name
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
        
}
$arrayspamsenderbefore= $arrayspam | ConvertTo-Html -Head $style
}
Else {
$arrayspam='1000 Spam mail gönderimi tespit edilemedi'
$arrayspamsenderbefore= $arrayspam
}
$TimeLine= get-date -Format dd_MM_yy__HH
$arrayspam | Out-File C:\tools\Script\Actions_Before_$TimeLine.csv

$LogicControl= $arrayspam | where {$_.SamAccountAdi -ne $Null} | where {$_.SamAccountAdi -ne "Administrator"} | where {$_.AccountEnable -eq $True}
$LogicControl | Out-File C:\tools\Script\Actions_List_$TimeLine.csv
if ($LogicControl -ne $Null) {
foreach ($Spammercheck in $LogicControl){
Disable-ADAccount -Identity $Spammercheck.SamAccountAdi
Add-ADGroupMember -Identity "ASG_SPAM_OUTBOUND_DENY-127246211" -Members $Spammercheck.SamAccountAdi
Get-ExchangeServer | Get-Queue | Get-Message -ResultSize unlimited | Where {$_.FromAddress -eq "$Spammercheck.MailSender"} | Suspend-Message -Confirm:$False
#Get-ExchangeServer | Get-Queue | Get-Message -ResultSize unlimited | Where {$_.FromAddress -eq "$Spammercheck.MailSender"} | Remove-Message -WithNDR $False -Confirm:$False
Get-aduser $Spammercheck.SamAccountAdi | select Name,enabled | Export-Csv -NoTypeInformation -Encoding UTF8 -Append C:\tools\Script\Actions_After_$TimeLine.csv -Force
}
}
Else {
$LogicControl="1000 üzerinde Spam gönderimi tespit edilemedi ve/veya Enable account bulunamadı"
$LogicControl | Out-File C:\tools\Script\Actions_After_$TimeLine.csv
}

$files = Get-ChildItem -Path C:\tools\Script\Actions_*.csv | Sort-Object -Descending LastWriteTime | select -First 3


$attachments = @()
foreach($file in $files){
    $filename = [system.io.path]::GetFileName($file.FullName)
    $attachments += $file.fullname
    
}

$MailSender = "ExchangeDailyReport@acibadem.com.tr"
$Subject = 'Top External Mail Senders Raporu'
$SMTPServer = 'smtprelay01.acibadem.com.tr'
##$SendtoMail = "kamil.cicek@acibadem.com"
$SendtoMail = "acibademsistemyonetimi@acibadem.com"
##Ek Geliştirme2
$valuesToLookFor = @(
    'mrharryloanoffer0@gmail.com'
    'mrjohnrichardson89@hotmail.com',
    'j.mcbrian1@aol.com',
    'garryewing93@yahoo.com'
    'gwilliams18443@aol.com'
    )
$MuhtemelSpams=Get-ExchangeServer | Get-MessageTrackingLog -Start (get-date).AddDays(-1) -EventID "SENDEXTERNAL" -ResultSize Unlimited |  Where {$valuesToLookFor -contains $_.Recipients} 
$Victim= $MuhtemelSpams | Group Sender,Count | Select Name,Count | ConvertTo-Html -Head $style
##

if ($MuhtemelSpams -ne $Null) {
$Victim= $MuhtemelSpams | Group Sender,Count | Select Name,Count | ConvertTo-Html -Head $style
}
Else {
$Victim="Spam adreslerine mail atan kullanıcı tespit edilemedi"
}
if ($topsenders -ne $Null) {
$EmailBody = @"
<font face=Tahoma>Merhaba,</font><br />
<br />
<b><font face=Tahoma>Spam adreslerine mail atan kullanıcılar aşağıdaki gibidir.</font></b><br />
<font face=Tahoma>>$Victim</font><br />
<br />
<b><font face=Tahoma>Şirket dışına en çok mail atan kullanıcı raporu aşağıdaki gibidir.</font></b><br />
<font face=Tahoma>>$arraytopsenders</font><br />
<br />
<b><font face=Tahoma>Gönderilen maillerde Subject'leri aynı olup, 15'den fazla dışarıya mail atan kullanıcılar aşağıdaki gibidir.</font></b><br />
<font face=Tahoma>>$SubjectTable</font><br />
<br />
<b><font face=Tahoma>1000 den fazla dışarıya e-mail gönderen kullanıcıların account bilgileri aşağıdaki gibidir.</font></b><br />
<font face=Tahoma>>$arrayspamsenderbefore</font><br />
<br />
<b><font face=Tahoma>En çok e-mail gönderen $($topsender.Name) kullanıcısının son 20 maili aşağıdaki gibidir.</b></font><br />
<font face=Tahoma>>$arraytopsender100</font><br />
<br /></font></h5>
<br /><br />
"@
}
Else {
$EmailBody = @"
<font face=Tahoma>Merhaba,</font><br />
<br />
<b><font face=Tahoma>Spam adreslerine mail atan kullanıcılar aşağıdaki gibidir.</font></b><br />
<br />
<font face=Tahoma>>$Victim</font><br />
<b><font face=Tahoma>Şirket dışına en çok mail atan kullanıcı raporu aşağıdaki gibidir.</font></b><br />
<br />
<font face=Tahoma>>$arraytopsenders</font><br />
<br /><br />
<b><font face=Tahoma>Aynı Subject'e sahip olup 15'den fazla dışarıya mail atan kullanıcılar aşağıdaki gibidir.</font></b><br />
<br />
<font face=Tahoma>>$SubjectTable</font><br />
<br /></font></h5>
"@
}
Start-Sleep -s 1
Send-MailMessage -To @('servet.bal@acibadem.com','emre.erkal@acibadem.com') -Cc $SendtoMail -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHTML -Attachments $attachments -Priority High

##Send-MailMessage -To $SendtoMail -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHTML -Priority High
