@echo off
if not defined TC_ROOT goto ENV_MISSING

setlocal

echo Type in password of "infodba"
set /P DBAPASS=Password: 

echo Type target user name
set /P TARGET_USER=User: 

:START_PROCESS
set OUTPUT_FILE=%TEMP%\%TARGET_USER%_user_preferences.xml
if defined TC_TMP_DIR set OUTPUT_FILE=%TC_TMP_DIR%\%TARGET_USER%_user_preferences.xml

echo INFO: Exporting user preferences of '%TARGET_USER%'...
preferences_manager -u=infodba -p=%DBAPASS% -g=dba -mode=export -scope=USER -target=%TARGET_USER% -out_file=%OUTPUT_FILE%

echo.
echo INFO: Clearing user preferences of '%TARGET_USER%'...
preferences_manager -u=infodba -p=%DBAPASS% -g=dba -mode=clear -scope=USER -target=%TARGET_USER%

endlocal
:FINISHED
goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
