
# Windows Server Hardening
These PowerShell scripts were a study of Windows Server 2008 R2 security harding during my time on the Metropolitan State University CCDC team in 2020.

- The [hardening_exe.ps1](./hardening_exe.ps1) PowerShell script is designed to be compiled into a binary executable with [PS2EXE](http://web.archive.org/web/20200318065516/https://gallery.technet.microsoft.com/scriptcenter/PS2EXE-GUI-Convert-e7cb69d5), which allows the script to work even if PowerShell is completely disabled on the target machine.
> [!TIP]
> 🔥 Use the compiled executable from CLI and pass function names (below) as arguments/switches.
- The [passwords](./passwords) scripts explore PowerShell encryption with [Data Protection API (DPAPI)](https://learn.microsoft.com/en-us/powershell/utility-modules/secretmanagement/how-to/using-secrets-in-automation?view=ps-modules) and batch AD user password management.

## Documentation

### Function Descriptions:  
#### ------- Enumerate (reads the system): -------  
**startups** (enumerate startup programs)  
**superNetstat** (netstat -abno, LISTENING, ESTABLISHED > netstat_lsn.txt, netstat_est.txt)  
**firewallStatus**  
**runningServices**  
**expertUpdate** (checks list of HotFix KBs against systeminfo)  
**SMBStatus** (returns SMB registry info)  
**enumerate**: (executes all modules above)  
**events** (Win events)  
**eternalBlue** (indicates if Eternal Blue has been patched)  
**makeOutDir** (creates output dir on desktop)  
**timeStamp** (timestamp Script_Output dir)  
**getTools** (download and install your tools)  
**pickAKB** (Provides applicable KB info then prompts for KB and downloads \<KB\>.msu to "downloads")  
**GPTool** (opens group policy info tool)  
##### ------- Extra Enumerate: -------  
**loopPing** (identify ping replies in a class C network)  
**ports** (displays common ports file)  
**dateChanged**  
**morePIDInfo** (enter a PID to display detailed info)  
**serviceInfo** (enter a service name to display detailed info)  
**NTPStripchart**  
**plainPass** (decrypt and display password(s) from ciphertext file)  
**readOutput** (read output files to console)  
**avail** (display this screen)  
#### ------- Invasive (changes the system): ------  
**harden**: (makeOutputDir, firewallRules, turnOnFirewall, scriptToTxt, disableAdminShares, miscRegedits, enableSMB2, disableRDP, 
**disablePrintSpooler**, disableGuest, changePAdmin, changePBinddn, GPTool, changePass, passPolicy, userPols, enumerate)  
**scriptToTxt** (script file type open with notepad) | -Revert, -r  
**removeIsass**  
**netCease** (disable Net Session Enumeration) | -Revert, -r  
**cve_0674** (disables jscript.dll) | -Revert, -r  
**disableGuest** (disables Guest account)  
**disableRDP** (disables RDP via regedit)  
**disableAdminShares** (disables Admin share via regedit)  
**miscRegedits** (many mimikatz cache edits)  
**disablePrintSpooler** (disables print spooler service)  
**disableTeredo**  (disables teredo)  
**firewallOn** (turns on firewall)  
**firewallRules** (Block RDP In, Block VNC In, Block VNC Java In, Block FTP In)  
**enableSMB2** (disables SMB1 and enable SMB2 via registry)  
**changePass** (<> AD user password script enhanced)  
**changePAdmin** (input admin password)  
**changePBinddn** (input binddn password)  
**passPolicy** (enable passwd complexity and length 12)  
**userPols** (enable all users require passwords, enable admin sensitive, remove all members from Schema Admins)  
##### ------- Extra: -------  
**configNTP** (ipconfig + set NTP server)  
**changeDCMode** (changes Domain Mode to Windows2008R2Domain)   
**makeADBackup**  
#### ------- Injects: -------  
**firewallStatus**  
**configNTP**  
**firewallRules** (opt. 1) - Open RDP for an IP address  

### Script Goals/To-Do:  
- Disable unecessary services  
- KB research and implementation  
- AD users  
- malware stuff  
- group policy efficiency  
