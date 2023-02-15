@echo off

cd /D "%~dp0"

if not defined TC_ROOT goto ENV_MISSING
if x%SILENT_MODE%==xTRUE goto START_PROCESS

echo Type in password of "infodba"
set /P DBAPASS=Password: 
set DBAPASS_TMP=******
cls

:START_PROCESS

REM create R&D project
echo Create R&D project
echo create_project -u=infodba -p=%DBPASS_TMP% -g=dba -id=RD -name=”R&D” -desc=”Secure project for R&D. Only project members have access to the data created in this projects context" -status=A -teams=”R&D”~*~* -privileged=”R&D”~*~*
create_project -u=infodba -p=infodba -g=dba -id="RD" -name=”R&D” -desc=”Secure project for R&D. Only project members have access to the data created in this projects context" -status=A -teams=”R&D”~*~* -privileged=”R&D”~*~*

REM create Bid Packaging project
echo Create Bid Packaging project
echo create_project -u=infodba -p=%DBPASS_TMP% -g=dba -id=BID -name=”Bid Packaging” -desc=”Secure project for Bid Packaging. Only project members have access to the data created in this projects context" -status=A -teams=”Bid Packaging”~*~* -privileged=”Bid Packaging”~*~*
create_project -u=infodba -p=%DBPASS% -g=dba -id="BID" -name=”Bid Packaging” -desc=”Secure project for Bid Packaging. Only project members have access to the data created in this projects context" -status=A -teams=”Bid Packaging”~*~* -privileged=”Bid Packaging”~*~*

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment