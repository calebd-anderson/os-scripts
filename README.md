# Windows Server Hardening
### This script served as a study of Windows Server R2 security hardening.  
**Disclaimer**: This script was built to be run in a VM for testing and educational purposes. It was not built for a production environment nor for malicious purposes.  
It is a combination of cmd bash and PowerShell.

#### There are two versions:  
A PowerShell script meant to be run right in PowerShell. (probably behind)  
- hardening.ps1  

As well as a script that was designed to be compiled into a binary executable which allows PowerShell to be disabled completely.
- hardening_exe.ps1  

Compile using PS2EXE found at this URL    
https://gallery.technet.microsoft.com/scriptcenter/PS2EXE-GUI-Convert-e7cb69d5  

🔥 Start the executable from cmd and pass function names as arguments/switches.

### Script Goals/To-Do:  
Disable unecessary services  
KB research and implementation  
AD users  
malware stuff  
group policy efficiency  
  
### Function Descriptions  
#### ------- Enumerate (reads the system): -------  
startups (enumerate startup programs)  
superNetstat (netstat -abno, LISTENING, ESTABLISHED > netstat_lsn.txt, netstat_est.txt)  
firewallStatus  
runningServices  
expertUpdate (checks list of HotFix KBs against systeminfo)  
SMBStatus (returns SMB registry info)  
enumerate (executes all modules above)  
events (Win events)  
eternalBlue (indicates if Eternal Blue has been patched)  
makeOutDir (creates output dir on desktop)  
timeStamp (timestamp Script_Output dir)  
getTools (download and install your tools)  
pickAKB (Provides applicable KB info then prompts for KB and downloads \<KB\>.msu to "downloads")  
GPTool (opens group policy info tool)  
##### ------- Extra Enumerate: -------  
loopPing (identify ping replies in a class C network)  
ports (displays common ports file)  
dateChanged  
morePIDInfo (enter a PID to display detailed info)  
serviceInfo (enter a service name to display detailed info)  
NTPStripchart  
plainPass (decrypt and display password(s) from ciphertext file)  
readOutput (read output files to console)  
avail (display this screen)  
#### ------- Injects: -------  
firewallStatus  
configNTP  
firewallRules (opt. 1) - Open RDP for an IP address  
#### ------- Invasive (changes the system): ------  
harden (makeOutputDir, firewallRules, turnOnFirewall, scriptToTxt, disableAdminShares, miscRegedits, enableSMB2, disableRDP,  
disablePrintSpooler, disableGuest, changePAdmin, changePBinddn, GPTool, changePass, passPolicy, userPols, enumerate)  
scriptToTxt (script file type open with notepad) | -Revert, -r  
removeIsass  
netCease (disable Net Session Enumeration) | -Revert, -r  
cve_0674 (disables jscript.dll) | -Revert, -r  
disableGuest (disables Guest account)  
disableRDP (disables RDP via regedit)  
disableAdminShares (disables Admin share via regedit)  
miscRegedits (many mimikatz cache edits)  
disablePrintSpooler (disables print spooler service)  
disableTeredo  (disables teredo)  
firewallOn (turns on firewall)  
firewallRules (Block RDP In, Block VNC In, Block VNC Java In, Block FTP In)  
enableSMB2 (disables SMB1 and enable SMB2 via registry)  
changePass (<> AD user password script enhanced)  
changePAdmin (input admin password)  
changePBinddn (input admin password)  
passPolicy (enable passwd complexity and length 12)  
userPols (enable all users require passwords, enable admin sensitive, remove all members from Schema Admins)  
##### ------- Extra: -------  
configNTP (ipconfig + set NTP server)  
changeDCMode (changes Domain Mode to Windows2008R2Domain)   
makeADBackup  
  
### Other credit:  
https://github.com/PaulSec/awesome-windows-domain-hardening    
https://www.codeproject.com/articles/2318/data-encryption-with-dpapi    
https://gallery.technet.microsoft.com/scriptcenter/PowerShell-Encryption-45709b87    
https://gallery.technet.microsoft.com/Reset-the-krbtgt-account-581a9e51    
https://support.microsoft.com/en-us/help/4023262/how-to-verify-that-ms17-010-is-installed    
https://www.amazon.com/Blue-Team-Field-Manual-BTFM/dp/154101636X/ref=sr_1_3?dchild=1&hvadid=78134097399686&hvbmt=be&hvdev=c&hvqmt=e&keywords=blue+team+handbook&qid=1607392571&sr=8-3&tag=mh0b-20
