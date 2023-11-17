$recently = [DateTime]::Today.AddDays(-10)
$Tar=(get-date -Format dd/MM/yyyy/hhmm)
$GetComp= Get-ADComputer -Filter 'WhenCreated -ge $recently' -Properties whenCreated,OperatingSystem | Where {($_.OperatingSystem -notlike "*server*") -and ($_.OperatingSystem -like "*windows*")} | Select Name
$GetComp.Count
$DNSArray = @()
$HostCl= @()
foreach ($CheckDns in $GetComp)
{
  $DNSArray+= Get-DnsServerResourceRecord -ComputerName gmasgdc03 -ZoneName acibadem.com.tr -Name $CheckDns.Name -RRType A | Where {($_.Timestamp -ne $null)} 
}
    ForEach ($DNSRecord in $DNSArray)
    {
        If ($DNSRecord.RecordType -eq "A" -and $DNSRecord.Timestamp -ne $Null -and $DNSRecord.Hostname -ne "@")
        {
            Write-Host $DNSRecord.HostName
            $Computer = $DNSRecord.HostName
            $TimestampDNS = $DNSRecord.Timestamp
           
            Try
            {
                $ADComputer = Get-ADComputer $Computer -Properties whenCreated
                $CreateDate = $ADComputer.whenCreated

            }
            Catch
            {
                Write-Host "The computer object could not be retreived from Active Directory. Skip." -ForegroundColor yellow
            }

            $DNSObject = New-Object -TypeName PSObject
            Add-Member -InputObject $DNSObject -MemberType 'NoteProperty' -Name 'Hostname' -Value $Computer
            Add-Member -InputObject $DNSObject -MemberType 'NoteProperty' -Name 'TimeStampDNS' -Value $TimestampDNS
            Add-Member -InputObject $DNSObject -MemberType 'NoteProperty' -Name 'CreateDate' -Value $CreateDate
            $DNSArray += $DNSObject
            
            If (($DNSRecord.Timestamp) -lt $CreateDate)
            {
                
                $HostCl+= $DNSRecord 
                Write-Host OldDNSRecord
                Write-Host $HostCl
                $HostCl | Export-Csv -Path C:\Disable_Computer\$Tar'_'StaleDNSRecord.csv -NoTypeInformation -Append
                #$HostCl+= $DNSRecord.HostName 
                #Write-Host $Computer
                #Get-DnsServerResourceRecord -ComputerName gmasgdc03 -ZoneName acibadem.com.tr -Name $Computer -RRType A 
               Remove-DnsServerResourceRecord -ComputerName gmasgdc03 -ZoneName acibadem.com.tr -Name $Computer -RRType A -Force
                #Remove-DnsServerResourceRecord -ComputerName gmasgdc03 -ZoneName "acibadem.com.tr" -RRType A -Name $Computer -Force
                #Remove-DnsServerResourceRecord -ZoneName "acibadem.com.tr" -RRType A -Name $Record.HostName
            }
             #Add-Member -InputObject $DNSObject -MemberType 'NoteProperty' -Name 'Status' -Value $Status
            #$DNSArray += $DNSObject
        }
    }
    $HostCl.Count
    #Read-Host
    #Send-MailMessage -SmtpServer "smtprelay01.acibadem.com.tr" -From "dnstest@acibadem.com" -To "tugrul.kilic@acibadem.com" -Subject "Dns Clean" -Body "DNS Clean"
    #$DNSArray | Out-GridView -Title "DNS Records - Stale Repor"
    #Remove-DnsServerResourceRecord -ZoneName "acibadem.com.tr" -RRType A -Name 25P32788 -Force
    #Remove-DnsServerResourceRecord -ComputerName gmasgdc03 -ZoneName "acibadem.com.tr" -RRType A -Name $Record.HostName -Force

    #get-adComputer 31P42031 -Properties whencreated
    #Get-DnsServerResourceRecord -ComputerName gmasgdc03 -ZoneName acibadem.com.tr -Name 32P48607 -RRType A 
    ##
