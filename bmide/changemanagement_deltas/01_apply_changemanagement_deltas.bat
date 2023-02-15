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

REM Apply bmide deltas for change management
echo business_model_updater.exe %CREDENTIALS_TMP% -mode=upgrade -update=all -process=all -file="changemanagement_deltas.xml" -predelta -nolocalization
echo.
business_model_updater.exe %CREDENTIALS% -mode=upgrade -update=all -process=all -file="changemanagement_deltas.xml" -predelta -nolocalization

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment