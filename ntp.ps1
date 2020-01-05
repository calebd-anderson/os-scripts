function configNTP{
$host.UI.RawUI.foregroundcolor = "cyan"
Write-Host "Configuring NTP"
#$computer = hostname
#w32tm /config /computer:$computer /update
$host.UI.RawUI.foregroundcolor = "white"
ipconfig
$host.UI.RawUI.foregroundcolor = "magenta"
$local_ip = Read-Host "`nEnter the local ip address? "
$host.UI.RawUI.foregroundcolor = "white"
w32tm /config /update /manualpeerlist:"$local_ip" /syncfromflags:MANUAL
w32tm /query /status | Out-File $env:USERPROFILE\desktop\Script_Output\NTP_status.txt
$host.UI.RawUI.foregroundcolor = "cyan"
Write-Host "`"$env:USERPROFILE\desktop\Script_Output\NTP_status.txt`" has NTP status"
reg query HKLM\System\CurrentControlSet\Services\W32Time\Parameters | Out-File -Append $env:USERPROFILE\desktop\Script_Output\NTP_status.txt
#cmd /c "net stop w32time && net start w32time"
$host.UI.RawUI.foregroundcolor = "white"
}