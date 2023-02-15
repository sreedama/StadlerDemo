@echo off

if not defined TC_DATA goto ENV_MISSING
if x%SILENT_MODE%==xTRUE goto START_PROCESS

REM Ask for the TC_DATA if a different one wants to be used (e.g. 2-Tier / 4-Tier environment)
echo The following TC_DATA will be used: %TC_DATA%
echo Is this correct?
echo [Y] YES
echo [N] NO
echo.
choice /c:YN
echo.
if errorlevel 2 goto SET_TC_DATA

:START_PROCESS
echo Starting copy files to TC_DATA...
xcopy /s /y server\tc_data\common %TC_DATA%
echo.
exit /B %ERRORLEVEL%

goto :EOF

:SET_TC_DATA
set /P TC_DATA=Specify TC_DATA: 
if not exist %TC_DATA% (
    echo ERROR: The specified directory "%TC_DATA%" does not exist!
    goto :EOF
)
echo.
goto START_PROCESS

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
exit /B 0
