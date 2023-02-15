@ECHO OFF
SETLOCAL
CLS

IF NOT DEFINED TC_ROOT GOTO ENV_MISSING

:: ### 7z-Config - Change this variable to the correct value depending on where 7z is installed on your machine.
SET SEVEN_ZIP=C:\Program Files\7-Zip\7z.exe

for /f "delims=" %%a in ('
    powershell -Command "Get-Date -format 'yyyy-MM-dd_HH-mm'"
') do set "DATETIME=%%a"

echo =================================================================
echo =       _____ _            _ _             _____       _ _      =
echo =      ^/ ____^| ^|          ^| ^| ^|           ^|  __ \     (_) ^|     =
echo =     ^| (___ ^| ^|_ __ _  __^| ^| ^| ___ _ __  ^| ^|__) ^|__ _ _^| ^|     =
echo =      ^\___ ^\^| __^/ _` ^|^/ _` ^| ^|^/ _ ^\ '__^| ^|  _  ^/^/ _` ^| ^| ^|     =
echo =      ____) ^| ^|^| (_^| ^| (_^| ^| ^|  __^/ ^|    ^| ^| ^\ ^\ (_^| ^| ^| ^|     =
echo =     ^|_____^/ ^\__^\__,_^|^\__,_^|_^|^\___^|_^|    ^|_^|  ^\_^\__,_^|_^|_^|     =
echo =                                                               =
echo =================================================================
echo *
echo *
echo *    ________                .__                                      __   
echo *    ^\______ ^\   ____ ______ ^|  ^|   ____ ___.__. _____   ____   _____^/  ^|_ 
echo *     ^|    ^|  ^\_^/ __ ^\^\____ ^\^|  ^|  ^/  _ ^<   ^|  ^|^/     ^\_^/ __ ^\ ^/    ^\   __^\
echo *     ^|    `   ^\  ___^/^|  ^|_^> ^>  ^|_(  ^<_^> )___  ^|  Y Y  ^\  ___^/^|   ^|  ^\  ^|  
echo *    ^/_______  ^/^\___  ^>   __^/^|____^/^\____^/^/ ____^|__^|_^|  ^/^\___  ^>___^|  ^/__^|  
echo *            ^\^/     ^\^/^|__^|               ^\^/          ^\^/     ^\^/     ^\^/      
echo *    __________               __                                           
echo *    ^\______   ^\____    ____ ^|  ^| ______    ____   ____                    
echo *     ^|     ___^|__  ^\ _^/ ___^\^|  ^|^/ ^|__  ^\  ^/ ___^\_^/ __ ^\                   
echo *     ^|    ^|    ^/ __ ^\^\  ^\___^|    ^< ^/ __ ^\^/ ^/_^/  ^>  ___^/                   
echo *     ^|____^|   (____  ^/^\___  ^>__^|_ (____  ^|___  ^/ ^\___  ^>                  
echo *                   ^\^/     ^\^/     ^\^/    ^\^/_____^/      ^\^/                   
echo *      ________                                   __                       
echo *     ^/  _____^/  ____   ____   ________________ _^/  ^|_  ___________        
echo *    ^/   ^\  ____^/ __ ^\ ^/    ^\_^/ __ ^\_  __ ^\__  ^\^\   __^\^/  _ ^\_  __ ^\       
echo *    ^\    ^\_^\  ^\  ___^/^|   ^|  ^\  ___^/^|  ^| ^\^/^/ __ ^\^|  ^| (  ^<_^> )  ^| ^\^/       
echo *     ^\______  ^/^\___  ^>___^|  ^/^\___  ^>__^|  (____  ^/__^|  ^\____^/^|__^|          
echo *            ^\^/     ^\^/     ^\^/     ^\^/           ^\^/           
echo *
echo * This is the Stadler Rail deployment package generator
echo * It will generate a new deployment package based on a GIT diff between two specified release tags.
echo * 
:ASK_VERSION
SET /P VERSION= * Please specify the current Teamcenter version (nn.nn.nn.nn, e.g., 13.3.0.4):

:: ### Validate the entered Teamcenter version
:VALIDATE_VERSION
for /f "delims=" %%a in (' powershell '%VERSION%' -match '^[1-9][0-9]?\.[0-9]\.[0-9]\.[0-9]$' ') do set VERSION_IS_VALID=%%a
if %VERSION_IS_VALID%==True (
    goto :NEXT
) else (
    echo *
    powershell write-host -fore Yellow * WARN: %VERSION% is not a valid version. You must adhere to semantic versioning.
    SET /P VERSION= * Please specify the current Teamcenter version in the format nn.nn.nn.nn e.g., 13.3.0.4:
    echo *
    goto VALIDATE_VERSION
)
:NEXT
SET /P BUILD= * Please specify the BMIDE build (release) to generate (nn.nn.nn, e.g., 1.2.17):

:: ### Validate the entered BMIDE build
:VALIDATE_BUILD
for /f "delims=" %%a in (' powershell '%BUILD%' -match '^[1-9]\.[1-9]\.[1-9][0-9]?$' ') do set BUILD_IS_VALID=%%a
if %BUILD_IS_VALID%==True (
    goto :NEXT2
) else (
    echo *
    powershell write-host -fore Yellow * WARN: %BUILD% is not a valid build. You must adhere to semantic versioning.
    SET /P BUILD= * Please specify the current BMIDE build in the format nn.nn.nn, e.g., 1.2.17:
    echo *
    goto VALIDATE_BUILD
)
:NEXT2
SET /P PREV_BUILD= * Please specify the BMIDE build (release) from where the diff should start from (nn.nn.nn, e.g., 1.2.17):

:: ### Validate the entered BMIDE build
:VALIDATE_PREV_BUILD
for /f "delims=" %%a in (' powershell '%PREV_BUILD%' -match '^[1-9]\.[1-9]\.[1-9][0-9]?$' ') do set PREV_BUILD_IS_VALID=%%a
if %PREV_BUILD_IS_VALID%==True (
    goto :NEXT3
) else (
    echo *
    powershell write-host -fore Yellow * WARN: %PREV_BUILD% is not a valid build. You must adhere to semantic versioning.
    SET /P PREV_BUILD= * Please specify the BMIDE build from where the diff should start from in the format nn.nn.nn, e.g., 1.2.17:
    echo *
    goto VALIDATE_PREV_BUILD
)
:NEXT3

:: ### Ask if organization should be considered
SET SKIP_ORGA_BOOL=false
SET /P SKIP_ORGA_DECISION= * If there are changes to the organization, do you want them to be included in the deployment package? (Y,n)
IF x%SKIP_ORGA_DECISION%==xY set SKIP_ORGA_BOOL=true
IF x%SKIP_ORGA_DECISION%==xy set SKIP_ORGA_BOOL=true

:: ### Ask for correct version and build then start
echo *
echo * This will generate a deployment package for %VERSION%:%BUILD% using a GIT diff from the R%PREV_BUILD% tag to your current HEAD.
IF %SKIP_ORGA_BOOL%==true (
  powershell write-host -fore DarkCyan * INFO: Changes to the organization will be considered during generation.
) else (
  powershell write-host -fore DarkCyan * INFO: Changes to the organization will not be considered during generation.
)

SET /P DECISION=* Is this ok? (Y,n)
IF %DECISION%==Y (
    goto BUILD_PACKAGE
) else (
    goto ASK_VERSION
)

:BUILD_PACKAGE

SET PACKAGE_DIR="DP_%DATETIME%_%VERSION%_%BUILD%"
SET BMIDE_OUT_DIR="%PACKAGE_DIR%\bmide"
SET BIN_DIR="%PACKAGE_DIR%\binaries"
SET CONFIG_DIR="%PACKAGE_DIR%\configuration"
SET BUILD_LOG="%PACKAGE_DIR%\%PACKAGE_DIR%_log.txt"

IF EXIST %PACKAGE_DIR% RMDIR %PACKAGE_DIR%

MKDIR %PACKAGE_DIR%
MKDIR %BMIDE_OUT_DIR%
MKDIR %BIN_DIR%
MKDIR %CONFIG_DIR%

break>%BUILD_LOG%

:: ### Build BMIDE software package
echo *
echo * Building the BMIDE software package...
CALL bmide_generate_package -projectLocation=bmide\sr5stadlerrailbase -packageLocation=%BMIDE_OUT_DIR% -dependencyTemplateFolder=%TC_ROOT%\bmide\templates -softwareVersion=%VERSION% -buildVersion=%BUILD% -log=%BMIDE_OUT_DIR%\bmide_build_log.log>nul
if %errorlevel% == 0 (
  echo * Successfuly buildt software package.
  echo *
) else (
  echo * Error building BMIDE software package.
  echo * You need to run this script in a Teamcenter environment.
  pause>nul
  goto :EOF
)

:: ### Generate Install Script
echo *
echo * Building the install script...

:: ### Generate GIT diff from latest Release tag to HEAD
SET DIFF_FILE=%PACKAGE_DIR%\git_diff.txt
git --no-pager diff R%PREV_BUILD% HEAD --name-only>>%DIFF_FILE%

:: ### Create the empty install script
SET INSTALL_SCRIPT=%PACKAGE_DIR%\install_release_%VERSION%_%BUILD%.cmd
break>%INSTALL_SCRIPT%

:: ### Add header to install script
type administration\utils\deployment_package\install_script_begin.txt >> %INSTALL_SCRIPT%

:: ### Look for changes in arttribute mappings
>nul find "configuration/attribute_mapping" %DIFF_FILE% && (
  xcopy /S /I /Y /F configuration\attribute_mapping %PACKAGE_DIR%\configuration\attribute_mapping>>%BUILD_LOG%
  xcopy configuration\47_import_attribute_mappings.cmd %PACKAGE_DIR%\configuration>>%BUILD_LOG%
  echo CALL 47_import_attribute_mappings.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
) || (
  echo REM CALL 47_import_attribute_mappings.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
)

:: ### Look for changes in relation browser configuration
>nul find "configuration/aw_relationbrowser" %DIFF_FILE% && (
  xcopy /S /I /Y /F configuration\aw_relationbrowser %PACKAGE_DIR%\configuration\aw_relationbrowser>>%BUILD_LOG%
  xcopy configuration\75_import_rb_ui_configure.cmd %PACKAGE_DIR%\configuration>>%BUILD_LOG%
  echo CALL 75_import_rb_ui_configures.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
) || (
  echo REM CALL 75_import_rb_ui_configures.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
)

:: ### Look for changes in tile collections (SR5TileCollection only)
>nul find "configuration/aw_tile_collections" %DIFF_FILE% && (
  xcopy /S /I /Y /F configuration\aw_tile_collections %PACKAGE_DIR%\configuration\aw_tile_collections>>%BUILD_LOG%
  xcopy configuration\74_import_tile_collection.cmd %PACKAGE_DIR%\configuration>>%BUILD_LOG%
  echo CALL 74_import_tile_collection.cmd remove SR5TileCollection_remove >> %INSTALL_SCRIPT%
  echo CALL 74_import_tile_collection.cmd add SR5TileCollection_add>> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
) || (
  echo REM CALL 74_import_tile_collection.cmd remove SR5TileCollection_remove >> %INSTALL_SCRIPT%
  echo REM CALL 74_import_tile_collection.cmd add SR5TileCollection_add>> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
)

:: ### Look for changes in column configurations
>nul find "configuration/aw_ui_config" %DIFF_FILE% && (
  xcopy /S /I /Y /F configuration\aw_ui_config %PACKAGE_DIR%\configuration\aw_ui_config>>%BUILD_LOG%
  xcopy configuration\71_import_aw_ui_config.cmd %PACKAGE_DIR%\configuration>>%BUILD_LOG%
  echo CALL 71_import_aw_ui_config.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
) || (
  echo REM CALL 71_import_aw_ui_config.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
)

:: ### Look for changes in workfspace configuration
>nul find "configuration/aw_workspaces" %DIFF_FILE% && (
  xcopy /S /I /Y /F configuration\aw_workspaces %PACKAGE_DIR%\configuration\aw_workspaces>>%BUILD_LOG%
  xcopy configuration\72_import_aw_workspaces.cmd %PACKAGE_DIR%\configuration>>%BUILD_LOG%
  echo CALL 72_import_aw_workspaces.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
) || (
  echo REM CALL 72_import_aw_workspaces.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
)

:: ### Look for changes in closure rules
>nul find "configuration/closure_rules" %DIFF_FILE% && (
  xcopy /S /I /Y /F configuration\closure_rules %PACKAGE_DIR%\configuration\closure_rules>>%BUILD_LOG%
  xcopy configuration\43_import_closure_rules.cmd %PACKAGE_DIR%\configuration>>%BUILD_LOG%
  echo CALL 43_import_closure_rules.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
) || (
  echo REM CALL 43_import_closure_rules.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
)

:: ### Look for changes in external lovs
>nul find "configuration/external_lovs" %DIFF_FILE% && (
  xcopy /S /I /Y /F configuration\external_lovs %PACKAGE_DIR%\configuration\external_lovs>>%BUILD_LOG%
  xcopy configuration\51_update_external_lovs.cmd %PACKAGE_DIR%\configuration>>%BUILD_LOG%
  echo CALL 51_update_external_lovs.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
) || (
  echo REM CALL 51_update_external_lovs.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
)

:: ### Look for changes in textserver
>nul find "configuration/localization" %DIFF_FILE% && (
  xcopy /S /I /Y /F configuration\localization %PACKAGE_DIR%\configuration\localization>>%BUILD_LOG%
  xcopy configuration\32_import_textserver_updates.cmd %PACKAGE_DIR%\configuration>>%BUILD_LOG%
  echo CALL 32_import_textserver_updates.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
) || (
  echo REM CALL 32_import_textserver_updates.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
)

:: ### Look for changes in site preferences (override)
>nul find "configuration/preferences/site_preferences" %DIFF_FILE% && (
  xcopy /S /I /Y /F configuration\preferences %PACKAGE_DIR%\configuration\preferences>>%BUILD_LOG%
  xcopy configuration\01_import_site_preferences.cmd %PACKAGE_DIR%\configuration>>%BUILD_LOG%
  echo CALL 01_import_site_preferences.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
) || (
  echo REM CALL 01_import_site_preferences.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
)

:: ### Look for changes in site preferences (merge)
>nul find "configuration/preferences/site_preferences_merge" %DIFF_FILE% && (
  IF NOT EXIST %PACKAGE_DIR%\configuration\preferences xcopy /S /I /Y /F configuration\preferences %PACKAGE_DIR%\configuration\preferences>>%BUILD_LOG%
  xcopy configuration\02_import_site_preferences_merge.cmd %PACKAGE_DIR%\configuration>>%BUILD_LOG%
  echo CALL 02_import_site_preferences_merge.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
) || (
  echo REM CALL 02_import_site_preferences_merge.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
)

:: ### Look for changes in dba group preferences (override)
>nul find "configuration/preferences/group_preferences_dba" %DIFF_FILE% && (
  IF NOT EXIST %PACKAGE_DIR%\configuration\preferences xcopy /S /I /Y /F configuration\preferences %PACKAGE_DIR%\configuration\preferences>>%BUILD_LOG%
  xcopy configuration\03_import_group_preferences_dba.cmd %PACKAGE_DIR%\configuration>>%BUILD_LOG%
  echo CALL 03_import_group_preferences_dba.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
) || (
  echo REM CALL 03_import_group_preferences_dba.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
)

:: ### Look for changes in t4x site preferences (override)
>nul find "configuration/t4x/preferences" %DIFF_FILE% && (
  xcopy /S /I /Y /F configuration\t4x\preferences %PACKAGE_DIR%\configuration\t4x\preferences>>%BUILD_LOG%
  xcopy configuration\29_import_t4x_preferences.cmd %PACKAGE_DIR%\configuration>>%BUILD_LOG%
  echo CALL 29_import_t4x_preferences.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
) || (
  echo REM CALL 29_import_t4x_preferences.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
)

:: ### Look for changes in SR5_GENERAL queries
>nul find "configuration/queries/SR5_GENERAL" %DIFF_FILE% && (
  xcopy /S /I /Y /F configuration\queries\SR5_GENERAL %PACKAGE_DIR%\configuration\queries\SR5_GENERAL>>%BUILD_LOG%
  xcopy configuration\40_import_query.cmd %PACKAGE_DIR%\configuration>>%BUILD_LOG%
  echo CALL 40_import_query.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
) || (
  echo REM CALL 40_import_query.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
)

:: ### Look for changes in the rule tree
>nul find "configuration/ruletree" %DIFF_FILE% && (
  xcopy /S /I /Y /F configuration\ruletree %PACKAGE_DIR%\configuration\ruletree>>%BUILD_LOG%
  xcopy configuration\30_import_rule_tree.cmd %PACKAGE_DIR%\configuration>>%BUILD_LOG%
  echo CALL 30_import_rule_tree.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
) || (
  echo REM CALL 30_import_rule_tree.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
)

:: ### Look for changes in stylesheets
>nul find "configuration/stylesheets" %DIFF_FILE% && (
  xcopy /S /I /Y /F configuration\stylesheets %PACKAGE_DIR%\configuration\stylesheets>>%BUILD_LOG%
  xcopy configuration\42_import_stylesheet.cmd %PACKAGE_DIR%\configuration>>%BUILD_LOG%
  echo CALL 42_import_stylesheet.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
) || (
  echo REM CALL 42_import_stylesheet.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
)

:: ### Look for changes in workflows
>nul find "configuration/workflows" %DIFF_FILE% && (
  xcopy /S /I /Y /F configuration\workflows %PACKAGE_DIR%\configuration\workflows>>%BUILD_LOG%
  xcopy configuration\41_import_workflow.cmd %PACKAGE_DIR%\configuration>>%BUILD_LOG%
  echo CALL 41_import_workflow.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
) || (
  echo REM CALL 41_import_workflow.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
)

:: ### Look for changes in transfer modes
>nul find "configuration/transfermodes" %DIFF_FILE% && (
  xcopy /S /I /Y /F configuration\transfermodes %PACKAGE_DIR%\configuration\transfermodes>>%BUILD_LOG%
  xcopy configuration\44_import_transfermodes.cmd %PACKAGE_DIR%\configuration>>%BUILD_LOG%
  echo CALL 44_import_transfermodes.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
) || (
  echo REM CALL 44_import_transfermodes.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
)

:: ### Look for changes in CNO datasets
>nul find "configuration/CNO/Datasets" %DIFF_FILE% && (
  xcopy /S /I /Y /F configuration\CNO\Datasets %PACKAGE_DIR%\configuration\CNO\Datasets>>%BUILD_LOG%
  xcopy configuration\90_import_cno_datasets.cmd %PACKAGE_DIR%\configuration>>%BUILD_LOG%
  echo CALL 90_import_cno_datasets.cmd.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
) || (
  echo REM CALL 90_import_cno_datasets.cmd.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
)

:: ### Look for changes in CNO preferences (imports all user, group and site preferences)
>nul find "configuration/preferences/cno_" %DIFF_FILE% && (
  IF NOT EXIST %PACKAGE_DIR%\configuration\preferences xcopy /S /I /Y /F configuration\preferences %PACKAGE_DIR%\configuration\preferences>>%BUILD_LOG%
  xcopy configuration\91_import_cno_preferences.cmd %PACKAGE_DIR%\configuration>>%BUILD_LOG%
  echo CALL 91_import_cno_preferences.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
) || (
  echo REM CALL 91_import_cno_preferences.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
)

:: ### Look for changes in CNO querries
>nul find "configuration/queries/CNO_VFW" %DIFF_FILE% && (
  xcopy /S /I /Y /F configuration\queries\CNO_VFW %PACKAGE_DIR%\configuration\queries\CNO_VFW>>%BUILD_LOG%
  xcopy configuration\92_import_cno_query.cmd %PACKAGE_DIR%\configuration>>%BUILD_LOG%
  echo CALL 92_import_cno_query.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
) || (
  echo REM CALL 92_import_cno_query.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
)

IF x%SKIP_ORGA_BOOL%==xtrue goto SKIP_ORGA

:: ### Look for changes in the organization
>nul find "configuration/organisation" %DIFF_FILE% && (
  xcopy /S /I /Y /F configuration\organisation %PACKAGE_DIR%\configuration\organisation>>%BUILD_LOG%
  echo cd organisation >> %INSTALL_SCRIPT%
  echo if %%TC_ENV%%==dev CALL 02_import_users_DEV.cmd >> %INSTALL_SCRIPT%
  echo if %%TC_ENV%%==qual CALL 03_import_users_QA.cmd >> %INSTALL_SCRIPT%
  echo if %%TC_ENV%%==mig CALL 03_import_users_QA.cmd >> %INSTALL_SCRIPT%
  echo cd .. >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
) || (
  echo REM cd organisation >> %INSTALL_SCRIPT%
  echo REM if %%TC_ENV%%==dev CALL 02_import_users_DEV.cmd >> %INSTALL_SCRIPT%
  echo REM if %%TC_ENV%%==qual CALL 03_import_users_QA.cmd >> %INSTALL_SCRIPT%
  echo REM if %%TC_ENV%%==mig CALL 03_import_users_QA.cmd >> %INSTALL_SCRIPT%
  echo REM cd .. >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
)

:SKIP_ORGA

:: ### Look for changes in SR5Custom library
>nul find "configuration/customization/tc/server/SR5Custom/SR5Custom" %DIFF_FILE% && (

  :: ### build dll and lib for sr5Custom
  CD customization\tc\server\SR5Custom\SR5Custom
  CALL build.bat
  CD %~dp0
  xcopy customization\tc\server\SR5Custom\SR5Custom\libSR5custom.dll %BIN_DIR%>>%BUILD_LOG%
  DEL /s customization\tc\server\SR5Custom\SR5Custom\libSR5custom.dll
  xcopy customization\tc\server\SR5Custom\SR5Custom\libSR5Custom.lib %BIN_DIR%>>%BUILD_LOG%
  DEL customization\tc\server\SR5Custom\SR5Custom\libSR5Custom.lib

  echo :EXCHANGE_BINARIES >> %INSTALL_SCRIPT%
  echo cd ../binaries >> %INSTALL_SCRIPT%
  echo xcopy /s libSR5custom.dll "%TC_ROOT%"\bin >> %INSTALL_SCRIPT%>>%BUILD_LOG%
  echo xcopy /s libSR5Custom.lib "%TC_ROOT%"\lib >> %INSTALL_SCRIPT%>>%BUILD_LOG%
  echo cd ../configuration >> %INSTALL_SCRIPT%
  echo if %%MODE%%==bin goto :EOF >> %INSTALL_SCRIPT%
  echo if %%MODE%%==corp goto :EOF >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT% >> %INSTALL_SCRIPT%
) || (
  echo REM :EXCHANGE_BINARIES >> %INSTALL_SCRIPT%
  echo REM cd ../binaries >> %INSTALL_SCRIPT%
  echo REM xcopy /s libSR5custom.dll "%TC_ROOT%"\bin >> %INSTALL_SCRIPT%
  echo REM xcopy /s libSR5Custom.lib "%TC_ROOT%"\lib >> %INSTALL_SCRIPT%
  echo REM cd ../configuration >> %INSTALL_SCRIPT%
  echo if %%MODE%%==bin goto :EOF >> %INSTALL_SCRIPT%
  echo if %%MODE%%==corp goto :EOF >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT% >> %INSTALL_SCRIPT%
)

:: ### Look for changes in Active Workspace client customization
>nul find "configuration/aw_src_updates" %DIFF_FILE% && (
  xcopy /S /I /Y /F configuration\aw_src_updates %PACKAGE_DIR%\configuration\aw_src_updates>>%BUILD_LOG%
  xcopy configuration\70_import_aw_src_updates.cmd %PACKAGE_DIR%\configuration>>%BUILD_LOG%
  echo :AW_SRC_UPDATE >> %INSTALL_SCRIPT%
  echo call 70_import_aw_src_updates.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
) || (
  echo :AW_SRC_UPDATE >> %INSTALL_SCRIPT%
  echo REM call 70_import_aw_src_updates.cmd >> %INSTALL_SCRIPT%
  echo. >> %INSTALL_SCRIPT%
)

:: ### TODO User Queries

:: ### Add footer to install script
type administration\utils\deployment_package\install_script_end.txt >> %INSTALL_SCRIPT%

echo * Successfuly built the installation script.
echo *
echo * Deployment package %PACKAGE_DIR% was generated.
echo * Please check the generated deployment package %PACKAGE_DIR% beforde proceeding.
echo *
SET /P CREATE_TAG= * Do you want to creata a new tag for the generated release? (Y/n)
IF %CREATE_TAG%==Y (
  git tag -a R%BUILD% -m "%VERSION%:%BUILD%"
)
ECHO *

SET /P CREATE_7Z=* Do you want to create a 7z-archive of the deployment package? (Y/n)
IF %CREATE_7Z%==Y (
  ECHO * Compressing deployment package into archive %PACKAGE_DIR%.7z
  CALL "%seven_zip%" a "%PACKAGE_DIR%.7z" %PACKAGE_DIR%>nul
  ECHO * Successfuly created archive.
)

GOTO :EOF

:: ### Exit if script is not run in a TC environment
:ENV_MISSING
ECHO You need to run this script in a Teamcenter environment
ECHO TC_ROOT = %TC_ROOT%
ECHO TC_DATA = %TC_DATA%
ENDLOCAL
GOTO :EOF