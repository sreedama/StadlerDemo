@echo off

set GROUP=dba

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

REM Import Teamcenter T4x preferences
echo.
echo preferences_manager %CREDENTIALS_TMP% -mode=import -file=t4x\preferences\site_preferences_t4x.xml -scope=SITE -action=OVERRIDE
echo preferences_manager %CREDENTIALS_TMP% -mode=import -file=t4x\preferences\site_preferences_t4st.xml -scope=SITE -action=OVERRIDE
preferences_manager %CREDENTIALS% -mode=import -file=t4x\preferences\site_preferences_t4x.xml -scope=SITE -action=OVERRIDE
preferences_manager %CREDENTIALS% -mode=import -file=t4x\preferences\site_preferences_t4st.xml -scope=SITE -action=OVERRIDE

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
