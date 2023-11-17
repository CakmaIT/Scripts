#$Computers = "MASDP","SAMDP"
$Computers = @(
        'ALTMCAFEE'
        'ANKDP'
        'ASG100EPO02'
        'ASG101MDP01'
        'ASG120SDP01'
        'ASG132SDP01'
        'ASG134MDP01'
        'ASG179MDP01.labmed.saglik.local'
        'ATKDPSRV'
        'BKRDPSRV'
        'BRSDPSRV'
        'ESKDPSRV'
        'FULDP'
        'INTDPSRV'
        'KAYDPSRV'
        'KCLDPSRV'
        'KDKDP'
        'KOZDP'
        'MASDP'
        'MOBSRVUPDATE.mobil.saglik.local'
        'SAMDP'
        'ASG100SQL01'
        'ASG100MGR01'

    )
#,"APY100MDP01","APY100MDP01","APY100MDP01","APY100MDP01","APY100MDP01","APY100MDP01","APY100MDP01","APY100MDP01","APY100MDP01","APY100MDP01","APY100MDP01","APY100MDP01","APY100MDP01","APY100MDP01","APY100MDP01","APY100MDP01","APY100MDP01","APY100MDP01","APY100MDP01","APY100MDP01","APY100MDP01","APY100MDP01","APY100MDP01","APY100MDP01","APY100MDP01","APY100MDP01","APY100MDP01"
#$Computers2 = "localhost"
$array = @()
foreach ($Comp in $Computers){
#$Error.Clear()
$userSystem =Get-WmiObject win32_operatingsystem -ComputerName $Comp -ErrorAction SilentlyContinue
#$ErrorCode = $Error[0].Exception
#switch -regex ($ErrorCode) {
#("The RPC server is unavailable") {
#$userSystem = "Sunucuya Erişilemiyor,"
#Write-warning "RPC Unavailable on $computer"
#$obj += "" | Select @{e={$entry};n='Target'},@{e={"RPC_Unavalable"};n='caption'} 
#continue
#}}
$Uptime = ""
$Uptime = [math]::round((((Get-Date) - $userSystem.ConvertToDateTime($userSystem.LastBootUpTime))).TotalDays)
$LastBoot = ""
$LastBoot = ($userSystem.ConvertToDateTime($userSystem.LastBootUpTime)).tostring(“MM-dd-yyyy”)
$FreeRam = ""
$FreeRam = [math]::round(((Get-WmiObject Win32_OperatingSystem -ComputerName $Comp ).FreePhysicalMemory)/ 1048576,1)
$Socket = ""
$Socket = (Get-WmiObject Win32_ComputerSystem -Computername $Comp ).numberofprocessors
$Core = ""
$Core = (Get-WmiObject Win32_ComputerSystem -Computername $Comp ).NumberOfLogicalProcessors
$FreeVirRam = ""
$FreeVirRam = [math]::Round(((Get-WmiObject Win32_OperatingSystem -ComputerName $Comp ).FreeVirtualMemory) /1048576,1)
$TotalRam = ""
$TotalRam = [math]::Round(((Get-WmiObject Win32_ComputerSystem -Computername $Comp ).TotalPhysicalMemory) /1GB)
$CDrive = ""
$CDrive = Get-WmiObject win32_logicaldisk –ComputerName $Comp -filter "deviceid='C:'"
$Totalsize = ""
$Totalsize = [math]::Round($CDrive.Size /1GB)
$FreeSpace = ""
$FreeSpace = [math]::round($CDrive.FreeSpace / 1GB,0)
$DriveName = ""
$DriveName = $CDrive.DeviceID
$ServisName = "Erisim Sağlanamadı"
$ServisName = Get-Service -ComputerName $Comp -DisplayName 'McAfee ePolicy Orchestrator 5.9.1 Server'
$ServisStatus = "Erişim Sağlanamadı"
$ServisStatus = $ServisName.Status
$OS = (Get-WmiObject Win32_OperatingSystem -ComputerName $Comp).Caption

$row = new-object psobject
        $row | add-member -type NoteProperty -name 'Name' -Value $Comp
        $row | add-member -type NoteProperty -name 'OS' -Value $OS
        $row | add-member -type NoteProperty -name 'Service' -Value $ServisName
        $row | add-member -type NoteProperty -name 'Status' -Value $ServisStatus
        $row | add-member -type NoteProperty -name 'Drive' -Value $DriveName
        $row | add-member -type NoteProperty -name 'FreeSpace' -Value $FreeSpace
        $row | add-member -type NoteProperty -name 'TotalSize/GB' -Value $Totalsize
        $row | add-member -type NoteProperty -name 'LastBoot' -Value $LastBoot
        $row | add-member -type NoteProperty -name 'Uptime/Day' -Value $Uptime
        $row | add-member -type NoteProperty -name 'Socket' -Value $Socket
        $row | add-member -type NoteProperty -name 'Core' -Value $Core
        $row | add-member -type NoteProperty -name 'FreeVirRam' -Value $FreeVirRam
        $row | add-member -Type NoteProperty -name 'FreeRam' -Value $FreeRam
        $row | add-member -Type NoteProperty -name 'TotalRam/GB' -Value $TotalRam
        $array += $row
}
$style = "<style>BODY{font-family: Arial; font-size: 10pt;}"
$style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}"
$style = $style + "TH{border: 1px solid black; background: #dddddd; padding: 5px; }"
$style = $style + "TD{border: 1px solid black; padding: 5px; }"
$style = $style + "</style>"

$arrayoutput = $array | ConvertTo-Html -Head $style 
#$arrayoutput = $array | FT -AutoSize * 
#$arrayoutput = $arrayoutput | ConvertTo-Html -Head $style

$PingArray = @()
$ComputersPing = @(
'10.180.0.85'
'10.140.0.51'
'192.168.0.162'
'10.6.240.136'
'10.150.0.35'
'10.90.0.217'
'10.130.0.51'
'10.170.0.12'
'10.220.0.53'
'10.160.0.51'
'10.20.0.51'
'10.50.0.51'
'10.120.0.50'
'10.110.0.51'
'10.60.0.51'
'10.100.0.50'
'10.30.0.51'
'10.191.0.50'
'10.40.0.50'
'10.80.0.50'
'10.13.0.46'
'172.17.0.55'

)
#$pingerResult = test-connection $ip -count 4 -quiet
Write-Host "Started Pinging.."
foreach( $ip in $ComputersPing) {
$pinger = new-object psobject
$pinger | add-member -type NoteProperty -name 'IPaddress' -Value $ip
    if ((test-connection $ip -count 4 -quiet) -eq "True") {
        write-host $ip "Ping succeeded." -foreground green
        
            $pinger | add-member -type NoteProperty -name 'PingStatus' -Value "True"
            $PingArray += $pinger
    } 
    else {
         write-host $ip "Ping failed." -foreground red
            $pinger | add-member -type NoteProperty -name 'PingStatus' -Value "False"
         $PingArray += $pinger
}
}

$PingArray

$PingArrayoutput = $PingArray | ConvertTo-Html -Head $style


$PingArray2 = @()
$ComputersPing2 = @(
'10.6.243.154'
'10.6.243.156'
'10.6.243.157'
'10.6.243.158'
'10.6.243.159'
'10.6.243.160'
'10.6.243.161'
'10.6.243.162'
'10.6.243.163'
'10.6.243.164'
'10.6.240.93'
'10.6.240.75'
'10.6.240.76'
'10.6.243.150'
'10.6.240.226'
)
#$pingerResult = test-connection $ip -count 4 -quiet
Write-Host "Started Pinging.."
foreach( $ip in $ComputersPing2) {
$pinger2 = new-object psobject
$pinger2 | add-member -type NoteProperty -name 'IPaddress' -Value $ip
    if ((test-connection $ip -count 4 -quiet) -eq "True") {
        write-host $ip "Ping succeeded." -foreground green
        
            $pinger2 | add-member -type NoteProperty -name 'PingStatus' -Value "True"
            $PingArray2 += $pinger2
    } 
    else {
         write-host $ip "Ping failed." -foreground red
            $pinger2 | add-member -type NoteProperty -name 'PingStatus' -Value "False"
         $PingArray2 += $pinger2
}
}

$PingArray2

$PingArrayoutput2 = $PingArray2 | ConvertTo-Html -Head $style
Start-Sleep -s 1

$MailSender = "EpoCheck@acibadem.com"
$Subject = 'Agent Handler Sunucuları Raporu'
$SMTPServer = 'smtprelay01.acibadem.com.tr'
$SendtoMail = "kamil.cicek@acibadem.com"
$EmailBody = @"
<font face=Tahoma>Merhaba,</font><br />
<br />
<font face=Tahoma>Agent Handler Sunucuları Raporu aşağıdaki gibidir.</font><br />
<br />
<strong>$arrayoutput</strong><br /><br />
<strong>$PingArrayoutput</strong><br /><br />
<strong>$PingArrayoutput2</strong><br /><br />
<br /></font></h5>
"@

Start-Sleep -s 1
Send-MailMessage -To $SendtoMail -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHTML -Priority High
