#$credential = Get-Credential

#$credential | Export-Clixml -Path C:\Scripts\Snapshot_Removal\mycredential.xml

#Get-Snapshot -VM * | Where-Object {$_.Created -lt (Get-Date).AddDays(-14)} | select VM,Description,Created,Parent,children

$credential = Import-Clixml -Path C:\Scripts\Snapshot_Removal\mycredential.xml


Connect-VIServer -Server 10.147.8.10 -Credential $credential

Get-Snapshot -VM * | Where-Object {$_.Created -lt (Get-Date).AddDays(-14)} | Remove-Snapshot -RemoveChildren -Confirm:$false

Connect-VIServer -Server 10.253.68.10 -Credential $credential

Get-Snapshot -VM * | Where-Object {$_.Created -lt (Get-Date).AddDays(-14)} | Remove-Snapshot -RemoveChildren -Confirm:$false

Connect-VIServer -Server 10.69.77.101 -Credential $credential

Get-Snapshot -VM * | Where-Object {$_.Created -lt (Get-Date).AddDays(-14)} | Remove-Snapshot -RemoveChildren -Confirm:$false

Connect-VIServer -Server 10.89.90.61 -Credential $credential

Get-Snapshot -VM * | Where-Object {$_.Created -lt (Get-Date).AddDays(-14)} | Remove-Snapshot -RemoveChildren -Confirm:$false