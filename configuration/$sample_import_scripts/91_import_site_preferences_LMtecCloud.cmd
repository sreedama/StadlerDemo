@echo off

if not defined TC_ROOT goto ENV_MISSING
if x%SILENT_MODE%==xTRUE goto START_PROCESS

echo The currently selected environment is LMtec Cloud, is this correct?
set /P USER_ANSWER=(Y)es or (N)o:
if /I "%USER_ANSWER%"=="Y" goto ASK_CREDENTIALS
if /I "%USER_ANSWER%"=="N" goto :EOF

:ASK_CREDENTIALS
if defined UPG_CREDENTIALS goto START_PROCESS
echo Specify full path to password file of "infodba" user
set /P PWD_FILE_PATH=Path: 

if exist %PWD_FILE_PATH% set UPG_CREDENTIALS_TMP=-u=infodba -pf=%PWD_FILE_PATH% -g=dba
if exist %PWD_FILE_PATH% set UPG_CREDENTIALS=-u=infodba -pf=%PWD_FILE_PATH% -g=dba
if exist %PWD_FILE_PATH% goto START_PROCESS

echo.
echo Provided password file %PWD_FILE_PATH% does not exist!
echo Type in password of "infodba"
set /P DBAPASS=Password: 
set CREDENTIALS=-u=infodba -p=%DBAPASS% -g=dba
set CREDENTIALS_TMP=-u=infodba -p=****** -g=dba

:START_PROCESS
if defined UPG_CREDENTIALS set CREDENTIALS=%UPG_CREDENTIALS%
if defined UPG_CREDENTIALS_TMP set CREDENTIALS_TMP=%UPG_CREDENTIALS_TMP%

REM Import Teamcenter site preferences
echo.
echo preferences_manager %CREDENTIALS_TMP% -mode=import -file=preferences\site_preferences_LMtecCloud.xml -scope=SITE -action=OVERRIDE
preferences_manager %CREDENTIALS% -mode=import -file=preferences\site_preferences_LMtecCloud.xml -scope=SITE -action=OVERRIDE

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
