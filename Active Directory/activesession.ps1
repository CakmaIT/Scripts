# Import the Active Directory module for the Get-ADComputer CmdLet
Import-Module ActiveDirectory

# Get today's date for the report
$today = Get-Date
$arrayofStringsNonInterestedIn = "console" , "RDP" , "services"

# Setup email parameters
$subject = "ACTIVE SERVER SESSIONS REPORT - " + $today
$priority = "Normal"
$smtpServer = "mail.yildirimgroup.com"
$emailFrom = "system.monitor@yildirimgroup.com"
$emailTo = "system.monitor@yildirimgroup.com"
# Comment out line abve and Uncomment line below and change to test email for testing purposes
#$emailTo = "youremail@yourdomain.com"

# Create a fresh variable to collect the results. You can use this to output as desired
$SessionList = "ACTIVE SERVER SESSIONS REPORT - " + $today + "`n`n"

# Query Active Directory for computers running a Server operating system
$Servers = Get-ADComputer -Filter {OperatingSystem -like "*server*"} 

#Add the fiter line below in place of the astreisk aboveif you want to filter out all non server OS Computers
#-Filter {OperatingSystem -like "*server*"}

# Loop through the list to query each server for login sessions
ForEach ($Server in $Servers) {
	$ServerName = $Server.Name

	# When running interactively, uncomment the Write-Host line below to show which server is being queried
	# Write-Host "Querying $ServerName"

	# Run the qwinsta.exe and parse the output
	$queryResults = (qwinsta /server:$ServerName | foreach { (($_.trim() -replace "\s+",","))} | ConvertFrom-Csv) 
	
	# Pull the session information from each instance
                    ForEach ($queryResult in $queryResults) { 
                         $RDPUser = $queryResult.USERNAME 
                         $sessionType = $queryResult.SESSIONNAME 
                         $State=$queryResult.State
                         If ($queryResult.ID -eq "Disc") {
                                $RDPUser = $queryResult.Sessionname
                                $SessionType=" "
                                $State=$queryResult.ID
                                }
		
		# We only want to display where a "person" is logged in. Otherwise unused sessions show up as USERNAME as a number
	    If (($RDPUser -match "[a-z]") -and ($RDPUser -ne $NULL) -and ($RDPUser -ne "Disc")) { 
			# When running interactively, uncomment the Write-Host line below to show the output to screen
			# Write-Host $ServerName logged in by $RDPUser on $sessionType
			$SessionList = $SessionList + "`n`n" + $ServerName + " logged in by " + $RDPUser + " on " + $sessionType
		}
	}
}

# When running interactively, uncomment the Write-Host line below to see the full list on screen
#$SessionList
get-content $sessionlist | where {$arrayofStringsNonInterestedIn -notcontains $_}
#Write-host $SessionList

$SessionList2 = ""
ForEach($l in $SessionList.split("`n")){
    if ($l.Trim().Equals("")){continue}
    if ($l.Contains("services")) {continue}
    if ($l.Trim().EndsWith("on")) {$SessionList2 += $l + "`n"}
    
}

#Write-host $SessionList2 
# Send the report email
Send-MailMessage -To $emailTo -Subject $subject -Body $SessionList2 -SmtpServer $smtpServer -From $emailFrom -Priority $priority