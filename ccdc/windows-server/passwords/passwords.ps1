# --------- Main password changer ---------
# password complexity code credit to: https://gallery.technet.microsoft.com/Reset-the-krbtgt-account-581a9e51
#disable reverse encryption policy then change all DC user passwords except admin and binddn
function changePass {
    function Confirm-CtmADPasswordIsComplex
    {
    Param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]
    $Pw
    )
        Process
        {
        $CriteriaMet = 0
        If ($Pw -cmatch '[A-Z]') {$CriteriaMet++}
        If ($Pw -cmatch '[a-z]') {$CriteriaMet++}
        If ($Pw -match '\d') {$CriteriaMet++}
        If ($Pw -match '[\^~!@#$%^&*_+=`|\\(){}\[\]:;"''<>,.?/]') {$CriteriaMet++}
        If ($CriteriaMet -lt 3) {Return $false}
        If ($Pw.Length -lt 6) {Return $false}
        Return $true
        }
    }
function New-CtmADComplexPassword 
    {
    Param(
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
        [ValidateRange(6,127)]
        [Int]
        $PwLength=24
    )
    Process
        {
        $Iterations = 0
        Do 
            {
            If ($Iterations -ge 20) 
                {
                Write-Host "Password generation failed to meet complexity after $Iterations attempts, exiting."
                Return $null
                }
            $Iterations++
            $PWBytes = @()
            $RNG = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
            Do 
                {
                [byte[]]$Byte = [byte]1
                $RNG.GetBytes($Byte)
                If ($Byte[0] -lt 33 -or $Byte[0] -gt 126) { continue }
                $PWBytes += $Byte[0]
                } 
            While 
                ($PWBytes.Count -lt $PwLength)

            $Pw = ([char[]]$PWBytes) -join ''
            } 
        Until 
            (Confirm-CtmADPasswordIsComplex $Pw)
        Return $Pw
        }      
    }

    Write-Host -ForegroundColor Green "`nChanging all AD user passwords"
    Write-Host -ForegroundColor Cyan "Importing AD module"
    Import-Module ActiveDirectory
    Write-Host -ForegroundColor Cyan "Creation of hashes used in pass the hash attack reg setting:"
    reg query HKLM\System\CurrentControlSet\Control\Lsa /f NoLMHash

    $passLen = Read-Host "`nEnter the password length (0-25)"
    
    $samUsers = (Get-ADUser -Filter {SamAccountName -NotLike "Administrator" -and SamAccountName -NotLike "Guest" -and SamAccountName -NotLike "krbtgt" -and SamAccountName -NotLike "*_*" -and SamAccountName -NotLike "DefaultAccount"}).SamAccountName

    New-Variable -Name hashTable -Visibility Public -Value @{}
    foreach ($user in $samUsers)
    {
        $securePassword = ConvertTo-SecureString (New-CtmADComplexPassword "$passLen") -AsPlainText -Force;
        Write-Host -ForegroundColor DarkGray "Updating " -NoNewline
        Write-Host -ForegroundColor Cyan $user -NoNewline
        Write-Host -ForegroundColor DarkGray " password and enabling";
        Set-ADAccountPassword -Identity $user -Reset -NewPassword $securePassword;
        $encrypted = ConvertFrom-SecureString -SecureString $securePassword;
        Enable-ADAccount -Identity $user;
        Write-Host -ForegroundColor DarkGray "Adding $user to the hash table"
        $hashTable.Add($user,$encrypted)
    }
    $hashTable | Export-Clixml -Path $env:userprofile\Desktop\securePasswords.xml
    Write-Host -ForegroundColor Cyan "`n`"$env:userprofile\Desktop\securePasswords.xml`" has the AD user/password db.`n"
}

# --------- update the admin password ---------
function updateAdminPassword {
    Write-Host -ForegroundColor Green "`nChanges Admin password and name"
    Write-Host -ForegroundColor Cyan "Importing ActiveDirectory module"
    Import-Module ActiveDirectory

    Write-Host -ForegroundColor Cyan "Getting AD user admin"
    $admin = Get-ADUser Administrator

    Write-Host -ForegroundColor Cyan "Changing the admin password"
    $host.UI.RawUI.foregroundcolor = "magenta"
    $securePassword = Read-Host "`nEnter a new Administrator password" -AsSecureString
    Set-ADAccountPassword -Identity $admin -Reset -NewPassword $securePassword
    <# encrypt and export
    Write-Host -ForegroundColor Cyan "Encrypting and exporting"
    $encrypted = ConvertFrom-SecureString -SecureString $securePassword
    $admin = "$admin".Trim() -replace '[CN=]{3}|[\,].*',''
    Out-File -FilePath "$env:userprofile\desktop\Script_Output\admin_binddn_passwds.txt" -Append -InputObject $admin, $encrypted, ""
    Write-Host "desktop\Script_Output\admin_binddn_passwds.txt has changes log"
    if(Test-Path -LiteralPath $env:userprofile\appdata\local\securePasswords.xml){
        $hashtable = Import-Clixml $env:userprofile\appdata\local\securePasswords.xml
    }else{$hashtable = @{}}
    $hashTable[$admin] = $encrypted
    $hashTable | Export-Clixml -Path $env:userprofile\appdata\local\securePasswords.xml
    #>
    Write-Host -ForegroundColor Cyan "admin password has been updated"
    $host.UI.RawUI.foregroundcolor = "white"
    Write-Host "Press any key to continue . . ."; $HOST.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
    $HOST.UI.RawUI.Flushinputbuffer()
}

# --------- update the binddn password ---------
function updateBinddnPassword{
    Write-Host -ForegroundColor Green "`nChanges binddn password"
    Write-Host -ForegroundColor Cyan "Importing ActiveDirectory module"
    Import-Module ActiveDirectory

    Write-Host -ForegroundColor Cyan "Getting AD user binddn"
    $binddn = Get-ADUser binddn

    Write-Host -ForegroundColor Cyan "Changing binddn password"
    $host.UI.RawUI.foregroundcolor = "magenta"
    $securePassword = Read-Host "`nEnter a new binddn password" -AsSecureString
    Set-ADAccountPassword -Identity $binddn -Reset -NewPassword $securePassword
    <# encrypt and export
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
    #>
    Write-Host -ForegroundColor Cyan "binddn user password has been updated - now enabling"
    Enable-ADAccount -Identity $binddn
    $host.UI.RawUI.foregroundcolor = "white"
    Write-Host "Press any key to continue . . ."; $HOST.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
    $HOST.UI.RawUI.Flushinputbuffer()
}

function retrievePlainPasswords {
    if(Test-Path -Path $env:userprofile\Desktop\securePasswords.xml) {
        $hashtable = Import-Clixml $env:userprofile\Desktop\securePasswords.xml
        Write-Host "Loaded AD users hashtable: " -NoNewline
        Write-Host -ForegroundColor Green "True"        
    } else {
        Write-Host "Loaded AD users hashtable: " -NoNewline
        Write-Host -ForegroundColor Red "False"
    }
    Write-Host -ForegroundColor Green "Retreives plaintext AD password(s)"    
    Write-Host -ForegroundColor Cyan "`n1) Update all user passwords.`n2) Update binddn password.`n3) Update Administrator password.`n4) Print all plaintext to console.`n5) Save all plaintext to `"$env:userprofile\Desktop\all_user_passwords.txt`". (risky!)`n6) Retrieve single plaintext using SamAccountName.`n"
    Write-Host -ForegroundColor Magenta "Choose one: " -NoNewline
    $switch = Read-Host
    switch ($switch) {
        1 {
            changePass
        }
        2 {
            updateBinddnPassword
        }
        3 {
            updateAdminPassword
        }
        4 {
            foreach ($key in $hashTable.GetEnumerator()) {
                $PlainPassword = $key.Value
                $SecurePassword = ConvertTo-SecureString $PlainPassword
                $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
                $UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($BSTR)
                [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
                Write-Host -ForegroundColor Cyan $key.Name -NoNewline; 
                Write-Host ":" -NoNewline
                Write-Host -ForegroundColor DarkGray $UnsecurePassword
            }
        }
        5 {
            foreach ($key in $hashTable.GetEnumerator()) {
                $PlainPassword = "$($key.Value)"
                $SecurePassword = ConvertTo-SecureString $PlainPassword
                $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
                $UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($BSTR)
                [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
                #$host.UI.RawUI.foregroundcolor = "darkgray"
                Out-File -FilePath "$env:userprofile\Desktop\all_user_passwords.txt" -InputObject "$($key.Name):$UnsecurePassword`n" -Append
            }                
            Write-Host -ForegroundColor Cyan "All plaintext passwords saved to `"$env:userprofile\Desktop\all_user_passwords.txt`""
        }
        6 {
            $username = Read-Host "Enter SamAccountName to retreive the plaintext password"    
            $PlainPassword = $hashtable."$username"
            $SecurePassword = ConvertTo-SecureString $PlainPassword
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
            $UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($BSTR)
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
            Write-Host -ForegroundColor Cyan `n$username -NoNewline
            Write-Host ":" -NoNewline
            Write-Host -ForegroundColor DarkGray $UnsecurePassword`n
        }
    }
}

retrievePlainPasswords

