@echo off

set FILENAME=%1

if not defined TC_ROOT goto ENV_MISSING
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

if not exist "Preferences\%FILENAME%.txt" (
    echo ERROR: File "Preferences\%FILENAME%.txt" does not exist.
    goto :EOF
)

REM Delete obsolete preference definitions
echo.
echo preferences_manager %CREDENTIALS_TMP% -mode=delete -file="Preferences\%FILENAME%.txt"
preferences_manager %CREDENTIALS% -mode=delete -file="Preferences\%FILENAME%.txt"
echo.
goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
