$date = (Get-Date).AddDays(-6)
Get-ADUser -Filter * -Properties whenchanged | where {$_.whenchanged -like $date}

Get-ADUser eguler -Properties |fl