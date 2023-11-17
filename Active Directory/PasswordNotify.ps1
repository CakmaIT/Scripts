Start-Transcript C:\Batch\test.txt
$Ausers = Get-Aduser -SearchBase "OU=04_AD_BT_Admin_Users,OU=Groups,DC=acibadem,DC=com,DC=tr" -Filter {Enabled -eq $True -and PasswordNeverExpires -eq $False -and PasswordLastSet -gt 0} –Properties "Manager", "SamAccountName","msDS-UserPasswordExpiryTimeComputed" | Where-Object {($_.manager -ne $null)} | Select-Object -Property "SamAccountName", @{Name="ManagerEmail";Expression={(get-aduser -property emailaddress $_.manager).emailaddress}} ,@{Name="ExpireDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed").tolongdatestring()}}
$5Day = (get-date).adddays(5).ToLongDateString()
$4Day = (get-date).adddays(4).ToLongDateString()
$3Day = (get-date).adddays(3).ToLongDateString()
$2Day = (get-date).adddays(2).ToLongDateString()
$1Day = (get-date).adddays(1).ToLongDateString()
$BccMail = "kamil.cicek@acibadem.com"
$today=Get-Date

$MailSender = "acibademsistemyonetimi@acibadem.com"
$Subject = 'Admin hesabinizin sifresi expire olmak uzere'
$SMTPServer = 'smtprelay01.acibadem.com.tr'

foreach ($user in $Ausers) {
if ($user.ExpireDate -eq $5Day) {
$days = 5
$Hesap= $User.SamAccountName
$EmailBody = @"
<font face=Tahoma>Merhaba,</font><br />
<br />
<font face=Tahoma>Bu mail Sistem Yönetimi tarafından otomatik olarak gönderilmektedir.</font><br />
<font face=Tahoma><strong>$Hesap</strong> hesabınızın şifresi <font color=red><strong>$days</strong></font> gün içerisinde expire olacaktır.
(<strong>$5Day</strong>)<br /><br />
Parolanızı değiştirme işlemini kişisel bilgisayarlarınıza admin hesabiniz ile login olarak  <strong>CTRL-ALT-DEL</strong> tuşları yardımıyla <strong>Parolayı değiştir</strong> seçerek gerçekleştirebilirsiniz.<br /><br />
Yeni şifreniz <strong>en az 8 karakterden </strong> oluşmalıdir.
Aşağıdaki kriterleri sağlamalıdır.<br /><br />
    En az 1 Büyük Harf <strong>(A-Z)</strong><br />
    En az 1 Küçük Harf  <strong>(a-z)</strong><br />
    En az 1 Rakam <strong>(0-9)</strong><br />
    En az 1 Sembol <strong>(!"£$%^&*)</strong><br /><br />
Herhangi bir sorunuz olursa, Sistem Destek ekibi ile iletişime geçebilirsiniz.<br /><br />
Rapor oluşturma tarihi : $today<br /><br />
_____________ <br />
<br /></font></h5>
"@
Start-Sleep -s 1
Send-MailMessage -To $user.ManagerEmail -Bcc $BccMail -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHTML -Priority High
}
elseif ($user.ExpireDate -eq $4Day) {
$days = 4
$Hesap= $User.SamAccountName

$EmailBody = @"
<font face=Tahoma>Merhaba,</font><br />
<br />
<font face=Tahoma>Bu mail Sistem Yönetimi tarafından otomatik olarak gönderilmektedir.</font><br />
<font face=Tahoma><strong>$Hesap</strong> hesabınızın şifresi <font color=red><strong>$days</strong></font> gün içerisinde expire olacaktır.
(<strong>$4Day</strong>)<br /><br />
Parolanızı değiştirme işlemini kişisel bilgisayarlarınıza admin hesabiniz ile login olarak  <strong>CTRL-ALT-DEL</strong> tuşları yardımıyla <strong>Parolayı değiştir</strong> seçerek gerçekleştirebilirsiniz.<br /><br />
Yeni şifreniz <strong>en az 8 karakterden </strong> oluşmalıdir.
Aşağıdaki kriterleri sağlamalıdır.<br /><br />
    En az 1 Büyük Harf <strong>(A-Z)</strong><br />
    En az 1 Küçük Harf  <strong>(a-z)</strong><br />
    En az 1 Rakam <strong>(0-9)</strong><br />
    En az 1 Sembol <strong>(!"£$%^&*)</strong><br /><br />
Herhangi bir sorunuz olursa, Sistem Destek ekibi ile iletişime geçebilirsiniz.<br /><br />
Rapor oluşturma tarihi : $today<br /><br />
_____________ <br />
<br /></font></h5>
"@
Start-Sleep -s 1
Send-MailMessage -To $user.ManagerEmail -Bcc $BccMail -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHTML -Priority High
}
elseif ($user.ExpireDate -eq $3Day) {
$days = 3
$Hesap= $User.SamAccountName

$EmailBody = @"
<font face=Tahoma>Merhaba,</font><br />
<br />
<font face=Tahoma>Bu mail Sistem Yönetimi tarafından otomatik olarak gönderilmektedir.</font><br />
<font face=Tahoma><strong>$Hesap</strong> hesabınızın şifresi <font color=red><strong>$days</strong></font> gün içerisinde expire olacaktır.
(<strong>$3Day</strong>)<br /><br />
Parolanızı değiştirme işlemini kişisel bilgisayarlarınıza admin hesabiniz ile login olarak  <strong>CTRL-ALT-DEL</strong> tuşları yardımıyla <strong>Parolayı değiştir</strong> seçerek gerçekleştirebilirsiniz.<br /><br />
Yeni şifreniz <strong>en az 8 karakterden </strong> oluşmalıdir.
Aşağıdaki kriterleri sağlamalıdır.<br /><br />
    En az 1 Büyük Harf <strong>(A-Z)</strong><br />
    En az 1 Küçük Harf  <strong>(a-z)</strong><br />
    En az 1 Rakam <strong>(0-9)</strong><br />
    En az 1 Sembol <strong>(!"£$%^&*)</strong><br /><br />
Herhangi bir sorunuz olursa, Sistem Destek ekibi ile iletişime geçebilirsiniz.<br /><br />
Rapor oluşturma tarihi : $today<br /><br />
_____________ <br />
<br /></font></h5>
"@
Start-Sleep -s 1
Send-MailMessage -To $user.ManagerEmail -Bcc $BccMail -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHTML -Priority High
}
elseif ($user.ExpireDate -eq $2Day) {
$days = 2
$Hesap= $User.SamAccountName

$EmailBody = @"
<font face=Tahoma>Merhaba,</font><br />
<br />
<font face=Tahoma>Bu mail Sistem Yönetimi tarafından otomatik olarak gönderilmektedir.</font><br />
<font face=Tahoma><strong>$Hesap</strong> hesabınızın şifresi <font color=red><strong>$days</strong></font> gün içerisinde expire olacaktır.
(<strong>$2Day</strong>)<br /><br />
Parolanızı değiştirme işlemini kişisel bilgisayarlarınıza admin hesabiniz ile login olarak  <strong>CTRL-ALT-DEL</strong> tuşları yardımıyla <strong>Parolayı değiştir</strong> seçerek gerçekleştirebilirsiniz.<br /><br />
Yeni şifreniz <strong>en az 8 karakterden </strong> oluşmalıdir.
Aşağıdaki kriterleri sağlamalıdır.<br /><br />
    En az 1 Büyük Harf <strong>(A-Z)</strong><br />
    En az 1 Küçük Harf  <strong>(a-z)</strong><br />
    En az 1 Rakam <strong>(0-9)</strong><br />
    En az 1 Sembol <strong>(!"£$%^&*)</strong><br /><br />
Herhangi bir sorunuz olursa, Sistem Destek ekibi ile iletişime geçebilirsiniz.<br /><br />
Rapor oluşturma tarihi : $today<br /><br />
_____________ <br />
<br /></font></h5>
"@
Start-Sleep -s 1
Send-MailMessage -To $user.ManagerEmail -Bcc $BccMail -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHTML -Priority High
}
elseif ($user.ExpireDate -eq $1Day) {
$days = 1
$Hesap= $User.SamAccountName

$EmailBody = @"
<font face=Tahoma>Merhaba,</font><br />
<br />
<font face=Tahoma>Bu mail Sistem Yönetimi tarafından otomatik olarak gönderilmektedir.</font><br />
<font face=Tahoma><strong>$Hesap</strong> hesabınızın şifresi <font color=red><strong>$days</strong></font> gün içerisinde expire olacaktır.
(<strong>$1Day</strong>)<br /><br />
Parolanızı değiştirme işlemini kişisel bilgisayarlarınıza admin hesabiniz ile login olarak  <strong>CTRL-ALT-DEL</strong> tuşları yardımıyla <strong>Parolayı değiştir</strong> seçerek gerçekleştirebilirsiniz.<br /><br />
Yeni şifreniz <strong>en az 8 karakterden </strong> oluşmalıdir.
Aşağıdaki kriterleri sağlamalıdır.<br /><br />
    En az 1 Büyük Harf <strong>(A-Z)</strong><br />
    En az 1 Küçük Harf  <strong>(a-z)</strong><br />
    En az 1 Rakam <strong>(0-9)</strong><br />
    En az 1 Sembol <strong>(!"£$%^&*)</strong><br /><br />
Herhangi bir sorunuz olursa, Sistem Destek ekibi ile iletişime geçebilirsiniz.<br /><br />
Rapor oluşturma tarihi : $today<br /><br />
_____________ <br />
<br /></font></h5>
"@
Start-Sleep -s 1
Send-MailMessage -To $user.ManagerEmail -Bcc $BccMail -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHTML -Priority High
}

else {}
} 

Stop-Transcript