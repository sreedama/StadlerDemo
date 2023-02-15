setlocal
cd %~dp0

if exist deploy rd /Q /S deploy
if exist deploy (
	echo Error removing old deploy folder
	exit /B 1
)
mkdir deploy

(
	echo @if not defined ST4_ENVIRONMENT ^(
	echo 	echo ERROR: Variable "MT4_ENVIRONMENT" is not defined
	echo 	exit /B 1
	echo ^)
	echo @echo Deploy Workflows to %%ST4_ENVIRONMENT%%
) > deploy\deploy.bat

goto start

:build_one
set FILENAME=%~1
set HASH=unknown
for /F %%H in ('git log "--format=""%%H""" -1 --show-pulls "%FILENAME%"') do set HASH=%%H
for /F %%R in ('git rev-list --count %HASH%') do set CHECKED_REVISION=%%R
copy "%FILENAME%" deploy
echo call deploy-one.bat %CHECKED_REVISION% "%FILENAME%" ^& if errorlevel 1 echo Error importing "%FILENAME%" ^& exit /B 1 >> deploy\deploy.bat
exit /B 0

:start

for %%F in (*.xml) do call :build_one "%%F"

copy jenkins\deploy-one.bat deploy

exit /B 0
