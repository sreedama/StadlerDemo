@echo off

if not defined TC_ROOT goto ENV_MISSING
echo Type in password of "infodba"
set /P DBAPASS=Password: 
set DBAPASS_TMP=******
echo.
set /P GRP_EXP=Group to export: 


REM Export Organisation Tree
echo.
echo dsa_util -u=infodba -p=%DBAPASS_TMP% -g=dba -class=Group -f=export -name=%GRP_EXP% -filename=%GRP_EXP%_organisation.xml
dsa_util -u=infodba -p=%DBAPASS% -g=dba -class=Group -f=export -name=%GRP_EXP% -filename=%GRP_EXP%_organisation.xml

echo.
echo IMPORTANT: Please remove the site information before importing the file on another site (DSA_export_site). Usually line 6 to 8 in XML file.

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment
