::Using Double Colon works like a Comment
::Made for CyberPatriot Work & Script Work

::Tips: 
::Format for Creating Variable w/ User Input: 'set /p [variable-name]=[Words to Prompt User]'


:: The '@' symbol prevents the batch file from printing commands; neither this one
@echo off

echo CyberPatriot: Windows Server 2022 Script (September)
::Command to find the Type of Windows System you are
systeminfo | findstr /B /C:"OS Name"

timeout 3

::------------------------Removing Users--------------------------------::

:: Allows for Manipulation without Excess Code Storage & Need for Error Checking
echo Redirecting you to Other Users in Settings
explorer ms-settings:otherusers

timeout 1
::--------------------Misc Policies-----------------------------------::

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
echo SMB Client and Server Configurations
powershell.exe Set-SmbClientConfiguration -RequireSecuritySignature $true -Force
powershell.exe Set-SmbServerConfiguration -RequireSecuritySignature $true -Force

:: Turn on Complexity Reqs
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "PasswordComplexity" /t REG_DWORD /d 1 /f

::Session Idle Timeouts & Limits
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v MaxIdleTime /t REG_DWORD /d 900000 /f

:: Audit Policy Configurations
auditpol /set /category:* /success:enable /failure:enable

reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v EnablePlainTextPassword /t REG_DWORD /d 0 /f

echo Turning On All Firewalls!
netsh advfirewall set currentprofile state on
netsh advfirewall set domainprofile state on
netsh advfirewall set privateprofile state on

netsh advfirewall set allprofiles logging filename %systemroot%\system32\LogFiles\Firewall\pfirewall.log
netsh advfirewall set allprofiles logging maxfilesize 4096
netsh advfirewall set allprofiles logging droppedconnections enable

echo Log Dropped Connections and Configure Firewall IPsec to Enable Dynamic Firewall Adjustments
netsh advfirewall set allprofiles logging droppedconnections enable
netsh advfirewall set global statefulftp enable
netsh advfirewall set global statefulpptp enable

:: Enable Windows Defender Network Protection
powershell.exe Set-MpPreference -EnableNetworkProtection Enabled

::Disable NetBios over TCP
powershell.exe -command "(Get-WmiObject Win32_NetworkAdapterConfiguration -Filter 'IpEnabled=""true""') | ForEach-Object {$_.SetTcpipNetbios(2)}"


::Flush DNS and Auto-Clean
echo Flushing DNS
ipconfig /flushdns


::PowerShell Firewall Configurations
powershell -command "Set-MpPreference -DisableRealtimeMonitoring $false"

::Window Defender Firewall
sc start mpssvc
sc config mpssvc start= auto

::Microsoft Defender Antivirus Service
sc start WinDefend
sc config WinDefend start= auto

::---------------------Deleting Programs (Malicious)-----------------------::
echo Removing Wireshark, Npcap, and BitTorrent
"%ProgramFiles%\Wireshark\uninstall.exe" /S
"%ProgramFiles%\Npcap\uninstall.exe" /S
"%ProgramFiles%\WinPcap\uninstall.exe" /S
"%ProgramFiles%\BitTorrent\uninstall.exe" /S

::--------------------------Service Disabling—-------------------------------::
echo Disabling Insecure Services

:: FTP Service
sc stop ftpsvc
sc config ftpsvc start= manual

::Remote Registry
sc stop RemoteRegistry
sc config RemoteRegistry start= disabled

::SMTP
sc stop SMTPSVC
sc config SMTPSVC start= disabled

::SNMP Trap
sc stop SNMPTRAP
sc config SNMPTRAP start= disabled

::Telephony
sc stop tapisrv
sc config tapisrv start= manual

::Universal Plug n Play (host)
sc stop upnphost
sc config upnphost start= disabled

::Windows Defender Advanced Threat Protection Service
sc query Sense >nul 2>&1 && (
sc config Sense start= auto
sc start Sense
)

::Windows Auto-Update Service
sc start wuauserv
sc config wuauserv start= auto

::--------------------Searching Directories for Programs & Music--------------::

net user guest /active:no

echo Doing Background work.....

::Searching for Files in the Public Accessible Directory

echo CyberPatriot Directories and Logs > CyberLogs.txt

echo. >> CyberLogs.txt
dir /A C:\Users\Public\Documents\* >> CyberLogs.txt
echo. >> CyberLogs.txt
dir /A C:\Users\Public\Music\* >> CyberLogs.txt
echo. >> CyberLogs.txt
dir /A C:\Users\Public\Pictures\* >> CyberLogs.txt
echo. >> CyberLogs.txt
dir /A C:\Users\Public\Downloads\* >> CyberLogs.txt
echo. >> CyberLogs.txt
dir /A C:\Users\Public\Videos\* >> CyberLogs.txt
echo. >> CyberLogs.txt

echo Logging Functions Completed... or at least I think..

:: 2>nul is redirection of error messages to random thing
echo Mp3 files and Zip files >> CyberLogs.txt
echo. >> CyberLogs.txt
start /b cmd /c "dir /s /b C:\Users\*.mp3 2>nul >> CyberLogs.txt"
echo. >> CyberLogs.txt
start /b cmd /c "dir /s /b C:\Users\*.zip 2>nul >> CyberLogs.txt"


::-------------------Installing Security Software-------------------::

:: Check for Updates
wuauclt.exe /detectnow /updatenow

:: Force Windows Defender Sandbox
setx /M MP_FORCE_USE_SANDBOX 1

:: Update Windows Def. Signatures
"%ProgramFiles%\Windows Defender\MpCmdRun.exe" -SignatureUpdate

echo Updating Browsers...
if exist "C:\Program Files (x86)\Google\Update\" (
	echo Updating Google
  	Taskkill /F /IM "chrome.exe" 2>nul
  	"C:\Program Files (x86)\Google\Update\GoogleUpdate.exe" /ua
)else (
	echo Google does not exist on this Windows System
)
::-----------------Windows Update & Other Settings------------------::

:: The command 'explorer ms-settings' opens the GUI
:: Chromium Security Setting Configurations
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v SmartScreenEnabled /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v SmartScreenPuaEnabled /t REG_DWORD /d 1 /f


::timeout is basically time.sleep(x) [timeout 500]

echo Redirecting You to Update Options and RDP with Remote Assistance
SystemPropertiesRemote.exe

::Prevent Remote Assistance
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v fAllowToGetHelp /t REG_DWORD /d 0 /f


echo Completed Script!

PAUSE
