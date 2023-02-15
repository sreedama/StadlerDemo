@echo off
if not defined TC_ROOT goto ENV_MISSING
setlocal
set CURRENT_DIR=%~dp0
set template_file=%1
set OUTFILE=%CURRENT_DIR%_exportedWorkflows.xml
if defined UPG_CREDENTIALS goto START_PROCESS

:ASK_CREDENTIALS
echo Type in password of "infodba"
set /P DBAPASS=Password: 

:START_PROCESS
set CREDENTIALS=-u=infodba -p=%DBAPASS% -g=dba
set CREDENTIALS_TMP=-u=infodba -p=****** -g=dba
if defined UPG_CREDENTIALS set CREDENTIALS=%UPG_CREDENTIALS%
if defined UPG_CREDENTIALS_TMP set CREDENTIALS_TMP=%UPG_CREDENTIALS_TMP%

echo.
echo INFO: Exporting workflows...
for /F "tokens=*" %%i in (%template_file%) do (
    echo plmxml_export %CREDENTIALS_TMP% -xml_file=%%i.xml -template=%%i -transfermode=workflow_template_mode
    plmxml_export %CREDENTIALS% -xml_file=%%i.xml -template=%%i -transfermode=workflow_template_mode
)

if %ERRORLEVEL%==0 (
    echo.
    echo INFO: Exported file to '%OUTFILE%'
)

endlocal

:FINISHED
goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
