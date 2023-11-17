$Computers = @(
'GMASGDC01.acibadem.com.tr'
'GMASGDC02.acibadem.com.tr'
'GMASGDC03.acibadem.com.tr'
'LABMEDDC01.labmed.saglik.local'
'GMLABMEDDC.labmed.saglik.local'
'MOBDC01.mobil.saglik.local'
'MOBDC02.mobil.saglik.local'
'GMMOBDC01.mobil.saglik.local'
'KDKDC01.acibadem.com.tr'
'KDKDC02.acibadem.com.tr'
'KCLDC01.acibadem.com.tr'
'KCLDC02.acibadem.com.tr'
'KOZDC01.acibadem.com.tr'
'KOZDC02.acibadem.com.tr'
'MASDC01.acibadem.com.tr'
'MASDC02.acibadem.com.tr'
'TKSDC01.acibadem.com.tr'
'TKSDC02.acibadem.com.tr'
'ADADC01.acibadem.com.tr'
'ADADC02.acibadem.com.tr'
'ANKDC01.acibadem.com.tr'
'ANKDC02.acibadem.com.tr'
'BKRDC01.acibadem.com.tr'
'BKRDC02.acibadem.com.tr'
'BRSDC01.acibadem.com.tr'
'BRSDC02.acibadem.com.tr'
'KAYDC01.acibadem.com.tr'
'KAYDC02.acibadem.com.tr'
'FULDC01.acibadem.com.tr'
'FULDC02.acibadem.com.tr'
'ESKDC1.acibadem.com.tr'
'ESKDC02.acibadem.com.tr'
'SAMCMDC01.acibadem.com.tr'
'SAMCMDC02.acibadem.com.tr'
'APLUSDC01.acibadem.com.tr'
'APLUSDC02.acibadem.com.tr'
'ALTDC01.acibadem.com.tr'
'ALTDC02.acibadem.com.tr'
'BODDC01.acibadem.com.tr'
'BODDC02.acibadem.com.tr'
'ATKDC01.acibadem.com.tr'
'ATKDC02.acibadem.com.tr'
'KUCDC01.acibadem.com.tr'
'KUCDC02.acibadem.com.tr'
'INTDC01.acibadem.com.tr'
'INTDC02.acibadem.com.tr'
'DRCDC01.acibadem.com.tr'
'DRCDC02.acibadem.com.tr'
    )
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
$ServisName = "Servis Bulunamadı"
$ServisName = Get-Service -ComputerName $Comp -DisplayName 'DNS Server'
$ServisStatus = "Servis Bulunamadı"
$ServisStatus = $ServisName.Status
$ServisName2 = "Servis Bulunamadı"
$ServisName2 = Get-Service -ComputerName $Comp -DisplayName 'Network Policy Server'
$ServisStatus2 = "Servis Bulunamadı"
$ServisStatus2 = $ServisName2.Status
$ServisName3 = "Servis Bulunamadı"
$ServisName3 = Get-Service -ComputerName $Comp -DisplayName 'DHCP Server'
$ServisStatus3 = "Servis Bulunamadı"
$ServisStatus3 = $ServisName3.Status

$row = new-object psobject
        $row | add-member -type NoteProperty -name 'Name' -Value $Comp
        $row | add-member -type NoteProperty -name 'Service' -Value $ServisName
        $row | add-member -type NoteProperty -name 'Status' -Value $ServisStatus
        $row | add-member -type NoteProperty -name 'Service2' -Value $ServisName2
        $row | add-member -type NoteProperty -name 'Status2' -Value $ServisStatus2
        $row | add-member -type NoteProperty -name 'Service3' -Value $ServisName3
        $row | add-member -type NoteProperty -name 'Status3' -Value $ServisStatus3
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

Write-Host "Started Pinging.."
foreach( $ip in $Computers) {
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

Start-Sleep -s 1

$MailSender = "ADCheck@acibadem.com"
$Subject = 'ActiveDirectory Sunucuları Raporu'
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
