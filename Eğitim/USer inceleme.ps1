 param (
    
    [string]$user = $( Read-Host "lütfen kullanıcı adını girin" )
   
 )


$gonderici = "userinceleme@acibadem.com"
$SMTP = "smtprelay01.acibadem.com.tr"
$baslik = "User inceleme"

$style = "<style>BODY{font-family: Tahoma; font-size: 10pt;}"
$style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}"
$style = $style + "TH{border: 1px solid black; background: #dddddd; padding: 5px; }"
$style = $style + "TD{border: 1px solid black; padding: 5px; }"
$style = $style + "</style>"

$userinfo = get-aduser $user -Properties * | Select DisplayName,Description,EmailAddress,Office,Department ,Title 
$userinfohtml = $userinfo | ConvertTo-Html -Head $style

$userinfo1 = get-aduser $user -Properties * | Select Created,Modified,PasswordLastSet,PasswordNeverExpires,LastLogonDate,LastBadPasswordAttempt
$userinfohtml1 = $userinfo1 | ConvertTo-Html -Head $style

Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;

$userinfo2 = Get-Mailbox $user | select IssueWarningQuota,UseDatabaseQuotaDefaults,DatabaseIssueWarningQuota
$userinfohtml2 = $userinfo2 | ConvertTo-Html -Head $style

$userinfo3 = Get-MailboxStatistics $user | select totalitemsize,Database,ServerName
$userinfohtml3 = $userinfo3 | ConvertTo-Html -Head $style




$EmailBody = @"
<br />
<font face=Tahoma>$userinfohtml</font><br />
<br />
<font face=Tahoma>$userinfohtml1</font><br />
<br />
<font face=Tahoma>$userinfohtml2</font><br />
<br />
<font face=Tahoma>$userinfohtml3</font><br />
<br />
<br /></font></h5>
"@



Send-MailMessage -To yasar.abravaya@acibadem.com -From $gonderici -SmtpServer $SMTP -Subject $baslik -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHTML




Get-Mailbox -identity yasar.abravaya | select ProhibitSendQuota