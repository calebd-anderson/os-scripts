do{
#introduce
$exten_type = Read-Host "To reset a file format's program association back to empty; start by typing the entire affected file's suffix (.cfg),`nthen press Enter"
Write-Host "The system will create a log on your desktop with the registry path of keys that will conditionally be affected named`n`"extension_reset_log.txt`". Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

#create, and open log
$open_log = Read-Host  "Do you want to automatically open the log to have the path of the affected registry keys readily in front of`nyou? (y, n)"
New-Item -ItemType file "C:\Users\$environment.specialfolder\desktop\extension_reset_log.txt" -ErrorAction SilentlyContinue
$key1 = Get-Item -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$exten_type -ErrorAction SilentlyContinue
$key2 = Get-Item -Path HKCU:\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\$exten_type -ErrorAction SilentlyContinue
$key3 = Get-Item -Path HKCU:\Software\Classes\$exten_type -ErrorAction SilentlyContinue
$key4 = Get-Item -Path HKLM:\SOFTWARE\Classes\$exten_type -ErrorAction SilentlyContinue
Add-Content C:\Users\$env:username\Desktop\extension_reset_log.txt "-Registry paths to keys that will be deleted after carrying out the operation on the `"$exten_type`" extension:"
Add-Content C:\Users\$env:username\Desktop\extension_reset_log.txt $key1 
Add-Content C:\Users\$env:username\Desktop\extension_reset_log.txt $key2 
Add-Content C:\Users\$env:username\Desktop\extension_reset_log.txt $key3 
Add-Content C:\Users\$env:username\Desktop\extension_reset_log.txt $key4 
if ($open_log -eq 'y'){
Invoke-Item C:\Users\$desktop\Desktop\extension_reset_log.txt
}

#query open regedit
$reg_open = Read-Host "`nDo you want to open the registry editor to manually backup each affected key in the log? (y, n)"
if ($reg_open -eq 'y'){
regedit.exe
}

#init main
Write-Host "`nPress any key to initiate the reset. You will be prompted to confirm of each key deletion ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Remove-Item -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$exten_type -Recurse -ErrorAction SilentlyContinue -Confirm
Remove-Item -Path HKCU:\Software\Microsoft\Windows\Roaming\OpenWith\FileExts\$exten_type -Recurse -ErrorAction SilentlyContinue -Confirm
Remove-Item -Path HKCU:\Software\Classes\$exten_type -Recurse -ErrorAction SilentlyContinue -Confirm
Remove-Item -Path HKLM:\SOFTWARE\Classes\$exten_type -Recurse <#-ErrorAction SilentlyContinue#> -Confirm

#query run again, and restart
$again = Read-Host -Prompt "Would you like to carry out the operation again on another extension? (y, n)"
if ($again -eq 'n'){
$restart_now = Read-Host -Prompt "Restart your computer now to complete the extension association reset? (y, n)"
if ($restart_now -eq 'n') {
Write-Host "`nThe operation finished, press any key to exit ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
if ($restart_now -eq 'y'){
Write-Host "`nThe operation finished, save your work, then press any key to restart your computer ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Restart-Computer
}
}
if ($again -eq 'y'){
cls
}

}
while ($again -ne 'n')