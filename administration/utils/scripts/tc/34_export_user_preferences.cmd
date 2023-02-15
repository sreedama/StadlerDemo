@echo off
if not defined TC_ROOT goto ENV_MISSING

setlocal
set CURRENT_DIR=%~dp0

echo Type in password of "infodba"
set /P DBAPASS=Password: 

echo Type target user name to export
set /P TARGET_USER=User: 
set OUTFILE=%CURRENT_DIR%%TARGET_USER%_preferences.xml

:START_PROCESS
echo.
echo INFO: Exporting user preferences of '%TARGET_USER%'...
preferences_manager -u=infodba -p=%DBAPASS% -g=dba -mode=export -scope=USER -target=%TARGET_USER% -out_file=%OUTFILE%

if %ERRORLEVEL%==0 (
    echo.
    echo INFO: Exported file to '%OUTFILE%'
)

endlocal

:FINISHED
goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
