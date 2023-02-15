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

REM Update custom localization for TextServer.
echo.
xcopy /E localization "%TC_ROOT%"\lang\ /Y

echo.
echo -----------------------------------------------------------------------
echo START CACHE GENERATION
echo -----------------------------------------------------------------------
generate_client_meta_cache %CREDENTIALS% generate textservers
generate_metadata_cache %CREDENTIALS%	
echo -----------------------------------------------------------------------
echo FINISHED CACHE GENERATION
echo -----------------------------------------------------------------------
echo.

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment.
pause