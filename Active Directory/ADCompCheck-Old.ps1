import-Module ActiveDirectory
$DaysInactive = 90
$time = (Get-Date).Adddays(-($DaysInactive))
$date = (get-date)
$dateat = $date.ToString("dd.MM.yyyy")
$results = @()
$deletere = @()
$expiryDate = ( Get-date ).AddDays(90)
$systems = Get-ADComputer -Filter { LastLogonTimeStamp -lt $time -and Enabled -eq $true } -ResultPageSize 20000 -resultSetSize $null -Properties Name, OperatingSystem, DistinguishedName, LastLogonTimeStamp | Where-Object {$_.OperatingSystem -notlike "*server*"} | where-Object  {$_.OperatingSystem -like "*windows*"}
$disadet = $systems.Count
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
      $dateForFilename = $date.ToString("dd-MM-yyyy")
      $results | export-csv "C:\Disable_Computer\$dateForFilename-InactiveComputersCheck.csv" -Append -NoTypeInformation 
   }
else
   {
      $results | export-csv "C:\Disable_Computer\$dateForFilename-InactiveComputersCheck.csv" -Append -NoTypeInformation 
   }
 $DisablesComps = Get-ADComputer -SearchBase "OU=79 Disabled Computer,DC=acibadem,DC=com,DC=tr" -Filter { LastLogonTimeStamp -lt $time -and Enabled -eq $false } -Properties Name, OperatingSystem, DistinguishedName, LastLogonTimeStamp, extensionAttribute9 | Where-Object {$_.OperatingSystem -notlike "*server*"} | where-Object  { $_.extensionAttribute9 -lt $date }
 $Deladet = $DisablesComps.Count
       foreach($computerd in $DisablesComps)
      {
        $deletere += $computerd | select-object Name, OperatingSystem, DistinguishedName, LastLogonTimeStamp
        $computerd | Remove-ADComputer -Confirm:$False
        Write-Host $computerd deleted   
      }  
      $deletedateFilename = $date.ToString("dd-MM-yyyy")
      $deletere | export-csv "C:\Disable_Computer\$deletedateFilename-DeleteComputersCheck.csv" -Append -NoTypeInformation 

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

$ZoneName = "acibadem.com.tr"
$NumberOfDaysBack = 10
$DateInThePast = (Get-Date).AddDays(-$NumberOfDaysBack)
$Tar = (Get-Date -Format dd_MM_yy)

       #$RecordsArray = Get-DnsServerResourceRecord -ZoneName $ZoneName -RRType A | Where-Object {($_.Timestamp -lt $DateInThePast) -and ($_.Timestamp -ne $null)} | Where-Object {($_.Hostname -match "^[0-9][0-9][N-P]")}
       $RecordsArray = Get-DnsServerResourceRecord -ZoneName acibadem.com.tr -RRType A | Where-Object {($_.Timestamp -lt $DateInThePast) -and ($_.Timestamp -ne $null)} | Where-Object {($_.Hostname -match "^[0-9][0-9][NP]") -or ($_.Hostname -match "^[B][S][-]")}
       $RecordsArray | Export-Csv -Path C:\Disable_Computer\$Tar'_'$ZoneName.csv -NoTypeInformation -Append
       $RecordsCounter = $RecordsArray.Count
           if ($RecordsArray)
		{
		   foreach($Record in $RecordsArray)
            {
                Try
                {
				Remove-DnsServerResourceRecord -ZoneName "acibadem.com.tr" -RRType A -Name $Record.HostName -Force
                }
                Catch
                {
                $ErrorMessage = $_.Exception.Message
                $FailedItem = $_.Exception.ItemName
		        Write-Log -Message $ErrorMessage -LogFile C:\Temp\Dns_Logs\$Tar-DNShatalari.txt -LogLevel ERROR -ConsoleOutput
                Write-Log -Message $FailedItem -LogFile C:\Temp\Dns_Logs\$Tar-DNShatalari.txt -LogLevel ERROR -ConsoleOutput 
                }
				
            }
        }
        else
        {
            $RecordsArray | Export-Csv -Path C:\Disable_Computer\$Tar'_'$ZoneName.csv -NoTypeInformation -Append -NoTypeInformation 
        }
		
$ZoneName02 = "mobil.saglik.local"
$NumberOfDaysBack02 = 8
$DateInThePast = (Get-Date).AddDays(-$NumberOfDaysBack02)
$Tar = (Get-Date -Format dd_MM_yy)

       $RecordsArray02 = Get-DnsServerResourceRecord -ZoneName mobil.saglik.local -RRType A | Where-Object {($_.Timestamp -lt $DateInThePast) -and ($_.Timestamp -ne $null)} | Where-Object {($_.Hostname -match "^[8][4][NP]") -or ($_.Hostname -match "^[B][S][-]")}
       $RecordsArray02 | Export-Csv -Path C:\Disable_Computer\$Tar'_'$ZoneName02.csv -NoTypeInformation -Append
       $RecordsCounter02 = $RecordsArray02.Count
           if ($RecordsArray02)
		{
		   foreach($Record in $RecordsArray02)
            {
                Try
                {
				Remove-DnsServerResourceRecord -ZoneName "mobil.saglik.local" -RRType A -Name $Record.HostName -Force
                }
                Catch
                {
                $ErrorMessage = $_.Exception.Message
                $FailedItem = $_.Exception.ItemName
		        Write-Log -Message $ErrorMessage -LogFile C:\Temp\Dns_Logs\$Tar-DNShatalari.txt -LogLevel ERROR -ConsoleOutput
                Write-Log -Message $FailedItem -LogFile C:\Temp\Dns_Logs\$Tar-DNShatalari.txt -LogLevel ERROR -ConsoleOutput 
                }
				
            }
        }
        else
        {
            $RecordsArray02 | Export-Csv -Path C:\Disable_Computer\$Tar'_'$ZoneName02.csv -NoTypeInformation -Append -NoTypeInformation 
        }

$ZoneName03 = "labmed.saglik.local"
$NumberOfDaysBack03 = 8
$DateInThePast = (Get-Date).AddDays(-$NumberOfDaysBack03)
$Tar = (Get-Date -Format dd_MM_yy)

       $RecordsArray03 = Get-DnsServerResourceRecord -ZoneName labmed.saglik.local -RRType A | Where-Object {($_.Timestamp -lt $DateInThePast) -and ($_.Timestamp -ne $null)} | Where-Object {($_.Hostname -match "^[7][9][NP]") -or ($_.Hostname -match "^[B][S][-]")}
       $RecordsArray03 | Export-Csv -Path C:\Disable_Computer\$Tar'_'$ZoneName03.csv -NoTypeInformation -Append
       $RecordsCounter03 = $RecordsArray03.Count
           if ($RecordsArray03)
		{
		   foreach($Record in $RecordsArray03)
            {
                Try
                {
				Remove-DnsServerResourceRecord -ZoneName "labmed.saglik.local" -RRType A -Name $Record.HostName -Force
                }
                Catch
                {
                $ErrorMessage = $_.Exception.Message
                $FailedItem = $_.Exception.ItemName
		        Write-Log -Message $ErrorMessage -LogFile C:\Temp\Dns_Logs\$Tar-DNShatalari.txt -LogLevel ERROR -ConsoleOutput
                Write-Log -Message $FailedItem -LogFile C:\Temp\Dns_Logs\$Tar-DNShatalari.txt -LogLevel ERROR -ConsoleOutput 
                }
				
            }
        }
        else
        {
            $RecordsArray03 | Export-Csv -Path C:\Disable_Computer\$Tar'_'$ZoneName03.csv -NoTypeInformation -Append -NoTypeInformation 
        }		
	

Start-Sleep -s 10

  
$files = Get-ChildItem -Path C:\Disable_Computer | Sort-Object LastWriteTime -Descending | Select-Object -First 5
$body = @()
$attachments = @()
foreach($file in $files){
    $filename = [system.io.path]::GetFileName($file.FullName)
    $attachments += $file.fullname
    
}
$body += "Active Directory'den $Deladet bilgisayar silinmis $disadet bilgisayar disable edilmis ve Acibadem'den $RecordsCounter Mobil'den $RecordsCounter02 Labmed'den $RecordsCounter03 eski dns kaydi temizlenmistir. Detaylari ekteki gibidir."
$body = $body | Out-String
Send-MailMessage -to Asgbtsistemyonetimi@acibadem.com.tr -From ActiveDirectory@acibadem.com.tr -SmtpServer smtprelay01.acibadem.com.tr -Subject "AD Computer Cleanup $deletedateFilename" -BodyAsHtml $body -Attachments $attachments
