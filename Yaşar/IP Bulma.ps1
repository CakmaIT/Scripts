
$servers = Get-Content -Path C:\temp\IP.txt


$Results = foreach( $server in $Servers ){

    $IP=Test-Connection $server -count 1 | select @{Name="Computername";Expression={$_.Address}},Ipv4Address

 

    New-Object -TypeName psobject -Property @{
        Name                     = $server
        IP                       = $IP.IPV4Address
          


        }
    }

 

$Results | select name,IP

 

$Results | export-csv c:/temp/IP.csv