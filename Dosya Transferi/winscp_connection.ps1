Import-Module -Name WinSCP
#Credential Bilgisi
read-host -assecurestring | convertfrom-securestring | out-file C:\userdata\securestring.txt
$pass = cat C:\userdata\securestring.txt | convertto-securestring
$mycred = new-object -typename System.Management.Automation.PSCredential -argumentlist "13742517P",$pass
$mycred.GetNetworkCredential().Password

#Folder Bilgisi
$folder = Get-Date -Format yyyyMMdd

#SFTP Baglan ve dosya cek

$Options = New-WinSCPSessionOption -HostName "prodftp2.successfactors.eu" -Credential $mycred -GiveUpSecurityAndAcceptAnySshHostKey
$session = Open-WinSCPSession -SessionOption $Options
Receive-WinSCPItem -WinSCPSession $Session -RemotePath "/BT/$folder/" -LocalPath "C:\UserData"





<#Password sifrelemek icin
#>
read-host -assecurestring | convertfrom-securestring | out-file C:\userdata\securestring.txt
$pass = cat C:\userdata\securestring.txt | convertto-securestring
$mycred = new-object -typename System.Management.Automation.PSCredential -argumentlist "13742517P",$pass
$mycred.GetNetworkCredential().Password

#Close-WinSCPSession -WinSCPSession $Session  #pass : GUqo48cNSlGr