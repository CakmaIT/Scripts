#$Date=((Get-Date -UFormat %V)-1)
#$Date2=(Get-Date -Format dd_MM_yy)
cd C:\tools\FileSync\Logs
$Source      = Get-ChildItem "C:\tools\FileSync\Logs\Koz_Log_*.txt" | Where-Object {$_.Name -notlike "*.zip" -and $_.LastWriteTime -lt (Get-Date).AddHours(-12)}| Where-Object {$_.Name -notlike "*.rar"}
$Destination = "C:\tools\FileSync\Logs\Archieve\"
$RarApp      = "C:\tools\FileSync\rar.exe" 
ForEach ($files in $Source) { 
    & $RarApp a $($Destination + $files.Name + ".rar") $($files.FullName) -u -df -m5
    Get-Process rar.exe | Wait-Process
    }

#ForEach ($files in $Source) { 
#    & $RarApp a -u -df $($Destination + $Date+".Hafta_CD_" + $Date2 + ".rar") $($files.FullName) -u -df -m5
#    Get-Process rar.exe | Wait-Process
#    }

$Source2      = Get-ChildItem "C:\tools\FileSync\Logs\Tree\Koz_*.txt" | Where-Object {$_.Name -notlike "*.zip" -and $_.LastWriteTime -lt (Get-Date).AddHours(-12)}| Where-Object {$_.Name -notlike "*.rar"}
$Destination2 = "C:\tools\FileSync\Logs\Tree\Archieve\"
ForEach ($files2 in $Source2) { 
    & $RarApp a $($Destination2 + $files2.Name + ".rar") $($files2.FullName) -u -df -m5
    Get-Process rar.exe | Wait-Process
    }
