@echo off
setlocal

call "C:\plm\tc112\install\tem_init.bat"

set TPR=C:\plm\tc112\portal
set JRE_HOME=%TC_JRE_HOME%
set CMD=call Teamcenter.exe -vm "%JRE_HOME%\bin\javaw.exe" -application com.teamcenter.rac.util.RegistryLoader -nosplash
set VMARGS=-vmargs -Xmx128m

cd /d "%TPR%"

%CMD% -nl de %VMARGS%
%CMD% -nl en %VMARGS%

:END_SCRIPT
exit /b %ERRORLEVEL%
endlocal
echo on
