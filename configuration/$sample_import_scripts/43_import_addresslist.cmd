@echo off

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

set LIST_NAME=%1
set LIST_FNAME=address_lists\%LIST_NAME%.txt

:CHECK_FNAME
if exist %LIST_FNAME% goto IMPORT

if not exist %LIST_FNAME% (
    echo Addresslist "%LIST_FNAME%" does not exist.
    echo Specify the full path for the addresslist import file.
    set /P LIST_FNAME=Path: 
	
    echo Specify the addresslist name in Teamcenter.
    set /P LIST_NAME=Adresslist name:     
)
goto CHECK_FNAME

:IMPORT
REM Import Addresslist
echo.
echo convert_distribution_lists %CREDENTIALS_TMP% -import=%LIST_FNAME% -new_list_name=%LIST_NAME% -overwrite
convert_distribution_lists %CREDENTIALS% -import=%LIST_FNAME% -new_list_name=%LIST_NAME% -overwrite

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
