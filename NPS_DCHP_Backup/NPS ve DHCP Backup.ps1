$servis = get-service winrm

if ($servis.Status -eq 'Stopped'){
           Start-Service $servis
           Enable-PSRemoting
      }
      elseif ($servis.status -eq 'Running'){
           Write-Host "Windows Remote Management (WS-Management) servisi çalşıyor"
      }


      $komut = {
      
     New-Item -Path 'C:\Users\admabravaya\Desktop' -Name "deneme.txt" -ItemType "file" -Value "bu bir deneme yazısıdır."
      
      }

      $s = New-PSSession -ComputerName (Get-Content C:\Users\yasar.abravaya\Desktop\Scriptler\NPS_DCHP_Backup\CompList.txt)
      Invoke-Command -Session $s -ScriptBlock $komut
      

     



