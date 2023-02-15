@echo off

if not defined TC_ROOT goto ENV_MISSING
if x%SILENT_MODE%==xTRUE goto START_PROCESS

echo Type in password of "infodba"
set /P DBAPASS=Password: 
set DBAPASS_TMP=******

:START_PROCESS
REM Update attribute mappings
echo.
echo. import_attr_mappings -u=infodba -p=%DBAPASS_TMP% -g=dba -file=attribute_mapping\dataset_attribute_mappings.txt
import_attr_mappings -u=infodba -p=%DBAPASS% -g=dba -file=attribute_mapping\dataset_attribute_mappings.txt

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
