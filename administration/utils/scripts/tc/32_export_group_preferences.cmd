@echo off
setlocal
set CURRENT_DIR=%~dp0
set DBAPASS_TMP=******
if not defined TC_ROOT goto ENV_MISSING
if not x%1==x set TARGET_GROUP=%1
if not x%2==x set ACTION_STRING=_%2
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

if not x%1==x goto AUTO_MODE

:INTERACTIVE_MODE
echo.
echo Type target group name to export
set /P TARGET_GROUP=Group: 
set OUTFILE=%CURRENT_DIR%%TARGET_GROUP%_preferences.xml

echo.
echo INFO: Exporting group preferences of '%TARGET_GROUP%'...
echo preferences_manager %CREDENTIALS_TMP% -mode=export -scope=GROUP -target=%TARGET_GROUP% -out_file=%OUTFILE%
preferences_manager %CREDENTIALS% -mode=export -scope=GROUP -target=%TARGET_GROUP% -out_file=%OUTFILE%

if %ERRORLEVEL%==0 (
    echo.
    echo INFO: Exported file to '%OUTFILE%'
)

endlocal
goto :EOF

:AUTO_MODE
REM use LOG_DIR1 if executed withing Preferences folder
set LOG_DIR1=..\..\..\..\logs\%COMPUTERNAME%
REM use LOG_DIR2 if executed from root directory
set LOG_DIR2=logs\%COMPUTERNAME%
set OUTFILE=group_preferences_backup_%TARGET_GROUP%_%random%%ACTION_STRING%.xml
if exist %LOG_DIR1% set OUTFILE=%LOG_DIR1%\group_preferences_backup_%TARGET_GROUP%_%random%%ACTION_STRING%.xml
if exist %LOG_DIR2% set OUTFILE=%LOG_DIR2%\group_preferences_backup_%TARGET_GROUP%_%random%%ACTION_STRING%.xml

REM Export Teamcenter site preferences
echo.
echo preferences_manager %CREDENTIALS_TMP% -mode=export -scope=GROUP -target=%TARGET_GROUP% -out_file=%OUTFILE%
preferences_manager %CREDENTIALS% -mode=export -scope=GROUP -target=%TARGET_GROUP% -out_file=%OUTFILE%

endlocal
goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
