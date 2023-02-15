@echo off

if not defined TC_ROOT goto ENV_MISSING
if x%SILENT_MODE%==xTRUE goto START_PROCESS

echo Type in password of "infodba"
set /P DBAPASS=Password: 
set DBAPASS_TMP=******

:START_PROCESS
REM Import seedparts


set UGII_TEMPLATE_DIR=%UGII_BASE_DIR%\UGII\templates
if not defined UGII_TMP_DIR set UGII_TMP_DIR=%temp%
if defined TC_TMP_DIR set UGII_TMP_DIR=%TC_TMP_DIR%
set THISDRIVE=%~d0
set THISPATH=%~p0
set THISDIR=%THISDRIVE%%THISPATH%
cd /d "%THISDIR%"

set UGII_KEEP_SYSTEM_LOG=true
set IMAN_KEEP_SYSTEM_LOG=true

Set BYPASS_RULES=ON
Set NR_BYPASS=ON
Set BMF_BYPASS_ALL_EXTENSION_RULES=ON
Set TC_BYPASS_CANNED_METHODS=ALL
Set IMAN_BYPASS_CANNED_METHODS=ALL
Set AM_BYPASS=ON

echo STEP 1: copy PAX and image files...
copy /y %THISDIR%*.jpg %UGII_TEMPLATE_DIR%
copy /y %THISDIR%*.pax %UGII_TEMPLATE_DIR%
echo.

:: Seedparts
FOR %%i in ("%THISDIR%*.prt") DO call :IMPORT_PART %%i

:IMPORT_PART
set CURRENT_PART_FILE=%1

echo STEP 2: seedpart import ...
echo %UGII_BASE_DIR%\UGMANAGER\ug_import -u=infodba -p=%DBAPASS_TMP% -g=dba -part=%CURRENT_PART_FILE% -mapping=%THISDIR%seedpart_mapping.txt
echo.
call %UGII_BASE_DIR%\UGMANAGER\ug_import -u=infodba -p=%DBAPASS% -g=dba -part=%CURRENT_PART_FILE% -mapping=%THISDIR%seedpart_mapping.txt

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
