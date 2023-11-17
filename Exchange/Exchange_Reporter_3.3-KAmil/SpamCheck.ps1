$style = "<style>BODY{font-family: Tahoma; font-size: 10pt;}"
$style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}"
$style = $style + "TH{border: 1px solid black; background: #dddddd; padding: 5px; }"
$style = $style + "TD{border: 1px solid black; padding: 5px; }"
$style = $style + "</style>"

Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;

$topsenders=Get-TransportService | Get-MessageTrackingLog -Start (get-date).AddDays(-1) -EventID "SENDEXTERNAL" -ResultSize Unlimited | Group-Object -Property Sender | Sort-Object -Descending Count | Where-Object {$_.Count -gt 100}
$array = @()
foreach ($Sendur in $topsenders){
$row = new-object psobject
        $row | add-member -type NoteProperty -name 'Mail Count' -Value $Sendur.Count
        $row | add-member -type NoteProperty -name 'Mail Address' -Value $Sendur.Name
        $array += $row
}
$arraytopsenders= $array | ConvertTo-Html -Head $style 
#$topsendersout = [string]::Join([Environment]::NewLine,$topsendersout);
$topsender=Get-TransportService | Get-MessageTrackingLog -Start (get-date).AddDays(-1) -EventID "SENDEXTERNAL" -ResultSize Unlimited | Group-Object -Property Sender | Sort-Object -Descending Count | Where-Object {$_.Count -gt 100} | Select -First 1 | Select Name
$Kullanici=$topsender.Name
$Last100Mailout=Get-TransportService | Get-MessageTrackingLog -Start (get-date).AddDays(-1) -EventID "SENDEXTERNAL" -Sender ($topsender.Name) -ResultSize Unlimited | Select Sender,MessageSubject,Timestamp,@{Name='Alici' ; Expression={$_.Recipients}} | Sort-Object -Descending TimeStamp | select -First 50

$array2 = @()
foreach ($Send100 in $Last100Mailout){
$row2 = new-object psobject
        $row2 | add-member -type NoteProperty -name 'MailSender' -Value $Send100.Sender
        $row2 | add-member -type NoteProperty -name 'MailSubject' -Value $Send100.MessageSubject
        $row2 | add-member -type NoteProperty -name 'MailTime' -Value $Send100.Timestamp
        $row2 | add-member -type NoteProperty -name 'MailSendto' -Value $Send100.Alici
        $array2 += $row2
}
$arraytopsender100 = $array2 | ConvertTo-Html -Head $style 

$MailSender = "ExchangeDailyReport@acibadem.com.tr"
$Subject = 'Top External Mail Senders Raporu'
$SMTPServer = 'smtprelay01.acibadem.com.tr'
$SendtoMail = "kamil.cicek@acibadem.com"
$EmailBody = @"
<font face=Tahoma>Merhaba,</font><br />
<br />
<font face=Tahoma>En çok şirket dışına mail atan kullanıcılara ait rapor aşağıdaki gibidir.</font><br />
<br />
<font face=Tahoma>$arraytopsenders</font><br />
<font face=Tahoma>En çok mail attığı gözlemlenen $($topsender.Name) mail adresinden gönderilen son 50 mail aşağıdaki gibidir.</font><br />
<br /><br />
<font face=Tahoma>$arraytopsender100</font><br />
<br /></font></h5>
"@

Start-Sleep -s 1
Send-MailMessage -To $SendtoMail -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHTML -Priority High



#$EmailBody = @"
#<font face=Tahoma>Merhaba,</font><br />
#<br />
#<font face=Tahoma>Ençok dışarıya mail atan kullanıcılara ait rapor aşağıdaki gibidir.</font><br />
#<br />
#<strong>$arraytopsenders</strong><br /><br />
#<strong>En çok mail attığı gözlemlenen $($topsender.Name) mail adresinden gönderilen son 50 mail aşağıdaki gibidir.</strong><br /><br />
#<strong></strong><br /><br />
#$arraytopsender100
#<br /></font></h5>
#"@