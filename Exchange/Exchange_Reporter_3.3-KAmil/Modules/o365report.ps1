$o365report = Generate-ReportHeader "o365report.png" "$l_o365_header	"

$O365settingshash = $inifile["Office365"]
$O365settings = convert-hashtoobject $O365settingshash

$O365User = ($O365settings| Where-Object {$_.Setting -eq "O365Username"}).Value
$O365Pass = ($O365settings | Where-Object {$_.Setting -eq "O365Password"}).Value

$O365passpassword = $O365Pass | ConvertTo-SecureString -AsPlainText -Force
$o365Creds= New-Object System.Management.Automation.PSCredential -ArgumentList $O365User, $O365passpassword

$PSsession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $o365creds -Authentication Basic -AllowRedirection
$connect = Import-PSSession $PSsession -ea 0 -wa 0 –Prefix o365 *>$null

$messages = $null
$page = 1
do
{
	$currmessages = Get-o365MessageTrace -pagesize 5000 -page $page -startdate $start -enddate $end | select SenderAddress,RecipientAddress,Received,size
	$page++
	$messages += $currmessages
}
until ($currmessages -eq $null)

# Gesamt Mail Übersicht

if ($OnlyOffice365 -match "yes")
{
	$orgname = (Get-o365StaleMailboxReport | select -first 1).TenantName
}

$cells=@("$l_o365_mailcount","$l_o365_mailvol")
$o365report += Generate-HTMLTable "$l_o365_header1" $cells

$totalmail = $messages | measure-object size -sum
$totalmailvol = $totalmail.sum
$totalmailvol = $totalmailvol / 1024 /1024
$totalmailvol = [System.Math]::Round($totalmailvol , 2)

$totalmailcount = $messages.count

$totalmailstat = @{$l_o365_count=$totalmailcount}

new-cylinderchart 500 400 "$l_o365_overallmailcout" Mails "$l_o365_count" $totalmailstat "$tmpdir\o365totalmailcount.png"

$totalmailstat = @{$l_o365_vol=$totalmailvol}

new-cylinderchart 500 400 "$l_o365_overallmailcout" Mails "$l_o365_vol	" $totalmailstat "$tmpdir\o365totalmailvol.png"

$cells=@("$totalmailcount","$totalmailvol")
$o365report += New-HTMLTableLine $cells
$o365report += End-HTMLTable
$o365report += Include-HTMLInlinePictures "$tmpdir\o365totalmail*.png"

# Mails je Tag

$cells=@("$l_o365_date","$l_o365_mailcount","$l_o365_volmb")
$o365report += Generate-HTMLTable "$l_o365_header2" $cells

$daycounter = 1
do
 {
 $dayendcounter = $daycounter - 1
 $daystart = (Get-Date -Hour 00 -Minute 00 -Second 00).AddDays(-$daycounter)
 $dayend = (Get-Date -Hour 00 -Minute 00 -Second 00).AddDays(-$dayendcounter)
  
  $DayReceivedMails = $messages | where {$_.Received -ge $daystart -and $_.Received -le $dayend}
  
  $daytotalreceivedmail = $dayreceivedmails  | measure-object size -sum
  
  $daytotalreceivedvol = $daytotalreceivedmail.sum
  $daytotalreceivedvol = $daytotalreceivedvol / 1024 /1024
  $daytotalreceivedvol  = [System.Math]::Round($daytotalreceivedvol , 2)
  
  $daytotalreceivedcount = $daytotalreceivedmail.count
  
  $day = $daystart | get-date -Format "dd.MM.yy"
  
  $daystotalmailvol +=[ordered]@{$day=$daytotalreceivedvol}
  $daystotalmailcount +=[ordered]@{$day=$daytotalreceivedcount}
  
  $cells=@("$day","$daytotalreceivedcount","$daytotalreceivedvol")
  $o365report += New-HTMLTableLine $cells
  
 $daycounter++
 }
 while ($daycounter -le $reportinterval)

 new-cylinderchart 500 400 "$l_o365_mailperday" Mails "$l_o365_count" $daystotalmailcount "$tmpdir\o365dailymailcount.png"
 new-cylinderchart 500 400 "$l_o365_volperday" Mails "$l_o365_vol" $daystotalmailvol "$tmpdir\o365dailymailvol.png" 

$o365report += End-HTMLTable
$o365report += Include-HTMLInlinePictures "$tmpdir\o365dailymail*.png"

#Top Ten Anzahl

$sendstat = $messages | select SenderAddress,size
$receivedstat = $messages | select RecipientAddress,size

$sendmails = $messages.SenderAddress
$ReceivedMails = $messages.RecipientAddress

$topsenders = $sendmails | Group-Object –noelement | Sort-Object Count -descending | Select-Object -first 10
$toprecipients = $ReceivedMails | Group-Object –noelement | Sort-Object Count -descending | Select-Object -first 10

$cells=@("$l_o365_sender","$l_o365_count")
$o365report += Generate-HTMLTable "$l_o365_topsendcount" $cells
foreach ($topsender in $topsenders)
{
 $tsname = $topsender.name
 $tscount = $topsender.count
 
 $cells=@("$tsname","$tscount")
 $o365report += New-HTMLTableLine $cells
}
$o365report += End-HTMLTable
 
$cells=@("$l_o365_recipient","$l_o365_count")
$o365report += Generate-HTMLTable "$l_o365_topreccount)" $cells
foreach ($toprecipient in $toprecipients)
{
 $trname = $toprecipient.name
 $trcount = $toprecipient.count
 
 $cells=@("$trname","$trcount")
 $o365report += New-HTMLTableLine $cells
}
$o365report += End-HTMLTable

#Top 10 Volume 

$cells=@("$l_o365_sender","$l_o365_volmb")
$o365report += Generate-HTMLTable "$l_o365_topsendvol" $cells

$sendstatgroup = $sendstat | group SenderAddress
$total  = @()
foreach ($group in $sendstatgroup)
	{
		$name = ($group.Group | select -first 1).SenderAddress
		$volume = ($group.Group | measure size -Sum).Sum
		$total += new-object PSObject -property @{Name="$name";Volume=$volume}
	}
$toptensendersvol = $total | sort volume -descending | select -first 10

foreach ($topsender in $toptensendersvol)
{
 $tsname = $topsender.name
 $tsvolume= $topsender.volume
 $tsvolume = $tsvolume / 1024 /1024
 $tsvolume = [System.Math]::Round($tsvolume , 2)
 $cells=@("$tsname","$tsvolume")
 $o365report += New-HTMLTableLine $cells
}
$o365report += End-HTMLTable

$cells=@("$l_o365_recipient","$l_o365_volmb")
$o365report += Generate-HTMLTable "$l_o365_toprecvol" $cells

$receivedstatgroup = $receivedstat | group RecipientAddress
$total  = @()
foreach ($group in $receivedstatgroup)
	{
		$name = ($group.Group | select -first 1).RecipientAddress
		$volume = ($group.Group | measure size -Sum).Sum
		$total += new-object PSObject -property @{Name="$name";Volume=$volume}
	}
$toptenrecipientsvol = $total | sort volume -descending | select -first 10

foreach ($toprecipient in $toptenrecipientsvol)
{
 $trname = $toprecipient.name
 $trvolume = $toprecipient.Volume
 $trvolume = $trvolume / 1024 /1024
 $trvolume = [System.Math]::Round($trvolume , 2)
 $cells=@("$trname","$trvolume")
 $o365report += New-HTMLTableLine $cells
}
$o365report += End-HTMLTable

#Durchschnitt

$usercount = (Get-o365Mailbox -resultsize unlimited | select alias).count

$dsend = $totalmailcount / $usercount
 $dsend = [System.Math]::Round($dsend , 2)
$dsendvol = $totalmailvol / $usercount
 $dsendvol= [System.Math]::Round($dsendvol , 2)
$dmailsizesend = $totalmailvol / $totalmailcount
 $dmailsizesend= [System.Math]::Round($dmailsizesend , 2)

$cells=@("$l_o365_average","$l_o365_value")
$o365report += Generate-HTMLTable "$l_o365_averagevalue" $cells

 $cells=@("$l_o365_avcountperday","$dsend")
 $o365report += New-HTMLTableLine $cells
 
 $cells=@("$l_o365_avvolperday","$dsendvol MB")
 $o365report += New-HTMLTableLine $cells

 $cells=@("$l_o365_avmail","$dmailsizesend MB")
 $o365report += New-HTMLTableLine $cells
 
$o365report += End-HTMLTable


#Postfächer

$cells=@("$l_o365_name","$l_o365_size","$l_o365_db")
$o365report += Generate-HTMLTable "$l_o365_topmailbox" $cells

$mailboxes = Get-o365Mailbox -ResultSize unlimited | Get-o365MailboxStatistics | select database, displayname, @{name="TotalItemSize (MB)"; expression={[math]::Round(($_.TotalItemSize.ToString().Split("(")[1].Split(" ")[0].Replace(",","")/1MB),2)}} | Sort "TotalItemSize (MB)" -Descending | select -First 20
foreach ($mailbox in $mailboxes)
{

 $mbxname = $mailbox.displayname
 $mbxsize = $mailbox."TotalItemSize (MB)"
 $db = $mailbox.database

 $cells=@("$mbxname","$mbxsize","$db")
 $o365report += New-HTMLTableLine $cells
 
}
$o365report += End-HTMLTable

#Inaktive Postfächer

$cells=@("$l_o365_date","$l_o365_activemailbox","$l_o365_inac1","$l_o365_inac2","$l_o365_inac3")
$o365report += Generate-HTMLTable "$l_o365_activemailbox" $cells

$stalemailboxes = Get-o365StaleMailboxReport -startdate $start -enddate $end
foreach ($stalemailbox in $stalemailboxes)
{
	$activembx = $stalemailbox.ActiveMailboxes
	$inac60 = $stalemailbox.InactiveMailboxes31To60Days
	$inac90 = $stalemailbox.InactiveMailboxes61To90Days
	$inac1460 = $stalemailbox.InactiveMailboxes91To1460Days
	$staledate = convert-date $stalemailbox.date
	
	$cells=@("$staledate","$activembx","$inac60","$inac90","$inac1460")
	$o365report += New-HTMLTableLine $cells
}
$o365report += End-HTMLTable	

#Browser

$cells=@("$l_o365_browser","$l_o365_accesscount")
$o365report += Generate-HTMLTable "$l_o365_browsercount" $cells

$browser = Get-o365O365ClientBrowserReport -StartDate ((get-date).adddays(-120))
$browsergroups = $browser | group name
foreach ($browsergroup in $browsergroups)
	{
		$browsername = $browsergroup.Name
		$browsercount = $browsergroup.Count
		$browserstats +=[ordered]@{$browsername=$browsercount}
		
		$cells=@("$browsername ","$browsercount")
		$o365report += New-HTMLTableLine $cells
	}

new-cylinderchart 500 400 "$l_o365_accbrowser" Browser "$l_o365_count" $browserstats "$tmpdir\browser.png"
$o365report += End-HTMLTable
$o365report += Include-HTMLInlinePictures "$tmpdir\browser.png"

#Mobiles

$cells=@("$l_o365_mbx","$l_o365_devid","$l_o365_model","$l_o365_type","$l_o365_displayname","$l_o365_os","$l_o365_firstsync","$l_o365_lastsync","$l_o365_inacsince")
$o365report += Generate-HTMLTable "$l_o365_header3" $cells

try 
{
$timenow = get-date
$easmailboxes = Get-o365CASMailbox -Resultsize Unlimited -wa 0 -ea 0 | Where {$_.HasActiveSyncDevicePartnership}
if ($easmailboxes)
{
foreach ($easmailbox in $easmailboxes)
	{
		$easdevices = Get-o365ActiveSyncDeviceStatistics -Mailbox $easmailbox.Identity -ea 0 -wa 0
		if ($easdevices)
		{
			foreach ($easdevice in $easdevices)
				{
		
					$easmbxname = $easmailbox.Name
					$easlastsync = $easdevice.LastSuccessSync
					$easfirstsync = $easdevice.FirstSyncTime		
					$easdeviceid = $easdevice.DeviceID
					$easdevicemodel = $easdevice.DeviceModel
					$easdevicetype = $easdevice.DeviceType
					$easdeviceos = $easdevice.DeviceOS
					$easdevicefrname = $easdevice.DeviceFriendlyName
					

			
					if ($easlastsync -and $easfirstsync -and $timenow)
						{
							$inactivetimestamp = $timenow - $easlastsync
							$daysinactive = $inactivetimestamp.days
		
							$easlastsync = $easlastsync | get-date -format "dd.MM.yyyy HH:mm"
							$easfirstsync = $easfirstsync | get-date -format "dd.MM.yyyy HH:mm"
		
							if ($daysinactive -gt 60)
								{
									[string]$daysinactivestring = $daysinactive
									$daysinactivestring= "$daysinactivestring" + " Tage"
									$cells=@("$easmbxname","$easdeviceid","$easdevicemodel","$easdevicetype","$easdevicefrname","$easdeviceos","$easfirstsync","$easlastsync","$daysinactivestring")
									$o365report += New-HTMLTableLine $cells
								}
							else
								{
									$accells=@("$easmbxname","$easdeviceid","$easdevicemodel","$easdevicetype","$easdevicefrname","$easdeviceos","$easfirstsync","$easlastsync")
									$accreport += New-HTMLTableLine $accells
								}
						}
				}
		}
	}
}	
$o365report += End-HTMLTable
}
catch
{
}

$cells=@("$l_o365_mbx","$l_o365_devid","$l_o365_model","$l_o365_type","$l_o365_displayname","$l_o365_os","$l_o365_firstsync","$l_o365_lastsync")
$o365report += Generate-HTMLTable "$l_o365_header4" $cells
$o365report += $accreport
$o365report += End-HTMLTable

#Lizenzen

$cells=@("$l_o365_service","$l_o365_liccount","$l_o365_evalliccount","$l_o365_acusers")
$o365report += Generate-HTMLTable "$l_o365_header5" $cells

$licreport = Get-o365LicenseVsUsageSummaryReport
foreach ($entry in $licreport)
	{
		$workload = $entry.workload
		if ($workload -eq "EXO")
		{
			$servicename = "Exchange Online"
		}
		if ($workload -eq "LYO")
		{
			$servicename = "Lync Online"
		}
		if ($workload -eq "SPO")
		{
			$servicename = "SharePoint Online"
		}
		$triallic = $entry.TrialEntitlements
		$prodlic = $entry.NonTrialEntitlements
		$actuser = $entry.ActiveUsers
		
			$cells=@("$servicename","$prodlic","$triallic","$actuser")
			$o365report += New-HTMLTableLine $cells
	}
$o365report += End-HTMLTable		

$removesession = Remove-PSSession $PSsession

$o365report | set-content "$tmpdir\o365report.html"
$o365report | add-content "$tmpdir\report.html"
