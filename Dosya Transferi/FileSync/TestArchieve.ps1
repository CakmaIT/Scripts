$Date=((Get-Date -UFormat %V)-1)
$Date2=(Get-Date -Format dd_MM_yy)
$Source      = Get-ChildItem "C:\tools\Test\Koz_*.txt" | Where-Object {$_.Name -notlike "*.zip"} | Where-Object {$_.Name -notlike "*.rar"}
$Destination = "C:\tools\Test\"
$RarApp      = "C:\tools\FileSync\rar.exe" 
ForEach ($files in $Source) { 
    & $RarApp a -df $($Destination + $Date+".Hafta_CD_" + $Date2 + ".rar") $($files.FullName)
    Get-Process rar | Wait-Process
    }