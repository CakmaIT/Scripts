#Modul �berschrift erzeugen:
# Die PNG Datei (Logo vor �berschrift) sollte eine gr��e von 31x31px nicht �berschreiten, die PNG-Datei muss wie das Modul benannt werden
# Modulname: 3rdPartydemo.ps1 (\Modules\3rdParty\)
# PNG Datei Name: 3rdPartyDemo.png (\Images\3rdParty\)
# Farbcode f�r Hintergrund der PNG Datei: Rot=0, Gr�n=114, Blau=198

$3rdPartyDemo = Generate-ReportHeader "3rdPartyDemo.png" "Mein eigenes Modul"

#Neue Tabelle erzeugen:

$cells=@("Spalte 1","Spalte 2","Spalte 3","usw","usw")
$3rdPartyDemo += Generate-HTMLTable "�berschrift der Tabelle" $cells

#Neue Zeile mit Daten der Tabelle hinzuf�gen:

$cells=@("Zeile1 Spalte 1","Zeile 1 Spalte 2"," Zeile 1 Spalte 3","usw","usw")
$3rdPartyDemo += New-HTMLTableLine $cells

#Noch eine Zeile hinzuf�gen

$cells=@("Zeile2 Spalte 1","Zeile 2 Spalte 2"," Zeile 2 Spalte 3","usw","usw")
$3rdPartyDemo += New-HTMLTableLine $cells

#Tabelle abschlie�en

$3rdPartyDemo += End-HTMLTable

#Neues Balkendiagram erzeugen

$values = @{"Balken1"=10;"Balken2"=20;"Balken3"=30}
new-cylinderchart 500 400 Balken Name "Anzahl" $outlookcltvalues "$tmpdir\diagramname.png"

#Neues Kuchendiagram erzeugen

$values = @{Frei=50; Belegt=50}
new-piechart "150" "150" "Name" $values "$tmpdir\kuchendiagramname.png"

#Grafik in Report einf�gen

$3rdPartyDemo += Include-HTMLInlinePictures "$tmpdir\diagramname.png"
$3rdPartyDemo += Include-HTMLInlinePictures "$tmpdir\kuchendiagramname.png"

#Report erzeugen und Modul beenden
# 3rdPartyDemo.html f�r Fehleranalyse
# Report.html ist der komplette Report der verschickt wird

$3rdPartyDemo | set-content "$tmpdir\3rdPartyDemo.html"
$3rdPartyDemo | add-content "$tmpdir\report.html"