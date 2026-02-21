Import-Module ActiveDirectory

# import user hashtable from getalladusers.ps1
$hashtable = Import-Clixml $env:userprofile\Desktop\ad_users_hashtable.xml
$uid = 1000
foreach ($key in $hashTable.GetEnumerator()) {
    New-ADUser -Name $key.Value -SamAccountName $key.Name -Path "OU=MailUsers,DC=metro-ccdc,DC=lab" -OtherAttributes `
    @{'gidNumber'='10000';'uidNumber'=($uid++);'uid'=$key.Name;'unixHomeDirectory'='/home/'+$key.Name;'loginShell'='/bin/bash';} `
    -UserPrincipalName ($key.name + "@metro-ccdc.lab")
}
