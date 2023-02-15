@echo off

:ASK_CREDENTIALS
echo Type in password of "infodba"
set /P DBAPASS=Password: 


clearlocks -verbose

echo y | audit_purge -u=infodba -p=%DBAPASS% -g=dba -purge -retentionperiod=0 -logtype=Fnd0WorkflowAudit -sublogtype=process_audit
echo y | audit_purge -u=infodba -p=%DBAPASS% -g=dba -purge -retentionperiod=0 -logtype=Fnd0WorkflowAudit -sublogtype=signoff_audit
echo y | audit_purge -u=infodba -p=%DBAPASS% -g=dba -purge -retentionperiod=0 -logtype=Fnd0FileAccessAudit
echo y | audit_purge -u=infodba -p=%DBAPASS% -g=dba -purge -retentionperiod=0 -logtype=Fnd0SecurityAudit
echo y | audit_purge -u=infodba -p=%DBAPASS% -g=dba -purge -retentionperiod=0 -logtype=Fnd0LicenseExportAudit
echo y | audit_purge -u=infodba -p=%DBAPASS% -g=dba -purge -retentionperiod=0 -logtype=Fnd0DigitalSignatureAudit
echo y | audit_purge -u=infodba -p=%DBAPASS% -g=dba -purge -retentionperiod=0 -logtype=Fnd0OrganizationAudit
echo y | audit_purge -u=infodba -p=%DBAPASS% -g=dba -purge -retentionperiod=0 -logtype=Fnd0GeneralAudit
echo y | audit_purge -u=infodba -p=%DBAPASS% -g=dba -purge -retentionperiod=0 -logtype=Fnd0ScheduleAudit
echo y | audit_purge -u=infodba -p=%DBAPASS% -g=dba -purge -retentionperiod=0 -logtype=Fnd0LicenseChangeAudit
echo y | audit_purge -u=infodba -p=%DBAPASS% -g=dba -purge -retentionperiod=0 -logtype=Fnd0StructureAudit

index_verifier.exe -u=infodba -p=%DBAPASS% -g=dba -o=DO_IT

pause