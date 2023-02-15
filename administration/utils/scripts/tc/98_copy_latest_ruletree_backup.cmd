@echo off

if not defined TC_ROOT goto ENV_MISSING

setlocal

:START_PROCESS
set CURRENT_DIR=%~dp0
cd /D %CURRENT_DIR%
REM use LOG_DIR1 if executed withing Preferences folder
set LOG_DIR1=..\..\..\..\logs\%COMPUTERNAME%
REM use LOG_DIR2 if executed from root directory
set LOG_DIR2=logs\%COMPUTERNAME%
REM use %TEMP% per default
set LOG_DIR=%TEMP%
if exist %LOG_DIR1% set LOG_DIR=%LOG_DIR1%
if exist %LOG_DIR2% set LOG_DIR=%LOG_DIR2%

:COPY LATEST FILES
echo.
cd /D %TC_DATA%\am
for /f "delims=" %%x in ('dir /od /a-d /b *.*') do set recent=%%x
echo Trying to copy recent file [%recent%] to log directory [%LOG_DIR%]...
cd /D %CURRENT_DIR%
xcopy /s /y %TC_DATA%\am\%recent%* %LOG_DIR%

endlocal
goto :EOF


:FETCH CURRENT DATE SETTINGS
for /F "usebackq tokens=1,2 delims==" %%i in (`wmic os get LocalDateTime /VALUE 2^>NUL`) do if '.%%i.'=='.LocalDateTime.' set ldt=%%j 
(
    REM set ldt=%ldt:~0,4%-%ldt:~4,2%-%ldt:~6,2% %ldt:~8,2%:%ldt:~10,2%:%ldt:~12,6%
    set CURRENT_YEAR=%ldt:~0,4%
    set CURRENT_MONTH=%ldt:~4,2%
    set CURRENT_DAY=%ldt:~6,2%
    set CURRENT_HOUR=%ldt:~8,2%
    set CURRENT_MINUTE=%ldt:~10,2%
    set CURRENT_SECOND=%ldt:~12,2%
)
echo.
echo DEBUG: Year   [%CURRENT_YEAR%]
echo DEBUG: Month  [%CURRENT_MONTH%]
echo DEBUG: Day    [%CURRENT_DAY%]
echo DEBUG: Hour   [%CURRENT_HOUR%]
echo DEBUG: Minute [%CURRENT_MINUTE%]
echo DEBUG: Second [%CURRENT_SECOND%]

set RULETREE_FILE_NAME_PREFIX=tree_%CURRENT_YEAR%_%CURRENT_MONTH%_%CURRENT_DAY%_

if exist %TC_DATA% (
    copy %TC_DATA%\am\%RULETREE_FILE_NAME_PREFIX%* .
)

endlocal
goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
