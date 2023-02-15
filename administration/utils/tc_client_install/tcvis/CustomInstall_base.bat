@echo off
rem --------------------------------------------------------------------
rem
rem This script provides a template for customizing and launching the
rem Teamcenter Visualization 11.2.3 installer.  Controlling the installer
rem in this manner will:
rem
rem     * allow for preselection of features to be installed
rem     * prefill required fields (e.g. licensing options)
rem     * ease deployment to a large number of users.
rem
rem To use this script, simply uncomment and fill in the proper options
rem below, and choose the proper features to be installed, or feel free
rem to otherwise modify it to fit your use case.
rem
rem For some Windows Installer options, there are more possible values than
rem are listed here.  For the complete Windows Installer command line reference, see
rem http://msdn.microsoft.com/library/default.asp?url=/library/en-us/msi/setup/command_line_options.asp
rem
rem --------------------------------------------------------------------
rem
rem Important Notes on Setup Prerequisites:
rem  1. The TcVis installer requires Windows Installer version 3.1 or higher.
rem     If the required level of Windows Installer is not present, this install
rem     script will fail.  Windows Installer 3.1 has been available long enough
rem     that this will generally not be a problem.
rem
rem  2. Certain Microsoft Visual Studio (MSVC++) runtime libraries
rem     must be installed before running the TcVis installer.   If you run the TcVis
rem     installer by invoking 'setup.exe' they will be automatically installed for you.
rem     However, if you launch the TcVis installer by directly invoking the msi file
rem     (e.g. by using a variant of this batch file) then the MSVC++ runtimes will
rem     not be automatically installed, and you will have to install them separately.
rem
rem  2a. Microsoft Visual Studio 2012 Update 1
rem     Location:
rem       Included with this distribution in the "ISSetupPrerequisites\VS2012U1" directory.
rem     Detection:
rem       The 64-bit VS2012U1 MSVC++ runtime has been installed if any of these keys exist:
rem       HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{5AF4E09F-5C9B-3AAF-B731-544D3DC821DD}
rem       HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{2EDC2FA3-1F34-34E5-9085-588C9EFD1CC6}
rem       HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{CF2BEA3C-26EA-32F8-AA9B-331F7E34BA97}
rem     Installation:
rem       To launch the 64-bit redist installer this command may be used:
C:\TEMP\ClientDeploymentPackage\tcvis\TcVis_1123_20161212_win64\ISSetupPrerequisites\VS2012U1\vcredist_x64.exe /quiet
rem
rem  2b. Microsoft Visual Studio 2013, both _x86 and _x64 runtimes required.
rem     Location:
rem       Included with this distribution in the "ISSetupPrerequisites\VS2013" directory.
rem     Detection (_x86):
rem       The 32-bit VS2013 MSVC++ runtime has been installed if this key exists:
rem       HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{F65DB027-AFF3-4070-886A-0D87064AABB1}
rem     Installation (_x86):
rem       To launch the 32-bit redist installer this command may be used:
C:\TEMP\ClientDeploymentPackage\tcvis\TcVis_1123_20161212_win64\ISSetupPrerequisites\VS2013\vcredist_x86.exe /quiet
rem     Detection (_x64):
rem       The 64-bit VS2013 MSVC++ runtime has been installed if this key exists:
rem       HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{A749D8E6-B613-3BE3-8F5F-045C84EBA29B}
rem     Installation (_x64):
rem       To launch the 64-bit redist installer this command may be used:
C:\TEMP\ClientDeploymentPackage\tcvis\TcVis_1123_20161212_win64\ISSetupPrerequisites\VS2013\vcredist_x64.exe /quiet
rem
rem  2c. Microsoft Visual Studio 2015
rem     Location:
rem       Included with this distribution in the "ISSetupPrerequisites\VS2015" directory.
rem     Detection:
rem       The 64-bit VS2015 MSVC++ runtime has been installed if this key exists:
rem       HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{36F68A90-239C-34DF-B58C-64B30153CE35}
rem     Installation:
rem       To launch the 64-bit redist installer this command may be used:
C:\TEMP\ClientDeploymentPackage\tcvis\TcVis_1123_20161212_win64\ISSetupPrerequisites\VS2015\vc_redist.x64.exe /quiet
rem
rem --------------------------------------------------------------------
setlocal

rem default values which can be overridden by cmd line args
rem --------------------------------------------------------------------
rem define msi name
rem --------------------------------------------------------------------
set MSI=Teamcenter_Visualization_11_2_3_win64.msi
rem --------------------------------------------------------------------
rem define default install-to directory
rem --------------------------------------------------------------------
set INSTALLDIR=C:\plm\tcvis112


rem argument processing
if "%1" == "" goto argscomplete
:parseargs
if /i "%1" == "" goto argscomplete
if /i not "%1" == "-msi" goto nomsiarg
	shift
	if /i "%1" == "" goto argerror
	set MSI=%1
	echo %MSI%
	set MSIARG=true
:nomsiarg
if /i not "%1" == "-installdir" goto noinstalldirarg
	shift
	if /i "%1" == "" goto argerror
	set INSTALLDIR=%1
:nextpiece
	shift
	if /i "%1" == "" goto argscomplete
	if /i "%1" == "-msi" goto parseargs
	set INSTALLDIR=%INSTALLDIR% %1
	goto nextpiece
:noinstalldirarg
shift
goto parseargs

:argerror
echo.
echo ERROR: Invalid or missing argument.
pause
echo.
goto exit

:argscomplete

if "%MSIARG%" == "true" goto nopushd
rem If using default msi file, assume it is up 1 dir level, and pushd there
pushd %~dp0..
:nopushd

rem begin with blank options strings
set OPTIONS=
set FEATURES=


rem --------------------------------------------------------------------
rem specify silent mode option (optional, select none or one only)
rem --------------------------------------------------------------------
rem total silence
rem set OPTIONS=%OPTIONS% -qn
rem silence except for modal "done" at end
rem set OPTIONS=%OPTIONS% -qn+
rem show progress dialog
set OPTIONS=%OPTIONS% -qb


rem --------------------------------------------------------------------
rem specify the language for the install itself
rem --------------------------------------------------------------------
rem Spanish
rem set OPTIONS=%OPTIONS% TRANSFORMS=1034.mst
rem French
rem set OPTIONS=%OPTIONS% TRANSFORMS=1036.mst
rem German
set OPTIONS=%OPTIONS% TRANSFORMS=1031.mst
rem Italian
rem set OPTIONS=%OPTIONS% TRANSFORMS=1040.mst
rem Czech
rem set OPTIONS=%OPTIONS% TRANSFORMS=1029.mst
rem Polish
rem set OPTIONS=%OPTIONS% TRANSFORMS=1045.mst
rem Portuguese (Brazil)
rem set OPTIONS=%OPTIONS% TRANSFORMS=1046.mst
rem Japanese
rem set OPTIONS=%OPTIONS% TRANSFORMS=1041.mst
rem Korean
rem set OPTIONS=%OPTIONS% TRANSFORMS=1042.mst
rem Chinese (Simplified)
rem set OPTIONS=%OPTIONS% TRANSFORMS=2052.mst
rem Chinese (Traditional)
rem set OPTIONS=%OPTIONS% TRANSFORMS=1028.mst
rem Russian
rem set OPTIONS=%OPTIONS% TRANSFORMS=1049.mst


rem --------------------------------------------------------------------
rem create a log of the installation (optional)
rem --------------------------------------------------------------------
set OPTIONS=%OPTIONS% -l* "C:\Temp\TcVisLog.txt"


rem --------------------------------------------------------------------
rem set licensing options - choose proper option, set proper values
rem for hostname/port or license file location
rem --------------------------------------------------------------------
rem using license server
set OPTIONS=%OPTIONS% LICENSE_TYPE=2 SERVER_NAME=2141aslic2 SERVER_PORT=28000
rem if using multiple servers, specify like this:
rem set OPTIONS=%OPTIONS% LICENSE_TYPE=2 SERVER_NAME=port@hostname1;port@hostname2;etc
rem using node-locked license file
rem set OPTIONS=%OPTIONS% LICENSE_TYPE=1 LICENSE_INFO_FILE="C:\Temp\MyLicense.dat"


rem --------------------------------------------------------------------
rem set Help server location
rem   Just set HELP_SERVER_SIEMENS=1 to use Siemens.com for help files
rem --------------------------------------------------------------------
rem set OPTIONS=%OPTIONS% HELP_SERVER_SIEMENS=1
rem set OPTIONS=%OPTIONS% HELP_SERVER_SIEMENS=0 HELP_SERVER_NAME=hostname HELP_SERVER_PORT=port


rem --------------------------------------------------------------------
rem set limit for license borrowing--this is only valid for the
rem VisLicenseborrow Windows client application.  Set to desired value.
rem --------------------------------------------------------------------
rem set OPTIONS=%OPTIONS% MAX_BORROW_HOURS=48


rem --------------------------------------------------------------------
rem set install-to location
rem (don't change value here--change default at beginning of script, or pass arg)
rem --------------------------------------------------------------------
set OPTIONS=%OPTIONS% INSTALLDIR="%INSTALLDIR%"


rem --------------------------------------------------------------------
rem optionally remove old (pre-5.0) versions of Vis Products
rem Notes: 1. 5.0 and later versions can co-exist with this version.
rem        2. To remove 5.0 and later versions, use these commands:
rem           TcVis 5.0:
rem             msiexec -x {0F0B945F-357D-48FB-A349-C3A4F7B692FA} -qn
rem           TcVis 5.1:
rem             msiexec -x {8C865A5F-90D6-4AD6-8323-530108C14CFE} -qn
rem           TcVis 2005:
rem             msiexec -x {41BA74DF-31E9-4054-826B-9AC77A6994E3} -qn
rem           TcVis 2005 SR1 (win32):
rem             msiexec -x {F16C6F9E-5974-4759-87B5-D84B4DEED99B} -qn
rem           TcVis 2005 SR1 (win64):
rem             msiexec -x {2D929DE4-C03E-4E58-8170-FE8CF26CD8E5} -qn
rem           TcVis 2007 (win32):
rem             msiexec -x {BF141CE6-067D-47E5-AEC0-B080B107BD02} -qn
rem           TcVis 2007 (win64):
rem             msiexec -x {78566424-2104-4258-84D3-AA050FDF8205} -qn
rem           TcVis 2007.2 (win32):
rem             msiexec -x {A668660C-D8C2-4644-80BC-CFEDB97C36CE} -qn
rem           TcVis 2007.2 (win64):
rem             msiexec -x {A4074B1D-E7A9-464A-8787-82CA500F519B} -qn
rem           TcVis 8.0 (win32):
rem             msiexec -x {EC6011D8-D561-4684-9F18-E74B1B3C198D} -qn
rem           TcVis 8.0 (win64):
rem             msiexec -x {BE42BB2C-79E9-4566-98E2-6234CF54D762} -qn
rem           TcVis 8.1 (win32):
rem             msiexec -x {BB55B702-8659-486A-9335-0420DDFC45A3} -qn
rem           TcVis 8.1 (win64):
rem             msiexec -x {A9803A81-721A-42BC-B609-2AD90898B968} -qn
rem           TcVis 8.2 (win32):
rem             msiexec -x {2E7F5BBD-8068-45F5-BB86-7626CB55C677} -qn
rem           TcVis 8.2 (win64):
rem             msiexec -x {C6421567-3C6B-47D7-9EFD-ADF2FD25438D} -qn
rem           TcVis 8.3 (win32):
rem             msiexec -x {A7511BA1-00AC-4922-9C8E-5C7066343DE5} -qn
rem           TcVis 8.3 (win64):
rem             msiexec -x {434BB36B-4F54-410F-99BF-70187B74A406} -qn
rem           TcVis 9.0 (win32):
rem             msiexec -x {93ECA3FD-1CB2-4670-AFB6-304903296267} -qn
rem           TcVis 9.0 (win64):
rem             msiexec -x {6A83AF8A-F92A-4329-AE39-A8E52DB54188} -qn
rem           TcVis 9.1 (win32):
rem             msiexec -x {711D79F4-4D45-4889-B95E-4F35022F11A4} -qn
rem           TcVis 9.1 (win64):
rem             msiexec -x {E508B3E7-97CE-4D65-B0CB-7CFF967A057B} -qn
rem           TcVis 10.0 (win32):
rem             msiexec -x {CE108907-215B-449C-BE30-71B4C7B15C2E} -qn
rem           TcVis 10.0 (win64):
rem             msiexec -x {91DDD1AD-7BFC-4BEB-AB3F-04D6117200D2} -qn
rem           TcVis 10.1 (win32):
rem             msiexec -x {07BC55FF-6D74-432A-AE92-30E819968224} -qn
rem           TcVis 10.1 (win64):
rem             msiexec -x {20DE69F5-BBA1-4F4D-A713-2584BEEFC925} -qn
rem           TcVis 11.1 (win64):
rem             msiexec -x {83667B88-BCD7-4E36-AB8B-F20E3D8A6189} -qn
rem  If you want to remove an earlier version, just uncomment the appropriate
rem  line above.  See also the file 'uninstall.bat' for more details/options
rem --------------------------------------------------------------------
rem set OPTIONS=%OPTIONS% REMOVE_OLD_PRODUCTS=1


rem --------------------------------------------------------------------
rem set foreign language options (optional)
rem --------------------------------------------------------------------
rem set OPTIONS=%OPTIONS% INSTALL_SPANISH=1
set OPTIONS=%OPTIONS% INSTALL_GERMAN=1
rem set OPTIONS=%OPTIONS% INSTALL_FRENCH=1
rem set OPTIONS=%OPTIONS% INSTALL_ITALIAN=1
rem set OPTIONS=%OPTIONS% INSTALL_CZECH=1
rem set OPTIONS=%OPTIONS% INSTALL_PORTUGUESE=1
rem set OPTIONS=%OPTIONS% INSTALL_POLISH=1
rem set OPTIONS=%OPTIONS% INSTALL_JAPANESE=1
rem set OPTIONS=%OPTIONS% INSTALL_KOREAN=1
rem set OPTIONS=%OPTIONS% INSTALL_SCHINESE=1
rem set OPTIONS=%OPTIONS% INSTALL_TCHINESE=1
rem set OPTIONS=%OPTIONS% INSTALL_RUSSIAN=1


rem --------------------------------------------------------------------
rem option to NOT install desktop shortcuts
rem Note: Start Menu shortcuts are always installed
rem --------------------------------------------------------------------
rem set OPTIONS=%OPTIONS% NO_DTSC=1


rem --------------------------------------------------------------------
rem option to launch VisFastStart.exe at the conclusion of the install
rem Note: VisFastStart is always set to launch on reboot/login, and this
rem  option is really only useful if the user doing the install is the
rem  user who will run the application.
rem --------------------------------------------------------------------
rem set OPTIONS=%OPTIONS% START_FASTSTART=1


rem --------------------------------------------------------------------
rem option to install a PostScript printer.  READ IMPORTANT CAVEATS BELOW!
rem Notes: 
rem  - TcVis needs a PS printer to view, convert, or print external
rem    application documents such as MS Word, Excel, and PowerPoint.
rem  - On Windows XP, it is automatically installed
rem  - On Vista/Win7, you'll need to use this option (or equivalent)
rem  - The propery value is the file to use as Local port for the printer.
rem    This location must be writable by end users.
rem  Caveats: You may get a Windows Logo warning dialog during the install
rem     This dialog will have to be manually accepted,
rem     and WILL INTERFERE WITH A SILENT INSTALL!
rem  -> Do not use this option if you are running an unattended install
rem  Alternative Method: after vis install, install PS printer with
rem    <INSTALLDIR>\VVCP\Drivers\InstallPrinter.bat (admin rights required)
rem --------------------------------------------------------------------
rem set OPTIONS=%OPTIONS% VVCP_PS_PRINTER=C:\temp\psout.ps


rem --------------------------------------------------------------------
rem set alternate default registry [HKCU] file(s) (optional)
rem   path to files can be full path, or if file exists in the directory
rem   next to the .msi, can specify file name only.
rem If installing from a mapped drive location, you will need to
rem   either use a UNC path to the defaultreg file(s), or copy them locally.
rem Registry files must be in REGEDIT4 format.
rem --------------------------------------------------------------------
rem set OPTIONS=%OPTIONS% DEFAULTREG_VVBASE="C:\temp\vvbase_reg.reg"
rem set OPTIONS=%OPTIONS% DEFAULTREG_VVSTD="C:\temp\vvstd_reg.reg"
rem set OPTIONS=%OPTIONS% DEFAULTREG_VVPRO="C:\temp\vvpro_reg.reg"
rem set OPTIONS=%OPTIONS% DEFAULTREG_VMU="C:\temp\vmu_reg.reg"


rem --------------------------------------------------------------------
rem Complete Feature list.  Uncomment features to be installed
rem --------------------------------------------------------------------

rem Visualization Base + optional features:
set FEATURES=%FEATURES%VVBase,
set FEATURES=%FEATURES%VVBase_2d_ug,
set FEATURES=%FEATURES%VVBase_3d,
set FEATURES=%FEATURES%VVBase_ecad,

rem Visualization Standard + optional features:
rem set FEATURES=%FEATURES%VVStd,
rem set FEATURES=%FEATURES%VVStd_ecad,
rem set FEATURES=%FEATURES%VVStd_ug,
rem set FEATURES=%FEATURES%VVStd_issues,
rem set FEATURES=%FEATURES%VVStd_vr,
rem set FEATURES=%FEATURES%VVStd_iges,
rem set FEATURES=%FEATURES%VVStd_step,
rem set FEATURES=%FEATURES%VVStd_dxf,
rem set FEATURES=%FEATURES%VVStd_stl,
rem set FEATURES=%FEATURES%VVStd_vrml,

rem Visualization Professional + optional features:
rem set FEATURES=%FEATURES%VVPro,
rem set FEATURES=%FEATURES%VVPro_animation,
rem set FEATURES=%FEATURES%VVPro_ecad,
rem set FEATURES=%FEATURES%VVPro_issues,
rem set FEATURES=%FEATURES%VVPro_publish,
rem set FEATURES=%FEATURES%VVPro_vsa,
rem set FEATURES=%FEATURES%VVPro_vsa_flex,
rem Note: select only one of VVPro_dpv and VVPro_quality, not both
rem set FEATURES=%FEATURES%VVPro_dpv,
rem set FEATURES=%FEATURES%VVPro_quality,
rem set FEATURES=%FEATURES%VVPro_ug,
rem set FEATURES=%FEATURES%VVPro_adams,
rem set FEATURES=%FEATURES%VVPro_concept_desktop,
rem set FEATURES=%FEATURES%VVPro_concept_showroom,
rem set FEATURES=%FEATURES%VVPro_vr,
rem set FEATURES=%FEATURES%VVPro_iges,
rem set FEATURES=%FEATURES%VVPro_step,
rem set FEATURES=%FEATURES%VVPro_step_export,
rem set FEATURES=%FEATURES%VVPro_dxf,
rem set FEATURES=%FEATURES%VVPro_stl,
rem set FEATURES=%FEATURES%VVPro_vrml,

rem Visualization Mockup + optional features:
rem set FEATURES=%FEATURES%VMU,
rem set FEATURES=%FEATURES%VMU_analysis,
rem set FEATURES=%FEATURES%VMU_animation,
rem set FEATURES=%FEATURES%VMU_ecad,
rem set FEATURES=%FEATURES%VMU_pathplan,
rem set FEATURES=%FEATURES%VMU_jack,
rem set FEATURES=%FEATURES%VMU_publish,
rem set FEATURES=%FEATURES%VMU_vsa,
rem set FEATURES=%FEATURES%VMU_vsa_flex,
rem Note: select only one of VMU_dpv and VMU_quality, not both
rem set FEATURES=%FEATURES%VMU_dpv,
rem set FEATURES=%FEATURES%VMU_quality,
rem set FEATURES=%FEATURES%VMU_ug,
rem set FEATURES=%FEATURES%VMU_issues,
rem set FEATURES=%FEATURES%VMU_adams,
rem set FEATURES=%FEATURES%VMU_concept_desktop,
rem set FEATURES=%FEATURES%VMU_concept_showroom,
rem set FEATURES=%FEATURES%VMU_vr,
rem set FEATURES=%FEATURES%VMU_iges,
rem set FEATURES=%FEATURES%VMU_step,
rem set FEATURES=%FEATURES%VMU_step_export,
rem set FEATURES=%FEATURES%VMU_dxf,
rem set FEATURES=%FEATURES%VMU_stl,
rem set FEATURES=%FEATURES%VMU_vrml,

rem VisAutomationApp:
rem set FEATURES=%FEATURES%VisAutomationApp,

rem Clearance DB Features:
rem set FEATURES=%FEATURES%CDB_Calc,
rem set FEATURES=%FEATURES%CDB_Client,
rem set FEATURES=%FEATURES%CDB_Proxy,
rem set FEATURES=%FEATURES%CDB_Server,

rem Visualization Convert and Print + optional features:
rem set FEATURES=%FEATURES%VVConvert,
rem set FEATURES=%FEATURES%VVPrint,

rem Miscellaneous (non-product specific) optional features:
rem set FEATURES=%FEATURES%Help,
rem set FEATURES=%FEATURES%FastStart,
rem set FEATURES=%FEATURES%PMI_fonts,
rem set FEATURES=%FEATURES%LicenseBorrow,
rem set FEATURES=%FEATURES%Examples_2D,
rem set FEATURES=%FEATURES%Examples_3D,
rem set FEATURES=%FEATURES%Examples_XML,
rem set FEATURES=%FEATURES%Examples_CDB,
rem set FEATURES=%FEATURES%Examples_ECAD,
rem set FEATURES=%FEATURES%Examples_Factory,
rem set FEATURES=%FEATURES%Examples_Automation,
rem set FEATURES=%FEATURES%Examples_Publish,
rem set FEATURES=%FEATURES%Examples_Concept,
rem set FEATURES=%FEATURES%Examples_Jack,
rem set FEATURES=%FEATURES%Examples_VSA,

rem --------------------------------------------------------------------
rem Launch the install
rem --------------------------------------------------------------------
if not "%FEATURES%" == "" goto doit
echo Error: No features specified
pause
goto end

:doit
rem launch installer
start msiexec -i "%MSI%" %OPTIONS% ADDLOCAL=%FEATURES%

:end
if "%MSIARG%" == "true" goto nopopd
popd
:nopopd

:exit
endlocal