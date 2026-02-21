Get-Content $args[0] | Select-String -Pattern "(?<=Size:\ )\d+" | Foreach-Object { [double]$total+=[double]$_.Matches[0].Value }
$result = [math]::Round($total/1GB,2)
Write-Host $result "gigabytes used by duplicate files."