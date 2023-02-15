@echo off
setlocal
REM ############################################
REM VERSION / HISTORY
REM --------------------------------------------
REM 01.12.2018  v1.0        initial draft
REM ############################################

REM ############################################
REM USAGE OF THIS SCRIPT
REM review the following environment variables and do not use spaces or special characters. Do also review the date format on current machine and adjust the script if necessary.
REM call this script without any argument
REM ############################################

set TC_ENV_NAME=TC_CLOUD
set TC_ROOT=%TC_ROOT%
SET TC_DATA=%TC_DATA%
set JOB_NAME=aw_indexing_service
set SERVER_NAME=%computername%

set CURRENT_DATE=%date%
REM pls check the date format on your system, if it look like "Tue 01/08/2019" then you can use the following definition
set CURRENT_DAY=%date:~7,2%
set CURRENT_MONTH=%date:~4,2%
set CURRENT_YEAR=%date:~10,4%
REM if you date is of format like this "08.01.2019", use the following definition
REM set CURRENT_DAY=%date:~0,2%
REM set CURRENT_MONTH=%date:~3,2%
REM set CURRENT_YEAR=%date:~6,4%

REM pls check if time format looks like "14:33:53.77" and adjust below function if necessary to extract hour and minute value properly
set CURRENT_HOUR=%time:~0,2%
set CURRENT_MINUTE=%time:~3,2%

REM ############################################
REM DO NOT MODIFY BEYOND THIS POINT
REM ############################################
set SANITISIZED_DATE_TIME=%CURRENT_YEAR%-%CURRENT_MONTH%-%CURRENT_DAY%-%CURRENT_HOUR%-%CURRENT_MINUTE%
set CURRENT_TIME=%time%
set LOG_FILE_NAME=%TC_ENV_NAME%_%SANITISIZED_DATE_TIME%_%JOB_NAME%_%SERVER_NAME%.log
set LOG_DIR=%TC_TMP_DIR%
if not exist %LOG_DIR% set LOG_DIR=%TEMP%
set LOG_FILE=%LOG_DIR%\%LOG_FILE_NAME%

if not exist %TC_ROOT% goto TC_ENV_ERROR
if not exist %TC_DATA% goto TC_ENV_ERROR

REM launch TC environment settings
call %TC_DATA%\tc_profilevars

REM ############################################
REM START PROCESSING
REM ############################################
title %JOB_NAME% startet at %CURRENT_DATE% %CURRENT_TIME%

echo Starting process %CURRENT_DATE% %CURRENT_TIME%>>%LOG_FILE%
echo.>>%LOG_FILE%

cd /D %TC_ROOT%\TcFTSIndexer\bin
start runTcFTSIndexer.bat -service
call runTcFTSIndexer -task=objdata:sync -interval=60

echo.>>%LOG_FILE%
echo %JOB_NAME% process finished at %date% %time%>>%LOG_FILE%

echo %JOB_NAME% process finished at %date% %time%

endlocal
goto :EOF

:TC_ENV_ERROR
echo Teamcenter environment variables are not set properly. Please check again
echo TC_ROOT=%TC_ROOT%
echo TC_DATA=%TC_DATA%

echo Teamcenter environment variables are not set properly. Please check again.>>%LOG_FILE%
endlocal