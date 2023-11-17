$Server = "gbzexc01.yildirim.local"
$Credentials = Get-Credential -Message "Enter your Exchange admin credentials."
$ExchangeParams = @{
    ConfigurationName = 'Microsoft.Exchange'
    ConnectionUri     = "http://$Server/PowerShell/"
    Authentication    = 'Kerberos'
    Credential        = $Credentials
}
$ExchangeSession = New-PSSession @ExchangeParams
Import-PSSession $ExchangeSession