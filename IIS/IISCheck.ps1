$Computers= @(
'ALTCPLUS01'
'ALTCPLUS02'
'ASG100CCP03'
'ASG100CCP04'
'ASG100CCP05'
'ASG100CCP06'
'ASG100CCP07'
'ASG100CCP08'
'ASG100CCP09'
'ASG100CCP10'
'ASG100CCP11'
'ASG100CCP12'
'ASG100CCP13'
'ASG100CCP14'
'ASG100CCP15'
'ASG100CCP16'
'ASG100CCP17'
'ASG100COR01'
'ASG100COR02'
'CPLUSIIS03'
'CPLUSIIS04'
'ASG100CPP01'
'ASG100CPP02'
'CPLUSIIS01'
'CPLUSIIS02'
'ASG100CPT03'
'ASG100CPT04'
'ASG100CPT05'
'CPLUSIIS06'
'ASG100CPU03'
'ASG100CPU04'
'ATMCPPLUS01'
'ATMCPPLUS02'
'ASG100TCP01'
'ASG100TCP02'
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
$ServisName = Get-Service -ComputerName $Comp -DisplayName 'World Wide Web Publishing Service'
$ServisStatus = "Erişim Sağlanamadı"
$ServisStatus = $ServisName.Status
$OS = (Get-WmiObject Win32_OperatingSystem -ComputerName $Comp).Caption
$ENS = gwmi -class "win32reg_addremoveprograms" -computername $Comp | Where {$_.DisplayName -like "*McAfee Endpoint Security Platform*" } | Select -ExpandProperty Version
$ATP = gwmi -class "win32reg_addremoveprograms" -computername $Comp | Where {$_.DisplayName -like "*McAfee Endpoint Security Adaptive Threat Protection*" } | Select -ExpandProperty Version
$row = new-object psobject
        $row | add-member -type NoteProperty -name 'Server' -Value $Comp
        $row | add-member -type NoteProperty -name 'OS' -Value $OS
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

$MailSender = "iisreport@acibadem.com"
$Subject = 'IIS Sunucuları Raporu'
$SMTPServer = 'smtprelay01.acibadem.com.tr'
$SendtoMail = "acibademsistemyonetimi@acibadem.com"
#$SendtoMail = "kamil.cicek@acibadem.com"
$EmailBody = @"
<font face=Tahoma>Merhaba,</font><br />
<br />
<font face=Tahoma> Merkezi IIS sunucuları raporu aşağıdaki gibidir.</font><br />
<br />
<strong>$arrayoutput</strong><br /><br />
<br /></font></h5>
"@

Start-Sleep -s 1
Send-MailMessage -To $SendtoMail -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHTML -Priority High
