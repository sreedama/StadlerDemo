@echo off

set QUERY_DISPLAY_NAME=%1
set QUERY_FILE_NAME=%2
if not defined QUERY_DISPLAY_NAME goto ASK_QUERY_NAME
if not defined QUERY_FILE_NAME goto ASK_QUERY_NAME
if not defined TC_ROOT goto ENV_MISSING
if x%SILENT_MODE%==xTRUE goto START_PROCESS

:SET_CREDENTIALS
echo Type in password of "infodba"
set /P DBAPASS=Password: 
set DBAPASS_TMP=******

:START_PROCESS
REM Import Teamcenter Query
if not exist ..\logs\%COMPUTERNAME% mkdir ..\logs\%COMPUTERNAME%

echo -----------------------------------------------------------------------
echo tc_set_query_where_run -u=infodba -p=%DBAPASS_TMP% -g=dba -query=%QUERY_DISPLAY_NAME% -run=iman
echo.
tc_set_query_where_run -u=infodba -p=%DBAPASS% -g=dba -query=%QUERY_DISPLAY_NAME% -run=iman
echo -----------------------------------------------------------------------
echo plmxml_import -u=infodba -p=%DBAPASS_TMP% -g=dba -xml_file="queries\user_queries\%QUERY_FILE_NAME%" -import_mode=overwrite -log="..\logs\%COMPUTERNAME%\%QUERY_FILE_NAME%.log"
echo.
plmxml_import -u=infodba -p=%DBAPASS% -g=dba -xml_file="queries\user_queries\%QUERY_FILE_NAME%" -import_mode=overwrite -log="..\logs\%COMPUTERNAME%\%QUERY_FILE_NAME%.log"
echo -----------------------------------------------------------------------
echo tc_set_query_where_run -u=infodba -p=%DBAPASS_TMP% -g=dba -query=%QUERY_DISPLAY_NAME% -run=query
echo.
tc_set_query_where_run -u=infodba -p=%DBAPASS% -g=dba -query=%QUERY_DISPLAY_NAME% -run=query
echo -----------------------------------------------------------------------

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment

:ASK_QUERY_NAME
echo Please specify the user query to import
set /p QUERY_DISPLAY_NAME="Enter the user query display name:"
set /p QUERY_FILE_NAME="Enter the user query file name:"
goto SET_CREDENTIALS