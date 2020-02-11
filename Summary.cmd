chcp 65001

REM 
REM 	Windows Reporting Tool
REM 	Version 02.2020.03 by marcin919
REM 
@echo off

mkdir %COMPUTERNAME%
set "AKTPFAD=%cd%"
set Network=%cd%\Network.log
set /a stunde=%time:~0,2%
set minute=%time:~3,2%

REM NETWORK
color 6a&&cls&&title by marcin919
echo NETWORKING/NETZWEK >>"%Network%"
echo Auswertung wurde startet um : %date% %stunde%:%minute%  >"%Network%" 
		
	ipconfig /all >>"%Network%" 
	ping 1.1.1.1 >>"%Network%"
	ping 8.8.8.8 >>"%Network%"

REM Kann extra eingeschaltet werden. Braucht aber extrem viel Zeit.
REM tracert 1.1.1.1 >>"%Network%"	
REM pathping 1.1.1.1 >>"%Network%"

REM USER
color 2f
Set User=%cd%\User.log
	
	whoami  >"%User%"
	whoami /all >>"%User%"
	net localgroup Administratoren >>"%User%"

REM KEY
REM https://www.tech-faq.net/windows-product-key-auslesen/
color 3f
Set Key=%cd%\Key.log
	wmic path softwarelicensingservice get OA3xOriginalProductKey >"%Key%"

REM SYSTEMINFO
color 4f
Set Systeminfo=%cd%\Systeminfo.log

	systeminfo > %Systeminfo%

REM PUBLIC IP 
REM wird IPv6 unterstuezt? Google DNS IPv6
REM ping -6 -n 1 COMPUTERNAME | findstr TTL && start home.mp3 || start alarm.mp3

REM ping -6 -n 1 2001:4860:4860::8888 | findstr "(0% Verlust)" && call Public-IPv6.vbs || call Public-IPv4.vbs
call Public-IPv4.vbs

REM Summary
color 5a
set Summary=%cd%\%COMPUTERNAME%\Summary_%COMPUTERNAME%_%date%.log

echo -------------------------------------------------------------  >"%Summary%"
findstr "Windows-IP-Konfiguration" Network.log >>"%Summary%"
echo ------------------------  >>"%Summary%"
findstr "Hostname" Network.log >>"%Summary%"
findstr "DNS-Suffixsuchliste" Network.log >>"%Summary%"
findstr "IPv4-Adresse" Network.log >>"%Summary%"
findstr "Subnetzmaske" Network.log >>"%Summary%"
findstr "Standardgateway" Network.log >>"%Summary%"
findstr "DHCP-Server" Network.log >>"%Summary%"
findstr "DNS-Server" Network.log >>"%Summary%"
echo.
color 5f
echo -------------------------------------------------------------  >>"%Summary%"
findstr "BENUTZERINFORMATIONEN" User.log >>"%Summary%"
echo ---------------------  >>"%Summary%"
	whoami  >>"%Summary%"
echo.
color 6c
echo -------------------------------------------------------------  >>"%Summary%"
echo PUBLIC IP-Adresse: >>"%Summary%"
echo ------------------  >>"%Summary%"
setlocal
for /f "tokens=13* delims=<>, " %%a in ('findstr "<body>" Public-IP.txt')  do (
	echo %%a >>"%Summary%"
)
echo.
color ea
echo -------------------------------------------------------------  >>"%Summary%"
echo SYSTEMINFO >>"%Summary%"
echo ---------- >>"%Summary%"
setlocal
for /f "tokens=3* delims=, " %%a in ('systeminfo.exe ^| find /i "Urspr"') do (
	set InstallDate=%%a
	set InstallTime=%%b
)
echo Ursprüngliches Installationsdatum: %InstallDate% >>"%Summary%"
REM Unbrauchbar
:: echo Ursprüngliches Installationszeit: %InstallTime% >>"%Summary%"

color ac
echo -------------------------------------------------------------  >>"%Summary%"
echo HARDWARE INFORMATIONEN >>"%Summary%"
echo ---------- >>"%Summary%"
	powershell -Command "gwmi win32_baseboard | fl *" | findstr /B ".*Manufacturer">>"%Summary%"
	powershell -Command "gwmi win32_baseboard | fl *" | findstr /B ".*Product">>"%Summary%"
	powershell -Command "gwmi win32_baseboard | fl *" | findstr /B ".*Version">>"%Summary%"
	powershell -Command "gwmi win32_baseboard | fl *" | findstr /B ".*SerialNumber">>"%Summary%"
REM BIOS Serial Nummer, ziemmlich unbrauchbar. 
::	echo BIOS SN: | wmic bios get serialnumber >>"%Summary%"
::	echo.>>"%Summary%"
color fa
echo -------------------------------------------------------------  >>"%Summary%"
echo OS INFORMATIONEN >>"%Summary%"
echo ---------- >>"%Summary%"
Set Slmgr=%cd%\Slmgr.log

findstr /b "Betriebssystemname" Systeminfo.log >>"%Summary%"
findstr /b "Betriebssystemversion" Systeminfo.log >>"%Summary%"
cscript c:\Windows\System32\slmgr.vbs /dli >"%Slmgr%"
findstr "Teil-Product" Slmgr.log >>"%Summary%"
findstr "Lizenzstatus" Slmgr.log >>"%Summary%"
echo .
color 5f
echo UPDATES >>"%Summary%"
echo ---------- >>"%Summary%"
Set Updates=%cd%\Updates.log

REM dism /online /get-Packages>"%Updates%"
REM findstr /b "Installationszeit" Updates.log >>"%Summary%"

powershell -command "Get-HotFix | Sort-Object HotFixID -Descending">"%Updates%"
powershell -command "Get-HotFix | Sort-Object InstalledOn">>"%Summary%"

REM setLocal enableDelayedExpansion
REM for /f %%a in (Updates.log) do for /f "tokens=*" %%A in ('findstr /xs "%%a"') do set lastFound=%%A
REM echo !lastFound! >>"%Summary%"

color 9a
REM /////////////////////////////////////////////////////////////////////////////////
move .\Key.log ".\%COMPUTERNAME%\Key_%COMPUTERNAME%_%date%.log"
move .\Network.log ".\%COMPUTERNAME%\Network_%COMPUTERNAME%_%date%.log"
move .\User.log ".\%COMPUTERNAME%\User_%COMPUTERNAME%_%date%.log"
move .\Key.log ".\%COMPUTERNAME%\Key_%COMPUTERNAME%_%date%.log"
move .\Systeminfo.log ".\%COMPUTERNAME%\Systeminfo_%COMPUTERNAME%_%date%.log"
move .\Public-IP.txt ".\%COMPUTERNAME%\Public-IP_%COMPUTERNAME%_%date%.log"
move .\Slmgr.log ".\%COMPUTERNAME%\Slmgr_%COMPUTERNAME%_%date%.log"
move .\Updates.log ".\%COMPUTERNAME%\Updates_%COMPUTERNAME%_%date%.log"
