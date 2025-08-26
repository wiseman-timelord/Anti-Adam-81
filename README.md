# AntiMsVirus8-81
Status: Alpha (Not Working)

### Description
Its to disable built in redundant software in Windows 8/8.1, where you have an alternate solution maybe, or just want more efficient OS.

### Development
- It will be, AntiMSVirus and Satan Inside Remover, that were for widnows 10/11, but in 1 and for windows 8/8.1.
- T.B.A

### Preview
- Explains what it does...
```
===============================================================================
    AntiMsVirus8-81: Main Menu
===============================================================================







    1. Active Directory (Inconsistent)

    2. Windows Defender (Inconsistent)







===============================================================================
Selection; Menu Option = 1-2, Exit Tool = X:


```
- output 1...
```
===============================================================================
    Active Directory - Disable Operation
===============================================================================
Netlogon: Stopped and set to Disabled
W32Time: Stopped and set to Disabled
TermService: Stopped and set to Disabled
RemoteRegistry: Stopped and set to Disabled
iphlpsvc: Stopped and set to Disabled
SSDPSRV: Stopped and set to Disabled
fdPHost: Stopped and set to Disabled
FDResPub: Stopped and set to Disabled
WerSvc: Stopped and set to Disabled
DPS: Stopped and set to Disabled
wuauserv: Stopped and set to Disabled

===============================================================================
FINAL STATUS:
Active Directory Services: Inconsistent
===============================================================================
Press any key to return to menu...



```
- output 2...
```
===============================================================================
    Windows Defender - Disable Operation
===============================================================================
Creating registry disable flags...
  Set DisableAntiSpyware = 1
  Set DisableRealtimeMonitoring = 1
Stopping WinDefend service...
Setting WinDefend service to Disabled...
Disabling Windows Defender scheduled tasks...
  Disabled: Windows Defender Cache Maintenance
  Disabled: Windows Defender Cleanup
  Disabled: Windows Defender Scheduled Scan
  Disabled: Windows Defender Verification
Stopping Windows Defender processes...

===============================================================================
FINAL STATUS:
Windows Defender: Inconsistent
===============================================================================
Press any key to return to menu...


```


### Notation
- To Enable `F8` during boot for Boot Options such as Safe Mode, use this command in Command Prompt with Administrator rights
```
bcdedit /set {default} bootmenupolicy legacy"
```
## Warnings
- Do not apply unsafe hacks to your computer, unless you fully understand what it is you are doing, you should first know what, Active Directory and Windows Defender, do, and what would happen without them.
