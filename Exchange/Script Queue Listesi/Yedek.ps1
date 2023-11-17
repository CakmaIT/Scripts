$style = "<style>BODY{font-family: Tahoma; font-size: 10pt;}"
$style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}"
$style = $style + "TH{border: 1px solid black; background: #dddddd; padding: 5px; }"
$style = $style + "TD{border: 1px solid black; padding: 5px; }"
$style = $style + "</style>"

Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;

$MailSender = "13466455802@acibadem.com.tr"
$Subject = '13466455802'
$SMTPServer = 'smtprelay01.acibadem.com.tr'

$valuesToLookFor = @(
    'mrharryloanoffer0@gmail.com'
    'mrjohnrichardson89@hotmail.com',
    'j.mcbrian1@aol.com',
    'garryewing93@yahoo.com'
    'gwilliams18443@aol.com'
    )
$MuhtemelSpams=Get-ExchangeServer | Get-MessageTrackingLog -Start (get-date).AddDays(-1) -EventID "SENDEXTERNAL" -ResultSize Unlimited |  Where {$valuesToLookFor -contains $_.Recipients} 
$Victim= $MuhtemelSpams | Group Sender,Count | Select Name,Count | ConvertTo-Html -Head $style

$number=get-transportservice | Get-Queue | Get-Message | Group-Object FromAddress,Count| Sort-Object -Descending count | Where {$_.Count -gt 10} | select Count,Name
$numberstyle= $number | ConvertTo-Html -Head $style

$SubjectTable = @()
$SubjectOrder=Get-ExchangeServer | Get-MessageTrackingLog -Start (get-date).AddDays(-1) -EventID "SENDEXTERNAL" -ResultSize Unlimited | Group-Object -Property Sender,MessageSubject,Count | Sort-Object -Descending Count | Where-Object {$_.Count -gt 15} 
if ($SubjectOrder -ne $Null ) {
$SubjectTable = $SubjectOrder | Select Name,Count | Convertto-Html -Fragment -As Table
}
Else{$SubjectTable = "Aynı subject ile 15'in üzerinde kurum dışına mail atan kullanıcıya rastlanmamıştır."}





$number1=get-transportservice | Get-Queue | Get-Message | Group-Object FromAddress,Count| Sort-Object -Descending count | Where {$_.Count -gt 10} | select Count,Name | Measure-Object -Property 'Count' -Sum | select sum


if ($number1.sum -gt 500) 
{
$EmailBody = @"
<font face=Tahoma>Merhaba,</font><br />
<br />
<font face=Tahoma>Spam adreslerine mail atan kullanıcılar aşağıdaki gibidir.</font><br />
<font face=Tahoma>$Victim</font><br />
<br /><br />
<font face=Tahoma>Queue da bulunan 10'un üzerinde gönderim yapan mailboxlar</font><br />
<font face=Tahoma>$numberstyle</font><br />
<br /><br />
<font face=Tahoma>Gönderilen maillerde Subject'leri aynı olup, 15'den fazla dışarıya mail atan kullanıcılar aşağıdaki gibidir.</font><br />
<font face=Tahoma>$SubjectTable</font><br />
<br /></font></h5>
<br /><br />
"@

Invoke-WebRequest  'http://mm.turatel.com/projects/postsms/sendsms.aspx?Platformid=1&chncode=581&user=acibademsaglik&pw=01122014&from=ACIBADEM.&to=905462624192&text=Queue daki mail sayısı 500 ü geçmiştir ' -Method 'POST'

}
Else {
$EmailBody = @"
<font face=Tahoma>Sorun yok</font><br />
<br />
<br /></font></h5>
"@
}
Start-Sleep -s 1
Send-MailMessage -To yasar.abravaya@acibadem.com -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHTML -Priority High
