Write-Host -ForegroundColor Magenta "Please enter the URI: " -NoNewline
$URI = Read-Host
Write-Host -ForegroundColor Magenta "Please enter the filename: " -NoNewline
$Filename = Read-Host
$Response = Invoke-WebRequest -Uri $URI
$Stream = [System.IO.StreamWriter]::new($Filename, $false, $Response.Encoding)
try {
    $Stream.Write($Response.Content)
}
finally {
    $Stream.Dispose()
}