
$style = "<style>BODY{font-family: Tahoma; font-size: 10pt; }"
$style = $style + "TABLE{border: 2px solid black; border-collapse: collapse;letter-spacing: -0.4px; text-align: center;}"
$style = $style + "TH{border: 1px solid black; background: #3498DB; padding: 5px; text-align: center;}"
$style = $style + "TD{border: 1px solid black; padding: 5px; text-align: center; }"
$style = $style + "</style>"

Import-Module -Name ActiveDirectory

## 2.1	Active Directory Objeler
##Haftalık eklenen user,Group,OU bilgisi;

$date = (get-date).AddDays(-7)

$ou=Get-ADOrganizationalUnit -Filter {whenCreated -gt $date} -Properties * | select name,whenCreated | ConvertTo-html -Head $style 

$user=Get-ADUser -Filter * -Properties * | where { $_.whenCreated -ge $date } | select Name,WhenCreated | ConvertTo-html -Head $style

$grup=Get-ADgroup -Filter * -Properties * | where { $_.whenCreated -gt $date }  |select Name,whenCreated | ConvertTo-html -Head $style


##2.2	Active Directory Site yapısı Raporu
##Haftalık eklenen site ve subnet bilgisi ;
##Haftalık KCC ve Dc’ler arası replikasyonların kontrolü gerekmektedir.

$adsite=Get-ADReplicationSite -Properties * | where { $_.whenCreated -ge $date } |select name,WhenCreated,whenchanged,subnets | ConvertTo-html -Head $style

if(Get-ChildItem "c:\Report\Repadmin\represult.csv"){

del "represult.csv"

}

cmd /c repadmin /showrepl * /csv > c:\Report\Repadmin\represult.csv

$repinfo=Import-csv "c:\Report\Repadmin\represult.csv"

$repinfo | select 'Source DSA','Destination DSA','Number of Failures','Last Failure Time','Last Success Time','Last Failure Status' | ft -AutoSize

$errcheck=$repinfo | select 'showrepl_Columns','naming context','Destination DSA'

foreach($e in $errcheck){

    if($e.showrepl_COLUMNS -like "showrepl_ERROR"){

        Write-host $e.'Naming Context' -ForegroundColor DarkYellow

    }

}  

Set-Location (get-location).Path

$filenameFormat = "Repreport" + " " + (Get-Date -Format "yyyy-MM-dd") + ".csv"
Rename-Item -Path "c:\Report\Repadmin\represult.csv" -NewName $filenameFormat





##2.3	Active Directory Domain Controllers Raporu
##Haftalık Sunucu Disk analizleri
##Sunucu adı – Disk durumu


$Computers= @(

Get-ADDomainController -filter * | Select-Object name

    )

$array = @()
foreach ($Comp in $Computers){
$userSystem =Get-WmiObject win32_operatingsystem -ComputerName $Comp.name -ErrorAction SilentlyContinue
$Uptime = ""
$Uptime = [math]::round((((Get-Date) - $userSystem.ConvertToDateTime($userSystem.LastBootUpTime))).TotalDays)
$LastBoot = ""
$LastBoot = ($userSystem.ConvertToDateTime($userSystem.LastBootUpTime)).tostring(“MM-dd-yyyy”)
$FreeRam = ""
$FreeRam = [math]::round(((Get-WmiObject Win32_OperatingSystem -ComputerName $Comp.name ).FreePhysicalMemory)/ 1048576,1)
$Socket = ""
$Socket = (Get-WmiObject Win32_ComputerSystem -Computername $Comp.name ).numberofprocessors
$Core = ""
$Core = (Get-WmiObject Win32_ComputerSystem -Computername $Comp.name ).NumberOfLogicalProcessors
$FreeVirRam = ""
$FreeVirRam = [math]::Round(((Get-WmiObject Win32_OperatingSystem -ComputerName $Comp.name ).FreeVirtualMemory) /1048576,1)
$TotalRam = ""
$TotalRam = [math]::Round(((Get-WmiObject Win32_ComputerSystem -Computername $Comp.name ).TotalPhysicalMemory) /1GB)
$CDrive = ""
$CDrive = Get-WmiObject win32_logicaldisk –ComputerName $Comp.name -filter "deviceid='C:'"
$Totalsize = ""
$Totalsize = [math]::Round($CDrive.Size /1GB)
$FreeSpace = ""
$FreeSpace = [math]::round($CDrive.FreeSpace / 1GB,0)
$DriveName = ""
$DriveName = $CDrive.DeviceID
$OS = (Get-WmiObject Win32_OperatingSystem -ComputerName $Comp.name).Caption
$row = new-object psobject
        $row | add-member -type NoteProperty -name 'Server' -Value $Comp.name
        $row | add-member -type NoteProperty -name 'OS' -Value $OS
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
        $array += $row
       
}

$arrayoutput = $array | Sort-Object Server | ConvertTo-Html -Head $style 


##2.4	Sunucu & Active Directory DC Kritik Açıklar Raporu
##Haftalık CVE databaseleri üzerinden güvenlik açıkları listelenmelidir.





##2.5	Active Directory Geçici Hesapların Raporu
##Haftalık oluşturulmuş Test user,computer hesapları ve Test veya POC OU’ların temizliği

$DateCutOff=(Get-Date).AddDays(-7)

$usertest=Get-ADUser -searchbase 'DC=tfz,DC=local' -Filter {samaccountname -like "*test*" -or name -like "*test*" -or surname -like "*test*" }  -Property name,whenCreated | Where {$_.whenCreated -gt $datecutoff} | select name,whenCreated  |ConvertTo-html -Head $style

$comptest = Get-ADComputer -searchbase 'DC=tfz,DC=local' -Filter{name -like "*test*"}  -Property whenCreated | Where {$_.whenCreated -gt $datecutoff} | select name,whenCreated | ConvertTo-html -Head $style

$gruptest = Get-ADGroup -searchbase 'DC=tfz,DC=local' -Filter{name -like "*test*"}  -Property whenCreated | Where {$_.whenCreated -gt $datecutoff}| select name,whenCreated | ConvertTo-html -Head $style

$outest = Get-ADOrganizationalUnit -searchbase 'DC=tfz,DC=local' -Filter{name -like "*test*"} -Property whenCreated | Where {$_.whenCreated -gt $datecutoff} | select name,whenCreated | ConvertTo-html -Head $style


##2.6	Active Directory Computers Description Raporu
##Aylık eksik description’a sahip computer ve server ‘ların bilgilerin tamamlanması


$DateCutOff=(Get-Date).AddDays(-31)
$EkiskDesc = Get-ADComputer -searchbase 'DC=tfz,DC=local' -Filter {(Enabled -eq "True" ) -and (description -notlike '*')} -Properties Description,whenCreated | 

Where {$_.whenCreated -gt $datecutoff} | select name,whenCreated,description | ConvertTo-html -Head $style 



##2.7	Domain controller üzerine kurulu 3th party servislerin listesi
##Aylık olarak listelenmelidir.

$ucparty = Invoke-Command -Computername $Computers.name -Scriptblock {

Get-WmiObject -Class Win32_Product | select name,vendor,pscomputername | Where-Object Vendor -notlike "*Microsoft*" | ConvertTo-html -Head $style 

}

##2.8	Yeni eklenen ve değiştirilmiş GPO’ler Raporu
##Aylık değişikliği yapılmış GPO ve değişiklik bilgilerini içermelidir.

$GPO = Get-GPO -All | ?{ ([datetime]::today - ($_.ModificationTime)).Days -le 31 } | select DisplayName,ModificationTime  | ConvertTo-html -Head $style


##2.9	Active Directory CA Raporu
##Aylık Sertifika sunucunun genel incelemesi gerekir

$ExpiredCertsmy = Invoke-Command -Computername $Computers.name -Scriptblock {

$Servername = [Environment]::GetEnvironmentVariable

Get-ChildItem Cert:LocalMachine\MY -Recurse | Where-Object {$_ -is [System.Security.Cryptography.X509Certificates.X509Certificate2] -and 

$_.NotAfter -le ((Get-date))} | sort notafter |Select-Object dnsnamelist,notafter,notbefore,pscomputername

}  | ConvertTo-html -Head $style

$ExpiredCertsrdp = Invoke-Command -Computername $Computers.name -Scriptblock {

$Servername = [Environment]::GetEnvironmentVariable

Get-ChildItem 'Cert:\LocalMachine\Remote Desktop' -Recurse | Where-Object {$_ -is [System.Security.Cryptography.X509Certificates.X509Certificate2] -and 

$_.NotAfter -le ((Get-date))} | sort notafter |Select-Object dnsnamelist,notafter,notbefore,pscomputername

}  | ConvertTo-html -Head $style


$ValidCertsmy = Invoke-Command -Computername $Computers.name -Scriptblock {

$Servername = [Environment]::GetEnvironmentVariable

Get-ChildItem Cert:\LocalMachine\My -Recurse | Where-Object {$_ -is [System.Security.Cryptography.X509Certificates.X509Certificate2] -and 

$_.NotAfter -gt (Get-Date) -and $_.NotAfter -lt (Get-Date).AddDays(365)} | sort notafter | Select-Object -Property dnsnamelist,notafter,notbefore,pscomputername

} | ConvertTo-html -Head $style


$ValidCertsrdp = Invoke-Command -Computername $Computers.name -Scriptblock {

$Servername = [Environment]::GetEnvironmentVariable

Get-ChildItem 'Cert:\LocalMachine\Remote Desktop' -Recurse | Where-Object {$_ -is [System.Security.Cryptography.X509Certificates.X509Certificate2] -and 

$_.NotAfter -gt (Get-Date) -and $_.NotAfter -lt (Get-Date).AddDays(365)} | sort notafter | Select-Object -Property dnsnamelist,notafter,notbefore,pscomputername

} | ConvertTo-html -Head $style


##2.10	Active Directory DC Windows Update
##Aylık DC’lerin Security ve critical path gereksinim listesini içermelidir.

$yukluupdates = Invoke-Command -Computername $Computers.name -Scriptblock {

Get-HotFix | Sort-Object -Property InstalledOn | select PSComputerName,Description,HotFixID,InstalledOn |ConvertTo-html -Head $style

}


##2.11	Active Directory DC’lerin event log inceleme Raporu
##Haftalık DC’lerdeki krtik event log’ların bulgu raporuna eklenmelidir. 

$errorlog = Invoke-Command -Computername $Computers.name -Scriptblock {

Get-EventLog -LogName 'Directory Service' -EntryType Error,warning -After(get-date).AddDays(-7) -Before(get-date) | select PSComputerName,EntryType,Message,TimeGenerated,InstanceID | sort TimeGenerated

} | ConvertTo-html -Head $style



$MailSender = "DcControl@yildirimgroup.com"
$Subject = 'Domain COntroller Sunucuları Raporu'
$SMTPServer = '10.32.8.35'
$SendtoMail = "yasar.abravaya@yildirimgroup.com"
$SendtoMail1 = "yakup.akpinar@yildirimgroup.com"
$EmailBody = @"
<font face=Tahoma>Merhaba,</font><br />
<br />
<br />
<font face=Tahoma>2.1 Haftalık eklenen user,Group,OU bilgisi</font><br />
<br />
<font face=Tahoma>Son 1 haftada oluşturulan ou</font><br />
<br />
<strong>$ou</strong><br /><br />
<br />
<font face=Tahoma> Son 1 haftada oluşturulan user </font><br />
<br />
<strong>$user</strong><br /><br />
<br />
<font face=Tahoma> Son 1 haftada oluşturulan grup </font><br />
<br />
<strong>$grup</strong><br /><br />
<br />
<font face=Tahoma>2.2 Active Directory Site yapısı Raporu</font><br />
<br />
<strong>$adsite</strong><br /><br />
<br />
<br />
<strong>Aşağıdaki linkten ayrıntılı rapora erişebilirsiniz</strong>
<br />
<strong>\\STUR100ADCVP01\Repadmin</strong>
<br />
<br />
<font face=Tahoma> 2.3	Active Directory Domain Controllers Raporu - Haftalık Sunucu Disk analizleri</font><br />
<br />
<strong>$arrayoutput</strong><br /><br />
<br />
<font face=Tahoma> 2.5 Active Directory Geçici Hesapların Raporu - Haftalık oluşturulmuş Test user,computer hesapları ve Test veya POC OU’ların temizliği</font><br />
<br />
<font face=Tahoma>Haftalık oluşturulmuş Test user</font><br />
<br />
<strong>$usertest</strong><br /><br />
<br />
<font face=Tahoma>Haftalık oluşturulmuş Test Computer</font><br />
<br />
<strong>$comptest</strong><br /><br />
<br />
<font face=Tahoma>Haftalık oluşturulmuş Test Grup</font><br />
<br />
<strong>$gruptest</strong><br /><br />
<br />
<font face=Tahoma>Haftalık oluşturulmuş Test OU</font><br />
<br />
<strong>$outest</strong><br /><br />
<br />
<font face=Tahoma> 2.6	Active Directory Computers Description Raporu - Aylık eksik description’a sahip computer ve server ‘ların bilgilerin tamamlanması</font><br />
<br />
<strong>$EkiskDesc</strong><br /><br />
<br />
<font face=Tahoma> 2.7	Domain controller üzerine kurulu 3th party servislerin listesi - Aylık olarak listelenmelidir.</font><br />
<br />
<strong>$ucparty</strong><br /><br />
<br />
<font face=Tahoma> 2.8	Yeni eklenen ve değiştirilmiş GPO’ler Raporu - Aylık değişikliği yapılmış GPO ve değişiklik bilgilerini içermelidir</font><br />
<br />
<strong>$GPO</strong><br /><br />
<br />
<font face=Tahoma> 2.9	Active Directory CA Raporu - Aylık Sertifika sunucunun genel incelemesi gerekir</font><br />
<br />
<font face=Tahoma>-Expire olmuş sertifaların listesi</font><br />
<br />
<font face=Tahoma>MY</font><br />
<br />
<strong>$ExpiredCertsmy</strong><br /><br />
<br />
<font face=Tahoma>RDP</font><br />
<br />
<strong>$ExpiredCertsrdp</strong><br /><br />
<br />
<font face=Tahoma>-Expire olacak sertifikaların listesi</font><br />
<br />
<font face=Tahoma>MY</font><br />
<br />
<strong>$ValidCertsmy</strong><br /><br />
<br />
<font face=Tahoma>RDP</font><br />
<br />
<strong>$ValidCertsrdp</strong><br /><br />
<br />
<font face=Tahoma>2.10	Active Directory DC Windows Update - Aylık DC’lerin Security ve critical path gereksinim listesini içermelidir.	</font><br />
<br />
<strong>$yukluupdates</strong><br /><br />
<br />
<br />
<font face=Tahoma>2.11	Active Directory DC’lerin event log inceleme Raporu - Haftalık DC’lerdeki krtik event log’ların bulgu raporuna eklenmelidir.</font><br />
<br />
<strong>$errorlog</strong><br /><br />
<br />
<br /></font></h5>
"@



Start-Sleep -s 1
#Send-MailMessage -To $SendtoMail -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHTML -Priority High

#Send-MailMessage -To $SendtoMail1 -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $EmailBody -Encoding ([System.Text.Encoding]::Unicode) -BodyAsHTML -Priority High

$EmailBody | Out-File C:\Report\WeeklyReport\WeeklyReport.htm
