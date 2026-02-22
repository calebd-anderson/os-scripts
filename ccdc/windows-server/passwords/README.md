## Enumerates and sets AD user passwords
- `ad_users_hashtable.xml` - Local XML store containing all user [SamAccountName](https://learn.microsoft.com/en-us/windows/win32/adschema/a-samaccountname)s (key) and Names (value).  
- `getalladusers.ps1` - Enumerate all AD users and save to the XML store
- `passwords.ps1` - Manage AD user passwords
- `setalladusers.ps1` - Loads all users from the XML store then adds them to AD
