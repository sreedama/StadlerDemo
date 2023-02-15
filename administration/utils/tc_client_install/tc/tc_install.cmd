@echo off
REM 1. copy tc installables to c:\temp\ClientDeploymentPackage prior execution of this script
REM 2. copy java 8 64x to c:\plm\java\jre8 prior execution of this script
REM 3. install / copy NX to c:\opt\nx\DAG110111D3
REM 4. run this script as admin

"C:\temp\ClientDeploymentPackage\tc\11_2_3\Tc11.2.3_wntx64\wntx64\tem.bat" -jre C:\plm\java\jre8 -s="C:\TEMP\ClientDeploymentPackage\silent_v1_with_cad.xml"