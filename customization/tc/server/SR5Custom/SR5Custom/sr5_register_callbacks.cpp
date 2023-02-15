#include "sr5_register_callbacks.h"
   
extern DLLAPI int libSR5Custom_register_custom_handlers(int* decision, va_list args) {
	int rcode = ITK_ok;
	*decision = ALL_CUSTOMIZATIONS;


	METHOD_id_t method;

	// Action Handlers
	ITK_CALL(EPM_register_action_handler("SR5_AH_BOM_Alignment", "SR5_AH_BOM_Alignment", SR5_AH_BOM_Alignment));
	ITK_CALL(EPM_register_action_handler("SR5_AH_Generate_AltRep", "SR5_AH_Generate_AltRep", SR5_AH_Generate_AltRep));
	ITK_CALL(EPM_register_action_handler("SR5_AH_Generate_EngEnv", "SR5_AH_Generate_EngEnv", SR5_AH_Generate_EngEnv));
	ITK_CALL(EPM_register_action_handler("SR5_AH_Create_Item", "SR5_AH_Create_Item", SR5_AH_Create_Item));
	ITK_CALL(EPM_register_action_handler("SR5_AH_Revise_Item", "SR5_AH_Revise_Item", SR5_AH_Revise_Item));
	ITK_CALL(EPM_register_action_handler("SR5_AH_Recursive_Create_CATProdcut", "SR5_AH_Recursive_Create_CATProdcut", SR5_AH_Recursive_Create_CATProdcut));
	ITK_CALL(EPM_register_action_handler("SR5_AH_Create_LLT", "SR5_AH_Create_LLT", SR5_AH_Create_LLT));
	ITK_CALL(EPM_register_action_handler("SR5_AH_Create_SBOM", "SR5_AH_Create_SBOM", SR5_AH_Create_SBOM));
	ITK_CALL(EPM_register_action_handler("SR5_AH_Init_UnitEffectivity", "SR5_AH_Init_UnitEffectivity", SR5_AH_Init_UnitEffectivity));
	ITK_CALL(EPM_register_action_handler("SR5_AH_Attach_EngEng_to_Targets", "SR5_AH_Attach_EngEng_to_Targets", SR5_AH_Attach_EngEng_to_Targets));
	ITK_CALL(EPM_register_action_handler("SR5_AH_WriteCurrentLocalDate", "SR5_AH_WriteCurrentLocalDate", SR5_AH_WriteCurrentLocalDate));
	ITK_CALL(EPM_register_action_handler("SR5_AH_Attach_MBOM", "SR5_AH_Attach_MBOM", SR5_AH_Attach_MBOM));
	ITK_CALL(EPM_register_action_handler("SR5_AH_CheckIn_BVR_of_Targets", "SR5_AH_CheckIn_BVR_of_Targets", SR5_AH_CheckIn_BVR_of_Targets));
	ITK_CALL(EPM_register_action_handler("SR5_AH_Init_MParts", "SR5_AH_Init_MParts", SR5_AH_Init_MParts));
	ITK_CALL(EPM_register_action_handler("SR5_AH_Register_for_SmartDisc", "SR5_AH_Register_for_SmartDisc", SR5_AH_Register_for_SmartDisc));
	ITK_CALL(EPM_register_action_handler("SR5_AH_Calculate_Weight", "SR5_AH_Calculate_Weight", SR5_AH_Calculate_Weight));
	ITK_CALL(EPM_register_action_handler("SR5_AH_Update_Document_Dataset_Names", "SR5_AH_Update_Document_Dataset_Names", SR5_AH_Update_Document_Dataset_Names));
	ITK_CALL(EPM_register_action_handler("SR5_AH_Update_Document_Language", "SR5_AH_Update_Document_Language", SR5_AH_Update_Document_Language));
	ITK_CALL(EPM_register_action_handler("SR5_AH_Check_Requirement_Document", "SR5_AH_Check_Requirement_Document", SR5_AH_Check_Requirement_Document));
	ITK_CALL(EPM_register_action_handler("SR5_AH_Check_Required_Project_Relation", "SR5_AH_Check_Required_Project_Relation", SR5_AH_Check_Required_Project_Relation));
	ITK_CALL(EPM_register_action_handler("SR5_AH_Cut_Related_Datasets", "SR5_AH_Cut_Related_Datasets", SR5_AH_Cut_Related_Datasets));


	//Rule Handlers
	ITK_CALL(EPM_register_rule_handler("SR5_RH_CheckMaterialAssignmentForAltRep", "SR5_RH_CheckMaterialAssignmentForAltRep", SR5_RH_CheckMaterialAssignmentForAltRep));

	
	// Runtime Properties
	ITK_CALL(METHOD_register_prop_method(SR5_TYPE_SR5GenEngObj, "sr5AltRepList", PROP_ask_value_tags_msg, sr5AltRepList, NULL, &method ) );
	ITK_CALL(METHOD_register_prop_method(SR5_TYPE_SR5GenEngObj, "sr5ItemIdAltRepCounter", PROP_ask_value_string_msg, sr5ItemIdAltRepCounter, NULL, &method));
	ITK_CALL(METHOD_register_prop_method(SR5_TYPE_SR5GenEngObjRevision, "sr5CATIAReferencedBy", PROP_ask_value_tags_msg, sr5CATIAReferencedBy, NULL, &method));
	ITK_CALL(METHOD_register_prop_method(SR5_TYPE_SR5GenEngObjRevision, "sr5CATIAReferenceTo", PROP_ask_value_tags_msg, sr5CATIAReferenceTo, NULL, &method));
	ITK_CALL(METHOD_register_prop_method(SR5_TYPE_Mat1MaterialRev, "sr5MaterialNorm", PROP_ask_value_string_msg, sr5MaterialNorm, NULL, &method));
	//ITK_CALL(METHOD_register_prop_method(SR5_TYPE_SR5GenEngObjRevision, "sr5WeightInKG", PROP_ask_value_double_msg, sr5WeightInKG, NULL, &method));
	ITK_CALL(METHOD_register_prop_method(SR5_TYPE_SR5GenEngObjRevision, "sr5FullDimension", PROP_ask_value_string_msg, sr5FullDimension, NULL, &method));
	ITK_CALL(METHOD_register_prop_method(SR5_TYPE_SR5GenDocumentRevision, "sr5IsExpired", PROP_ask_value_int_msg, sr5IsExpired, NULL, &method));
	ITK_CALL(METHOD_register_prop_method("SR5ArticleReqForm", "sr5ProposedObjectName", PROP_ask_value_string_msg, sr5ProposedObjectName, NULL, &method));


	ITK_CALL(METHOD_register_prop_method(SR5_TYPE_SR5GenEngObjRevision, "sr5CATIAName1", PROP_ask_value_string_msg, sr5CATIAName1, NULL, &method));
	ITK_CALL(METHOD_register_prop_method(SR5_TYPE_SR5GenEngObjRevision, "sr5CATIAName2", PROP_ask_value_string_msg, sr5CATIAName2, NULL, &method));


	ITK_CALL(METHOD_register_prop_method(SR5_TYPE_SR5GenEngObjRevision, "sr5CATIADisplayName", PROP_ask_value_string_msg, sr5CATIADisplayName, NULL, &method));
	
	//Runtime Properties for Change Attributes on drawing

	ITK_CALL(METHOD_register_prop_method(SR5_TYPE_SR5GenEngObjRevision, "sr5ChangeAttr_Line1", PROP_ask_value_string_msg, sr5ChangeAttr_Line1, NULL, &method));
	ITK_CALL(METHOD_register_prop_method(SR5_TYPE_SR5GenEngObjRevision, "sr5ChangeAttr_Line2", PROP_ask_value_string_msg, sr5ChangeAttr_Line2, NULL, &method));
	ITK_CALL(METHOD_register_prop_method(SR5_TYPE_SR5GenEngObjRevision, "sr5ChangeAttr_Line3", PROP_ask_value_string_msg, sr5ChangeAttr_Line3, NULL, &method));
	ITK_CALL(METHOD_register_prop_method(SR5_TYPE_SR5GenEngObjRevision, "sr5ChangeAttr_Line4", PROP_ask_value_string_msg, sr5ChangeAttr_Line4, NULL, &method));
	ITK_CALL(METHOD_register_prop_method(SR5_TYPE_SR5GenEngObjRevision, "sr5ChangeAttr_Line5", PROP_ask_value_string_msg, sr5ChangeAttr_Line5, NULL, &method));
	ITK_CALL(METHOD_register_prop_method(SR5_TYPE_SR5GenEngObjRevision, "sr5ChangeAttr_Line6", PROP_ask_value_string_msg, sr5ChangeAttr_Line6, NULL, &method));
	ITK_CALL(METHOD_register_prop_method(SR5_TYPE_SR5GenEngObjRevision, "sr5ChangeAttr_Line7", PROP_ask_value_string_msg, sr5ChangeAttr_Line7, NULL, &method));
	ITK_CALL(METHOD_register_prop_method(SR5_TYPE_SR5GenEngObjRevision, "sr5ChangeAttr_Line8", PROP_ask_value_string_msg, sr5ChangeAttr_Line8, NULL, &method));

	// User Exit
	ITK_CALL(CUSTOM_register_exit("libSR5Custom", "USER_ask_new_seqno", (CUSTOM_EXIT_ftn_t)SR5_USER_ask_new_seqno));

	// Init User entry language
	char* sCurrentLocale = NULL;
	ITK_CALL(TC_text_get_current_W3C_locale(&sCurrentLocale));
	sr5UpdateUserDataEntryLanguage(sCurrentLocale);
	SAFE_SM_FREE(sCurrentLocale);


	return rcode;
}

int libSR5Custom_register_callbacks()
{
	int
		iRetCode = ITK_ok,
		iErrorCode = ITK_ok;

	CUSTOM_register_exit("libSR5Custom", "USER_gs_shell_init_module", (CUSTOM_EXIT_ftn_t)libSR5Custom_register_custom_handlers);

	return (iRetCode);
}