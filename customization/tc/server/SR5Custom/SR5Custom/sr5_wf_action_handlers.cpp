#include "sr5_register_callbacks.h"


/**
@brief Generation and linking of an Engineering Environment for the selected Engineering Installation Location or Engineering Article

@param EPM_action_message_t msg

@return Error code
*/
extern int SR5_AH_Generate_EngEnv(EPM_action_message_t msg)
{
	int	iReturnValue = ITK_ok;

	tag_t	tJob = NULLTAG,
		tRootTask = NULLTAG;

	tag_t *taWFTargets = NULL;
	//tag_t* taWFReferences = NULL;
	int iWFTargets = 0;
	//int iWFReferences = 0;

	logical	lHasBypass = false;

	//char *sEngEnvName = NULL;
	vector<tag_t> vecEngEnvChildObjects;

	// Set bypass
	ITK_CALL(ITK_ask_bypass(&lHasBypass));
	AM__set_application_bypass(true);

	ITK_CALL(EPM_ask_job(msg.task, &tJob));
	ITK_CALL(EPM_ask_root_task(tJob, &tRootTask));

	ITK_CALL(EPM_ask_attachments(tRootTask, EPM_target_attachment, &iWFTargets, &taWFTargets));
	//ITK_CALL(EPM_ask_attachments(tRootTask, EPM_reference_attachment, &iWFReferences, &taWFReferences));

	for (int i = 0; i < iWFTargets; i++) {
		std::string sObjectType = "";
		sr5ReadAttrValue_STRING(taWFTargets[i], SR5_TYPE_WorkspaceObject, "object_type", &sObjectType);

		if (sObjectType.compare(SR5_TYPE_SR5EngInstallLocRevision) == 0) {
			vecEngEnvChildObjects.push_back(taWFTargets[i]);
		}
	}

	//for (int i = 0; i < iWFReferences; i++) {
	//	std::string sObjectType = "";
	//	sr5ReadAttrValue_STRING(taWFReferences[i], SR5_TYPE_WorkspaceObject, "object_type", &sObjectType);

	//	if (sObjectType.compare(SR5_TYPE_SR5WFCreateEngEnv) == 0) {
	//		ITK_CALL(AOM_ask_value_string(taWFReferences[i], "sr5EngEnvName", &sEngEnvName));
	//	}
	//}


	//if (tc_strcmp(sEngEnvName, "") != 0 && vecEngEnvChildObjects.size() > 0) {

	tag_t
		tTargetItemType = NULLTAG,
		tTargetRevisionType = NULLTAG,
		tRelTypeHasEngEnvironment = NULLTAG;

	ITK_CALL(TCTYPE_find_type(SR5_TYPE_SR5EngEnv, SR5_TYPE_SR5EngEnv, &tTargetItemType));
	ITK_CALL(TCTYPE_find_type(SR5_TYPE_SR5EngEnvRevision, SR5_TYPE_SR5EngEnvRevision, &tTargetRevisionType));
	ITK_CALL(GRM_find_relation_type("SR5HasEngEnvironment", &tRelTypeHasEngEnvironment));

	// Traverse selected articles
	for (int i = 0; i < vecEngEnvChildObjects.size(); i++) {
			// Create Eng Envs
		tag_t	tNewEngEnv_Top		= NULLTAG,
				tNewEngEnvRev_Top	= NULLTAG,
				tNewEngEnv_Sub		= NULLTAG,
				tNewEngEnvRev_Sub	= NULLTAG,
				tEngEnvTopBV		= NULLTAG,
				tEngEnvTopBVR		= NULLTAG;

		char* sSelectedObjectName = NULL;

		tag_t tEngEnvChildRev = vecEngEnvChildObjects.at(i);
		tag_t tEngEnvChildItem = NULLTAG;
		ITK_CALL(ITEM_ask_item_of_rev(tEngEnvChildRev, &tEngEnvChildItem));

		// Skip in case of existing EngEnvs
		vector<tag_t> vecExistingEngEnvs;
		sr5AskSecondaryObjects(tEngEnvChildRev, "SR5HasEngEnvironment", SR5_TYPE_SR5EngEnv, &vecExistingEngEnvs);
		if (vecExistingEngEnvs.size() > 0) continue;

		ITK_CALL(WSOM_ask_name2(tEngEnvChildRev, &sSelectedObjectName));
		std::stringstream ssTopName, ssSubName;

		ssTopName << sSelectedObjectName << " with Environment";
		ssSubName << "Environment for " << sSelectedObjectName;

		// ENG ENV - TOP
		{
			tag_t	tTargetItemCreateInput = NULLTAG,
					tTargetRevisionCreateInput = NULLTAG;

			ITK_CALL(TCTYPE_construct_create_input(tTargetItemType, &tTargetItemCreateInput));
			ITK_CALL(AOM_set_value_string(tTargetItemCreateInput, SR5_ATTR_objectName, ssTopName.str().c_str()));

			ITK_CALL(TCTYPE_construct_create_input(tTargetRevisionType, &tTargetRevisionCreateInput));
			ITK_CALL(AOM_set_value_string(tTargetRevisionCreateInput, SR5_ATTR_objectName, ssTopName.str().c_str()));
			ITK_CALL(AOM_set_value_tag(tTargetItemCreateInput, "revision", tTargetRevisionCreateInput));

			// Create Object
			TCTYPE_create_object(tTargetItemCreateInput, &tNewEngEnv_Top);
			ITK_CALL(AOM_save_without_extensions(tNewEngEnv_Top));
			ITK_CALL(AOM_refresh(tNewEngEnv_Top, false));

			// Init Rev
			ITK_CALL(ITEM_ask_latest_rev(tNewEngEnv_Top, &tNewEngEnvRev_Top));
			initBomViewandBomViewRevision(tNewEngEnv_Top, tNewEngEnvRev_Top, &tEngEnvTopBV, &tEngEnvTopBVR);
		}

		// ENG ENV - SUB
		{
			tag_t	tTargetItemCreateInput = NULLTAG,
				tTargetRevisionCreateInput = NULLTAG,
				tBV = NULLTAG,
				tBVR = NULLTAG;

			ITK_CALL(TCTYPE_construct_create_input(tTargetItemType, &tTargetItemCreateInput));
			ITK_CALL(AOM_set_value_string(tTargetItemCreateInput, SR5_ATTR_objectName, ssSubName.str().c_str()));

			ITK_CALL(TCTYPE_construct_create_input(tTargetRevisionType, &tTargetRevisionCreateInput));
			ITK_CALL(AOM_set_value_string(tTargetRevisionCreateInput, SR5_ATTR_objectName, ssSubName.str().c_str()));
			ITK_CALL(AOM_set_value_tag(tTargetItemCreateInput, "revision", tTargetRevisionCreateInput));

			// Create Object
			TCTYPE_create_object(tTargetItemCreateInput, &tNewEngEnv_Sub);
			ITK_CALL(AOM_save_without_extensions(tNewEngEnv_Sub));
			ITK_CALL(AOM_refresh(tNewEngEnv_Sub, false));

			// Init Rev
			ITK_CALL(ITEM_ask_latest_rev(tNewEngEnv_Sub, &tNewEngEnvRev_Sub));
			initBomViewandBomViewRevision(tNewEngEnv_Sub, tNewEngEnvRev_Sub, &tBV, &tBVR);
		}

		// Add BOM Lines
		tag_t	tEngEnvWindow = NULLTAG,
				tEngEnvLine_Top = NULLTAG,
				tEngEnvLine_Sub = NULLTAG,
				tEngEnvLine_Obj = NULLTAG,
				tRevRule = NULLTAG;

		ITK_CALL(BOM_create_window(&tEngEnvWindow));
		CFM_find(SR5_REVRULE_LatestWorking, &tRevRule);
		ITK_CALL(BOM_set_window_config_rule(tEngEnvWindow, tRevRule));
		ITK_CALL(BOM_set_window_top_line(tEngEnvWindow, NULLTAG, tNewEngEnvRev_Top, NULLTAG, &tEngEnvLine_Top));

		char* sNextSeqNo = NULL;

		ITK_CALL(PS_bvr_ask_default_next_seq_no(tEngEnvTopBVR, tNewEngEnv_Sub, &sNextSeqNo));
		ITK_CALL(BOM_line_add(tEngEnvLine_Top, NULLTAG, tNewEngEnvRev_Sub, NULLTAG, &tEngEnvLine_Sub));
		ITK_CALL(AOM_set_value_string(tEngEnvLine_Sub, bomAttr_occSeqNo, sNextSeqNo));

		ITK_CALL(PS_bvr_ask_default_next_seq_no(tEngEnvTopBVR, tEngEnvChildItem, &sNextSeqNo));
		ITK_CALL(BOM_line_add(tEngEnvLine_Top, NULLTAG, tEngEnvChildRev, NULLTAG, &tEngEnvLine_Obj));
		ITK_CALL(AOM_set_value_string(tEngEnvLine_Obj, bomAttr_occSeqNo, sNextSeqNo));

		SAFE_SM_FREE(sNextSeqNo);

		ITK_CALL(BOM_save_window(tEngEnvWindow));
		ITK_CALL(BOM_close_window(tEngEnvWindow));

		// Link EnvEnv
		if (tRelTypeHasEngEnvironment != NULLTAG) {
			createRelation(vecEngEnvChildObjects.at(i), tNewEngEnv_Top, tRelTypeHasEngEnvironment, "");
		}

		// Create CATProduct -> TODO
	/*	tag_t ds_type = NULLTAG;
		tag_t tool = NULLTAG;
		tag_t tRelType_spec = NULLTAG;

		ITK_CALL(AE_find_datasettype2("CATProduct",&ds_type));
		ITK_CALL(AE_find_tool2("CatiaExport",&tool));
		ITK_CALL(GRM_find_relation_type(REL_TYPE_IMAN_specification, &tRelType_spec));*/

		// CATProduct - TOP
	/*	{
			tag_t newDataset = NULLTAG;
			std::string strDatasetName = "";

			sr5ReadAttrValue_STRING(tNewEngEnv_Top, SR5_TYPE_Item, "item_id", &strDatasetName);
			strDatasetName.append("/00");

			ITK_CALL(AE_create_dataset_with_id(ds_type, strDatasetName.c_str(), strDatasetName.c_str(), "ds_id", "A", &newDataset));
			ITK_CALL(AE_set_dataset_tool(newDataset, tool));
			ITK_CALL(AE_set_dataset_format2(newDataset, BINARY_REF));
			ITK_CALL(AOM_save_with_extensions(newDataset));

			createRelation(tNewEngEnvRev_Top, newDataset, tRelType_spec, "");
		}*/

		// CATProduct - SUB
	/*	{
			tag_t newDataset = NULLTAG;
			std::string strDatasetName = "";

			sr5ReadAttrValue_STRING(tNewEngEnv_Sub, SR5_TYPE_Item, "item_id", &strDatasetName);
			strDatasetName.append("/00");

			ITK_CALL(AE_create_dataset_with_id(ds_type, strDatasetName.c_str(), strDatasetName.c_str(), "ds_id", "A", &newDataset));
			ITK_CALL(AE_set_dataset_tool(newDataset, tool));
			ITK_CALL(AE_set_dataset_format2(newDataset, BINARY_REF));
			ITK_CALL(AOM_save_with_extensions(newDataset));

			createRelation(tNewEngEnvRev_Sub, newDataset, tRelType_spec, "");
		}*/

		SAFE_SM_FREE(sSelectedObjectName);
	}

	SAFE_SM_FREE(taWFTargets);
	//SAFE_SM_FREE(taWFReferences);

	// Reset Bypass
	if (lHasBypass == false) AM__set_application_bypass(FALSE);

	return iReturnValue;
}

/**
 * @brief Create Alternate Representation for target part
 *
 * @param EPM_action_message_t msg
 *
 * @return Error code.
 */
extern int SR5_AH_Generate_AltRep(EPM_action_message_t msg)
{
	int	iReturnValue = ITK_ok,
		iWFTargets = 0;

	tag_t	tJob = NULLTAG,
			tRootTask = NULLTAG,
			*taWFTargets = NULL;

	logical	lHasBypass = false;

	// Set bypass
	ITK_CALL(ITK_ask_bypass(&lHasBypass));
	AM__set_application_bypass(true);

	//Get Target Objects
	ITK_CALL(EPM_ask_job(msg.task, &tJob));
	ITK_CALL(EPM_ask_root_task(tJob, &tRootTask));
	ITK_CALL(EPM_ask_attachments(tRootTask, EPM_target_attachment, &iWFTargets, &taWFTargets));

	//Create Alternate Representations for each target object
	for (int i = 0; i < iWFTargets; i++) {
		std::string sObjectType = "";
		sr5ReadAttrValue_STRING(taWFTargets[i], SR5_TYPE_WorkspaceObject, "object_type", &sObjectType);
		//Check object type of current target
		if (sObjectType.compare(SR5_TYPE_SR5EngArticleRevision) == 0 || sObjectType.compare(SR5_TYPE_SR5EngArticleARRevision) == 0 ||
			sObjectType.compare(SR5_TYPE_SR5GenCatPartRevision) == 0 || sObjectType.compare(SR5_TYPE_SR5GenCatPartARRevision) == 0)
		{

			tag_t tItem = NULLTAG;

			ITK_CALL(ITEM_ask_item_of_rev(taWFTargets[i], &tItem));


			//If workflow was started on AltRep, switch to the original part to check latest revision
			if (sObjectType.compare(SR5_TYPE_SR5EngArticleARRevision) == 0 ||
				sObjectType.compare(SR5_TYPE_SR5GenCatPartARRevision) == 0)
			{
				tag_t relTypeIMAN_based_on = NULLTAG;
				GRM_find_relation_type("IMAN_based_on", &relTypeIMAN_based_on);
				int iSecCount = 0;
				tag_t* taSecObjects = NULL;
				ITK_CALL(GRM_list_secondary_objects_only(tItem, relTypeIMAN_based_on, &iSecCount, &taSecObjects));
				tItem = taSecObjects[0];
				SAFE_SM_FREE(taSecObjects);
			}

			tag_t tLastItemRev = NULLTAG;
			char* latestRevId = NULL;

			//switch to latest revision of original part and create AltRep from there
			ITK_CALL(ITEM_ask_latest_rev(tItem, &tLastItemRev));
			ITK_CALL(ITEM_ask_rev_id2(tLastItemRev, &latestRevId));
			//taWFTargets[i] = tLastItemRev;


			tag_t	tCurrentItem = NULLTAG,
					tCurrentUOM = NULLTAG,
					tNewItem = NULLTAG;
			std::string sCurrentID = "",
						sNewRevID = "",
						sCurrentName = "";
			int iNewAltCounter = 1;

			// Get parameters from original object (Item ID, etc, to be copied to AltRep)
			sr5ReadAttrValue_STRING(taWFTargets[i], SR5_TYPE_WorkspaceObject, SR5_ATTR_objectName, &sCurrentName);
			sr5ReadAttrValue_TAG(taWFTargets[i], SR5_TYPE_ItemRev, "items_tag", &tCurrentItem);
			sr5ReadAttrValue_TAG(tCurrentItem, SR5_TYPE_Item, "uom_tag", &tCurrentUOM);
			sr5ReadAttrValue_STRING(tCurrentItem, SR5_TYPE_Item, ITEM_ITEM_ID_PROP, &sCurrentID);
			sr5ReadAttrValue_STRING(tLastItemRev, SR5_TYPE_ItemRev, "item_revision_id", &sNewRevID);

			// Get Object types for new AltRep
			std::vector<tag_t> vecSearchResults;
			sr5QryAttr_STRING(SR5_TYPE_Item, "item_id", sCurrentID.c_str(), &vecSearchResults);

			std::string ARObjType,
						ARRevObjType,
						ARMasterObjType,
						ARMasterRevObjType;

			if (sObjectType.compare(SR5_TYPE_SR5EngArticleRevision) == 0 || sObjectType.compare(SR5_TYPE_SR5EngArticleARRevision) == 0)
			{
				ARObjType = SR5_TYPE_SR5EngArticleAR;
				ARRevObjType = SR5_TYPE_SR5EngArticleARRevision;
				ARMasterObjType = "SR5EngArticleARMaster";
				ARMasterRevObjType = "SR5EngArticleARRevisionMaster";
			}
			else if(sObjectType.compare(SR5_TYPE_SR5GenCatPartRevision) == 0 || sObjectType.compare(SR5_TYPE_SR5GenCatPartARRevision) == 0) 
			{
				ARObjType = SR5_TYPE_SR5GenCatPartAR;
				ARRevObjType = SR5_TYPE_SR5GenCatPartARRevision;
				ARMasterObjType = "SR5GenCatPartARMaster";
				ARMasterRevObjType = "SR5GenCatPartARRevisionMaster";
			}

			//Get AltRep counter for new object. search for objects with same ID and object type.
			for (int j = 0; j < vecSearchResults.size(); j++) {
				std::string sCurrentType = "";
				sr5ReadAttrValue_STRING(vecSearchResults.at(j), SR5_TYPE_WorkspaceObject, SR5_ATTR_objectType, &sCurrentType);
				if (sCurrentType.compare(ARObjType) == 0) {
					std::string sTmpAltRepCounter = "";
					sr5ReadAttrValue_STRING(vecSearchResults.at(j), SR5_TYPE_SR5GenEngObj, "sr5AltRepCounter", &sTmpAltRepCounter);

					try {
						int iTmpAltRepCounter = std::stoi(sTmpAltRepCounter);
						if (iTmpAltRepCounter >= iNewAltCounter) iNewAltCounter = iTmpAltRepCounter + 1;
					} catch (...) {
						//
					}
				}
			}

			// Copy new Item. Item is copied from target object.
			tag_t tNewItemRev = NULLTAG;
			ITK_CALL(ITEM_copy_item(taWFTargets[i], NULL, NULL, &tNewItem, &tNewItemRev));



			//Change Object Type of secondary objects like Master form, BVR etc
			std::string sObjectType2 = "";
			sr5ReadAttrValue_STRING(taWFTargets[i], SR5_TYPE_WorkspaceObject, "object_type", &sObjectType2);
			if (tNewItem != NULLTAG && tNewItemRev != NULLTAG) {
				// Change Object Type. This is always procesed since the sObjectType2 is always from the original part.
				if (sObjectType2.compare(ARRevObjType) != 0) {
					vector<string> vecTypes;
					vecTypes.push_back(ARObjType);
					vecTypes.push_back(ARRevObjType);
					vecTypes.push_back(ARMasterObjType);
					vecTypes.push_back(ARMasterRevObjType);
					vector<tag_t> vecChangedObjects = change_item_type(tNewItem, vecTypes);
				}

				// Update AltRep Counter on new object
				ITK_CALL(AOM_refresh(tNewItem, true));
				ITK_CALL(AOM_set_value_string(tNewItem, "sr5AltRepCounter", std::to_string(iNewAltCounter).c_str()));
				ITK_CALL(AOM_save_without_extensions(tNewItem));
				ITK_CALL(AOM_refresh(tNewItem, false));


				// Update Item ID
				char* sTmpID = NULL;
				ITK_CALL(ITEM_ask_id2(tNewItem, &sTmpID));


				//This is the currently defined RevID of the generated Revision of the AltRep. 
				//It has to be changed to the latest rev f the original part.
				char* initRevID = "000";
				if (sNewRevID.length() != 3) 
				{
					sNewRevID = "000";
				}
				//Change names of Item ID, Rev ID, BV, BVR, Master Form, Revv Master Form and Datasets
				sr5UpdateItemAndRevID(tNewItem, tNewItemRev, sTmpID, sCurrentID, initRevID, sNewRevID);
				SAFE_SM_FREE(sTmpID);

				// Get CATIA Datasets
				vector<tag_t> vecCatPartDatasets, vecCatProductDatasets, vecCatDrawingDatasets;
				sr5AskSecondaryObjects(tNewItemRev, TC_specification_rtype, "CATPart", &vecCatPartDatasets);
				sr5AskSecondaryObjects(tNewItemRev, TC_specification_rtype, "CATProduct", &vecCatProductDatasets);
				sr5AskSecondaryObjects(tNewItemRev, TC_specification_rtype, "CATDrawing", &vecCatDrawingDatasets);

				stringstream ssCatiaDatasetIdString;
				ssCatiaDatasetIdString << sCurrentID << "_" << std::to_string(iNewAltCounter);
				if (vecCatPartDatasets.size() > 0) {
					// rename named reference of CATPart
					renameCatiaDatasetAfterSaveAs(ssCatiaDatasetIdString.str(), vecCatPartDatasets.at(0), "catpart", "CATPart", sNewRevID);
				}

				if (vecCatProductDatasets.size() > 0) {
					// rename named reference of CATProduct
					renameCatiaDatasetAfterSaveAs(ssCatiaDatasetIdString.str(), vecCatProductDatasets.at(0), "catproduct", "CATProduct", sNewRevID);
				}


				//delete CATDrawing
				tag_t relTypeIMAN_specification = NULLTAG;
				GRM_find_relation_type(REL_TYPE_IMAN_specification, &relTypeIMAN_specification);
				tag_t relToDelete = NULLTAG;
				if (vecCatDrawingDatasets.size()!=0 && vecCatDrawingDatasets.at(0) != NULLTAG) {
					ITK_CALL(GRM_find_relation(tNewItemRev, vecCatDrawingDatasets.at(0), relTypeIMAN_specification, &relToDelete));
					if (relToDelete != NULLTAG)
					{

						ITK_CALL(AOM_refresh(tNewItemRev, true));
						ITK_CALL(GRM_delete_relation(relToDelete));
						ITK_CALL(AOM_save_without_extensions(tNewItemRev));
						ITK_CALL(AOM_refresh(tNewItemRev, false));

						ITK_CALL(AE_delete_all_dataset_revs(vecCatDrawingDatasets.at(0)));
					}
				}
				//if (vecCatDrawingDatasets.size() > 0) {
				//	// Duplicate CATProduct
				//	renameCatiaDatasetAfterSaveAs(ssCatiaDatasetIdString.str(), vecCatDrawingDatasets.at(0), "catdrawing", "CATDrawing", sNewRevID);
				//}


				// Copy Direct Model
				/*vector<tag_t> vecRelatedJTs;
				sr5AskSecondaryObjects(taWFTargets[i], "IMAN_Rendering", "DirectModel", &vecRelatedJTs);
				for (int j = 0; j < vecRelatedJTs.size(); j++) {
					char* sDatasetID = NULL;
					char* sDatasetRev = NULL;
					tag_t tNewJTDataset = NULLTAG;

					try {
						stringstream ssDatasetName;
						ssDatasetName << sCurrentID.c_str() << "/" << "A";

						ITK_CALL(AE_ask_dataset_id_rev(vecRelatedJTs.at(j), &sDatasetID, &sDatasetRev));
						ITK_CALL(AE_copy_dataset_with_id(vecRelatedJTs.at(j), ssDatasetName.str().c_str(), sDatasetID, sDatasetRev, &tNewJTDataset));
						renameCatiaDatasetAfterSaveAs(ssCatiaDatasetIdString.str(), tNewJTDataset, "JTPART", "jt");

						createRelation(tNewItemRev, tNewJTDataset, "IMAN_Rendering", NULL);
					}
					catch (...) {}

					SAFE_SM_FREE(sDatasetID);
					SAFE_SM_FREE(sDatasetRev);
				}*/
			} else {
				// TODO: Add error message
			}


			// Cleanup AR-BOM (remote MDM-objects)
			int iTmpNewBVCount = 0;
			tag_t* taNewBVs = NULL;
			ITK_CALL(ITEM_list_bom_views(tNewItem, &iTmpNewBVCount, &taNewBVs));
			if (iTmpNewBVCount > 0) {
				tag_t tTmpWindow = NULLTAG;
				tag_t tTmpTopLine = NULLTAG;
				tag_t tTmpRevRule = NULLTAG;
				tag_t *taTmpChildLines = NULL;
				int iTmpChildLines = 0;

				ITK_CALL(BOM_create_window(&tTmpWindow));
				ITK_CALL(BOM_set_window_top_line(tTmpWindow, tNewItem, tNewItemRev, NULLTAG, &tTmpTopLine));
				ITK_CALL(CFM_find(SR5_REVRULE_LatestWorking, &tTmpRevRule));
				ITK_CALL(BOM_set_window_config_rule(tTmpWindow, tTmpRevRule));

				ITK_CALL(BOM_line_ask_child_lines(tTmpTopLine, &iTmpChildLines, &taTmpChildLines));
				for (int iChildLineCnt = iTmpChildLines - 1; iChildLineCnt >= 0; iChildLineCnt--) {
					tag_t tTmpChildItem = NULLTAG;
					
					ITK_CALL(AOM_ask_value_tag(taTmpChildLines[iChildLineCnt], "bl_item", &tTmpChildItem));

					if (sr5IsMDMObject(tTmpChildItem) == true) {
						ITK_CALL(BOM_line_cut(taTmpChildLines[iChildLineCnt]));
					}
				}

				ITK_CALL(BOM_save_window(tTmpWindow));
				ITK_CALL(BOM_close_window(tTmpWindow));

				SAFE_SM_FREE(taTmpChildLines);
			}

			SAFE_SM_FREE(taNewBVs);

		}
	}

	SAFE_SM_FREE(taWFTargets);

	// Reset Bypass
	if (lHasBypass == false) AM__set_application_bypass(FALSE);

	return iReturnValue;
}

//-----------------------------------------------------------------------
// Function    : SR5_AH_Create_LLT
// Description : TODO               
// Returns     : execution status
//-----------------------------------------------------------------------
// Date            By                       Reason
// Jan-2021        Sebastian Falkenberg     Initial creation
//-----------------------------------------------------------------------
extern int SR5_AH_Create_LLT(EPM_action_message_t msg) {
	int	iReturnValue = ITK_ok,
		iWFTargets = 0;

	tag_t	tJob = NULLTAG,
		tRootTask = NULLTAG,
		* taWFTargets = NULL;

	logical	lHasBypass = false;

	char* sPlant = NULL;

	// Set bypass
	ITK_CALL(ITK_ask_bypass(&lHasBypass));
	AM__set_application_bypass(true);

	// Get Arguments
	char* sHandlerArg_SourceRevRule = SR5_REVRULE_Latest30_40_50_Working; // sr5GetActionHandlerArgument(msg.arguments, "ebom_rev_rule");
	char* sHandlerArg_TargetRevRule = SR5_REVRULE_LatestWorking; //sr5GetActionHandlerArgument(msg.arguments, "mbom_rev_rule");

	// Check Arguments
	if (sHandlerArg_SourceRevRule == NULL || sHandlerArg_TargetRevRule == NULL) {
		PRINT(" > ERROR - Wrong handler arguments");
		iReturnValue = ERROR_CODE_HANDLER_ARGS;
		//ITK_CALL(EMH_store_error(EMH_severity_error, ERROR_CODE_HANDLER_ARGS));

		return iReturnValue;
	}

	// Get the target + reference object(s)
	ITK_CALL(EPM_ask_job(msg.task, &tJob));
	ITK_CALL(EPM_ask_root_task(tJob, &tRootTask));
	ITK_CALL(EPM_ask_attachments(tRootTask, EPM_target_attachment, &iWFTargets, &taWFTargets));

	// Traverse Targets
	for (int i = 0; i < iWFTargets; i++) {
		char* sObjectType = NULL;

		ITK_CALL(WSOM_ask_object_type2(taWFTargets[i], &sObjectType));

		if (tc_strcmp(sObjectType, SR5_TYPE_SR5EngEndItemRevision) == 0) {
			stringstream ssCollabName;
			char* sPlant = "STAP";
			char* sTmpSourceItemId = NULL;
			char* sTmpSourceRevId = NULL;
			tag_t tTmpSourceItem = NULLTAG;
			tag_t tTargetTopLevelItemRev = NULLTAG;
			tag_t tTargetTopLevelItem = NULLTAG;
			tag_t tTargetTopLevelBV = NULLTAG;
			tag_t tTargetTopLevelBVR = NULLTAG;

			// Init CC & Target Item/Rev
			ITK_CALL(ITEM_ask_item_of_rev(taWFTargets[i], &tTmpSourceItem));
			ITK_CALL(ITEM_ask_id2(tTmpSourceItem, &sTmpSourceItemId));
			ITK_CALL(ITEM_ask_rev_id2(taWFTargets[i], &sTmpSourceRevId));

			ssCollabName << "EBOM - LongLead BOM for " << sTmpSourceItemId << "-" << sTmpSourceRevId << " (" << sPlant << ")";
			iReturnValue = sr5InitLocalizedTargetObjectAndCollaborationContext(taWFTargets[i], &tTargetTopLevelItemRev, SR5_TYPE_SR5LLEndItem, SR5_TYPE_SR5LLEndItemRevision, sPlant, NULL, ssCollabName.str().c_str(), "sr5EBOM_LLBOM_CC", "LLBOM", sHandlerArg_SourceRevRule, sHandlerArg_TargetRevRule, true);

			// Check for existing L-Mass
			tag_t tLLBOMWindow = NULLTAG;
			tag_t tLLBOMTopLine = NULLTAG;
			tag_t tRevRuleLatestWorking = NULLTAG;
			ITK_CALL(BOM_create_window(&tLLBOMWindow));
			ITK_CALL(CFM_find(sHandlerArg_TargetRevRule, &tRevRuleLatestWorking));
			ITK_CALL(BOM_set_window_config_rule(tLLBOMWindow, tRevRuleLatestWorking));
			ITK_CALL(BOM_set_window_top_line(tLLBOMWindow, NULLTAG, tTargetTopLevelItemRev, NULLTAG, &tLLBOMTopLine));
			ITK_CALL(BOM_set_window_pack_all(tLLBOMWindow, false));

			ITK_CALL(ITEM_ask_item_of_rev(tTargetTopLevelItemRev, &tTargetTopLevelItem));
			initBomViewandBomViewRevision(tTargetTopLevelItem, tTargetTopLevelItemRev, &tTargetTopLevelBV, &tTargetTopLevelBVR);

			int iChildLines = 0;
			tag_t* taChildLines = NULL;
			ITK_CALL(BOM_line_ask_child_lines(tLLBOMTopLine, &iChildLines, &taChildLines));

			// Create L-Mass
			if (iChildLines == 0) {
				tag_t tNewLLMass = NULLTAG;

				tag_t tTargetItemType = NULLTAG,
					tTargetRevisionType = NULLTAG,
					tTargetItemCreateInput = NULLTAG,
					tTargetRevisionCreateInput = NULLTAG;

				TCTYPE_find_type(SR5_TYPE_SR5LLMajorAssy, SR5_TYPE_SR5LLMajorAssy, &tTargetItemType);
				TCTYPE_find_type(SR5_TYPE_SR5LLMajorAssyRevision, SR5_TYPE_SR5LLMajorAssyRevision, &tTargetRevisionType);

				ITK_CALL(TCTYPE_construct_create_input(tTargetItemType, &tTargetItemCreateInput));
				ITK_CALL(AOM_set_value_string(tTargetItemCreateInput, SR5_ATTR_objectName, "Default Long Lead"));
				ITK_CALL(AOM_set_value_string(tTargetItemCreateInput, "sr5Plant", sPlant));

				ITK_CALL(TCTYPE_construct_create_input(tTargetRevisionType, &tTargetRevisionCreateInput));
				ITK_CALL(AOM_set_value_string(tTargetRevisionCreateInput, SR5_ATTR_objectName, "Default Long Lead"));
				ITK_CALL(AOM_set_value_tag(tTargetItemCreateInput, "revision", tTargetRevisionCreateInput));

				// Create Object
				TCTYPE_create_object(tTargetItemCreateInput, &tNewLLMass);
				ITK_CALL(AOM_save_without_extensions(tNewLLMass));
				ITK_CALL(AOM_refresh(tNewLLMass, false));

				// Add L-Mass to LL-BOM
				tag_t tNewBOMLine = NULLTAG;
				ITK_CALL(BOM_line_add(tLLBOMTopLine, tNewLLMass, NULLTAG, NULLTAG, &tNewBOMLine));

				char* sNextSeqNo = NULL;
				ITK_CALL(PS_bvr_ask_default_next_seq_no(tTargetTopLevelBVR, tNewLLMass, &sNextSeqNo));
				ITK_CALL(AOM_set_value_string(tNewBOMLine, bomAttr_occSeqNo, sNextSeqNo));

				SAFE_SM_FREE(sNextSeqNo);

				ITK_CALL(BOM_save_window(tLLBOMWindow));
			}

			ITK_CALL(BOM_close_window(tLLBOMWindow));

			SAFE_SM_FREE(taChildLines);
			SAFE_SM_FREE(sTmpSourceItemId);
			SAFE_SM_FREE(sTmpSourceRevId);
		}

		SAFE_SM_FREE(sObjectType);
	}

	return iReturnValue;
}

//-----------------------------------------------------------------------
// Function    : SR5_AH_Create_SBOM
// Description : TODO               
// Returns     : execution status
//-----------------------------------------------------------------------
// Date            By                       Reason
// Feb-2021        Sebastian Falkenberg     Initial creation
//-----------------------------------------------------------------------
extern int SR5_AH_Create_SBOM(EPM_action_message_t msg) {
	int	iReturnValue = ITK_ok,
		iWFTargets = 0;

	tag_t	tJob = NULLTAG,
		tRootTask = NULLTAG,
		* taWFTargets = NULL;

	logical	lHasBypass = false;

	char* sPlant = NULL;

	// Set bypass
	ITK_CALL(ITK_ask_bypass(&lHasBypass));
	AM__set_application_bypass(true);

	// Get Arguments
	char* sHandlerArg_SourceRevRule = SR5_REVRULE_Latest30_40_50_Working; // sr5GetActionHandlerArgument(msg.arguments, "ebom_rev_rule");
	char* sHandlerArg_TargetRevRule = SR5_REVRULE_LatestWorking; //sr5GetActionHandlerArgument(msg.arguments, "mbom_rev_rule");

	// Check Arguments
	if (sHandlerArg_SourceRevRule == NULL || sHandlerArg_TargetRevRule == NULL) {
		PRINT(" > ERROR - Wrong handler arguments");
		iReturnValue = ERROR_CODE_HANDLER_ARGS;
		//ITK_CALL(EMH_store_error(EMH_severity_error, ERROR_CODE_HANDLER_ARGS));

		return iReturnValue;
	}

	// Get the target + reference object(s)
	ITK_CALL(EPM_ask_job(msg.task, &tJob));
	ITK_CALL(EPM_ask_root_task(tJob, &tRootTask));
	ITK_CALL(EPM_ask_attachments(tRootTask, EPM_target_attachment, &iWFTargets, &taWFTargets));

	// Traverse Targets
	for (int i = 0; i < iWFTargets; i++) {
		char* sObjectType = NULL;

		ITK_CALL(WSOM_ask_object_type2(taWFTargets[i], &sObjectType));

		if (tc_strcmp(sObjectType, SR5_TYPE_SR5EngEndItemRevision) == 0) {
			stringstream ssCollabName;
			char* sPlant = "STAP";
			char* sTmpSourceItemId = NULL;
			char* sTmpSourceRevId = NULL;
			tag_t tTmpSourceItem = NULLTAG;
			tag_t tTargetTopLevelItemRev = NULLTAG;
			tag_t tTargetTopLevelItem = NULLTAG;

			// Init CC & Target Item/Rev
			ITK_CALL(ITEM_ask_item_of_rev(taWFTargets[i], &tTmpSourceItem));
			ITK_CALL(ITEM_ask_id2(tTmpSourceItem, &sTmpSourceItemId));
			ITK_CALL(ITEM_ask_rev_id2(taWFTargets[i], &sTmpSourceRevId));

			ssCollabName << "EBOM - SRV BOM for " << sTmpSourceItemId << "-" << sTmpSourceRevId << " (" << sPlant << ")";
			iReturnValue = sr5InitLocalizedTargetObjectAndCollaborationContext(taWFTargets[i], &tTargetTopLevelItemRev, SR5_TYPE_SR5SRVEndItem, SR5_TYPE_SR5SRVEndItemRevision, sPlant, NULL, ssCollabName.str().c_str(), "sr5EBOM_SRVBOM_CC", "SRVBOM", sHandlerArg_SourceRevRule, sHandlerArg_TargetRevRule, false);

			SAFE_SM_FREE(sTmpSourceItemId);
			SAFE_SM_FREE(sTmpSourceRevId);
		}

		SAFE_SM_FREE(sObjectType);
	}

	return iReturnValue;
}

//-----------------------------------------------------------------------
// Function    : SR5_AH_BOM_Alignment
// Description : TODO               
// Returns     : execution status
//-----------------------------------------------------------------------
// Date            By                       Reason
// 15-May-2021	   Sebastian Falkenberg     Initial creation
//-----------------------------------------------------------------------
extern int SR5_AH_BOM_Alignment(EPM_action_message_t msg)
{
	int	iReturnValue	= ITK_ok,
		iWFTargets		= 0,
		iWFReferences	= 0;

	tag_t	tJob					= NULLTAG,
			tRootTask				= NULLTAG,
			tWFTargetForAlignment	= NULLTAG,
			*taWFTargets			= NULL,
			*taWFReferences			= NULL;

	logical	lHasBypass = false;

	char *sPlant = NULL;

	// Set bypass
	ITK_CALL(ITK_ask_bypass(&lHasBypass));
	AM__set_application_bypass(true);

	// Get Arguments
	char* sHandlerArg_SourceRevRule = SR5_REVRULE_Latest40_50_Working; // sr5GetActionHandlerArgument(msg.arguments, "ebom_rev_rule");
	char* sHandlerArg_TargetRevRule = SR5_REVRULE_LatestWorking; //sr5GetActionHandlerArgument(msg.arguments, "mbom_rev_rule");

	// Check Arguments
	if (sHandlerArg_SourceRevRule == NULL || sHandlerArg_TargetRevRule == NULL) {
		PRINT(" > ERROR - Wrong handler arguments");
		iReturnValue = ERROR_CODE_HANDLER_ARGS;
		//ITK_CALL(EMH_store_error(EMH_severity_error, ERROR_CODE_HANDLER_ARGS));

		return iReturnValue;
	}

	// Get the target + reference object(s)
	ITK_CALL(EPM_ask_job(msg.task, &tJob));
	ITK_CALL(EPM_ask_root_task(tJob, &tRootTask));
	ITK_CALL(EPM_ask_attachments(tRootTask, EPM_target_attachment, &iWFTargets, &taWFTargets));
	ITK_CALL(EPM_ask_attachments(tRootTask, EPM_reference_attachment, &iWFReferences, &taWFReferences));

	// Traverse References
	for (int i = 0; i < iWFReferences; i++) {
		char *sObjectType = NULL;

		// Ask Object Type
		ITK_CALL(WSOM_ask_object_type2(taWFReferences[i], &sObjectType));

		if (tc_strcmp(sObjectType, "SR5WFPlantForm") == 0) {
			ITK_CALL(AOM_ask_value_string(taWFReferences[i], "sr5Plant", &sPlant));
		}

		SAFE_SM_FREE(sObjectType);
		if (sPlant != NULL) break;
	}

	if (tc_strcmp(sPlant, "") != 0) {
		// Traverse Targets
		for (int i = 0; i < iWFTargets; i++) {
			tag_t tEItemRevision = taWFTargets[i];
			char* sObjectType = NULL;

			ITK_CALL(WSOM_ask_object_type2(tEItemRevision, &sObjectType));

			if (tc_strcmp(sObjectType, SR5_TYPE_SR5EngEndItemRevision) == 0 || tc_strcmp(sObjectType, SR5_TYPE_SR5EngArticleRevision) == 0) {
				char* sObjectName = NULL,
					* sItemID = NULL,
					* sRevID = NULL;
				tag_t tEItem = NULLTAG,
					tMItem = NULLTAG,
					tMItemRevision = NULLTAG;

				int iQueryResults = 0;
				tag_t* taQueryResults = NULL;

				ITK_CALL(WSOM_ask_name2(tEItemRevision, &sObjectName));
				ITK_CALL(ITEM_ask_item_of_rev(tEItemRevision, &tEItem));
				ITK_CALL(ITEM_ask_id2(tEItem, &sItemID));
				ITK_CALL(ITEM_ask_rev_id2(tEItemRevision, &sRevID));

				const char* sTargetItemType = (tc_strcmp(sObjectType, SR5_TYPE_SR5EngEndItemRevision) == 0) ? SR5_TYPE_SR5MfgEndItem : SR5_TYPE_SR5MfgMajorAssy;
				const char* sTargetItemRevType = (tc_strcmp(sObjectType, SR5_TYPE_SR5EngEndItemRevision) == 0) ? SR5_TYPE_SR5MfgEndItemRevision : SR5_TYPE_SR5MfgMajorAssyRevision;

				// Find/Create MBOM
				const char
					* sQryAttrNames[2] = { ITEM_ITEM_ID_PROP, SR5_ATTR_objectType },
					* sQryAttrValues[2] = { sItemID, sTargetItemType };
				ITK_CALL(ITEM_find_items_by_key_attributes(2, sQryAttrNames, sQryAttrValues, &iQueryResults, &taQueryResults));

				if (iQueryResults > 0) {
					tMItem = taQueryResults[0];
				} else {
					tag_t tTargetItemType = NULLTAG,
						tTargetRevisionType = NULLTAG,
						tTargetItemCreateInput = NULLTAG,
						tTargetRevisionCreateInput = NULLTAG;

					TCTYPE_find_type(sTargetItemType, sTargetItemType, &tTargetItemType);
					TCTYPE_find_type(sTargetItemRevType, sTargetItemRevType, &tTargetRevisionType);

					ITK_CALL(TCTYPE_construct_create_input(tTargetItemType, &tTargetItemCreateInput));
					ITK_CALL(AOM_set_value_string(tTargetItemCreateInput, ITEM_ITEM_ID_PROP, sItemID));
					ITK_CALL(AOM_set_value_string(tTargetItemCreateInput, SR5_ATTR_objectName, sObjectName));
					ITK_CALL(AOM_set_value_string(tTargetItemCreateInput, "sr5Plant", sPlant));

					ITK_CALL(TCTYPE_construct_create_input(tTargetRevisionType, &tTargetRevisionCreateInput));
					ITK_CALL(AOM_set_value_string(tTargetRevisionCreateInput, SR5_ATTR_objectName, sObjectName));
					ITK_CALL(AOM_set_value_tag(tTargetItemCreateInput, "revision", tTargetRevisionCreateInput));

					// Create Object
					TCTYPE_create_object(tTargetItemCreateInput, &tMItem);
					ITK_CALL(AOM_save_without_extensions(tMItem));
					ITK_CALL(AOM_refresh(tMItem, false));
				}

				// Find latest working rev
				int iMRevStatusCount = 0;
				tag_t* taMRevStatus = NULL;
				ITK_CALL(ITEM_ask_latest_rev(tMItem, &tMItemRevision));
				ITK_CALL(WSOM_ask_release_status_list(tMItemRevision, &iMRevStatusCount, &taMRevStatus));
				if (iMRevStatusCount > 0) {
					tag_t tTmptMItemRevision = tMItemRevision;
					ITK_CALL(ITEM_copy_rev(tTmptMItemRevision, NULL, &tMItemRevision));
					ITK_CALL(ITEM_save_rev(tMItemRevision));
				}
				SAFE_SM_FREE(taMRevStatus);

				// Link M-E Objects
				tag_t relTypeHasEBOM = NULLTAG;
				findRelationType("SR5HasEBOM", &relTypeHasEBOM);
				createRelation(tMItemRevision, tEItemRevision, relTypeHasEBOM, "SR5HasEBOM");

				// Init CC
				tag_t tCC = NULLTAG;
				tag_t tSourceStructContext = NULLTAG;
				tag_t tTargetStructContext = NULLTAG;

				stringstream ssCollabName;
				ssCollabName << "EBOM - MBOM for " << sItemID << "-" << sRevID << " (" << sPlant << ")";

				int iExistingCCs = 0;
				tag_t* taExistingCCs = NULLTAG;
				ITK_CALL(AOM_ask_value_tags(tEItemRevision, "sr5EBOM_MBOM_CC", &iExistingCCs, &taExistingCCs));
				for (int j = 0; j < iExistingCCs; j++) {
					string sTmpName = "";
					sr5ReadAttrValue_STRING(taExistingCCs[j], "WorkspaceObject", "object_name", &sTmpName);
					if (ssCollabName.str().compare(sTmpName) == 0) {
						int iCtxCount = 0;
						tag_t* taStrucCtx = NULL;

						// Assign CC
						tCC = taExistingCCs[j];

						// Remove Struct Ctx
						ITK_CALL(COLLABCTX_ask_structure_contexts(tCC, &iCtxCount, &taStrucCtx));
						for (int k = 0; k < iCtxCount; k++) {
							ITK_CALL(COLLABCTX_remove_structure_context(tCC, taStrucCtx[k]));
						}

						SAFE_SM_FREE(taStrucCtx);
					}
				}
				SAFE_SM_FREE(taExistingCCs);

				if (tCC == NULLTAG) ITK_CALL(COLLABCTX_create_ccobject(COLLABCTX_me_ccobject_type_name_c, ssCollabName.str().c_str(), "", &tCC));
				ITK_CALL(COLLABCTX_create_structure_context(COLLABCTX_product_structure_type_name_c, "EBOM", "", &tSourceStructContext));
				ITK_CALL(COLLABCTX_create_structure_context(COLLABCTX_product_structure_type_name_c, "MBOM", "", &tTargetStructContext));

				ITK_CALL(COLLABCTX_add_structure_context(tCC, tSourceStructContext));
				ITK_CALL(COLLABCTX_add_structure_context(tCC, tTargetStructContext));

				tag_t tEBV, tEBVR, tMBV, tMBVR;
				initBomViewandBomViewRevision(tEItem, tEItemRevision, &tEBV, &tEBVR);
				initBomViewandBomViewRevision(tMItem, tMItemRevision, &tMBV, &tMBVR);

				ITK_CALL(COLLABCTX_context_add_content(tSourceStructContext, tEItem, COLLABCTX_content_rel_any_stype));
				ITK_CALL(COLLABCTX_context_add_content(tTargetStructContext, tMItem, COLLABCTX_content_rel_any_stype));

				tag_t relTypeMETarget = NULLTAG;
				findRelationType(REL_TYPE_IMAN_METarget, &relTypeMETarget);
				createRelation(tMBV, tEBV, relTypeMETarget, "relTypeMETarget");

				tag_t	tSourceConfigContext, tTargetConfigContext;
				ITK_CALL(COLLABCTX_create_configuration_context(COLLABCTX_configuration_context_type_name_c, "Configuration Context", "", &tSourceConfigContext));
				ITK_CALL(COLLABCTX_create_configuration_context(COLLABCTX_configuration_context_type_name_c, "Configuration Context", "", &tTargetConfigContext));

				tag_t tSourceRuleTag, tTargetRuleTag;
				CFM_find(sHandlerArg_SourceRevRule, &tSourceRuleTag);
				CFM_find(sHandlerArg_TargetRevRule, &tTargetRuleTag);
				ITK_CALL(COLLABCTX_configuration_set_revisionrule(tSourceConfigContext, tSourceRuleTag));
				ITK_CALL(COLLABCTX_configuration_set_revisionrule(tTargetConfigContext, tTargetRuleTag));

				ITK_CALL(COLLABCTX_context_set_config_context(tSourceStructContext, tSourceConfigContext));
				ITK_CALL(COLLABCTX_context_set_config_context(tTargetStructContext, tTargetConfigContext));

				ITK_CALL(AOM_refresh(tCC, false));
				ITK_CALL(AOM_refresh(tSourceStructContext, false));
				ITK_CALL(AOM_refresh(tTargetStructContext, false));
				ITK_CALL(AOM_refresh(tSourceConfigContext, false));
				ITK_CALL(AOM_refresh(tTargetConfigContext, false));
				ITK_CALL(AOM_refresh(tEBV, false));
				ITK_CALL(AOM_refresh(tMBV, false));
				ITK_CALL(AOM_refresh(tEBVR, false));
				ITK_CALL(AOM_refresh(tMBVR, false));

				// TODO: Add the new CC to the array instead of overwriting the array!
				ITK_CALL(AOM_refresh(tEItemRevision, true));
				ITK_CALL(AOM_refresh(tMItemRevision, true));
				ITK_CALL(AOM_set_value_tags(tEItemRevision, "sr5EBOM_MBOM_CC", 1, &tCC));
				//ITK_CALL(AOM_set_value_tags(tMItemRevision, "sr4HasCollaborationContexts", 1, &tCC));
				ITK_CALL(AOM_save_without_extensions(tEItemRevision));
				ITK_CALL(AOM_save_without_extensions(tMItemRevision));
				ITK_CALL(AOM_refresh(tEItemRevision, false));
				ITK_CALL(AOM_refresh(tMItemRevision, false));

				// Add the new CC to the active change
				vector<tag_t> vecPrimaryChangeNotices;
				ITK_CALL(sr5AskPrimaryObjects(tEItemRevision, "CMHasSolutionItem", "ChangeNoticeRevision", &vecPrimaryChangeNotices));
				for (int j = 0; j < vecPrimaryChangeNotices.size(); j++) {
					string sTmpMaturity = "";
					sr5ReadAttrValue_STRING(vecPrimaryChangeNotices.at(j), "ChangeNoticeRevision", "CMMaturity", &sTmpMaturity);
					if (sTmpMaturity.compare("Executing") == 0) {
						tag_t relTypeCMReferences = NULLTAG;
						findRelationType("CMReferences", &relTypeCMReferences);
						createRelation(vecPrimaryChangeNotices.at(j), tCC, relTypeCMReferences, "relTypeCMReferences");
					}
				}

				// Recursive creation of MBOM structure
				tag_t	tSourceWindow = NULLTAG,
						tSourceTopLine = NULLTAG;
				tag_t	tTargetWindow = NULLTAG,
						tTargetTopLine = NULLTAG;

				ITK_CALL(BOM_create_window(&tSourceWindow));
				ITK_CALL(BOM_set_window_config_rule(tSourceWindow, tSourceRuleTag));
				ITK_CALL(BOM_set_window_top_line(tSourceWindow, NULLTAG, tEItemRevision, NULLTAG, &tSourceTopLine));
				ITK_CALL(BOM_set_window_pack_all(tSourceWindow, false));
				ITK_CALL(BOM_save_window(tSourceWindow)); // Save Source BOM Window -> In case of unsaved-changes

				ITK_CALL(BOM_create_window(&tTargetWindow));
				ITK_CALL(BOM_set_window_config_rule(tTargetWindow, tTargetRuleTag));
				ITK_CALL(BOM_set_window_top_line(tTargetWindow, NULLTAG, tMItemRevision, NULLTAG, &tTargetTopLine));
				ITK_CALL(BOM_set_window_pack_all(tTargetWindow, false));
				ITK_CALL(BOM_save_window(tTargetWindow)); // Save Target BOM Window -> In case of unsaved-changes

				// Recursive create MBOM
				if (tc_strcmp(sObjectType, SR5_TYPE_SR5EngEndItemRevision) == 0) sr5DeriveMainMBOMfromEBOM(tSourceTopLine, tTargetTopLine, tSourceTopLine, tTargetTopLine, sPlant, true, 0, 1);
				ITK_CALL(BOM_save_window(tTargetWindow));
				ITK_CALL(BOM_close_window(tSourceWindow));
				ITK_CALL(BOM_close_window(tTargetWindow));

				// Skip Default Eff due to new BOM concept
				/*
				ITK_CALL(BOM_create_window(&tTargetWindow));
				ITK_CALL(BOM_set_window_config_rule(tTargetWindow, tTargetRuleTag));
				ITK_CALL(BOM_set_window_top_line(tTargetWindow, NULLTAG, tMItemRevision, NULLTAG, &tTargetTopLine));
				ITK_CALL(BOM_set_window_pack_all(tTargetWindow, false));

				// Recursive set Unit Effectivity
				if (tc_strcmp(sObjectType, SR5_TYPE_SR5EngEndItemRevision) == 0) {
					recursiveInitBOMLinesWithUnitEffectivity(NULLTAG, tMItem, tTargetTopLine, true);
					ITK_CALL(BOM_save_window(tTargetWindow));
				}
				ITK_CALL(BOM_close_window(tTargetWindow));
				*/

				// Free
				SAFE_SM_FREE(sObjectName);
				SAFE_SM_FREE(sItemID);
				SAFE_SM_FREE(sRevID);
				SAFE_SM_FREE(taQueryResults);
			}

			SAFE_SM_FREE(sObjectType);
		}
	} else {
		iReturnValue = -1;
	}

	// Free
	SAFE_SM_FREE(taWFTargets);
	SAFE_SM_FREE(taWFReferences);
	
	// Reset Bypass
	if (lHasBypass == false) AM__set_application_bypass(FALSE);
	
	return iReturnValue;
}

//-----------------------------------------------------------------------
// Function    : SR5_AH_Create_Item
// Description : Creates a Part by Input Parameters               
// Returns     : execution status
//-----------------------------------------------------------------------
// Date            By                       Reason
// 05-Dec-2021	   Kai Frantz				Initial creation
//-----------------------------------------------------------------------
extern int SR5_AH_Create_Item(EPM_action_message_t msg)
{
	int		iReturnValue = ITK_ok,
		iRevCount = 0,
		* iNewWFAttTypes = NULL;

	tag_t	tJob = NULLTAG,
		tRootTask = NULLTAG,
		tNewPart = NULLTAG,
		* taRevList = NULL;
	
	logical	lHasBypass = false;

	// Set bypass
	ITK_CALL(ITK_ask_bypass(&lHasBypass));
	AM__set_application_bypass(true);

	// Get Arguments
	char* sHandlerArg_PartType = sr5GetActionHandlerArgument(msg.arguments, "part_type");

	// Get Root Task
	ITK_CALL(EPM_ask_job(msg.task, &tJob));
	ITK_CALL(EPM_ask_root_task(tJob, &tRootTask));

	// Create Part
	ITK_CALL(createPart(sHandlerArg_PartType, &tNewPart));
	ITK_CALL(ITEM_list_all_revs(tNewPart, &iRevCount, &taRevList));

	// Attach new Part as Target Attachment
	iNewWFAttTypes = (int*)MEM_alloc(1 * sizeof(int));
	iNewWFAttTypes[0] = EPM_target_attachment;
	ITK_CALL(EPM_add_attachments(tRootTask, 1, taRevList, iNewWFAttTypes));

	// Reset Bypass
	if (lHasBypass == false) AM__set_application_bypass(FALSE);

	// Free
	SAFE_SM_FREE(taRevList);

	return iReturnValue;
}

//-----------------------------------------------------------------------
// Function    : SR5_AH_Revise_Item
// Description : Creates a Part by Input Parameters               
// Returns     : execution status
//-----------------------------------------------------------------------
// Date            By                       Reason
// 05-Dec-2021	   Kai Frantz				Initial creation
//-----------------------------------------------------------------------
extern int SR5_AH_Revise_Item(EPM_action_message_t msg)
{
	int		iReturnValue = ITK_ok,
		iRevCount = 0,
		iWFTargets = 0,
		* iNewWFAttTypes = NULL;

	tag_t	tJob = NULLTAG,
		tRootTask = NULLTAG,
		tNewRev = NULLTAG,
		* tNewWFAttachemnts = NULL,
		* taWFTargets;

	logical	lHasBypass = false;

	// Set bypass
	ITK_CALL(ITK_ask_bypass(&lHasBypass));
	AM__set_application_bypass(true);

	// Get Target Attachments
	ITK_CALL(EPM_ask_job(msg.task, &tJob));
	ITK_CALL(EPM_ask_root_task(tJob, &tRootTask));
	ITK_CALL(EPM_ask_attachments(tRootTask, EPM_target_attachment, &iWFTargets, &taWFTargets));

	if (iWFTargets == 1) {
		// Revise Part
		ITK_CALL(ITEM_copy_rev(taWFTargets[0], NULL, &tNewRev));

		// Remove old Revision
		ITK_CALL(EPM_remove_attachments(tRootTask, 1, taWFTargets));

		// Attach new Revision as Target Attachment
		iNewWFAttTypes = (int*)MEM_alloc(1 * sizeof(int));
		tNewWFAttachemnts = (tag_t*)MEM_alloc(1 * sizeof(tag_t));
		iNewWFAttTypes[0] = EPM_target_attachment;
		tNewWFAttachemnts[0] = tNewRev;

		ITK_CALL(EPM_add_attachments(tRootTask, 1, tNewWFAttachemnts, iNewWFAttTypes));
	}

	// Reset Bypass
	if (lHasBypass == false) AM__set_application_bypass(FALSE);

	// Free
	SAFE_SM_FREE(taWFTargets);

	return iReturnValue;
}

//-----------------------------------------------------------------------
// Function    : SR5_AH_Recursive_Create_CATProdcut
// Description : Recursive creation of CATProduct Datasets             
// Returns     : execution status
//-----------------------------------------------------------------------
// Date            By                       Reason
// 10-Jan-2022	   Sebastian Falkenberg		Initial creation
//-----------------------------------------------------------------------
extern int SR5_AH_Recursive_Create_CATProdcut(EPM_action_message_t msg)
{
	int		iReturnValue = ITK_ok,
			iWFTargets = 0;

	tag_t	tJob = NULLTAG,
			tRootTask = NULLTAG,
			* taWFTargets;

	logical	lHasBypass = false;

	// Set bypass
	ITK_CALL(ITK_ask_bypass(&lHasBypass));
	AM__set_application_bypass(true);

	// Get Target Attachments
	ITK_CALL(EPM_ask_job(msg.task, &tJob));
	ITK_CALL(EPM_ask_root_task(tJob, &tRootTask));
	ITK_CALL(EPM_ask_attachments(tRootTask, EPM_target_attachment, &iWFTargets, &taWFTargets));

	if (iWFTargets == 1) {
		char* sObjectType = NULL;

		ITK_CALL(WSOM_ask_object_type2(taWFTargets[0], &sObjectType));
		if (tc_strcmp(sObjectType, SR5_TYPE_SR5EngEndItemRevision) == 0) {
			vector<string> vecObjectTypes;

			vecObjectTypes.push_back(SR5_TYPE_SR5EngEndItemRevision);
			vecObjectTypes.push_back(SR5_TYPE_SR5EngMajorAssyRevision);
			//vecObjectTypes.push_back(SR5_TYPE_SR5EngInstallLocRevision); ... Disabled according to SRS-2442

			tag_t tWindow = NULLTAG;
			tag_t tRevRule = NULLTAG;
			tag_t tTopLine = NULLTAG;
			ITK_CALL(BOM_create_window(&tWindow));
			ITK_CALL(CFM_find(SR5_REVRULE_LatestWorking, &tRevRule));
			ITK_CALL(BOM_set_window_config_rule(tWindow, tRevRule));
			ITK_CALL(BOM_set_window_top_line(tWindow, NULLTAG, taWFTargets[0], NULLTAG, &tTopLine));
			ITK_CALL(BOM_set_window_pack_all(tWindow, false));

			sr5BulkCreateCATProductDatasets(tTopLine, vecObjectTypes);
		}

		SAFE_SM_FREE(sObjectType);
	}

	// Reset Bypass
	if (lHasBypass == false) AM__set_application_bypass(FALSE);

	// Free
	SAFE_SM_FREE(taWFTargets);

	return iReturnValue;
}

//-----------------------------------------------------------------------
// Function    : SR5_AH_Init_UnitEffectivity
// Description : TODO               
// Returns     : execution status
//-----------------------------------------------------------------------
// Date            By                       Reason
// 03-Feb-2022	   Sebastian Falkenberg     Initial creation
//-----------------------------------------------------------------------
extern int SR5_AH_Init_UnitEffectivity(EPM_action_message_t msg)
{
	int	iReturnValue = ITK_ok,
		iWFTargets = 0;

	tag_t	tJob = NULLTAG,
			tRootTask = NULLTAG,
			* taWFTargets = NULL;

	logical	lHasBypass = false;

	// Set bypass
	ITK_CALL(ITK_ask_bypass(&lHasBypass));
	AM__set_application_bypass(true);

	// Get the target + reference object(s)
	ITK_CALL(EPM_ask_job(msg.task, &tJob));
	ITK_CALL(EPM_ask_root_task(tJob, &tRootTask));
	ITK_CALL(EPM_ask_attachments(tRootTask, EPM_target_attachment, &iWFTargets, &taWFTargets));

	// Traverse References

	// Traverse Targets
	for (int i = 0; i < iWFTargets; i++) {
		// Is derived from ItemRevision?
		if(sr5IsDerivedFromClass(taWFTargets[i], "ItemRevision") == true) {
			tag_t tBOMWindow = NULLTAG;
			tag_t tBOMTopLine = NULLTAG;
			tag_t tRevRule = NULLTAG;

			tag_t tItemRevision = taWFTargets[i];
			tag_t tItem = NULLTAG;
			ITK_CALL(ITEM_ask_item_of_rev(taWFTargets[i], &tItem));

			ITK_CALL(BOM_create_window(&tBOMWindow));
			ITK_CALL(CFM_find(SR5_REVRULE_LatestWorking, &tRevRule));
			ITK_CALL(BOM_set_window_config_rule(tBOMWindow, tRevRule));
			ITK_CALL(BOM_set_window_top_line(tBOMWindow, NULLTAG, taWFTargets[i], NULLTAG, &tBOMTopLine));
			ITK_CALL(BOM_set_window_pack_all(tBOMWindow, false));
			ITK_CALL(BOM_save_window(tBOMWindow)); // Save Target BOM Window -> In case of unsaved-changes

			// Recursive set Unit Effectivity
			recursiveInitBOMLinesWithUnitEffectivity(NULLTAG, tItem, tBOMTopLine, true);
			ITK_CALL(BOM_save_window(tBOMWindow));
			ITK_CALL(BOM_close_window(tBOMWindow));
		}
	}

	SAFE_SM_FREE(taWFTargets);

	// Reset Bypass
	if (lHasBypass == false) AM__set_application_bypass(FALSE);

	return iReturnValue;
}

//-----------------------------------------------------------------------
// Function    : SR5_AH_Attach_EngEng_to_Targets
// Description : Automatic attachment of Engineering Environment (Top & Sub) to the WF targets in order to satisfy the STAP-specific requirment to keep the LC of Article and EngEnvs in sync               
// Returns     : execution status
//-----------------------------------------------------------------------
// Date            By                       Reason
// 21-Feb-2022	   Sebastian Falkenberg     Initial creation
//-----------------------------------------------------------------------
int SR5_AH_Attach_EngEng_to_Targets(EPM_action_message_t msg)
{
	int	iReturnValue = ITK_ok,
		iWFTargets = 0;

	tag_t	tJob = NULLTAG,
			tRootTask = NULLTAG,
			* taWFTargets = NULL;

	logical	lHasBypass = false;

	// Set bypass
	ITK_CALL(ITK_ask_bypass(&lHasBypass));
	AM__set_application_bypass(true);

	// Get the target + reference object(s)
	ITK_CALL(EPM_ask_job(msg.task, &tJob));
	ITK_CALL(EPM_ask_root_task(tJob, &tRootTask));
	ITK_CALL(EPM_ask_attachments(tRootTask, EPM_target_attachment, &iWFTargets, &taWFTargets));

	vector<tag_t> vecExistingWFTargets;
	for (int i = 0; i < iWFTargets; i++) {
		vecExistingWFTargets.push_back(taWFTargets[i]);
	}

	tag_t tRevRule = NULLTAG;
	ITK_CALL(CFM_find(SR5_REVRULE_LatestWorking, &tRevRule));

	// Traverse existing targets in order to identify new ones
	vector<tag_t> vecNewWFTargets;
	for (int i = 0; i < vecExistingWFTargets.size(); i++) {
		vector<tag_t> vecEngEnvironments;

		// Read and Traverse Engineering Environment
		sr5AskSecondaryObjects(vecExistingWFTargets.at(i), REL_TYPE_SR5HasEngEnvironment, SR5_TYPE_SR5EngEnv, &vecEngEnvironments);
		for (int j = 0; j < vecEngEnvironments.size(); j++) {
			// ENG-ENV
			{
				tag_t tLatestTopEngEnvRevision = NULLTAG;

				ITK_CALL(ITEM_ask_latest_rev(vecEngEnvironments.at(j), &tLatestTopEngEnvRevision));
				vecNewWFTargets.push_back(tLatestTopEngEnvRevision);
			}

			// BOM
			{
				tag_t tWindow = NULLTAG;
				tag_t tTopLine = NULLTAG;

				ITK_CALL(BOM_create_window(&tWindow));
				ITK_CALL(BOM_set_window_config_rule(tWindow, tRevRule));
				ITK_CALL(BOM_set_window_top_line(tWindow, vecEngEnvironments.at(j), NULLTAG, NULLTAG, &tTopLine));
				ITK_CALL(BOM_set_window_pack_all(tWindow, false));

				int iBOMChildLines = 0;
				tag_t* taBOMChildLines = NULL;
				ITK_CALL(BOM_line_ask_child_lines(tTopLine, &iBOMChildLines, &taBOMChildLines));
				for (int k = 0; k < iBOMChildLines; k++) {
					char* sObjectType = NULL;
					
					ITK_CALL(AOM_ask_value_string(taBOMChildLines[k], "bl_item_object_type", &sObjectType));
					if (tc_strcmp(sObjectType, SR5_TYPE_SR5EngEnv) == 0) {
						tag_t tSubEngRevision = NULLTAG;
						ITK_CALL(AOM_ask_value_tag(taBOMChildLines[k], "bl_revision", &tSubEngRevision));
						vecNewWFTargets.push_back(tSubEngRevision);
					}
					SAFE_SM_FREE(sObjectType);
				}
			}
		}
	}

	// Add identified new WF-targets
	for (int i = 0; i < vecNewWFTargets.size(); i++) {
		addObjectToWorkflowAttachments(tRootTask, vecExistingWFTargets, vecNewWFTargets.at(i), EPM_target_attachment);
	}

	SAFE_SM_FREE(taWFTargets);

	// Reset Bypass
	if (lHasBypass == false) AM__set_application_bypass(FALSE);

	return iReturnValue;
}

//-----------------------------------------------------------------------
// Function    : SR5_AH_WriteCurrentLocalDate
// Description : TODO               
// Returns     : execution status
//-----------------------------------------------------------------------
// Date            By                       Reason
// 23-Feb-2022	   Johannes Buddeberg		Initial creation
//-----------------------------------------------------------------------
extern int SR5_AH_WriteCurrentLocalDate(EPM_action_message_t msg)
{
	int	iReturnValue = ITK_ok,
		iWFTargets = 0;

	tag_t	tJob = NULLTAG,
		tRootTask = NULLTAG,
		* taWFTargets = NULL;

	logical	lHasBypass = false;

	// Set bypass
	ITK_CALL(ITK_ask_bypass(&lHasBypass));
	AM__set_application_bypass(true);

	// Get Arguments
	char* sHandlerArg_Attr =  sr5GetActionHandlerArgument(msg.arguments, "attribute");

	// Check Arguments
	if (sHandlerArg_Attr == NULL) {
		PRINT(" > ERROR - Wrong handler arguments");
		iReturnValue = ERROR_CODE_HANDLER_ARGS;
		return iReturnValue;
	}

	ITK_CALL(EPM_ask_job(msg.task, &tJob));
	ITK_CALL(EPM_ask_root_task(tJob, &tRootTask));
	ITK_CALL(EPM_ask_attachments(tRootTask, EPM_target_attachment, &iWFTargets, &taWFTargets));

	char* currDate = NULL;
	DATE_default_date_format(&currDate);

	for (int i = 0; i < iWFTargets; i++) {

		//get the master form
		vector<tag_t> vecRevMasterForm;
		sr5AskSecondaryObjects(taWFTargets[i],"IMAN_master_form","ItemRevision Master",&vecRevMasterForm);

		AOM_set_value_string(vecRevMasterForm[0],sHandlerArg_Attr, currDate);

		ITK_CALL(AOM_save_without_extensions(vecRevMasterForm[0]));
		ITK_CALL(AOM_refresh(vecRevMasterForm[0], false));
	}

	SAFE_SM_FREE(taWFTargets);

	// Reset Bypass
	if (lHasBypass == false) AM__set_application_bypass(FALSE);

	return iReturnValue;
}

//-----------------------------------------------------------------------
// Function    : SR5_AH_Attach_MBOM
// Description : Attach all assembly components to the WF Targets for initial top-level MBOM transfer (PS-attach-assembly-components) can't be used, because of the STR unit effectivities
// Returns     : execution status
//-----------------------------------------------------------------------
// Date            By                       Reason
// 03-Mar-2022	   Sebastian Falkenberg		Initial creation
//-----------------------------------------------------------------------
extern int SR5_AH_Attach_MBOM(EPM_action_message_t msg)
{
	int	iReturnValue = ITK_ok,
		iWFTargets = 0;

	tag_t	tJob = NULLTAG,
		tRootTask = NULLTAG,
		* taWFTargets = NULL;

	logical	lHasBypass = false;

	vector<tag_t> vecExistingWFRevisions, vecNewWFRevisions;

	// Set bypass
	ITK_CALL(ITK_ask_bypass(&lHasBypass));
	AM__set_application_bypass(true);

	ITK_CALL(EPM_ask_job(msg.task, &tJob));
	ITK_CALL(EPM_ask_root_task(tJob, &tRootTask));
	ITK_CALL(EPM_ask_attachments(tRootTask, EPM_target_attachment, &iWFTargets, &taWFTargets));

	tag_t tRevRule = NULLTAG;
	ITK_CALL(CFM_find(SR5_REVRULE_LatestWorking, &tRevRule));

	// Traverse WF targets
	for (int i = 0; i < iWFTargets; i++) {
		if (sr5IsDerivedFromClass(taWFTargets[i], "ItemRevision")) {
			vecExistingWFRevisions.push_back(taWFTargets[i]);

			tag_t tWindow = NULLTAG;
			tag_t tTopLine = NULLTAG;

			ITK_CALL(BOM_create_window(&tWindow));
			ITK_CALL(BOM_set_window_config_rule(tWindow, tRevRule));
			ITK_CALL(BOM_set_window_top_line(tWindow, NULLTAG, taWFTargets[i], NULLTAG, &tTopLine));
			ITK_CALL(BOM_set_window_pack_all(tWindow, true));

			sr5AttachUnreleasedAssemblyComponents(tTopLine, &vecNewWFRevisions);

			ITK_CALL(BOM_close_window(tWindow));
		}
	}

	// Attach WF targets
	for (int i = 0; i < vecNewWFRevisions.size(); i++) {
		addObjectToWorkflowAttachments(tRootTask, vecExistingWFRevisions, vecNewWFRevisions.at(i), EPM_target_attachment);
	}

	SAFE_SM_FREE(taWFTargets);

	// Reset Bypass
	if (lHasBypass == false) AM__set_application_bypass(FALSE);

	return iReturnValue;
}





//-----------------------------------------------------------------------
// Function    : SR5_AH_CheckIn_BVR_of_Targets
// Description : Checks in all BOMVIEWRevisions of all targets before these BVRs are attached to the Workflow
// Returns     : execution status
//-----------------------------------------------------------------------
// Date            By                       Reason
// 03-Mar-2022	   Sebastian Falkenberg		Initial creation
//-----------------------------------------------------------------------
extern int SR5_AH_CheckIn_BVR_of_Targets(EPM_action_message_t msg)
{
	int	iReturnValue = ITK_ok,
		iWFTargets = 0;

	tag_t	tJob = NULLTAG,
		tRootTask = NULLTAG,
		* taWFTargets = NULL;

	logical	lHasBypass = false;

	vector<tag_t> vecExistingWFRevisions, vecNewWFRevisions;

	// Set bypass
	ITK_CALL(ITK_ask_bypass(&lHasBypass));
	AM__set_application_bypass(true);

	ITK_CALL(EPM_ask_job(msg.task, &tJob));
	ITK_CALL(EPM_ask_root_task(tJob, &tRootTask));
	ITK_CALL(EPM_ask_attachments(tRootTask, EPM_target_attachment, &iWFTargets, &taWFTargets));


	// Traverse WF targets
	for (int i = 0; i < iWFTargets; i++) {
		if (sr5IsDerivedFromClass(taWFTargets[i], "ItemRevision")) 
		{
			vecExistingWFRevisions.push_back(taWFTargets[i]);

			tag_t objType = NULLTAG;
			char* objTypeName = NULL;
			tag_t BVRevisionTag = NULLTAG;
			ITK_CALL(TCTYPE_ask_object_type(taWFTargets[i], &objType));
			ITK_CALL(TCTYPE_ask_name2(objType, &objTypeName));

			sr5ReadAttrValue_TAG(taWFTargets[i], objTypeName ,"structure_revisions",&BVRevisionTag);

			if (BVRevisionTag != NULLTAG) 
			{
				logical isCheckedOut = NULL;
				ITK_CALL(RES_is_checked_out(BVRevisionTag, &isCheckedOut));
				if (isCheckedOut == TRUE)
				{
					ITK_CALL(RES_checkin(BVRevisionTag));
				}
			}

			// Attach WF targets
			//addObjectToWorkflowAttachments(tRootTask, vecExistingWFRevisions, BVRevisionTag, EPM_target_attachment);

		}
	}


	SAFE_SM_FREE(taWFTargets);

	// Reset Bypass
	if (lHasBypass == false) AM__set_application_bypass(FALSE);

	return iReturnValue;
}

//-----------------------------------------------------------------------
// Function    : SR5_AH_Init_MParts
// Description : TODO               
// Returns     : execution status
//-----------------------------------------------------------------------
// Date            By                       Reason
// 28-Mar-2022	   Sebastian Falkenberg     Initial creation
//-----------------------------------------------------------------------
extern int SR5_AH_Init_MParts(EPM_action_message_t msg)
{
	int	iReturnValue = ITK_ok,
		iWFTargets = 0;

	tag_t	tJob = NULLTAG,
		tRootTask = NULLTAG,
		* taWFTargets = NULL;

	logical	lHasBypass = false;

	// Set bypass
	ITK_CALL(ITK_ask_bypass(&lHasBypass));
	AM__set_application_bypass(true);

	// Get the target + reference object(s)
	ITK_CALL(EPM_ask_job(msg.task, &tJob));
	ITK_CALL(EPM_ask_root_task(tJob, &tRootTask));
	ITK_CALL(EPM_ask_attachments(tRootTask, EPM_target_attachment, &iWFTargets, &taWFTargets));

	// Traverse Targets
	for (int i = 0; i < iWFTargets; i++) {
		// Is derived from ItemRevision?
		if (sr4IsValidEBOMObject(taWFTargets[i]) == true) {
			tag_t tBOMWindow = NULLTAG;
			tag_t tBOMTopLine = NULLTAG;
			tag_t tRevRule = NULLTAG;

			tag_t tItemRevision = taWFTargets[i];
			tag_t tItem = NULLTAG;
			ITK_CALL(ITEM_ask_item_of_rev(taWFTargets[i], &tItem));

			ITK_CALL(BOM_create_window(&tBOMWindow));
			ITK_CALL(CFM_find(SR5_REVRULE_LatestWorking, &tRevRule));
			ITK_CALL(BOM_set_window_config_rule(tBOMWindow, tRevRule));
			ITK_CALL(BOM_set_window_top_line(tBOMWindow, NULLTAG, taWFTargets[i], NULLTAG, &tBOMTopLine));
			ITK_CALL(BOM_set_window_pack_all(tBOMWindow, false));
			ITK_CALL(BOM_save_window(tBOMWindow)); // Save Target BOM Window -> In case of unsaved-changes

			// Recursive set Unit Effectivity
			sr5RecursiveInitMPartForEPart(tBOMTopLine, "STAP");
			ITK_CALL(BOM_save_window(tBOMWindow));
			ITK_CALL(BOM_close_window(tBOMWindow));
		}
	}

	SAFE_SM_FREE(taWFTargets);

	// Reset Bypass
	if (lHasBypass == false) AM__set_application_bypass(FALSE);

	return iReturnValue;
}


/**
 * @brief Register structure for Smart Discovery Filtering
 *
 * @param EPM_action_message_t msg
 *
 * @return Error code.
 */
extern int SR5_AH_Register_for_SmartDisc(EPM_action_message_t msg)
{
	int	iReturnValue = ITK_ok,
		iWFTargets = 0;

	tag_t	tJob = NULLTAG,
		tRootTask = NULLTAG,
		* taWFTargets = NULL;

	logical	lHasBypass = false;

	// Set bypass
	ITK_CALL(ITK_ask_bypass(&lHasBypass));
	AM__set_application_bypass(true);

	// Get the target + reference object(s)
	ITK_CALL(EPM_ask_job(msg.task, &tJob));
	ITK_CALL(EPM_ask_root_task(tJob, &tRootTask));
	ITK_CALL(EPM_ask_attachments(tRootTask, EPM_target_attachment, &iWFTargets, &taWFTargets));

	// Traverse Targets
	for (int i = 0; i < iWFTargets; i++)
	{
		std::string TargetItemID = "";
		tag_t itemTag = NULLTAG;
		ITK_CALL(sr5ReadAttrValue_TAG(taWFTargets[i], SR5_TYPE_ItemRev, "items_tag", &itemTag));
		sr5ReadAttrValue_STRING(itemTag, SR5_TYPE_Item, ITEM_ITEM_ID_PROP, &TargetItemID);


		std::string TargetObjType = "";
		sr5ReadAttrValue_STRING(itemTag, SR5_TYPE_WorkspaceObject, "object_type", &TargetObjType);

		//Exclude AltRep assemblies from processing. otherwise MFK must be take ninto account (not yet implemented)
		if (TargetObjType.compare(SR5_TYPE_SR5EngArticleAR) != 0 &&
			TargetObjType.compare(SR5_TYPE_SR5CatDefArtAR) != 0 &&
			TargetObjType.compare(SR5_TYPE_SR5GenCatPartAR) != 0)
		{


			char* user = sr5GetActionHandlerArgument(msg.arguments, "user");
			char* pwd = sr5GetActionHandlerArgument(msg.arguments, "pwd");


			//Register Structure for Smart Discovery
			string commandLine = string("smart_discovery_index") + " -u=" + "\"" + user + "\"" +
				+" -p=" + "\"" + pwd + "\"" +
				+" -g=" + "\"" + "dba" + "\"" +
				+" -create" +
				+" -product=" + "\"" + TargetItemID + "\"";

			printf("\nCommand - %s", commandLine.c_str()); fflush(stdout);
			system(commandLine.c_str());

			//Initiate processing of bbox and tso creation by dispatcher
			string commandLine2 = string("create_or_update_bbox_and_tso.exe") + " -u=" + "\"" + user + "\"" +
				+" -p=" + "\"" + pwd + "\"" +
				+" -g=" + "\"" + "dba" + "\"" +
				+" -translation_mode=JTTOBBOX+JTTOTSO" +
				+" -mode=query+process" +
				+" -scope=product" +
				+" -translation_mode=JTTOBBOX+JTTOTSO" +
				+" -product=" + "\"" + TargetItemID + "\"" +
				+" -output_dir=" + "\"" + "C:/Temp/BBOX_TSO" + "\"";
			printf("\nCommand - %s", commandLine2.c_str()); fflush(stdout);
			system(commandLine2.c_str());

		}


	}
	return iReturnValue;

}



/**
 * @brief Initiate weight calculation in release workflow
 *
 * @param EPM_action_message_t msg
 *
 * @return Error code.
 */
extern int SR5_AH_Calculate_Weight(EPM_action_message_t msg)
{
	int	iReturnValue = ITK_ok,
		iWFTargets = 0;

	tag_t	tJob = NULLTAG,
		tRootTask = NULLTAG,
		* taWFTargets = NULL;

	logical	lHasBypass = false;

	// Set bypass
	ITK_CALL(ITK_ask_bypass(&lHasBypass));
	AM__set_application_bypass(true);

	// Get the target + reference object(s)
	ITK_CALL(EPM_ask_job(msg.task, &tJob));
	ITK_CALL(EPM_ask_root_task(tJob, &tRootTask));
	ITK_CALL(EPM_ask_attachments(tRootTask, EPM_target_attachment, &iWFTargets, &taWFTargets));

	tag_t targetTag = NULLTAG;
	// Traverse Targets
	for (int i = 0; i < iWFTargets; i++)
	{

		double* dWeight=nullptr;
		double value = 0.0;
		dWeight = &value;
		targetTag = taWFTargets[i];
		if (targetTag != NULLTAG) {

			//Get Material Assignment of TopLine

			initiateWeightCalculation(targetTag, dWeight);

		}
	}
	SAFE_SM_FREE(taWFTargets);
	return iReturnValue;
}

/**
 * @brief Update Dataset names accoring to the defined file name syntax.
 * 
 * @param EPM_action_message_t msg
 * 
 * @return Error code.
 */
extern int SR5_AH_Update_Document_Dataset_Names(EPM_action_message_t msg) {
	int iStat{ ITK_ok };
	tag_t tJob{ NULLTAG };
	tag_t tRootTask{ NULLTAG };
	tag_t* taWFTargets{ NULL };
	int iWFTargets{ 0 };

	logical	lHasBypass = false;
	ITK_CALL(ITK_ask_bypass(&lHasBypass));
	AM__set_application_bypass(true);

	ITK_CALL(EPM_ask_job(msg.task, &tJob));
	ITK_CALL(EPM_ask_root_task(tJob, &tRootTask));
	ITK_CALL(EPM_ask_attachments(tRootTask, EPM_target_attachment, &iWFTargets, &taWFTargets));

	// Config respected dataset types (TODO: use preference)
	std::vector<RespectedDataset> respectedDatasets;
	respectedDatasets.push_back({ "TC_Attaches", "MSWordX", "word", ".docx"});
	respectedDatasets.push_back({ "TC_Attaches", "MSExcelX", "excel", ".xlsx"});
	respectedDatasets.push_back({ "TC_Attaches", "PDF", "pdf", ".pdf"});
	respectedDatasets.push_back({ "IMAN_manifestation", "PDF", "PDF_Reference", ".pdf" });

	for (int i = 0; i < iWFTargets; i++) {
		std::string sObjectType = "";
		sr5ReadAttrValue_STRING(taWFTargets[i], SR5_TYPE_WorkspaceObject, "object_type", &sObjectType);
		if (sObjectType.compare("SR5TechDocumentRevision") == 0 || sObjectType.compare("SR5CoatingStructRevision") == 0) {
			std::vector<Dataset> attachedDatasets;
			for (auto const &respectedDataset : respectedDatasets) {
				std::vector<tag_t> secondaryObjects;
				sr5AskSecondaryObjects(taWFTargets[i], respectedDataset.relation, respectedDataset.type, &secondaryObjects);
				for (auto const &secondaryObject : secondaryObjects) {
					char* refType{ respectedDataset.refType };
					char* fileExtension{ respectedDataset.fileExtension };
					attachedDatasets.push_back({secondaryObject, refType, fileExtension});
				}
			}
			if (attachedDatasets.size() == 0) break; /* Do nothing if no respected datasets are present */
			tag_t tDocumentItem{ NULLTAG };
			ITK_CALL(ITEM_ask_item_of_rev(taWFTargets[i], &tDocumentItem));
			std::string sItemId{ "" };
			sr5ReadAttrValue_STRING(tDocumentItem, SR5_TYPE_Item, "item_id", &sItemId);
			std::string sDocumentContent{ "" };
			sr5ReadAttrValue_STRING(tDocumentItem, SR5_TYPE_SR5GenDocument, "sr5DocumentContent", &sDocumentContent);
			std::string sExternalRevision{ "" };
			sr5ReadAttrValue_STRING(taWFTargets[i], SR5_TYPE_ItemRev, "sr5ExternalRevision", &sExternalRevision);
			for (auto const &dataset : attachedDatasets) {
				std::string sDocLanguage{ "" };
				sr5ReadAttrValue_STRING(dataset.dataset, SR5_TYPE_Dataset, "sr5DocLanguage", &sDocLanguage);
				std::string sDatasetName{ sItemId + "_" + sExternalRevision + "_" + sDocumentContent + "_" + sDocLanguage };
				std::string sRefFileName{ sDatasetName + dataset.fileExtension };
				ITK_CALL(AOM_refresh(dataset.dataset, TRUE));
				ITK_CALL(AOM_set_value_string(dataset.dataset, "object_name", sDatasetName.c_str()));
				ITK_CALL(AOM_save_without_extensions(dataset.dataset));
				ITK_CALL(AOM_refresh(dataset.dataset, FALSE));
				ITK_CALL(AOM_unlock(dataset.dataset));
				int iCountNamedReferences{ 0 };
				tag_t* taNamedReferences{ NULL };
				ITK_CALL(AE_ask_all_dataset_named_refs2(dataset.dataset, dataset.refType, &iCountNamedReferences, &taNamedReferences));
				for (int k = 0; k < iCountNamedReferences; k++) {
					ITK_CALL(AOM_refresh(taNamedReferences[k], TRUE));
					ITK_CALL(IMF_set_original_file_name2(taNamedReferences[k], sRefFileName.c_str()));
					ITK_CALL(AOM_save_without_extensions(taNamedReferences[k]));
					ITK_CALL(AOM_refresh(taNamedReferences[k], FALSE));
					ITK_CALL(AOM_unlock(taNamedReferences[k]));
				}
				SAFE_SM_FREE(taNamedReferences);
			}
		}
	}
	SAFE_SM_FREE(taWFTargets);
	if (lHasBypass == false) AM__set_application_bypass(FALSE);
	return iStat;
}

/**
 * @brief Update the language of derived PDFs to the language of the source Dataset
 *
 * @param EPM_action_message_t msg
 *
 * @return Error code.
 */
extern int SR5_AH_Update_Document_Language(EPM_action_message_t msg) {
	int iStat{ ITK_ok };
	tag_t tJob{ NULLTAG };
	tag_t tRootTask{ NULLTAG };
	tag_t* taWFTargets{ NULL };
	int iWFTargets{ 0 };
	logical lHasBypass = false;
	ITK_CALL(ITK_ask_bypass(&lHasBypass));
	AM__set_application_bypass(true);
	ITK_CALL(EPM_ask_job(msg.task, &tJob));
	ITK_CALL(EPM_ask_root_task(tJob, &tRootTask));
	ITK_CALL(EPM_ask_attachments(tRootTask, EPM_target_attachment, &iWFTargets, &taWFTargets));

	char* respectedDatasets[]{ "MSWordX", "MSExcelX" };

	for (int i = 0; i < iWFTargets; i++) {
		if (!sr5CheckObjectType(taWFTargets[i], { "SR5TechDocumentRevision", "SR5CoatingStructRevision" })) continue;
		std::vector<tag_t> attachedDatasets;
		for (auto respectedDataset : respectedDatasets) {
			std::vector<tag_t> tempAttachedDatasets;
			sr5AskSecondaryObjects(taWFTargets[i], "TC_Attaches", respectedDataset, &tempAttachedDatasets);
			attachedDatasets.insert(attachedDatasets.end(), tempAttachedDatasets.begin(), tempAttachedDatasets.end());
		}
		if (attachedDatasets.empty()) continue;
		for (auto attachedDataset : attachedDatasets) {
			std::vector<tag_t> derivedDatasets;
			sr5AskSecondaryObjects(attachedDataset, "TC_Derived", "PDF", &derivedDatasets);
			if (derivedDatasets.empty()) continue;
			char* sDocumentLanguage{ "" };
			ITK_CALL(AOM_ask_value_string(attachedDataset, "sr5DocLanguage", &sDocumentLanguage));
			ITK_CALL(AOM_refresh(derivedDatasets[0], TRUE));
			ITK_CALL(AOM_set_value_string(derivedDatasets[0], "sr5DocLanguage", sDocumentLanguage));
			ITK_CALL(AOM_save_without_extensions(derivedDatasets[0]));
			ITK_CALL(AOM_refresh(derivedDatasets[0], FALSE));
			AOM_unlock(derivedDatasets[0]);
		}
	}
	if (lHasBypass == false) AM__set_application_bypass(FALSE);
	return 0;
}

/**
 * @brief Check if the submitted requirement document is already related to the selected engineering project.
 *
 * @param EPM_action_message_t msg
 *
 * @return Error code.
 */
extern int SR5_AH_Check_Required_Project_Relation(EPM_action_message_t msg) {
	int iStat = ITK_ok;
	tag_t tJob{ NULLTAG };
	tag_t tRootTask{ NULLTAG };
	tag_t* taWFTargets{ nullptr };
	int iWFTargets{ 0 };

	ITK_CALL(EPM_ask_job(msg.task, &tJob));
	ITK_CALL(EPM_ask_root_task(tJob, &tRootTask));

	ITK_CALL(EPM_ask_attachments(tRootTask, EPM_target_attachment, &iWFTargets, &taWFTargets));
	tag_t tEngineeringProject{ NULLTAG };

	for (int i = 0; i < iWFTargets; i++) {
		std::string sObjectTypeEngProject{ "" };
		sr5ReadAttrValue_STRING(taWFTargets[i], SR5_TYPE_WorkspaceObject, "object_type", &sObjectTypeEngProject);
		if (sr5CheckObjectType(taWFTargets[i], { "SR5EngProjectRevision" })) {
			for (int j = 0; j < iWFTargets; j++) {
				std::string sObjectTypeTechDocument{ "" };
				sr5ReadAttrValue_STRING(taWFTargets[j], SR5_TYPE_WorkspaceObject, "object_type", &sObjectTypeTechDocument);
				if (sr5CheckObjectType(taWFTargets[j], { "SR5TechDocument" })) {
					int iCountRelationTypes{ 0 };
					tag_t* taRelationTypes{ nullptr };
					ITK_CALL(GRM_list_relation_types(&iCountRelationTypes, &taRelationTypes));
					for (int k = 0; k < iCountRelationTypes; k++) {
						char* typeName{ "" };
						ITK_CALL(TCTYPE_ask_name2(taRelationTypes[k], &typeName));
						if (strcmp(typeName, "SR5HasRequiredDocument") == 0) {
							tag_t hasRequiredDocumentRelation{ NULLTAG };
							ITK_CALL(GRM_find_relation(taWFTargets[i], taWFTargets[j], taRelationTypes[k], &hasRequiredDocumentRelation));
							if (hasRequiredDocumentRelation != NULLTAG) {
								ITK_CALL(EPM_set_task_result(msg.task, EPM_RESULT_True));
							}
							else {
								ITK_CALL(EPM_set_task_result(msg.task, EPM_RESULT_False));
							}
						}
						SAFE_SM_FREE(typeName);
					}
					SAFE_SM_FREE(taRelationTypes);
				}
			}
		}
	}
	SAFE_SM_FREE(taWFTargets);
	return iStat;
}

/**
 * @brief Check if requirement document is valid for attachment to released article.
 *
 * @param EPM_action_message_t msg
 *
 * @return Error code.
 */
extern int SR5_AH_Check_Requirement_Document(EPM_action_message_t msg) {
	int iStat = ITK_ok;
	tag_t tJob{ NULLTAG };
	tag_t tRootTask{ NULLTAG };
	tag_t* taWFTargets{ nullptr };
	int iWFTargets{ 0 };

	ITK_CALL(EPM_ask_job(msg.task, &tJob));
	ITK_CALL(EPM_ask_root_task(tJob, &tRootTask));

	ITK_CALL(EPM_ask_attachments(tRootTask, EPM_target_attachment, &iWFTargets, &taWFTargets));
	tag_t tEngineeringProject{ NULLTAG };

	for (int i = 0; i < iWFTargets; i++) {
		if (sr5CheckObjectType(taWFTargets[i], { "SR5TechDocument" })) {
			bool lResult{ false };
			tag_t* taRevisions{ nullptr };
			int iCountRevisions{ 0 };
			ITK_CALL(ITEM_list_all_revs(taWFTargets[i], &iCountRevisions, &taRevisions));
			for (int j = 0; j < iCountRevisions; j++) {
				bool lHasStatus50{ false };
				sr5HasStatus(taRevisions[j], "SR5Status50", &lHasStatus50);
				if (lHasStatus50) {
					bool lHasStatus90{ false };
					sr5HasStatus(taRevisions[j], "SR5Status90", &lHasStatus90);
					if (lHasStatus90) continue;
					lResult = true;
					break;
				}
			}
			SAFE_SM_FREE(taRevisions);
			if (lResult) {
				ITK_CALL(EPM_set_task_result(msg.task, EPM_RESULT_True));
			}
			else {
				ITK_CALL(EPM_set_task_result(msg.task, EPM_RESULT_False));
			}

		}
	}
	SAFE_SM_FREE(taWFTargets);
	return iStat;
}



extern int SR5_AH_Cut_Related_Datasets(EPM_action_message_t msg) {
	int iStat = ITK_ok;
	logical lHasBypass{ false };
	ITK_CALL(ITK_ask_bypass(&lHasBypass));
	AM__set_application_bypass(true);
	char* relatedType{ "" };
	char* relationType{ "" };
	int countArgs{ 0 };
	char** argNames{ nullptr };
	char** argValues{ nullptr };
	ITK_CALL(EPM_args_process_args(msg.task, msg.arguments, &countArgs, &argNames, &argValues));
	for (int i = 0; i < countArgs; i++) {
		if (strcmp(argNames[i], "related_type") == 0) {
			relatedType = argValues[i];
		}
		else if (strcmp(argNames[i], "relation") == 0) {
			relationType = argValues[i];
		}
	}
	tag_t tRelationType{ NULLTAG };
	ITK_CALL(GRM_find_relation_type(relationType, &tRelationType));
	tag_t tJob{ NULLTAG };
	ITK_CALL(EPM_ask_job(msg.task, &tJob));
	tag_t tRootTask{ NULLTAG };
	ITK_CALL(EPM_ask_root_task(tJob, &tRootTask));
	tag_t* taWFTargets{ nullptr };
	int iWFTargets{ 0 };
	ITK_CALL(EPM_ask_attachments(tRootTask, EPM_target_attachment, &iWFTargets, &taWFTargets));
	if (iWFTargets == 0) return 0;
	for (int j = 0; j < iWFTargets; j++) {
		std::vector<tag_t> secondaryObjects{ NULL };
		sr5AskSecondaryObjects2(taWFTargets[j], relationType, &secondaryObjects);
		if (secondaryObjects.empty()) continue;
		for (auto secondaryObject : secondaryObjects) {
			if (sr5CheckObjectType(secondaryObject, { relatedType }) == false) continue;
			tag_t tRelation{ NULLTAG };
			ITK_CALL(GRM_find_relation(taWFTargets[j], secondaryObject, tRelationType, &tRelation));
			ITK_CALL(GRM_delete_relation(tRelation));
		}
	}
	if (lHasBypass == false) AM__set_application_bypass(FALSE);
	return 0;
}