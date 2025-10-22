::Using Double Colon works like a Comment
::Made for CyberPatriot Work & Script Work

::Ronan's CyberScript for Windows & Windows Server

::Tips: 
::Format for Creating Variable w/ User Input: 'set /p [variable-name]=[Words to Prompt User]'


:: The '@' symbol prevents the batch file from printing commands;neither this one
@echo off

echo CyberPatriot: Windows Server 2022 Script (September)


::------------------------Removing Users w/ Admin--------------------------------::

echo Displaying Users w/ Admin

net localgroup administrators

set /p AdminRemove=Name an incorrect Administrator: 

::Press Enter to Skip Removing Admins::

if "%AdminRemove%"=="" (echo No User Specified, Skipping Removal...) else (
echo Removing %AdminRemove%
net localgroup administrators "%AdminRemove%" /delete
)

::----------------------------Removing Users w/out Admin------------------------::

echo Displaying Total Users

net localgroup users

set /p UserRemove=Name a invalid or bad user: 

:Press 'space' then 'backspace' to not do anything::

if "%UserRemove%"=="" (echo No User Specified, Skipping Removal..) else (
echo Removing "%UserRemove%"
net localgroup users "%UserRemove%" /delete
)


::--------------------Misc Policies-----------------------------------::

echo Turning On All Firewalls!
netsh advfirewall set currentprofile state on
netsh advfirewall set domainprofile state on
netsh advfirewall set privateprofile state on

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

::how many unique passwords before reuse
net accounts /uniquepw:10

::Turn on Complexity Reqs
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "PasswordComplexity" /t REG_DWORD /d 1 /f


::auditpol (Audit Policies --> Configuration Command); && runs only if the last worked; ensure that the system supports it

echo Audit Policy Configurations


auditpol /set /category:* /success:enable /failure:enable

::User Rights Assignment Policies

::Nothing...Yet


::---------------------Deleting Programs (Malicious)-----------------------::

"%ProgramFiles%\Wireshark\uninstall.exe" /S
:: DOESNT WORK --> "%ProgramFiles%\Npcap\uninstall.exe" /S
"%ProgramFiles%\WinPcap\uninstall.exe" /S

:: DOESNT WORK → %ProgramFiles%\BitTorrent\uninstall.exe /S

::--------------------------Service Disabling—-------------------------------::
::FTP Service
sc stop ftpsvc
sc config ftpsvc start= disabled

::Plug n Play
sc stop PlugPlay
sc config PlugPlay start= manual

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
echo. > susfile_.txt

::echo ==== All Found Music Files (if any) =====

dir C:\Users\*.mp3 /s /b >> susfile_.txt

::echo ==== All Found .Exe Files (if any need to be removed) ====
echo .exe files >> susfile_.txt
dir C:\Users\*.exe /s /b >> susfile_.txt

::echo ==== Other .bat Files (probs remove) ====

echo .bat files >> susfile_.txt
dir C:\*.bat /s /b >> susfile_.txt

::Finding Startup Programs
echo Startup Programs >> susfile_.txt
dir "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Startup" /s /b >> susfile_.txt

::Open Ports
netstat -ano >> susfile_.txt

::echo Powershell Firewall Configurations

powershell -Command "Set-MpPreference -DisableRealtimeMonitoring 0; Start-Service WinDefend"
::To check that it's up and running

::Window Defender Firewall
sc start mpssvc
sc config mpssvc start= auto

::Microsoft Defender Antivirus Service
sc start WinDefend
sc config WinDefend start= auto

echo Important Information Results saved to susfile_.txt


::-------------------Installing Security Software-------------------::

::Check for Updates
wuauclt.exe /detectnow

::-----------------Windows Update & Other Settings------------------::


::The command 'explorer ms-settings' [] allows for me to go through Windows Settings, or do actions while opening the GUI


::timeout is basically time.sleep(x)
timeout 5


echo Redirecting You --> Update Options
explorer ms-settings:windowsupdate-options

::Prevents Batch File from Immeadiately closing when finished
:: 'If needed' PAUSE


 

