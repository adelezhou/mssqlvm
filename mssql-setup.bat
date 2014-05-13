@echo off

rem dependencies required to be present in the same folder as this script
rem ---
rem 7z922.exe
rem curl-7.29.0-rtmp-ssh2-ssl-sspi-zlib-idn-static-bin-w32.zip
rem ---

set WORK_DIR=C:\mssql-setup
mkdir %WORK_DIR%
cd %WORK_DIR%

set DESKTOP_DIR=%~p0

copy "%DESKTOP_DIR%7z922.exe" %WORK_DIR%\
copy "%DESKTOP_DIR%curl-7.29.0-rtmp-ssh2-ssl-sspi-zlib-idn-static-bin-w32.zip" %WORK_DIR%\

7z922.exe /S
"%ProgramFiles%\7-Zip\7z.exe" x curl-7.29.0-rtmp-ssh2-ssl-sspi-zlib-idn-static-bin-w32.zip

set "CURL_BIN=%WORK_DIR%\curl-7.29.0-rtmp-ssh2-ssl-sspi-zlib-idn-static-bin-w32"

echo Downloading Microsoft .NET Framework Version 2.0 Redistributable Package (x86)
%CURL_BIN%\curl -L -O http://download.microsoft.com/download/5/6/7/567758a3-759e-473e-bf8f-52154438565a/dotnetfx.exe

echo Downloading Microsoft SQL Server 2000 Desktop Engine (MSDE 2000) Release A
%CURL_BIN%\curl -L -O http://download.microsoft.com/download/D/5/4/D5402C33-65DE-4464-9D82-D1DE2971D9DB/MSDE2000A.exe

echo Downloading Microsoft SQL Server Management Studio Express
%CURL_BIN%\curl -L -O http://download.microsoft.com/download/a/6/c/a6c820bb-9043-4ef6-8a7b-a0cd327cf8c5/SQLServer2005_SSMSEE.msi

echo Installing Microsoft .NET Framework Version 2.0 Redistributable Package (x86)
dotnetfx.exe /q:a /c:"install.exe /q"

echo Installing Microsoft SQL Server Management Studio Express
msiexec /passive /norestart /i SQLServer2005_SSMSEE.msi

echo Installing Microsoft SQL Server 2000 Desktop Engine (MSDE 2000) Release A
"%ProgramFiles%\7-Zip\7z.exe" x -oMSDE2000A MSDE2000A.EXE
mkdir "C:\MSSQL2000"
MSDE2000A\setup INSTANCENAME="DEVDB" SECURITYMODE=SQL SAPWD="devadmin" DISABLENETWORKPROTOCOLS=0 DATADIR="C:\MSSQL2000\Data\" TARGETDIR="C:\MSSQL2000\"

echo Configuring database
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\DEVDB\MSSQLServer\SuperSocketNetLib\Tcp" /v TcpDynamicPorts /t REG_SZ /d 1433 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\DEVDB\MSSQLServer\SuperSocketNetLib\Tcp" /v TcpPort /t REG_SZ /d 1433 /f

echo Configuring firewall
netsh firewall add allowedprogram "C:\MSSQL2000\MSSQL$DEVDB\Binn\sqlservr.exe" "MSSQL - DEVDB" enable

echo Start database
net start "MSSQL$DEVDB"

echo Set static IP for host-only interface
netsh interface ip set address name="Local Area Connection 2" static 192.168.56.101 255.255.255.0

echo Setup complete
echo Database[ip=192.168.56.101, port=1433, user=sa, password=devadmin]
