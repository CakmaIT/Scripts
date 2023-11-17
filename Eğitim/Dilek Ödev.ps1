param (
[string]$user = $( Read-Host "lütfen kullanıcı adını girin" )
)
$gonderici = "karadenizlizehra@acibadem.com"
$SMTP = "smtprelay01.acibadem.com.tr"
$baslik = "eee bilgilendirme de"
$style = ""
$userinfo = get-aduser $user -Properties * | select displayname, emailaddress , description
$userinfohtml = $userinfo | ConvertTo-Html -Head $style
$EmailBody = @"


$userinfohtml


"@
$ek = "C:\tel.txt"
Send-MailMessage -To $userinfo.EmailAddress -From $gonderici -SmtpServer $SMTP -Subject $baslik -Body $EmailBody -Attachments $ek -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHTML
