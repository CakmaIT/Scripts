$easreport = Generate-ReportHeader "easreport.png" "$l_eas_header"

$cells=@("$l_eas_mbx","$l_eas_id","$l_eas_model","$l_eas_type","$l_eas_displayname","$l_eas_os","$l_eas_firstsync","$l_eas_lastsync	","$l_eas_inactivesince")
$easreport += Generate-HTMLTable "$l_eas_t1header" $cells

try 
{
$timenow = get-date
$easmailboxes = Get-CASMailbox -Resultsize Unlimited -wa 0 -ea 0 | Where {$_.HasActiveSyncDevicePartnership}
if ($easmailboxes)
{
foreach ($easmailbox in $easmailboxes)
	{
		$easdevices = Get-ActiveSyncDeviceStatistics -Mailbox $easmailbox.Identity -ea 0 -wa 0
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
									$easreport += New-HTMLTableLine $cells
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
$easreport += End-HTMLTable
}
catch
{
}

$cells=@("$l_eas_mbx","$l_eas_id","$l_eas_model","$l_eas_type","$l_eas_displayname","$l_eas_os","$l_eas_firstsync","$l_eas_lastsync")
$easreport += Generate-HTMLTable "$l_eas_t2header	" $cells
$easreport += $accreport
$easreport += End-HTMLTable


$easreport | set-content "$tmpdir\easreport.html"
$easreport | add-content "$tmpdir\report.html"