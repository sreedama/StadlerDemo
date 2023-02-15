@echo off
rem   If you make changes to any of the .properties files, or you add new
rem   plug-ins or change plug-in content, you must run the genregxml
rem   script to ensure your changes are included when the rich client starts.
rem   This enhances performance because it caches the properties so they
rem   can be loaded at startup. The script takes no arguments and generates
rem   a RegistryLoader file for each locale in the portal\Registry
rem   directory.

set PLATFORM=%1
set NO_REGISTER=%2
set PLATFORM_STRING=64bit

if x%PLATFORM%==x32 set PLATFORM_STRING=32bit

if not defined TC_ROOT goto ENV_MISSING
if x%SILENT_MODE%==xTRUE goto START_PROCESS

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
if exist %TC_ROOT%\portal\plugins\configuration_11000.2.0 (
    echo.
    echo INFO: Copy configuration files to plugins folder...
    copy /y client\%PLATFORM_STRING%\tc_root\portal\plugins\configuration_11000.2.0 %TC_ROOT%\portal\plugins\configuration_11000.2.0
)

if not exist %TC_ROOT%\portal\plugins\configuration_11000.2.0 (
    echo.
    echo WARNING: %TC_ROOT%\portal\plugins\configuration_11000.2.0 does not exist!
)

if x%NO_REGISTER%==xNO_REGISTER goto :EOF

:REGISTER_PLUGIN
echo.
echo INFO: Registering with "%TC_ROOT%\portal\registry\genregxml.bat" ...
call %TC_ROOT%\portal\registry\genregxml.bat
echo Finished!

rem don't copy registry files (server and client create differnet files)
goto DELETE_CACHE

:COPY_REGISTRY
::echo.
::echo INFO: Cleanup local temporary registry folder...
::del /q Plugins\TC_ROOT\portal\registry\*.*
::copy /y %TC_ROOT%\portal\registry\RegistryLoader_*.xml* Plugins\TC_ROOT\portal\registry

:DELETE_CACHE
echo.
if not exist "%USERPROFILE%\Teamcenter" echo WARNING: Teamcenter Cache directory not found in "%USERPROFILE%\Teamcenter". Please delete directory manually!
if exist "%USERPROFILE%\Teamcenter" (
    echo Deleting Teamcenter Cache "%USERPROFILE%\Teamcenter"...
    rd /s /q "%USERPROFILE%\Teamcenter"
)

echo.
echo INFO: Copy the registry resources in TC_ROOT\portal\registry to each client and make sure to delete the Teamcenter cache as well. E.g. on users home there is a subdirectory Teamcenter
echo. 
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
