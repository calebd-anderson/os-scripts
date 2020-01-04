# 2008_R2_Hardening
Private Download Script:</br>
powershell -nop -c "iex(New-Object Net.WebClient).DownloadString('https://bit.ly/2QnDanB')"

Private Main Script:</br>
Start-BitsTransfer -Source "https://bit.ly/36mYlvB" -Destination "$env:userprofile\desktop\script.ps1"

Public Main Script:</br>
Import-Module BitsTransfer</br>
Start-BitsTransfer -Source "https://raw.github.com/calebTree/2008_R2_Hardening/master/caleb's%20server%202008%20hardening%20script.ps1" -Destination "$env:userprofile\desktop\script.ps1"
