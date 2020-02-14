# Windows Server Hardening
This script is a collection of many Windows Server hardening functions.  

hardening_exe is useable after compiled with PS2EXE  
https://gallery.technet.microsoft.com/scriptcenter/PS2EXE-GUI-Convert-e7cb69d5  

To-Do:  
Bring PS-modules version up to speed with exe compileable version.  

Script Goals:  
Disable unecessary services  
KB research and implementation  
AD users  
malware stuff  

# Function Descriptions
------- Invasive: -------  
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
    changePass (Kyle's AD user password script enhanced)  
    changePAdmin (input admin password)  
    changePBinddn (input admin password)  
    passPolicy (enable passwd complexity and length 12)  
    userPols (enable all users require passwords, enable admin sensitive, remove all members from Schema Admins)  
    ------- Extra: -------  
    configNTP (ipconfig + set NTP server)  
    changeDCMode (changes Domain Mode to Windows2008R2Domain)   
    makeADBackup  
    ------- Noninvasive: -------  
    events  
    eternalBlue (detects if Eternal Blue has been patched)  
    makeOutDir (makes script output directory on desktop)  
    timeStamp (timestamp Script_Output)  
    enumerate (startups, formatNetstat, firewallStatus, runningServices, hotFixCheck)  
    getTools (download and install relevant tools)  
    hotFixCheck (checks list of HotFix KBs against systeminfo)  
    pickAKB (Provides applicable KB info then prompts for KB and downloads <KB>.msu to `"downloads`")  
    startups  
    GPTool (opens GP info tool)  
    firewallStatus  
    SMBStatus (returns SMB registry info)  
    formatNetstat (format/regex netstat -abno, listening, and established > netstat_lsn.txt, netstat_est.txt)  
    runningServices  
    ------- Extra: -------  
    loopPing (ping all IP addresses in a class C network)  
    ports (displays common ports file)  
    dateChanged  
    morePIDInfo (enter a PID for more info)  
    serviceInfo (enter a service name for more info)  
    NTPStripchart  
    plainPass (retreive plaintext password(s) from saved ciphertext file)  
    readOutput (provide function output to console)  
    avail (display this screen)  
    ------- Injects: -------  
    firewallStatus  
    configNTP  
    firewallRules (opt. 1) - Open RDP for an IP address  
