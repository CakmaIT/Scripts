 $Tar = (Get-Date -Format dd_MM_yy_hh_mm)
if (-not( Test-Path -Path 'C:\tools\logs' -PathType Container)) {
New-Item -Path "c:\" -Name "tools\logs" -ItemType "directory"
}
  function Write-Log(
    [string[]]$Message,
    [string]$LogFile = (Get-Date -Format yyyy-mm-dd-hh-mm) + "_Logfile.txt",
    [switch]$ConsoleOutput,
    [ValidateSet("SUCCESS", "INFO", "WARN", "ERROR", "DEBUG")][string]$LogLevel
)
{
    $Message = $Message + $Input
    If (!$LogLevel) { $LogLevel = "INFO" }
    switch ($LogLevel)
    {
        SUCCESS { $Color = "Green" }
        INFO { $Color = "White" }
        WARN { $Color = "Yellow" }
        ERROR { $Color = "Red" }
        DEBUG { $Color = "Gray" }
    } # End Switch $LogLevel
    if ($Message -ne $null -and $Message.Length -gt 0)
    {
        $TimeStamp = [System.DateTime]::Now.ToString("yyyy-MM-dd HH:mm:ss")
        if ($LogFile -ne $null -and $LogFile -ne [System.String]::Empty)
        {
            Out-File -Append -FilePath $LogFile -InputObject "[$TimeStamp] $Message"
        } # End If $LogFile
        if ($ConsoleOutput -eq $true)
        {
            Write-Host "[$TimeStamp] [$LogLevel] :: $Message" -ForegroundColor $Color
        } # End If $ConsoleOutput
    } # End If $Message
} # End Function
$Statictext="Klasor bulunamadı."
$Statictext2="Silinecek dosya bulunamadı."
 
 if ( Test-Path -Path 'C:\Reports' -PathType Container ) {
try{
   Remove-Item –path 'C:\Reports\*' -Recurse -Force -Verbose 4>&1 | Add-Content C:\tools\Logs\$Tar-ReportsDeleted.log
}
catch 
{
$ErrorMessage = $_.Exception.Message
$FailedItem = $_.Exception.ItemName
Write-Log -Message $ErrorMessage -LogFile C:\tools\Logs\$Tar-hatalar.txt -LogLevel ERROR -ConsoleOutput
Write-Log -Message $FailedItem -LogFile C:\tools\Logs\$Tar-hatalar.txt -LogLevel ERROR -ConsoleOutput 

}
}
else {
$Statictext | Add-Content C:\tools\Logs\$Tar-ReportsDeleted.log
}
## IIS Logların Silinmesi

$Now = Get-Date
$Days = "10"
$TargetFolder = "c:\inetpub\logs\logfiles"
$Extension = "*.log"
$LastWrite = $Now.AddDays(-$Days)

$Files = Get-Childitem $TargetFolder -Include $Extension -Recurse | Where {$_.LastWriteTime -le "$LastWrite"}
 
foreach ($File in $Files) 
    {
    if ($File -ne $NULL)
        {
        Remove-Item $File.FullName -Force -Verbose 4>&1 | Add-Content C:\tools\Logs\$Tar-IISDeleted.log
        }
    else
        {
        $Statictext2 | Add-Content C:\tools\Logs\$Tar--IISDeleted.log
        }
    }