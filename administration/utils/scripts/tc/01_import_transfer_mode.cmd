@echo off

if not defined TC_ROOT goto ENV_MISSING
if x%SILENT_MODE%==xTRUE goto START_PROCESS

echo Type in password of "infodba"
set /P DBAPASS=Password: 
set DBAPASS_TMP=******

echo.
echo Type in the file path to the TransferMode XML to get imported
set /P FILE_PATH=Path:%1

:START_PROCESS
REM Import tranfer mode for document migration
echo.
echo tcxml_import -u=infodba -p=%DBAPASS_TMP% -g=dba -file=%FILE_PATH% -scope_rules_mode=overwrite
tcxml_import -u=infodba -p=%DBAPASS% -g=dba -file=%FILE_PATH% -scope_rules_mode=overwrite

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
