@echo off

if not defined TC_ROOT goto ENV_MISSING

if x%1==x-clean set CLEAN_BUILD=TRUE
set SPLASH_DIR="%TC_ROOT%"\aws2\stage\repo\tc-aw-framework\src_native\assets\images
set LOGO_DIR="%TC_ROOT%"\aws2\stage\src\image
set AW_THEME_DIR="%TC_ROOT%"\aws2\stage\src\sr5CustomTheme\src

if not defined TC_ENV goto ASK_TC_ENV

:AW_SRC_UPDATE
REM Update AW Config
echo.
xcopy /E aw_src_updates "%TC_ROOT%"\aws2\ /Y
xcopy aw_custom_themes\%TC_ENV%\logo.jpg %SPLASH_DIR% /Y
xcopy aw_custom_themes\%TC_ENV%\miscSiemensLogo24.svg %LOGO_DIR% /Y
xcopy aw_custom_themes\%TC_ENV%\ui-sr5CustomTheme.scss %AW_THEME_DIR% /Y

if x%CLEAN_BUILD%==xTRUE (rmdir %TC_ROOT%\aws2\stage\out /s /q)

call %TC_ROOT%\aws2\stage\awbuild.cmd

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment

:ASK_TC_ENV
echo #################################################################################################
echo Please select on which Teamcenter environment this script is run.
echo This information is used to update the Teamcenter organization with the correct user lists and
echo to deploy the correct themes for the Active Workspace client.
echo Available options are:
echo:
echo    dev - The development environment
echo    qual - The quality environment
echo    prod - the production environment
echo    train - the training environment
echo    mig - The migration environment
echo:
set /p TC_ENV="Enter Teamcenter environment:"

if "%TC_ENV%"=="dev" goto AW_SRC_UPDATE
if "%TC_ENV%"=="qual" goto AW_SRC_UPDATE
if "%TC_ENV%"=="prod" goto AW_SRC_UPDATE
if "%TC_ENV%"=="train" goto AW_SRC_UPDATE
if "%TC_ENV%"=="mig" goto AW_SRC_UPDATE

goto ASK_TC_ENV
