$1 = "TEST Deneme"
$2 = "deneme"
$3 = "$1 $2"

$1.Substring(0,1).ToUpper()+$1.Substring(1).ToLower()

[bool](Get-ADUser -Filter "DisplayName -eq 'werwerwqer 2er'" -ErrorAction SilentlyContinue)

($d.FirstName.Substring(0,1).ToUpper()+$d.FirstName.Substring(1).ToLower()) + " " + ($d.LastName.ToUpper())
$d.LastName.ToUpper()

Get-ADUser -Filter "DisplayName -eq '$($d.adsoyad)'" | Set-ADUser 