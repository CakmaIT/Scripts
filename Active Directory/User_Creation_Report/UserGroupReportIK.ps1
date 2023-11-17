#Setting Date of One Week Back
$week = (Get-Date).AddDays(-1)
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
$to = "HR_Welcome_Team@yildirimgroup.com" 
$from = "HR_Welcome_Team@yildirimgroup.com"
$subject = "Daily User Report"

# Import Module of Active Directory
Import-Module -Name ActiveDirectory

# Run Command 
$Users = Get-ADUser -Filter * -Properties WhenCreated | `
	where { $_.whenCreated -ge $week }  | sort | select Name,SamAccountName,WhenCreated  `
                                          | ConvertTo-html -Head $a -Body "<H2>Gunluk Olusan User Listesi</H2>"
$body = "Rapor olusturma Araligi $week - $today ."
$body += "`n"
$body += $Users
$body += "`n"



Send-MailMessage -SmtpServer $smtp -To $to -From $from -Subject $subject -Body $body -BodyAsHtml