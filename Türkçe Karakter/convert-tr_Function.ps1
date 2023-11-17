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


Convert-TR $d.adsoyad

