Import-Module BitsTransfer
#$url = "https://raw.githubusercontent.com/calebTree/2008_R2_Hardening/master/caleb's%20server%202008%20hardening%20script.ps1?token=***REMOVED***"
#$url = "https://bit.ly/39EmNKI"
#$url = "https://bit.ly/36pOxB0"
$url = "https://bit.ly/2Qnjznf"
$output = "$env:userprofile\desktop\W08R2Harden.ps1"
Start-BitsTransfer -Source $url -Destination $output
. $env:userprofile\desktop\W08R2Harden.ps1
