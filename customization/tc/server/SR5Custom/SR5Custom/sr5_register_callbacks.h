#pragma warning (push, 0)
#include <time.h>
#include <sstream>
#include <vector>
#include <algorithm>
#include <iostream>
#include <fstream>
#include <string>
#include <regex>

#include <ae/ae.h>
#include <bom/bom.h>
#include <cfm/cfm.h>
#include <epm/epm_toolkit_tc_utils.h>
#include <epm/epm_task_template_itk.h>
#include <fclasses/tc_date.h>
#include <ict/ict_userservice.h>
#include <me/me.h>
#include <ps/ps.h>
#include <ps/absocc.h>
#include <sa/am.h>
#include <tccore/aom.h>
#include <tccore/aom_prop.h>
#include <tccore/custom.h>
#include <tccore/grm.h>
#include <tccore/grmtype.h>
#include <textsrv/textserver.h>
#include <tccore/uom.h>
#include <tccore/part.h>
#include <tccore/tctype.h>
#include <pom/enq/enq.h>
#include <epm/signoff.h>
#include <res/res_itk.h>
#include <pom/pom/pom.h>
#include <sa/user.h>
#include <collabctx/collabctx.h>
#include <form/form.h>
#include <tc/preferences.h>
#include <dispatcher/dispatcher_itk.h>
#include <lov/lov.h>
#include <constants/constants.h>

#include <bmf/libuserext_exports.h>
#pragma warning (pop)

/* Admin functions */
extern "C" void AM__set_application_bypass(logical bypass);
extern "C" void AM__ask_application_bypass(logical* bypass);

/* Namespaces */
using namespace std;
using std::string;
using std::vector;

/* Structs */
struct RelationTypes {
	string	sRelationName	= "";
	tag_t		tRelationType	= NULLTAG;
};

struct Dataset {
	tag_t dataset;
	char* refType;
	char* fileExtension;
};

struct RespectedDataset {
	char* relation;
	char* type;
	char* refType;
	char* fileExtension;
};

/* Constants */
#define SR5_REVRULE_LatestWorking			"Latest Working"
#define SR5_REVRULE_Latest30_40_50_Working	"Latest 30-40-50; Working"
#define SR5_REVRULE_Latest40_50_Working		"Latest 40-50; Working"

#define SR5_TYPE_SR5WFCreateEngEnv			"SR5WFCreateEngEnv"

#define SR5_TYPE_SR5EngEndItem				"SR5EngEndItem"
#define SR5_TYPE_SR5EngEndItemRevision		"SR5EngEndItemRevision"
#define SR5_TYPE_SR5GenEngObj				"SR5GenEngObj"
#define SR5_TYPE_SR5GenEngObjRevision		"SR5GenEngObjRevision"
#define SR5_TYPE_SR5EngMajorAssy			"SR5EngMajorAssy"
#define SR5_TYPE_SR5EngMajorAssyRevision	"SR5EngMajorAssyRevision"
#define SR5_TYPE_SR5EngInstallLoc			"SR5EngInstallLoc"
#define SR5_TYPE_SR5EngInstallLocRevision	"SR5EngInstallLocRevision"

#define SR5_TYPE_SR5EngArticle				"SR5EngArticle"
#define SR5_TYPE_SR5EngArticleRevision		"SR5EngArticleRevision"
#define SR5_TYPE_SR5EngArticleAR			"SR5EngArticleAR"
#define SR5_TYPE_SR5EngArticleARRevision	"SR5EngArticleARRevision"

#define SR5_TYPE_SR5NonERPArticle			"SR5NonERPArticle"
#define SR5_TYPE_SR5NonERPArticleRevision	"SR5NonERPArticleRevision"

#define SR5_TYPE_SR5CatDefArticle			"SR5CatDefArticle"
#define SR5_TYPE_SR5CatDefArticleRevision	"SR5CatDefArticleRevision"
#define SR5_TYPE_SR5CatDefArtAR				"SR5CatDefArtAR"
#define SR5_TYPE_SR5CatDefArtARRevision		"SR5CatDefArtARRevision"

#define SR5_TYPE_SR5Weld					"SR5Weld"
#define SR5_TYPE_SR5WeldRevision			"SR5WeldRevision"
#define SR5_TYPE_SR5ColorDef				"SR5ColorDef"
#define SR5_TYPE_SR5ColorDefRevision		"SR5ColorDefRevision"
#define SR5_TYPE_SR5CoatingStruct			"SR5CoatingStruct"
#define SR5_TYPE_SR5CoatingStructRevision	"SR5CoatingStructRevision"

#define SR5_TYPE_SR5GenCatPart				"SR5GenCatPart"
#define SR5_TYPE_SR5GenCatPartRevision		"SR5GenCatPartRevision"
#define SR5_TYPE_SR5GenCatPartAR			"SR5GenCatPartAR"
#define SR5_TYPE_SR5GenCatPartARRevision	"SR5GenCatPartARRevision"


#define SR5_TYPE_SR5EngRawArticle			"SR5EngRawArticle"
#define SR5_TYPE_SR5EngRawArticleRevision	"SR5EngRawArticleRevision"

#define SR5_TYPE_SR5EngEnv					"SR5EngEnv"
#define SR5_TYPE_SR5EngEnvRevision			"SR5EngEnvRevision"
#define SR5_TYPE_SR5ElectricAssy			"SR5ElectricAssy"
#define SR5_TYPE_SR5ElectricAssyRevision	"SR5ElectricAssyRevision"

#define SR5_TYPE_SR5MfgEndItem				"SR5MfgEndItem"
#define SR5_TYPE_SR5MfgEndItemRevision		"SR5MfgEndItemRevision"
#define SR5_TYPE_SR5MfgMajorAssy			"SR5MfgMajorAssy"
#define SR5_TYPE_SR5MfgMajorAssyRevision	"SR5MfgMajorAssyRevision"
#define SR5_TYPE_SR5MfgInstallKit			"SR5MfgInstallKit"
#define SR5_TYPE_SR5MfgInstallKitRevision	"SR5MfgInstallKitRevision"
#define SR5_TYPE_SR5MfgColorAssy			"SR5MfgColorAssy"
#define SR5_TYPE_SR5MfgColorAssyRevision	"SR5MfgColorAssyRevision"
#define SR5_TYPE_SR5MfgObject				"SR5MfgObject"
#define SR5_TYPE_SR5MfgObjectRevision		"SR5MfgObjectRevision"

#define SR5_TYPE_SR5LLEndItem				"SR5LLEndItem"
#define SR5_TYPE_SR5LLEndItemRevision		"SR5LLEndItemRevision"
#define SR5_TYPE_SR5LLMajorAssy				"SR5LLMajorAssy"
#define SR5_TYPE_SR5LLMajorAssyRevision		"SR5LLMajorAssyRevision"

#define SR5_TYPE_SR5GenDocument				"SR5GenDocument"
#define SR5_TYPE_SR5GenDocumentRevision		"SR5GenDocumentRevision"

#define SR5_TYPE_SR5SRVEndItem				"SR5SRVEndItem"
#define SR5_TYPE_SR5SRVEndItemRevision		"SR5SRVEndItemRevision"
#define SR5_TYPE_SR5SRVMajorAssy			"SR5SRVMajorAssy"
#define SR5_TYPE_SR5SRVMajorAssyRevision	"SR5SRVMajorAssyRevision"

#define RELSTAT_20							"SR5Status20"
#define RELSTAT_30							"SR5Status30"
#define RELSTAT_40							"SR5Status40"
#define RELSTAT_50							"SR5Status50"
#define RELSTAT_70							"SR5Status70"
#define RELSTAT_80							"SR5Status80"
#define RELSTAT_90							"SR5Status90"
//#define RELSTAT_FROZEN					"MT4Frozen"
//#define RELSTAT_COTS						"MT4COTS"
//#define RELSTAT_SERIALPRODUCTION			"MT4SerialProduction"
//#define RELSTAT_MIGRATED					"MT4Migrated"
//#define RELSTAT_APPROVED					"Approved"

#define REL_TYPE_IMAN_METarget				"IMAN_METarget"
#define REL_TYPE_IMAN_specification			TC_specification_rtype
#define REL_TYPE_SR5HasEBOM					"SR5HasEBOM"
#define REL_TYPE_SR5HasEngEnvironment		"SR5HasEngEnvironment"
#define REL_TYPE_TC_Is_Represented_By_rtype	TC_Is_Represented_By_rtype
#define REL_TYPE_TC_Primary_Design_Representation_rtype TC_Primary_Design_Representation_rtype;
//#define REL_TYPE_SR4HasEPart				"SR4HasEPart"
//#define REL_TYPE_MT4HasSAPPlantData		"MT4HasSAPPlantData"
//#define REL_TYPE_TCAI_iPart2Factory		"TCAI_iPart2Factory_relation"
//#define REL_TYPE_TCAI_iAssy2Factory		"TCAI2_iAssembly2Factory_relation"
//#define REL_TYPE_MT4_Family				"MT4_Family"
//#define REL_TYPE_MT4_Instance				"MT4_instance"

#define SR5_TYPE_WorkspaceObject	"WorkspaceObject"
#define SR5_TYPE_Item				ITEM_item_class_name_c
#define SR5_TYPE_ItemRev			ITEM_rev_class_name_c
#define SR5_TYPE_Mat1MaterialRev	"Mat1MaterialRevision"
#define SR5_TYPE_Dataset			"Dataset"

//#define MT4_FORM_MT4SAPPlantData	"MT4SAPPlantData"
//#define MT4_FORM_PlantForm			"MT4PlantForm"
//#define MT4_FORM_PlantFormDesEBOM	"MT4PlantFormDesEBOM"
//#define MT4_FORM_OLAForm			"MT4CreOLA4DsgnInput"

//#define SR4_TYPE_Design				"SR4Design"
//#define SR4_TYPE_DesignRev			"SR4DesignRevision"
//#define SR4_TYPE_GenDesign			"Design"
//#define SR4_TYPE_GenDesignRev		"DesignRevision"

#define SR4_TYPE_EBOM				"SR4EngPart"
#define SR4_TYPE_EBOMRev			"SR4EngPartRevision"

#define SR4_TYPE_MBOM				"SR4MfgPart"
#define SR4_TYPE_MBOMRev			"SR4MfgPartRevision"

#define SR5_ATTR_objectType			"object_type"
#define SR5_ATTR_objectName			"object_name"
#define SR5_ATTR_objectDesc			"object_desc"
//#define MT4_ATTR_isDesignRequired	"is_designrequired"

#define SCENARIO_NORMAL				"Normal"
#define SCENARIO_PURCHASED			"Purchased"
#define SCENARIO_PHANTOM			"Phantom"
#define SCENARIO_REFERENCE			"Reference"
#define SCENARIO_REFERENCED			"Referenced"
#define SCENARIO_INSEPARABLE		"Inseparable"

#define ALIGNMENT_DES_EBOM			"Alignment_DES_EBOM"
#define ALIGNMENT_STD_MBOM			"Alignment_STD_MBOM"
#define ALIGNMENT_OLA_MBOM			"Alignment_OLA_MBOM"

#define BOMCACHE_SEARCH_SOURCE		"SOURCE"
#define BOMCACHE_SEARCH_TARGET		"TARGET"

#define ALIGNMENT_MODE_CUSTOM		"CUSTOM"
#define ALIGNMENT_MODE_OOTB			"OOTB"

#define ALIGNMENT_SCENARIO_SKIP		"SKIP_EBOM_LINES"
#define ALIGNMENT_SCENARIO_TRAVERSE	"TRAVERSE_EBOM_LINES"

#define TOP_LEVEL_BOM_TYPE_ORDER	"Sales Order Dependent"
#define TOP_LEVEL_BOM_TYPE_STANDARD	"Sales Order Independent"

/* Error codes - return values from the handler to TC */
const int ERROR_CODE_HANDLER_ARGS		= 919400;
const int ERROR_CODE_PLANT_MISSING		= 919401;
const int ERROR_CODE_GENERAL_ALIGNMENT	= 919402;
const int ERROR_CODE_BOM_MISMATCH		= 919403;
const int ERROR_CODE_NO_ATTACHMENTS		= 919420;
const int ERROR_CODE_NO_TASK_WITH_NAME	= 919421;
const int ERROR_CODE_NO_SIGNOFF			= 919422;
const int ERROR_CODE_PROPERTY_NOT_FOUND	= 919423;
const int ERROR_CODE_IS_CHECKED_OUT		= 919426;
const int ERROR_CODE_NO_PLANT_FORM_ATTACHED = 919429;

/* Error codes - internal only  */
const int INT_ERROR_CODE_ALIGNMENT_EXCEPTION	= -100;
const int INT_ERROR_CODE_BOMCACHE_INIT			= -101;

/* Control marker */
const bool ALIGNMENT_FOR_PCBA_PCBAC		= false;

/* SR functions */
int initBomViewandBomViewRevision(tag_t tParentItem, tag_t tParentRev, tag_t *pBV, tag_t *pBVR);
int findRelationType(const char *sRelationType, tag_t *tRelationType);
int sr5DeleteRelation(tag_t tPrimary, tag_t tSecondary, tag_t tRelationType);
int createRelation(tag_t tPrimaryObject, tag_t tSecondaryObject, tag_t tRelationType, const char *sRelationTypeForInfoLog);
int createRelation(tag_t tPrimaryObject, tag_t tSecondaryObject, const char* sRelationType, const char* sRelationTypeForInfoLog);
char* sr5GetActionHandlerArgument(TC_argument_list_t* pArgList, char *sArgumentName);
int sr5AskSecondaryObjects(tag_t tPrimaryObject, const char *cRelationType, char *sSecondaryType, vector<tag_t> *vSecondaryObjects);
int sr5AskSecondaryObjects2(tag_t tPrimaryObject, const char* cRelationType, vector<tag_t>* vSecondaryObjects);
int sr5AskPrimaryObjects2(tag_t tSecondaryObject, const char* cRelationType, std::vector<tag_t>* vPrimaryObjects);
int sr5AskPrimaryObjects(tag_t tSecondaryObject, const char* cRelationType, char* sPrimaryType, vector<tag_t>* vPrimaryObjects);
int sr5ReadAttrValue_TAG(tag_t tObject, char* sObjectType, char* sAttributeName, tag_t* tReturnValue);
int sr5ReadAttrValue_STRING(tag_t tObject, char *sObjectType, char *sAttributeName, std::string *sReturnValue);
int sr5QryAttr_STRING(char* pClass, char* pSearchAttr, const char* pSearchValue, std::vector<tag_t>* vecQryResults);
void initiateWeightCalculation(tag_t revTag, double* dWeight);
int sr5QryAttr_TAG(char* pClass, char* pSearchAttr, tag_t tSearchValue, vector<tag_t>* vecQryResults, logical lIncludingWsoActiveSeq);
int sr5DeriveMainMBOMfromEBOM(tag_t tSourceTopLine, tag_t tTargetTopLine, tag_t tCurrentSourceLine, tag_t tCurrentTargetParentLine, char *sPlant, logical lIsRoot, int iLevel, int iMaxLevel);
int createPart(const char* sPartType, tag_t* newItem);
int createMPart(const char* sMPartItemType, const char* sMPartRevType, const char* sItemID, const char* sPlant, const char* sName, tag_t tBaseUOM, tag_t* tNewItem);
int createEPart(const char* sEPartItemType, const char* sEPartRevType, const char* sItemID, const char* sName, tag_t* tNewItem);
int renameCatiaDatasetAfterSaveAs(std::string sNewIdString, tag_t tNewCatiaDataset, const char* sNamedReference, const char* sFileExtension, string sNewRevID);
int sr5BulkCreateCATProductDatasets(tag_t tItemRevision, vector<string> vecObjectTypes);
//int sr5DuplicateOneLevelStructure(tag_t tSourceItem, tag_t tTargetItem);
int sr5InitLocalizedTargetObjectAndCollaborationContext(tag_t tSourceItemRevision, tag_t* tTargetItemRevision, const char* sTargetItemType, const char* sTargetItemRevType, const char* sPlant, const char* sCustomRelTypeBetweenSourceAndTarget, const char* sCCName, const char* sAttrToLinkCCToSourceRev, const char* sTargetStructName, const char* sSourceRevRule, const char* sTargetRevRule, logical lUseMFKItemID);
vector<tag_t> change_item_type(tag_t tItem, const std::vector<std::string>& types);
int sr5UpdateItemAndRevID(tag_t tNewItem,tag_t tNewItemRev, string sOldID, string sNewID,string sOldRevID,string sNewRevID);
logical sr5IsDerivedFromClass(const tag_t objectTag, const char* pcClassName);
int sr5PrepareObjForModify(tag_t tObject, const char* sClass);
int sr5UnloadInstances(int n, tag_t* tags);
int sr5HasStatus(tag_t tObject, char* sStatusName, logical* lHasStatus);
int addObjectToWorkflowAttachments(tag_t tRootTask, vector<tag_t>vecExistingWFTargets, tag_t tObject, int iAttachType);
double get_sublevel_weight(tag_t topline,char* revRule);
int sr5AttachUnreleasedAssemblyComponents(tag_t tBOMLine, vector<tag_t>*vecNewWFRevisions);
extern DLLAPI int sr5CalculateAndSetWeight(const char* uid, int* iErrorCode, char** sErrorText, double* dWeight);
void sr5IncrementAlphabeticalRevision(std::string& strRevision, const std::string& strExcludeChars);
void sr5GetCurrentDateTime(date_t* currentDateTime);
int sr5CompareDates(date_t* dateOne, date_t* dateTwo);
bool sr5CheckObjectType(const tag_t& wso, std::vector<std::string> objectTypes);
int sr5AskLovalizedLovValueString(tag_t& lovTag, char* lovValue, const char* locale, char** localizedLovValue);
int sr5SetLocalizedObjectNameItemRev(tag_t itemRev);
int sr5SetLocalizedObjectNameItem(tag_t itemRev);
bool sr5CheckUseObjectNameTermLovsForRev(tag_t& rev);
int sr5AskObjectNameDefaultLocales(tag_t& wso, vector<string>& defaultLocales, bool& isValidMasterLocale);

string getChangeAttrString(tag_t revTag);
void CalculateString(tag_t tArticle,int Number, string* myString);

int recursiveInitBOMLinesWithUnitEffectivity(tag_t tParentBVR, tag_t tTopLevelItem, tag_t tCurrentBOMLine, logical lIsTopLevel);
int sr5RecursiveInitMPartForEPart(tag_t tCurrentBOMLine, const char* sPlant);

logical sr5IsMDMObject(tag_t tWorkspaceobject);
logical sr5IsValidMfgAssy(tag_t tWorkspaceobject);
logical sr4IsValidEBOMObject(tag_t tWorkspaceobject);
logical sr5IsValidLLObject(tag_t tWorkspaceobject);

int sr5UpdateUserDataEntryLanguage(char* sNewLocale);

int sr5HasPrivilegeChangeOwner(tag_t tObject);
int sr5HasPrivilegeWrite(tag_t tObject);
int sr5HasPrivilegeRead(tag_t tObject);

#ifdef __cplusplus
extern "C" {
#endif
	// Register Callbacks	
	extern DLLAPI int libSR5Custom_register_callbacks(void);

	// Action Handlers
	extern int SR5_AH_BOM_Alignment( EPM_action_message_t msg );
	extern int SR5_AH_Generate_AltRep(EPM_action_message_t msg);
	extern int SR5_AH_Generate_EngEnv(EPM_action_message_t msg);
	extern int SR5_AH_Create_Item(EPM_action_message_t msg);
	extern int SR5_AH_Revise_Item(EPM_action_message_t msg);
	extern int SR5_AH_Recursive_Create_CATProdcut(EPM_action_message_t msg);
	extern int SR5_AH_Create_LLT(EPM_action_message_t msg);
	extern int SR5_AH_Create_SBOM(EPM_action_message_t msg);
	extern int SR5_AH_Init_UnitEffectivity(EPM_action_message_t msg);
	extern int SR5_AH_Attach_EngEng_to_Targets(EPM_action_message_t msg);
	extern int SR5_AH_WriteCurrentLocalDate(EPM_action_message_t msg);
	extern int SR5_AH_Attach_MBOM(EPM_action_message_t msg);
	extern int SR5_AH_CheckIn_BVR_of_Targets(EPM_action_message_t msg);
	extern int SR5_AH_Init_MParts(EPM_action_message_t msg);
	extern int SR5_AH_Register_for_SmartDisc(EPM_action_message_t msg);
	extern int SR5_AH_Calculate_Weight(EPM_action_message_t msg);
	extern int SR5_AH_Update_Document_Dataset_Names(EPM_action_message_t msg);
	extern int SR5_AH_Update_Document_Language(EPM_action_message_t msg);
	extern int SR5_AH_Check_Requirement_Document(EPM_action_message_t msg);
	extern int SR5_AH_Check_Required_Project_Relation(EPM_action_message_t msg);
	extern int SR5_AH_Cut_Related_Datasets(EPM_action_message_t msg);


	// Rule Handlers
	extern EPM_decision_t SR5_RH_CheckMaterialAssignmentForAltRep(EPM_rule_message_t message);

	// BMF extensions
	extern USER_EXT_DLL_API int SR5Extension_BOMLineAdd_Precondition(METHOD_message_t* method, va_list arg);
	extern USER_EXT_DLL_API int SR5Extension_BOMLineAdd_PostAction(METHOD_message_t* method, va_list arg);
	extern USER_EXT_DLL_API int SR5Extension_BMFQRYCustomExecute_BaseAction(METHOD_message_t* method, va_list arg);
	extern USER_EXT_DLL_API int SR5Extension_BOMLine_AssignChild_PostAction(METHOD_message_t* method, va_list arg);
	extern USER_EXT_DLL_API int SR5Extension_ITEM_deep_copy_PostAction(METHOD_message_t* msg, va_list args);
	extern USER_EXT_DLL_API int SR5Extension_CATPart_Save_PostAction(METHOD_message_t* msg, va_list args);
	extern USER_EXT_DLL_API int SR5Extension_GRM_create_PostAction(METHOD_message_t* msg, va_list args);
	extern USER_EXT_DLL_API int SR5Extension_ITEM_create_rev_PostAction(METHOD_message_t* msg, va_list args);
	extern USER_EXT_DLL_API int SR5Extension_SR5MfgObject_create_PostAction(METHOD_message_t* msg, va_list args);
	extern USER_EXT_DLL_API int SR5Extension_SR5EngArticleRevision_ITEM_copy_rev_PostAction(METHOD_message_t* msg, va_list args);
	extern USER_EXT_DLL_API int SR5Extension_IMAN_Save_Mat1UsesMaterial_PostAction(METHOD_message_t* msg, va_list args);
	extern USER_EXT_DLL_API int SR5Extension_IMAN_Delete_Mat1UsesMaterial_PostAction(METHOD_message_t* msg, va_list args);
	extern USER_EXT_DLL_API int SR5Extension_IMAN_Delete_Mat1UsesMaterial_PreAction(METHOD_message_t* msg, va_list args);
	extern USER_EXT_DLL_API int SR5Extension_SR5EngInstallLocRev_ITEM_copy_rev_PostAction(METHOD_message_t* msg, va_list args);
	extern USER_EXT_DLL_API int SR5Extension_QChecker_Save_PostAction(METHOD_message_t* msg, va_list args);

	//property extensions
	extern USER_EXT_DLL_API int SR5Extension_FSF_object_name_PROP_PostAction(METHOD_message_t* msg, va_list args);
	extern USER_EXT_DLL_API int SR5Extension_sr5ObjectNameTerm_PROP_PostAction(METHOD_message_t* msg, va_list args);

	// Runtime Properties
	extern int sr5AltRepList(METHOD_message_t* msg, va_list args);
	extern int sr5ItemIdAltRepCounter(METHOD_message_t* msg, va_list args);
	extern int sr5CATIAReferencedBy(METHOD_message_t* msg, va_list args);
	extern int sr5CATIAReferenceTo(METHOD_message_t* msg, va_list args);
	extern int sr5MaterialNorm(METHOD_message_t* msg, va_list args);
	//extern int sr5WeightInKG(METHOD_message_t* msg, va_list args);
	extern int sr5FullDimension(METHOD_message_t* msg, va_list args);
	extern int sr5IsExpired(METHOD_message_t* msg, va_list args);
	extern int sr5ProposedObjectName(METHOD_message_t* msg, va_list args);


	extern int sr5CATIAName1(METHOD_message_t* msg, va_list args);
	extern int sr5CATIAName2(METHOD_message_t* msg, va_list args);


	extern int sr5CATIADisplayName(METHOD_message_t* msg, va_list args);


	//Runtime Properties for Change Attributes on drawing

	extern int sr5ChangeAttr_Line1(METHOD_message_t* msg, va_list args);
	extern int sr5ChangeAttr_Line2(METHOD_message_t* msg, va_list args);
	extern int sr5ChangeAttr_Line3(METHOD_message_t* msg, va_list args);
	extern int sr5ChangeAttr_Line4(METHOD_message_t* msg, va_list args);
	extern int sr5ChangeAttr_Line5(METHOD_message_t* msg, va_list args);
	extern int sr5ChangeAttr_Line6(METHOD_message_t* msg, va_list args);
	extern int sr5ChangeAttr_Line7(METHOD_message_t* msg, va_list args);
	extern int sr5ChangeAttr_Line8(METHOD_message_t* msg, va_list args);


	// User Exits
	extern DLLAPI int SR5_USER_ask_new_seqno(int* decision, va_list args);

#ifdef __cplusplus
}
#endif


// Global DEBUG Variable ----------------------------------------------------

#define DEBUG 0

// --------------------------------------------------------------------------

#define ITK_CALL_CLEANUP(x){													\
    int stat;																	\
    char *err_string;															\
    if((stat =(x))!= ITK_ok)													\
    {																			\
		EMH_get_error_text(NULLTAG, stat, 1, &err_string);						\
		TC_printf("ERROR: %d ERROR MSG: %s.\n", stat, err_string);				\
		TC_printf("FUNCTION: %s\nFILE: %s LINE: %d\n", #x, __FILE__, __LINE__);	\
		TC_write_syslog("ERROR: %d ERROR MSG: %s.\n", stat, err_string);		\
		TC_write_syslog("FUNCTION: %s\nFILE: %s LINE: %d\n", #x, __FILE__, __LINE__);	\
		if(err_string)MEM_free(err_string);										\
		goto CLEANUP;															\
    }																			\
}

// --------------------------------------------------------------------------

#define ITK_CALL(x){															\
    int stat;																	\
    char *err_string;															\
    if((stat =(x))!= ITK_ok)													\
    {																			\
		stringstream ssErrorMessage;											\
		EMH_get_error_text(NULLTAG, stat, 1, &err_string);						\
		ssErrorMessage << "ERROR: '" << err_string << "' (" << stat << "); File: " << __FILE__ << "; Line " << __LINE__;	\
		TC_printf("ERROR: %d ERROR MSG: %s.\n", stat, err_string);				\
		TC_printf("FUNCTION: %s\nFILE: %s LINE: %d\n", #x, __FILE__, __LINE__);	\
		TC_write_syslog("ERROR: %d ERROR MSG: %s.\n", stat, err_string);		\
		TC_write_syslog("FUNCTION: %s\nFILE: %s LINE: %d\n", #x, __FILE__, __LINE__);	\
		if(err_string)MEM_free(err_string);										\
		ssErrorMessage.str("");													\
		ssErrorMessage.clear();													\
    }																			\
}

// --------------------------------------------------------------------------

#define ENTER_FUNCTION() {													\
	if(DEBUG == 1)TC_write_syslog("> Enter the function: %s\n", __FUNCTION__);	\
	if(DEBUG == 1)printf("> Enter the function: %s\n", __FUNCTION__);		\
	addInfoLog("<Function ", __FUNCTION__, ">");							\
	addInfoLogLevel();														\
}

// --------------------------------------------------------------------------

#define EXIT_FUNCTION() {													\
	if(DEBUG == 1)TC_write_syslog("> Exit the function: %s\n", __FUNCTION__);	\
	if(DEBUG == 1)printf("> Exit the function: %s\n", __FUNCTION__);		\
	removeInfoLogLevel();													\
	addInfoLog("</Function ", __FUNCTION__, ">");						\
	if(getInfoLogLevel() == 0) addInfoLog("");								\
}

// --------------------------------------------------------------------------

#define PRINT(x){															\
	if(DEBUG == 1)TC_write_syslog("> PRINT: %s\n", x);						\
	if(DEBUG == 1)printf("> PRINT: %s\n", x);								\
}

// --------------------------------------------------------------------------
