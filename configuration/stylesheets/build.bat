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
	echo 	echo ERROR: Variable "ST4_ENVIRONMENT" is not defined
	echo 	exit /B 1
	echo ^)
	echo @echo Deploy Attribute Mapping to %%ST4_ENVIRONMENT%%
	echo @echo Deploy stylesheets to %%ST4_ENVIRONMENT%%
	echo if exist input.txt del input.txt
	echo if exist input.txt echo Error preparing to import stylesheets ^& exit /B 1
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

for /R %%F in ("*.xml") do call :build_one "%%F"


(
echo if not exist input.txt exit /B 0
echo echo Stylesheets to be deployed: ^>^> %%ST4_DEPLOY_LOGFILE%%
echo type input.txt ^>^> %%ST4_DEPLOY_LOGFILE%%
::echo 	cmd /C install_xml_stylesheet_datasets %%TC_LOGIN%% -input=input.txt -filepath=%%CD%% -replace ^& if errorlevel 1 echo Error importing stylesheets. ^& exit /B 1
echo echo Deploying stylesheets ^>^> %%ST4_DEPLOY_LOGFILE%%
echo set command=install_xml_stylesheet_datasets -input=input.txt -filepath=%%CD%% -replace
echo echo %%command%%
echo cmd /C "%%command%% %%ST4_TC_LOGIN%%"
echo @if errorlevel 1 ^(
echo 	echo Error importing stylesheets
echo 	exit /B 1
echo ^)
) >> deploy\deploy.bat

copy jenkins\deploy-one.bat deploy

exit /B 0
