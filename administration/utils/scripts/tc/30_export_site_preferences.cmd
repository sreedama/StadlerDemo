@echo off
setlocal
if not defined TC_ROOT goto ENV_MISSING
if not x%1==x set ACTION_STRING=_%1
if x%SILENT_MODE%==xTRUE goto START_PROCESS
if defined UPG_CREDENTIALS goto START_PROCESS

:ASK_CREDENTIALS
echo Type in password of "infodba"
set /P DBAPASS=Password: 

:START_PROCESS
set CREDENTIALS=-u=infodba -p=%DBAPASS% -g=dba
set CREDENTIALS_TMP=-u=infodba -p=****** -g=dba
if defined UPG_CREDENTIALS set CREDENTIALS=%UPG_CREDENTIALS%
if defined UPG_CREDENTIALS_TMP set CREDENTIALS_TMP=%UPG_CREDENTIALS_TMP%

REM use LOG_DIR1 if executed withing Preferences folder
set LOG_DIR1=..\..\..\..\logs\%COMPUTERNAME%
REM use LOG_DIR2 if executed from root directory
set LOG_DIR2=logs\%COMPUTERNAME%
set OUTFILE=site_preferences_backup_%random%%ACTION_STRING%.xml
if exist %LOG_DIR1% set OUTFILE=%LOG_DIR1%\site_preferences_backup_%random%%ACTION_STRING%.xml
if exist %LOG_DIR2% set OUTFILE=%LOG_DIR2%\site_preferences_backup_%random%%ACTION_STRING%.xml

REM Export Teamcenter site preferences
echo.
echo preferences_manager %CREDENTIALS_TMP% -mode=export -out_file=%OUTFILE% -scope=SITE
preferences_manager %CREDENTIALS% -mode=export -out_file=%OUTFILE% -scope=SITE

endlocal

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
