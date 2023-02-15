@setlocal
@cd %~dp0
@call %ST4_TC_INIT_SCRIPT%
@echo on
@set ST4_DEPLOY_TIMESTAMP=%BUILD_TIMESTAMP%
@set ST4_DEPLOY_LOGFILE=%WORKSPACE%\deploy-%COMPUTERNAME%-%ST4_DEPLOY_TIMESTAMP%.log
@echo Deployment started on %ST4_DEPLOY_TIMESTAMP% on %COMPUTERNAME% >  %ST4_DEPLOY_LOGFILE%
@echo Start deployment of Teamcenter live-deployable configuration andcustomizations

@if not defined TC_ROOT (
	echo Variable "TC_ROOT" is not defined
	exit /B 1
)

setlocal enabledelayedexpansion
if exist "%TC_ROOT%\jenkins-last-deploy-git.txt" (
	set /p SERVER_REVISION=< "%TC_ROOT%\jenkins-last-deploy-git.txt"
	echo server revision is: !SERVER_REVISION!
	echo Server revision is: !SERVER_REVISION! >>  %ST4_DEPLOY_LOGFILE%
) else (
	set SERVER_REVISION=0
	echo server revision not found, assuming 0
	echo Server revision not found, assuming 0 >>  %ST4_DEPLOY_LOGFILE%
)
endlocal & set ST4_SERVER_REVISION=%SERVER_REVISION%

set /p ST4_NEW_SERVER_REVISION=< "jenkins-last-deploy-git.txt"
echo package revision is: %ST4_NEW_SERVER_REVISION%
echo package revision is: %ST4_NEW_SERVER_REVISION% >>  %ST4_DEPLOY_LOGFILE%

@for /D %%D in (*) do (
	pushd "%%D"
	if exist deploy.bat cmd /C deploy.bat
	if errorlevel 1 (
		echo ERROR executing %%D\deploy.bat
		exit /B 1
	)
	popd
)

@echo Save the number of this deployment: %ST4_NEW_SERVER_REVISION% >>  %ST4_DEPLOY_LOGFILE%
copy jenkins-last-deploy-git.txt %TC_ROOT%\
if errorlevel 1 (
	echo Can't copy last git revision number to the server!
	exit /B 1
)

@echo Deployment finished successfully >>  %ST4_DEPLOY_LOGFILE%
@exit /B 0
