Set-ExecutionPolicy unrestricted 

Install-module MicrosoftTeams -force -Allowclobber -skipPublisherCheck 

Import-Module -Name MicrosoftTeams 

Connect-MicrosoftTeams

Get-CsOnlineUser -Identity "RES-ZA-PT-COOP@za.webhelp.com"

Set-CsPhoneNumberAssignment -Identity RES-ZA-PT-COOP@za.webhelp.com -EnterpriseVoiceEnabled $true