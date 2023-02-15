@echo off

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

REM Import Teamcenter site preferences
echo.
echo preferences_manager %CREDENTIALS_TMP% -mode=import -file=preferences\site_preferences.xml -scope=SITE -action=OVERRIDE
preferences_manager %CREDENTIALS% -mode=import -file=preferences\site_preferences.xml -scope=SITE -action=OVERRIDE

REM Import Teamcenter Catia site preferences
echo.
echo preferences_manager %CREDENTIALS_TMP% -mode=import -file=preferences\site_preferences_Integration.Catia_STR.xml -scope=SITE -action=OVERRIDE
preferences_manager %CREDENTIALS% -mode=import -file=preferences\site_preferences_Integration.Catia_STR.xml -scope=SITE -action=OVERRIDE

REM Import Change Management site preferences
echo.
echo preferences_manager %CREDENTIALS_TMP% -mode=import -file=preferences\site_preferences_changemanagement.xml -scope=SITE -action=OVERRIDE
preferences_manager %CREDENTIALS% -mode=import -file=preferences\site_preferences_changemanagement.xml -scope=SITE -action=OVERRIDE

REM Import stylesheets site preferences
echo.
echo preferences_manager %CREDENTIALS_TMP% -mode=import -file=preferences\site_preferences_stylesheets.xml -scope=SITE -action=OVERRIDE
preferences_manager %CREDENTIALS% -mode=import -file=preferences\site_preferences_stylesheets.xml -scope=SITE -action=OVERRIDE

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
