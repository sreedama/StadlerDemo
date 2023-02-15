# ==================================================
# Copyright 2013.
# Siemens Product Lifecycle Management Software Inc.
# All Rights Reserved.
# ==================================================
# ==================================================
#             Auto-generated source
#                 DO NOT EDIT
# ==================================================
   


 
# ==================================================
# Define macros for the service library Auto-Generation
# ==================================================   
SR5SOACUSTOMAUTOGEN_ANTARGS   = -Dtoolbox.home=$(TOOLBOX_HOME)  \
                                 -Dtemplate.home=$(TEMPLATE_HOME)           -Dgen.src.home=$(PROJECT_DRV) \
                                 -Dproject.soa.client=$(PROJECT_SOA_CLIENT) -Dproject.tc=$(PROJECT_TC) \
                                 -Dplatform=$(PLAT) -Dteamcenter.home=$(TC_ROOT) \
                                 -Dgenerated.stubs="$(GENERATED_STUBS)"

SR5SOACUSTOMAUTOGEN_AUTO_SRC  = $(PROJECT_HOME)$(PS)extensions$(PS)*.xml
SR5SOACUSTOMAUTOGEN_AUTO_TARG = $(PROJECT_DRV)$(PS)SR5SoaCustom$(PS)SR5SoaCustomMap.properties


# ==================================================
# Build targets for Auto-Generation of Service library
# ==================================================
SR5SoaCustomAutoGen_all:    $(SR5SOACUSTOMAUTOGEN_AUTO_TARG) 

$(SR5SOACUSTOMAUTOGEN_AUTO_TARG) : $(SR5SOACUSTOMAUTOGEN_AUTO_SRC)
	@echo ________________________________________________________________________________
	@echo Auto Generation of Source for Service Library SR5SoaCustom
	@$(SET_ENV) CLASSPATH=$(TOOLBOX_HOME)/xerces_j/xercesImpl.jar$(PD)$(TOOLBOX_HOME)/xerces_j/xml-apis.jar
	@$(ANT) -file build/SR5SoaCustom/SR5SoaCustomAutoGen/SR5SoaCustomAutoGen-build.xml $(SR5SOACUSTOMAUTOGEN_ANTARGS) all
	@echo ________________________________________________________________________________


	
SR5SoaCustomAutoGen_clean: 
	@echo ________________________________________________________________________________
	@echo Cleaning Auto Generated Source of Service Library SR5SoaCustom
	@$(ANT) -file build/SR5SoaCustom/SR5SoaCustomAutoGen/SR5SoaCustomAutoGen-build.xml $(SR5SOACUSTOMAUTOGEN_ANTARGS) clean  
	@echo ________________________________________________________________________________
