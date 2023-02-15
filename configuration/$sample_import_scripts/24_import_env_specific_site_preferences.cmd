@echo off

if not defined TC_ROOT goto ENV_MISSING
if x%SILENT_MODE%==xTRUE goto START_PROCESS

echo The currently selected environment is with computer name %COMPUTERNAME%. Please make sure a preference file for this host name exists. Does it exist?
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

if not exist "preferences\site_preferences_%COMPUTERNAME%.xml" goto FILE_NOT_FOUND

REM Import site specific site preferences for the current COMPUTERNAME
echo.
echo preferences_manager %CREDENTIALS_TMP% -mode=import -file=preferences\site_preferences_%COMPUTERNAME%.xml -scope=SITE -action=OVERRIDE
preferences_manager %CREDENTIALS% -mode=import -file=preferences\site_preferences_%COMPUTERNAME%.xml -scope=SITE -action=OVERRIDE

REM Set system environment variable based on current environment COMPUTERNAME, please adjust the list below. The variable can be used in active workspace to show the environment (custom extension required for this). If not implemented the following section can be commented out.
set ENV_NAME=%CUSTOMERNAME_CURRENT_RELEASE_CANDIDATE%
if x%COMPUTERNAME%==xEC2AMAZ-DO3AO9T set ENV_NAME=LMtec Cloud with %CUSTOMERNAME_CURRENT_RELEASE_CANDIDATE%
if x%COMPUTERNAME%==x2141AS0070PLM03 set ENV_NAME=Legacy Test with %CUSTOMERNAME_CURRENT_RELEASE_CANDIDATE%
if x%COMPUTERNAME%==x2344AS0070PLM04 set ENV_NAME=Test with %CUSTOMERNAME_CURRENT_RELEASE_CANDIDATE%
if x%COMPUTERNAME%==x2344AS0070PLM01 set ENV_NAME=Production with %CUSTOMERNAME_CURRENT_RELEASE_CANDIDATE%
setx AWC_built_update_in_UI "%ENV_NAME%" /m

goto :EOF

:FILE_NOT_FOUND
echo ERROR: environment specific preference file "site_preferences_%COMPUTERNAME%.xml" not found in sub directory "preferences"

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
