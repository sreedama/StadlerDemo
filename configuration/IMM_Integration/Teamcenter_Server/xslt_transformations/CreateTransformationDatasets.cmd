echo off

if not defined TC_ROOT ( 
	Echo TC_ROOT Variable not defined
	Echo Please Specify
	set /P TC_ROOT=TC_ROOT:
)

if not defined TC_DATA (
	Echo TC_DATA Variable not defined
	Echo Please Specify
	set /P TC_DATA=TC_DATA:
)

if not defined PWD ( 
	Echo PWD Variable not defined
	Echo Please Specify the infodba
	set /P PWD=PASSWORD:
)

call %TC_DATA%/tc_profilevars.bat

@rem Style sheets for Export
%TC_ROOT%/bin/import_file.exe -u=infodba -p=%PWD% -g=dba -f="./export/Mapping_CatiaMatml.xslt" -type=Text -ref=Text -d=IMM_Mapping_CatiaMatml -de=r


PAUSE