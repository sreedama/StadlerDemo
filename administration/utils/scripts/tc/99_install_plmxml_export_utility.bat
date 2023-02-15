@echo OFF
title Installation of PLMXML export utility

REM This script is to install the plmxml export utility that exports files to a specific folder structure. It is triggered by a workflow. The following environment variables are required to be set. These variables can be either set on each server where tcserver process is running or centralized in a script that is called when creating a new tcserver process (e.g. tc_profilevars.bat)

REM ============== Mandatory Configuration Variables ====================================

REM     A4_PLMXML_EXP_EXTERNAL_COMMAND=Full path to this utility incl utility file name
set A4_PLMXML_EXP_EXTERNAL_COMMAND_ROOT_DIR=C:\plm\admin\scripts
set A4_PLMXML_EXP_EXTERNAL_COMMAND=%A4_PLMXML_EXP_EXTERNAL_COMMAND_ROOT_DIR%\R4_create_plmxml_requests.exe

REM     A4_PLMXML_EXP_TC_GROUP=group of executing user, most probably "dba"
set A4_PLMXML_EXP_TC_GROUP=dba

REM     A4_PLMXML_EXP_TC_PW=Full path to encrypted password file of executing user
set A4_PLMXML_EXP_TC_PW=C:\plm\tc101\security\TC10_infodba.pwf

REM     A4_PLMXML_EXP_TC_USER=User id of executing user, e.g. "infodba"
set A4_PLMXML_EXP_TC_USER=infodba

REM     A4_PLMXML_EXP_WFL_BASE_DIR=Path to directory where the user directory is generated to place the exported files
set A4_PLMXML_EXP_WFL_BASE_DIR=C:\temp\plmxml_exports\output

REM     A4_PLMXML_EXP_WFL_EXPORT_DATA_PATH=Path to directory where the workflow exports the job file to be processed by this utility
set A4_PLMXML_EXP_WFL_EXPORT_DATA_PATH=C:\temp\plmxml_exports\jobs

REM ============== Optional Configuration Variables ====================================

REM     A4_PLMXML_EXP_WFL_EXPORT_CLEANUP=If this variable is defined and set to any value, the generated PLMXML file is deleted afterwards
set A4_PLMXML_EXP_WFL_EXPORT_CLEANUP=Y



REM ============== Do not adjust beyond this point =====================================
set UTILITY_LOCATION=..\..\..\configuration\server\tc_root\common\bin\A4_create_plmxml_requests.exe

if not exist %UTILITY_LOCATION% (
    echo ERROR: The utility does not exist in %UTILITY_LOCATION%. Cannot copy the same to directory %A4_PLMXML_EXP_EXTERNAL_COMMAND_ROOT_DIR%. Copy the utility manually.
    goto end
)

if not exist %A4_PLMXML_EXP_EXTERNAL_COMMAND_ROOT_DIR% (
    echo ERROR: The directory defined as %A4_PLMXML_EXP_EXTERNAL_COMMAND_ROOT_DIR% does not exist. Cannot copy the utility. Please correct the environment variable in this script.
    goto end
)

if not exist %A4_PLMXML_EXP_TC_PW% (
    echo ERROR: The password file defined in A4_PLMXML_EXP_TC_PW as %A4_PLMXML_EXP_TC_PW% does not exist. Please correct the environment variable.
    goto end
)

if not exist %A4_PLMXML_EXP_WFL_BASE_DIR% (
    echo INFO: Base directory does not yet exist. Creating directory %A4_PLMXML_EXP_WFL_BASE_DIR%...
    mkdir %A4_PLMXML_EXP_WFL_BASE_DIR%
)

if not exist %A4_PLMXML_EXP_WFL_EXPORT_DATA_PATH% (
    echo INFO: Job file directory does not yet exist. Creating directory %A4_PLMXML_EXP_WFL_EXPORT_DATA_PATH%...
    mkdir %A4_PLMXML_EXP_WFL_EXPORT_DATA_PATH%
)

REM Creating system environment variables
echo INFO: Setting environment variables...
setx A4_PLMXML_EXP_EXTERNAL_COMMAND %A4_PLMXML_EXP_EXTERNAL_COMMAND% /m
setx A4_PLMXML_EXP_TC_GROUP %A4_PLMXML_EXP_TC_GROUP% /m
setx A4_PLMXML_EXP_TC_PW %A4_PLMXML_EXP_TC_PW% /m
setx A4_PLMXML_EXP_TC_USER %A4_PLMXML_EXP_TC_USER% /m
setx A4_PLMXML_EXP_WFL_BASE_DIR %A4_PLMXML_EXP_WFL_BASE_DIR% /m
setx A4_PLMXML_EXP_WFL_EXPORT_DATA_PATH %A4_PLMXML_EXP_WFL_EXPORT_DATA_PATH% /m
if defined A4_PLMXML_EXP_WFL_EXPORT_CLEANUP setx A4_PLMXML_EXP_WFL_EXPORT_CLEANUP %A4_PLMXML_EXP_WFL_EXPORT_CLEANUP% /m

echo.
echo A4_PLMXML_EXP_EXTERNAL_COMMAND=%A4_PLMXML_EXP_EXTERNAL_COMMAND%
echo A4_PLMXML_EXP_TC_GROUP=%A4_PLMXML_EXP_TC_GROUP%
echo A4_PLMXML_EXP_TC_PW=%A4_PLMXML_EXP_TC_PW%
echo A4_PLMXML_EXP_TC_USER=%A4_PLMXML_EXP_TC_USER%
echo A4_PLMXML_EXP_WFL_BASE_DIR=%A4_PLMXML_EXP_WFL_BASE_DIR%
echo A4_PLMXML_EXP_WFL_EXPORT_DATA_PATH=%A4_PLMXML_EXP_WFL_EXPORT_DATA_PATH%
echo A4_PLMXML_EXP_WFL_EXPORT_CLEANUP=%A4_PLMXML_EXP_WFL_EXPORT_CLEANUP%
echo.

REM Copy utility
echo INFO: Copy plmxml export utility...
xcopy /s /y %UTILITY_LOCATION% %A4_PLMXML_EXP_EXTERNAL_COMMAND_ROOT_DIR%

echo.
echo INFO: Installation process completed!
goto :EOF

:end
pause
exit /B 0
