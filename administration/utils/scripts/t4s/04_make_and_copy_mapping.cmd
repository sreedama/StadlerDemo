@echo off

rem Define some T4X envs
set T4X_MMAP_USER=t4adm
set T4X_MMAP_PASSWD=geheim
set T4X_MMAP_EXE=%TP_T4XINSTL%\bin64\mmap.exe

rem Default if folder is mmap
set T4X_DEFAULT_MMAP_OUT=t4s_mapping_config.rfdt

rem List of Server to deploy
rem set T4X_SERVER_LIST=localhost@11301,localhost@11302
set T4X_SERVER_LIST=localhost@11301,localhost@11302

if not defined TP_T4XINSTL goto error_t4s_env


set T4X_MAIN_MMAP_DIR=%T4S_GS_PATH%\var
echo T4X_MAIN_MMAP_DIR: %T4X_MAIN_MMAP_DIR%
echo -----------------------------------------------------------------

for /f "delims=" %%A in ('dir /B %T4X_MAIN_MMAP_DIR%') do call :make_mmap_dir %%A
goto end

:make_mmap_dir
set MMAP_DIR_NAME=%1
echo MMAP_DIR_NAME: %MMAP_DIR_NAME%

set T4X_MMAP_SRCDIR=%T4X_MAIN_MMAP_DIR%\%MMAP_DIR_NAME%

if "%MMAP_DIR_NAME%" == "mmap" set T4X_MMAP_OUT=%T4X_DEFAULT_MMAP_OUT%
if not "%MMAP_DIR_NAME%" == "mmap" set T4X_MMAP_OUT=t4x_%MMAP_DIR_NAME%.rfdt
echo T4X_MMAP_OUT: %T4X_MMAP_OUT%


rem Define Folders
set T4X_MMAP_DSTDIR=%TP_T4XINSTL%\tmp
set T4X_MMAP_SDSTDIR=lib


rem now call the mmap
echo Build mapping ...
echo %T4X_MMAP_EXE%

REM call %T4X_MMAP_EXE% -srcdir %T4X_MMAP_SRCDIR% -dstdir %T4X_MMAP_DSTDIR% -out %T4X_MMAP_OUT%
start %T4X_MMAP_EXE% -srcdir %T4X_MMAP_SRCDIR% -dstdir %T4X_MMAP_DSTDIR% -out %T4X_MMAP_OUT%
pause
echo -----------------------------------------------------------------
if not exist %T4X_MMAP_DSTDIR%\%T4X_MMAP_OUT% goto error_rfdt_not_found
echo xcopy %T4X_MMAP_DSTDIR%\%T4X_MMAP_OUT% to %TP_T4XINSTL%\lib
xcopy /s /y %T4X_MMAP_DSTDIR%\%T4X_MMAP_OUT% %TP_T4XINSTL%\lib


goto end
:error_rfdt_not_found
echo ERROR: %T4X_MMAP_DSTDIR%\%T4X_MMAP_OUT%  not found!
pause
goto end

:error_t4s_env
echo ERROR: T4X Env is missing!
pause


:end
