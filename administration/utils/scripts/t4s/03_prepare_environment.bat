@echo off

set START_DIR=%~dp0
set START_DIR=%START_DIR:~0,-1%

call %START_DIR%\01_set_environment.bat
call %T4S_GS_PATH%\etc\t4x_env.bat

echo ##############################
echo Start Preparing T4S Mapping 
echo ##############################

call %START_DIR%\04_make_and_copy_mapping.cmd

echo #############################
echo Finished Preparing T4S Mapping
echo #############################

call %T4S_GS_PATH%\etc\t4xcust.bat

pause