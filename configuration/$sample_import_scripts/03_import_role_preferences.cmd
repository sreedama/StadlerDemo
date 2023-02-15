@echo off

set ROLE=%1
REM ROLE_WITH_SPACES is optional, if not used the value of ROLE is used instead
set ROLE_WITH_SPACES=%2

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

set TC_ROLE=%ROLE_WITH_SPACES%
if x%ROLE_WITH_SPACES%==x set TC_ROLE=%ROLE%

REM Import Teamcenter role preferences
echo.
echo preferences_manager %CREDENTIALS_TMP% -mode=import -file=preferences\role_preferences_%ROLE%.xml -scope=ROLE -target=%TC_ROLE% -action=OVERRIDE
preferences_manager %CREDENTIALS% -mode=import -file=preferences\role_preferences_%ROLE%.xml -scope=ROLE -target=%TC_ROLE% -action=OVERRIDE

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
