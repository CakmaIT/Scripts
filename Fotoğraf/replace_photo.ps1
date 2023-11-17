$skypCred = Get-Credential
$sessionOpt = New-PSSessionOption  -SkipRevocationCheck
$session = New-PSSession -ConnectionURI “https://TRISGBSFVP001.yildirim.local/OcsPowershell” -Credential $skypCred -SessionOption $sessionOpt
Import-PsSession $session
Get-CsUser eguler

#ChangePhoto
Get-ADUser iogmen | Set-ADUser -Replace @{thumbnailPhoto=([byte[]](Get-Content "C:\Users\gulere\Desktop\eguler.jpg" -Encoding byte))}

Get-Content C:\users\gulere\Desktop\mhan.jpg