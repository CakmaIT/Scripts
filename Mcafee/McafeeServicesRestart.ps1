Get-Service -Name "MCAFEETOMCATSRV590" -ComputerName EPO | Stop-Service -Force -Verbose
Start-Sleep -Seconds 10
Get-Service -Name "MCAFEEAPACHESRV" -ComputerName EPO | Stop-Service -Force -Verbose
Start-Sleep -Seconds 10
Get-Service -Name "MCAFEEEVENTPARSERSRV" -ComputerName EPO | Stop-Service -Force -Verbose

Start-Sleep -Seconds 60

Get-Service -Name "MCAFEETOMCATSRV590" -ComputerName EPO | Start-Service -Verbose
Start-Sleep -Seconds 10
Get-Service -Name "MCAFEEAPACHESRV" -ComputerName EPO | Start-Service -Verbose
Start-Sleep -Seconds 10
Get-Service -Name "MCAFEEEVENTPARSERSRV" -ComputerName EPO | Start-Service -Verbose
