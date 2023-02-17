@if not defined ST4_SERVER_REVISION (
	echo ERROR: Variable "ST4_SERVER_REVISION" is not defined
	exit /B 1
)
@if not defined ST4_DEPLOY_LOGFILE (
	echo ERROR: Variable "ST4_DEPLOY_LOGFILE" is not defined
	exit /B 1
)
@if not defined ST4_TC_LOGIN (
	echo ERROR: Variable "ST4_TC_LOGIN" is not defined
	exit /B 1
)
@if not defined ST4_ENVIRONMENT_IS_MAIN_APP_SERVER (
	echo ERROR: Variable "ST4_ENVIRONMENT_IS_MAIN_APP_SERVER" is not defined
	exit /B 1
)
if not "xyes"=="x%ST4_ENVIRONMENT_IS_MAIN_APP_SERVER%" exit /B 0
if %1 leq %ST4_SERVER_REVISION% exit /B 0
@echo Deploying Workflow %~2 ... >> %ST4_DEPLOY_LOGFILE%
::cmd /C plmxml_import -transfermode=workflow_template_overwrite -import_mode=overwrite -ignore_originid -xml_file="%~2" %ST4_TC_LOGIN%
set command=plmxml_import -transfermode=workflow_template_overwrite -import_mode=overwrite -ignore_originid -xml_file="%~2"
echo %command%
cmd /C "%command% %ST4_TC_LOGIN%"
@if errorlevel 1 (
	echo Error importing "%~2"
	exit /B 1
)
