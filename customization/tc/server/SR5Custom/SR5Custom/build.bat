@echo on
cd /D %~dp0

del *.obj
del *.dll

call ..\common\compile_env.bat

REM Init
set MSDEV_HOME=C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC

REM Loop over all source-files(*.c, *.cpp, *.cxx) and compile them
for %%i in (*.c*) do call %TC_ROOT%\sample\compile -debug -DIPLIB=none "%%i"
::	echo ### ### ###
::	echo ### ### ### %%i
::	echo ### ### ###
::	call %TC_ROOT%\sample\compile -DIPLIB=none "%%i" & if errorlevel 1 echo Error compiling "%%i" & exit /B 1
::)

REM Linking     
call %TC_ROOT%\sample\link_custom_exits libSR5Custom & if errorlevel 1 echo Error linking libSR5Custom.dll & exit /B 1

REM Delete
del *.obj
del *.ilk
del *.exp
del *.pdb