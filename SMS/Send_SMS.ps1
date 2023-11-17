$telefon = "+9005374541364"
$mesaj = "Username : okale - Sifre: p6GCpmsbhQjmF6xD"

Invoke-WebRequest -Uri "http://services.yildirim.local/SMS/send?to=$telefon&text=$mesaj" 
