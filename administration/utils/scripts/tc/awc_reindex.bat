@echo off


if not defined TC_ROOT goto ENV_MISSING
if not defined TC_DATA goto ENV_MISSING

REM check following paths if they are correct
set SOLR_HOME=%TC_ROOT%\solr-6.2.1

if not exist %SOLR_HOME% goto DIRS_NOT_FOUND

echo Type in password of "infodba"
set /P DBAPASS=Password: 
set DBAPASS_TMP=******

:START_PROCESS
echo.
echo confirm if Active Workspace indexing service is stopped
pause
cd /d %SOLR_HOME%
call TcSchemaToSolrSchemaTransform.bat %TC_DATA%\ftsi\solr_schema_files

echo.
echo confirm if Active Workspace indexing service, FSC and poolmanager are running
pause

cd /d %TC_ROOT%\TcFTSIndexer\bin
echo.
echo testing indexer...
call runTcFTSIndexer.bat -task=objdata:test

echo.
echo Do you want to drop existing index and re-index afterwards?
set /P DECISION=(Y)es or (N)o:
if /I "%DECISION%"=="Y" goto DROP_INDEX
if /I "%DECISION%"=="N" goto INDEX_DATA

:DROP_INDEX
echo.
echo dropping index...
call runTcFTSIndexer.bat -task=objdata:clear

:INDEX_DATA
echo.
echo indexing data...
call runTcFTSIndexer.bat -task=objdata:index

echo.
echo confirm that live indexing scheduled task is started again
pause

echo DONE

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
goto :EOF

:DIRS_NOT_FOUND
echo the following directories must exist or need to be adjusted in this script
echo    SOLR_HOME=%SOLR_HOME%
goto :EOF