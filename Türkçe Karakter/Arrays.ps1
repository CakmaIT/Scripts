Import-Module ImportExcel
Import-Module ActiveDirectory

function Convert-TR{
    Param(
        [String]$inputString
    )
    $replaceTable = @{"ç"="c";"İ"="I";"Ü"="U";"Ğ"="G";"Ö"="O";"Ş"="S"}

    foreach($key in $replaceTable.Keys){
        $inputString = $inputString -Replace($key,$replaceTable.$key)
    }
    return $inputString
}

$deneme8 = Import-Excel -Path C:\UserData\xlsxtest.xlsx -StartRow 3

$FirstName=@()
$Lastname=@()
$adsoyad=@()
$telephonenumber=@()
$title=@()
$dep=@()
$company=@()
$sam=@()

foreach ($dem in $deneme8)
{

$dem.'E-Mail'
    $FirstName += $dem.FirstName.Substring(0,1).ToUpper()+$dem.FirstName.Substring(1).ToLower()
    $LastName += $dem.LastName.ToUpper()
    $adsoyad += $dem.adsoyad
    $telephoneNumber += $dem.telephoneNumber
    $title += $dem.jobtitle
    $dep += $dem.department
    $company += $dem.Company
    $sam  += Convert-TR -inputString ($($dem.FirstName.Substring(0,2))+$($dem.LastName))
    Convert-TR -inputString "$($d.FirstName.ToLower().Substring(0,2))$($d.LastName.ToLower())"
}