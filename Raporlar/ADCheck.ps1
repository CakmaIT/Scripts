$Computers = @(
'GMASGDC01.acibadem.com.tr'
'GMASGDC02.acibadem.com.tr'
'GMASGDC03.acibadem.com.tr'
'LABMEDDC01.labmed.saglik.local'
'MOBDC01.mobil.saglik.local'
'GMLABMEDDC.labmed.saglik.local'
'MOBDC02.mobil.saglik.local'
'KDKDC02.acibadem.com.tr'
'KCLDC02.acibadem.com.tr'
'KDKDC01.acibadem.com.tr'
'KCLDC01.acibadem.com.tr'
'KOZDC01.acibadem.com.tr'
'MASDC01.acibadem.com.tr'
'MASDC02.acibadem.com.tr'
'KOZDC02.acibadem.com.tr'
'TKSDC02.acibadem.com.tr'
'TKSDC01.acibadem.com.tr'
'ADADC01.acibadem.com.tr'
'ADADC02.acibadem.com.tr'
'ANKDC02.acibadem.com.tr'
'ANKDC01.acibadem.com.tr'
'ATKDC02.acibadem.com.tr'
'BKRDC01.acibadem.com.tr'
'BKRDC02.acibadem.com.tr'
'BODDC02.acibadem.com.tr'
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
'KUCDC01.acibadem.com.tr'
'ALTDC01.acibadem.com.tr'
'ALTDC02.acibadem.com.tr'
'BODDC01.acibadem.com.tr'
'ATKDC01.acibadem.com.tr'
'GMMOBDC01.mobil.saglik.local'
'KUCDC02.acibadem.com.tr'
'INTDC01.acibadem.com.tr'
'INTDC02.acibadem.com.tr'
'DRCDC01.acibadem.com.tr'
'DRCDC02.acibadem.com.tr'
    )

$array = @()
foreach ($Comp in $Computers){
$userSystem =Get-WmiObject win32_operatingsystem -ComputerName $Comp -ErrorAction SilentlyContinue
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
$ServisName = Get-Service -ComputerName $Comp -DisplayName 'DNS Server'
$ServisStatus = "Erişim Sağlanamadı"
$ServisStatus = $ServisName.Status
$ENS = gwmi -class "win32reg_addremoveprograms" -computername $Comp | Where {$_.DisplayName -like "*McAfee Endpoint Security Platform*" } | Select -ExpandProperty Version
$ATP = gwmi -class "win32reg_addremoveprograms" -computername $Comp | Where {$_.DisplayName -like "*McAfee Endpoint Security Adaptive Threat Protection*" } | Select -ExpandProperty Version
$row = new-object psobject
        $row | add-member -type NoteProperty -name 'Server' -Value $Comp
        $row | add-member -type NoteProperty -name 'Service' -Value $ServisName
        $row | add-member -type NoteProperty -name 'Status' -Value $ServisStatus
        $row | add-member -type NoteProperty -name 'Drive' -Value $DriveName
        $row | add-member -type NoteProperty -name 'Free Disk ' -Value $FreeSpace
        $row | add-member -type NoteProperty -name 'Total Disk' -Value $Totalsize
        $row | add-member -type NoteProperty -name 'Last Boot' -Value $LastBoot
        $row | add-member -type NoteProperty -name 'Uptime/Day' -Value $Uptime
        $row | add-member -type NoteProperty -name 'Socket' -Value $Socket
        $row | add-member -type NoteProperty -name 'Core' -Value $Core
        $row | add-member -type NoteProperty -name 'Free VRam' -Value $FreeVirRam
        $row | add-member -Type NoteProperty -name 'Free Ram' -Value $FreeRam
        $row | add-member -Type NoteProperty -name "Total Ram" -Value $TotalRam
        $row | add-member -Type NoteProperty -name 'ENS' -Value $ENS
        $row | add-member -Type NoteProperty -name 'ATP' -Value $ATP
        $array += $row
       
}
$style = "<style>BODY{font-family: Tahoma; font-size: 10pt; }"
$style = $style + "TABLE{border: 2px solid black; border-collapse: collapse;letter-spacing: -0.4px; text-align: center;}"
$style = $style + "TH{border: 1px solid black; background: #3498DB; padding: 5px; text-align: center;}"
$style = $style + "TD{border: 1px solid black; padding: 5px; text-align: center; }"
$style = $style + "</style>"

$arrayoutput = $array | Sort-Object Server | ConvertTo-Html -Head $style 
#$arrayoutput = $array | FT -AutoSize * 
#$arrayoutput = $arrayoutput | ConvertTo-Html -Head $style

#$pingerResult = test-connection $ip -count 4 -quiet

$MailSender = "activedirectoryreport@acibadem.com"
$Subject = 'AD Sunucuları Raporu'
$SMTPServer = 'smtprelay01.acibadem.com.tr'
#$SendtoMail = "acibademsistemyonetimi@acibadem.com"
$SendtoMail = "kamil.cicek@acibadem.com"
$EmailBody = @"
<font face=Tahoma>Merhaba,</font><br />
<br />
<font face=Tahoma> ActiveDirectory sunucuları raporu aşağıdaki gibidir.</font><br />
<br />
<strong>$arrayoutput</strong><br /><br />
<br /></font></h5>
"@

Start-Sleep -s 1
Send-MailMessage -To $SendtoMail -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHTML -Priority High
