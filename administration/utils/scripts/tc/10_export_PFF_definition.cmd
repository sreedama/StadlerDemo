@echo off

if not defined TC_ROOT goto ENV_MISSING
if defined UPG_CREDENTIALS goto START_PROCESS

:ASK_CREDENTIALS
echo Type in password of "infodba"
set /P DBAPASS=Password: 

:START_PROCESS
set CREDENTIALS=-u=infodba -p=%DBAPASS% -g=dba
set CREDENTIALS_TMP=-u=infodba -p=****** -g=dba
if defined UPG_CREDENTIALS set CREDENTIALS=%UPG_CREDENTIALS%
if defined UPG_CREDENTIALS_TMP set CREDENTIALS_TMP=%UPG_CREDENTIALS_TMP%

REM Export all PFF definitions to check for the desired UID
echo.

echo tcxml_export %CREDENTIALS_TMP% -class=ImanPFF -transfermode=ASP_ExportPFF -file=%temp%\AllPFFs.xml
tcxml_export %CREDENTIALS% -class=ImanPFF -transfermode=ASP_ExportPFF -file=%temp%\AllPFFs.xml

echo.
echo Check the file AllPFFs.xml for the desired uid to get exported. Look for the label value of the respective GSIdentity tag.
echo Type in GSIdentity "label" id of TransferMode to be exported
set /P TM_UID=UID:%1

REM Export specific PFF definition
echo.

echo tcxml_export %CREDENTIALS_TMP% -transfermode=ASP_ExportPFF -file=%temp%\myPFF.xml -uid=%TM_UID%
tcxml_export %CREDENTIALS% -transfermode=ASP_ExportPFF -file=%temp%\myPFF.xml -uid=%TM_UID%

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
