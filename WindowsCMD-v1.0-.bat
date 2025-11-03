 ::Using Double Colon works like a Comment
::Made for CyberPatriot Work & Script Work

::Tips: 
::Format for Creating Variable w/ User Input: 'set /p [variable-name]=[Words to Prompt User]'


:: The '@' symbol prevents the batch file from printing commands;neither this one
@echo off

echo CyberPatriot: Windows Server 2022 Script (September)


::------------------------Removing Users--------------------------------::

:: Allows for Manipulation without Excess Code Storage & Need for Error Checking
explorer:ms-settings:otherusers

::--------------------Misc Policies-----------------------------------::

::Enforce Device Driver Signing
BCDEDIT /set nointegritychecks OFF

echo Security Time-Outs....
net accounts /lockoutthreshold:5
net accounts /lockoutduration:31
net accounts /maxpwage:90

echo Max Password Length and Min Age
net accounts /minpwlen:13
net accounts /minpwage:1

echo Force Logoff, Unique Password Cache, Complexity Reqs
::how long until expired/deleted accounts are forced logged off
net accounts /forcelogoff:5

::Change Unique Passwords Required Until Re-Use
net accounts /uniquepw:10

::Enable SMB Signing Requirements
powershell.exe Set-SmbClientConfiguration -RequireSecuritySignature $true
powershell.exe Set-SmbServerConfiguration -RequireSecuritySignature $true

:: Turn on Complexity Reqs
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "PasswordComplexity" /t REG_DWORD /d 1 /f

::auditpol (Audit Policies --> Configuration Command); && runs only if the last worked; ensure that the system supports it

:: Audit Policy Configurations
auditpol /set /category:* /success:enable /failure:enable
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v EnablePlainTextPassword /t REG_DWORD /d 0 /f

:: Stops Macros and Enables Safe Mode
reg add "HKCU\Software\Microsoft\Office\14.0\Word\Options" /v DontUpdateLinks /t REG_DWORD /d 00000001 /f
reg add "HKCU\Software\Microsoft\Office\14.0\Word\Options\WordMail" /v DontUpdateLinks /t REG_DWORD /d 00000001 /f
reg add "HKCU\Software\Microsoft\Office\15.0\Word\Options" /v DontUpdateLinks /t REG_DWORD /d 00000001 /f
reg add "HKCU\Software\Microsoft\Office\15.0\Word\Options\WordMail" /v DontUpdateLinks /t REG_DWORD /d 00000001 /f
reg add "HKCU\Software\Microsoft\Office\16.0\Word\Options" /v DontUpdateLinks /t REG_DWORD /d 00000001 /f
reg add "HKCU\Software\Microsoft\Office\16.0\Word\Options\WordMail" /v DontUpdateLinks /t REG_DWORD /d 00000001 /f


echo Turning On All Firewalls!
netsh advfirewall set currentprofile state on
netsh advfirewall set domainprofile state on
netsh advfirewall set privateprofile state on

:: Enable Secondary Firewalls (if any)
Netsh Advfirewall set allprofiles state on

netsh advfirewall set allprofiles logging filename %systemroot%\system32\LogFiles\Firewall\pfirewall.log
netsh advfirewall set allprofiles logging maxfilesize 4096
netsh advfirewall set allprofiles logging droppedconnections enable

::Log Dropped Connections & Configure Firewall IPsec --> Enable Dynamic Firewall Adjustments
netsh advfirewall set allprofiles droppedconnections on
netsh advfirewall set global statfulftp enable
netsh advfirewall set global statefulpptp enable

:: Enable Windows Defender Network Protection
powershell.exe Set-MpPreference -Enable NetworkProtection Enabled

::Disable NetBios over TCP
powershell.exe (Get-WmiObject Win32_NetworkAdapterConfiguration -Filter IpEnabled="true").setTcpipNetbios(2)
::---------------------Deleting Programs (Malicious)-----------------------::

"%ProgramFiles%\Wireshark\uninstall.exe" /S

:: DOESNT WORK --> 
"%ProgramFiles%\npcap.exe" /S

"%ProgramFiles%\WinPcap\uninstall.exe" /S

:: DOESNT WORK → 

%ProgramFiles%\BitTorrent\uninstall.exe /S
%ProgramFiles%\BitTorrent\unins000.exe /S

::--------------------------Service Disabling—-------------------------------::
:: FTP Service
sc stop ftpsvc
sc config ftpsvc start= disabled

: :Plug n Play
sc stop PlugPlay
sc config PlugPlay start= manual

: :Remote Registry
sc stop RemoteRegistry
sc config RemoteRegistry start= disabled

::SMTP
sc stop SMTPSVC
sc config SMTPSVC start= disabled

:: SNMP Trap
sc stop SNMPTRAP
sc config SNMPTRAP start= disabled

::Telephony
sc stop tapisrv
sc config tapisrv start= disabled

::Universal Plug n Play (host)
sc stop upnphost
sc config upnphost start= disabled

::Windows Defender Advanced Threat Protection Service
sc start Sense
sc config Sense start= auto

::Windows Auto-Update Service
sc start wuauserv
sc config wuauserv start= auto


::--------------------Searching Directories for Programs & Music--------------::

net user guest /active:no

echo Doing Background work.....

::Found Files
echo Space > susfile_.txt

:: ==== All Found Music Files (if any) =====

dir C:\Users\*.mp3 /s /b >> susfile_.txt

:: ==== All Found .Exe Files (if any need to be removed) ====
echo .exe files >> susfile_.txt
dir C:\Users\*.exe /s /b >> susfile_.txt

:: ==== Other .bat Files (probs remove) ====

echo .bat files >> susfile_.txt
dir C:\*.bat /s /b >> susfile_.txt

::Finding Startup Programs
echo Startup Programs >> susfile_.txt
dir "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Startup" /s /b >> susfile_.txt

::Open Ports
netstat -ano >> susfile_.txt

::Powershell Firewall Configurations
powershell -command "Set-MpPreference -DisableRealtimeMonitoring $false"
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring /t REG_DWORD /d 0 /f

::To check that it's up and running

::Window Defender Firewall
sc start mpssvc
sc config mpssvc start= auto

::Microsoft Defender Antivirus Service
sc start WinDefend
sc config WinDefend start= auto

echo Important Information Results saved to susfile_.txt

::-------------------Installing Security Software-------------------::

:: Check for Updates
wuauclt.exe /detectnow /updatenow

:: Force Windows Defender Sandbox
setx /M MP_FORCE_USE_SANDBOX 1

:: Update Windows Def. Signatures
"%ProgramFiles%"\"Windows Defender"\MpCmdRun.exe -SignatureUpdate

::Enable Periodic Scanning
reg add "HKCU\SOFTWARE\Microsoft\Windows Defender" /v Passive Mode /t REG_DWORD /d 2 /f


::-----------------Windows Update & Other Settings------------------::

:: The command 'explorer ms-settings' opens the GUI --> ENABL SmartScreen - Edge Phishing Protector
reg add "HKCU\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" /v EnabledV9 /t REG_DWORD /d 1 /f

::Enabling EncryptedFileSystem Encryption
fsutil behavior set disableencryption 0
if "fsutil behavior query disableencryption" == 0 (
echo Successfully Enabled EFS. Restart to Take Affect...) 
else (echo Failed to Enable EFS on the Provided Windows System)

REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v fAllowToGetHelp /t REG_DWORD /d 0 /f
netsh advfirewall firewall set rule group="Remote Assistance" new enable=no

::timeout is basically time.sleep(x)
timeout 5

::Sync Settings as Needed
explorer ms-settings:sync


echo Redirecting You --> Update Options and RDP with Remote Assistance

SystemPropertiesRemote.exe
timeout 3
explorer ms-settings:windowsupdate-action
timeout 2
explorer ms-settings:windowsupdate-options

PAUSE

