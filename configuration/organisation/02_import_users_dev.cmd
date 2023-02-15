@echo off

cd /D "%~dp0"

if not defined TC_ROOT goto ENV_MISSING
if x%SILENT_MODE%==xTRUE goto START_PROCESS

echo Type in password of "infodba"
set /P DBAPASS=Password: 
set DBAPASS_TMP=******
cls

:START_PROCESS
REM Import organizational structure
echo Creating/updating users.
echo.

make_user.exe -u=infodba -p=%DBAPASS% -g=dba -file=organization_users_dev.lst

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment