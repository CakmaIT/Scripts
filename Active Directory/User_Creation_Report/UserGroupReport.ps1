#Setting Date of One Week Back
$week = (Get-Date).AddDays(-7)
$today = (Get-Date).ToString()

# Html
$a = "<style>"
$a = $a + "BODY{background-color:PowderBlue ;}"
$a = $a + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
$a = $a + "TH{border-width: 1px;padding: 5px;border-style: solid;border-color: black;background-color:DarkBlue}"
$a = $a + "TD{border-width: 1px;padding: 5px;border-style: solid;border-color: black;background-color:LightSkyBlue}"
$a = $a + "</style>"


# Email Variables
$smtp = "mail.yildirimgroup.com"
$to = "system.monitor@yildirimgroup.com" 
$from = "system.monitor@yildirimgroup.com"
$subject = "Haftalik Kullanici ve Grup olusturma Raporu"

# Import Module of Active Directory
Import-Module -Name ActiveDirectory

# Run Command 
$Users = Get-ADUser -Filter * -Properties * | `
	where { $_.whenCreated -ge $week }  | sort | select Name,WhenCreated  `
                                          | ConvertTo-html -Head $a -Body "<H2>Gecen Hafta Olusturulan Kullanicilar</H2>"
#  Group
$group = Get-ADgroup -Filter * -Properties * | `
	where { $_.whenCreated -ge $week } | sort |select Name,whenCreated `
                                          | ConvertTo-html -Head $a -Body "<H2>Gecen Hafta Olusturulan Gruplar</H2>"


$body = "Rapor olusturma Araligi $week - $today ."
$body += "`n"
$body += $Users
$body += "`n"
$body += $group
$body += "`n"


Send-MailMessage -SmtpServer $smtp -To $to -From $from -Subject $subject -Body $body -BodyAsHtml