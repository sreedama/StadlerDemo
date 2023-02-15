@echo off

cd /D "%~dp0"

if not defined TC_ROOT goto ENV_MISSING
if x%SILENT_MODE%==xTRUE goto START_PROCESS

echo Type in password of "infodba"
set /P DBAPASS=Password: 
set DBAPASS_TMP=******
cls

:START_PROCESS
REM Import organizational structure
echo Creating/updating organizational structure.
echo.

make_user.exe -u=infodba -p=%DBAPASS% -g=dba -file=organization_structure.lst

REM Assign default volumes to groups
echo Assigning default volumes to groups.
echo.

set /P defaultvolume=Type in name of default volume:

make_user.exe -u=infodba -p=%DBAPASS% -g=dba -group="TC Admin" -defaultvolume=%defaultvolume% -update
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -group="Material Management.Global.Stadler" -defaultvolume=%defaultvolume% -update
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -group="R&D.Global.Stadler" -defaultvolume=%defaultvolume% -update
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -group="Bid Packaging.Global.Stadler" -defaultvolume=%defaultvolume% -update
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -group="MDM.Global.Stadler" -defaultvolume=%defaultvolume% -update
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -group="Change Management.Global.Stadler" -defaultvolume=%defaultvolume% -update
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -group="Services.Global.Stadler" -defaultvolume=%defaultvolume% -update
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -group="Welding.Special Processes.Global.Stadler" -defaultvolume=%defaultvolume% -update
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -group="Structural.Special Processes.Global.Stadler" -defaultvolume=%defaultvolume% -update
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -group="Adhesive Bonding.Special Processes.Global.Stadler" -defaultvolume=%defaultvolume% -update
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -group="Business Partner.External.Stadler" -defaultvolume=%defaultvolume% -update
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -group="Engineering Supplier.External.Stadler" -defaultvolume=%defaultvolume% -update
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -group="Project Management.Internal.Stadler" -defaultvolume=%defaultvolume% -update
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -group="Manufacturing.Internal.Stadler" -defaultvolume=%defaultvolume% -update
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -group="MCAD.Engineering.Internal.Stadler" -defaultvolume=%defaultvolume% -update
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -group="ECAD.Engineering.Internal.Stadler" -defaultvolume=%defaultvolume% -update
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -group="Software.Engineering.Internal.Stadler" -defaultvolume=%defaultvolume% -update
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -group="Requirements.Engineering.Internal.Stadler" -defaultvolume=%defaultvolume% -update

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment