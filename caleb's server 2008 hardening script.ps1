<# --------- Self-elevate the script if required ---------
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        Exit
    }
}
#>

# --------- create output directory on desktop ---------
function makeOutDir{
if(-not (Test-Path -LiteralPath $env:USERPROFILE\desktop\Script_Output)){
$host.UI.RawUI.foregroundcolor = "green"
Write-Host "Creating the output directory `"Script_Output`" on the desktop`n"
New-Item -Path "$env:USERPROFILE\desktop\Script_Output" -ItemType Directory | Out-Null
}
else{
$host.UI.RawUI.foregroundcolor = "darkgray"
Write-Host "`n`"Script_Output`" already exists"
}
$host.UI.RawUI.foregroundcolor = "white"
}

# --------- downloads relevant tools ---------
function downloadTools{
    makeOutDir
    $host.UI.RawUI.foregroundcolor = "green"
    Write-Host "`nDownloading relevant tools"
    $downloads = @{
    Malwarebytes_exe = "https://downloads.malwarebytes.com/file/mb-windows"
    firefox_installer_exe = "https://mzl.la/35e3KDv"
    Sysinternals_suit_zip = "https://download.sysinternals.com/files/SysinternalsSuite.zip"
    }
    $host.UI.RawUI.foregroundcolor = "cyan"
       Write-Host "Importing BitsTransfer module"
       Import-Module BitsTransfer
       foreach ($key in $downloads.GetEnumerator()) {
           "Downloading $($key.Name) from $($key.Value)"
           $filename = $($key.Name)
           $url = $downloads.$filename
           $filename = $filename -replace '_(?!.*_)', '.'
           $output = "$env:userprofile\desktop\Script_Output\$filename"
           Start-BitsTransfer -Source $url -Destination $output
       }
    Write-Host "All the relevant tools have been downloaded"
    $host.UI.RawUI.foregroundcolor = "white"
    cmd /c pause
}

#region Firewall
# --------- turn firewall on ---------
function turnOnFirewall{
    $host.UI.RawUI.foregroundcolor = "green"
    Write-Host "`nTurning On Firewall"
    $host.UI.RawUI.foregroundcolor = "cyan"
    netsh advfirewall set allprofiles state on
    $host.UI.RawUI.foregroundcolor = "white"
    cmd /c pause
}

# --------- firewall rules ---------
function firewallRules{
    $host.UI.RawUI.foregroundcolor = "green"
    Write-Host "`nCreating firewall rules:"
    $host.UI.RawUI.foregroundcolor = "cyan"
    Write-Host "Block RDP In"
    netsh advfirewall firewall add rule name="Block RDP In" protocol=TCP dir=in localport=3389 action=block
    Write-Host "Block VNC In"
    netsh advfirewall firewall add rule name="Block VNC In" protocol=TCP dir=in localport=5900 action=block
    Write-Host "Block VNC Java In"
    netsh advfirewall firewall add rule name="Block VNC In" protocol=TCP dir=in localport=5800 action=block
    Write-Host "Block FTP In"
    netsh advfirewall firewall add rule name="Block VNC In" protocol=TCP dir=in localport=20 action=block
    $host.UI.RawUI.foregroundcolor = "white"
    cmd /c pause
}

# --------- firewall status ---------
function firewallStatus{
    $host.UI.RawUI.foregroundcolor = "green"
    Write-Host "`nGenerating firewall status"
    $host.UI.RawUI.foregroundcolor = "cyan"
    netsh firewall show config | Out-File $env:USERPROFILE\desktop\Script_Output\firewall_status.txt
    Write-Host "`"$env:USERPROFILE\desktop\Script_Output\firewall_status.txt`" has fireawll status"
    $host.UI.RawUI.foregroundcolor = "white"
    cmd /c pause
}
#endregion Firewall

#region Disable Services
# --------- Disable Teredo ---------
function disableTeredo{
$host.UI.RawUI.foregroundcolor = "green"
Write-Host "`nDisabling Teredo"
$host.UI.RawUI.foregroundcolor = "cyan"
Start-Process cmd /k, 'echo > Desktop\Script_Output\disable_teredo.vbs set shell = CreateObject("WScript.Shell"):shell.SendKeys "netsh{ENTER}interface{ENTER}teredo{ENTER}set state disabled{ENTER}exit{ENTER}exit{ENTER}" & %userprofile%\desktop\Script_Output\disable_teredo.vbs'
Write-Host "`Teredo disabled"
$host.UI.RawUI.foregroundcolor = "white"
cmd /c pause
}
# --------- disable administrative shares via registry ---------
function disableAdminShares{
    $host.UI.RawUI.foregroundcolor = "green"
    Write-Host "`nDisabling administrative shares via registry"
    $host.UI.RawUI.foregroundcolor = "cyan"
    REG ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters\ /v AutoShareServer /t REG_DWORD /d 0
    Write-Host "Stopping and starting server"
    #cmd /c "net stop server && net start server"
    #cmd /c "net start Netlogon && net start dfs"
    Stop-Service server -Force
    Start-Service dfs
    Start-Service netlogon
    Start-Service server
    $host.UI.RawUI.foregroundcolor = "white"
    cmd /c pause
} 
# --------- disable cached credentials via registry ---------
function disableCacheCreds{
$host.UI.RawUI.foregroundcolor = "green"
Write-Host "`nDisabling cached credentials via registry"
$host.UI.RawUI.foregroundcolor = "cyan"
REG ADD HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\WDigest /v UseLogonCredential /t REG_DWORD /d 0
$host.UI.RawUI.foregroundcolor = "white"
cmd /c pause
}
# --------- disable SMB1 via registry ---------
function disableSMB1{
    $host.UI.RawUI.foregroundcolor = "green"
    Write-Host "`nDisabling SMB1 via registry"
    $host.UI.RawUI.foregroundcolor = "cyan"
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" SMB1 -Type DWORD -Value 0
    Write-Host "SMB1 disabled"
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" SMB2 -Type DWORD -Value 1
    Write-Host "SMB2 enabled"
    $host.UI.RawUI.foregroundcolor = "white"
    cmd /c pause
}
# --------- disable RDP ---------
function disableRDP{
    $host.UI.RawUI.foregroundcolor = "green"
    Write-Host "`nDisabling RDP"
    $host.UI.RawUI.foregroundcolor = "cyan"
    Write-Host "Opening System Properties dialog box. Remove all Remote Desktop Users"
    sysdm.cpl
    Write-Host "Stopping RDP Service"
    #net stop "remote desktop services"
    Stop-Service "Remote Desktop Services"
    Write-Host "Removing RDP via registry"
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" –Value 1 –Force
    Write-Host "RDP disabled"
    $host.UI.RawUI.foregroundcolor = "white"
    cmd /c pause
}
#endregion Disable Services

#region Passwords
# --------- Main password changer ---------
#disable reverse encryption policy then change all DC user passwords except admin and binddn 
function changeP{
    ##Make sure $OU is accurate
    makeOutDir
    $host.UI.RawUI.foregroundcolor = "green"
    Write-Host "Changing all DC user passwords"
    $host.UI.RawUI.foregroundcolor = "cyan"
    Write-Host "Extracting the domain name"
    $domain = wmic computersystem get domain | Select-Object -skip 1
    $domain = "$domain".Trim()
    $domaina = "$domain".Trim() -replace '.\b\w+', ''
    $domainb = "$domain".trim() -replace '^\w+\.', ''
    # Author Kyle Henson
    Write-Host "`nImporting AD module"
    Import-Module ActiveDirectory
    Write-Host "Disabling reversible encryption"
    Set-ADDefaultDomainPasswordPolicy -Identity $domain -ReversibleEncryptionEnabled $false
    #Write-Host "Forcing GP update"
    #gpupdate
    Write-Host "Changing All Passwords except admin and binddn"
    $list = "0123456789!@#$".ToCharArray()
    $OU = "CN=Users, DC=$domaina, DC=$domainb"
    $users = Get-ADUser -Filter * -SearchScope Subtree -SearchBase $OU
    $admin = "CN=Administrator,CN=Users,DC=$domaina,DC=$domainb"
    #$binddn =  "CN=binddn,CN=Users,DC=$domaina,DC=$domainb"
    $host.UI.RawUI.foregroundcolor = "darkgray"
    #to-do: fix when auto pass not meet complex required
    New-Variable -Name hashTable -Visibility Public -Value @{}
    foreach ($user in $users) 
    { 
        if ($user -match $admin){
        Write-Host "Skipping Administrator"
        }
        elseif ($user -match 'binddn'){
        Write-Host "Skipping binddn"
        }
        else{
        $securePassword = ConvertTo-SecureString (-join ($list + (65..90) + (97..122) | Get-Random -Count 12 | ForEach-Object {[char]$_})) -AsPlainText -Force
        Write-Host "Changing the password of $user"
        Set-ADAccountPassword -Identity $user -Reset -NewPassword $securePassword
        $user = "$user".Trim() -replace '[CN=]{3}|[\,].*',''
        $encrypted = ConvertFrom-SecureString -SecureString $securePassword
        Out-File $env:userprofile\desktop\Script_Output\user_passwds_list.txt -Append -InputObject $user, $encrypted,""
        Write-Host "Adding $user to the hash table"
        $hashTable.Add($user,$encrypted)
        }
    }
    $host.UI.RawUI.foregroundcolor = "cyan"
    Write-Host "`"$env:USERPROFILE\desktop\Script_Output\user_passwds_list.txt`" has list of users and passwords"
    $hashTable | Export-Clixml -Path $env:userprofile\appdata\local\securePasswords.xml
    Write-Host "`"%localappdata%\securePasswords.xml`" has AD users .xml hashtable"
    $host.UI.RawUI.foregroundcolor = "white"
    cmd /c pause
}
    
# --------- set the admin password ---------
function changePAdmin{
    makeOutDir
    $host.UI.RawUI.foregroundcolor = "green"
    Write-Host "`nChanges Admin password"
    $host.UI.RawUI.foregroundcolor = "cyan"
    Write-Host "Importing ActiveDirectory module"
    Import-Module ActiveDirectory
    Write-Host "Extracting the domain name"
    $domain = wmic computersystem get domain | Select-Object -skip 1
    $domain = "$domain".Trim()
    $domaina = "$domain".Trim() -replace '.\b\w+', ''
    $domainb = "$domain".trim() -replace '^\w+\.', ''
    Write-Host "Changing the admin password"
    $admin = "CN=Administrator,CN=Users,DC=$domaina,DC=$domainb"
    $host.UI.RawUI.foregroundcolor = "magenta"
    $securePassword = Read-Host "`nEnter a new admin password" -AsSecureString
    Set-ADAccountPassword -Identity $admin -Reset -NewPassword $securePassword
    $host.UI.RawUI.foregroundcolor = "cyan"
    Write-Host "Encrypting and exporting"
    $encrypted = ConvertFrom-SecureString -SecureString $securePassword
    $admin = "$admin".Trim() -replace '[CN=]{3}|[\,].*',''
    Out-File -FilePath "$env:userprofile\desktop\Script_Output\admin_binddn_passwds.txt" -Append -InputObject $admin, $encrypted, ""
    if(Test-Path -LiteralPath $env:userprofile\appdata\local\securePasswords.xml){
        $hashtable = Import-Clixml $env:userprofile\appdata\local\securePasswords.xml
    }else{$hashtable = @{}}
    $hashTable[$admin] = $encrypted
    $hashTable | Export-Clixml -Path $env:userprofile\appdata\local\securePasswords.xml
    $host.UI.RawUI.foregroundcolor = "cyan"
    Write-Host "admin user password has been changed"
    $host.UI.RawUI.foregroundcolor = "white"
    cmd /c pause
}
    
# --------- set the binddn password ---------
function changePBinddn{
    makeOutDir
    $host.UI.RawUI.foregroundcolor = "green"
    Write-Host "`nChanges binddn password"
    $host.UI.RawUI.foregroundcolor = "cyan"
    Write-Host "Importing ActiveDirectory module"
    Import-Module ActiveDirectory
    Write-Host "Extracting the domain name"
    $domain = wmic computersystem get domain | Select-Object -skip 1
    $domain = "$domain".Trim()
    $domaina = "$domain".Trim() -replace '.\b\w+', ''
    $domainb = "$domain".trim() -replace '^\w+\.', ''
    Write-Host "Changing binddn password"
    $binddn = "CN=binddn,CN=Users,DC=$domaina,DC=$domainb"
    $host.UI.RawUI.foregroundcolor = "magenta"
    $securePassword = Read-Host "`nEnter a new binddn password" -AsSecureString
    Set-ADAccountPassword -Identity $binddn -Reset -NewPassword $securePassword
    $host.UI.RawUI.foregroundcolor = "cyan"
    Write-Host "Encrypting and exporting"
    $encrypted = ConvertFrom-SecureString -SecureString $securePassword
    $binddn = "$binddn".Trim() -replace '[CN=]{3}|[\,].*',''
    Out-File -FilePath "$env:userprofile\desktop\Script_Output\admin_binddn_passwds.txt" -Append -InputObject $binddn, $encrypted, ""
    Write-Host "desktop\Script_Output\admin_binddn_passwds.txt has changes log"
    if(Test-Path -LiteralPath $env:userprofile\appdata\local\securePasswords.xml){
        $hashtable = Import-Clixml $env:userprofile\appdata\local\securePasswords.xml
    }else{$hashtable = @{}}
    $hashTable[$binddn] = $encrypted
    $hashTable | Export-Clixml -Path $env:userprofile\appdata\local\securePasswords.xml
    $host.UI.RawUI.foregroundcolor = "cyan"
    Write-Host "binddn user password has been changed"
    $host.UI.RawUI.foregroundcolor = "white"
    cmd /c pause
}
    
# --------- enable LockoutDuration 00:40:00, LockoutObservationWindow 00:20:00, ComplexityEnabled $True, MaxPasswordAge 10.00:00:00, MinPasswordLength 12 ---------
function setPassPol{
    $host.UI.RawUI.foregroundcolor = "green"
    Write-Host "`nEnabling LockoutDuration 00:40:00, LockoutObservationWindow 00:20:00, ComplexityEnabled $True, MaxPasswordAge 10.00:00:00, MinPasswordLength 12"
    $host.UI.RawUI.foregroundcolor = "cyan"
    Write-Host "Importing ActiveDirectory module"
    Import-Module ActiveDirectory
    Write-Host "Extracting domain name"
    $domain = wmic computersystem get domain | Select-Object -skip 1
    $domain = "$domain".Trim()
    Set-ADDefaultDomainPasswordPolicy -Identity $domain -LockoutDuration 00:40:00 -LockoutObservationWindow 00:20:00 -ComplexityEnabled $True -MaxPasswordAge 10.00:00:00 -MinPasswordLength 12
    Write-Host "Password policies enabled"
    $host.UI.RawUI.foregroundcolor = "white"
    cmd /c pause
}
#endregion Passwords

#region User Query
#--------- extract more info on pid ---------
function morePIDInfo{
    $host.UI.RawUI.foregroundcolor = "cyan"
    Write-Host "Displays more info on PID(s)"
    $host.UI.RawUI.foregroundcolor = "magenta"
    $aPID = Read-Host "`nEnter a PID to get its properties"
    Write-Host "Displaying properties of $aPID"
    $host.UI.RawUI.foregroundcolor = "darkgray"
    Get-WMIObject Win32_Process -Filter "processid = '$aPID'" | Select-Object *
    $host.UI.RawUI.foregroundcolor = "white"
    cmd /c pause
}
# --------- enter service name for more info ---------
function serviceInfo{
    $host.UI.RawUI.foregroundcolor = "green"
    Write-Host "Displays more info on service by name"
    $host.UI.RawUI.foregroundcolor = "magenta"
    $service = Read-Host "`nEnter a service name to get its properties"
    Write-Host "Displaying properties of $service"
    $host.UI.RawUI.foregroundcolor = "darkgray"
    cmd /c sc qdescription $service
    $host.UI.RawUI.foregroundcolor = "white"
    cmd /c pause
}
# --------- prompt for a KB to download ---------
function pickAKB{
    Import-Module BitsTransfer
    $applicable_KBs = Import-Clixml $env:userprofile\appdata\local\might_install.xml
    $host.UI.RawUI.foregroundcolor = "green"
    Write-Host "`nThere are" $applicable_KBs.count "that might install below. KB2489256, KB2503658, and KB2769369 installed on lab"
    $host.UI.RawUI.foregroundcolor = "darkgray"   
    $applicable_KBs   
    $host.UI.RawUI.foregroundcolor = "magenta"
    $KB = Read-Host "Enter the full KB you would like to install?"
    $url = $applicable_KBs.$KB
    $output = "$env:userprofile\desktop\Script_Output\$KB.msu"
    try{Start-BitsTransfer -Source $url -Destination $output}
    catch{$host.UI.RawUI.foregroundcolor = "cyan"; Write-Host $KB "Is not an available KB`n"; break; $host.UI.RawUI.foregroundcolor = "white"}
    $host.UI.RawUI.foregroundcolor = "cyan"
    Write-Host "$KB downloaded to `"Script_Output`""
    $host.UI.RawUI.foregroundcolor = "white"
    cmd /c pause
}
# --------- Configure NTP ---------
function configNTP{
    $host.UI.RawUI.foregroundcolor = "green"
    Write-Host "Configuring NTP"
    $host.UI.RawUI.foregroundcolor = "cyan"
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
    cmd /c pause
}
# --------- NTP Stripchart ---------
function NTPStripchart{
    $host.UI.RawUI.foregroundcolor = "green"
    Write-Host "NTP Stripchart"
    $host.UI.RawUI.foregroundcolor = "magenta"
    $target_ip = Read-Host 'What is the target ip address? '
    w32tm /stripchart /computer:$target_ip
    $host.UI.RawUI.foregroundcolor = "white"
    cmd /c pause
}
# --------- read a password ---------
function readPasswords{
    $host.UI.RawUI.foregroundcolor = "green"
    Write-Host "Retreives the plaintext AD password from the encrypted password DB file"
    $host.UI.RawUI.foregroundcolor = "magenta"
    $username = Read-Host "Enter a full username to retreive the password"
    $hashtable = Import-Clixml $env:userprofile\appdata\local\securePasswords.xml
    $PlainPassword = $hashtable."$username"
    $SecurePassword = ConvertTo-SecureString $PlainPassword
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
    $UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($BSTR)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
    $host.UI.RawUI.foregroundcolor = "darkgray"
    Write-Host "The $username password is: $UnsecurePassword`n"
    $host.UI.RawUI.foregroundcolor = "white"
    cmd /c pause
}
#endregion User Query

#region User Edits
# --------- Set admin sensitive, password required all, remove members from Schema Admins ---------
function uniqueUserPols{
    $host.UI.RawUI.foregroundcolor = "green"
    Write-Host "`nEnabling admin sensitive, password required for all, and removing all members from Schema Admins"
    $host.UI.RawUI.foregroundcolor = "cyan"
    Write-Host "Importing ActiveDirectory module"
    Import-Module ActiveDirectory
    Write-Host "`nUsers that don't require a password:"
    $host.UI.RawUI.foregroundcolor = "darkgray"
    Get-ADUser -Filter {PasswordNotRequired -eq $true}
    Set-ADUser -Identity "CN=Administrator,CN=Users,DC=team,DC=local" -AccountNotDelegated $true
    Get-ADUser -Filter {PasswordNotRequired -eq $true} | Set-ADUser -PasswordNotRequired $false
    $host.UI.RawUI.foregroundcolor = "cyan"
    Write-Host "All users now require a password even Guest :-)"
    Write-Host "Removing all members from 'Schema Admins' AD group"
    #Remove-ADGroupMember -Identity Schema Admins -Members Administrator -Confirm:$False
    try {
        $Groups = "Schema Admins"
        foreach ($Group in $Groups){Get-ADGroupMember -Identity $Group | Remove-ADPrincipalGroupMembership -MemberOf $Group -Confirm:$false}
        }
        catch [System.SystemException] {
            $host.UI.RawUI.foregroundcolor = "red"
            Write-Host "An error occurred:"
            Write-Host $_
            break
        }
    Write-Host "All members removed from Schema Admins group"
    $host.UI.RawUI.foregroundcolor = "white"
    cmd /c pause
    }
    # --------- disable guest account ---------
    function disableGuest{
        $host.UI.RawUI.foregroundcolor = "green"
        Write-Host "`nDisabling guest account"
        net user guest /active:no
        $host.UI.RawUI.foregroundcolor = "cyan"
        Write-Host "Guest account disabled"
        $host.UI.RawUI.foregroundcolor = "white"
        cmd /c pause
    }
#endregion User Edits

# --------- group policy tool ---------
function GPTool{
    $host.UI.RawUI.foregroundcolor = "green"
    Write-Host "Opening GP Tool"
    $host.UI.RawUI.foregroundcolor = "cyan"
    Write-Host "Click each drop box item and make the change displayed"
    #WPF AD GUI script
    Add-Type -assembly System.Windows.Forms
    $main_form = New-Object System.Windows.Forms.Form
    $main_form.Text ='Set GPO Tool'
    $main_form.Width = 600
    $main_form.Height = 100
    $main_form.AutoSize = $true
    $Label = New-Object System.Windows.Forms.Label
    $Label.Text = "GPO Object "
    $Label.Location  = New-Object System.Drawing.Point(0,10)
    $Label.AutoSize = $true
    $main_form.Controls.Add($Label)
    $ComboBox = New-Object System.Windows.Forms.ComboBox
    $ComboBox.Width = 300
    
    #hashtable Name:Value
    $GPO_EDITS = @{
    PS_Script_Execution = "Comp Config\Policies\Administrative Templates\Windows Components\Windows PowerShell\ -> `"Turn on script execution`"";
    Kerberos_Encryption = "Comp Config\Policies\Windows Settings\Security Settings\Local Policies\Security Options -> Network Security: Config encrypt types (...) Kerberos\ `"AES256`""; 
    LAN_MGR_Hash = "Comp Config\Policies\Windows Settings\Security Settings\Local Policies\Security Options -> Network Security: Do not store LAN MGR hash (...) pswd change\ `"ENABLE`"";
    LAN_MGR_Auth = "Comp Config\Policies\Windows Settings\Security Settings\Local Policies\Security Options -> Network Security: LAN MGR Auth LVL\ `"?Refuse All`"";
    Win32_Conficker = "Comp Config\Policies\Administrative Templates\Windows Components\Autoplay Policies -> Turn off Autoplay\ `"ENABLE`"";
    Startup_Scripts = "Comp Config\Windows Settings\Scripts (Startup/Shutdown)`nUser Config\Windows Settings\Scripts (Startup/Shutdown)";
    Audit_Policy = "Comp Config\Policies\Windows Settings\Security Settings\Local Policies\Security Settings\Advanced Audit Policy Configuration\Audit Policies\ -> `"MANY HERE ???`"";
    Passwd_Policy = "Windows Settings\Security Settings\Account Policies\Password Policy\ -> Store passwords using reversible encryption\ `"Disabled`", `"MANY HERE ???`"";
    Add_Comp_Pol = "Computer Configuration\Windows Settings\Security Settings\Local Policies\User Rights Assignment\ -> Add workstations to Domain\ `"0`"";
    Deny_User_Rights = "Comp Config\Policies\Windows Settings\Security Settings\Local Policies\User Rights Assignments\ -> `"MANY w/ Deny`"";
    Restricted_Groups = "Computer Configuration\Policies\Windows Settings\Security Settings\Restricted Groups -> Remove All";
    Harden_UNC = "Computer Configuration / Administrative Templates / Network / Network Provider -> Hardened UNC Paths"}
    
    Foreach ($GPO in $GPO_EDITS.GetEnumerator()){$ComboBox.Items.Add($($GPO.Name)) | Out-Null}
    $ComboBox.Location = New-Object System.Drawing.Point(70,10)
    $main_form.Controls.Add($ComboBox)
    $Label2 = New-Object System.Windows.Forms.Label
    $Label2.Text = "Location:"
    $Label2.Location  = New-Object System.Drawing.Point(0,40)
    $Label2.AutoSize = $true
    $main_form.Controls.Add($Label2)
    $Label3 = New-Object System.Windows.Forms.Label
    $Label3.Text = ""
    $Label3.Location = New-Object System.Drawing.Point(50,40)
    $Label3.AutoSize = $true
    $main_form.Controls.Add($Label3)
    $Button = New-Object System.Windows.Forms.Button
    $Button.Location = New-Object System.Drawing.Size(400,10)
    $Button.Size = New-Object System.Drawing.Size(120,23)
    $Button.Text = "Check"
    $main_form.Controls.Add($Button)
    $ComboBox.Add_SelectedIndexChanged({$Label3.Text = $GPO_EDITS[$ComboBox.selectedItem]})
    #$Button.Add_Click({$Label3.Text = $GPO_EDITS[$ComboBox.selectedItem]})
    $Button2 = New-Object System.Windows.Forms.Button
    $Button2.Location = New-Object System.Drawing.Size(530,10)
    $Button2.Size = New-Object System.Drawing.Size(120,23)
    $Button2.Text = "Open gpmc.msc"
    $main_form.Controls.Add($Button2)
    $Button2.Add_Click({gpmc.msc})
    $Button3 = New-Object System.Windows.Forms.Button
    $Button3.Location = New-Object System.Drawing.Size(660,10)
    $Button3.Size = New-Object System.Drawing.Size(120,23)
    $Button3.Text = "Open secpol.msc"
    $main_form.Controls.Add($Button3)
    $Button3.Add_Click({secpol.msc})
    $main_form.ShowDialog()
    Write-Host "Ending GP tool"
    $host.UI.RawUI.foregroundcolor = "white"
    cmd /c pause
}

# --------- sets script extensions to open notepad ---------
function setAssToTxt{
    $host.UI.RawUI.foregroundcolor = "green"
    Write-Host "`nAssociating script extensions to open with notepad"
    $host.UI.RawUI.foregroundcolor = "cyan"
    cmd /c assoc .bat=txtfile
    cmd /c assoc .js =txtfile
    cmd /c assoc .jse=txtfile
    cmd /c assoc .vbe=txtfile
    cmd /c assoc .vbs=txtfile
    cmd /c assoc .wsf=txtfile
    cmd /c assoc .wsh=txtfile
    $host.UI.RawUI.foregroundcolor = "white"
    cmd /c pause
}

#region Enumeration
# --------- format netstat -abno --------- 
function formatNetstat{
    makeOutDir
    $host.UI.RawUI.foregroundcolor = "green"
    Write-Host "`nRunning netstat -abno and formatting"
    $host.UI.RawUI.foregroundcolor = "cyan"
    $netstat = (netstat -abno | Select-Object -skip 2) -join "`n" -split "(?= [TU][CD]P\s+(?:\d+\.|\[\w*:\w*:))" |
    ForEach-Object {$_.trim() -replace "`n",' ' -replace '\s{2,}',',' -replace '\*:\*', '*:*,' -replace 'PID', 'PID,Ownership_Info'} | ConvertFrom-Csv
    #create ESTABLISHED and LISTENING netstat files list with only unique PIDs
    Write-Host "Creating ESTABLISHED netstat list file"
    $netstat_est = $netstat | Where-Object {$_.State -eq 'ESTABLISHED'} | Select-Object -Expand PID | Sort-Object | Get-Unique | ForEach-Object {Set-Variable -Name c -Value $_ -PassThru} |
    ForEach-Object {Get-WmiObject Win32_Process -Filter "ProcessID = '$c'" | Select-Object ProcessID,Name,Path}
    $netstat_est = ($netstat_est | Out-String).trim() -replace '(?m)^\s{30}', ''
    $netstat_est | Out-File $env:USERPROFILE\desktop\Script_Output\netstat_est.txt
    Write-Host "`"$env:USERPROFILE\desktop\Script_Output\netstat_est.txt`" has ESTABLISHED netstat"
    Write-Host "Creating LISTENING netstat list file"
    $netstat_lsn = $netstat | Where-Object {$_.State -eq 'LISTENING'} | Select-Object -Expand PID | Sort-Object | Get-Unique | ForEach-Object {Set-Variable -Name c -Value $_ -PassThru} |
    ForEach-Object {Get-WmiObject Win32_Process -Filter "ProcessID = '$c'" | Select-Object ProcessID,Name,Path}
    $netstat_lsn = ($netstat_lsn | Out-String).trim() -replace '(?m)^\s{30}', ''
    $netstat_lsn | Out-File $env:USERPROFILE\desktop\Script_Output\netstat_lsn.txt
    Write-Host "`"$env:USERPROFILE\desktop\Script_Output\netstat_lsn.txt`" has LISTENING netstat"
    $host.UI.RawUI.foregroundcolor = "white"
    cmd /c pause
}

# --------- create list of running services file on desktop ---------
function runningServices{
    makeOutDir
    $host.UI.RawUI.foregroundcolor = "green"
    Write-Host "`nCreating list of running services"
    $host.UI.RawUI.foregroundcolor = "cyan"
    Get-Service | Where-Object {$_.Status -eq "Running"} | Out-File $env:USERPROFILE\desktop\Script_Output\running_services.txt
    $host.UI.RawUI.foregroundcolor = "cyan"
    Write-Host "`"$env:USERPROFILE\desktop\Script_Output\running_services.txt`" has list of running services"
    $host.UI.RawUI.foregroundcolor = "white"
    cmd /c pause
}

# --------- enumerate HotFix updates ---------
function hotFixCheck{
    makeOutDir
    $host.UI.RawUI.foregroundcolor = "green"
    Write-Host "`nComparing systeminfo HotFix list against HotFix master-list"
    #manual page
    #$manual_KBs = @{KB4012213 = "http://support.microsoft.com/kb/4012213"}
    #Windows Server 2008 R2 32-bit (6.1)
    #$R2_32_bit_KBs = @{}
    
    #compare systeminfo to KB hashtable master list
    $host.UI.RawUI.foregroundcolor = "cyan"
    $system_info = systeminfo
    $host.UI.RawUI.foregroundcolor = "darkgray"    
    if(($system_info | Out-String).Contains("x64-based PC")){
        if(($system_info | Out-String).Contains("R2")){
            #Windows Server 2008 R2 64-bit (6.1)
            Write-Host "The system is 64-bit 6.1"
            $auto_download_KBs = @{    
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
        }
        else{
            #Windows Server 2008 64-bit (6.0)
            Write-Host "The system is 64-bit 6.0"
            $auto_download_KBs = @{
                KB2588516 = "https://bit.ly/37oIwEN"
                KB2705219 = "https://bit.ly/2ZxEGGm"
                KB2849470 = "https://bit.ly/2MG0fQ6"
                KB3011780 = "http://download.windowsupdate.com/d/msdownload/update/software/secu/2014/10/windows6.0-kb3011780-x64_c6135e518ffd1b053f1244a3f17d4c352c569c5b.msu"
                KB4012598 = "http://download.windowsupdate.com/d/msdownload/update/software/secu/2017/02/windows6.0-kb4012598-x64_6a186ba2b2b98b2144b50f88baf33a5fa53b5d76.msu"
                } 
        }
    }
    else{
        #Windows Server 2008 32-bit (6.0)
        Write-Host "The system is 32-bit 6.0"
        $auto_download_KBs = @{
            KB4012598 = "https://bit.ly/2Q3Qjlk"
            KB3011780 = "https://bit.ly/2ZzTRPF"
            }
    }

    #removes installed from $auto_download_KBs and removes junk from systeminfo KB name
    $kb_list = Foreach ($KB in $auto_download_KBs.GetEnumerator()){$KB.Name}
    $installed = $system_info | Select-String $kb_list
    if ($null -ne $installed){
        $installed = $installed -replace '(?m)^\s{27,}\[[0-9]\w\]\:\s',''
        $installed | ForEach-Object {Set-Variable -Name c -Value $_ -PassThru} | ForEach-Object {$auto_download_KBs.Remove($c)}
    }

    #export applicable list and provide output to console
    $host.UI.RawUI.foregroundcolor = "cyan"
    $auto_download_KBs | Export-Clixml -Path $env:userprofile\appdata\local\might_install.xml
    Write-Host "`"$env:userprofile\appdata\local\might_install.xml`" has list of HotFixes and thier URLs that did not match systeminfo HotFix list"

    $host.UI.RawUI.foregroundcolor = "magenta"
    $all = Read-Host "`nWould you like to downlad all" $auto_download_KBs.count "potentially applicable HotFixes now? (y, n)"
    if ($all -eq 'y'){
        #download all
        $host.UI.RawUI.foregroundcolor = "cyan"
        Write-Host "The" $auto_download_KBs.count "hotfixes below will be downloaded. Try installing KB2489256, KB2503658, and KB2769369 first"
        $host.UI.RawUI.foregroundcolor = "darkgray"
        $auto_download_KBs
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
    }else{
        pickAKB
    }  
    $host.UI.RawUI.foregroundcolor = "white"
    cmd /c pause
}

# --------- SMB status ---------
function SMBStatus{
makeOutDir
$host.UI.RawUI.foregroundcolor = "green"
Write-Host "`nReg query SMB status"
$host.UI.RawUI.foregroundcolor = "cyan"
#reg query HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters
Get-Item HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters | ForEach-Object {Get-ItemProperty $_.pspath} | Out-File $env:USERPROFILE\desktop\Script_Output\SMB_status.txt
$host.UI.RawUI.foregroundcolor = "darkgray"
Get-Content $env:USERPROFILE\desktop\Script_Output\SMB_status.txt
$host.UI.RawUI.foregroundcolor = "cyan"
Write-Host "`"$env:USERPROFILE\desktop\Script_Output\SMB_status.txt`" has SBM1 status"
$host.UI.RawUI.foregroundcolor = "white"
cmd /c pause
}

# --------- provide script output to the console ---------
function readOutput{
#output netstat -abno
$host.UI.RawUI.foregroundcolor = "green"
Write-Host "`nReading script output to console:`n"
$host.UI.RawUI.foregroundcolor = "cyan"
Write-Host "#netstat Output:"
if(-not (Test-Path -LiteralPath $env:USERPROFILE\desktop\Script_Output\netstat_est.txt)){
$host.UI.RawUI.foregroundcolor = "darkgray"
Write-Host "run regexNetstat"
}else{
$host.UI.RawUI.foregroundcolor = "cyan"
Write-Host "#ESTABLISHED Connections (netstat_est.txt)"
$host.UI.RawUI.foregroundcolor = "darkgray"
Get-Content $env:USERPROFILE\desktop\Script_Output\netstat_est.txt
Start-Sleep -s 3
$host.UI.RawUI.foregroundcolor = "cyan"
Write-Host "#LISTENING Connections (netstat_lsn.txt)"
$host.UI.RawUI.foregroundcolor = "darkgray"
Get-Content $env:USERPROFILE\desktop\Script_Output\netstat_lsn.txt
}

Start-Sleep -s 3
#output running services
$host.UI.RawUI.foregroundcolor = "cyan"
Write-Host "`n#List of Running Services (running_services.txt)"
$host.UI.RawUI.foregroundcolor = "darkgray"
if(-not (Test-Path -LiteralPath $env:USERPROFILE\desktop\Script_Output\running_services.txt)){
Write-Host "run runningServices"
}else{
Get-Content $env:USERPROFILE\desktop\Script_Output\running_services.txt
}

Start-Sleep -s 3
#updates to install
$host.UI.RawUI.foregroundcolor = "cyan"
Write-Host "#Please attempt to install these KBs (might_install.txt):"
$host.UI.RawUI.foregroundcolor = "darkgray"
if(-not (Test-Path "$env:USERPROFILE\desktop\Script_Output\might_install.txt")){
Write-host "criticalUpdateCheck not run or 0 HotFixes installed"
}
else{
Get-Content $env:USERPROFILE\desktop\Script_Output\might_install.txt
}

Start-Sleep -s 3
#NTP status
$host.UI.RawUI.foregroundcolor = "cyan"
Write-Host "`n#Network Time Protocol (NTP) Status (w32tm /query /status)"
$host.UI.RawUI.foregroundcolor = "darkgray"
w32tm /query /status

Start-Sleep -s 3
#firewall status
$host.UI.RawUI.foregroundcolor = "cyan"
Write-Host "#Firewall Status (firewall_status.txt)"
$host.UI.RawUI.foregroundcolor = "darkgray"
if(-not (Test-Path -LiteralPath $env:USERPROFILE\desktop\Script_Output\firewall_status.txt)){
Write-Host "run firewallStatus"
}else{
Get-Content $env:USERPROFILE\desktop\Script_Output\firewall_status.txt
}

Start-Sleep -s 3
#SMB status
$host.UI.RawUI.foregroundcolor = "cyan"
Write-Host "#SMB Status (SMB_status.txt)"
$host.UI.RawUI.foregroundcolor = "darkgray"
if(-not (Test-Path -LiteralPath $env:USERPROFILE\desktop\Script_Output\SMB_status.txt)){
Write-Host "run SMBStatus"
}else{
Get-Content $env:USERPROFILE\desktop\Script_Output\SMB_status.txt
}
$host.UI.RawUI.foregroundcolor = "white"
cmd /c pause
}

# --------- run enumeration functions ---------
function enumerate{
    $host.UI.RawUI.foregroundcolor = "green"
    Write-Host "Running enumeration functions"
    formatNetstat
    firewallStatus
    runningServices
    hotFixCheck
    SMBStatus
    readOutput
    cmd /c pause
}
#endregion Enumeration

# --------- run all critical functions ---------
function harden{
$host.UI.RawUI.foregroundcolor = "green"
Write-Host "Hardening"
makeOutDir
enumerate
turnOnFirewall
firewallRules
uniqueUserPols
disableTeredo
disableSMB1
disableRDP
disableAdminShares
disableGuest
disableCacheCreds
changeP
changePAdmin
changePBinddn
setPassPol
setAssToTxt
downloadTools
GPTool
$host.UI.RawUI.foregroundcolor = "green"
Write-Host "`nOpening Task Scheduler"
taskschd.msc
$host.UI.RawUI.foregroundcolor = "cyan"
Write-Host "Manually examine scheduled tasks"
$host.UI.RawUI.foregroundcolor = "green"
Write-Host "`nAll hardening functions are finished. Restart computer?"
$host.UI.RawUI.foregroundcolor = "white"
restart-computer -Confirm
cmd /c pause
}

# --------- provide list of available functions ---------
function avail{
$host.UI.RawUI.foregroundcolor = "green"
Write-Host "`nAvailable Functions:"
$host.UI.RawUI.foregroundcolor = "cyan"
Write-Host "
------- Noninvasive: -------
makeOutDir (makes script output directory on desktop)
enumerate (formatNetstat, firewallStatus, runningServices, hotFixCheck, readOutput)
downloadTools (download relevant tools)
hotFixCheck (checks list of HotFix KBs against systeminfo)
pickAKB (Provides applicable KB info then prompts for KB and downloads <KB>.msu to Script_Output)
autoDownloadKB (#incomplete)
firewallStatus
SMBStatus (returns SMB registry info)
formatNetstat (format netstat -abno)
runningServices
morePIDInfo (enter a PID for more info)
serviceInfo (enter a service name for more info)
NTPStripchart
readPasswords
readOutput (provide function output to console)
avail (display this screen)
------- Invasive: -------
harden (makeOutputDir, turnOnFirewall, setAssToTxt, disableAdminShares, disableSMB1, disableRDP, disableGuest, changePAdmin, changePBinddn, GPTool, changeP, setPassPol, uniqueUserPols, enumerate)
setAssToTxt (script file type open with notepad)
GPTool (opens GP info tool)
disableGuest (disables Guest account)
disableRDP (disables RDP via regedit)
disableAdminShares (disables Admin share via regedit)
disableTeredo  (disables teredo)
turnOnFirewall (turns on firewall)
firewallRules (Block RDP In, Block VNC In, Block VNC Java In, Block FTP In)
disableSMB1 (disables SMB1 and enable SMB2 via registry)
configNTP (ipconfig + set NTP server)
changeP (Kyle's AD user password script enhanced)
changePAdmin
changePBinddn
setPassPol (enable passwd complexity and length 12)
uniqueUserPols (enable all users require passwords, enable admin sensitive, remove all members from Schema Admins)
------- Injects: -------
firewallStatus
configNTP
`n"
$host.UI.RawUI.foregroundcolor = "white"
}
avail

#$HOST.UI.RawUI.ReadKey(“NoEcho,IncludeKeyDown”) | OUT-NULL
#$HOST.UI.RawUI.Flushinputbuffer()