Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;

$OUpath = 'OU=DisabledUsers,DC=yildirim,DC=local'
$ExportPath = 'C:\temp\users_all1.csv'


#Where {$_.HiddenFromAddressListsEnabled -eq $True}

Get-Mailbox -OrganizationalUnit 'OU=DisabledUsers,DC=yildirim,DC=local' | 

select DisplayName,SamAccountName,UserPrincipalName,OrganizationalUnit,PrimarySmtpAddress,HiddenFromAddressListsEnabled| Export-Csv -NoType $ExportPath

#Get-ADUser -Filter * -SearchBase $OUpath | Where {$_.HiddenFromAddressListsEnabled -eq $True} 


#Düzeltme için
Get-Mailbox -OrganizationalUnit 'OU=DisabledUsers,DC=yildirim,DC=local' | Where {$_.HiddenFromAddressListsEnabled -eq $False} | Set-Mailbox -HiddenFromAddressListsEnabled $true