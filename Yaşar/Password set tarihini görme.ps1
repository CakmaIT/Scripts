$csvPath = 'C:\temp\lastpasswordset.csv'

Get-Content 'C:\temp\users.txt' | ForEach-Object {
    $user = $_
    $pwdLastSet = (Get-ADUser $user -Properties "PwdLastSet").PwdLastSet
    $lastSetDate = [DateTime]::FromFileTime($pwdLastSet)
    $source = ""
    $logonTime = (Get-ADUser $user -Properties "msDS-LastSuccessfulInteractiveLogonTime")."msDS-LastSuccessfulInteractiveLogonTime"
    $logonTimeDate = [DateTime]::FromFileTime($logonTime)
    if ($logonTimeDate -lt $lastSetDate) {
        $source = "Administrator reset"
    } else {
        $source = "User reset"
    }
    $mustChange = (Get-ADUser $user -Properties "PasswordExpired","PasswordNeverExpires").PasswordExpired -or (Get-ADUser $user -Properties "PasswordExpired","PasswordNeverExpires").PasswordNeverExpires
    New-Object PSObject -Property @{
        "Username" = $user
        "Last Password Set Date" = $lastSetDate
        "Password Set By" = $source
        "User Must Change Password at Next Logon" = $mustChange
    }
} | Export-Csv $csvPath -NoTypeInformation 
