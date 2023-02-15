# ==================================================
# Copyright 2015
# Siemens Product Lifecycle Management Software Inc.
# All Rights Reserved.
# ==================================================
# ==================================================
#             Auto-generated source
#                 DO NOT EDIT
# ==================================================



# ==================================================
# Define macros for C++ Service implementation
# ==================================================
LIBSR5SOACUSTOM_SERVER     = $(PROJECT_HOME)$(PS)src$(PS)server
LIBSR5SOACUSTOM_SRC        = $(LIBSR5SOACUSTOM_SERVER)$(PS)SR5SoaCustom
LIBSR5SOACUSTOM_DRV        = $(PROJECT_DRV)$(PS)SR5SoaCustom
LIBSR5SOACUSTOM_OBJ        = $(PROJECT_OBJ)$(PS)libsr5soacustom
LIBSR5SOACUSTOM_CXXS       = $(LIBSR5SOACUSTOM_SRC)$(PS)*.cxx $(LIBSR5SOACUSTOM_DRV)$(PS)*.cxx
LIBSR5SOACUSTOM_CXX_FLAGS  = $(CXX_FLAGS) -DIPLIB=libsr5soacustom
LIBSR5SOACUSTOM_LINK_FLAGS = $(LINK_FLAGS)
LIBSR5SOACUSTOM_INCLUDES   = $(CPP_INCLUDES) -I$(LIBSR5SOACUSTOM_SRC) -I$(LIBSR5SOACUSTOM_DRV) -I$(PROJECT_DRV) -I$(LIBSR5SOACUSTOM_SERVER) \
                                  -I$(TC_ROOT)$(PS)include -I$(TC_ROOT)$(PS)include_cpp -I$(TC_ROOT)$(PS)aw_include_cpp \
                                  -I$(TOOLBOX_HOME)$(PS)TCGATEWAYSRC \
                                  
LIBSR5SOACUSTOM_LIB_PATH   = $(LP)$(PROJECT_BIN)  $(LIB_PATH)
LIBSR5SOACUSTOM_LIBS       = $(SYSLIBS)  \
                                  $(LIB_PREFIX)tcsoacommon$(LIB_SUFFIX)        $(LIB_PREFIX)tcsoaserver$(LIB_SUFFIX) $(LIB_PREFIX)pom$(LIB_SUFFIX)  \
                                  $(LIB_PREFIX)itk$(LIB_SUFFIX)                $(LIB_PREFIX)fclasses$(LIB_SUFFIX)    $(LIB_PREFIX)metaframework$(LIB_SUFFIX) \
                                  $(LIB_PREFIX)extensionframework$(LIB_SUFFIX) $(LIB_PREFIX)tccore$(LIB_SUFFIX)      $(LIB_PREFIX)tc$(LIB_SUFFIX) \
                                  $(LIB_PREFIX)cxpom$(LIB_SUFFIX)              $(LIB_PREFIX)base_utils$(LIB_SUFFIX)  $(LIB_PREFIX)mld$(LIB_SUFFIX)
LIBSR5SOACUSTOM_LD_FLAGS   = $(LIBSR5SOACUSTOM_LINK_FLAGS) $(LIBSR5SOACUSTOM_LIB_PATH)
LIBSR5SOACUSTOM_TARGET     = $(PROJECT_BIN)$(PS)libsr5soacustom



libsr5soacustom_all:   $(LIBSR5SOACUSTOM_OBJ)  $(LIBSR5SOACUSTOM_TARGET).$(LIB_EXT)


$(LIBSR5SOACUSTOM_OBJ) :
	@echo Creating: $(LIBSR5SOACUSTOM_OBJ)
	-@$(MAKE_DIR) $(LIBSR5SOACUSTOM_OBJ)

$(LIBSR5SOACUSTOM_CXXS) :


# ==================================================
# Windows Build Target
# ==================================================
$(LIBSR5SOACUSTOM_TARGET).dll : $(LIBSR5SOACUSTOM_CXXS)
	@echo ________________________________________________________________________________
	@echo Building C++ Server libsr5soacustom
	@echo Compiling Source...
	@$(COMPILE)  $(LIBSR5SOACUSTOM_CXX_FLAGS) $(LIBSR5SOACUSTOM_INCLUDES) -c $(**)   $(CARG_OUT)$(LIBSR5SOACUSTOM_OBJ)$(PS)
	@echo.
	@$(LINK) $(LIBSR5SOACUSTOM_LD_FLAGS) $(LIBSR5SOACUSTOM_OBJ)$(PS)*.$(OBJ_EXT)  $(LIBSR5SOACUSTOM_LIBS)  $(LARG_OUT)$(LIBSR5SOACUSTOM_TARGET).dll
	$(COPY_FILE)  $(PROJECT_BIN)$(PS)libsr5soacustom.dll $(PROJECT_TC)$(PS)bin
	$(COPY_FILE)  $(PROJECT_BIN)$(PS)libsr5soacustom.lib $(PROJECT_TC)$(PS)lib
	@echo ________________________________________________________________________________


	
# ==================================================
# UNIX Build Target
# ==================================================
$(LIBSR5SOACUSTOM_TARGET).so : $(LIBSR5SOACUSTOM_CXXS)
	@echo ________________________________________________________________________________
	@echo Building C++ Server libsr5soacustom
	@# The compile output goes to the current directory (project root), so remove any .o files
	@# that may have been left here from previous failed builds. Then after the compile move all .o
	@# files to the the desired obj folder.
	@-rm *.$(OBJ_EXT)
	@echo Compiling $(LIBSR5SOACUSTOM_CXXS)
	@$(COMPILE)  $(LIBSR5SOACUSTOM_CXX_FLAGS) $(LIBSR5SOACUSTOM_INCLUDES) -c $(LIBSR5SOACUSTOM_CXXS) 
	@mv *.$(OBJ_EXT) $(LIBSR5SOACUSTOM_OBJ)
	@echo Linking $(LIBSR5SOACUSTOM_TARGET).so
	@$(LINK) $(LIBSR5SOACUSTOM_LD_FLAGS) $(LIBSR5SOACUSTOM_OBJ)$(PS)*.$(OBJ_EXT)  $(LIBSR5SOACUSTOM_LIBS)  $(LARG_OUT) $(LIBSR5SOACUSTOM_TARGET).so
	$(COPY_FILE)  $(PROJECT_BIN)$(PS)libsr5soacustom.so $(PROJECT_TC)$(PS)lib
	@echo ________________________________________________________________________________


libsr5soacustom_clean:
	@echo ________________________________________________________________________________
	@echo Cleaning C++ Server libsr5soacustom
	-$(DELETE_DIR)  $(LIBSR5SOACUSTOM_OBJ)
	-$(DELETE_FILE) $(PROJECT_BIN)$(PS)libsr5soacustom.*	
	-$(DELETE_FILE) $(PROJECT_TC)$(PS)bin$(PS)libsr5soacustom.dll
	-$(DELETE_FILE) $(PROJECT_TC)$(PS)lib$(PS)libsr5soacustom.lib	
	-$(DELETE_FILE) $(PROJECT_TC)$(PS)lib$(PS)libsr5soacustom.so	
	@echo ________________________________________________________________________________

