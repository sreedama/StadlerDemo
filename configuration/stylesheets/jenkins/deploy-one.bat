@if not defined MT4_SERVER_REVISION (
	echo ERROR: Variable "MT4_SERVER_REVISION" is not defined
	exit /B 1
)
@if not defined MT4_DEPLOY_LOGFILE (
	echo ERROR: Variable "MT4_DEPLOY_LOGFILE" is not defined
	exit /B 1
)
@if not defined MT4_TC_LOGIN (
	echo ERROR: Variable "MT4_TC_LOGIN" is not defined
	exit /B 1
)
@if not defined MT4_ENVIRONMENT_IS_MAIN_APP_SERVER (
	echo ERROR: Variable "MT4_ENVIRONMENT_IS_MAIN_APP_SERVER" is not defined
	exit /B 1
)
if not "xyes"=="x%MT4_ENVIRONMENT_IS_MAIN_APP_SERVER%" exit /B 0
if %1 leq %MT4_SERVER_REVISION% exit /B 0
@echo Adding stylesheet %~2 to be deployed... >> %MT4_DEPLOY_LOGFILE%
echo %~n2, %~2 >> input.txt
@if errorlevel 1 (
	echo Error importing "%~2"
	exit /B 1
)
