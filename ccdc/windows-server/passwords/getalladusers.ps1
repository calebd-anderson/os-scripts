# to-do: skip these users
# Administrator
# Guest
# krbtgt
# IUSR_SHAREPEG
# HVU_FILESERVER1
# IWAM_SHAREPEG

Import-Module ActiveDirectory

# bug in legacy powershell with this
$domain = "$(wmic computersystem get domain | Select-Object -skip 1)".Trim();
$subd = $domain.Split('.')[0];
$tld = $domain.Split('.')[1];
$container = "CN=Users, DC=$subd, DC=$tld";
$filter = {SamAccountName -NotLike "Administrator" -and SamAccountName -NotLike "Guest" -and SamAccountName -NotLike "binddn" -and SamAccountName -NotLike "krbtgt" -and SamAccountName -NotLike "*_*"}

$userTable = Get-ADUser -Filter $filter -SearchScope Subtree -SearchBase $container | Format-Table Name,SamAccountName -A

$userObjects = Get-ADUser -Filter $filter -SearchScope Subtree -SearchBase $container

Out-File $env:userprofile\Desktop\all_users_table.txt -InputObject $userTable

New-Variable -Name hashTable -Visibility Public -Value @{};

foreach ($user in $userObjects) {
    $hashTable.add($user.SamAccountName,$user.Name);
}

$hashTable | Export-Clixml -Path $env:userprofile\Desktop\ad_users_hashtable.xml
