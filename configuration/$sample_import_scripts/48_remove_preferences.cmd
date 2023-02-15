@echo off

set FILENAME=%1
set SCOPE=%2
set TARGET=%3

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

if not exist "preferences\%FILENAME%.txt" (
    echo ERROR: File "preferences\%FILENAME%.txt" does not exist.
    goto :EOF
)

if x%SCOPE%==xSITE goto SITE_SCOPE_PROCESSING
if x%SCOPE%==xGROUP goto GROUP_SCOPE_PROCESSING
if x%SCOPE%==xROLE goto ROLE_SCOPE_PROCESSING
if x%SCOPE%==x goto SITE_SCOPE_PROCESSING

echo ERROR: Undefined processing scope %SCOPE%!
goto :EOF

:SITE_SCOPE_PROCESSING
REM Remove obsolete site preferences
echo.
echo preferences_manager %CREDENTIALS_TMP% -mode=remove -file="preferences\%FILENAME%.txt" -scope=SITE
preferences_manager %CREDENTIALS% -mode=remove -file="preferences\%FILENAME%.txt" -scope=SITE
echo.
goto :EOF

:GROUP_SCOPE_PROCESSING
REM Remove obsolete group preferences
if x%TARGET%==x (
    echo ERROR: Undefined processing target %TARGET%!
    goto :EOF
)

echo.
echo preferences_manager %CREDENTIALS_TMP% -mode=remove -file="preferences\%FILENAME%.txt" -scope=GROUP -target=%TARGET%
preferences_manager %CREDENTIALS% -mode=remove -file="preferences\%FILENAME%.txt" -scope=GROUP -target=%TARGET%
echo.
goto :EOF

:ROLE_SCOPE_PROCESSING
REM Remove obsolete group preferences
if x%TARGET%==x (
    echo ERROR: Undefined processing target %TARGET%!
    goto :EOF
)

echo.
echo preferences_manager %CREDENTIALS_TMP% -mode=remove -file="preferences\%FILENAME%.txt" -scope=ROLE -target=%TARGET%
preferences_manager %CREDENTIALS% -mode=remove -file="preferences\%FILENAME%.txt" -scope=ROLE -target=%TARGET%
echo.
goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
