Import-Module ImportExcel
Import-Module ActiveDirectory

##$test = Get-Content C:\UserData\data\test_export.csv | select -Skip 2 | ConvertFrom-Csv


$deneme1 = Import-Excel -Path C:\UserData\Report_RevisedUserList-Component1.xlsx -StartRow 3



foreach ($d in $deneme1)
{

$Params = @{
SamAccountName = "$($d.FirstName.Substring(0,2))$($d.LastName.ToLower())" -replace('Ü','U') -replace ('ü','u') -replace ('Ğ','G') -replace ('ğ','g') -replace ('İ','i') -replace ('ı','i') -replace ('Ö','O') -replace ('ö','o') -replace ('Ş','S') -replace ('ş','s') -replace ('Ç','C') -replace ('ç','c') 
Name = $d.adsoyad -replace('Ü','U') -replace ('ü','u') -replace ('Ğ','G') -replace ('ğ','g') -replace ('İ','i') -replace ('ı','i') -replace ('Ö','O') -replace ('ö','o') -replace ('Ş','S') -replace ('ş','s') -replace ('Ç','C') -replace ('ç','c')
GivenName = $d.FirstName.Substring(0,1).ToUpper()+$d.FirstName.Substring(1).ToLower() -replace('Ü','U') -replace ('ü','u') -replace ('Ğ','G') -replace ('ğ','g') -replace ('İ','i') -replace ('ı','i') -replace ('Ö','O') -replace ('ö','o') -replace ('Ş','S') -replace ('ş','s') -replace ('Ç','C') -replace ('ç','c')
Surname = $d.LastName.ToUpper() -replace('Ü','U') -replace ('ü','u') -replace ('Ğ','G') -replace ('ğ','g') -replace ('İ','i') -replace ('ı','i') -replace ('Ö','O') -replace ('ö','o') -replace ('Ş','S') -replace ('ş','s') -replace ('Ç','C') -replace ('ç','c')
Displayname = ($d.FirstName.Substring(0,1).ToUpper()+$d.FirstName.Substring(1).ToLower()) + " " + ($d.LastName.ToUpper()) -replace('Ü','U') -replace ('ü','u') -replace ('Ğ','G') -replace ('ğ','g') -replace ('İ','i') -replace ('ı','i') -replace ('Ö','O') -replace ('ö','o') -replace ('Ş','S') -replace ('ş','s') -replace ('Ç','C') -replace ('ç','c')
OfficePhone = $d.TelephoneNumber
Company = $d.Company
Department = $d.Department
Title = $d.JobTitle
UserPrincipalName = "$($d.FirstName.Substring(0,2))$($d.LastName)@yildirim.local" -replace('Ü','U') -replace ('ü','u') -replace ('Ğ','G') -replace ('ğ','g') -replace ('İ','i') -replace ('ı','i') -replace ('Ö','O') -replace ('ö','o') -replace ('Ş','S') -replace ('ş','s') -replace ('Ç','C') -replace ('ç','c') 
AccountPassword = (ConvertTo-SecureString "Aa12345678" -AsPlainText -Force)
Path = "OU=test2,DC=yildirim,DC=local"
Enabled = $true

}

New-ADUser @Params -Verbose  
   
} 

Start-Sleep 3

#mail ayarlari
$from = "system.monitor@yildirimgroup.com"
$to = "system.monitor@yildirimgroup.com"
$subject = "Bugun olusan kullanicilar:"
$smtp = "mail.yildirimgroup.com"

foreach ($d in $deneme1)
{
    Send-MailMessage -From $from -To $to -Subject $subject -SmtpServer $smtp -Port 25 -Body $d.adsoyad -Encoding Unicode

}


<#

$formail1 =  Get-ADUser -Filter "DisplayName -eq '$($e.adsoyad)'" -ErrorAction SilentlyContinue

 foreach ($e in $formail1)
    {


if ([bool]$formail1 -eq $TRUE)
{
}
else
{
    $errmessage = "Bir hata olustu"
    Send-MailMessage -From $from -To $to -Subject $subject -SmtpServer $smtp -Port 25 -Body "$errmessage"
}
}
#>