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

echo -------------------------------------------------------------------------------------------------------------------

FOR %%f in (CNO\Datasets\*.txt) do (
	REM Try to delete the file only if it exists
    IF EXIST "..\logs\%%~nf.log" del /F "..\logs\%%~nf.log"
	echo import_file -vb %CREDENTIALS_TMP% -f=%%f -d=%%~nf -ref=Text -type=Text -de=r -log="..\logs\%%~nf.log"
	echo.
	import_file -vb %CREDENTIALS% -f=%%f -d=%%~nf -ref=Text -type=Text -de=r -log="..\logs\%%~nf.log"
	echo -------------------------------------------------------------------------------------------------------------------
)

FOR %%f in (CNO\Datasets\*.xlsm) do (
	REM Try to delete the file only if it exists
    IF EXIST "..\logs\%%~nf.log" del /F "..\logs\%%~nf.log"
	echo import_file -vb %CREDENTIALS_TMP% -f=%%f -d=%%~nf -ref=excel -type=MSExcelX -de=r -log="..\logs\%%~nf.log"
	echo.
	import_file -vb %CREDENTIALS% -f=%%f -d=%%~nf -ref=excel -type=MSExcelX -de=r -log="..\logs\%%~nf.log"
	echo -------------------------------------------------------------------------------------------------------------------
)

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
