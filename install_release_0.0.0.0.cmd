@echo off
setlocal

if not defined TC_ROOT goto ENV_MISSING

cd /d %~dp0
cd configuration

:SELECT_MODE
echo #################################################################################################
echo Please select a valid mode for this script to run in.
echo Available options are:
echo:
echo    full - to update configuration and the Active Workspace client on a single machine
echo    corp - only updates configuration for the corporate server (4-tier)
echo    aw - only updates the Active Workspace client and performs a rebuild (No downtime required)
echo    bin - only exchanges DLLs (No downtime required - warm servers will still use old DLLs)
echo:
set /p MODE="Enter mode:"

if "%MODE%"=="full" goto ASK_TC_ENV
if "%MODE%"=="corp" goto ASK_TC_ENV
if "%MODE%"=="aw" goto AW_SRC_UPDATE
if "%MODE%"=="bin" goto EXCHANGE_BINARIES

goto SELECT_MODE

:ASK_TC_ENV
echo #################################################################################################
echo Please select on which Teamcenter environment this script is run.
echo This information is used to update the Teamcenter organization with the correct user lists.
echo Available options are:
echo:
echo    dev - The development environment
echo    qual - The quality environment
echo    prod - the production environment
echo    train - the training environment
echo    mig - The migration environment
echo:
set /p TC_ENV="Enter Teamcenter environment:"

if "%TC_ENV%"=="dev" goto SET_CREDENTIALS
if "%TC_ENV%"=="qual" goto SET_CREDENTIALS
if "%TC_ENV%"=="prod" goto SET_CREDENTIALS
if "%TC_ENV%"=="train" goto SET_CREDENTIALS
if "%TC_ENV%"=="mig" goto SET_CREDENTIALS

goto ASK_TC_ENV

:SET_CREDENTIALS
:: ### Provide credentials for infodba
echo Type in password of "infodba"
set /P DBAPASS=Password: 
set UPG_CREDENTIALS_TMP=-u=infodba -p=****** -g=dba
set UPG_CREDENTIALS=-u=infodba -p=%DBAPASS% -g=dba

:: ### Import site preferences
@REM call 01_import_site_preferences.cmd

:: ### Import site preferences merge
@REM call 02_import_site_preferences_merge.cmd

:: ### Import group preferences dba
@REM call 03_import_group_preferences_dba.cmd

:: ### Import t4x preferences
@REM call 29_import_t4x_preferences.cmd

:: ### Import revision rules
@REM cd revision_rule
@REM call 02_import_revision_rules.cmd
@REM cd ..

:: ### Import rule tree
@REM call 30_import_rule_tree.cmd

:: ### Import TestServer updates
@REM call 32_import_textserver_updates.cmd

:: ### Import queries
@REM call 40_import_query.cmd

:: ### Import workflows
@REM call 41_import_workflow.cmd

:: ### Import stylesheets
@REM call 42_import_stylesheet.cmd

:: ### Import closure rules
@REM call 43_import_closure_rules.cmd

:: ### Import transfer modes
@REM call 44_import_transfermodes.cmd

:: ### Import attribute mappings
@REM call 47_import_attribute_mappings.cmd

:: ### Import user queries (List each query with display name and file name to import)
:: ### call 48_import_user_query.cmd [Display Name] [File Name]
@REM call 48_import_user_query.cmd "Find Objects without JT File" Find_Objects_without_JT_File.xml
@REM call 48_import_user_query.cmd "Checked-Out Objects by Type" SR5_Checked_Out_Objects_By_Type.xml

:: ### Update external LOVs
@REM call 51_update_external_lovs.cmd

:: ### Import AW UI configuration
@REM call 71_import_aw_ui_config.cmd

:: ### Import AW workspaces
@REM call 72_import_aw_workspaces.cmd

:: ### Import AW tile collection
@REM call 74_import_tile_collection.cmd

:: ### Import AW Relation Browser configuration
@REM call 75_import_rb_ui_configure.cmd

:: ### Import CNO datasets
@REM call 90_import_cno_datasets.cmd

:: ### Import CNO preferences
@REM call 91_import_cno_preferences.cmd

:: ### Import CNO queries
@REM call 92_import_cno_query.cmd

:EXCHANGE_BINARIES
set datetime=%date:~6,4%-%date:~3,2%-%date:~,2%_%time:~,2%-%time:~3,2%
:: ### Exchange binaries for libSR5Custom
@REM cd ../binaries
@REM rename "%TC_ROOT%\bin\libSR5Custom.dll" "libSR5Custom.dll_%datetime%"
@REM xcopy /s libSR5custom.dll "%TC_ROOT%"\bin

:: ### Exchange library for libSR5Custrom
@REM rename "%TC_ROOT%\lib\libSR5Custom.lib" "libSR5Custom.lib_%datetime%"
@REM xcopy /s libSR5Custom.lib "%TC_ROOT%"\lib
@REM cd ../configuration

:: ### Exchange binaries for libcatia_custom
@REM cd ../binaries
@REM rename "%TC_ROOT%\bin\libcatia_custom.dll" "libcatia_custom.dll_%datetime%"
@REM xcopy /s libcatia_custom.dll "%TC_ROOT%"\bin

:: ### Exchange library for libcatia_custom
@REM rename "%TC_ROOT%\lib\libcatia_custom.lib" "libcatia_custom.lib_%datetime%"
@REM xcopy /s libcatia_custom.lib "%TC_ROOT%"\lib
@REM cd ../configuration

if %MODE%==bin goto :EOF
if %MODE%==corp goto :GENERATE_META_CLIENT_CACHE

:AW_SRC_UPDATE
:: ### Build AW
@REM call 70_import_aw_src_updates.cmd
if %MODE%==aw goto :EOF

:GENERATE_META_CLIENT_CACHE
generate_client_meta_cache %UPG_CREDENTIALS% delete
generate_client_meta_cache %UPG_CREDENTIALS% generate all
generate_metadata_cache %UPG_CREDENTIALS%


goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
echo    TC_ROOT = %TC_ROOT%
echo    TC_DATA = %TC_DATA%
endlocal
goto :EOF