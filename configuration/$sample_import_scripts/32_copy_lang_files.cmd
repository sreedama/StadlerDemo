@echo off

if not defined TC_ROOT goto ENV_MISSING
if x%SILENT_MODE%==xTRUE goto START_PROCESS
if defined TC_USER_MSG_ROOT goto START_PROCESS

REM Ask for the TC_ROOT if a different one wants to be used (e.g. 2-Tier / 4-Tier environment)
echo The following TC_ROOT will be used: %TC_ROOT%
echo Is this correct?
echo [Y] YES
echo [N] NO
echo.
choice /c:YN
echo.
if errorlevel 2 goto SET_TC_ROOT

:START_PROCESS
set TARGET_DIR=%TC_ROOT%\lang\textserver
if defined TC_USER_MSG_ROOT set TARGET_DIR=%TC_USER_MSG_ROOT%

echo Starting copy files to %TARGET_DIR%...
xcopy /s /y server\tc_root\common\lang\textserver %TARGET_DIR%
echo.
exit /B %ERRORLEVEL%

goto :EOF

:SET_TC_ROOT
set /P TC_ROOT=Specify TC_ROOT: 
if not exist %TC_ROOT% (
    echo ERROR: The specified directory "%TC_ROOT%" does not exist!
    goto :EOF
)
echo.
goto START_PROCESS

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
exit /B 0
