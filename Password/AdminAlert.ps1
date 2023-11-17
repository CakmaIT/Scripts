$Ausers = Get-Aduser -SearchBase "OU=04_AD_BT_Admin_Users,OU=Groups,DC=acibadem,DC=com,DC=tr" -Filter {Enabled -eq $True -and PasswordNeverExpires -eq $False -and PasswordLastSet -gt 0} –Properties "Manager", "DisplayName","msDS-UserPasswordExpiryTimeComputed" | Where {($_.manager -ne $null)} | Select-Object -Property "Displayname",@{Name="ManagerEmail";Expression={(get-aduser -property emailaddress $_.manager).emailaddress}},@{Name="ExpireDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed").tolongdatestring()}}
$7Day = (get-date).adddays(7).ToLongDateString()
$6Day = (get-date).adddays(6).ToLongDateString()
$5Day = (get-date).adddays(5).ToLongDateString()
$4Day = (get-date).adddays(4).ToLongDateString()
$3Day = (get-date).adddays(3).ToLongDateString()
$2Day = (get-date).adddays(2).ToLongDateString()
$1Day = (get-date).adddays(1).ToLongDateString()
$EmailStub1 = 'Bu mail Sistem Yonetimi tarafindan otomatik olarak gonderilmektedir.'
$EmailStub2 = 'isimli hesabiniz'
$EmailStub3 = 'gun icerisinde expire olacaktir. ('
$EmailStub4 = ').Sifreniz expire olmadan degistiriniz.Sifreniz expire olursa kisisel bilgisayarlarinizda admin hesaplarinizi ile login olarak password degisikligi gerceklestirebilirsiniz. '


$MailSender = "acibademsistemyonetimi@acibadem.com"
$Subject = 'Admin hesabinizin sifresi expire olmak uzere'
$SMTPServer = 'smtprelay01.acibadem.com.tr'

foreach ($user in $Ausers) {
 if ($user.ExpireDate -eq $7Day) {
 $days = 7
 $EmailBody = $EmailStub1, $user.Displayname, $EmailStub2, $days, $EmailStub3,  $7Day ,$EmailStub4 -join ' '
Send-MailMessage -To $user.ManagerEmail -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode)
 
 }
elseif ($user.ExpireDate -eq $6Day) {
$days = 6
 $EmailBody = $EmailStub1, $user.Displayname, $EmailStub2, $days, $EmailStub3,  $6Day, $EmailStub4 -join ' '
Send-MailMessage -To $user.ManagerEmail -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode)
 }
elseif ($user.ExpireDate -eq $5Day) {
  $days = 5
 $EmailBody = $EmailStub1, $user.Displayname, $EmailStub2, $days, $EmailStub3,  $5Day, $EmailStub4 -join ' '
 Send-MailMessage -To $user.ManagerEmail -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode)
 }
elseif ($user.ExpireDate -eq $4Day) {
$days = 4
 $EmailBody = $EmailStub1, $user.Displayname, $EmailStub2, $days, $EmailStub3,  $4Day, $EmailStub4 -join ' '
 Send-MailMessage -To $user.ManagerEmail -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode)
 }
elseif ($user.ExpireDate -eq $3Day) {
  $days = 3
 $EmailBody = $EmailStub1, $user.Displayname, $EmailStub2, $days, $EmailStub3,  $3Day, $EmailStub4 -join ' '
Send-MailMessage -To $user.ManagerEmail -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode)
 }
elseif ($user.ExpireDate -eq $2Day) {
$days = 2
 $EmailBody = $EmailStub1, $user.Displayname, $EmailStub2, $days, $EmailStub3,  $2Day, $EmailStub4 -join ' '
Send-MailMessage -To $user.ManagerEmail -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode)
 }
 elseif ($user.ExpireDate -eq $1Day) {
 $days = 1
 $EmailBody = $EmailStub1, $user.Displayname, $EmailStub2, $days, $EmailStub3, $1Day, $EmailStub4 -join ' '
Send-MailMessage -To $user.ManagerEmail -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode)
 }
 else {}
 }