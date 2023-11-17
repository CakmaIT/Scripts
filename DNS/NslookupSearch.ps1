$Computers = @(
'GMASGDC01.acibadem.com.tr'
'GMASGDC02.acibadem.com.tr'
'GMASGDC03.acibadem.com.tr'
'LABMEDDC01.labmed.saglik.local'
'MOBDC01.mobil.saglik.local'
'GMLABMEDDC.labmed.saglik.local'
'MOBDC02.mobil.saglik.local'
'KDKDC02.acibadem.com.tr'
'KCLDC02.acibadem.com.tr'
'KDKDC01.acibadem.com.tr'
'KCLDC01.acibadem.com.tr'
'KOZDC01.acibadem.com.tr'
'MASDC01.acibadem.com.tr'
'MASDC02.acibadem.com.tr'
'KOZDC02.acibadem.com.tr'
'TKSDC02.acibadem.com.tr'
'TKSDC01.acibadem.com.tr'
'ADADC01.acibadem.com.tr'
'ADADC02.acibadem.com.tr'
'ANKDC02.acibadem.com.tr'
'ANKDC01.acibadem.com.tr'
'ATKDC02.acibadem.com.tr'
'BKRDC01.acibadem.com.tr'
'BKRDC02.acibadem.com.tr'
'BODDC02.acibadem.com.tr'
'BRSDC01.acibadem.com.tr'
'BRSDC02.acibadem.com.tr'
'KAYDC01.acibadem.com.tr'
'KAYDC02.acibadem.com.tr'
'FULDC01.acibadem.com.tr'
'FULDC02.acibadem.com.tr'
'ESKDC1.acibadem.com.tr'
'ESKDC02.acibadem.com.tr'
'SAMCMDC01.acibadem.com.tr'
'SAMCMDC02.acibadem.com.tr'
'APLUSDC01.acibadem.com.tr'
'APLUSDC02.acibadem.com.tr'
'KUCDC01.acibadem.com.tr'
'ALTDC01.acibadem.com.tr'
'ALTDC02.acibadem.com.tr'
'BODDC01.acibadem.com.tr'
'ATKDC01.acibadem.com.tr'
'GMMOBDC01.mobil.saglik.local'
'KUCDC02.acibadem.com.tr'
'INTDC01.acibadem.com.tr'
'INTDC02.acibadem.com.tr'
'DRCDC01.acibadem.com.tr'
'DRCDC02.acibadem.com.tr'
    )
    
    foreach ($Comp in $Computersa){
   Write-Host $Comp
    $Comp >>112b.txt
Resolve-DnsName teamviewer.com -Server $Comp | FT >>112b.txt
Resolve-DnsName v10.events.data.microsoft.com -Server $Comp | FT >>112b.txt
Resolve-DnsName settings-win.data.microsoft.com -Server $Comp | FT >>112b.txt
Resolve-DnsName watson.telemetry.microsoft.com -Server $Comp | FT >>112b.txt
Resolve-DnsName displaycatalog.mp.microsoft.com -Server $Comp | FT >>112b.txt
Resolve-DnsName ping3.teamviewer.com -Server $Comp | FT >>112b.txt

}

foreach ($Comp in $Computers){
   Write-Host $Comp
    $Comp >>112b.txt
Resolve-DnsName settings-win.data.microsoft.com -Server $Comp | FT IP4Address
}
