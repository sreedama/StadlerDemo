@echo off
:: Set TC_ROOT
SET TC_ROOT=D:\plm\tc13
SET TC_DATA=D:\PLMShare\tc_data13
SET AWC_STAGE_DIR=%TC_ROOT%\aws2\stage

:: Call TC_profilevars
CALL %TC_DATA%\tc_profilevars.bat

:: Disable open collective
SET DISABLE_OPENCOLLECTIVE=true

:: Add Node.js to PATH
SET PATH=%AWC_STAGE_DIR%\bin\wntx64\nodejs;%AWC_STAGE_DIR%\bin;%AWC_STAGE_DIR%\node_modules\.bin;%PATH%