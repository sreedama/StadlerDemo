@echo off
echo **************************************************************
echo *													     
echo *         Voestalpine Environment Switcher
echo *													 
echo **************************************************************

set CURRENT_DIR=%~dp0
goto check_Permissions

:DECISION
echo.
echo Please confirm that you have closed Teamcenter before continuing this switcher. Specify "N" to exist without change.
set /P DECISION=(Y)es or (N)o:
if /I "%DECISION%"=="Y" goto START
if /I "%DECISION%"=="N" goto :EOF
if /I "%DECISION%"!="Y" "&" "%DECISION%"!="N"   goto :EOF

:START
TASKKILL /F /IM java.exe
TASKKILL /F /IM Teamcenter.exe

echo Please confirm which Environment to Login.
echo Enter 1 For Production Teamcenter 12
echo Enter 2 For Test with Teamcenter 12
echo Enter 3 For any environment with Teamcenter 11

set /P DECISION=(1, 2 or 3):
if /I "%DECISION%"=="1" goto PROD
if /I "%DECISION%"=="2" goto TEST
if /I "%DECISION%"=="3" goto TC11
if /I "%DECISION%"!="1" "&" "%DECISION%"!="2"   goto :EOF

:PROD
echo setting FMS_HOME...
setx FMS_HOME c:\plm\tc12_4t\tccs /m
echo copying files to Enable PRODUCTION client configuration...
xcopy /s /y %CURRENT_DIR%switcher\PROD\midtierservers\*.* C:\plm\tc12_4t\midtierservers
xcopy /s /y %CURRENT_DIR%switcher\PROD\portal\plugins\configuration_12000.3.0\*.* C:\plm\tc12_4t\portal\plugins\configuration_12000.3.0
xcopy /s /y %CURRENT_DIR%switcher\PROD\OfficeClient\*.* C:\plm\tc12_4t\OfficeClient
call C:\plm\tc12_4t\portal\registry\genregxml.bat
echo Teamcenter Production (TC12) client enabled on %date% %time%>"%CURRENT_DIR%teamcenter_client_enabled.txt"
goto :EOF

:TEST
echo setting FMS_HOME...
setx FMS_HOME c:\plm\tc12_4t\tccs /m
echo copying files to Enable TEST client configuration...
xcopy /s /y %CURRENT_DIR%switcher\TEST\midtierservers\*.* C:\plm\tc12_4t\midtierservers
xcopy /s /y %CURRENT_DIR%switcher\TEST\portal\plugins\configuration_12000.3.0\*.* C:\plm\tc12_4t\portal\plugins\configuration_12000.3.0
xcopy /s /y %CURRENT_DIR%switcher\TEST\OfficeClient\*.* C:\plm\tc12_4t\OfficeClient
call C:\plm\tc12_4t\portal\registry\genregxml.bat
echo Teamcenter Test (TC12) client enabled on %date% %time%>"%CURRENT_DIR%teamcenter_client_enabled.txt"
goto :EOF

:TC11
echo setting FMS_HOME...
setx FMS_HOME c:\plm\tc112\tccs /m
echo Teamcenter 11 configuration enabled on %date% %time%>"%CURRENT_DIR%teamcenter_client_enabled.txt"
goto :EOF

:check_Permissions
echo Administrative permissions required. Detecting permissions...

net session >nul 2>&1
if %errorLevel% == 0 (
	echo Success: Administrative permissions confirmed.
	goto DECISION
) else (
	echo Failure: Current permissions inadequate. 
)

timeout 5
goto :EOF
