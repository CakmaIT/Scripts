Import-Module -Name Posh-SSH
$compacc = 'prodftp2.successfactors.eu'
$uname = '13742517P'
$pass = 'GUqo48cNSlGr'

$date = Get-Date -Format ddMMyyyy

$destpath = "/PersonelIseGirisRapor/Report_HireUserList_$date.csv"


$cred = Get-Credential -Credential $uname
Get-SCPFolder -ComputerName $compacc -Credential $cred -LocalFolder "c:\UserData" -RemoteFolder "/BT/"

Start-Sleep 5

$FtpItem = Get-ChildItem C:\test\1\readme.txt



Rename-Item -Path $FtpItem -NewName "$date.txt"

Start-Sleep 5

Move-Item -Path c:\test\1\$date.txt -Destination C:\test\1\tasi\$date.txt