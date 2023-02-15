@echo off

set TILE_MODE=%1
set TILE_FILENAME=%2
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

REM Import AWC UI Table Configuration

echo aws2_install_tilecollections.exe %CREDENTIALS% -mode=%TILE_MODE% -file=aw_tile_collections\%TILE_FILENAME%.xml


aws2_install_tilecollections.exe %CREDENTIALS% -mode=%TILE_MODE% -file=aw_tile_collections\%TILE_FILENAME%.xml
goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment