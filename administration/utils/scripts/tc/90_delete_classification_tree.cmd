@echo off
if not defined TC_ROOT goto ENV_MISSING

setlocal

echo Type in password of "infodba"
set /P DBAPASS=Password: 

:START_PROCESS

echo.
echo WARNING: all classification data and the classes are getting deleted, press any key to continue

pause

smlutility -delete infodba %DBAPASS% dba -class -id=ICM01 -recurse –icos

smlutility -delete infodba %DBAPASS% dba -class -id=ICM02 -recurse –icos

echo.
echo WARNING: all custom classification attributes that are not referenced are going to get deleted, press any key to continue

pause

smlutility -delete infodba %DBAPASS% dba attribute -id=*

echo.
echo WARNING: all custom classification key lovs that are not referenced are going to get deleted, press any key to continue

pause

smlutility -delete infodba %DBAPASS% dba keylov -id=*

endlocal
:FINISHED
goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
