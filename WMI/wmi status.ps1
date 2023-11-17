$Computers = $env:COMPUTERNAME
#$Computers = Get-Content C:\Computerlist.txt

Function Test-WMIStatus
{
Param(
[Array]$Computers
)

$Report = @()

Foreach ($Computer in $Computers)
{

$Row = "" | Select Computer,WMIStatus
$Row.Computer = $Computer

        Try 
        {
        $WMI = Get-WmiObject -Class win32_ComputerSystem -ComputerName $Computer -ErrorAction Stop
        $Row.WMIStatus = $true
        }

        Catch 
        {
        $Row.WMIStatus = $false
        }

    $Report += $Row
}

Return $Report
}

Test-WMIStatus -Computers $computers