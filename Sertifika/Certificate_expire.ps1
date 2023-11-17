$Header = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@

#Sunucular
$i = 'gbzexc01','gbzexc02','trisgbexvp001','trisgbexvp002','trisgbsfvp001'


$smtp1 = "mail.yildirimgroup.com"
$to1 = "system.monitor@yildirimgroup.com" 
$from1 = "system.monitor@yildirimgroup.com"
$Subject1 = "Certificate Expire Report - $((Get-Date).ToShortDateString())"
$body1 = Invoke-Command -ComputerName $i {Get-ChildItem Cert:\LocalMachine\My -Recurse | Where-Object {$_ -is [System.Security.Cryptography.X509Certificates.X509Certificate2] -and $_.NotAfter -gt (Get-Date) -and $_.NotAfter -lt (Get-Date).AddDays(30)}}  | ConvertTo-Html  PsComputerName,NotAfter,Subject | Out-String

Send-MailMessage -SmtpServer $smtp1 -To $to1 -From $from1 -Subject $subject1 -Body $body1 -BodyAsHtml