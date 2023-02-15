@echo off

if not defined TC_ROOT goto ENV_MISSING
if x%1==x goto HELP

if not exist "%1" (
	echo ERROR: File "%1" does not exist.
	goto :EOF
)

setlocal
set CURRENT_DIR=%~dp0
set DBAPASS_TMP=******

echo Type in password of "infodba"
set /P DBAPASS=Password: 

cd /D "%~dp1"

echo bmide_manage_batch_lovs.bat -u=infodba -p=%DBAPASS_TMP% -g=dba -option=update -file=%1
echo.
bmide_manage_batch_lovs.bat -u=infodba -p=%DBAPASS% -g=dba -option=update -file=%1

cd /D "%CURRENT_DIR%"
endlocal

goto :EOF

:ENV_MISSING
echo ERROR: You need to run this script in a Teamcenter environment
goto :EOF

:HELP
echo USAGE:
echo    manage_batch_lovs.cmd [FULL PATH TO XML]
echo        The path specified has to include the XML file name. The lang folder 
echo		in the same directory has to contain the localization  
