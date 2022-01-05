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

    Write-Host -ForegroundColor Cyan "`nReplacing all AD passwords`n"
    Write-Host -ForegroundColor Cyan "Skipping service, admin, guest, and default accounts`n"
    $users = (Get-ADUser -Filter {SamAccountName -NotLike "Administrator" -and SamAccountName -NotLike "Guest" -and SamAccountName -NotLike "krbtgt" -and SamAccountName -NotLike "*_*" -and SamAccountName -NotLike "DefaultAccount"}).SamAccountName
    
    New-Variable -Name hashTable -Visibility Public -Value @{}
    $host.UI.RawUI.foregroundcolor = "darkgray"
    foreach ($user in $users)
    {
        $securePassword = ConvertTo-SecureString (New-CtmADComplexPassword "$passLen") -AsPlainText -Force
        Write-Host "Changing the password of $user"
        Set-ADAccountPassword -Identity $user -Reset -NewPassword $securePassword
        $encrypted = ConvertFrom-SecureString -SecureString $securePassword
        Write-Host "Now enabling $user account"
        Enable-ADAccount -Identity $user
        Out-File $env:userprofile\desktop\user_passwds_list.txt -Append -InputObject $user, $encrypted,""
        Write-Host "Adding $user to the hash table"
        $hashTable.Add($user,$encrypted)
    }
    Write-Host -ForegroundColor Cyan "`n`"$env:USERPROFILE\Desktop\user_passwds_list.txt`" has list of users and passwords"
    $hashTable | Export-Clixml -Path $env:userprofile\Desktop\securePasswords.xml
    Write-Host -ForegroundColor Cyan "`"%localappdata%\securePasswords.xml`" has AD users .xml db"
}

# --------- update the admin password ---------
function updateAdminPassword {
    Write-Host -ForegroundColor Green "`nChanges Admin password and name"
    Write-Host -ForegroundColor Cyan "Importing ActiveDirectory module"
    Import-Module ActiveDirectory

    Write-Host -ForegroundColor Cyan "Parsing the domain name"
    $domain = wmic computersystem get domain | Select-Object -skip 1
    $domain = "$domain".Trim()
    $domaina = "$domain".Trim() -replace '.\b\w+', ''
    $domainb = "$domain".trim() -replace '^\w+\.', ''

    Write-Host -ForegroundColor Cyan "Changing the admin password"
    $admin = "CN=Administrator,CN=Users,DC=$domaina,DC=$domainb"
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

    Write-Host "Parsing the domain name"
    $domain = wmic computersystem get domain | Select-Object -skip 1
    $domain = "$domain".Trim()
    $domaina = "$domain".Trim() -replace '.\b\w+', ''
    $domainb = "$domain".trim() -replace '^\w+\.', ''

    Write-Host "Changing binddn password"
    $binddn = "CN=binddn,CN=Users,DC=$domaina,DC=$domainb"
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
    Write-Host "Press any key to continue . . ."; $HOST.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
    $HOST.UI.RawUI.Flushinputbuffer()
}

function retrievePlainPasswords {
    Write-Host -ForegroundColor Green "Retreives plaintext AD password(s)"    
    $hashtable = Import-Clixml $env:userprofile\Desktop\securePasswords.xml
    #$host.UI.RawUI.foregroundcolor = "darkgray"
    Write-Host -ForegroundColor Cyan "1) Print all to console.`n2) Saves all to `"all_user_passwords.txt`".`n3) Prompt for a single username.`n"
    Write-Host -ForegroundColor Magenta "Choose one: " -NoNewline
    $switch = Read-Host
    switch ($switch) {
        1 {
            foreach ($key in $hashTable.GetEnumerator()) {
                #"The key $($key.Name) is $($key.Value)"
                $PlainPassword = "$($key.Value)"
                $SecurePassword = ConvertTo-SecureString $PlainPassword
                $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
                $UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($BSTR)
                [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
                #$host.UI.RawUI.foregroundcolor = "darkgray"
                Write-Host -ForegroundColor Cyan "$($key.Name)'s password is:" -NoNewline; Write-Host -ForegroundColor DarkGray " $UnsecurePassword`n" -NoNewline
            }
        }
        2 {
            foreach ($key in $hashTable.GetEnumerator()) {
                #"The key $($key.Name) is $($key.Value)"
                $PlainPassword = "$($key.Value)"
                $SecurePassword = ConvertTo-SecureString $PlainPassword
                $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
                $UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($BSTR)
                [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
                #$host.UI.RawUI.foregroundcolor = "darkgray"
                Out-File -FilePath "$env:userprofile\desktop\Script_Output\all_user_passwords.txt" -InputObject "$($key.Name):$UnsecurePassword`n" -Append
            }                
            Write-Host -ForegroundColor Cyan "All plaintext passwords are saved to `"Script_Output\all_user_passwords.txt`""
        }
        3 {
            $host.UI.RawUI.foregroundcolor = "magenta"
            $username = Read-Host "Enter a full username to retreive the password"    
            $PlainPassword = $hashtable."$username"
            $SecurePassword = ConvertTo-SecureString $PlainPassword
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
            $UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($BSTR)
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
            $host.UI.RawUI.foregroundcolor = "darkgray"
            Write-Host "The $username password is: $UnsecurePassword`n"
        }
    }
}

#changePass
retrievePlainPasswords
