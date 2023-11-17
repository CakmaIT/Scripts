$session=New-PSSession -ComputerName ASG100MGR01
Enter-PSSession $session

Invoke-Command -Session $session {
$Source      = Get-ChildItem "C:\Program Files\McAfee\Content Security Reporter\reporter\log\server*.log*" | Where-Object {$_.Name -notlike "*.zip" -and $_.LastWriteTime -lt (Get-Date).AddDays(-7)}| Where-Object {$_.Name -notlike "*.rar"}
$Destination = "C:\Program Files\McAfee\Content Security Reporter\reporter\log\"
$RarApp      = "C:\tools\Compress\rar.exe" 
ForEach ($files in $Source) { 
    & $RarApp a -df $($Destination + $files.Name + ".rar") $($files.FullName)
    Get-Process rar | Wait-Process
    }
$style = "<style>BODY{font-family: Arial; font-size: 10pt;}"
$style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}"
$style = $style + "TH{border: 1px solid black; background: #dddddd; padding: 5px; }"
$style = $style + "TD{border: 1px solid black; padding: 5px; }"
$style = $style + "</style>"

$LastLogFiles = Get-ChildItem "C:\Program Files\McAfee\Content Security Reporter\reporter\log\server*.log*" | Where-Object {$_.Name -notlike "*.zip" -and $_.LastWriteTime -gt ((Get-Date).AddDays(-2))}| Where-Object {$_.Name -notlike "*.rar"} | Sort-Object LastWriteTime | Select-Object Name,LastWriteTime,@{Name="Size/MB";Expression={"{0:F2}" -f ($_.length/1MB)}} | ConvertTo-Html -Head $style
$MailSender = "EpoCheck@acibadem.com"
$Subject = 'Asg100MGR01 üzerindeki log sizeleri'
$SMTPServer = 'smtprelay01.acibadem.com.tr'
$SendtoMail = "Asgbtsistemyonetimi@acibadem.com"
$EmailBody = @"
<font face=Tahoma>Merhaba,</font><br />
<br />
<font face=Tahoma>Güncel Log dosyaları ve sizeleri aşağıdaki gibidir.</font><br />
<br />
<strong>$LastLogFiles</strong><br /><br />
<br /></font></h5>
"@

Start-Sleep -s 1
Send-MailMessage -To $SendtoMail -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHTML -Priority High
}
Exit-PSSession 
Remove-PSSession $session