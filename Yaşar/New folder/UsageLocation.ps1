$users = Get-Content 'C:\Users\yasar.abravaya\OneDrive - WEBHELP\Desktop\F3_License_users.csv'

#Connect-MsolService

$Results = foreach( $user in $users ){
    $o365 = Get-MsolUser -UserPrincipalName $user

    New-Object -TypeName psobject -Property @{
        DisplayName                     = $o365.DisplayName
        UserPrincipalName               = $o365.UserPrincipalName 
        UsageLocation                   = $o365.UsageLocation
        Country                         = $o365.Country 
        City                            = $o365.City 
        Licenses                        = $o365.Licenses
        }
    }


$Results | select DisplayName,UserPrincipalName,UsageLocation,Country,City,Licenses

$Results | export-csv c:/temp/UsageLocation.csv