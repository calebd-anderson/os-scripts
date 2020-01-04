Import-Module BitsTransfer
#$url = "https://bit.ly/36mYlvB"
$url = "https://bit.ly/2sNP2Ga"
$output = "$env:userprofile\desktop\W08R2Harden.ps1"
Start-BitsTransfer -Source $url -Destination $output
. $env:userprofile\desktop\W08R2Harden.ps1
