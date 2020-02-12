@echo off
chcp 65001 >nul & rem umlaute im Text darstellen

REM 	Windows Reporting Tool
REM 	Version 2020-02-12 by marcin919

setlocal enableDelayedExpansion

REM Create a path for the entire computer information
mkdir %COMPUTERNAME%
set "AKTPFAD=%cd%"
set Network=%cd%\Network.log
set /a stunde=%time:~0,2%
set minute=%time:~3,2%


REM 1. NETWORK

color E1&&cls&&title Windows Reporting Tool (2020-02-12)
echo NETZWERK >>"%Network%"
echo Dieser Auswertung wurde um %stunde%:%minute% Uhr am %date% gestartet.>"%Network%" 

	ipconfig /all >>"%Network%" 
	ping 1.1.1.1 >>"%Network%"
	ping 8.8.8.8 >>"%Network%"

REM Extra Netzwerk auswertung. Skript Braucht viel mehr Zeit.
REM tracert 1.1.1.1 >>"%Network%"	
REM pathping 1.1.1.1 >>"%Network%"

set Summary=%cd%\%COMPUTERNAME%\Summary_%COMPUTERNAME%_%date%.log

echo.>"%Summary%"
echo Dieser Auswertung wurde um %stunde%:%minute% Uhr am %date% gestartet.>>"%Summary%"
echo.>>"%Summary%"	
findstr "Windows-IP-Konfiguration" Network.log >>"%Summary%"
echo ------------------------  >>"%Summary%"
findstr "Hostname" Network.log >>"%Summary%"
findstr "DNS-Suffixsuchliste" Network.log >>"%Summary%"
findstr "IPv4-Adresse" Network.log >>"%Summary%"
findstr "Subnetzmaske" Network.log >>"%Summary%"
findstr "Standardgateway" Network.log >>"%Summary%"
findstr "DHCP-Server" Network.log >>"%Summary%"
findstr "DNS-Server" Network.log >>"%Summary%"
echo.>>"%Summary%"


REM 2. USER

color D1
Set User=%cd%\User.log
	
	whoami  >"%User%"
	whoami /all >>"%User%"
	net localgroup Administratoren >>"%User%"


findstr "BENUTZERINFORMATIONEN" User.log >>"%Summary%"
echo ---------------------  >>"%Summary%"
	whoami  >>"%Summary%"
echo.>>"%Summary%"


REM 3. KEY
REM Funktioniert selten?!
color C1
Set Key=%cd%\Key.log
	wmic path softwarelicensingservice get OA3xOriginalProductKey >"%Key%"
REM ohne Ausgabe in >>"%Summary%"


REM 4. SYSTEMINFO

color B1
Set Systeminfo=%cd%\Systeminfo.log
	systeminfo > %Systeminfo%


echo SYSTEMINFO >>"%Summary%"
echo ---------- >>"%Summary%"
setlocal
for /f "tokens=3* delims=, " %%a in ('systeminfo.exe ^| find /i "Urspr"') do (
	set InstallDate=%%a
	set InstallTime=%%b
)
echo Ursprüngliches Installationsdatum: %InstallDate% >>"%Summary%"
echo.>>"%Summary%"
REM Unbrauchbar
:: echo Ursprüngliches Installationszeit: %InstallTime% >>"%Summary%"


REM 5. PUBLIC IP 

color A1
REM wird IPv6 unterstuezt? Google DNS IPv6 wird hier angepingt

REM ping -6 -n 1 2001:4860:4860::8888 | findstr "(0% Verlust)" && call Public-IPv6.vbs || call Public-IPv4.vbs
 call Public-IPv4.vbs
REM call Public-IPv6.vbs 


echo PUBLIC IP-Adresse: >>"%Summary%"
echo ------------------  >>"%Summary%"
setlocal
for /f "tokens=13* delims=<>, " %%a in ('findstr "<body>" Public-IP.txt')  do (
	echo %%a >>"%Summary%"
)
echo.>>"%Summary%"


REM 6. HARDWARE INFORMATIONEN 

color 91

echo HARDWARE INFORMATIONEN >>"%Summary%"
echo ---------- >>"%Summary%"
	powershell -Command "gwmi win32_baseboard | fl *" | findstr /B ".*Manufacturer">>"%Summary%"
	powershell -Command "gwmi win32_baseboard | fl *" | findstr /B ".*Product">>"%Summary%"
	powershell -Command "gwmi win32_baseboard | fl *" | findstr /B ".*Version">>"%Summary%"
	powershell -Command "gwmi win32_baseboard | fl *" | findstr /B ".*SerialNumber">>"%Summary%"
REM BIOS Serial Nummer, ziemmlich unbrauchbar. 
::	echo BIOS SN: | wmic bios get serialnumber >>"%Summary%"
echo.>>"%Summary%"


REM 7. OS INFORMATIONEN 

color 8f

echo OS INFORMATIONEN >>"%Summary%"
echo ---------- >>"%Summary%"
Set Slmgr=%cd%\Slmgr.log

findstr /b "Betriebssystemname" Systeminfo.log >>"%Summary%"
findstr /b "Betriebssystemversion" Systeminfo.log >>"%Summary%"
cscript c:\Windows\System32\slmgr.vbs /dli >"%Slmgr%"
findstr "Teil-Product" Slmgr.log >>"%Summary%"
findstr "Lizenzstatus" Slmgr.log >>"%Summary%"
echo.>>"%Summary%"


REM 8. OS UPDATES 

color 7f
echo UPDATES >>"%Summary%"
echo ---------- >>"%Summary%"
Set Updates=%cd%\Updates.log

REM dism /online /get-Packages>"%Updates%"
REM findstr /b "Installationszeit" Updates.log >>"%Summary%"

powershell -command "Get-HotFix | Sort-Object HotFixID -Descending">"%Updates%"
powershell -command "Get-HotFix | Sort-Object InstalledOn | Select-Object -last 3">>"%Summary%"

REM setLocal enableDelayedExpansion
REM for /f %%a in (Updates.log) do for /f "tokens=*" %%A in ('findstr /xs "%%a"') do set lastFound=%%A
REM echo !lastFound! >>"%Summary%"
echo.>>"%Summary%"


REM 9 DRUCKER

color 2a
echo STANDARD DRUCKER >>"%Summary%"
echo ---------------- >>"%Summary%"
Set TMP=%cd%\TMP.log
	wmic printer where "Default = 'True'" get Name>"%TMP%"
    more +1 TMP.log  >>"%Summary%"


del TMP.log
echo.>>"%Summary%"

color 6f
REM /////////////////////////////////////////////////////////////////////////////////
move .\Key.log ".\%COMPUTERNAME%\Key_%COMPUTERNAME%_%date%.log"
move .\Network.log ".\%COMPUTERNAME%\Network_%COMPUTERNAME%_%date%.log"
move .\User.log ".\%COMPUTERNAME%\User_%COMPUTERNAME%_%date%.log"
move .\Key.log ".\%COMPUTERNAME%\Key_%COMPUTERNAME%_%date%.log"
move .\Systeminfo.log ".\%COMPUTERNAME%\Systeminfo_%COMPUTERNAME%_%date%.log"
move .\Public-IP.txt ".\%COMPUTERNAME%\Public-IP_%COMPUTERNAME%_%date%.log"
move .\Slmgr.log ".\%COMPUTERNAME%\Slmgr_%COMPUTERNAME%_%date%.log"
move .\Updates.log ".\%COMPUTERNAME%\Updates_%COMPUTERNAME%_%date%.log"
