$user='ahmet.akgul1'

$UserInfo = Get-ADUser $user -Properties * | select CN,emailaddress,department,title,office

$Group=Get-ADGroup -Identity "CN=ASG_SPAM_OUTBOUND_DENY,OU=Old Email Groups,OU=68 Email Groups,DC=acibadem,DC=com,DC=tr" -Server "acibadem.com.tr"

Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;

Disable-ADAccount -Identity $user

Add-ADGroupMember -Identity $Group -Members $User

Set-Mailbox $UserInfo.emailaddress -ProhibitSendQuota 0.01GB -IssueWarningQuota 0.01GB –ProhibitSendReceiveQuota 1GB -UseDatabaseQuotaDefaults $false


Get-TransportService | Get-Queue | Get-Message -ResultSize unlimited | Where {$_.FromAddress -eq "ahmet.akgul1@acibadem.com"} | Suspend-Message -Confirm:$False

Get-TransportService | Get-Queue | Get-Message -ResultSize unlimited | Where {$_.FromAddress -eq "ahmet.akgul1@acibadem.com"} | Remove-Message -WithNDR $False -Confirm:$False


####################################################################################3

$style = "<style>BODY{font-family: Tahoma; font-size: 10pt;}"
$style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}"
$style = $style + "TH{border: 1px solid black; background: #dddddd; padding: 5px; }"
$style = $style + "TD{border: 1px solid black; padding: 5px; }"
$style = $style + "</style>"

Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;

$SMTPHost="smtprelay01.acibadem.com.tr"

$SendingEmail="queue@acibadem.com"

$EmailSubject="Queue Listesi"

$queue=Get-ExchangeServer | Get-Queue -ResultSize unlimited -Filter {MessageCount -gt 1} | select name, identity, Status, DeliveryType, Messagecount, Nexthopdomain, LastError
$arraytopsenders= $queue | ConvertTo-Html -Head $style

$number=get-transportservice | Get-Queue | Get-Message | Group-Object FromAddress,Count| Sort-Object -Descending count | Where {$_.Count -gt 10} | select Count,Name
$numberstyle= $number | ConvertTo-Html -Head $style


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

#################################################################

$style1 = "<style>BODY{font-family: Tahoma; font-size: 10pt;}"
$style1 = $style1 + "TABLE{border: 1px solid black; border-collapse: collapse;}"
$style1 = $style1 + "TH{border: 1px solid black; background: #dddddd; padding: 5px; }"
$style1 = $style1 + "TD{border: 1px solid black; padding: 5px; }"
$style1 = $style1 + "</style>"

$userinfotyle= $UserInfo| ConvertTo-Html -Head $style1

$Sahasender="saha@acibadem.com"

$SahaSubject="Hacklenen Kullanıcı Hk."

$SahaBody = @"
<font face=Tahoma>Merhaba,</font><br />
<br />
<font face=Tahoma>Aşağıdaki kullanıcının hesabı ele geçirilmiştir.</font><br />
<br /><br />
<font face=Tahoma>$userinfotyle</font><br />
<br /><br />
<font face=Tahoma>Saha Yöneticilerinin gerekli aksiyonu almasını rica ederiz</font><br />
<br /></font></h5>
"@


Send-MailMessage -To yasar.abravaya@acibadem.com -From $Sahasender -SmtpServer $SMTPhost -Subject $SahaSubject -Body $SahaBody -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHTML -Priority High

#############################################################