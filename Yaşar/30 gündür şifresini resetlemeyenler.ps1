$Days = 30
$Time = [DateTime]::Today.AddDays(-$Days)

Get-ADUser -Properties DisplayName, UserPrincipalName, SamAccountName, DistinguishedName, PasswordLastSet, LastLogonDate, PasswordExpired, PasswordNeverExpires -Filter {(PasswordLastSet -lt $Time) -and (Enabled -eq $true) -and (UserPrincipalName -notlike "*svc-*") -and (UserPrincipalName -notlike "*smb-*") -and (UserPrincipalName -notlike "*res-*") -and (DisplayName -notlike "*svc-*") -and (DisplayName -notlike "*smb-*") -and (DisplayName -notlike "*res-*") -and (CN -notlike "*svc-*") -and (CN -notlike "*smb-*") -and (CN -notlike "*res-*")} |
    
    
    Select-Object DisplayName, UserPrincipalName, SamAccountName, DistinguishedName, PasswordLastSet, LastLogonDate, @{Name="User Must Change Password at Next Logon";Expression={$_.PasswordExpired}},@{Name="Password never expire";Expression={$_.PasswordNeverExpires}} |
    
    
    Export-Csv -Path 'C:\temp\yasaryasar123123.csv' -NoTypeInformation -Encoding Unicode
