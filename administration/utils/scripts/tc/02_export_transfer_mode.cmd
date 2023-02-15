@echo off

if not defined TC_ROOT goto ENV_MISSING

echo Type in password of "infodba"
set /P DBAPASS=Password: 
set DBAPASS_TMP=******

:START_PROCESS
REM Export all tranfer modes to check for the desired UID
echo.
echo tcxml_export -u=infodba -p=%DBAPASS_TMP% -g=dba  -class=TransferMode -file=%temp%\AllTransferModes.xml
tcxml_export -u=infodba -p=%DBAPASS% -g=dba  -class=TransferMode -file=%temp%\AllTransferModes.xml

echo.
echo Check the file AllTransferModes.xml for the desired uid to get exported. Look for the label value of the respective GSIdentity tag.
echo Type in GSIdentity "label" id of TransferMode to be exported
set /P TM_UID=UID:%1

REM Export specific tranfer mode
echo.
echo tcxml_export -u=infodba -p=%DBAPASS_TMP% -g=dba -file=%temp%\myTransferMode.xml -uid=%TM_UID%
tcxml_export -u=infodba -p=%DBAPASS% -g=dba -file=%temp%\myTransferMode.xml -uid=%TM_UID%

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
