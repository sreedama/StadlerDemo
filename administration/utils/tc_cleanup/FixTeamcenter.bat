REM Make sure you installed gli_kill_installer.exe once before running this script!
set TEAMCENTER_VERSION=V10000.1.0.61_30_20160802.00
set FSC_SERVICE_NAME=Teamcenter FSC Service FSC_DEUSRV01_Administrator
set SERVER_MANAGER_SERVICE_NAME=Teamcenter Server Manager TC10_PoolA

:STOP
:: net stop "Teamcenter Dispatcher Module %TEAMCENTER_VERSION%"
:: net stop "Teamcenter Dispatcher Scheduler %TEAMCENTER_VERSION%"
:: net stop "taskmonitor"
:: net stop "actionmgrd"
:: net stop "subscripmgrd"
net stop "%SERVER_MANAGER_SERVICE_NAME%"

REM stop fcc client process if necessary
%FMS_HOME%\bin\fccstat -kill

net stop "%FSC_SERVICE_NAME%"

REM use "kill" command if utility gli_kill_installer has been installed
::kill java.exe
REM otherwise you can use the three commands below
TASKKILL /F /IM tcserver.exe
TASKKILL /F /IM java.exe
TASKKILL /F /IM Teamcenter.exe

:CLEANUP
del /F/Q/S %temp%
del /F/Q/S C:\temp
if exist "%temp%"\%TEAMCENTER_VERSION% rmdir/S/Q  "%temp%"\%TEAMCENTER_VERSION%
if exist "%USERPROFILE%\FSCCache" rmdir/S/Q  %USERPROFILE%\FSCCache
if exist "%USERPROFILE%\FCCCache" rmdir/S/Q  %USERPROFILE%\FCCCache
if exist "%USERPROFILE%\Siemens" rmdir/S/Q  %USERPROFILE%\Siemens
if exist "%USERPROFILE%\Teamcenter" rmdir/S/Q  %USERPROFILE%\Teamcenter

net start "%FSC_SERVICE_NAME%"

if x%1==x goto RESTART
echo.
echo Services have been stopped and temporary files are removed. Click any key to re-start the services
pause

:RESTART
net start "%SERVER_MANAGER_SERVICE_NAME%"
:: net start "taskmonitor"
:: net start "subscripmgrd"
:: net start "actionmgrd"
:: net start "Teamcenter Dispatcher Scheduler %TEAMCENTER_VERSION%"
:: net start "Teamcenter Dispatcher Module %TEAMCENTER_VERSION%"

REM the following section can be used to re-start the vis poolmanager and call net assigner URL (esp. with <=AWC 4.2)
REM call %TC_ROOT%\vispoolmanager\run_visservermgr.cmd
REM echo Waiting for 20 seconds to launch the Net Assigner URL
REM timeout 20 >nul
REM start iexplore.exe http://server:8002/net_assigner/
