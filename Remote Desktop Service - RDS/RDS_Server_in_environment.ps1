$termserv = Get-ADObject -Filter {objectClass -eq 'serviceConnectionPoint' -and Name -eq 'TermServLicensing'} -Properties * | Select ServiceDNSName,CN,WhenCreated | ConvertTo-Html

Send-MailMessage -To erkan.guler@yildirimgroup.com -From erkan.guler@yildirimgroup.com -BodyAsHtml -Body "$termserv" -SmtpServer mail.yildirimgroup.com -Subject "RDS Sunucular"