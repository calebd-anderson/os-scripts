Write-Host "ifconfig.me/ip:" (Invoke-RestMethod -Uri "ifconfig.me/ip")
Write-Host "ipinfo.io:"
$id = 0
while($ipAddr -ne 'q') {
	$ipAddr = Read-Host -Prompt "Enter an ip address ('q' to quit, 'myip' to return public ip info)"
	if($ipAddr -ne 'q') {
		$id++
		Write-Host "-------------------$id--------------------"
		if ($ipAddr -eq 'myip') {
			((Invoke-RestMethod -Uri "https://ipinfo.io/what-is-my-ip") | Out-String).Trim()
		} else {
			((Invoke-RestMethod -Uri "http://ipinfo.io/$ipAddr") | Out-String).Trim()
		}
		Write-Host "-------------------$("-" * $id.tostring().length)--------------------"
	}
}
