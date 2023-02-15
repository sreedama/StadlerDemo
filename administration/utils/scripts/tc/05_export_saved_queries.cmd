@echo off
if not defined TC_ROOT goto ENV_MISSING
setlocal
set CURRENT_DIR=%~dp0
set OUTFILE=%CURRENT_DIR%_savedQueries.xml
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
echo INFO: Exporting saved queries...
echo plmxml_export %CREDENTIALS_TMP% -imantypedef=ImanQuery -xml_file=%OUTFILE%
plmxml_export %CREDENTIALS% -imantypedef=ImanQuery -xml_file=%OUTFILE%

if %ERRORLEVEL%==0 (
    echo.
    echo INFO: Exported file to '%OUTFILE%'
)

endlocal

:FINISHED
goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
