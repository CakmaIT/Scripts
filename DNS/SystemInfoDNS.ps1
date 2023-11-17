# Create get-systeminfo function
function Get-SystemInfo 
{ 
  param($ComputerName = $env:ComputerName) 

  $header = 'Hostname','OSName','OSVersion','OSManufacturer','OSConfig','Buildtype', 'RegisteredOwner','RegisteredOrganization','ProductID','InstallDate', 'StartTime','Manufacturer','Model','Type','Processor','BIOSVersion', 'WindowsFolder' ,'SystemFolder','StartDevice','Culture', 'UICulture', 'TimeZone','PhysicalMemory', 'AvailablePhysicalMemory' , 'MaxVirtualMemory', 'AvailableVirtualMemory','UsedVirtualMemory','PagingFile','Domain' ,'LogonServer','Hotfix','NetworkAdapter' 
  systeminfo.exe /FO CSV /S $ComputerName |  
        Select-Object -Skip 1 |  
        ConvertFrom-CSV -Header $header 
} 
$recently = [DateTime]::Today.AddDays(-180)
#$ARecords = Get-DnsServerResourceRecord -ComputerName gmasgdc03 -ZoneName acibadem.com.tr -RRType A | Where {($_.Timestamp -ne $null)} | Where {($_.Timestamp -lt $recently)} | Where {($_.HostName -ne "@")} | Where {($_.HostName -notlike "*dnszones*")}
$ARecords=Get-DnsServerResourceRecord -ComputerName gmasgdc03 -ZoneName acibadem.com.tr -RRType A | Where {($_.HostName -like "*00n455*")}
# Pull out just the hostnames
#$Desktops = $ARecords | Where-Object {$_.HostName -like <#my hostname prefix#>} | select -ExpandProperty HostName
$Desktops = $ARecords | select -ExpandProperty HostName
# Test the list of hostnames by outputting to a file
$Desktops | Out-File C:\tools\New folder\TEST.txt
# Get some info about each hostname on the list
ForEach ($Desktop in $Desktops) {if (Test-Connection $Desktop -Count 1 -Quiet) {
    Get-SystemInfo -ComputerName $Desktop | select Hostname,OSName,InstallDate,NetworkAdapter 
        {if ( $Desktop -eq $Desktops.Hostname) {
        #Get-SystemInfo -ComputerName $Desktop | select Hostname,OSName,InstallDate,NetworkAdapter |     out-file c:\test.txt -Append
    }
    else {
        #Throw some error or write $Desktop to remediation file for later follow up. you could also do a check on last logon date here to see if this computer has hit the domain in a specified amount of time.
    }
}

