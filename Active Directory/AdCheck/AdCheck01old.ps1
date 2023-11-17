import-Module ActiveDirectory
$DaysInactive = 120
$time = (Get-Date).Adddays(-($DaysInactive))
$date = (get-date)
$dateat = $date.ToString("dd.MM.yyyy")
$results = @()
$deletere = @()
$expiryDate = ( Get-date ).AddDays(120)
$dateForFilename = $date.ToString("dd-MM-yyyy")
$systems = Get-ADComputer -Filter { LastLogonTimeStamp -lt $time -and Enabled -eq $true } -ResultPageSize 20000 -resultSetSize $null -Properties Name, OperatingSystem, DistinguishedName, LastLogonTimeStamp | Where-Object {$_.OperatingSystem -notlike "*server*"} | where-Object  {$_.OperatingSystem -like "*windows*"}
#$disadet = $systems.Count
if ($systems)

   {
      foreach($computer in $systems)
      {
         $results += $computer | select-object Name, OperatingSystem, DistinguishedName, LastLogonTimeStamp
         $computer | disable-ADaccount
		 $computer | Set-ADComputer -Add @{extensionAttribute10 = "$dateat tarihinde disable edildi"}
	     $computer | Set-ADComputer -Add @{extensionAttribute9 = "$expiryDate"}
         $computer | move-ADobject -targetpath  "OU=79 Disabled Computer,DC=acibadem,DC=com,DC=tr"
         write-host "$computer has been disabled and moved."
      }
      $results | export-csv "C:\Disable_Computer\$dateForFilename-InactiveComputersCheck.csv" -Append -NoTypeInformation 
   }
else
   {
      $results | export-csv "C:\Disable_Computer\$dateForFilename-InactiveComputersCheck.csv" -Append -NoTypeInformation 
   }
 $disadet = ($results | Measure-Object).Count
 ######Alt Satırlar disable edildi.
 #$DisablesComps = Get-ADComputer -SearchBase "OU=79 Disabled Computer,DC=acibadem,DC=com,DC=tr" -Filter { LastLogonTimeStamp -lt $time -and Enabled -eq $false } -Properties Name, OperatingSystem, DistinguishedName, LastLogonTimeStamp, extensionAttribute9 | Where-Object {$_.OperatingSystem -notlike "*server*"} | where-Object  { $_.extensionAttribute9 -lt $date }
 #$Deladet = ($DisablesComps | Measure-Object).Count
 #      foreach($computerd in $DisablesComps)
 #     {
 #       $deletere += $computerd | select-object Name, OperatingSystem, DistinguishedName, LastLogonTimeStamp
 #       $computerd | Remove-ADComputer -Confirm:$False
 #       Write-Host $computerd deleted   
 #     }  
 #     $deletedateFilename = $date.ToString("dd-MM-yyyy")
 #     $deletere | export-csv "C:\Disable_Computer\$deletedateFilename-DeleteComputersCheck.csv" -Append -NoTypeInformation 

Start-Sleep -s 10


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

# <font face=Tahoma>Active Directory'den <strong>$Deladet</strong> bilgisayar silinmistir.</font><br />

$files = Get-ChildItem -Path C:\Disable_Computer\$dateForFilename-Inactive*.csv | where-Object {$_.LastWriteTime -gt (Get-Date).AddDays(-1)}
#$body = @()
$EmailBody = @"
<font face=Tahoma></font><br />
<font face=Tahoma>Active Directory'de <strong>$disadet</strong> bilgisayar disable edilmistir.</font><br />
<br />
<font face=Tahoma>Detaylari ekteki gibidir.</font><br />
"@
$attachments = @()
foreach($file in $files){
    $filename = [system.io.path]::GetFileName($file.FullName)
    $attachments += $file.fullname
    
}
#$body += "Active Directory'den $Deladet bilgisayar silinmiş, $disadet bilgisayar disable edilmis ve Acıbadem'den $RecordsCounter Mobil'den $RecordsCounter02 Labmed'den $RecordsCounter03 eski dns kaydı temizlenmiştir. Detayları ekteki gibidir."
#$body = $body | Out-String
Send-MailMessage -to Asgbtsistemyonetimi@acibadem.com.tr -From ActiveDirectory@acibadem.com.tr -SmtpServer smtprelay01.acibadem.com.tr -Subject "AD Computer Cleanup $deletedateFilename" -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHtml $EmailBody -Attachments $attachments
#Send-MailMessage -to kamil.cicek@acibadem.com.tr -From ActiveDirectory@acibadem.com.tr -SmtpServer smtprelay01.acibadem.com.tr -Subject "AD Computer Cleanup $deletedateFilename" -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHtml $EmailBody -Attachments $attachments
