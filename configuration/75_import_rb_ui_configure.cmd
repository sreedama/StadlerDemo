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

REM Import Relation Browser Configuration files
echo.
echo import_file %CREDENTIALS% -d=RelationBrowserConf -type=Rv1XML -ref=Rv1XMLFile -de=r -f=aw_relationbrowser\rb_ui_configuration.xml

import_file %CREDENTIALS% -d=RelationBrowserConf -type=Rv1XML -ref=Rv1XMLFile -de=r -f=aw_relationbrowser\rb_ui_configuration.xml


echo import_file %CREDENTIALS% -d=RelationBrowserStyle -type=Rv1XML -ref=Rv1XMLFile -de=r -f=aw_relationbrowser\GraphStyle.xml

import_file %CREDENTIALS% -d=RelationBrowserStyle -type=Rv1XML -ref=Rv1XMLFile -de=r -f=aw_relationbrowser\GraphStyle.xml


echo import_file %CREDENTIALS% -d=RelationBrowserPresentationRule -type=Rv1XML -ref=Rv1XMLFile -de=r -f=aw_relationbrowser\PresentationRule.xml

import_file %CREDENTIALS% -d=RelationBrowserPresentationRule -type=Rv1XML -ref=Rv1XMLFile -de=r -f=aw_relationbrowser\PresentationRule.xml

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment