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

REM Import revision rules
if not exist ..\logs\%COMPUTERNAME% mkdir ..\logs\%COMPUTERNAME%
echo.
echo plmxml_import %CREDENTIALS_TMP% -xml_file=revision_rules\tc_revision_rules.xml -import_mode=overwrite -log=..\logs\%COMPUTERNAME%\tc_revision_rules.log
plmxml_import %CREDENTIALS% -xml_file=revision_rules\tc_revision_rules.xml -import_mode=overwrite -log=..\logs\%COMPUTERNAME%\tc_revision_rules.log

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
