

$today=(Get-Date -Format dd_MM_yyyy_hh_mm)
$SMTPServer= "smtprelay01.acibadem.com.tr"
$Bilgisayar=$env:computername
$Subject=$Bilgisayar
$EmailBody = @"
<font face=Tahoma>Merhaba,</font><br />
<br />
<font face=Tahoma> Mcafee Bilesenleri ile ilgili islem <strong>$Bilgisayar</strong> isimli makinada tamamlanmistir. Restart edilmesi gerekmektedir..</font><br />

<font face=Tahoma>Rapor olusturma tarihi : $today </font><br />

"@
Start-Sleep -s 1
Send-MailMessage -To dilek.dogan@acibadem.com.tr -Bcc kamil.cicek@acibadem.com.tr -From McafeeOps@acibadem.com.tr -SmtpServer $SMTPServer -Subject $Subject -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHTML -Priority High
Remove-Item MEPU.exe