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

REM Update Teamcenter Organisation
echo.
echo dsa_util %CREDENTIALS_TMP% -f=import -filename=bmide\cmi4template\install\conmet_organisation.xml
dsa_util %CREDENTIALS% -f=import -filename=bmide\cmi4template\install\conmet_organisation.xml

REM echo admin_data_import -u=infodba -p=%DBAPASS_TMP% -g=dba -adminDataTypes=Organization -inputPackage=\organisation\tc_organisation.zip
REM admin_data_import -u=infodba -p=%DBAPASS% -g=dba -adminDataTypes=Organization -inputPackage=organisation\tc_organisation.zip

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
