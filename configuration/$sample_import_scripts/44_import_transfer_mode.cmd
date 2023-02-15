@echo off

set TRANSFERMODE=%1

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

REM Import tranfer mode for document migration
if exist "transfermodes\%TRANSFERMODE%.xml" (
    echo -----------------------------------------------------------------------
    echo tcxml_import %CREDENTIALS_TMP% -file=transfermodes\%TRANSFERMODE%.xml -scope_rules_mode=overwrite
    tcxml_import %CREDENTIALS% -file=transfermodes\%TRANSFERMODE%.xml -scope_rules_mode=overwrite
    echo -----------------------------------------------------------------------
)

REM move log files to log directory
if not exist ..\logs\%COMPUTERNAME% mkdir ..\logs\%COMPUTERNAME%

if exist "transfermodes\%TRANSFERMODE%.xml_validation.out" move "transfermodes\%TRANSFERMODE%.xml_validation.out" ..\logs\%COMPUTERNAME%\%TRANSFERMODE%.xml_validation.out
if exist "transfermodes\%TRANSFERMODE%.xml__importer.log" move "transfermodes\%TRANSFERMODE%.xml__importer.log" ..\logs\%COMPUTERNAME%\%TRANSFERMODE%.xml__importer.log
if exist "transfermodes\%TRANSFERMODE%.xml_failed_objects.xml" move "transfermodes\%TRANSFERMODE%.xml_failed_objects.xml" ..\logs\%COMPUTERNAME%\%TRANSFERMODE%.xml_failed_objects.xml

if not exist "transfermodes\%TRANSFERMODE%.xml" echo ERROR: File "transfermodes\%TRANSFERMODE%.xml" does not exist.
echo.

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
