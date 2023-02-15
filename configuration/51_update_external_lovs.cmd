@echo off

set MAX_STEPS=90
if not x%1==x set LOV_NAME=%1
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

if not x%LOV_NAME%==x goto SINGLE_UPDATE

REM cycle through all sub-directories of directory external_lovs
for /d %%G in ("external_lovs\*") do (
REM %%~nG extracts the basename from G=external_lovs\basename
echo bmide_manage_batch_lovs.bat %CREDENTIALS_TMP% -option=update -file=external_lovs\%%~nG\%%~nG.xml
call bmide_manage_batch_lovs.bat %CREDENTIALS% -option=update -file=external_lovs\%%~nG\%%~nG.xml
REM pause
)
goto :EOF

:SINGLE_UPDATE
echo.
echo bmide_manage_batch_lovs.bat %CREDENTIALS_TMP% -option=update -file=external_lovs\%LOV_NAME%\%LOV_NAME%.xml
call bmide_manage_batch_lovs.bat %CREDENTIALS% -option=update -file=external_lovs\%LOV_NAME%\%LOV_NAME%.xml

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
