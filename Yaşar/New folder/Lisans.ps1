Connect-MsolService

#Get-MsolAccountSku

#powerbi free = webhelpgroup:POWER_BI_STANDARD
#F3 = webhelpgroup:DESKLESSPACK
#E3 = webhelpgroup:ENTERPRISEPACK
#E1 = webhelpgroup:STANDARDPACK

#       Users have been assigned licenses.


try{

$userlist1 = Get-Content -Path C:\temp\lisans.txt

foreach ($userlist in $userlist1) {

$userAD = Get-ADUser $userlist -Properties *

$UPN = $userad.userprincipalname

$Att5 = $userAD.extensionAttribute5

$Att6 = $userAD.extensionAttribute6

$userO365 = Get-MsolUser -UserPrincipalName $upn


##$userO365.Licenses
#$user.Licenses.ServiceStatus
#$user.Licenses.ServiceStatus |  Where-Object -Property ProvisioningStatus -EQ 'PendingInput'


#Lisans Silme
#Set-MsolUserLicense -UserPrincipalName $user.UserPrincipalName –RemoveLicenses "webhelpgroup:ENTERPRISEPACK"


if ($Att5 -eq 'K1') 
{

Set-MsolUserLicense -UserPrincipalName $usero365.UserPrincipalName -AddLicenses "webhelpgroup:DESKLESSPACK"

}


if ($Att5 -eq 'E3') 
{

Set-MsolUserLicense -UserPrincipalName $usero365.UserPrincipalName -AddLicenses "webhelpgroup:ENTERPRISEPACK"

}

if ($Att5 -eq 'E3-PBS') 
{

Set-MsolUserLicense -UserPrincipalName $usero365.UserPrincipalName -AddLicenses "webhelpgroup:ENTERPRISEPACK"

Set-MsolUserLicense -UserPrincipalName $usero365.UserPrincipalName -AddLicenses "webhelpgroup:POWER_BI_STANDARD"

}

if ($Att5 -eq 'K1-PBS') 
{

Set-MsolUserLicense -UserPrincipalName $usero365.UserPrincipalName -AddLicenses "webhelpgroup:DESKLESSPACK"

Set-MsolUserLicense -UserPrincipalName $usero365.UserPrincipalName -AddLicenses "webhelpgroup:POWER_BI_STANDARD"

}


if ($Att5 -eq 'E1-PBS') 
{

Set-MsolUserLicense -UserPrincipalName $usero365.UserPrincipalName -AddLicenses "webhelpgroup:STANDARDPACK"

Set-MsolUserLicense -UserPrincipalName $usero365.UserPrincipalName -AddLicenses "webhelpgroup:POWER_BI_STANDARD"

}


if ($Att5 -eq 'E1') 
{

Set-MsolUserLicense -UserPrincipalName $usero365.UserPrincipalName -AddLicenses "webhelpgroup:STANDARDPACK"

}








###################################################################################################################
}

}
catch {

$message = $_

Write-Host ( $userO365.dis + " user failed because : " + $message )

}

