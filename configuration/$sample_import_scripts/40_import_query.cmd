@echo off

set SUBFOLDER=%1
set QUERY=%2

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

REM Import Teamcenter Query
if not exist ..\logs\%COMPUTERNAME% mkdir ..\logs\%COMPUTERNAME%

if exist "queries\%SUBFOLDER%\%QUERY%.xml" (
    echo -----------------------------------------------------------------------
    echo plmxml_import %CREDENTIALS_TMP% -xml_file="queries\%SUBFOLDER%\%QUERY%.xml" -import_mode=overwrite -log="..\logs\%COMPUTERNAME%\%QUERY%.log"
    echo.
    plmxml_import %CREDENTIALS% -xml_file="queries\%SUBFOLDER%\%QUERY%.xml" -import_mode=overwrite -log="..\logs\%COMPUTERNAME%\%QUERY%.log"
    echo -----------------------------------------------------------------------
)

if not exist "queries\%SUBFOLDER%\%QUERY%.xml" echo ERROR: File "queries\%SUBFOLDER%\%QUERY%.xml" does not exist.
echo.

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
