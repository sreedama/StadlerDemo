setlocal
cd %~dp0

if exist deploy rd /S /Q deploy
if exist deploy (
	echo Error clering old "deploy" folder.
	exit /B 1
)

mkdir deploy

:: process all except customisations
for /D %%D in (acls,attribute-mapping,DxDatabook,EDA_report_templates,jenkins,preferences,queries,revision-rules,stylesheets,transfer-modes,workflows,configuration) do (
	if exist "%%D\build.bat" (
		pushd "%%D"
		cmd /C build.bat & if errorlevel 1 echo Error building "%%D" & exit /B 1
		popd
		mkdir "deploy\%%D"
		robocopy /E "%%D/deploy" "deploy\%%D" *
	)
)

git rev-list --count HEAD > deploy\jenkins-last-deploy-git.txt
robocopy jenkins deploy deploy.bat

exit /B 0