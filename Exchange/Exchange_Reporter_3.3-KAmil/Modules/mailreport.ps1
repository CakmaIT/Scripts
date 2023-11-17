$mailreport = Generate-ReportHeader "mailreport.png" "$l_mail_header"

$deltas = ((Get-Date).DayOfWeek.value__ - 1)
$Ended = (Get-Date).AddDays(-$delta).Date
$Started = ($Ended.AddDays(-7)).AddMilliseconds(+1000)

$cells=@("$l_mail_sendcount","$l_mail_reccount","$l_mail_volsend","$l_mail_volrec")
$mailreport += Generate-HTMLTable "$l_mail_header2 $ReportInterval $l_mail_days" $cells

$mailexclude = ($excludelist | where {$_.setting -match "mailreport"}).value
if ($mailexclude)
	{
		[array]$mailexclude = $mailexclude.split(",")
	}

if ($emsversion -match "2016")
{
 $SendMails = Get-TransportService | Get-MessageTrackingLog -Start $Started -end $Ended -EventId Send -ea 0 -resultsize unlimited | where {$_.Recipients -notmatch "HealthMailbox" -and $_.Sender -notmatch "MicrosoftExchange" -and $_.source -match "SMTP"} | select sender,Recipients,timestamp,totalbytes,clienthostname
 $ReceivedMails = Get-TransportService | Get-MessageTrackingLog -Start $Started -end $Ended -EventId Receive -ea 0 -resultsize unlimited | where {$_.Recipients -notmatch "HealthMailbox" -and $_.Sender -notmatch "MicrosoftExchange" -and $_.source -match "SMTP"} | select sender,Recipients,timestamp,totalbytes,serverhostname
}

if ($emsversion -match "2013")
{
 $transportservers = Get-TransportService
 $SendMails = Get-TransportService | Get-MessageTrackingLog -Start $Start -end $End -EventId Send -ea 0 -resultsize unlimited | where {$_.Recipients -notmatch "HealthMailbox" -and $_.Sender -notmatch "MicrosoftExchange" -and $_.source -match "SMTP"} | select sender,Recipients,timestamp,totalbytes,clienthostname
 $ReceivedMails = Get-TransportService | Get-MessageTrackingLog -Start $Start -end $End -EventId Receive -ea 0 -resultsize unlimited | where {$_.Recipients -notmatch "HealthMailbox" -and $_.Sender -notmatch "MicrosoftExchange" -and $_.source -match "SMTP"} | select sender,Recipients,timestamp,totalbytes,serverhostname
}

if ($emsversion -match "2010")
{
 $transportservers = Get-TransportServer
 $SendMails = Get-TransportServer | Get-MessageTrackingLog -Start $Start -end $End -EventId Send -ea 0 -resultsize unlimited | where {$_.Recipients -notmatch "HealthMailbox" -and $_.Sender -notmatch "MicrosoftExchange" -and $_.source -match "SMTP"} | select sender,Recipients,timestamp,totalbytes,clienthostname
 $ReceivedMails = Get-TransportServer | Get-MessageTrackingLog -Start $Start -end $End -EventId Receive -ea 0 -resultsize unlimited | where {$_.Recipients -notmatch "HealthMailbox" -and $_.Sender -notmatch "MicrosoftExchange" -and $_.source -match "SMTP"} | select sender,Recipients,timestamp,totalbytes,serverhostname
}

if ($mailexclude)
	{
		foreach ($entry in $mailexclude) {$SendMails = $SendMails | where {$_.sender -notmatch $entry -and $_.recipients -notmatch $entry}}
		foreach ($entry in $mailexclude) {$ReceivedMails = $ReceivedMails | where {$_.sender -notmatch $entry -and $_.recipients -notmatch $entry}}
	}

#Total

$totalsendmail = $sendmails | measure-object Totalbytes -sum
$totalreceivedmail = $receivedmails  | measure-object Totalbytes -sum

$totalsendvol = $totalsendmail.sum
$totalreceivedvol = $totalreceivedmail.sum
$totalsendvol = $totalsendvol / 1024 /1024
$totalreceivedvol = $totalreceivedvol / 1024 /1024
$totalsendvol = [System.Math]::Round($totalsendvol , 2)
$totalreceivedvol  = [System.Math]::Round($totalreceivedvol , 2)

$totalsendcount = $totalsendmail.count
$totalreceivedcount = $totalreceivedmail.count

$totalmail = @{$l_mail_send=$totalsendcount}
$totalmail +=@{$l_mail_received=$totalreceivedcount}

new-cylinderchart 500 400 "$l_mail_overallcount" Mails "$l_mail_count" $totalmail "$tmpdir\totalmailcount.png"

$totalmail = @{$l_mail_send=$totalsendvol}
$totalmail +=@{$l_mail_received=$totalreceivedvol}

new-cylinderchart 500 400 "$l_mail_overallcount" Mails "$l_mail_size" $totalmail "$tmpdir\totalmailvol.png"

$cells=@("$totalsendcount","$totalreceivedcount","$totalsendvol","$totalreceivedvol")
$mailreport += New-HTMLTableLine $cells
$mailreport += End-HTMLTable
$mailreport += Include-HTMLInlinePictures "$tmpdir\totalmail*.png"

 
$mailreport | set-content "$tmpdir\mailreport.html"
$mailreport | add-content "$tmpdir\report.html"


Write-Host TotalSend $totalsendcount
Write-Host TotalReceive $totalreceivedcount
Write-Host TotalSendVolume $totalsendvol
Write-Host TotalReceiveVol $totalreceivedvol

$WeekOY = ((Get-date -UFormat %V)-1)
$Tarih = ((Get-date).ToString("dd.MM.yyyy"))
$DGAdet= (Get-DistributionGroup -IgnoreDefaultScope -ResultSize Unlimited).Count
$DDGAdet= (Get-DynamicDistributionGroup -IgnoreDefaultScope -ResultSize Unlimited).Count
$ASAdet = (Get-ActiveSyncDevice).count
$CompAdet = (Get-ADComputer -Filter *).count
Get-MailboxDatabase -Status | Select-Object Name,@{n="DatabaseSize";e={$_.DatabaseSize.ToGb()}},@{n="TotalMailboxes";e={@(Get-Mailbox -IgnoreDefaultScope -ResultSize Unlimited -Database $_).count}},@{Label = 'Date'; Expression = {$Tarih}},@{Label = 'WeekofYear'; Expression = {$WeekOY}},@{Label = 'DGCount'; Expression = {$DGAdet}},@{Label = 'DDGCount'; Expression = {$DDGAdet}},@{Label = 'ASyncCount'; Expression = {$ASAdet}},@{Label = 'CompCount'; Expression = {$CompAdet}},@{Label = 'TotalSendCount'; Expression = {$totalsendcount}},@{Label = 'TotalReceivedCount'; Expression = {$totalreceivedcount}},@{Label = 'TotalSendVolumeMB'; Expression = {$totalsendvol}},@{Label = 'TotalReceivedVolumeMB'; Expression = {$totalreceivedvol}} | Export-CSV -NoTypeInformation -Append "\\10.6.240.98\Bilgi_Teknolojileri\Mcafee\CSV\ReportCSVNew.csv"
