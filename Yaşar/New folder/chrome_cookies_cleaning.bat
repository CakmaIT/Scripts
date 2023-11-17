@echo off
color 6
echo ===========================================
echo Chrome Onbellek ve Cerezler Temizlenecektir.
echo ===========================================
echo Tarayici Gecmisi ve Sifreleriniz Silinmeceyektir.
set /p ask=Onayliyor Musunuz? Evet (E) / Hayir (H): 
if %ask%==H exit
if %ask%==E set ChromeDir=C:\Users\%USERNAME%\AppData\Local\Google\Chrome\User Data\Default\Cache
del /q /s /f "C:\Users\%USERNAME%\AppData\Local\Google\Chrome\User Data\Default\Cache"
rd /s /q "C:\Users\%USERNAME%\AppData\Local\Google\Chrome\User Data\Default\Cache"
del /q /s /f "C:\Users\%USERNAME%\AppData\Local\Google\Chrome\User Data\Default\Network"
rd /s /q "C:\Users\%USERNAME%\AppData\Local\Google\Chrome\User Data\Default\Network"