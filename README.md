# AntiMsVirus8-81
Status: Alpha (it does some things, but not all things intended).

### Description
Its to disable built in, Defender/Anti-Spyware and Active Directory, consisderd, redundant or unneccessary, software in Windows 8/8.1, or where you have an alternate solution, or dont want so many inspections/reports/updates going on. 

### Preview
- Explains what it does...
```
===============================================================================
    AntiMsVirus8-81: Main Menu
===============================================================================







    1. Active Directory (Disabled)

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
Active Directory Services: Disabled
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

## Instruction (safe mode boot)
Disabling Active Directory works, while Defender remains inconsistent, so it does more stuff...
1) Reboot into safe mode (you should know or research how to do this if unsure).
2) If the batch did not work (as it fails the admin check), then just Run the powershell script as admin.
3) Select to disable things.
4) In theory it can be re-enabled, the relating code is not tested.

### Instruction (normal boot)
Less tweaks work, both will remain inconsistent...
1) use other method done through Safe Mode.
2) if you insist, then the batch will work, and launch the powershell script with, pwsh or powershell, select to disable things.
3) return to menu, but with both showing "Inconsistent", due to full tweaks not being able to be applied.
4) In theory it can be re-enabled, the relating code is not tested.

## Development
- Disabling Active Directory works in Safe mode, so testing must be done in Safe Mode. Still issues with fully disabling Defender. 
- It will be, AntiMSVirus and Satan Inside Remover, but in 1 and for windows 8/8.1. AntiMSVirus and Satan Inside Remover, for win 10 will also be merged into AntiMsVirus10-11.

### Notation
- It didnt seem to work by itself but supposedly; to Enable `F8` during boot for Boot Options such as Safe Mode, use this command in Command Prompt with Administrator rights
```
bcdedit /set {default} bootmenupolicy legacy"
```
## Warnings
- Do not apply unsafe hacks to your computer, unless you fully understand what it is you are doing, you should first know what, Active Directory and Windows Defender, do, and what would happen without them.
