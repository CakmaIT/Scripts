Set-ExecutionPolicy RemoteSigned

Install-Module -Name PowerShellGet -Force

Install-Module -Name ExchangeOnlineManagement -Force

(Get-Module -ListAvailable -Name ExchangeOnlineManagement) -ne $null

Connect-ExchangeOnline -UserPrincipalName adm-yabravaya@webhelp.fr -ShowProgress $true

#Connect-ExchangeOnline -UserPrincipalName john@contoso.com -ShowProgress $true -DelegatedOrganization contoso.onmicrosoft.com