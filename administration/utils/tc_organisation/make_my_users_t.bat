@echo off

if not defined TC_ROOT goto ENV_MISSING
if x%SILENT_MODE%==xTRUE goto START_PROCESS

echo Type in password of "infodba"
set /P DBAPASS=Password: 
set DBAPASS_TMP=******

:START_PROCESS
REM Import users
echo.

make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Oliver Kirsten" -user="u565525" -group="Konstruktion.Engineering.voestalpine" -role="Konstrukteur" -PA9="oliver.kirsten@lmtec.eu"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Oliver Kirsten" -user="u565525" -group="dba" -role="DBA" -PA9="oliver.kirsten@lmtec.eu"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Gabriel Langenbacher" -user="u566599" -group="dba" -role="DBA" -PA9="gabriel.langenbacher@lmtec.eu"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Gabriel Langenbacher" -user="u566599" -group="Konstruktion.Engineering.voestalpine" -role="Konstrukteur" -PA9="gabriel.langenbacher@lmtec.eu"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Natalie Mackintosh" -user="u176413" -group="Controlling_RFQ_PM.Projektmanagement.voestalpine" -role="Controller" -PA9="Natalie.Mackintosh@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Maren Frank" -user="u199803" -group="dba" -role="DBA" -PA9="Maren.Frank@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Maren Frank" -user="u199803" -group="Projektadministration" -role="Projektadministrator" -PA9="Maren.Frank@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Maren Frank" -user="u199803" -group="Projektleitung.Projektmanagement.voestalpine" -role="Projektleiter" -PA9="Maren.Frank@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Maren Frank" -user="u199803" -group="Produktdesign.Engineering.voestalpine" -role="Produktdesigner" -PA9="Maren.Frank@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Theodor Zoller" -user="u490029" -group="Planung.Assembly.Engineering.voestalpine" -role="Planer" -PA9="Theodor.Zoller@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Waldemar Gohl" -user="u502329" -group="Produktdesign.Engineering.voestalpine" -role="Produktdesigner" -PA9="Waldemar.Gohl@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Waldemar Gohl" -user="u502329" -group="Konstruktion.Engineering.voestalpine" -role="Konstrukteur" -PA9="Waldemar.Gohl@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Viktor Schulz" -user="u503781" -group="Projektierung.Assembly.Engineering.voestalpine" -role="Projektierer" -PA9="Viktor.Schulz@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Rebekka Friedrich" -user="u508921" -group="Einkauf.voestalpine" -role="Einkauf" -PA9="Rebekka.Friedrich@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Alois Wallesch" -user="u530057" -group="Wirkflaeche.Engineering.voestalpine" -role="Wirkflaeche" -PA9="Alois.Wallesch@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Marco Hild" -user="u589468" -group="Produktdesign.Engineering.voestalpine" -role="Produktdesigner" -PA9="Marco.Hild@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Marco Hild" -user="u589468" -group="Konstruktion.Engineering.voestalpine" -role="Konstrukteur" -PA9="Marco.Hild@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Steffen Baun" -user="v108613" -group="Messtechnik.Qualitaetsmanagement.voestalpine" -role="Messtechniker" -PA9="Steffen.Baun@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Claudio Canalini" -user="v120097" -group="Projektleitung.Prototypenbau.voestalpine" -role="Projektleiter" -PA9="Claudio.Canalini@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Claudio Canalini" -user="v120097" -group="Projektadministration" -role="Projektadministrator" -PA9="Claudio.Canalini@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Rene Gross" -user="v149790" -group="dba" -role="DBA" -PA9="Rene.Gross@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Rene Gross" -user="v149790" -group="Konstruktion.Engineering.voestalpine" -role="Konstrukteur" -PA9="Rene.Gross@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Rene Gross" -user="v149790" -group="Produktdesign.Engineering.voestalpine" -role="Produktdesigner" -PA9="Rene.Gross@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Rene Gross" -user="v149790" -group="Anzeige.voestalpine" -role="Anzeige_Allgemein" -PA9="Rene.Gross@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Rene Gross" -user="v149790" -group="Projektadministration" -role="Projektadministrator" -PA9="Rene.Gross@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Roland Herzer" -user="v161314" -group="Messtechnik.Qualitaetsmanagement.voestalpine" -role="Messtechniker" -PA9="Roland.Herzer@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Guido Krieger" -user="v191105" -group="Kalkulation.voestalpine" -role="Kalkulator" -PA9="Guido.Krieger@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Armin Meier" -user="v207473" -group="Projektleitung.Prototypenbau.voestalpine" -role="Projektleiter" -PA9="Armin.Meier@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Armin Meier" -user="v207473" -group="Projektadministration" -role="Projektadministrator" -PA9="Armin.Meier@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Sascha Nicklich" -user="v215195" -group="Anzeige.voestalpine" -role="Anzeige_Allgemein" -PA9="Sascha.Nicklich@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Claude Parmentier" -user="v220805" -group="Projektleitung.Projektmanagement.voestalpine" -role="Projektleiter" -PA9="Claude.Parmentier@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Claude Parmentier" -user="v220805" -group="Projektadministration" -role="Projektadministrator" -PA9="Claude.Parmentier@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Florian Veihl" -user="v274977" -group="Arbeitsvorbereitung.Fertigung.voestalpine" -role="Arbeitsvorbereiter" -PA9="Florian.Veihl@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Jonas Fritz" -user="v364215" -group="Methode.Engineering.voestalpine" -role="Methode" -PA9="Jonas.Fritz@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Thomas Kurcz" -user="v364299" -group="Engineering.Prototypenbau.voestalpine" -role="Engineer" -PA9="Thomas.Kurcz@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Thomas Kurcz" -user="v364299" -group="Konstruktion.Engineering.voestalpine" -role="Konstrukteur" -PA9="Thomas.Kurcz@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Thomas Kurcz" -user="v364299" -group="Projektadministration" -role="Projektadministrator" -PA9="Thomas.Kurcz@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Thomas Kurcz" -user="v364299" -group="Produktdesign.Engineering.voestalpine" -role="Produktdesigner" -PA9="Thomas.Kurcz@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Christoph Wassermann" -user="v389057" -group="Konstruktion.Engineering.voestalpine" -role="Konstrukteur" -PA9="Christoph.Wassermann@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Sylvia Suntheim" -user="v748724" -group="Vertrieb.voestalpine" -role="Vertrieb" -PA9="Sylvia.Suntheim@voestalpine.com"
make_user.exe -u=infodba -p=%DBAPASS% -g=dba -person="Sylvia Suntheim" -user="v748724" -group="Projektadministration" -role="Projektadministrator" -PA9="Sylvia.Suntheim@voestalpine.com"

goto :EOF

:ENV_MISSING
echo You need to run this script in a Teamcenter environment