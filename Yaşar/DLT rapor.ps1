﻿#Connect-ExchangeOnline

 

$ad1 = Get-ADGroup -filter * -Properties * | Where-Object {$_.GroupCategory -eq "Distribution" -and $_.CanonicalName -like "WEBHELP.local/SITES/FR*"} | select name,description,GroupCategory,mail,SamAccountName,CanonicalName

 

#$ad1 = Get-ADGroup -Identity DLT-FR-COU1-COMUTITRES-SAINT-AVOLD -Properties * | Where-Object {$_.GroupCategory -eq "Distribution" -and $_.CanonicalName -like "*FR*"  -or $_.CanonicalName -like "*GR*" } | select name,description,GroupCategory,mail,SamAccountName,CanonicalName

 

$Results = foreach( $group in $ad1 ){
    $count1=(Get-ADGroupMember $group.SamAccountName ).Count
    $trace = Get-MessageTrace -RecipientAddress $group.mail -StartDate (get-date).AddDays(-10) -EndDate (get-date).AddDays(+1)
    $lastmail = $trace | select-object -first 1 |select received

 

    New-Object -TypeName psobject -Property @{
        Name                     = $group.name
        description              = $group.description
        GroupCategory            = $group.GroupCategory
        MemberCount              = $count1
        Mail                     = $group.mail
        SamAccountName           = $group.SamAccountName
        Lastmail                 = $lastmail.Received  
        CanonicalName            = $group.CanonicalName     


        }
    }

 

$Results | select name,description,GroupCategory,MemberCount,Mail,SamAccountName,Lastmail,CanonicalName

 

#$Results | export-csv c:/temp/yasar.csv