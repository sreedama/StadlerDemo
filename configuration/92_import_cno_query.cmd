@echo off

if not defined TC_ROOT goto ENV_MISSING
if x%SILENT_MODE%==xTRUE goto START_PROCESS

echo Type in password of "infodba"
set /P DBAPASS=Password: 
set DBAPASS_TMP=******

:START_PROCESS
REM Import CNO VFW Query
if not exist ..\logs\%COMPUTERNAME% mkdir ..\logs\%COMPUTERNAME%

for %%f in (queries\CNO_VFW\*.xml) do (
    echo -----------------------------------------------------------------------
    echo plmxml_import -u=infodba -p=%DBAPASS_TMP% -g=dba -xml_file="%%f" -import_mode=overwrite -log="..\logs\%COMPUTERNAME%\%%f.log"
    echo.
    plmxml_import -u=infodba -p=%DBAPASS% -g=dba -xml_file="%%f" -import_mode=overwrite -log="..\logs\%COMPUTERNAME%\%%f.log"
    echo -----------------------------------------------------------------------
)
goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment