#include <sr5_register_callbacks.h>

/**
 * @brief Perform checks before Alternate Representation is created
 *
 * @param EPM_rule_message_t message
 *
 * @return Error code.
 */
extern EPM_decision_t SR5_RH_CheckMaterialAssignmentForAltRep(EPM_rule_message_t message) 
{

	//This handler chacks if the Object is a component or an assembly ( by children, NOT by existence of a BOMViewRev). 
	//If a Leaf node (without children) has no IMM Material attached, an error message is thrown.
	// It also checks if the last revision of the original part has a status or not



	EPM_decision_t decision = EPM_go;
	int tNum = 0;
	tag_t* tTargets = NULL;

	int	iReturnValue = ITK_ok;

	tag_t	tJob = NULLTAG,
		tRootTask = NULLTAG,
		* taWFTargets = NULL;

	
	ITK_CALL(EPM_ask_attachments(message.task, EPM_target_attachment, &tNum, &tTargets));

	//Create Alternate Representations for each target object
	for (int i = 0; i < tNum; i++) {
		std::string sObjectType = "";
		sr5ReadAttrValue_STRING(tTargets[i], SR5_TYPE_WorkspaceObject, "object_type", &sObjectType);
		//Check object type of current target
		if (sObjectType.compare(SR5_TYPE_SR5EngArticleRevision) == 0 || sObjectType.compare(SR5_TYPE_SR5EngArticleARRevision) == 0 ||
			sObjectType.compare(SR5_TYPE_SR5GenCatPartRevision) == 0 || sObjectType.compare(SR5_TYPE_SR5GenCatPartARRevision) == 0)
		{
			tag_t tItem = NULLTAG;

			ITK_CALL(ITEM_ask_item_of_rev(tTargets[i], &tItem));

			//If workflow was started on AltRep, switch to the original part
			/*if (sObjectType.compare(SR5_TYPE_SR5EngArticleARRevision) == 0 ||
				sObjectType.compare(SR5_TYPE_SR5CatDefArtARRevision) == 0 ||
				sObjectType.compare(SR5_TYPE_SR5GenCatPartARRevision) == 0)
			{
				tag_t relTypeIMAN_based_on = NULLTAG;
				ITK_CALL(GRM_find_relation_type("IMAN_based_on", &relTypeIMAN_based_on));
				int iSecCount = 0;
				tag_t* taSecObjects = NULL;
				ITK_CALL(GRM_list_secondary_objects_only(tItem, relTypeIMAN_based_on, &iSecCount, &taSecObjects));
				tItem = taSecObjects[0];
				SAFE_SM_FREE(taSecObjects);

			}*/

			std::vector<tag_t> vecParts;

			sr5AskSecondaryObjects(tTargets[i], REL_TYPE_IMAN_specification, "CATPart", &vecParts);

			int nChildren = 0;
			tag_t* tChildren = NULL;
			ITK_CALL(AOM_ask_value_tags(tTargets[i], "view", &nChildren, &tChildren));
			std::string sObjectType2 = "";
			if (tChildren != NULL) {
				sr5ReadAttrValue_STRING(tChildren[0], SR5_TYPE_WorkspaceObject, "object_type", &sObjectType2);
				SAFE_SM_FREE(tChildren);
			}
		

			if ((nChildren == 0 || (nChildren==1 && sObjectType2.compare(SR5_TYPE_SR5CatDefArticle) == 0)) )
			{
				std::vector<tag_t> vecMaterials;
				sr5AskSecondaryObjects(tTargets[i], "Mat1UsesMaterial", "Mat1MaterialRevision", &vecMaterials);
				if (vecMaterials.size() == 0)
				{
					EMH_store_error_s2(EMH_severity_error, 919103, "No material attached", "EPM_nogo");
					decision = EPM_nogo;
					break;
				}

			}

			sr5AskSecondaryObjects(tTargets[i], REL_TYPE_IMAN_specification, "CATProduct", &vecParts);
			if (vecParts.size() == 0)
			{
				if (sObjectType.compare(SR5_TYPE_SR5EngArticleRevision) == 0 || sObjectType.compare(SR5_TYPE_SR5EngArticleARRevision) == 0 ||
					sObjectType.compare(SR5_TYPE_SR5GenCatPartRevision) == 0 || sObjectType.compare(SR5_TYPE_SR5GenCatPartARRevision) == 0)
				{
					EMH_store_error_s2(EMH_severity_error, 919106, "Target needs to have a 3D Model", "EPM_nogo");
					decision = EPM_nogo;
					break;
				}

			}
		}
		else
		{
			EMH_store_error_s2(EMH_severity_error, 919107, "Wrong object type", "EPM_nogo");
			decision = EPM_nogo;
			break;

		}
	}
	SAFE_SM_FREE(tTargets);
	return decision;
}
