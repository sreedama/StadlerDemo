@echo on

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


set ITEM_ID=013699

REM Enable product scoping
qsearch_process_queue %CREDENTIALS% -enable_product_scoping
REM pause
 
REM Make assembly indexable
qsearch_process_queue %CREDENTIALS% -make_indexable -product=%ITEM_ID%
REM pause
 
REM create BBOX + TSO ... Start Dispatcher with "jttobboxandtso" service
set QSEARCH_update_enabled=false
create_or_update_bbox_and_tso.exe %CREDENTIALS% -translation_mode=JTTOBBOX+JTTOTSO -mode=query+process -scope=product -product=%ITEM_ID% -output_dir=c:\temp\BBOX_TSO
REM pause
 
REM Process sub structure
set QSEARCH_update_enabled=true
qsearch_process_queue.exe %CREDENTIALS% -product=%ITEM_ID% -force_queue_product_substructure_update
REM pause

REM Force the Queue -> Dispatcher needs to be finalized?!?!
qsearch_process_queue.exe %CREDENTIALS% -process_queue
REM pause

REM Check
qsearch_process_queue.exe %CREDENTIALS% -check_product_indexes -product=%ITEM_ID%
REM pause

REM Trigger indexing
smart_discovery_index %CREDENTIALS% -create -product=%ITEM_ID%
REM pause


goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
