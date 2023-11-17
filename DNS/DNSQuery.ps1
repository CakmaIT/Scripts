$Computers = @(
'GMASGDC01.acibadem.com.tr'
'GMASGDC02.acibadem.com.tr'
'GMASGDC03.acibadem.com.tr'
'LABMEDDC01.labmed.saglik.local'
'MOBDC01.mobil.saglik.local'
'GMLABMEDDC.labmed.saglik.local'
'MOBDC02.mobil.saglik.local'
'KDKDC02.acibadem.com.tr'
'KCLDC02.acibadem.com.tr'
'KDKDC01.acibadem.com.tr'
'KCLDC01.acibadem.com.tr'
'KOZDC01.acibadem.com.tr'
'MASDC01.acibadem.com.tr'
'MASDC02.acibadem.com.tr'
'KOZDC02.acibadem.com.tr'
'TKSDC02.acibadem.com.tr'
'TKSDC01.acibadem.com.tr'
'ADADC01.acibadem.com.tr'
'ADADC02.acibadem.com.tr'
'ANKDC02.acibadem.com.tr'
'ANKDC01.acibadem.com.tr'
'ATKDC02.acibadem.com.tr'
'BKRDC01.acibadem.com.tr'
'BKRDC02.acibadem.com.tr'
'BODDC02.acibadem.com.tr'
'BRSDC01.acibadem.com.tr'
'BRSDC02.acibadem.com.tr'
'KAYDC01.acibadem.com.tr'
'KAYDC02.acibadem.com.tr'
'FULDC01.acibadem.com.tr'
'FULDC02.acibadem.com.tr'
'ESKDC1.acibadem.com.tr'
'ESKDC02.acibadem.com.tr'
'SAMCMDC01.acibadem.com.tr'
'SAMCMDC02.acibadem.com.tr'
'APLUSDC01.acibadem.com.tr'
'APLUSDC02.acibadem.com.tr'
'KUCDC01.acibadem.com.tr'
'ALTDC01.acibadem.com.tr'
'ALTDC02.acibadem.com.tr'
'BODDC01.acibadem.com.tr'
'ATKDC01.acibadem.com.tr'
'GMMOBDC01.mobil.saglik.local'
'KUCDC02.acibadem.com.tr'
'INTDC01.acibadem.com.tr'
'INTDC02.acibadem.com.tr'
'DRCDC01.acibadem.com.tr'
'DRCDC02.acibadem.com.tr'
    )

$tarlog=(get-date).ToString(“d_M_yyyy_hh”)
$domainsorgu = @(
'google.com'
'sgk.gov.tr'
'office365.com'
'mcafee.com'
'turkcell.com.tr'
'teamviewer.com'
'differentia.ru'
'disorderstatus.ru'
'ping3.teamviewer.com'
)
$ac= @()
    foreach ($Comp in $Computers){
    #Write-Host $Comp
        foreach ($Sorgu in $domainsorgu){
         Try
                {
				$ab=Resolve-DnsName $Sorgu -Server $Comp | Where {$_.Type -eq "A"} | Select Name,IPAddress,@{Label = 'ServerName'; Expression = {$Comp}}
                $ac += $ab
                }
         Catch
                {
                $ErrorMessage = $_.Exception.Message
                $FailedItem = $_.Exception.ItemName
		        Write-Log -Message $ErrorMessage -LogFile C:\Users\admcicek\Desktop\DNSExport\$Tarlog-DNShatalari.txt -LogLevel ERROR -ConsoleOutput
                Write-Log -Message $FailedItem -LogFile C:\Users\admcicek\Desktop\DNSExport\$Tarlog-DNShatalari.txt -LogLevel ERROR -ConsoleOutput 
                                }


}
}
$ac | Export-Csv C:\Users\admcicek\Desktop\DNSExport\$tarlog.csv
$style = "<style>BODY{font-family: Arial; font-size: 10pt;}"
$style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}"
$style = $style + "TH{border: 1px solid black; background: #dddddd; padding: 5px; }"
$style = $style + "TD{border: 1px solid black; padding: 5px; }"
$style = $style + "</style>"

$acarrayoutput = $ac | ConvertTo-Html -Head $style 

$MailSender = "RoksitKontrol@acibadem.com"
$Subject = 'Roksit DNS Sunucuları Raporu'
$SMTPServer = 'smtprelay01.acibadem.com.tr'
$SendtoMail = "kamil.cicek@acibadem.com"
#$SendtoMail = "acibademsistemyonetimi@acibadem.com"
$EmailBody = @"
<font face=Tahoma>Merhaba,</font><br />
<br />
<font face=Tahoma>Roksit DNS Sunucuları Raporu aşağıdaki gibidir.</font><br />
<br />
<strong>$acarrayoutput</strong><br /><br />

<br /></font></h5>
"@

Start-Sleep -s 5
Send-MailMessage -To $SendtoMail -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHTML -Priority High


