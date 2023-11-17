$session=New-PSSession -ComputerName GMASGDC03
Enter-PSSession $session

Invoke-Command -Session $session {
import-Module ActiveDirectory

$ZoneName = "acibadem.com.tr"
$NumberOfDaysBack = 10
$DateInThePast = (Get-Date).AddDays(-$NumberOfDaysBack)
$Tar = (Get-Date -Format dd_MM_yy)

       #$RecordsArray = Get-DnsServerResourceRecord -ZoneName $ZoneName -RRType A | Where-Object {($_.Timestamp -lt $DateInThePast) -and ($_.Timestamp -ne $null)} | Where-Object {($_.Hostname -match "^[0-9][0-9][N-P]")}
       $RecordsArray = Get-DnsServerResourceRecord -ZoneName acibadem.com.tr -RRType A | Where-Object {($_.Timestamp -lt $DateInThePast) -and ($_.Timestamp -ne $null)} | Where-Object {($_.Hostname -match "^[0-9][0-9][NP]") -or ($_.Hostname -match "^[B][S][-]")}
       $RecordsArray | Export-Csv -Path C:\Disable_Computer\$Tar'_'$ZoneName.csv -NoTypeInformation -Append
       $RecordsCounter = $RecordsArray.Count
           if ($RecordsArray)
		{
		   foreach($Record in $RecordsArray)
            {
                Try
                {
				Remove-DnsServerResourceRecord -ZoneName "acibadem.com.tr" -RRType A -Name $Record.HostName -Force
                }
                Catch
                {
                $ErrorMessage = $_.Exception.Message
                $FailedItem = $_.Exception.ItemName
		        Write-Log -Message $ErrorMessage -LogFile C:\Temp\Dns_Logs\$Tar-DNShatalari.txt -LogLevel ERROR -ConsoleOutput
                Write-Log -Message $FailedItem -LogFile C:\Temp\Dns_Logs\$Tar-DNShatalari.txt -LogLevel ERROR -ConsoleOutput 
                }
				
            }
        }
        else
        {
            $RecordsArray | Export-Csv -Path C:\Disable_Computer\$Tar'_'$ZoneName.csv -NoTypeInformation -Append
        }
		
$ZoneName02 = "mobil.saglik.local"
$NumberOfDaysBack02 = 8
$DateInThePast = (Get-Date).AddDays(-$NumberOfDaysBack02)
$Tar = (Get-Date -Format dd_MM_yy)

       $RecordsArray02 = Get-DnsServerResourceRecord -ZoneName mobil.saglik.local -RRType A | Where-Object {($_.Timestamp -lt $DateInThePast) -and ($_.Timestamp -ne $null)} | Where-Object {($_.Hostname -match "^[8][4][NP]") -or ($_.Hostname -match "^[B][S][-]")}
       $RecordsArray02 | Export-Csv -Path C:\Disable_Computer\$Tar'_'$ZoneName02.csv -NoTypeInformation -Append
       $MobilRecordsCounter = ($RecordsArray02 | Measure-Object).Count
           if ($RecordsArray02)
		{
		   foreach($Record in $RecordsArray02)
            {
                Try
                {
				Remove-DnsServerResourceRecord -ZoneName "mobil.saglik.local" -RRType A -Name $Record.HostName -Force
                }
                Catch
                {
                $ErrorMessage = $_.Exception.Message
                $FailedItem = $_.Exception.ItemName
		        Write-Log -Message $ErrorMessage -LogFile C:\Temp\Dns_Logs\$Tar-DNShatalari.txt -LogLevel ERROR -ConsoleOutput
                Write-Log -Message $FailedItem -LogFile C:\Temp\Dns_Logs\$Tar-DNShatalari.txt -LogLevel ERROR -ConsoleOutput 
                }
				
            }
        }
        else
        {
            $RecordsArray02 | Export-Csv -Path C:\Disable_Computer\$Tar'_'$ZoneName02.csv -NoTypeInformation -Append
        }

$ZoneName03 = "labmed.saglik.local"
$NumberOfDaysBack03 = 8
$DateInThePast = (Get-Date).AddDays(-$NumberOfDaysBack03)
$Tar = (Get-Date -Format dd_MM_yy)

       $RecordsArray03 = Get-DnsServerResourceRecord -ZoneName labmed.saglik.local -RRType A | Where-Object {($_.Timestamp -lt $DateInThePast) -and ($_.Timestamp -ne $null)} | Where-Object {($_.Hostname -match "^[7][9][NP]") -or ($_.Hostname -match "^[B][S][-]")}
       $RecordsArray03 | Export-Csv -Path C:\Disable_Computer\$Tar'_'$ZoneName03.csv -NoTypeInformation -Append
       $LabmedRecordsCounter = ($RecordsArray03 | Measure-Object).Count
           if ($RecordsArray03)
		{
		   foreach($Record in $RecordsArray03)
            {
                Try
                {
				Remove-DnsServerResourceRecord -ZoneName "labmed.saglik.local" -RRType A -Name $Record.HostName -Force
                }
                Catch
                {
                $ErrorMessage = $_.Exception.Message
                $FailedItem = $_.Exception.ItemName
		        Write-Log -Message $ErrorMessage -LogFile C:\Temp\Dns_Logs\$Tar-DNShatalari.txt -LogLevel ERROR -ConsoleOutput
                Write-Log -Message $FailedItem -LogFile C:\Temp\Dns_Logs\$Tar-DNShatalari.txt -LogLevel ERROR -ConsoleOutput 
                }
				
            }
        }
        else
        {
            $RecordsArray03 | Export-Csv -Path C:\Disable_Computer\$Tar'_'$ZoneName03.csv -NoTypeInformation -Append
        }		
	

Start-Sleep -s 10

  
$files = Get-ChildItem -Path C:\Disable_Computer\$Tar*.csv
#$body = @()
$EmailBody = @"

<font face=Tahoma>Acıbadem'den <strong>$RecordsCounter</strong> Mobil'den <strong>$MobilRecordsCounter</strong> Labmed'den <strong>$LabmedRecordsCounter</strong> eski dns kaydı temizlenmiştir.<br />
<br />
Detayları ekteki gibidir.
"@
$attachments = @()
foreach($file in $files){
    $filename = [system.io.path]::GetFileName($file.FullName)
    $attachments += $file.fullname
    
}
#$body += "Active Directory'den $Deladet bilgisayar silinmiş, $disadet bilgisayar disable edilmis ve Acıbadem'den $RecordsCounter Mobil'den $RecordsCounter02 Labmed'den $RecordsCounter03 eski dns kaydı temizlenmiştir. Detayları ekteki gibidir."
#$body = $body | Out-String
Send-MailMessage -to Asgbtsistemyonetimi@acibadem.com.tr -From ActiveDirectory@acibadem.com.tr -SmtpServer smtprelay01.acibadem.com.tr -Subject "AD DNS Cleanup $deletedateFilename" -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHtml $EmailBody -Attachments $attachments
#Send-MailMessage -to kamil.cicek@acibadem.com.tr -From ActiveDirectory@acibadem.com.tr -SmtpServer smtprelay01.acibadem.com.tr -Subject "AD Computer Cleanup $deletedateFilename" -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHtml $EmailBody -Attachments $attachments

##SecondScript
##Password Notifier
Start-Sleep -s 5
#Start-Transcript C:\Batch\test.txt
$Ausers = Get-Aduser -SearchBase "OU=04_AD_BT_Admin_Users,OU=Groups,DC=acibadem,DC=com,DC=tr" -Filter {Enabled -eq $True -and PasswordNeverExpires -eq $False -and PasswordLastSet -gt 0} –Properties "Manager", "SamAccountName","msDS-UserPasswordExpiryTimeComputed" | Where-Object {($_.manager -ne $null)} | Where-Object {($_.SamAccountName -ne "admin95209")} | Select-Object -Property "SamAccountName", @{Name="ManagerEmail";Expression={(get-aduser -property emailaddress $_.manager).emailaddress}} ,@{Name="ExpireDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed").tolongdatestring()}}
$5Day = (get-date).adddays(5).ToLongDateString()
$4Day = (get-date).adddays(4).ToLongDateString()
$3Day = (get-date).adddays(3).ToLongDateString()
$2Day = (get-date).adddays(2).ToLongDateString()
$1Day = (get-date).adddays(1).ToLongDateString()	
#$BccMail = "kamil.cicek@acibadem.com"
$today=(Get-Date -Format dd/MM/yyyy)

$MailSender = "acibademsistemyonetimi@acibadem.com"
$Subject = 'Admin hesabınızın şifresi expire olmak üzere'
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
Send-MailMessage -To $user.ManagerEmail -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHTML -Priority High
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
Send-MailMessage -To $user.ManagerEmail -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHTML -Priority High
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
Send-MailMessage -To $user.ManagerEmail -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHTML -Priority High
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
Send-MailMessage -To $user.ManagerEmail -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHTML -Priority High
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
Send-MailMessage -To $user.ManagerEmail -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHTML -Priority High
}

else {}
} 

Start-Sleep -s 40

$Tar = (Get-Date -Format dd_MM_yy)
$DaysAgo=(Get-Date).AddDays(-240)
Get-ADComputer -Filter {(PwdLastSet -lt $DaysAgo)} -Properties PwdLastSet,LastLogonTimeStamp,Description,OperatingSystem |Select-Object -Property DistinguishedName,Name,Enabled,Description,OperatingSystem, `
@{Name="PwdLastSet";Expression={[datetime]::FromFileTime($_.PwdLastSet)}}, `
@{Name="LastLogonTimeStamp";Expression={[datetime]::FromFileTime($_.LastLogonTimeStamp)}},
@{Name="PwdAge";Expression={if($_.PwdLastSet -ne 0){(new-TimeSpan([datetime]::FromFileTimeUTC($_.PwdLastSet)) $(Get-Date)).days}else{0}}} | Export-Csv -Path c:\temp\$Tar'_'possible_stale_computers.csv -NoTypeInformation -Encoding Unicode
$StaleBilgisayarCount = ( Get-ADComputer -Filter {(PwdLastSet -lt $DaysAgo)} ).Count


$filesStaleComp = Get-ChildItem -Path C:\temp\ | Where-Object {$_.Name -like "$Tar*possible_stale_*"} 
#$body = @()
$EmailBody = @"
<font face=Tahoma>Merhaba,</font><br />
<br />
<font face=Tahoma>Active Directory'de <strong>$StaleBilgisayarCount</strong> adet Computer 240 günden daha uzun süredir Password'unu değiştirmemiştir.</font><br />
<br />
<font face=Tahoma>Detayları ekteki gibidir.</font><br />
"@
$attachmentsStaleComp = @()
foreach($file in $filesStaleComp){
    $filename = [system.io.path]::GetFileName($file.FullName)
    $attachmentsStaleComp += $file.fullname
} 
Send-MailMessage -To Asgbtsistemyonetimi@acibadem.com -From ActiveDirectory@acibadem.com.tr -SmtpServer smtprelay01.acibadem.com.tr -Subject "AD Computer Password Change Control $Tar" -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHtml $EmailBody -Attachments $attachmentsStaleComp

#Stop-Transcript

}

Exit-PSSession
Remove-PSSession $session

