$spacereport = Generate-ReportHeader "spacereport.png" "$l_space_header"

$exsrvcount = 1
foreach ($exserver in $exservers)
 {
  $exvolcount = 1
  $computername = $exserver.name
  $cells=@("$l_space_drive","$l_space_name","$l_space_size","$l_space_free")
  $spacereport += Generate-HTMLTable "$computername $l_space_header" $cells
  $volumes = Get-WmiObject win32_volume -computername $computername | where {$_.Drivetype -match "3" -and $_.SystemVolume -match "False" -and $_.capacity -ne 314568704} | sort caption
  foreach ($volume in $volumes)
   {
    $filename = "$exsrvcount" + "_" + "$exvolcount" + ".png"
    $volsize = [long]($volume.Capacity / 1GB)
	$volfree = [long]($volume.FreeSpace / 1GB)
	[long]$volused = $volsize - $volfree
	$volname = $volume.Label
	$volid = $volume.name
	
	$chartdata = @{$l_space_free=$volfree; $l_space_used=$volused}
	new-piechart "150" "150" "$volname $volid" $chartdata "$tmpdir\$filename"
	
	$cells=@($volid,$volname,$volsize,$volfree)
    $spacereport += New-HTMLTableLine $cells
	
	 $exvolcount = $exvolcount + 1
	 
   } 
  $spacereport += End-HTMLTable
  $spacereport += Include-HTMLInlinePictures "$tmpdir\$exsrvcount*.png"
  
  $exsrvcount = $exsrvcount + 1  
 }

#Domain Controller
 
$dcsrvcount = 1
 
foreach ($domaincontroller in $domaincontrollers)
 {
  $dcvolcount = 1
  $computername = $domaincontroller.name
  $cells=@("$l_space_drive","$l_space_name","$l_space_size","$l_space_free")
  $spacereport += Generate-HTMLTable "$computername $l_space_header" $cells
  $volumes = Get-WmiObject win32_volume -computername $computername | where {$_.Drivetype -match "3" -and $_.SystemVolume -match "False" -and $_.capacity -ne 314568704} | sort caption
  foreach ($volume in $volumes)
   {
    $filename = "dc" + "$dcsrvcount" + "_" + "$dcvolcount" + ".png"
    $volsize = [long]($volume.Capacity/1073741824)
    $volfree = [long]($volume.FreeSpace/1073741824)
    [long]$volused = $volsize - $volfree
    $volid = $volume.name
    $volname = $volume.label
    $chartdata = @{$l_space_free=$volfree; $l_space_used=$volused}
   
    new-piechart "150" "150" "$volname $volid" $chartdata "$tmpdir\$filename"
   
    $cells=@($volid,$volname,$volsize,$volfree)
    $spacereport += New-HTMLTableLine $cells

    $dcvolcount= $dcvolcount + 1
   } 
  $spacereport += End-HTMLTable
  $spacereport += Include-HTMLInlinePictures "$tmpdir\dc$dcsrvcount*.png"
  
  $dcsrvcount = $dcsrvcount + 1  
 }

$spacereport | set-content "$tmpdir\spacereport.html"
$spacereport | add-content "$tmpdir\report.html"

