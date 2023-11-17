New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft Services'

New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft Services\AdmPwd'

Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft Services\AdmPwd' -name "PasswordComplexity" -value 00000004

Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft Services\AdmPwd' -name "PasswordLength" -value 16

Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft Services\AdmPwd' -name "PasswordAgeDays" -value 00000001

Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft Services\AdmPwd' -name "AdmPwdEnabled" -value 00000001