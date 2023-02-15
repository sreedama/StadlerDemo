@echo off

REM ********************************************************************************
REM This script allows the user to customize the JT translation tools
REM V4_EXE defines the executable to be used for CATIA V4 model to JT translation
REM V5_EXE defines the executable to be used for CATIA V5 Part and Product files to JT translation
REM Default behavior is to use THEOREM translator for all conversions.
REM On Windows, there is no SIEMENS Translator to convert V4 model into JT
REM 
REM This script takes 3 input parameters:
REM  -1st parameter: conversion type (0, 1 or 2)
REM      -0 : for converting a CATProduct
REM      -1 : for converting V4 files
REM      -2: form converting V5 files.
REM - 2d parameter: file(s) to convert:
REM      - if 1st parameter is 0, then the seconad parameter is file name (with full path).
REM      - else the 2d parameters is a directory path that contains the files to be converted. 
REM - 3d parameter: the output directory. this directory will contain the JT files.
REM 

REM  The directory where The Translator is installed.
REM     example for THEOREM translator: set TS_INST="C:\Theorem"
REM     example for SIEMENS translator: set TS_INST="C:\Translators\CATIAV5TOJT\6.2.1"
REM  Important : Do not forget to use quotes when the path contains spaces
set TS_INST="C:\Theorem"

REM Following CATIA environment should be set when using Theorem conversion:
REM variables CATIAV5_ENV and CATIAV5_DIRENV - similar to the CATIA V5 concept in that the first variable 
REM points to the file without the file extension and the second variable point to the directory that holds the file.
REM E.g.
set CATIAV5_ENV=Teamcenter_Integration_for_CATIAV5
set CATIAV5_DIRENV=C:\Program Files\Dassault Systemes\CATEnv

REM Translator executable:
REM example for THEOREM translator: 
REM       V5_EXE=%TS_INST%\bin\catia5r19_jt.cmd
REM       V4_EXE=%TS_INST%\bin\catfil_jt.cmd
REM example for SIEMENS translator (On Windows, there is no SIEMENS Translator to convert V4 model into JT): 
REM       V5_EXE=%TS_INST%\jt_catiav5.exe

set V5_EXE=%TS_INST%\bin\catia5r19_jt.cmd
set V4_EXE=%TS_INST%\bin\catfil_jt.cmd

REM ********************************************************************************
IF [%1]==[] goto END
IF [%2]==[] goto END
IF [%3]==[] goto END
IF [%1]==[0] goto PRODUCT
IF [%1]==[1] goto V4
goto V5  

:PRODUCT
    IF NOT EXIST "%V5_EXE%" Goto TRANSLATOR_ERROR
    REM *********************    
    REM THEOREM translator
    REM *********************
    call %V5_EXE% "%~2" -output_dir "%~3" -config "%TCICV5_DIR%\bin\WIN32\convert_catiav5producttojt.config">"%~3"\cattojt.out
    
    REM *********************
    REM Siemens Translator
    REM *********************
    REM call %V5_EXE% "%~2" -outputDirectory="%~3" -LogFileName="cat_file" -appendCADExtension="none" "%TCICV5_DIR%\bin\WIN32\convert_catiav5producttojt.config">"%~3"\cattojt.out
    goto END
:V4
    IF NOT EXIST "%V4_EXE%" Goto TRANSLATOR_ERROR
    REM comment the following line if Theorem is not used
    %V4_EXE% -input_dir "%~2" -output_dir "%~3">"%~3"\cattojt.out
    goto END
:V5
    IF NOT EXIST "%V5_EXE%" Goto TRANSLATOR_ERROR
    REM *********************    
    REM THEOREM translator
    REM *********************
    call %V5_EXE% -input_dir "%~2" -output_dir "%~3" -config "%TS_INST%\etc\tessCATIA5.config">"%~3"\cattojt.out
    
    REM *********************
    REM Siemens Translator
    REM *********************
    REM call %V5_EXE% -dir="%~2" -outputDirectory="%~3" -LogFileName="cat_file" -appendCADExtension="none" %TS_INST%\etc\catiatojt.config>"%~3"\cattojt.out
    goto END

:TRANSLATOR_ERROR
Exit 10
:END
Exit 0
