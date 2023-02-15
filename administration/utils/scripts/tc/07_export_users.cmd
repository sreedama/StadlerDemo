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

REM Export Organisation Tree with users
echo.
echo dsa_util %CREDENTIALS_TMP% -class=User -f=export -filename=organisation_with_users.xml
dsa_util %CREDENTIALS% -class=User -f=export -filename=organisation_with_users.xml

echo.
echo IMPORTANT: Please remove the site information before importing the file on another site (DSA_export_site). Usually line 6 to 8 in XML file.

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
