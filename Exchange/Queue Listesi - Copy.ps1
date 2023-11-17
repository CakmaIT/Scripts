$style = "<style>BODY{font-family: Tahoma; font-size: 10pt;}"
$style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}"
$style = $style + "TH{border: 1px solid black; background: #dddddd; padding: 5px; }"
$style = $style + "TD{border: 1px solid black; padding: 5px; }"
$style = $style + "</style>"

Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;

$SMTPHost="smtprelay01.acibadem.com.tr"

$SendingEmail="queue@acibadem.com"

$EmailSubject="Queue Listesi"

$queue=Get-ExchangeServer | Get-Queue -ResultSize unlimited -Filter {MessageCount -gt 1} | select identity, Status, DeliveryType, Messagecount, Nexthopdomain, LastError
$arraytopsenders= $queue | ConvertTo-Html -Head $style

$number=get-transportservice | Get-Queue | Get-Message | Group-Object FromAddress,Count| Sort-Object -Descending count | Where {$_.Count -gt 10} | select Count,Name
$numberstyle= $number | ConvertTo-Html -Head $style


$number1=get-transportservice | Get-Queue | Get-Message | Group-Object Count | Where {$_.Count -gt 10} | select Count | Measure-Object -sum


$EmailBody = @"
<font face=Tahoma>Merhaba,</font><br />
<br />
<br />
<font face=Tahoma>Queue da bulunan 10'un üzerinde gönderim yapan mailboxlar</font><br />
<font face=Tahoma>$numberstyle</font><br />
<br /><br />
<font face=Tahoma>Ayrıntılı Queue listesi aşağıdaki gibidir</font><br />
<font face=Tahoma>$arraytopsenders</font><br />
<br /></font></h5>
"@

Send-MailMessage -To yasar.abravaya@acibadem.com -From $SendingEmail -SmtpServer $SMTPhost -Subject $EmailSubject -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHTML -Priority High


##Send-Mailmessage -smtpServer $SMTPHost -from $SendingEmail -to yasar.abravaya@acibadem.com -Subject $EmailSubject -body ($MessageBody | out-string) -priority High