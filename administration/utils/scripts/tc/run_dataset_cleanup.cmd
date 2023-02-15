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

set TC_ENV_NAME=TC_PROD
set TC_ROOT=%TC_ROOT%
SET TC_DATA=%TC_DATA%
set JOB_NAME=dataset_cleanup
set SERVER_NAME=%computername%
set TC_INFODBA_PWD_FILE=%TC_ROOT%\security\tc_infodba.pwf

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
set CURRENT_DIRECTORY=%~dp0
set LAST_RUN_FILE=%CURRENT_DIRECTORY%dataset_cleanup_last_run.dat

REM ############################################
REM DO NOT MODIFY BEYOND THIS POINT
REM ############################################
set SANITISIZED_DATE_TIME=%CURRENT_YEAR%-%CURRENT_MONTH%-%CURRENT_DAY%-%CURRENT_HOUR%-%CURRENT_MINUTE%
set CURRENT_TIME=%time%
set LOG_FILE_NAME=%TC_ENV_NAME%_%SANITISIZED_DATE_TIME%_%JOB_NAME%_%SERVER_NAME%.log
set REPORT_FILE_NAME=%TC_ENV_NAME%_%SANITISIZED_DATE_TIME%_%JOB_NAME%_report_file_%SERVER_NAME%.log
set LOG_DIR=%TC_TMP_DIR%
if not exist %LOG_DIR% set LOG_DIR=%TEMP%
set LOG_FILE=%LOG_DIR%\%LOG_FILE_NAME%
set REPORT_FILE=%LOG_DIR%\%REPORT_FILE_NAME%

if not exist %TC_ROOT% goto TC_ENV_ERROR
if not exist %TC_DATA% goto TC_ENV_ERROR

REM launch TC environment settings
call %TC_DATA%\tc_profilevars

REM ############################################
REM START PROCESSING
REM ############################################
title %JOB_NAME% startet at %CURRENT_DATE% %CURRENT_TIME%

echo Starting dataset_cleanup process %CURRENT_DATE% %CURRENT_TIME%>>%LOG_FILE%
echo.>>%LOG_FILE%

:LOOP_LAST_TIL_NOW
REM Read date of last day processed
FOR /F "tokens=1,2,3 delims= " %%i in (%LAST_RUN_FILE%) do call :READ_LAST_RUN_DATE %%i %%j %%k

REM echo DEBUG: LAST_RUN_RESULT=%LAST_RUN_RESULT%

if x%LAST_RUN_RESULT% EQU xFINISHED goto RUN_DATASET_CLEANUP
if x%LAST_RUN_RESULT% EQU xRUNNING goto ERROR_STILL_RUNNING
if x%LAST_RUN_RESULT% EQU xERROR goto ERROR_FAILED
if x%LAST_RUN_RESULT% EQU x goto ERROR_NO_RESULT

:RUN_DATASET_CLEANUP
call :GET_MONTH_MMM %CURRENT_MONTH%
REM sample date format to be used "DD-MMM-YYYY HH:MM:SS", e.g. "12-OCT-2018 18:00:00"
set DATASET_CLEANUP_START_DATE=%LAST_RUN_DATE% %LAST_RUN_TIME%
set DATASET_CLEANUP_END_DATE=%CURRENT_DAY%-%CURRENT_MONTH_MMM%-%CURRENT_YEAR% %LAST_RUN_TIME%

REM echo DEBUG: DATASET_CLEANUP_START_DATE=%DATASET_CLEANUP_START_DATE%
REM echo DEBUG: DATASET_CLEANUP_END_DATE=%DATASET_CLEANUP_END_DATE%

echo %DATASET_CLEANUP_START_DATE% RUNNING>%LAST_RUN_FILE%
dataset_cleanup -u=infodba -pf=%TC_INFODBA_PWD_FILE% -g=dba -start_date=%DATASET_CLEANUP_START_DATE% -end_date=%DATASET_CLEANUP_END_DATE% -rf=%REPORT_FILE%

echo Please review report file %REPORT_FILE% for further details>>%LOG_FILE%
echo Cleanup report file if necessary and perform the purge with following command "dataset_cleanup -u=infodba -p=password -g=dba -if=%REPORT_FILE% -of=%REPORT_FILE%.output.log">>%LOG_FILE%

REM write back new starting date for next run
echo %DATASET_CLEANUP_END_DATE% FINISHED>%LAST_RUN_FILE%

echo.>>%LOG_FILE%
echo dataset_cleanup process finished at %date% %time%>>%LOG_FILE%

echo dataset_cleanup process finished at %date% %time%

endlocal
goto :EOF

:TC_ENV_ERROR
echo Teamcenter environment variables are not set properly. Please check again
echo TC_ROOT=%TC_ROOT%
echo TC_DATA=%TC_DATA%

echo Teamcenter environment variables are not set properly. Please check again.>>%LOG_FILE%
endlocal
goto :EOF

:READ_LAST_RUN_DATE
set LAST_RUN_DATE=%1
set LAST_RUN_TIME=%2
set LAST_RUN_RESULT=%3
goto :EOF

:ERROR_STILL_RUNNING
echo WARNING: dataset_cleanup utility seems to be still running, you might need to check this
echo WARNING: dataset_cleanup utility seems to be still running, you might need to check this.>>%LOG_FILE%
endlocal
goto :EOF

:ERROR_NO_RESULT
echo ERROR: dataset_cleanup has no result of last run, please check file %LAST_RUN_FILE%
echo ERROR: dataset_cleanup has no result of last run, please check file %LAST_RUN_FILE%>>%LOG_FILE%
endlocal
goto :EOF

:ERROR_FAILED
echo ERROR: dataset_cleanup has finished with error last time, please review the logs and correct issues. Update last run result accordingly, please check file %LAST_RUN_FILE%
echo ERROR: dataset_cleanup has finished with error last time, please review the logs and correct issues. Update last run result accordingly, please check file %LAST_RUN_FILE%>>%LOG_FILE%
endlocal
goto :EOF

:GET_MONTH_MMM
REM default month is december "DEC"
set CURRENT_MONTH_MMM=DEC
if %1x EQU 01x set CURRENT_MONTH_MMM=JAN
if %1x EQU 02x set CURRENT_MONTH_MMM=FEB
if %1x EQU 03x set CURRENT_MONTH_MMM=MAR
if %1x EQU 04x set CURRENT_MONTH_MMM=APR
if %1x EQU 05x set CURRENT_MONTH_MMM=MAY
if %1x EQU 06x set CURRENT_MONTH_MMM=JUN
if %1x EQU 07x set CURRENT_MONTH_MMM=JUL
if %1x EQU 08x set CURRENT_MONTH_MMM=AUG
if %1x EQU 09x set CURRENT_MONTH_MMM=SEP
if %1x EQU 10x set CURRENT_MONTH_MMM=OCT
if %1x EQU 11x set CURRENT_MONTH_MMM=NOV
if %1x EQU 12x set CURRENT_MONTH_MMM=DEC
goto :EOF