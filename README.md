# 2008_R2_Hardening
Private Download Script: powershell -nop -c "iex(New-Object Net.WebClient).DownloadString('https://bit.ly/2QnDanB')" 

#Public Main Script: 
Import-Module BitsTransfer 

Start-BitsTransfer -Source "https://raw.github.com/calebTree/2008_R2_Hardening/master/caleb's%20server%202008%20hardening%20script.ps1" -Destination "$env:userprofile\desktop\script.ps1" 
