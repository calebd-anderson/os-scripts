function hotFixCheck{
    makeOutDir
    $host.UI.RawUI.foregroundcolor = "cyan"
    Write-Host "`nComparing systeminfo HotFix list against known KB data"
    
    #manual page
    #$manual_KBs = @{KB4012213 = "http://support.microsoft.com/kb/4012213"}
    #Windows Server 2008 R2 32-bit (6.1)
    #$R2_32_bit_KBs = @{}

    #Windows Server 2008 R2 64-bit (6.1)
    $R2_64_bit_KBs = @{    
        KB975517 = "https://bit.ly/2rArzrt"
        KB2393802 = "http://bit.ly/2kodsxw"
        KB3006226 = "http://bit.ly/2jLUmzu"
        KB3000869 = "http://bit.ly/2kxFGZk"
        KB3000061 = "http://bit.ly/2k4FRHV"
        KB2503658 = "http://bit.ly/2l15YDR" # *actually installed
        KB2489256 = "http://bit.ly/2kqhe9I" # *actually installed
        KB2984972 = "http://bit.ly/2l6dBFP"
        KB3126593 = "http://bit.ly/2jN0x6n"
        KB2982378 = "https://bit.ly/39o5fTa"
        KB3042553 = "https://bit.ly/2ZxS11p"
        KB2562485 = "https://bit.ly/39oDXMc"
        KB2769369 = "https://bit.ly/2FeeQ17" # *actually installed
        KB3100465 = "https://bit.ly/2F2usVm"
        KB3004375 = "http://download.windowsupdate.com/c/msdownload/update/software/secu/2015/01/windows6.1-kb3004375-v3-x64_c4f55f4d06ce51e923bd0e269af11126c5e7196a.msu"
        KB3000483 = "http://download.windowsupdate.com/c/msdownload/update/software/secu/2015/01/windows6.1-kb3000483-x64_67cdef488e5dc049ecae5c2fd041092fd959b187.msu"
        KB3011780 = "http://download.windowsupdate.com/c/msdownload/update/software/secu/2014/11/windows6.1-kb3011780-x64_fdd28f07643e9f123cf935bc9be12f75ac0b4d80.msu"
        }

    #Windows Server 2008 64-bit (6.0)
    $64_bit_KBs = @{
        KB2588516 = "https://bit.ly/37oIwEN"
        KB2705219 = "https://bit.ly/2ZxEGGm"
        KB2849470 = "https://bit.ly/2MG0fQ6"
        KB3011780 = "http://download.windowsupdate.com/d/msdownload/update/software/secu/2014/10/windows6.0-kb3011780-x64_c6135e518ffd1b053f1244a3f17d4c352c569c5b.msu"
        KB4012598 = "http://download.windowsupdate.com/d/msdownload/update/software/secu/2017/02/windows6.0-kb4012598-x64_6a186ba2b2b98b2144b50f88baf33a5fa53b5d76.msu"
        }  

    #Windows Server 2008 32-bit (6.0)
    $32_bit_KBs = @{
        KB4012598 = "https://bit.ly/2Q3Qjlk"
        KB3011780 = "https://bit.ly/2ZzTRPF"
        }

    #compare systeminfo to KB hashtable master list
    $system_info = systeminfo
    
    if(($system_info | Out-String).Contains("x64-based PC")){
        if(($system_info | Out-String).Contains("R2")){
            $auto_download_KBs = $R2_64_bit_KBs.Clone()
        }
        else{
            $auto_download_KBs = $64_bit_KBs.Clone()
        }
    }
    else{
        $auto_download_KBs = $32_bit_KBs.Clone()
    }

    #removes installed from $auto_download_KBs and removes junk from systeminfo KB name
    $kb_list = Foreach ($KB in $auto_download_KBs.GetEnumerator()){$KB.Name}
    $installed = $system_info | findstr "$kb_list"
    if ($null -ne $installed){
        $installed = $installed.Trim() -replace '\[[0-9]\w\]\:\s+',''
        $installed | ForEach-Object {Set-Variable -Name c -Value $_ -PassThru} | ForEach-Object {$auto_download_KBs.Remove($c)}
    }

    #export applicable list and provide output to console
    $auto_download_KBs | Export-Clixml -Path $env:userprofile\appdata\local\might_install.xml
    $host.UI.RawUI.foregroundcolor = "cyan"
    Write-Host $auto_download_KBs.count "KB(s) in the master list did not appeare to be installed and will be downloaded"    
    Write-Host "`"$env:userprofile\appdata\local\might_install.xml`" has list of HotFixes and thier URLs that did not match systeminfo HotFix list"
    $host.UI.RawUI.foregroundcolor = "darkgray"
    $auto_download_KBs

    #download all
    $host.UI.RawUI.foregroundcolor = "cyan"
    Write-Host "Importing BitsTransfer module"
    Import-Module BitsTransfer
    foreach ($key in $auto_download_KBs.GetEnumerator()) {
        "Downloading $($key.Name) from $($key.Value)"
        $KB = $($key.Name)
        $url = $auto_download_KBs.$KB
        $output = "$env:userprofile\desktop\Script_Output\$KB.msu"
        Start-BitsTransfer -Source $url -Destination $output
    }
    $host.UI.RawUI.foregroundcolor = "white"
}