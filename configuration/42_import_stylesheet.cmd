@echo off

if not defined TC_ROOT goto ENV_MISSING
if x%SILENT_MODE%==xTRUE goto START_PROCESS
if defined UPG_CREDENTIALS goto START_PROCESS

:ASK_CREDENTIALS
echo Type in password of "infodba"
set /P DBAPASS=Password: 

:START_PROCESS
set CREDENTIALS=-u=infodba -p=%DBAPASS% -g=dba
set CREDENTIALS_TMP=-u=infodba -p=****** -g=dba
if defined UPG_CREDENTIALS set CREDENTIALS=%UPG_CREDENTIALS%
if defined UPG_CREDENTIALS_TMP set CREDENTIALS_TMP=%UPG_CREDENTIALS_TMP%

SET SRC_DIR=stylesheets\src
SET OUT_DIR=stylesheets\out
SET IMPORT_FILE=%OUT_DIR%\import_stylesheet.txt

REM Build the stylesheet import directory
IF NOT EXIST %OUT_DIR% (
    MKDIR %OUT_DIR%
    break>%IMPORT_FILE%
) ELSE (
    RMDIR %OUT_DIR% /s /q
    MKDIR %OUT_DIR%
    break>%IMPORT_FILE%
)

REM Copy all stylesheets in subfolders to out folder
FOR /D %%G in ("%SRC_DIR%\*") DO (
    
    ECHO Found stylesheets for %%~nxG
    XCOPY "%SRC_DIR%\%%~nxG\*.xml" %OUT_DIR% > nul
)

REM Build text file for bulk import
FOR /r %%F in ("%OUT_DIR%\*.xml") DO (
    ECHO %%~nF, %%~nxF>>%IMPORT_FILE%
)

REM Import Teamcenter stylesheet in bulk
echo install_xml_stylesheet_datasets %CREDENTIALS_TMP% -input=stylesheets\out\import_stylesheet.txt -filepath=stylesheets\out -replace
echo.
install_xml_stylesheet_datasets %CREDENTIALS% -input=stylesheets\out\import_stylesheet.txt -filepath=stylesheets\out -replace

REM Delet the out dir including copied stylesheets
IF EXIST %OUT_DIR% RMDIR %OUT_DIR% /s /q

echo.
echo -----------------------------------------------------------------------
echo START CACHE GENERATION
echo -----------------------------------------------------------------------
generate_client_meta_cache %CREDENTIALS% generate stylesheets
generate_metadata_cache %CREDENTIALS%	
echo -----------------------------------------------------------------------
echo FINISHED CACHE GENERATION
echo -----------------------------------------------------------------------
echo.

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
