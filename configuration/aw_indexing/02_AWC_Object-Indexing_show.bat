@echo off

SET TC_ROOT=C:\splm\tc13
SET TC_DATA=C:\splm\tcdata

call %TC_DATA%\tc_profilevars

call %TC_ROOT%\TcFTSIndexer\bin\runTcFTSIndexer.bat -task=objdata:show  2 C:\Users\Administrator\Desktop\AWC_Indexing