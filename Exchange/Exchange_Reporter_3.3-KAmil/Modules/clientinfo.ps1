$clientinfo = Generate-ReportHeader "clientinfo.png" "$l_client_header"

Function Filter-Data
	{
		Param($FullFilePath)
			If (Test-Path $FullFilePath)
				{
					$Results = @(Get-Content -path $FullFilePath  | ConvertFrom-Csv -Header date-time,session-id,seq-number,client-name,organization-info,client-software,client-software-version,client-mode,client-ip,server-ip,protocol,application-id,operation,rpc-status,processing-time,operation-specific,failures | ?{($_."client-software" -eq 'OUTLOOK.EXE') -and ($_."client-name" -ne $null)} | Select client-software,client-software-version,@{Name='client-name';Expression={($_."client-name")}} -Unique)
					Return $Results 
				}
	}
	
Function Filter-EwsData
	{
		Param($FullFilePath)
			If (Test-Path $FullFilePath)
				{
					$Results = @(Get-Content -path $FullFilePath  | ConvertFrom-Csv | select useragent,AuthenticatedUser -Unique)
					Return $Results 
				}
	}

$Servers = @(Get-ExchangeServer | where {(($_.IsClientAccessServer -eq '$true') -and (($_.AdminDisplayVersion).major -eq '14')) -or (($_.IsMailboxServer -eq '$true') -and (($_.AdminDisplayVersion).major -ge '15')) } | Select Name,@{Name='Path';Expression={("\\$($_.fqdn)\" + "$($_.Datapath)").Replace(':','$').Replace("Mailbox","Logging\RPC Client Access")}} )
$EWSServers = @(Get-ExchangeServer | where {(($_.IsClientAccessServer -eq '$true') -and (($_.AdminDisplayVersion).major -eq '14')) -or (($_.IsMailboxServer -eq '$true') -and (($_.AdminDisplayVersion).major -ge '15')) } | Select Name,@{Name='Path';Expression={("\\$($_.fqdn)\" + "$($_.Datapath)").Replace(':','$').Replace("Mailbox","Logging\EWS")}} )


$Data = @()
ForEach ($Item in $Servers)
	{
		$Thefile = @(GCI -Path $Item.Path -Filter *.log | ?{$_.LastWriteTime -gt (Get-Date).AddDays(-$reportinterval)} | Select @{Name='File';Expression={("$($Item.Path)" + "\$($_.Name)")}})
		Foreach ($F in $Thefile)
			{
				$Data += (Filter-Data $F.File)
			}
	}
	
$EWSData = @()
ForEach ($Item in $EWSServers)
	{
		$Thefile = @(GCI -Path $Item.Path -Filter *.log | ?{$_.LastWriteTime -gt (Get-Date).AddDays(-$reportinterval)} | Select @{Name='File';Expression={("$($Item.Path)" + "\$($_.Name)")}})
		Foreach ($F in $Thefile)
			{
				$EWSData += (Filter-EwsData $F.File)
			}
	}

$outlookusers = $data | select client-software-version,client-name -Unique
$macusers = $ewsdata | select useragent,AuthenticatedUser -Unique | where {$_.useragent -match "mac"}

$outlook11 = ($outlookusers | where {$_.'client-software-version' -like "11*"} | measure).count
$outlook12 = ($outlookusers | where {$_.'client-software-version' -like "12*"} | measure).count
$outlook14 = ($outlookusers | where {$_.'client-software-version' -like "14*"} | measure).count
$outlook15 = ($outlookusers | where {$_.'client-software-version' -like "15*"} | measure).count
$outlook16 = ($outlookusers | where {$_.'client-software-version' -like "16*"} | measure).count
$other = ($outlookusers | where {$_.'client-software-version' -notlike "11*" -and $_.'client-software-version' -notlike "12*" -and $_.'client-software-version' -notlike "14*" -and $_.'client-software-version' -notlike "15*" -and $_.'client-software-version' -notlike "16*"}).count

$macoutlook16 = ($macusers | where {$_.useragent -match "MacOutlook/0.0.0.15"} | measure).count
$macoutlook11 = ($macusers | where {$_.useragent -match "MacOutlook/14"} | measure).count

if (!$outlook11) {$outlook11 = 0}
if (!$outlook12) {$outlook12 = 0}
if (!$outlook14) {$outlook14 = 0}
if (!$outlook15) {$outlook15 = 0}
if (!$outlook16) {$outlook16 = 0}
if (!$other) {$other = 0}

if (!$macoutlook16) {$macoutlook16 = 0}
if (!$macoutlook11) {$macoutlook11 = 0}

$cells=@("$l_client_o2003","$l_client_o2007","$l_client_o2010","$l_client_o2013","$l_client_o2016","$l_client_mo2011","$l_client_mo2016","$l_client_otherversion")
$clientinfo += Generate-HTMLTable "$l_client_t1header" $cells

if ($outlookusers)
	{
		$cells=@("$outlook11","$outlook12","$outlook14","$outlook15","$outlook16","$macoutlook11","$macoutlook16","$other")
		$clientinfo += New-HTMLTableLine $cells
		$clientinfo += End-HTMLTable

		$outlookcltvalues += [ordered]@{"$l_client_o2003"=$outlook11;"$l_client_o2007"=$outlook12;"$l_client_o2010"=$outlook14;"$l_client_o2013"=$outlook15;"$l_client_o2016"=$outlook16;"$l_client_mo2016"=$macoutlook16;"$l_client_mo2011"=$macoutlook11;"$l_client_otherversion"=$other}
		new-cylinderchart 700 400 Betriebssystem Name "$l_client_count" $outlookcltvalues "$tmpdir\outlclients.png"

		$clientinfo += Include-HTMLInlinePictures "$tmpdir\outlclients.png"
	}
else
	{
		$cells=@("$l_client_nooutlook")
		$clientinfo += New-HTMLTableLine $cells
		$clientinfo += End-HTMLTable
	}
	
$cells=@("$l_client_ios","$l_client_android","$l_client_winphone","$l_client_blackberry","$l_client_outlookapp","$l_client_otherversion")
$clientinfo += Generate-HTMLTable "$l_client_t2header" $cells

if ($emsversion -match "2010")
	{ 
		$activesyncos = Get-ActiveSyncDevice | where { $_.DistinguishedName -NotLike "*,CN=ExchangeDeviceClasses,*" } | select deviceos
	}
	
if ($emsversion -match "2013")
	{
		$activesyncos = Get-MobileDevice | select deviceos
	}

if ($emsversion -match "2016")
	{
		$activesyncos = Get-MobileDevice | select deviceos
	}

if ($activesyncos)
	{
		$iOS = ($activesyncos | where {$_.deviceos -like "iOS*"}).count
		$android = ($activesyncos | where {$_.deviceos -like "Android*"}).count
		$wp = ($activesyncos | where {$_.deviceos -like "Windows*"}).count
		$bb = ($activesyncos | where {$_.deviceos -like "Black*"}).count
		$oapp = ($activesyncos | where {$_.deviceos -like "Outlook*"}).count
		$otheros = ($activesyncos | where {$_.deviceos -notlike "iOS*" -and $_.deviceos -notlike "Android*" -and $_.deviceos -notlike "Windows*" -and $_.deviceos -notlike "Black*" -and $_.deviceos -notlike "Outlook*"}).count

		$cells=@("$iOS","$android","$wp","$bb","$oapp","$otheros")
		$clientinfo += New-HTMLTableLine $cells
		$clientinfo += End-HTMLTable

		$eascltvalues += [ordered]@{"$l_client_ios"=$iOS;"$l_client_android"=$android;"$l_client_winphone"=$wp;"$l_client_blackberry"=$bb;"$l_client_outlookapp"=$oapp;"$l_client_otherversion"=$otheros}
		new-cylinderchart 500 400 Betriebssystem Name "$l_client_count" $eascltvalues "$tmpdir\easclients.png"

		$clientinfo += Include-HTMLInlinePictures "$tmpdir\easclients.png"
	}
else
	{
		$cells=@("$l_client_nodevice")
		$clientinfo += New-HTMLTableLine $cells
		$clientinfo += End-HTMLTable
	}

$clientinfo | set-content "$tmpdir\easreport.html"
$clientinfo | add-content "$tmpdir\report.html"