#include "sr5_register_callbacks.h"

vector<RelationTypes> vecRelationTypes;

logical sr5IsDerivedFromClass(const tag_t objectTag, const char* pcClassName) {
	tag_t	classIdTag = NULLTAG;
	tag_t	objectClassIdTag = NULLTAG;

	logical		bIsDescendant = FALSE;

	// Check input integrity
	if (objectTag != NULLTAG && tc_strlen(pcClassName) != 0) {
		ITK_CALL(POM_class_id_of_class(pcClassName, &classIdTag));
		if (classIdTag != NULLTAG) {
			ITK_CALL(POM_class_of_instance(objectTag, &objectClassIdTag));
			if (objectClassIdTag != NULLTAG) {
				ITK_CALL(POM_is_descendant(classIdTag, objectClassIdTag, &bIsDescendant));
			}
		}
	}

	return bIsDescendant;
}

/**
@brief This function is cleaning up the primary object to only link the provided latest secondary revision and cut all precessors

@param tag_t tPrimaryRev
@param tag_t tLatestSecondaryRev
@param const char* sRelationType

@return Error code
*/
int sr5CleanupRelationsToLatestRevOnly(tag_t tPrimaryRev, tag_t tLatestSecondaryRev, const char* sRelationType) {
	vector<tag_t> vecSecondaryRevs;
	tag_t tSecondaryItem = NULLTAG;

	sr5ReadAttrValue_TAG(tLatestSecondaryRev, SR5_TYPE_ItemRev, "items_tag", &tSecondaryItem);

	// Read and traverse secondary objects
	sr5AskSecondaryObjects2(tPrimaryRev, sRelationType, &vecSecondaryRevs);
	for (int i = 0; i < vecSecondaryRevs.size(); i++) {
		if (tLatestSecondaryRev != vecSecondaryRevs.at(i) && sr5IsDerivedFromClass(vecSecondaryRevs.at(i), SR5_TYPE_ItemRev)) {
			tag_t tTmpSecondaryItem = NULLTAG;

			sr5ReadAttrValue_TAG(vecSecondaryRevs.at(i), SR5_TYPE_ItemRev, "items_tag", &tTmpSecondaryItem);
			if (tTmpSecondaryItem == tSecondaryItem) {
				tag_t tRelationType = NULLTAG;

				findRelationType(sRelationType, &tRelationType);
				sr5DeleteRelation(tPrimaryRev, vecSecondaryRevs.at(i), tRelationType);
			}
		}
	}

	return ITK_ok;
}


/**
@brief This function creates a new relation-instance of the provided relation type between the primary and secondary object

@param tag_t tPrimary
@param tag_t tSecondary
@param tag_t tRelationType

@return Error code
*/int sr5DeleteRelation(tag_t tPrimary, tag_t tSecondary, tag_t tRelationType) {
	tag_t tRelation = NULLTAG;

	if (tPrimary == NULLTAG || tSecondary == NULLTAG || tRelationType == NULLTAG) return -1;

	// Delete Relation
	ITK_CALL(GRM_find_relation(tPrimary, tSecondary, tRelationType, &tRelation));
	if (tRelation != NULLTAG)
	{
		ITK_CALL(GRM_delete_relation(tRelation));
	}

	return ITK_ok;
}

int findRelationType(const char* sRelationType, tag_t* tRelationType) {
	// Traverse Relation Types Vector
	for (int i = 0; i < vecRelationTypes.size(); i++) {
		if (vecRelationTypes.at(i).sRelationName.compare(sRelationType) == 0) {
			*tRelationType = vecRelationTypes.at(i).tRelationType;
			break;
		}
	}

	// Found?
	if (*tRelationType == NULLTAG) {
		ITK_CALL(GRM_find_relation_type(sRelationType, tRelationType));

		RelationTypes relationTypeEntry;
		relationTypeEntry.sRelationName = sRelationType;
		relationTypeEntry.tRelationType = *tRelationType;

		vecRelationTypes.push_back(relationTypeEntry);
	}

	return *tRelationType != NULLTAG ? ITK_ok : 999999;
}

int createRelation(tag_t tPrimaryObject, tag_t tSecondaryObject, const char *sRelationType, const char* sRelationTypeForInfoLog) {
	int iRetCode = ITK_ok;
	tag_t tRelationType = NULLTAG;

	ITK_CALL(GRM_find_relation_type(sRelationType, &tRelationType));
	if (tRelationType != NULLTAG) {
		iRetCode = createRelation(tPrimaryObject, tSecondaryObject, tRelationType, sRelationTypeForInfoLog);
	}

	return iRetCode;
}

int createRelation(tag_t tPrimaryObject, tag_t tSecondaryObject, tag_t tRelationType, const char* sRelationTypeForInfoLog) {
	tag_t	tNewRelation = NULLTAG;
	int		iStatus = ITK_ok;

	if (tPrimaryObject == NULLTAG || tSecondaryObject == NULLTAG) return ITK_ok;

	// Relation already exists ?
	ITK_CALL(GRM_find_relation(tPrimaryObject, tSecondaryObject, tRelationType, &tNewRelation));

	if (tNewRelation == NULLTAG) {
		//addInfoLog("Relation '", sRelationTypeForInfoLog, "' does not exist -> create");

		tag_t class_id = NULLTAG;

		ITK_CALL(POM_class_id_of_class("ImanRelation", &class_id));

		if (class_id != NULLTAG)
		{
			ITK_CALL(POM_create_instance(class_id, &tNewRelation));
		}

		if (tNewRelation != NULLTAG)
		{
			logical is_loaded = false;
			tag_t person_attr_id = NULLTAG;

			tag_t
				iAttrIdSecondaryObject = NULLTAG,
				iAttrIdPrimaryObject = NULLTAG,
				iAttrIdRelationType = NULLTAG,
				iAttrIdCopyStableId = NULLTAG,
				iAttrIdCopyStableDate = NULLTAG,
				iAttrIdUserData = NULLTAG,
				iAttrIdReqDigitalSign = NULLTAG;

			date_t
				copyStableDate = NULLDATE;

			char* sUID = NULL;
			ITK__convert_tag_to_uid(tNewRelation, &sUID);

			ITK_CALL(POM_attr_id_of_attr("relation_type", "ImanRelation", &iAttrIdRelationType));
			ITK_CALL(POM_set_attr_tag(1, &tNewRelation, iAttrIdRelationType, tRelationType));

			ITK_CALL(POM_attr_id_of_attr("primary_object", "ImanRelation", &iAttrIdPrimaryObject));
			ITK_CALL(POM_set_attr_tag(1, &tNewRelation, iAttrIdPrimaryObject, tPrimaryObject));

			ITK_CALL(POM_attr_id_of_attr("secondary_object", "ImanRelation", &iAttrIdSecondaryObject));
			ITK_CALL(POM_set_attr_tag(1, &tNewRelation, iAttrIdSecondaryObject, tSecondaryObject));

			ITK_CALL(POM_attr_id_of_attr("user_data", "ImanRelation", &iAttrIdUserData));
			ITK_CALL(POM_set_attr_tag(1, &tNewRelation, iAttrIdUserData, NULLTAG));

			ITK_CALL(POM_attr_id_of_attr("fnd0RequiresDigitalSign", "ImanRelation", &iAttrIdReqDigitalSign));
			ITK_CALL(POM_set_attr_logical(1, &tNewRelation, iAttrIdReqDigitalSign, NULL));


			ITK_CALL(POM_attr_id_of_attr("fnd0CopyStableId", "ImanRelation", &iAttrIdCopyStableId));
			ITK_CALL(POM_set_attr_string(1, &tNewRelation, iAttrIdCopyStableId, sUID));

			ITK_CALL(POM_attr_id_of_attr("fnd0CopyStableDate", "ImanRelation", &iAttrIdCopyStableDate));
			ITK_CALL(POM_set_attr_date(1, &tNewRelation, iAttrIdCopyStableDate, copyStableDate));

			iStatus = POM_save_instances(1, &tNewRelation, true);
			ITK_CALL(iStatus);

			ITK_CALL(POM_is_loaded(tNewRelation, &is_loaded));

			if (is_loaded == true)
			{
				ITK_CALL(POM_unload_instances(1, &tNewRelation));
			}
		}

		// Create Relation
		//ITK_CALL(GRM_create_relation(tPrimaryObject, tSecondaryObject, tRelationType, NULLTAG, &tNewRelation));
		//ITK_CALL(GRM_save_relation(tNewRelation));

		//// Free
		//ITK_CALL(AOM_unload(tNewRelation));
	}
	else {
		//addInfoLog("Relation '", sRelationTypeForInfoLog,"' already exists -> don't create");
	}

	return iStatus;
}

int initBomViewandBomViewRevision(tag_t tParentItem, tag_t tParentRev, tag_t* pBV, tag_t* pBVR) {
	int iReturnValue = ITK_ok,
		iNumBVs = 0;

	tag_t* ptBVs = NULL;

	// BV / BVR existing?
	int ifail = (ITEM_list_bom_views(tParentItem, &iNumBVs, &ptBVs));
	if (ifail != ITK_ok) {
		printf("error \n");
	}
	if (iNumBVs == 0) {
		ITK_CALL(PS_create_bom_view(NULLTAG, "", "", tParentItem, pBV));
		ITK_CALL(AOM_save_without_extensions(*pBV));
		ITK_CALL(AOM_save_without_extensions(tParentItem));

		ITK_CALL(PS_create_bvr(*pBV, "", "", false, tParentRev, pBVR));
		ITK_CALL(AOM_save_without_extensions(*pBVR));
		ITK_CALL(AOM_save_without_extensions(tParentRev));

		ITK_CALL(AOM_refresh(tParentItem, false));
		ITK_CALL(AOM_refresh(tParentRev, false));
		ITK_CALL(AOM_refresh(*pBV, false));
		ITK_CALL(AOM_refresh(*pBVR, false));
	} else {
		int		iBvrCnt = 0;
		tag_t* taBVRs = NULL;

		*pBV = ptBVs[0];
		ITK_CALL(ITEM_rev_list_bom_view_revs(tParentRev, &iBvrCnt, &taBVRs));

		if (iBvrCnt > 0) {
			*pBVR = taBVRs[iBvrCnt - 1];
		} else {
			printf(" > Exception: BV without any BVRs - creating a new imprecise BVR with standard type \n");
			ITK_CALL(PS_create_bvr(*pBV, NULL, NULL, false, tParentRev, pBVR));
			ITK_CALL(AOM_save_without_extensions(*pBVR));
			ITK_CALL(AOM_save_without_extensions(tParentRev));

			ITK_CALL(AOM_refresh(tParentRev, false));
			ITK_CALL(AOM_refresh(*pBVR, false));
		}

		SAFE_SM_FREE(taBVRs);
	}

	return iReturnValue;
}

int sr5ReadAttrValue_TAG(tag_t tObject, char* sObjectType, char* sAttributeName, tag_t* tReturnValue)
{
	int
		status = ITK_ok,
		rows = 0,
		cols = 0;

	char
		* pQry1 = "__readAttrValue_TAG";

	const char
		* sSelectAttr[] = { sAttributeName };

	void
		*** ppReport = NULL;

	try
	{
		/* Check for existing Query */
		logical lExist = false;
		ITK_CALL(POM_enquiry_does_query_exists(pQry1, &lExist));
		if (lExist) ITK_CALL(POM_enquiry_delete(pQry1));

		/* Create Query */
		ITK_CALL(POM_enquiry_create(pQry1));

		/* Add Select-Attributes */
		ITK_CALL(POM_enquiry_add_select_attrs(pQry1, sObjectType, 1, sSelectAttr));

		/* Set Conditions */
		ITK_CALL(POM_enquiry_set_tag_value(pQry1, "BindExp1", 1, &tObject, POM_enquiry_bind_value));
		ITK_CALL(POM_enquiry_set_attr_expr(pQry1, "Exp1", sObjectType, "puid", POM_enquiry_equal, "BindExp1"));

		/* Set WHERE */
		ITK_CALL(POM_enquiry_set_where_expr(pQry1, "Exp1"));

		/* Execute Query */
		ITK_CALL(POM_enquiry_execute(pQry1, &rows, &cols, &ppReport));

		/* Delete Query */
		ITK_CALL(POM_enquiry_delete(pQry1));

		/* Traverse Results */
		for (int i = 0; i < rows; i++)
		{
			for (int ii = 0; ii < cols; ii++)
			{
				if (ii == 0)
				{
					/* tag_t */
					if ((tag_t*)ppReport[i][ii] != NULLTAG)
					{
						*tReturnValue = *((tag_t*)ppReport[i][ii]);
					}
				}
			}
		}
	}
	catch (...) {
		logical lExist = false;
		ITK_CALL(POM_enquiry_does_query_exists(pQry1, &lExist));
		if (lExist) ITK_CALL(POM_enquiry_delete(pQry1));
	}

	// Free
	SAFE_SM_FREE(ppReport);

	return status;
}

int sr5ReadAttrValue_STRING(tag_t tObject, char* sObjectType, char* sAttributeName, std::string* sReturnValue)
{
	int
		status = ITK_ok,
		rows = 0,
		cols = 0;

	char
		* pQry1 = "__readAttrValue_STRING";

	const char
		* sSelectAttr[] = { sAttributeName };

	void
		*** ppReport = NULL;

	try
	{
		/* Check for existing Query */
		logical lExist = false;
		ITK_CALL(POM_enquiry_does_query_exists(pQry1, &lExist));
		if (lExist) ITK_CALL(POM_enquiry_delete(pQry1));

		/* Create Query */
		ITK_CALL(POM_enquiry_create(pQry1));

		/* Add Select-Attributes */
		ITK_CALL(POM_enquiry_add_select_attrs(pQry1, sObjectType, 1, sSelectAttr));

		/* Set Conditions */
		ITK_CALL(POM_enquiry_set_tag_value(pQry1, "BindExp1", 1, &tObject, POM_enquiry_bind_value));
		ITK_CALL(POM_enquiry_set_attr_expr(pQry1, "Exp1", sObjectType, "puid", POM_enquiry_equal, "BindExp1"));

		/* Set WHERE */
		ITK_CALL(POM_enquiry_set_where_expr(pQry1, "Exp1"));

		/* Execute Query */
		ITK_CALL(POM_enquiry_execute(pQry1, &rows, &cols, &ppReport));

		/* Delete Query */
		ITK_CALL(POM_enquiry_delete(pQry1));

		/* Traverse Results */
		for (int i = 0; i < rows; i++)
		{
			for (int ii = 0; ii < cols; ii++)
			{
				if (ii == 0)
				{
					/* char* */
					char* sTmp = strdup((char*)ppReport[i][ii]);

					if (sTmp != NULL) {
						(*sReturnValue).assign(sTmp);
						delete sTmp;
					}
				}
			}
		}

		// Assign an empty string in case of NULL
		//if (*tReturnValue == NULL) *tReturnValue = "";
	}
	catch (...) {
		logical lExist = false;
		ITK_CALL(POM_enquiry_does_query_exists(pQry1, &lExist));
		if (lExist) ITK_CALL(POM_enquiry_delete(pQry1));
	}

	// Free
	SAFE_SM_FREE(ppReport);

	return status;
}

int sr5QryAttr_TAG(char* pClass, char* pSearchAttr, tag_t tSearchValue, vector<tag_t>* vecQryResults, logical lIncludingWsoActiveSeq)
{
	int
		rows = 0,
		cols = 0;

	// Main-Attributes
	const char
		* pQry1 = "Query1",
		* pMainExp1 = "Expression1",
		* pselectAttrs[] = { "puid" };

	// Sub-Attributes
	const char
		* pSubQry1 = "SubQuery1",
		* pSubClass = "WorkspaceObject",
		* pSubExp1 = "SubExpression1",
		* pSubExp2 = "SubExpression2",
		* pSubSelectAttrs[] = { "puid" };

	tag_t
		objectTag = NULLTAG;

	void
		*** ppReport = NULL;

	try
	{
		/* Check for existing Query */
		logical lExist = false;
		ITK_CALL(POM_enquiry_does_query_exists(pQry1, &lExist));
		if (lExist) ITK_CALL(POM_enquiry_delete(pQry1));

		// Create Query
		ITK_CALL(POM_enquiry_create(pQry1));

		// Set Main Select-Attributes
		ITK_CALL(POM_enquiry_add_select_attrs(pQry1, pClass, 1, pselectAttrs));

		// Set Main Where-Condition
		ITK_CALL(POM_enquiry_set_tag_expr(pQry1, pMainExp1, pClass, pSearchAttr, POM_enquiry_equal, tSearchValue));

		// Including WSO Active Sequence Check ?
		if (lIncludingWsoActiveSeq == true)
		{
			// Create Query
			ITK_CALL(POM_enquiry_set_sub_enquiry(pQry1, pSubQry1));

			// Set Sub Select-Attributes
			ITK_CALL(POM_enquiry_add_select_attrs(pSubQry1, pSubClass, 1, pSubSelectAttrs));

			// Set Sub Where-Condition
			ITK_CALL(POM_enquiry_set_int_expr(pSubQry1, pSubExp1, pSubClass, "active_seq", POM_enquiry_not_equal, 0));
			ITK_CALL(POM_enquiry_set_where_expr(pSubQry1, pSubExp1));


			// Connect Sub-Main
			ITK_CALL(POM_enquiry_set_attr_expr(pQry1, "SubMainQryConnection", pClass, "puid", POM_enquiry_in, pSubQry1));

			// Prepare Where
			ITK_CALL(POM_enquiry_set_expr(pQry1, pSubExp2, "SubMainQryConnection", POM_enquiry_and, pMainExp1));
		}

		// Set Where
		ITK_CALL(POM_enquiry_set_where_expr(pQry1, (lIncludingWsoActiveSeq == true) ? pSubExp2 : pMainExp1));

		// Execute Query
		ITK_CALL(POM_enquiry_execute(pQry1, &rows, &cols, &ppReport));

		// Assign Results
		for (int i = 0; i < rows; i++)
		{
			objectTag = *((tag_t*)ppReport[i][0]);
			(*vecQryResults).push_back(objectTag);
		}

		// Delete Query
		ITK_CALL(POM_enquiry_delete(pQry1));
	}
	catch (...) {
		logical lExist = false;
		ITK_CALL(POM_enquiry_does_query_exists(pQry1, &lExist));
		if (lExist) ITK_CALL(POM_enquiry_delete(pQry1));

		logical lExist2 = false;
		ITK_CALL(POM_enquiry_does_query_exists(pSubQry1, &lExist2));
		if (lExist2) ITK_CALL(POM_enquiry_delete(pSubQry1));
	}

	return ITK_ok;
}

int sr5QryAttr_STRING(char* pClass, char* pSearchAttr, const char* pSearchValue, std::vector<tag_t>* vecQryResults)
{
	int
		rows = 0,
		cols = 0;

	// Main-Attributes
	const char
		* pQry1 = "Query1",
		* pExp1 = "Expression1",
		* pselectAttrs[] = { "puid" };

	// Sub-Attributes
	const char
		* pSubQry1 = "SubQuery1",
		* pSubClass = "WorkspaceObject",
		* pSubExp1 = "SubExpression1",
		* pSubSelectAttrs[] = { "puid" };

	tag_t
		objectTag = NULLTAG;

	void
		*** ppReport = NULL;

	try
	{
		/* Check for existing Query */
		logical lExist = false;
		ITK_CALL(POM_enquiry_does_query_exists(pQry1, &lExist));
		if (lExist) ITK_CALL(POM_enquiry_delete(pQry1));

		//ITK_CALL(POM_enquiry_does_query_exists(pSubQry1, &lExist));
		//if(lExist) ITK_CALL(POM_enquiry_delete(pSubQry1)); 

		// Create Query
		ITK_CALL(POM_enquiry_create(pQry1));
		ITK_CALL(POM_enquiry_set_sub_enquiry(pQry1, pSubQry1));

		// Set Main Select-Attributes
		ITK_CALL(POM_enquiry_add_select_attrs(pQry1, pClass, 1, pselectAttrs));

		// Set Sub Select-Attributes
		ITK_CALL(POM_enquiry_add_select_attrs(pSubQry1, pSubClass, 1, pSubSelectAttrs));

		// Set Sub Where-Condition
		ITK_CALL(POM_enquiry_set_int_expr(pSubQry1, pSubExp1, pSubClass, "active_seq", POM_enquiry_not_equal, 0));
		ITK_CALL(POM_enquiry_set_where_expr(pSubQry1, pSubExp1));

		// Connect Sub-Main
		ITK_CALL(POM_enquiry_set_attr_expr(pQry1, "SubMainQryConnection", pClass, "puid", POM_enquiry_in, pSubQry1));

		// Set Main Where-Condition
		const char* str_list[] = { pSearchValue };
		ITK_CALL(POM_enquiry_set_string_value(pQry1, "MyConstParameter", 1, str_list, POM_enquiry_const_value));

		ITK_CALL(POM_enquiry_set_string_expr(pQry1, "MyUpperCase", pClass, pSearchAttr, POM_enquiry_upper, ""));

		ITK_CALL(POM_enquiry_set_expr(pQry1, pExp1, "MyUpperCase", POM_enquiry_equal, "MyConstParameter"));

		//ITK_CALL(POM_enquiry_set_string_expr(pQry1, pExp1, pClass, pSearchAttr, POM_enquiry_equal, (char*)pSearchValue));


		ITK_CALL(POM_enquiry_set_expr(pQry1, "AndExp1", "SubMainQryConnection", POM_enquiry_and, pExp1));

		ITK_CALL(POM_enquiry_set_where_expr(pQry1, "AndExp1"));

		// Execute Query
		ITK_CALL(POM_enquiry_execute(pQry1, &rows, &cols, &ppReport));

		// Assign Results
		for (int i = 0; i < rows; i++)
		{
			objectTag = *((tag_t*)ppReport[i][0]);
			(*vecQryResults).push_back(objectTag);
		}

		// Delete Query
		ITK_CALL(POM_enquiry_delete(pQry1));
	}
	catch (...) {
		logical lExist = false;
		ITK_CALL(POM_enquiry_does_query_exists(pQry1, &lExist));
		if (lExist) ITK_CALL(POM_enquiry_delete(pQry1));

		//logical lExist2 = false;
		//ITK_CALL(POM_enquiry_does_query_exists(pSubQry1, &lExist2));
		//if(lExist2) ITK_CALL(POM_enquiry_delete(pSubQry1)); 
	}

	return ITK_ok;
}

int sr5AskSecondaryObjects(tag_t tPrimaryObject, const char *cRelationType, char *sSecondaryType, vector<tag_t> *vSecondaryObjects)
{
	int
		status = ITK_ok,
		rows = 0,
		cols = 0;

	tag_t
		tRelationType = NULLTAG;

	char
		*pQry1 = "__ask_secodary_objects",
		*sClass_IMANRelation = "ImanRelation",
		*sClass_WorkspaceObject = "WorkspaceObject";

	const char
		*sSelectAttr_ImanRelation[] = { "secondary_object" },
		*sSelectAttr_WorkspaceObject[] = { "object_type" };

	void
		***ppReport = NULL;

	// Find relation type
	findRelationType(cRelationType, &tRelationType);

	try
	{
		/* Check for existing Query */
		logical lExist = false;
		ITK_CALL(POM_enquiry_does_query_exists(pQry1, &lExist));
		if (lExist) ITK_CALL(POM_enquiry_delete(pQry1));

		/* Create Query */
		ITK_CALL(POM_enquiry_create(pQry1));

		/* Add Select-Attributes */
		ITK_CALL(POM_enquiry_add_select_attrs(pQry1, sClass_IMANRelation, 1, sSelectAttr_ImanRelation));

		/* Join */
		ITK_CALL(POM_enquiry_set_join_expr(pQry1, "Exp1", sClass_WorkspaceObject, "puid", POM_enquiry_equal, sClass_IMANRelation, "secondary_object"));

		/* Relation Conditions */
		ITK_CALL(POM_enquiry_set_tag_expr(pQry1, "Exp2", sClass_IMANRelation, "relation_type", POM_enquiry_equal, tRelationType));
		ITK_CALL(POM_enquiry_set_tag_value(pQry1, "BindExp1", 1, &tPrimaryObject, POM_enquiry_bind_value));
		ITK_CALL(POM_enquiry_set_attr_expr(pQry1, "Exp3", sClass_IMANRelation, "primary_object", POM_enquiry_equal, "BindExp1"));

		/* WSO Conditions */
		ITK_CALL(POM_enquiry_set_int_expr(pQry1, "Exp4", sClass_WorkspaceObject, "active_seq", POM_enquiry_not_equal, 0));
		if(sSecondaryType != NULL) ITK_CALL(POM_enquiry_set_string_expr(pQry1, "Exp5", sClass_WorkspaceObject, "object_type", POM_enquiry_equal, sSecondaryType));

		/* Combine WHERE */
		ITK_CALL(POM_enquiry_set_expr(pQry1, "AndExp1", "Exp1", POM_enquiry_and, "Exp2"));
		ITK_CALL(POM_enquiry_set_expr(pQry1, "AndExp2", "AndExp1", POM_enquiry_and, "Exp3"));
		ITK_CALL(POM_enquiry_set_expr(pQry1, "AndExp3", "AndExp2", POM_enquiry_and, "Exp4"));
		if (sSecondaryType != NULL) ITK_CALL(POM_enquiry_set_expr(pQry1, "AndExp4", "AndExp3", POM_enquiry_and, "Exp5"));

		/* Set WHERE */
		ITK_CALL(POM_enquiry_set_where_expr(pQry1, (sSecondaryType != NULL ? "AndExp4" : "AndExp3")));

		/* Execute Query */
		ITK_CALL(POM_enquiry_execute(pQry1, &rows, &cols, &ppReport));

		/* Delete Query */
		ITK_CALL(POM_enquiry_delete(pQry1));

		/* Traverse Results */
		for (int i = 0; i < rows; i++)
		{
			for (int ii = 0; ii < cols; ii++)
			{
				if (ii == 0)
				{
					/* tag_t */
					tag_t tSecondaryObj = *((tag_t *)ppReport[i][ii]);

					// Add to vector
					vSecondaryObjects->push_back(tSecondaryObj);
				}
			}
		}
	}
	catch (...) {
		logical lExist = false;
		ITK_CALL(POM_enquiry_does_query_exists(pQry1, &lExist));
		if (lExist) ITK_CALL(POM_enquiry_delete(pQry1));
	}

	// Free
	SAFE_SM_FREE(ppReport);

	return status;
}

int sr5AskSecondaryObjects2(tag_t tPrimaryObject, const char* cRelationType, vector<tag_t>* vSecondaryObjects)
{
	int
		status = ITK_ok,
		rows = 0,
		cols = 0;

	tag_t
		tRelationType = NULLTAG;

	char
		* pQry1 = "__ask_secodary_objects",
		* sClass_IMANRelation = "ImanRelation",
		* sClass_WorkspaceObject = "WorkspaceObject";

	const char
		* sSelectAttr_ImanRelation[] = { "secondary_object" },
		* sSelectAttr_WorkspaceObject[] = { "object_type" };

	void
		*** ppReport = NULL;

	// Find relation type
	findRelationType(cRelationType, &tRelationType);

	try
	{
		/* Check for existing Query */
		logical lExist = false;
		ITK_CALL(POM_enquiry_does_query_exists(pQry1, &lExist));
		if (lExist) ITK_CALL(POM_enquiry_delete(pQry1));

		/* Create Query */
		ITK_CALL(POM_enquiry_create(pQry1));

		/* Add Select-Attributes */
		ITK_CALL(POM_enquiry_add_select_attrs(pQry1, sClass_IMANRelation, 1, sSelectAttr_ImanRelation));

		/* Join */
		ITK_CALL(POM_enquiry_set_join_expr(pQry1, "Exp1", sClass_WorkspaceObject, "puid", POM_enquiry_equal, sClass_IMANRelation, "secondary_object"));

		/* Relation Conditions */
		ITK_CALL(POM_enquiry_set_tag_expr(pQry1, "Exp2", sClass_IMANRelation, "relation_type", POM_enquiry_equal, tRelationType));
		ITK_CALL(POM_enquiry_set_tag_value(pQry1, "BindExp1", 1, &tPrimaryObject, POM_enquiry_bind_value));
		ITK_CALL(POM_enquiry_set_attr_expr(pQry1, "Exp3", sClass_IMANRelation, "primary_object", POM_enquiry_equal, "BindExp1"));

		/* WSO Conditions */
		ITK_CALL(POM_enquiry_set_int_expr(pQry1, "Exp4", sClass_WorkspaceObject, "active_seq", POM_enquiry_not_equal, 0));

		/* Combine WHERE */
		ITK_CALL(POM_enquiry_set_expr(pQry1, "AndExp1", "Exp1", POM_enquiry_and, "Exp2"));
		ITK_CALL(POM_enquiry_set_expr(pQry1, "AndExp2", "AndExp1", POM_enquiry_and, "Exp3"));
		ITK_CALL(POM_enquiry_set_expr(pQry1, "AndExp3", "AndExp2", POM_enquiry_and, "Exp4"));

		/* Set WHERE */
		ITK_CALL(POM_enquiry_set_where_expr(pQry1, "AndExp3"));

		/* Execute Query */
		ITK_CALL(POM_enquiry_execute(pQry1, &rows, &cols, &ppReport));

		/* Delete Query */
		ITK_CALL(POM_enquiry_delete(pQry1));

		/* Traverse Results */
		for (int i = 0; i < rows; i++)
		{
			for (int ii = 0; ii < cols; ii++)
			{
				if (ii == 0)
				{
					/* tag_t */
					tag_t tSecondaryObj = *((tag_t*)ppReport[i][ii]);

					// Add to vector
					vSecondaryObjects->push_back(tSecondaryObj);
				}
			}
		}
	}
	catch (...) {
		logical lExist = false;
		ITK_CALL(POM_enquiry_does_query_exists(pQry1, &lExist));
		if (lExist) ITK_CALL(POM_enquiry_delete(pQry1));
	}

	// Free
	SAFE_SM_FREE(ppReport);

	return status;
}

int sr5AskPrimaryObjects(tag_t tSecondaryObject, const char* cRelationType, char* sPrimaryType, vector<tag_t>* vPrimaryObjects)
{
	int
		status = ITK_ok,
		rows = 0,
		cols = 0;

	tag_t
		tRelationType = NULLTAG;

	char
		* pQry1 = "__ask_primary_objects",
		* sClass_IMANRelation = "ImanRelation",
		* sClass_WorkspaceObject = "WorkspaceObject";

	const char
		* sSelectAttr_ImanRelation[] = { "primary_object" },
		* sSelectAttr_WorkspaceObject[] = { "object_type" };

	void
		*** ppReport = NULL;

	// Find relation type
	findRelationType(cRelationType, &tRelationType);

	try
	{
		/* Check for existing Query */
		logical lExist = false;
		ITK_CALL(POM_enquiry_does_query_exists(pQry1, &lExist));
		if (lExist) ITK_CALL(POM_enquiry_delete(pQry1));

		/* Create Query */
		ITK_CALL(POM_enquiry_create(pQry1));

		/* Add Select-Attributes */
		ITK_CALL(POM_enquiry_add_select_attrs(pQry1, sClass_IMANRelation, 1, sSelectAttr_ImanRelation));

		/* Join */
		ITK_CALL(POM_enquiry_set_join_expr(pQry1, "Exp1", sClass_WorkspaceObject, "puid", POM_enquiry_equal, sClass_IMANRelation, "primary_object"));

		/* Relation Conditions */
		ITK_CALL(POM_enquiry_set_tag_expr(pQry1, "Exp2", sClass_IMANRelation, "relation_type", POM_enquiry_equal, tRelationType));
		ITK_CALL(POM_enquiry_set_tag_value(pQry1, "BindExp1", 1, &tSecondaryObject, POM_enquiry_bind_value));
		ITK_CALL(POM_enquiry_set_attr_expr(pQry1, "Exp3", sClass_IMANRelation, "secondary_object", POM_enquiry_equal, "BindExp1"));

		/* WSO Conditions */
		ITK_CALL(POM_enquiry_set_string_expr(pQry1, "Exp4", sClass_WorkspaceObject, "object_type", POM_enquiry_equal, sPrimaryType));
		ITK_CALL(POM_enquiry_set_int_expr(pQry1, "Exp5", sClass_WorkspaceObject, "active_seq", POM_enquiry_not_equal, 0));

		/* Combine WHERE */
		ITK_CALL(POM_enquiry_set_expr(pQry1, "AndExp1", "Exp1", POM_enquiry_and, "Exp2"));
		ITK_CALL(POM_enquiry_set_expr(pQry1, "AndExp2", "AndExp1", POM_enquiry_and, "Exp3"));
		ITK_CALL(POM_enquiry_set_expr(pQry1, "AndExp3", "AndExp2", POM_enquiry_and, "Exp4"));
		ITK_CALL(POM_enquiry_set_expr(pQry1, "AndExp4", "AndExp3", POM_enquiry_and, "Exp5"));

		/* Set WHERE */
		ITK_CALL(POM_enquiry_set_where_expr(pQry1, "AndExp4"));

		/* Execute Query */
		ITK_CALL(POM_enquiry_execute(pQry1, &rows, &cols, &ppReport));

		/* Delete Query */
		ITK_CALL(POM_enquiry_delete(pQry1));

		/* Traverse Results */
		for (int i = 0; i < rows; i++)
		{
			for (int ii = 0; ii < cols; ii++)
			{
				if (ii == 0)
				{
					/* tag_t */
					tag_t tSecondaryObj = *((tag_t*)ppReport[i][ii]);

					// Add to vector
					vPrimaryObjects->push_back(tSecondaryObj);
				}
			}
		}
	}
	catch (...) {
		logical lExist = false;
		ITK_CALL(POM_enquiry_does_query_exists(pQry1, &lExist));
		if (lExist) ITK_CALL(POM_enquiry_delete(pQry1));
	}

	// Free
	SAFE_SM_FREE(ppReport);

	return status;
}

int sr5AskPrimaryObjects2(tag_t tSecondaryObject, const char* cRelationType, vector<tag_t>* vPrimaryObjects)
{
	int
		status = ITK_ok,
		rows = 0,
		cols = 0;

	tag_t
		tRelationType = NULLTAG;

	char
		* pQry1 = "__ask_primary_objects",
		* sClass_IMANRelation = "ImanRelation",
		* sClass_WorkspaceObject = "WorkspaceObject";

	const char
		* sSelectAttr_ImanRelation[] = { "primary_object" },
		* sSelectAttr_WorkspaceObject[] = { "object_type" };

	void
		*** ppReport = NULL;

	// Find relation type
	findRelationType(cRelationType, &tRelationType);

	try
	{
		/* Check for existing Query */
		logical lExist = false;
		ITK_CALL(POM_enquiry_does_query_exists(pQry1, &lExist));
		if (lExist) ITK_CALL(POM_enquiry_delete(pQry1));

		/* Create Query */
		ITK_CALL(POM_enquiry_create(pQry1));

		/* Add Select-Attributes */
		ITK_CALL(POM_enquiry_add_select_attrs(pQry1, sClass_IMANRelation, 1, sSelectAttr_ImanRelation));

		/* Join */
		ITK_CALL(POM_enquiry_set_join_expr(pQry1, "Exp1", sClass_WorkspaceObject, "puid", POM_enquiry_equal, sClass_IMANRelation, "primary_object"));

		/* Relation Conditions */
		ITK_CALL(POM_enquiry_set_tag_expr(pQry1, "Exp2", sClass_IMANRelation, "relation_type", POM_enquiry_equal, tRelationType));
		ITK_CALL(POM_enquiry_set_tag_value(pQry1, "BindExp1", 1, &tSecondaryObject, POM_enquiry_bind_value));
		ITK_CALL(POM_enquiry_set_attr_expr(pQry1, "Exp3", sClass_IMANRelation, "secondary_object", POM_enquiry_equal, "BindExp1"));

		/* WSO Conditions */
		ITK_CALL(POM_enquiry_set_int_expr(pQry1, "Exp4", sClass_WorkspaceObject, "active_seq", POM_enquiry_not_equal, 0));

		/* Combine WHERE */
		ITK_CALL(POM_enquiry_set_expr(pQry1, "AndExp1", "Exp1", POM_enquiry_and, "Exp2"));
		ITK_CALL(POM_enquiry_set_expr(pQry1, "AndExp2", "AndExp1", POM_enquiry_and, "Exp3"));
		ITK_CALL(POM_enquiry_set_expr(pQry1, "AndExp3", "AndExp2", POM_enquiry_and, "Exp4"));

		/* Set WHERE */
		ITK_CALL(POM_enquiry_set_where_expr(pQry1, "AndExp3"));

		/* Execute Query */
		ITK_CALL(POM_enquiry_execute(pQry1, &rows, &cols, &ppReport));

		/* Delete Query */
		ITK_CALL(POM_enquiry_delete(pQry1));

		/* Traverse Results */
		for (int i = 0; i < rows; i++)
		{
			for (int ii = 0; ii < cols; ii++)
			{
				if (ii == 0)
				{
					/* tag_t */
					tag_t tSecondaryObj = *((tag_t*)ppReport[i][ii]);

					// Add to vector
					vPrimaryObjects->push_back(tSecondaryObj);
				}
			}
		}
	}
	catch (...) {
		logical lExist = false;
		ITK_CALL(POM_enquiry_does_query_exists(pQry1, &lExist));
		if (lExist) ITK_CALL(POM_enquiry_delete(pQry1));
	}

	// Free
	SAFE_SM_FREE(ppReport);

	return status;
}

/**
@brief Check if the current user session has the right to change the ownership of the object passed to this function

@param tag_t tObject

@return Error code
*/
int sr5HasPrivilegeChangeOwner(tag_t tObject)
{
	logical has_privilege = false;

	int iErrCode = AM_check_privilege(tObject, "CHANGE_OWNER", &has_privilege);
	EMH_clear_errors();

	if (has_privilege == false || iErrCode != ITK_ok) {
		char* cObjectName = NULL;
		WSOM_ask_name2(tObject, &cObjectName);
		EMH_store_error_s1(EMH_severity_error, 919607, cObjectName);
		SAFE_SM_FREE(cObjectName);
		return 919607;
	}
	return 0;
}

/**
@brief Check if the current user session has the right to write data on the object passed to this function

@param tag_t tObject

@return Error code
*/
int sr5HasPrivilegeWrite(tag_t tObject)
{
	logical has_privilege = false;

	int iErrCode = AM_check_privilege(tObject, "WRITE", &has_privilege);
	EMH_clear_errors();

	if (has_privilege == false || iErrCode != ITK_ok) {
		char *sObjectName = "";
		WSOM_ask_name2(tObject, &sObjectName);
		EMH_store_error_s1(EMH_severity_error, 919607, sObjectName);
		SAFE_SM_FREE(sObjectName);
		return 919607;
	}
	return 0;
}

/**
@brief Check if the current user session has the right to read data from the object passed to this function

@param tag_t tObject

@return Error code
*/
int sr5HasPrivilegeRead(tag_t tObject)
{
	logical has_privilege = false;

	int iErrCode = AM_check_privilege(tObject, "READ", &has_privilege);
	EMH_clear_errors();

	//PRINT(" > HAS PROVILEGE ? %i .. ERR CODE ? %i \n", has_privilege, iErrCode);

	if (has_privilege != 1 || iErrCode != ITK_ok) {
		//char cObjectName[WSO_name_size_c+1];
		//WSOM_ask_name(tObject, cObjectName);
		//EMH_store_error_s1(EMH_severity_error, 919607, cObjectName);
		return 919607;
	}
	return 0;
}

char* sr5GetActionHandlerArgument(TC_argument_list_t* pArgList, char *sArgumentName)
{
	char *sArgumentValue = NULL;

	// Get handler arguments
	int iArgCount = TC_number_of_arguments(pArgList);
	//ITK_CALL(EPM_setup_parser(msg.task));

	// Init cursor
	//TC_init_argument_list(msg.arguments);

	// Loop arguments
	for (int iIdx0 = 0; iIdx0 < iArgCount; iIdx0++)
	{
		char *pcArgName = NULL;
		char *pcArgValue = NULL;
		char* sNextArg = TC_next_argument(pArgList);

		//ITK_ask_argument_named_value( (const char*)arg, &pcArgName, &pcArgValue );
		int iRetCode = ITK_ask_argument_named_value((const char*)sNextArg, &pcArgName, &pcArgValue);

		// Read Argument
		if ((pcArgName != NULL) && (strcmp(pcArgName, sArgumentName) == 0) &&
			(pcArgValue != NULL) && (strlen(pcArgValue) > 0))
		{
			sArgumentValue = new char[strlen(pcArgValue) + 1];
			tc_strcpy(sArgumentValue, pcArgValue);
		}

		SAFE_SM_FREE(pcArgName);
		SAFE_SM_FREE(pcArgValue);
	}

	// Print Handler
	char sbuffer[256];
	sprintf(sbuffer, "FUNCTION 'getActionHandlerArgument' |  %s = %s", sArgumentName, sArgumentValue);
	PRINT(sbuffer);

	return sArgumentValue;
}

logical sr5IsValidLLObject(tag_t tWorkspaceobject) {
	logical lIsValidLL = false;
	string sObjectType;

	sr5ReadAttrValue_STRING(tWorkspaceobject, "WorkspaceObject", "object_type", &sObjectType);
	if (sObjectType.compare(SR5_TYPE_SR5LLMajorAssy) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5LLMajorAssyRevision) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5LLEndItem) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5LLEndItemRevision) == 0
		) {
		lIsValidLL = true;
	}

	return lIsValidLL;
}

logical sr5IsMDMObject(tag_t tWorkspaceobject) {
	logical lIsValidMfgAssy = false;
	string sObjectType;

	sr5ReadAttrValue_STRING(tWorkspaceobject, "WorkspaceObject", "object_type", &sObjectType);
	if (sObjectType.compare(SR5_TYPE_SR5CatDefArticle) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5CatDefArticleRevision) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5Weld) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5WeldRevision) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5ColorDef) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5ColorDefRevision) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5CoatingStruct) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5CoatingStructRevision) == 0
		) {
		lIsValidMfgAssy = true;
	}

	return lIsValidMfgAssy;
}

logical sr5IsValidMfgAssy(tag_t tWorkspaceobject) {
	logical lIsValidMfgAssy = false;
	string sObjectType;

	sr5ReadAttrValue_STRING(tWorkspaceobject, "WorkspaceObject", "object_type", &sObjectType);
	if (sObjectType.compare(SR5_TYPE_SR5MfgEndItem) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5MfgEndItemRevision) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5MfgMajorAssy) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5MfgMajorAssyRevision) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5MfgInstallKit) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5MfgInstallKitRevision) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5LLEndItem) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5LLEndItemRevision) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5LLMajorAssy) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5LLMajorAssyRevision) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5MfgObject) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5MfgObjectRevision) == 0
		) {
		lIsValidMfgAssy = true;
	}

	return lIsValidMfgAssy;
}

logical sr4IsValidEBOMObject(tag_t tWorkspaceobject) {
	logical lIsValidMfgAssy = false;
	string sObjectType;

	sr5ReadAttrValue_STRING(tWorkspaceobject, "WorkspaceObject", "object_type", &sObjectType);
	if (sObjectType.compare(SR5_TYPE_SR5EngEndItem) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5EngEndItemRevision) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5EngMajorAssy) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5EngMajorAssyRevision) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5EngArticle) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5EngArticleRevision) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5EngArticleAR) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5EngArticleARRevision) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5ElectricAssy) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5ElectricAssyRevision) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5GenCatPart) == 0 ||
		sObjectType.compare(SR5_TYPE_SR5GenCatPartRevision) == 0
		) {
		lIsValidMfgAssy = true;
	}

	return lIsValidMfgAssy;
}

int sr5HasStatus(tag_t tObject, char* sStatusName, logical* lHasStatus)
{
	int
		rows = 0,
		cols = 0;

	char
		* pQry1 = "__has_status",
		* sClass_WorkspaceObject = "WorkspaceObject",
		* sClass_ReleaseStatus = "ReleaseStatus";

	const char
		* saSelectAttrs_WorkspaceObject[] = { "puid" };

	void
		*** ppReport = NULL;

	// Reset param
	(*lHasStatus) = false;

	try
	{
		/* Check for existing Query */
		logical lExist = false;
		ITK_CALL(POM_enquiry_does_query_exists(pQry1, &lExist));
		if (lExist) ITK_CALL(POM_enquiry_delete(pQry1));

		/* Create Query */
		ITK_CALL(POM_enquiry_create(pQry1));

		/* Add Select-Attributes */
		ITK_CALL(POM_enquiry_add_select_attrs(pQry1, sClass_WorkspaceObject, 1, saSelectAttrs_WorkspaceObject));

		/* Join */
		ITK_CALL(POM_enquiry_set_join_expr(pQry1, "SubExp1", sClass_WorkspaceObject, "release_status_list", POM_enquiry_equal, sClass_ReleaseStatus, "puid"));

		/* Conditions */
		ITK_CALL(POM_enquiry_set_tag_value(pQry1, "BindExp1", 1, &tObject, POM_enquiry_bind_value));
		ITK_CALL(POM_enquiry_set_attr_expr(pQry1, "SubExp2", sClass_WorkspaceObject, "puid", POM_enquiry_equal, "BindExp1"));
		if (sStatusName != NULL && tc_strcmp(sStatusName, "") != 0) ITK_CALL(POM_enquiry_set_string_expr(pQry1, "SubExp3", sClass_ReleaseStatus, "name", POM_enquiry_equal, sStatusName));

		/* Combine WHERE */
		ITK_CALL(POM_enquiry_set_expr(pQry1, "AndExp1", "SubExp1", POM_enquiry_and, "SubExp2"));
		if (sStatusName != NULL && tc_strcmp(sStatusName, "") != 0) ITK_CALL(POM_enquiry_set_expr(pQry1, "AndExp2", "AndExp1", POM_enquiry_and, "SubExp3"));

		/* Set WHERE */
		if (sStatusName != NULL && tc_strcmp(sStatusName, "") != 0) {
			ITK_CALL(POM_enquiry_set_where_expr(pQry1, "AndExp2"));

		}
		else {
			ITK_CALL(POM_enquiry_set_where_expr(pQry1, "AndExp1"));
		}

		/* Execute Query */
		ITK_CALL(POM_enquiry_execute(pQry1, &rows, &cols, &ppReport));

		/* Delete Query */
		ITK_CALL(POM_enquiry_delete(pQry1));

		/* Traverse Results */
		for (int i = 0; i < rows; i++)
		{
			for (int ii = 0; ii < cols; ii++)
			{
				(*lHasStatus) = true;
				break;
			}

			if ((*lHasStatus)) break;
		}
	}
	catch (...) {
		logical lExist = false;
		ITK_CALL(POM_enquiry_does_query_exists(pQry1, &lExist));
		if (lExist) ITK_CALL(POM_enquiry_delete(pQry1));
	}

	// Free
	SAFE_SM_FREE(ppReport);

	return ITK_ok;
}

int sr5DeriveMainMBOMfromEBOM(tag_t tSourceTopLine, tag_t tTargetTopLine, tag_t tCurrentSourceLine, tag_t tCurrentTargetParentLine, char* sPlant, logical lIsRoot, int iLevel, int iMaxLevel) {
	int iReturnValue = ITK_ok;
	tag_t tTargetLine = NULLTAG;
	char* sSourceRevName = NULL;

	// Skip levels above threshold
	if (iMaxLevel > 0 && iLevel > iMaxLevel) {
		// Init default IKIT in case of leaf-level
		int iTargetChildLines = 0;
		tag_t* taTargetChildLines = NULL;

		ITK_CALL(BOM_line_ask_child_lines(tCurrentTargetParentLine, &iTargetChildLines, &taTargetChildLines));
		SAFE_SM_FREE(taTargetChildLines);

		if (iTargetChildLines == 0) {
			tag_t tTargetBV = NULLTAG, tTargetBVR = NULLTAG, tTargetItem = NULLTAG, tTargetRev = NULLTAG;

			tag_t	tTargetIKitItemType = NULLTAG,
				tTargetIKitItemCreateInput = NULLTAG,
				tTargetIKitItem = NULLTAG,
				tTargetIKitLine = NULLTAG;

			std::stringstream ssTargetIKitName;
			ssTargetIKitName << "Default IKIT";

			TCTYPE_find_type(SR5_TYPE_SR5MfgInstallKit, NULL, &tTargetIKitItemType);
			ITK_CALL(TCTYPE_construct_create_input(tTargetIKitItemType, &tTargetIKitItemCreateInput));
			ITK_CALL(AOM_set_value_string(tTargetIKitItemCreateInput, SR5_ATTR_objectName, ssTargetIKitName.str().c_str()));
			ITK_CALL(AOM_set_value_string(tTargetIKitItemCreateInput, "sr5Plant", sPlant));

			ITK_CALL(TCTYPE_create_object(tTargetIKitItemCreateInput, &tTargetIKitItem));
			ITK_CALL(AOM_save_without_extensions(tTargetIKitItem));
			ITK_CALL(AOM_refresh(tTargetIKitItem, false));

			ITK_CALL(AOM_ask_value_tag(tCurrentTargetParentLine, bomAttr_lineItemTag, &tTargetItem));
			ITK_CALL(AOM_ask_value_tag(tCurrentTargetParentLine, bomAttr_lineItemRevTag, &tTargetRev));
			initBomViewandBomViewRevision(tTargetItem, tTargetRev, &tTargetBV, &tTargetBVR);
			ITK_CALL(BOM_line_add(tCurrentTargetParentLine, tTargetIKitItem, NULLTAG, NULLTAG, &tTargetIKitLine));
			ITK_CALL(AOM_save_without_extensions(tTargetBVR));

			char* sNextSeqNo = NULL;
			ITK_CALL(PS_bvr_ask_default_next_seq_no(tTargetBVR, tTargetIKitItem, &sNextSeqNo));
			ITK_CALL(AOM_set_value_string(tTargetIKitLine, bomAttr_occSeqNo, sNextSeqNo));

			SAFE_SM_FREE(sNextSeqNo);
		}

		return iReturnValue;
	}

	// Skip alignment handling for top-line
	if (lIsRoot == false) {
		char* sSourceObjectType = NULL;

		ITK_CALL(AOM_ask_value_string(tCurrentSourceLine, "bl_item_object_type", &sSourceObjectType));
		if (tc_strcmp(sSourceObjectType, SR5_TYPE_SR5EngMajorAssy) == 0) {
			tag_t* taFoundLines = NULL;
			int iFoundLines = 0;

			// Target already existing?
			ITK_CALL(ME_find_node_in_context(tTargetTopLine, tCurrentSourceLine, true, true, NULLTAG, &taFoundLines, &iFoundLines));
			if (iFoundLines == 0) {
				char	//*sSourceAbsOccID = NULL,
						*sSourceItemID = NULL;

				ITK_CALL(AOM_ask_value_string(tCurrentSourceLine, bomAttr_itemId, &sSourceItemID));
				ITK_CALL(AOM_ask_value_string(tCurrentSourceLine, bomAttr_itemRevName, &sSourceRevName));
				//ITK_CALL(AOM_ask_value_string(tCurrentSourceLine, bomAttr_absOccID, &sSourceAbsOccID));

				//if (tc_strcmp(sSourceAbsOccID, "") == 0) {
				//	// TODO: Generate unique IDIC !!!

				//	tag_t tTmpOcc = NULLTAG;
				//	ITK_CALL(AOM_ask_value_tag(tCurrentSourceLine, bomAttr_realOccurrence, &tTmpOcc));
				//	ITK__convert_tag_to_uid(tTmpOcc, &sSourceAbsOccID);

				//	ITK_CALL(AOM_set_value_string(tCurrentSourceLine, bomAttr_absOccID, sSourceAbsOccID));
				//}

				const char
					* sQryAttrNames[2] = { ITEM_ITEM_ID_PROP, SR5_ATTR_objectType },
					* sQryAttrValues[2] = { sSourceItemID, SR5_TYPE_SR5MfgMajorAssy };
				int iTargetResults = 0;
				tag_t* taResults = NULL;
				tag_t tTargetItem = NULLTAG;
				ITK_CALL(ITEM_find_items_by_key_attributes(2, sQryAttrNames, sQryAttrValues, &iTargetResults, &taResults));

				if (iTargetResults == 0) {
					tag_t	tTargetItemType = NULLTAG,
						tTargetItemCreateInput = NULLTAG;

					TCTYPE_find_type(SR5_TYPE_SR5MfgMajorAssy, NULL, &tTargetItemType);
					ITK_CALL(TCTYPE_construct_create_input(tTargetItemType, &tTargetItemCreateInput));
					ITK_CALL(AOM_set_value_string(tTargetItemCreateInput, ITEM_ITEM_ID_PROP, sSourceItemID));
					ITK_CALL(AOM_set_value_string(tTargetItemCreateInput, SR5_ATTR_objectName, sSourceRevName));
					ITK_CALL(AOM_set_value_string(tTargetItemCreateInput, "sr5Plant", sPlant));

					ITK_CALL(TCTYPE_create_object(tTargetItemCreateInput, &tTargetItem));
					ITK_CALL(AOM_save_without_extensions(tTargetItem));
					ITK_CALL(AOM_refresh(tTargetItem, false));
				} else {
					tTargetItem = taResults[0];
				}

				tag_t tBV = NULLTAG, tBVR = NULLTAG, tParentItem = NULLTAG, tParentRev = NULLTAG;
				ITK_CALL(AOM_ask_value_tag(tCurrentTargetParentLine, bomAttr_lineItemTag, &tParentItem));
				ITK_CALL(AOM_ask_value_tag(tCurrentTargetParentLine, bomAttr_lineItemRevTag, &tParentRev));
				initBomViewandBomViewRevision(tParentItem, tParentRev, &tBV, &tBVR);

				ITK_CALL(BOM_line_add(tCurrentTargetParentLine, tTargetItem, NULLTAG, NULLTAG, &tTargetLine));
				ITK_CALL(AOM_save_without_extensions(tBVR));
				//ITK_CALL(AOM_set_value_string(tTargetLine, bomAttr_absOccID, sSourceAbsOccID));
			
				char *sNextSeqNo = NULL;
				ITK_CALL(PS_bvr_ask_default_next_seq_no(tBVR, tTargetItem, &sNextSeqNo));
				ITK_CALL(AOM_set_value_string(tTargetLine, bomAttr_occSeqNo, sNextSeqNo));

				SAFE_SM_FREE(sNextSeqNo);
				//SAFE_SM_FREE(sSourceAbsOccID);
				SAFE_SM_FREE(sSourceItemID);
				SAFE_SM_FREE(taResults);
			} else {
				tTargetLine = taFoundLines[0];
			}

			SAFE_SM_FREE(taFoundLines);
		}

		SAFE_SM_FREE(sSourceObjectType);
	} else {
		tTargetLine = tTargetTopLine;
	}

	if (tTargetLine != NULLTAG) {
		int iSourceChildLines = 0;
		tag_t* taSourceChildLines = NULL;

		ITK_CALL(BOM_line_ask_child_lines(tCurrentSourceLine, &iSourceChildLines, &taSourceChildLines));

		// Recursive traversal of child lines
		for (int i = 0; i < iSourceChildLines; i++) {
			sr5DeriveMainMBOMfromEBOM(tSourceTopLine, tTargetTopLine, taSourceChildLines[i], tTargetLine, sPlant, false, iLevel+1, iMaxLevel);
		}
		SAFE_SM_FREE(taSourceChildLines);

		// Init default IKIT in case of leaf-level
		if (iSourceChildLines == 0) {
			int iTargetChildLines = 0;
			tag_t* taTargetChildLines = NULL;

			ITK_CALL(BOM_line_ask_child_lines(tTargetLine, &iTargetChildLines, &taTargetChildLines));
			SAFE_SM_FREE(taTargetChildLines);

			if (iTargetChildLines == 0) {
				tag_t tTargetBV = NULLTAG, tTargetBVR = NULLTAG, tTargetItem = NULLTAG, tTargetRev = NULLTAG;

				tag_t	tTargetIKitItemType = NULLTAG,
						tTargetIKitItemCreateInput = NULLTAG,
						tTargetIKitItem = NULLTAG,
						tTargetIKitLine = NULLTAG;

				std::stringstream ssTargetIKitName;
				ssTargetIKitName << "Default IKIT " << sSourceRevName;

				TCTYPE_find_type(SR5_TYPE_SR5MfgInstallKit, NULL, &tTargetIKitItemType);
				ITK_CALL(TCTYPE_construct_create_input(tTargetIKitItemType, &tTargetIKitItemCreateInput));
				ITK_CALL(AOM_set_value_string(tTargetIKitItemCreateInput, SR5_ATTR_objectName, ssTargetIKitName.str().c_str()));
				ITK_CALL(AOM_set_value_string(tTargetIKitItemCreateInput, "sr5Plant", sPlant));

				ITK_CALL(TCTYPE_create_object(tTargetIKitItemCreateInput, &tTargetIKitItem));
				ITK_CALL(AOM_save_without_extensions(tTargetIKitItem));
				ITK_CALL(AOM_refresh(tTargetIKitItem, false));

				ITK_CALL(AOM_ask_value_tag(tTargetLine, bomAttr_lineItemTag, &tTargetItem));
				ITK_CALL(AOM_ask_value_tag(tTargetLine, bomAttr_lineItemRevTag, &tTargetRev));
				initBomViewandBomViewRevision(tTargetItem, tTargetRev, &tTargetBV, &tTargetBVR);
				ITK_CALL(BOM_line_add(tTargetLine, tTargetIKitItem, NULLTAG, NULLTAG, &tTargetIKitLine));
				ITK_CALL(AOM_save_without_extensions(tTargetBVR));

				char* sNextSeqNo = NULL;
				ITK_CALL(PS_bvr_ask_default_next_seq_no(tTargetBVR, tTargetIKitItem, &sNextSeqNo));
				ITK_CALL(AOM_set_value_string(tTargetIKitLine, bomAttr_occSeqNo, sNextSeqNo));

				SAFE_SM_FREE(sNextSeqNo);
			}
		}
	}

	SAFE_SM_FREE(sSourceRevName);

	return iReturnValue;
}

int createPart(const char* sPartType, tag_t* tNewItem) {
	int iReturnValue = ITK_ok;

	tag_t	tPartInputObject = NULLTAG,
			tPartType = NULLTAG;

	ITK_CALL(TCTYPE_ask_type(sPartType, &tPartType));
	ITK_CALL(TCTYPE_construct_create_input(tPartType, &tPartInputObject));
	ITK_CALL(TCTYPE_create_object(tPartInputObject, tNewItem));
	
	ITK_CALL(AOM_save_without_extensions(*tNewItem));
	ITK_CALL(AOM_refresh(*tNewItem, false));
	ITK_CALL(AOM_unload(*tNewItem));

	return iReturnValue;
}

int createMPart(const char* sMPartItemType, const char* sMPartRevType, const char *sItemID, const char *sPlant, const char *sName, tag_t tBaseUOM, tag_t* tNewItem) {
	int iReturnValue = ITK_ok;

	if (tc_strcmp(sMPartItemType, "") != 0 && tc_strcmp(sMPartRevType, "") != 0 && tc_strcmp(sItemID, "") != 0 && tc_strcmp(sPlant, "") != 0) {
		tag_t	tMPartItemInputObject = NULLTAG,
				tMPartItemType = NULLTAG,
				tMPartRevInputObject = NULLTAG,
				tMPartRevType = NULLTAG;

		ITK_CALL(TCTYPE_ask_type(sMPartItemType, &tMPartItemType));
		ITK_CALL(TCTYPE_ask_type(sMPartRevType, &tMPartRevType));

		ITK_CALL(TCTYPE_construct_create_input(tMPartItemType, &tMPartItemInputObject));

		if (tc_strcmp(sItemID, "") != 0) ITK_CALL(AOM_set_value_string(tMPartItemInputObject, ITEM_ITEM_ID_PROP, sItemID));
		if (tc_strcmp(sPlant, "") != 0) ITK_CALL(AOM_set_value_string(tMPartItemInputObject, "sr5Plant", sPlant));
		if (tc_strcmp(sName, "") != 0) ITK_CALL(AOM_set_value_string(tMPartItemInputObject, SR5_ATTR_objectName, sName));
		if (tBaseUOM) ITK_CALL(AOM_set_value_tag(tMPartItemInputObject, "uom_tag", tBaseUOM));

		ITK_CALL(TCTYPE_construct_create_input(tMPartRevType, &tMPartRevInputObject));
		ITK_CALL(AOM_set_value_string(tMPartRevInputObject, SR5_ATTR_objectName, sName));
		ITK_CALL(AOM_set_value_tag(tMPartItemInputObject, "revision", tMPartRevInputObject));

		ITK_CALL(TCTYPE_create_object(tMPartItemInputObject, tNewItem));

		ITK_CALL(AOM_save_without_extensions(*tNewItem));
		ITK_CALL(AOM_refresh(*tNewItem, false));
		ITK_CALL(AOM_unload(*tNewItem));
	}

	return iReturnValue;
}

int createEPart(const char* sEPartItemType, const char* sEPartRevType, const char* sItemID, const char* sName, tag_t* tNewItem) {
	int iReturnValue = ITK_ok;

	if (tc_strcmp(sEPartItemType, "") != 0 && tc_strcmp(sEPartRevType, "") != 0 && tc_strcmp(sItemID, "") != 0) {
		tag_t	tEPartItemInputObject = NULLTAG,
				tEPartItemType = NULLTAG,
				tEPartRevInputObject = NULLTAG,
				tEPartRevType = NULLTAG;

		ITK_CALL(TCTYPE_ask_type(sEPartItemType, &tEPartItemType));
		ITK_CALL(TCTYPE_ask_type(sEPartRevType, &tEPartRevType));

		ITK_CALL(TCTYPE_construct_create_input(tEPartItemType, &tEPartItemInputObject));

		if (tc_strcmp(sItemID, "") != 0) ITK_CALL(AOM_set_value_string(tEPartItemInputObject, ITEM_ITEM_ID_PROP, sItemID));
		if (tc_strcmp(sName, "") != 0) ITK_CALL(AOM_set_value_string(tEPartItemInputObject, SR5_ATTR_objectName, sName));

		ITK_CALL(TCTYPE_construct_create_input(tEPartRevType, &tEPartRevInputObject));
		ITK_CALL(AOM_set_value_string(tEPartRevInputObject, SR5_ATTR_objectName, sName));
		ITK_CALL(AOM_set_value_tag(tEPartItemInputObject, "revision", tEPartRevInputObject));

		ITK_CALL(TCTYPE_create_object(tEPartItemInputObject, tNewItem));

		ITK_CALL(AOM_save_without_extensions(*tNewItem));
		ITK_CALL(AOM_refresh(*tNewItem, false));
		ITK_CALL(AOM_unload(*tNewItem));
	}

	return iReturnValue;
}

int renameCatiaDatasetAfterSaveAs(std::string sNewIdString, tag_t tNewCatiaDataset, const char* sNamedReference, const char* sFileExtension, string sNewRevID) {
	if (sNewIdString.empty() == false && tNewCatiaDataset != NULL && tc_strcmp(sNamedReference, "") != 0 && tc_strcmp(sFileExtension, "") != 0) {
		{
			int iCatFileCount = 0;
			tag_t* taCatFiles = NULL;
			ITK_CALL(AE_ask_all_dataset_named_refs2(tNewCatiaDataset, sNamedReference, &iCatFileCount, &taCatFiles));

			for (int j = 0; j < iCatFileCount; j++) {
				std::stringstream ssFilename;
				ssFilename << sNewIdString << "." << sFileExtension;

				ITK_CALL(AOM_refresh(taCatFiles[j], TRUE));
				ITK_CALL(IMF_set_original_file_name2(taCatFiles[j], ssFilename.str().c_str()));
				ITK_CALL(AOM_save_with_extensions(taCatFiles[j]));
				ITK_CALL(AOM_refresh(taCatFiles[j], FALSE));
				ITK_CALL(AOM_unlock(taCatFiles[j]));
			}
			SAFE_SM_FREE(taCatFiles);
		}

		if(tc_strcmp(sNamedReference, "catpart") == 0 || tc_strcmp(sNamedReference, "catproduct") == 0) {
			int iCatAttrCount = 0;
			tag_t* taCatAttrForms = NULL;
			ITK_CALL(AE_ask_all_dataset_named_refs2(tNewCatiaDataset, "catia_doc_attributes", &iCatAttrCount, &taCatAttrForms));

			for (int j = 0; j < iCatAttrCount; j++) {std::stringstream ssFilename;
				ssFilename << sNewIdString << "/" << sNewRevID;

				ITK_CALL(AOM_refresh(taCatAttrForms[j], TRUE));
				ITK_CALL(WSOM_set_name2(taCatAttrForms[j], ssFilename.str().c_str()));
				ITK_CALL(AOM_save_with_extensions(taCatAttrForms[j]));
				ITK_CALL(AOM_refresh(taCatAttrForms[j], FALSE));
				ITK_CALL(AOM_unlock(taCatAttrForms[j]));
			}
			SAFE_SM_FREE(taCatAttrForms);
		}
	}

	return ITK_ok;
}

int sr5BulkCreateCATProductDatasets(tag_t tCurrentBOMLine, vector<string> vecObjectTypes) {
	char* sObjectType = NULL;
	logical lValidObjectType = false;

	
	ITK_CALL(AOM_ask_value_string(tCurrentBOMLine, "bl_rev_object_type", &sObjectType));
	for (int i = 0; i < vecObjectTypes.size(); i++) {
		if (vecObjectTypes.at(i).compare(sObjectType) == 0) {
			lValidObjectType = true;
			break;
		}
	}
	SAFE_SM_FREE(sObjectType);

	if (lValidObjectType == true) {
		tag_t tBomLineItem = NULLTAG;
		tag_t tBomLineRevision = NULLTAG;
		ITK_CALL(AOM_ask_value_tag(tCurrentBOMLine, "bl_item", &tBomLineItem));
		ITK_CALL(AOM_ask_value_tag(tCurrentBOMLine, "bl_revision", &tBomLineRevision));

		// Create CATProduct
		vector<tag_t> vecTmpSecondaryObjects;
		sr5AskSecondaryObjects(tBomLineRevision, TC_specification_rtype, "CATProduct", &vecTmpSecondaryObjects);

		if (vecTmpSecondaryObjects.size() == 0) {
			tag_t tCATProductType = NULLTAG;

			ITK_CALL(AE_find_datasettype2("CATProduct", &tCATProductType));

			if (tCATProductType != NULLTAG) {
				tag_t tNewDataset = NULLTAG;
				tag_t tDatasetTool = NULLTAG;

				char* sItemID = NULL;
				char* sRevID = NULL;
				ITK_CALL(AOM_ask_value_string(tCurrentBOMLine, "bl_rev_item_id", &sItemID));
				ITK_CALL(AOM_ask_value_string(tCurrentBOMLine, "bl_rev_item_revision_id", &sRevID));

				stringstream ssDatasetName;
				ssDatasetName << sItemID << "/" << sRevID;

				ITK_CALL(AE_ask_datasettype_def_tool(tCATProductType, &tDatasetTool));
				ITK_CALL(AE_create_dataset_with_id(tCATProductType, ssDatasetName.str().c_str(), "", "ds_id", sRevID, &tNewDataset));
				ITK_CALL(AE_set_dataset_tool(tNewDataset, tDatasetTool));
				ITK_CALL(AE_set_dataset_format2(tNewDataset, "BINARY_REF"));
				ITK_CALL(AOM_save_without_extensions(tNewDataset));

				createRelation(tBomLineRevision, tNewDataset, TC_specification_rtype, NULL);

				SAFE_SM_FREE(sItemID);
				SAFE_SM_FREE(sRevID);
			}
		}

		// Init BV / BVR
		tag_t tBV = NULLTAG, tBVR = NULLTAG;
		initBomViewandBomViewRevision(tBomLineItem, tBomLineRevision, &tBV, &tBVR);

		// Traverse Child Lines + Recursive Call
		int iChildCount = 0;
		tag_t* taChildLines = NULL;
		ITK_CALL(BOM_line_ask_all_child_lines(tCurrentBOMLine, &iChildCount, &taChildLines));

		for (int i = 0; i < iChildCount; i++) {
			sr5BulkCreateCATProductDatasets(taChildLines[i], vecObjectTypes);
		}

		SAFE_SM_FREE(taChildLines);
	}

	return ITK_ok;
}

/*
int sr5DuplicateOneLevelStructure(tag_t tSourceItem, tag_t tTargetItem) {
	int iRetVal = 0;
	tag_t tLatestSourceRev = NULLTAG;
	tag_t tLatestTargetRev = NULLTAG;

	ITK_CALL(ITEM_ask_latest_rev(tSourceItem, &tLatestSourceRev));
	ITK_CALL(ITEM_ask_latest_rev(tTargetItem, &tLatestTargetRev));

	int iStructRevsCount = 0;
	tag_t* taStructRevs = NULL;
	ITK_CALL(AOM_ask_value_tags(tLatestSourceRev, "structure_revisions", &iStructRevsCount, &taStructRevs));
	SAFE_SM_FREE(taStructRevs);

	if (iStructRevsCount > 0) {
		tag_t tRevRule = NULLTAG;
		tag_t tSourceWindow = NULLTAG;
		tag_t tSourceTopLine = NULLTAG;
		tag_t tTargetWindow = NULLTAG;
		tag_t tTargetTopLine = NULLTAG;

		ITK_CALL(BOM_create_window(&tSourceWindow));
		ITK_CALL(CFM_find(SR5_REVRULE_LatestWorking, &tRevRule));
		ITK_CALL(BOM_set_window_config_rule(tSourceWindow, tRevRule));
		ITK_CALL(BOM_set_window_top_line(tSourceWindow, tSourceItem, NULLTAG, NULLTAG, &tSourceTopLine));
		ITK_CALL(BOM_set_window_pack_all(tSourceWindow, false));

		int iSourceChildCount = 0;
		tag_t* taSourceChildLines = NULL;
		ITK_CALL(BOM_line_ask_all_child_lines(tSourceTopLine, &iSourceChildCount, &taSourceChildLines));

		if (iSourceChildCount > 0) {
			tag_t tTmpBV = NULLTAG;
			tag_t tTmpBVR = NULLTAG;
			initBomViewandBomViewRevision(tTargetItem, tLatestTargetRev, &tTmpBV, &tTmpBVR);

			ITK_CALL(BOM_create_window(&tTargetWindow));
			ITK_CALL(BOM_set_window_config_rule(tTargetWindow, tRevRule));
			ITK_CALL(BOM_set_window_top_line(tTargetWindow, tTargetItem, NULLTAG, NULLTAG, &tTargetTopLine));
			ITK_CALL(BOM_set_window_pack_all(tTargetWindow, false));
		}

		for (int i = 0; i < iSourceChildCount; i++) {
			tag_t tTmpChildItem = NULLTAG;
			tag_t tTmpUOM = NULLTAG;
			char* sTmpSeqNo = NULL;
			double dTmpQuantity = 0;

			ITK_CALL(AOM_ask_value_tag(taSourceChildLines[i], bomAttr_lineItemTag, &tTmpChildItem));
			ITK_CALL(AOM_ask_value_string(taSourceChildLines[i], bomAttr_occSeqNo, &sTmpSeqNo));
			ITK_CALL(AOM_ask_value_double(taSourceChildLines[i],  "bl_real_quantity", &dTmpQuantity));
			ITK_CALL(AOM_ask_value_tag(taSourceChildLines[i], bomAttr_occUoM, &tTmpUOM));

			tag_t tTmpNewLine = NULLTAG;
			ITK_CALL(BOM_line_add(tTargetTopLine, tTmpChildItem, NULLTAG, NULLTAG, &tTmpNewLine));

			stringstream ssQty;
			ssQty << dTmpQuantity;
			ITK_CALL(AOM_set_value_string(tTmpNewLine, bomAttr_occSeqNo, sTmpSeqNo));
			ITK_CALL(AOM_set_value_string(tTmpNewLine, "bl_quantity", ssQty.str().c_str()));
			ITK_CALL(AOM_set_value_tag(tTmpNewLine, bomAttr_occUoM, tTmpUOM));

			SAFE_SM_FREE(sTmpSeqNo);
		}

		ITK_CALL(BOM_close_window(tSourceWindow));
		if (iSourceChildCount > 0) {
			ITK_CALL(BOM_save_window(tTargetWindow));
			ITK_CALL(BOM_close_window(tTargetWindow));
		}

		SAFE_SM_FREE(taSourceChildLines);
	}

	return iRetVal;
}*/

int sr5InitLocalizedTargetObjectAndCollaborationContext(tag_t tSourceItemRevision, tag_t *tTargetItemRevision, const char* sTargetItemType, const char* sTargetItemRevType, const char* sPlant, const char* sCustomRelTypeBetweenSourceAndTarget, const char* sCCName, const char* sAttrToLinkCCToSourceRev, const char *sTargetStructName, const char *sSourceRevRule, const char *sTargetRevRule, logical lUseMFKItemID) {
	if (tSourceItemRevision != NULLTAG && tc_strcmp(sTargetItemType, "") != 0 && tc_strcmp(sTargetItemRevType, "") != 0 && tc_strcmp(sPlant, "") != 0 && tc_strcmp(sCustomRelTypeBetweenSourceAndTarget, "") != 0 && tc_strcmp(sCCName, "") != 0 && tc_strcmp(sAttrToLinkCCToSourceRev, "") != 0 && tc_strcmp(sTargetStructName, "") != 0) {
		char* sObjectName = NULL,
			* sItemID = NULL,
			* sRevID = NULL;
		tag_t tSourceItem = NULLTAG,
			tTargetItem = NULLTAG;

		int iQueryResults = 0;
		tag_t* taQueryResults = NULL;

		ITK_CALL(WSOM_ask_name2(tSourceItemRevision, &sObjectName));
		ITK_CALL(ITEM_ask_item_of_rev(tSourceItemRevision, &tSourceItem));
		ITK_CALL(ITEM_ask_id2(tSourceItem, &sItemID));
		ITK_CALL(ITEM_ask_rev_id2(tSourceItemRevision, &sRevID));

		// Find/Create MBOM
		/* TODO: Search for Plant!!!*/
		if (lUseMFKItemID == true) {
			const char
				* sQryAttrNames[2] = { ITEM_ITEM_ID_PROP, SR5_ATTR_objectType },
				* sQryAttrValues[2] = { sItemID, sTargetItemType };
			ITK_CALL(ITEM_find_items_by_key_attributes(2, sQryAttrNames, sQryAttrValues, &iQueryResults, &taQueryResults));
		}

		if (iQueryResults > 0) {
			tTargetItem = taQueryResults[0];
		} else {
			tag_t tTargetItemType = NULLTAG,
				tTargetRevisionType = NULLTAG,
				tTargetItemCreateInput = NULLTAG,
				tTargetRevisionCreateInput = NULLTAG;

			TCTYPE_find_type(sTargetItemType, sTargetItemType, &tTargetItemType);
			TCTYPE_find_type(sTargetItemRevType, sTargetItemRevType, &tTargetRevisionType);

			ITK_CALL(TCTYPE_construct_create_input(tTargetItemType, &tTargetItemCreateInput));
			if(lUseMFKItemID == true) ITK_CALL(AOM_set_value_string(tTargetItemCreateInput, ITEM_ITEM_ID_PROP, sItemID));
			ITK_CALL(AOM_set_value_string(tTargetItemCreateInput, SR5_ATTR_objectName, sObjectName));
			ITK_CALL(AOM_set_value_string(tTargetItemCreateInput, "sr5Plant", sPlant));

			ITK_CALL(TCTYPE_construct_create_input(tTargetRevisionType, &tTargetRevisionCreateInput));
			ITK_CALL(AOM_set_value_string(tTargetRevisionCreateInput, SR5_ATTR_objectName, sObjectName));
			ITK_CALL(AOM_set_value_tag(tTargetItemCreateInput, "revision", tTargetRevisionCreateInput));

			// Create Object
			TCTYPE_create_object(tTargetItemCreateInput, &tTargetItem);
			ITK_CALL(AOM_save_without_extensions(tTargetItem));
			ITK_CALL(AOM_refresh(tTargetItem, false));
		}

		// Find latest working rev
		int iMRevStatusCount = 0;
		tag_t* taMRevStatus = NULL;
		ITK_CALL(ITEM_ask_latest_rev(tTargetItem, tTargetItemRevision));
		ITK_CALL(WSOM_ask_release_status_list(*tTargetItemRevision, &iMRevStatusCount, &taMRevStatus));
		if (iMRevStatusCount > 0) {
			tag_t tTmptMItemRevision = *tTargetItemRevision;
			ITK_CALL(ITEM_copy_rev(tTmptMItemRevision, NULL, tTargetItemRevision));
			ITK_CALL(ITEM_save_rev(*tTargetItemRevision));
		}
		SAFE_SM_FREE(taMRevStatus);

		// Link M-E Objects
		if (sCustomRelTypeBetweenSourceAndTarget != NULL) {
			tag_t tCustomRelType = NULLTAG;
			findRelationType(sCustomRelTypeBetweenSourceAndTarget, &tCustomRelType);
			if (tCustomRelType != NULLTAG) createRelation(*tTargetItemRevision, tSourceItemRevision, tCustomRelType, "sCustomRelTypeBetweenSourceAndTarget");
		}

		// Init CC
		tag_t tCC = NULLTAG;
		tag_t tSourceStructContext = NULLTAG;
		tag_t tTargetStructContext = NULLTAG;

		int iExistingCCs = 0;
		tag_t* taExistingCCs = NULLTAG;
		ITK_CALL(AOM_ask_value_tags(tSourceItemRevision, sAttrToLinkCCToSourceRev, &iExistingCCs, &taExistingCCs));
		for (int j = 0; j < iExistingCCs; j++) {
			string sTmpName = "";
			sr5ReadAttrValue_STRING(taExistingCCs[j], "WorkspaceObject", "object_name", &sTmpName);
			if (sTmpName.compare(sCCName) == 0) {
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

		if (tCC == NULLTAG) ITK_CALL(COLLABCTX_create_ccobject(COLLABCTX_me_ccobject_type_name_c, sCCName, "", &tCC));
		ITK_CALL(COLLABCTX_create_structure_context(COLLABCTX_product_structure_type_name_c, "EBOM", "", &tSourceStructContext));
		ITK_CALL(COLLABCTX_create_structure_context(COLLABCTX_product_structure_type_name_c, sTargetStructName, "", &tTargetStructContext));

		ITK_CALL(COLLABCTX_add_structure_context(tCC, tSourceStructContext));
		ITK_CALL(COLLABCTX_add_structure_context(tCC, tTargetStructContext));

		tag_t tEBV, tEBVR, tMBV, tMBVR;
		initBomViewandBomViewRevision(tSourceItem, tSourceItemRevision, &tEBV, &tEBVR);
		initBomViewandBomViewRevision(tTargetItem, *tTargetItemRevision, &tMBV, &tMBVR);

		ITK_CALL(COLLABCTX_context_add_content(tSourceStructContext, tEBVR, COLLABCTX_content_rel_any_stype));
		ITK_CALL(COLLABCTX_context_add_content(tTargetStructContext, tMBVR, COLLABCTX_content_rel_any_stype));

		tag_t relTypeMETarget = NULLTAG;
		findRelationType(REL_TYPE_IMAN_METarget, &relTypeMETarget);
		createRelation(tMBV, tEBV, relTypeMETarget, "relTypeMETarget");

		tag_t	tSourceConfigContext, tTargetConfigContext;
		ITK_CALL(COLLABCTX_create_configuration_context(COLLABCTX_configuration_context_type_name_c, "Configuration Context", "", &tSourceConfigContext));
		ITK_CALL(COLLABCTX_create_configuration_context(COLLABCTX_configuration_context_type_name_c, "Configuration Context", "", &tTargetConfigContext));

		tag_t tSourceRuleTag, tTargetRuleTag;
		CFM_find(sSourceRevRule, &tSourceRuleTag);
		CFM_find(sTargetRevRule, &tTargetRuleTag);
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
		ITK_CALL(AOM_refresh(tSourceItemRevision, true));
		ITK_CALL(AOM_refresh(*tTargetItemRevision, true));
		ITK_CALL(AOM_set_value_tags(tSourceItemRevision, sAttrToLinkCCToSourceRev, 1, &tCC));
		//ITK_CALL(AOM_set_value_tags(tMItemRevision, "sr4HasCollaborationContexts", 1, &tCC));
		ITK_CALL(AOM_save_without_extensions(tSourceItemRevision));
		ITK_CALL(AOM_save_without_extensions(*tTargetItemRevision));
		ITK_CALL(AOM_refresh(tSourceItemRevision, false));
		ITK_CALL(AOM_refresh(*tTargetItemRevision, false));
	}

	return ITK_ok;
}

bool check_type(tag_t tObject, const std::string& sType) {
	int retcode = ITK_ok;

	char* sTypeName = NULL;
	bool result = false;

	retcode = WSOM_ask_object_type2(tObject, &sTypeName);
	if (retcode == ITK_ok) {
		result = sType == sTypeName;
	}

	return result;
}

int sr5UnloadInstances(int n, tag_t* tags) {
	for (int i = 0; i < n; i++) {
		logical isLoaded = false;
		POM_is_loaded(tags[i], &isLoaded);
		if (isLoaded)
			POM_unload_instances(1, &(tags[i]));
	}
	return ITK_ok;
}

vector<tag_t> change_item_type(tag_t tItem, const std::vector<std::string>& types) {
	int retcode = ITK_ok;
	tag_t tItemMaster = NULLTAG;
	int nRevisions = 0;
	tag_t* tRevisions = NULL;
	tag_t* tRevisionMaster = NULL;
	bool fail = false;
	bool typeChangeNeeded = false;
	logical isCorrectType = false;

	vector<tag_t> vecUpdatedObjects;

	isCorrectType = check_type(tItem, types[0]);


	retcode = AOM_ask_value_tag(tItem, "item_master_tag", &tItemMaster);

	if (retcode != ITK_ok || tItemMaster == NULLTAG) {
		fail = true;
		std::cerr << "ERROR could not locate ItemMaster" << std::endl;
	}
	else {
		isCorrectType &= check_type(tItemMaster, types[2]);
	}


	retcode = AOM_ask_value_tags(tItem, "revision_list", &nRevisions, &tRevisions);
	if (retcode != ITK_ok || nRevisions == 0) {
		fail = true;
		std::cerr << "ERROR could not locate ItemMaster" << std::endl;
	}
	else {
		tag_t tRevMasteRel = NULLTAG;

		retcode = GRM_find_relation_type("IMAN_master_form", &tRevMasteRel);

		tRevisionMaster = (tag_t*)MEM_alloc(nRevisions * sizeof(tag_t));

		for (int i = 0; i < nRevisions; i++) {
			int nMaster = 0;
			tag_t* tRevMaster = NULL;

			isCorrectType &= check_type(tRevisions[i], types[1]);

			retcode = GRM_list_secondary_objects_only(tRevisions[i], tRevMasteRel, &nMaster, &tRevMaster);

			if (retcode != ITK_ok || nMaster != 1) {
				fail = true;
				std::cerr << "ERROR could not locate ItemRevMaster: error (" << retcode << ") masters(" << nMaster << ")" << std::endl;
				isCorrectType = false;
			}
			else {
				tRevisionMaster[i] = tRevMaster[0];
				isCorrectType &= check_type(tRevisionMaster[i], types[3]);
			}

			SAFE_SM_FREE(tRevMaster);
		}
	}

	if (isCorrectType) {
		std::cout << " Type is already correct";
	}

	if (!fail && isCorrectType == false) {
		tag_t tAttr = NULLTAG;
		tag_t* tRev = NULL;
		int nChanges = 0;
		int nMarkPoint = -1;
		char* sID = NULL;

		std::cout << " Changing Type";

		//POM_tag_to_string(tItem, &sID);
		//if (sID) {
		//	logStream << "Item UID: " << sID;
		//	SAFE_SM_FREE(sID);
		//}
		//POM_tag_to_string(tItemMaster, &sID);
		//if (sID) {
		//	logStream << " - Item Master UID: " << sID;
		//	SAFE_SM_FREE(sID);
		//}
		//for (int i = 0; i < nRevisions; i++) {
		//	POM_tag_to_string(tRevisions[i], &sID);
		//	if (sID) {
		//		logStream << " - Item Rev (" << i << ") UID: " << sID;
		//		SAFE_SM_FREE(sID);
		//	}
		//	POM_tag_to_string(tRevisionMaster[i], &sID);
		//	if (sID) {
		//		logStream << " - ItemRevMaster (" << i << "): " << sID;
		//		SAFE_SM_FREE(sID);
		//	}
		//}


		ITK_CALL(POM_place_markpoint(&nMarkPoint));
		ITK_CALL(POM_attr_id_of_attr("object_type", "WorkspaceObject", &tAttr));

		ITK_CALL(sr5UnloadInstances(1, &tItem));
		ITK_CALL(sr5UnloadInstances(1, &tItemMaster));
		ITK_CALL(sr5UnloadInstances(nRevisions, tRevisions));
		ITK_CALL(sr5UnloadInstances(nRevisions, tRevisionMaster));

		ITK_CALL(POM_load_instances_any_class(1, &tItem, POM_modify_lock));
		ITK_CALL(POM_load_instances_any_class(1, &tItemMaster, POM_modify_lock));
		ITK_CALL(POM_load_instances_any_class(nRevisions, tRevisions, POM_modify_lock));
		ITK_CALL(POM_load_instances_any_class(nRevisions, tRevisionMaster, POM_modify_lock));

		ITK_CALL(POM_set_attr_string(1, &tItem, tAttr, types[0].c_str()));
		ITK_CALL(POM_set_attr_string(1, &tItemMaster, tAttr, types[2].c_str()));
		ITK_CALL(POM_set_attr_string(nRevisions, tRevisions, tAttr, types[1].c_str()));
		ITK_CALL(POM_set_attr_string(nRevisions, tRevisionMaster, tAttr, types[3].c_str()));

		ITK_CALL(POM_save_instances(1, &tItem, 1));
		ITK_CALL(POM_save_instances(1, &tItemMaster, 1));
		ITK_CALL(POM_save_instances(nRevisions, tRevisions, 1));
		ITK_CALL(POM_save_instances(nRevisions, tRevisionMaster, 1));

		ITK_CALL(POM_load_instances_any_class(1, &tItem, POM_no_lock));
		ITK_CALL(POM_load_instances_any_class(1, &tItemMaster, POM_no_lock));
		ITK_CALL(POM_load_instances_any_class(nRevisions, tRevisions, POM_no_lock));
		ITK_CALL(POM_load_instances_any_class(nRevisions, tRevisionMaster, POM_no_lock));

		ITK_CALL(POM_refresh_instances(1, &tItem, NULLTAG, POM_no_lock));
		ITK_CALL(POM_refresh_instances(1, &tItemMaster, NULLTAG, POM_no_lock));
		ITK_CALL(POM_refresh_instances(nRevisions, tRevisions, NULLTAG, POM_no_lock));
		ITK_CALL(POM_refresh_instances(nRevisions, tRevisionMaster, NULLTAG, POM_no_lock));

		vecUpdatedObjects.push_back(tItem);
		vecUpdatedObjects.push_back(tItemMaster);
		for (int i = 0; i < nRevisions; i++) {
			vecUpdatedObjects.push_back(tRevisions[i]);
			vecUpdatedObjects.push_back(tRevisionMaster[i]);
		}

		if (nMarkPoint != -1)
			if (retcode != ITK_ok) {
				logical dummy;
				ITK_CALL(POM_roll_to_markpoint(nMarkPoint, &dummy));
			}
			else {
				ITK_CALL(POM_forget_markpoint(nMarkPoint));
			}
	}

	SAFE_SM_FREE(tRevisions);
	SAFE_SM_FREE(tRevisionMaster);

	return vecUpdatedObjects;
}

int renameDerivedObjectsDuringItemIdChange(tag_t tObject, string sOldID, string sNewID, string sOldRevID, string sNewRevID, const char *sCheckObjectType, logical lObjectTypeToBeChecked) {
	if (tObject != NULLTAG && sOldID.empty() == false && sNewID.empty() == false) {
		logical lObjectTypeCheckStatus = false;

		char* sType = NULL;
		ITK_CALL(WSOM_ask_object_type2(tObject, &sType));

		if (lObjectTypeToBeChecked) {
			lObjectTypeCheckStatus = sr5IsDerivedFromClass(tObject, sCheckObjectType);
		} else {
			lObjectTypeCheckStatus = true;
		}

		if (lObjectTypeCheckStatus == true) 
		{
		/*	char* sObjectName = NULL;
			ITK_CALL(WSOM_ask_name2(tObject, &sObjectName));
			std::string strNewObjectName = std::regex_replace(sObjectName, std::regex(sOldID), sNewID);*/

			//std::string delimiter = "/";

			//std::string RevSubString = strNewObjectName;
			//size_t pos = 0;
			//std::string token;
			//for (int i=0;i<2;i++){
			//	token = RevSubString.substr(0, pos);
			//	std::cout << token << std::endl;
			//	RevSubString.erase(0, pos + delimiter.length());
			//}

			std::string NewName = sNewID + "/" + sNewRevID;


			//std::string strNewObjectName2 = std::regex_replace(strNewObjectName, std::regex(sOldRevID), sNewRevID);
			/*if (tc_strcmp(sType, "catia_model_attributes") == 0) 
			{
				
			}*/
			ITK_CALL(AOM_refresh(tObject, true));
			ITK_CALL(WSOM_set_name2(tObject, NewName.c_str()));
			ITK_CALL(AOM_save_without_extensions(tObject));
			ITK_CALL(AOM_refresh(tObject, false));

			//SAFE_SM_FREE(sObjectName);
		}
	}

	return ITK_ok;
}

int sr5UpdateItemAndRevID(tag_t tNewItem, tag_t tNewRev, string sOldID, string sNewID, string sOldRevID, string sNewRevID) {
	int iRetVal = ITK_ok;

	try {
		// Update Item ID
		ITK_CALL(AOM_refresh(tNewItem, true));
		ITK_CALL(ITEM_set_id(tNewItem, sNewID.c_str()));
		ITK_CALL(AOM_save_without_extensions(tNewItem));
		ITK_CALL(AOM_refresh(tNewItem, false));

		//Update RevID
		ITK_CALL(AOM_refresh(tNewRev, true));
		ITK_CALL(ITEM_set_rev_id(tNewRev, sNewRevID.c_str()));
		ITK_CALL(AOM_save_without_extensions(tNewRev));
		ITK_CALL(AOM_refresh(tNewRev, false));
		




		// Rename Master Form
		tag_t tItemMaster = NULLTAG;
		ITK_CALL(AOM_ask_value_tag(tNewItem, "item_master_tag", &tItemMaster));
		char* sType = NULL;
		ITK_CALL(WSOM_ask_object_type2(tItemMaster, &sType));
		renameDerivedObjectsDuringItemIdChange(tItemMaster, sOldID, sNewID, sOldRevID, sNewRevID, NULL, false);

		// Rename BV
		int iBVCount = 0;
		tag_t* taBVs = NULL;
		ITK_CALL(ITEM_list_bom_views(tNewItem, &iBVCount, &taBVs));
		for (int i = 0; i < iBVCount; i++) {

			char* sType = NULL;
			ITK_CALL(WSOM_ask_object_type2(taBVs[i], &sType));
			renameDerivedObjectsDuringItemIdChange(taBVs[i], sOldID, sNewID, sOldRevID, sNewRevID, NULL, false);
		}
		SAFE_SM_FREE(taBVs);

		int iRevCount = 0;
		tag_t* taRevs = NULL;
		ITK_CALL(ITEM_list_all_revs(tNewItem, &iRevCount, &taRevs));
		for (int i = 0; i < iRevCount; i++) {
			// Rename Revision Master Forms
			vector<tag_t> vecRevMasterForms;
			sr5AskSecondaryObjects(taRevs[i], "IMAN_master_form", NULL, &vecRevMasterForms);
			for (int j = 0; j < vecRevMasterForms.size(); j++) {
				char* sType = NULL;
				ITK_CALL(WSOM_ask_object_type2(vecRevMasterForms[j], &sType));
				renameDerivedObjectsDuringItemIdChange(vecRevMasterForms.at(j), sOldID, sNewID, sOldRevID, sNewRevID, NULL, false);
			}

			// Rename BVRs
			int iBVRCount = 0;
			tag_t* taBVRs = NULL;
			ITK_CALL(ITEM_rev_list_bom_view_revs(taRevs[i], &iBVRCount, &taBVRs));
			for (int j = 0; j < iBVRCount; j++) {
				char* sType = NULL;
				ITK_CALL(WSOM_ask_object_type2(taBVRs[i], &sType));
				renameDerivedObjectsDuringItemIdChange(taBVRs[j], sOldID, sNewID, sOldRevID, sNewRevID, NULL, false);
			}
			SAFE_SM_FREE(taBVRs);

			// Rename Dataset and catia model attributes
			int iSecCount = 0;
			tag_t* taSecObjects = NULL;
			//ITK_CALL(GRM_list_secondary_objects_only(taRevs[i], NULLTAG, &iSecCount, &taSecObjects));
		/*	for (int j = 0; j < iSecCount; j++) {
				char* sType = NULL;
				ITK_CALL(WSOM_ask_object_type2(taSecObjects[j], &sType));
				if (tc_strcmp(sType, "Mat1MaterialRevision")!=0){
					renameDerivedObjectsDuringItemIdChange(taSecObjects[j], sOldID, sNewID, "Dataset", true);
				}
				if (tc_strcmp(sType, "catia_model_attributes") == 0) {
					renameDerivedObjectsDuringItemIdChange(taSecObjects[j], sOldID, sNewID, "Form", true);
				}
			}*/

			tag_t relTypeIMAN_spec = NULLTAG;
			tag_t relTypeIMAN_Ren = NULLTAG;
			tag_t relTypecatia_cache_link = NULLTAG;
			GRM_find_relation_type(REL_TYPE_IMAN_specification, &relTypeIMAN_spec);
			GRM_find_relation_type("IMAN_Rendering", &relTypeIMAN_Ren);
			GRM_find_relation_type("catia_cache_link", &relTypecatia_cache_link);
			ITK_CALL(GRM_list_secondary_objects_only(taRevs[i], relTypeIMAN_spec, &iSecCount, &taSecObjects));
			for (int j = 0; j < iSecCount; j++) {
				renameDerivedObjectsDuringItemIdChange(taSecObjects[j], sOldID, sNewID, sOldRevID, sNewRevID, "Dataset", true);
				renameDerivedObjectsDuringItemIdChange(taSecObjects[j], sOldID, sNewID, sOldRevID, sNewRevID, "Form", true);
			}
			ITK_CALL(GRM_list_secondary_objects_only(taRevs[i], relTypeIMAN_Ren, &iSecCount, &taSecObjects));
			for (int j = 0; j < iSecCount; j++) {
				renameDerivedObjectsDuringItemIdChange(taSecObjects[j], sOldID, sNewID, sOldRevID, sNewRevID, "Dataset", true);
			}
			ITK_CALL(GRM_list_secondary_objects_only(taRevs[i], relTypecatia_cache_link, &iSecCount, &taSecObjects));
			for (int j = 0; j < iSecCount; j++) {
				renameDerivedObjectsDuringItemIdChange(taSecObjects[j], sOldID, sNewID, sOldRevID, sNewRevID, "Dataset", true);
			}
			





			SAFE_SM_FREE(taSecObjects);
		}

		SAFE_SM_FREE(taRevs);

	} catch (...) {}

	return iRetVal;
}

int recursiveInitBOMLinesWithUnitEffectivity(tag_t tParentBVR, tag_t tTopLevelItem, tag_t tCurrentBOMLine, logical lIsTopLevel) {
	if (lIsTopLevel == false) {
		tag_t tTargetOcc = NULLTAG;
		tag_t tTargetEff = NULLTAG;

		int bl_occurrence = 0;
		ITK_CALL(BOM_line_look_up_attribute("bl_occurrence", &bl_occurrence));
		ITK_CALL(BOM_line_ask_attribute_tag(tCurrentBOMLine, bl_occurrence, &tTargetOcc));

		int iEffCount = 0;
		tag_t* taEffObjects = NULL;
		ITK_CALL(PS_occ_eff_ask_effs(tParentBVR, tTargetOcc, &iEffCount, &taEffObjects));
		SAFE_SM_FREE(taEffObjects);

		if (iEffCount == 0) {
			ITK_CALL(AOM_refresh(tTargetOcc, true));

			ITK_CALL(PS_occ_eff_create(tParentBVR, tTargetOcc, &tTargetEff));
			ITK_CALL(AOM_save_without_extensions(tTargetEff));
			ITK_CALL(AOM_save_without_extensions(tTargetOcc));
			ITK_CALL(AOM_save_without_extensions(tParentBVR));

			//ITK_CALL(PS_occ_eff_set_id(tMBVR, tTargetOcc, tTargetEff, "Default_Unit_Effectivity"));
			ITK_CALL(PS_occ_eff_set_enditem(tParentBVR, tTargetOcc, tTargetEff, tTopLevelItem));
			ITK_CALL(PS_occ_eff_set_unit_range(tParentBVR, tTargetOcc, tTargetEff, "1-UP", true));

			ITK_CALL(AOM_save_without_extensions(tTargetEff));
			ITK_CALL(AOM_refresh(tTargetEff, false));
			//ITK_CALL(AOM_unlock(tTargetEff));
			ITK_CALL(AOM_unload(tTargetEff));

			ITK_CALL(AOM_save_without_extensions(tTargetOcc));
			ITK_CALL(AOM_refresh(tTargetOcc, false));
			//ITK_CALL(AOM_unlock(tTargetOcc));
			ITK_CALL(AOM_unload(tTargetOcc));
		}
	}

	int iChildCount = 0;
	tag_t* taChildLines = NULL;
	ITK_CALL(BOM_line_ask_all_child_lines(tCurrentBOMLine, &iChildCount, &taChildLines));
	if (iChildCount > 0) {
		tag_t tTmpRev = NULLTAG;
		tag_t tTmpItem = NULLTAG;

		ITK_CALL(AOM_ask_value_tag(tCurrentBOMLine, "bl_revision", &tTmpRev));
		ITK_CALL(AOM_ask_value_tag(tCurrentBOMLine, "bl_item", &tTmpItem));

		// Only initialize Unit Effectivities in case of parent MBOM-Object
		if (sr5IsValidMfgAssy(tTmpItem) == true) {
			tag_t tTmpBV = NULLTAG;
			tag_t tTmpBVR = NULLTAG;
			initBomViewandBomViewRevision(tTmpItem, tTmpRev, &tTmpBV, &tTmpBVR);

			ITK_CALL(AOM_refresh(tTmpBVR, true));

			for (int i = 0; i < iChildCount; i++) {
				recursiveInitBOMLinesWithUnitEffectivity(tTmpBVR, tTopLevelItem, taChildLines[i], false);
			}

			ITK_CALL(AOM_refresh(tTmpBVR, false));
		}
	}
	SAFE_SM_FREE(taChildLines);

	return ITK_ok;
}

int sr5PrepareObjForModify(tag_t tObject, const char *sClass)
{
	tag_t	tClassIdTag = NULLTAG;
	int		iInitialInstanceState = POM_inst_is_not_loaded;
	tag_t* taObjects = (tag_t*)MEM_alloc(1 * sizeof(tag_t));

	taObjects[0] = tObject;

	// Get Class ID
	ITK_CALL(POM_class_id_of_class(sClass, &tClassIdTag));

	if (tClassIdTag != NULLTAG) {
		// Ask state
		ITK_CALL(POM_ask_instance_state(tObject, &iInitialInstanceState));
		if (iInitialInstanceState != POM_inst_is_loaded_for_modify)
		{
			logical lIsLoaded = false;

			// Is already loaded ?
			ITK_CALL(POM_is_loaded(tObject, &lIsLoaded));

			if (lIsLoaded == true)
			{
				// Unload
				ITK_CALL(POM_unload_instances(1, taObjects));
			}

			// Load instance
			ITK_CALL(POM_load_instances(1, taObjects, tClassIdTag, POM_modify_lock));
		}
	}

	// Free
	if (taObjects != NULL) MEM_free(taObjects);

	return iInitialInstanceState;
}

int addObjectToWorkflowAttachments(tag_t tRootTask, vector<tag_t>vecExistingWFTargets, tag_t tObject, int iAttachType) {
	// Exit if attach type invalid
	if (iAttachType != EPM_target_attachment && iAttachType != EPM_reference_attachment) return -1;

	// Exit if already part of the worfklows
	for (int i = 0; i < vecExistingWFTargets.size(); i++) {
		if (vecExistingWFTargets.at(i) == tObject) return -1;
	}

	int iAttTypes[1] = { iAttachType };
	tag_t taAttObj[1] = { tObject };
	ITK_CALL(EPM_add_attachments(tRootTask, 1, taAttObj, iAttTypes));
	vecExistingWFTargets.push_back(tObject);

	return ITK_ok;
}



double get_sublevel_weight(tag_t topline, char* revRule)
{

	int nChildren = NULL;
	tag_t* children = NULL;

	//ask if children exist in general (irrespective of revrule)
	ITK_CALL(BOM_line_ask_child_lines(topline, &nChildren, &children));
	double weightChild = NULL;
	tag_t rule = NULLTAG;
	ITK_CALL(CFM_find(revRule, &rule));

	double cumulativeWeight = 0.0;
	if (nChildren > 0)
	{
		for (int j = 0; j < nChildren; j++)
		{


			//get Quantity and parse to double

			char* QTY = NULL;
			ITK_CALL(AOM_ask_value_string(children[j], "bl_quantity", &QTY));


			double dblQTY = strtod(QTY, NULL);
			if (dblQTY == 0.0) { dblQTY = 1.0; }
			SAFE_SM_FREE(QTY);

			tag_t tRev = NULLTAG;


			//Check if BOMLine has configured revision
			ITK_CALL(AOM_ask_value_tag(children[j], "bl_revision", &tRev));

			if (tRev != NULLTAG && sr5IsDerivedFromClass(tRev, "SR5GenEngObjRevision") == true)
			{


				//check if Adjusted weight has a value. If yes, take this value with priority. If not, go through the structure.
				double adjWeight = 0.0;
				ITK_CALL(AOM_ask_value_double(tRev, "sr5AdjustedWeight", &adjWeight));
				if (adjWeight> 0.0)
				{
					cumulativeWeight += dblQTY * adjWeight;
				}
				else 
				{
					//get Material Mass of Child Revision
					ITK_CALL(AOM_ask_value_double(tRev, "mat1CumulativeMaterialsMass", &weightChild));
					cumulativeWeight += dblQTY * weightChild / 1000;

					//std::string sObjectType = "";
					//sr5ReadAttrValue_STRING(tRev, "WorkspaceObject", "object_type", &sObjectType);
					//std::string sObjectName = "";
					//sr5ReadAttrValue_STRING(tRev, "WorkspaceObject", "object_name", &sObjectName);
					//Ask if Child has SubChildren. if yes, iteratively start function again

					vector<tag_t> vecSecondary;
					sr5AskSecondaryObjects(tRev, TC_specification_rtype, "CATProduct", &vecSecondary);

					if (vecSecondary.size() != 0) {

						tag_t* viewChildren = NULL;
						int nChildren = NULL;
						ITK_CALL(AOM_ask_value_tags(tRev, "view", &nChildren, &viewChildren));


						if (nChildren > 0)
						{
							cumulativeWeight += dblQTY * get_sublevel_weight(children[j], revRule);
						}
						SAFE_SM_FREE(viewChildren);
					}
				}
			}
		}
	}
	SAFE_SM_FREE(children);

	return cumulativeWeight;

}

int sr5AttachUnreleasedAssemblyComponents(tag_t tBOMLine, vector<tag_t>*vecNewWFRevisions) {
	int iRet = ITK_ok;
	int iChildCount = 0;
	tag_t* taChildLines = NULL;

	ITK_CALL(BOM_line_ask_child_lines(tBOMLine, &iChildCount, &taChildLines));
	for (int i = 0; i < iChildCount; i++) {
		tag_t tBomLineRevision = NULLTAG;
		logical lHasStatus = false;
		logical lIsReserved = false;
		char* sBomLineRevisionObjectType = NULL;

		ITK_CALL(AOM_ask_value_string(taChildLines[i], "bl_rev_object_type", &sBomLineRevisionObjectType));

		if (tc_strcmp(sBomLineRevisionObjectType, SR5_TYPE_SR5MfgEndItemRevision) == 0 || tc_strcmp(sBomLineRevisionObjectType, SR5_TYPE_SR5MfgMajorAssyRevision) == 0 || tc_strcmp(sBomLineRevisionObjectType, SR5_TYPE_SR5MfgInstallKitRevision) == 0) {
			ITK_CALL(AOM_ask_value_tag(taChildLines[i], "bl_revision", &tBomLineRevision));
			sr5HasStatus(tBomLineRevision, NULL, &lHasStatus);

			// Is checked-out
			ITK_CALL(RES_is_checked_out(tBomLineRevision, &lIsReserved));
			if (lIsReserved == true) {
				try {
					// try to checkin ...
					ITK_CALL(RES_checkin(tBomLineRevision));
					ITK_CALL(RES_is_checked_out(tBomLineRevision, &lIsReserved));
				} catch (...) {}
			}

			// Only attach to WF if no status or not checked-out
			if (lHasStatus == false && lIsReserved == false) {
				(*vecNewWFRevisions).push_back(tBomLineRevision);
				sr5AttachUnreleasedAssemblyComponents(taChildLines[i], vecNewWFRevisions);
			}
		}

		SAFE_SM_FREE(sBomLineRevisionObjectType);
	}

	SAFE_SM_FREE(taChildLines);

	return iRet;
}


void CalculateString(tag_t tArticle, int Number, string* myString)
// Calculate how the lines shall look like. Depending on the number of revisions, start function getChangeAttrString with a different revision.
{
	tag_t items_tag = NULLTAG;
	char* item_rev = NULL;
	int num_revs = 0;
	tag_t* rev_list = NULL;

	ITK_CALL(ITEM_ask_item_of_rev(tArticle, &items_tag));
	ITK_CALL(AOM_ask_value_string(tArticle, "item_revision_id", &item_rev));
	ITK_CALL(ITEM_list_all_revs(items_tag, &num_revs, &rev_list));

	std::vector<tag_t> prevValidItemRevisions;

	int numInternalRevs = 0;
	for (int z = 0;z < num_revs;z++)
	{
		char* tempItemRev = NULL;
		int iRevStatusCount = 0;
		tag_t* taRevStatus = NULLTAG;

		char** asRespectedStatus{ nullptr };
		int iCountRespectedStatus{ 0 };
		ITK_CALL(PREF_ask_char_values("SR5_external_revision_respect_status", &iCountRespectedStatus, &asRespectedStatus));
		logical lHasRespectedStatus{ false };
		
		
		for (int ii = 0; ii < iCountRespectedStatus; ii++)
		{
			sr5HasStatus(rev_list[z], asRespectedStatus[ii], &lHasRespectedStatus);
			if (lHasRespectedStatus)
			{
				prevValidItemRevisions.push_back(rev_list[z]);
				break;
			}
		}
		SAFE_SM_FREE(asRespectedStatus);

		//ITK_CALL(AOM_ask_value_string(rev_list[z], "item_revision_id", &tempItemRev));
		//if (tc_strcmp(tempItemRev, item_rev) == 0)
		//{
		//	numInternalRevs = z;
		//	prevValidItemRevisions.push_back(rev_list[z]);
		//	break;
		//}
	}

	int numExternalRevs = prevValidItemRevisions.size();


	if (numExternalRevs == 1 || numExternalRevs < Number+1)
	{
		*myString = "";
	}
	else if ((numExternalRevs >= Number+1 && numExternalRevs != Number+8 && numExternalRevs != Number+16 && numExternalRevs != Number+24 ) || Number==1)
	{
		if (numExternalRevs <= Number+8)
		{
			*myString = getChangeAttrString(prevValidItemRevisions.at(Number));
		}
		else if (numExternalRevs > Number+8 && numExternalRevs <= Number+16)
		{
			*myString = getChangeAttrString(prevValidItemRevisions.at(Number+8));
		}
		else if (numExternalRevs > Number+16 && numExternalRevs <= Number+24)
		{
			*myString = getChangeAttrString(prevValidItemRevisions.at(Number+16));
		}
		else if (numExternalRevs > Number+24 && numExternalRevs <= Number+32)
		{
			*myString = getChangeAttrString(prevValidItemRevisions.at(Number+24));
		}
	}
	else
	{
		*myString = "";
	}

}



string getChangeAttrString(tag_t revTag) {

	char* revID = NULL;
	char* ECNID = "";
	tag_t owningUser = NULLTAG;
	char* dateEngRelease = "";
	char* user_id = NULL;
	tag_t tMasterFormType = NULLTAG;
	std::vector<tag_t> vecChangeNoticeRevision;
	tag_t* tMasterForms = NULL;
	int nMasterForms = 0;

	ITK_CALL(AOM_ask_value_string(revTag, "sr5ExternalRevision", &revID));
	sr5AskPrimaryObjects(revTag, "CMHasSolutionItem", "ChangeNoticeRevision", &vecChangeNoticeRevision);
	if (vecChangeNoticeRevision.size() != 0) 
	{
		ITK_CALL(AOM_ask_value_string(vecChangeNoticeRevision[0], "awp0Item_item_id", &ECNID));
	}

	ITK_CALL(AOM_ask_value_string(revTag, "sr5CPDateEngineeringRelease", &dateEngRelease));
	string ss = "";
	ITK_CALL(AOM_ask_value_tag(revTag, "owning_user", &owningUser));
	ITK_CALL(AOM_ask_value_string(owningUser, "user_id", &user_id));

	string subdate = string(dateEngRelease).substr(0, 10);

		ss.append(revID);
		ss.append("|");
		ss.append(ECNID);
		ss.append("|");
		ss.append(subdate.c_str());
		ss.append("|");
		ss.append(user_id);
	return ss;
}

extern DLLAPI int sr5CalculateAndSetWeight(const char* uid, int* iErrorCode, char** sErrorText, double* dWeight) {

	// Logic for calculating and updating weight goes here.
	iErrorCode = 0;
	*sErrorText = "No error.";
	*dWeight = 0.0;
	tag_t targetTag = NULLTAG;
	ITK__convert_uid_to_tag(uid, &targetTag);

	if (targetTag != NULLTAG) {
		initiateWeightCalculation(targetTag, dWeight);
	}

	
	return 0;
}

void initiateWeightCalculation(tag_t targetTag, double* dWeight) {

	if (sr5IsDerivedFromClass(targetTag, "SR5GenEngObjRevision") == true) 
	{
		double massValueInGrams = NULL;

		ITK_CALL(AOM_ask_value_double(targetTag, "mat1CumulativeMaterialsMass", &massValueInGrams));
		double massValueInKG = massValueInGrams / 1000.0;

		//check if topline has Children
		tag_t* viewChildren = NULL;
		int nChildren = NULL;
		ITK_CALL(AOM_ask_value_tags(targetTag, "view", &nChildren, &viewChildren));

		SAFE_SM_FREE(viewChildren);
		vector<tag_t> vecSecondary;
		sr5AskSecondaryObjects(targetTag, TC_specification_rtype, "CATProduct", &vecSecondary);

		if (vecSecondary.size() != 0) {

			if (nChildren > 0)
			{
				//create BOM Window for whole structure
				tag_t itemTag = NULLTAG;
				sr5ReadAttrValue_TAG(targetTag, SR5_TYPE_ItemRev, "items_tag", &itemTag);
				tag_t window = NULL;
				tag_t rule = NULLTAG;
				tag_t topline = NULLTAG;
				ITK_CALL(BOM_create_window(&window));
				ITK_CALL(BOM_set_window_top_line(window, itemTag, targetTag, NULLTAG, &topline));
				ITK_CALL(CFM_find(SR5_REVRULE_LatestWorking, &rule));
				ITK_CALL(BOM_set_window_config_rule(window, rule));
				ITK_CALL(BOM_window_hide_unconfigured(window));

				//get sub Material weights
				massValueInKG += get_sublevel_weight(topline, SR5_REVRULE_LatestWorking);
			}
		}
		*dWeight = massValueInKG;

		double adjTotalWeight = 0.0;
		ITK_CALL(AOM_ask_value_double(targetTag, "sr5AdjustedWeight", &adjTotalWeight));
		double adjCalcWeight = 0.0;
		ITK_CALL(AOM_ask_value_double(targetTag, "sr5CalculatedWeight", &adjCalcWeight));


		ITK_CALL(AOM_refresh(targetTag, TRUE));
		ITK_CALL(AOM_set_value_double(targetTag, "sr5CalculatedWeight", *dWeight));
		if (adjTotalWeight==adjCalcWeight)
		{
			ITK_CALL(AOM_set_value_double(targetTag, "sr5AdjustedWeight", *dWeight));
		}
		ITK_CALL(AOM_save_with_extensions(targetTag));
		ITK_CALL(AOM_refresh(targetTag, FALSE));
		ITK_CALL(AOM_unlock(targetTag));

		SAFE_SM_FREE(viewChildren);
	}
}

/**
@brief Recursive traversal of the EBOM to identify ENG-Parts with missing MFG-representations and initialize and link the MFG-Parts accordingly

@param tag_t tCurrentBOMLine
@param tag_t const char* sPlant

@return Error code
*/
int sr5RecursiveInitMPartForEPart(tag_t tCurrentBOMLine, const char* sPlant) {
	if (tCurrentBOMLine != NULLTAG && sPlant != NULL && tc_strcmp(sPlant, "") != 0) {

		char	*sTmpSourceItemType	= NULL,
				*sTmpSourceItemID	= NULL,
				*sTmpSourceItemName	= NULL;
		tag_t	tEItemRev			= NULLTAG;

		ITK_CALL(AOM_ask_value_tag(tCurrentBOMLine, "bl_revision", &tEItemRev));
		ITK_CALL(AOM_ask_value_string(tCurrentBOMLine, "bl_item_object_type", &sTmpSourceItemType));
		ITK_CALL(AOM_ask_value_string(tCurrentBOMLine, "bl_item_item_id", &sTmpSourceItemID));
		ITK_CALL(AOM_ask_value_string(tCurrentBOMLine, "bl_item_object_name", &sTmpSourceItemName));

		if (tEItemRev != NULLTAG && tc_strcmp(sTmpSourceItemType, SR5_TYPE_SR5EngArticle) == 0) {
			vector<tag_t> vecMfgObjects;
			tag_t tMItemRev = NULLTAG;

			// TODO: Check for existing instances which are not related yet
			sr5AskPrimaryObjects(tEItemRev, REL_TYPE_TC_Is_Represented_By_rtype, SR5_TYPE_SR5MfgObjectRevision, &vecMfgObjects);
			for (int i = 0; i < vecMfgObjects.size(); i++) {
				char* sTmpPlant = NULL;

				ITK_CALL(AOM_ask_value_string(vecMfgObjects.at(i), "sr5Plant", &sTmpPlant));
				if (tc_strcmp(sPlant, sTmpPlant) == 0) {
					tMItemRev = vecMfgObjects.at(i);
				}

				SAFE_SM_FREE(sTmpPlant);

				if (tMItemRev != NULLTAG) break;
			}

			if (tMItemRev == NULLTAG) {
				tag_t tMItem = NULLTAG;

				{
					int iQueryResults = 0;
					tag_t *taQueryResults = NULL;
					
					const char
						* sQryAttrNames[3] = { ITEM_ITEM_ID_PROP, SR5_ATTR_objectType, "sr5Plant"},
						* sQryAttrValues[3] = { sTmpSourceItemID, SR5_TYPE_SR5MfgObject, sPlant };
					ITK_CALL(ITEM_find_items_by_key_attributes(3, sQryAttrNames, sQryAttrValues, &iQueryResults, &taQueryResults));

					if (iQueryResults > 0) tMItem = taQueryResults[0];
					SAFE_SM_FREE(taQueryResults);
				}

				if (tMItem == NULLTAG) {
					tag_t tTmpSourceItem = NULLTAG;
					tag_t tTmpSourceUOM = NULLTAG;

					ITK_CALL(AOM_ask_value_tag(tCurrentBOMLine, "bl_item", &tTmpSourceItem));
					ITK_CALL(ITEM_ask_unit_of_measure(tTmpSourceItem, &tTmpSourceUOM));

					createMPart(SR5_TYPE_SR5MfgObject, SR5_TYPE_SR5MfgObjectRevision, sTmpSourceItemID, sPlant, sTmpSourceItemName, tTmpSourceUOM, &tMItem);
				}

				if (tMItem != NULLTAG) {
					vector<tag_t> vecJTs;
					logical lMItemRevHasStatus = false;

					sr5AskSecondaryObjects(tEItemRev, "IMAN_Rendering", "DirectModel", &vecJTs);
					ITK_CALL(ITEM_ask_latest_rev(tMItem, &tMItemRev));

					sr5HasStatus(tMItemRev, "", &lMItemRevHasStatus);
					if (lMItemRevHasStatus == true) {
						tag_t tTmpNewRev = NULLTAG;
						tag_t tMRevOwner = NULLTAG;
						tag_t tMRevGroup = NULLTAG;

						ITK_CALL(AOM_ask_owner(tMItemRev, &tMRevOwner));
						ITK_CALL(AOM_ask_group(tMItemRev, &tMRevGroup));

						ITK_CALL(ITEM_copy_rev(tMItemRev, NULL, &tTmpNewRev));
						if (tTmpNewRev != NULLTAG) tMItemRev = tTmpNewRev;

						if (sr5HasPrivilegeChangeOwner(tMItemRev) == ITK_ok) {
							ITK_CALL(AOM_refresh(tMItemRev, true));
							ITK_CALL(POM_set_owners(1, &tMItemRev, tMRevOwner, tMRevGroup));
							ITK_CALL(AOM_save_without_extensions(tMItemRev));
							ITK_CALL(AOM_refresh(tMItemRev, false));
						}
					}

					createRelation(tMItemRev, tEItemRev, REL_TYPE_TC_Is_Represented_By_rtype, "");
					sr5CleanupRelationsToLatestRevOnly(tMItemRev, tEItemRev, REL_TYPE_TC_Is_Represented_By_rtype);

					if(vecJTs.size() > 0) createRelation(tMItemRev, vecJTs.at(0), "IMAN_Rendering", "");

					//createRelation(tMItemRev, tEItemRev, REL_TYPE_TC_Primary_Design_Representation_rtype, "");
				}
			}
		}

		int iChildCount = 0;
		tag_t* taChildLines = NULL;
		ITK_CALL(BOM_line_ask_all_child_lines(tCurrentBOMLine, &iChildCount, &taChildLines));

		for (int i = 0; i < iChildCount; i++) {
			sr5RecursiveInitMPartForEPart(taChildLines[i], sPlant);
		}

		SAFE_SM_FREE(taChildLines);
	}

	return ITK_ok;
}

/**
 * This functions increments an alphabetical revision and skips chars to exclude if provided.
 * e.g., AA - BB, AZ - BA, ...
 * Parameters are passed by reference (We do not need the parameters to be nullptr).
 *
 * @param strRevision[out] The current revision
 * @param strExcludeChars[in] Characters to exclude (optional)
 * @return - void
 */
void sr5IncrementAlphabeticalRevision(std::string& strRevision, const std::string& strExcludeChars = "")
{

	// Check if it is the initial revision "-" and set to A explicitly
	if (strRevision == "-")
	{
		strRevision = "A";
		return;
	}

	// Convert alphabetical revision to number
	int iNumericalRevision{ 0 };
	for (size_t i = 0; i < strRevision.size(); i++)
	{
		iNumericalRevision *= 26;
		iNumericalRevision += strRevision[i] - 'A' + 1;
	}

	// Increase to next revision
	std::string strAlphabeticalRevision{ "" };
	while (iNumericalRevision >= 0)
	{
		int iNumCharAscii{ 0 };
		iNumCharAscii = (iNumericalRevision % 26) + 65;
		strAlphabeticalRevision.insert(0, 1, static_cast<char>(iNumCharAscii));
		iNumericalRevision = (iNumericalRevision / 26) - 1;
	}

	// Skip excluded chars if provided
	if (strExcludeChars != "")
	{
		for (size_t j = 0; j < strAlphabeticalRevision.size(); j++)
		{
			for (char skip : strExcludeChars)
			{
				if (strAlphabeticalRevision[j] == skip)
					strAlphabeticalRevision[j] += 1;
			}
		}
	}

	// Set revision to next calculated
	strRevision = strAlphabeticalRevision;

	return;
}

/**
 * This function sets the value of the provided currentDateTime parameter
 * to the current local system date and time.
 * 
 * @param {date_t} currentDateTime
 * @returns void
 */
void sr5GetCurrentDateTime(date_t* currentDateTime)
{
	time_t now{ NULL };
	struct tm nowLocal { 0, 0, 0, 0, 0, 0, 0, 0, 0 };
	time(&now);
	nowLocal = *localtime(&now);
	*currentDateTime = NULLDATE;
	currentDateTime->year = (short)(nowLocal.tm_year + 1900);
	currentDateTime->month = (::byte)nowLocal.tm_mon;
	currentDateTime->day = (::byte)nowLocal.tm_mday;
	currentDateTime->hour = (::byte)nowLocal.tm_hour;
	currentDateTime->minute = (::byte)nowLocal.tm_min;
	currentDateTime->second = (::byte)nowLocal.tm_sec;
}

/**
 * This function compares two dates.
 *
 * @param {date_t} dateOne
 * @param {date_t} dateTwo
 * @returns int - 1 when dateOne is greater than dateTwo, -1 when dateOne is smaller than dateTwo, 0 if they are equal
 */
int sr5CompareDates(date_t* dateOne, date_t* dateTwo)
{
	if (dateOne->year != dateTwo->year) return dateOne->year > dateTwo->year ? 1 : -1;
	if (dateOne->month != dateTwo->month) return dateOne->month > dateTwo->month ? 1 : -1;
	if (dateOne->day != dateTwo->day) return dateOne->day > dateTwo->day ? 1 : -1;
	if (dateOne->hour != dateTwo->hour) return dateOne->hour > dateTwo->hour ? 1 : -1;
	if (dateOne->minute != dateTwo->minute) return dateOne->minute > dateTwo->minute ? 1 : -1;
	if (dateOne->second != dateTwo->second) return dateOne->second > dateTwo->second ? 1 : -1;
	return 0;
}

/**
 * This function checks if the given vmo is of one of the provided
 * object types.
 *
 * @param {const tag_t&} wso - The workspace object to check the type for
 * @param {vector<string>} objectTypes - Object types to check for
 * @returns bool - true if the wso is one of provided object types
 */
bool sr5CheckObjectType(const tag_t& wso, std::vector<std::string> objectTypes) {
	std::string sObjectType = "";
	sr5ReadAttrValue_STRING(wso, SR5_TYPE_WorkspaceObject, "object_type", &sObjectType);
	for (auto objectType : objectTypes) {
		if (sObjectType == objectType) return true;
	}
	return false;
}

/**
 * Get the localized value for an LOV entry.
 *
 * @param {tag_t&} lovTag - The LOV
 * @param {char*} lovValue - The LOV value for which to retrieve the localized value
 * @param {const char*} locale - The locale
 * @param {char**} - localizedLovValue - The localized LOV value
 * @returns Error code
 */
int sr5AskLovalizedLovValueString(tag_t& lovTag, char* lovValue, const char* locale, char** localizedLovValue) {
	int valueIndex{ 0 };
	int countLovValues{ 0 };
	char** lovValues{ NULL };
	ITK_CALL(LOV_ask_values_string(lovTag, &countLovValues, &lovValues));
	for (int i = 0; i < countLovValues; i++) {
		if (strcmp(lovValues[i], lovValue) == 0) {
			valueIndex = i;
			break;
		}
	}
	// 54044 Error code if there is no localization
	SAFE_SM_FREE(lovValues);
	int countLocalizedLovValues{ 0 };
	char** localizedLovValues{ NULL };
	ITK_CALL(LOV_ask_localized_values(lovTag, locale, &countLovValues, &localizedLovValues));
	*localizedLovValue = localizedLovValues[valueIndex];
	SAFE_SM_FREE(localizedLovValues);
	return 0;
}

/**
 * Get the list of default locales for the object name.
 *
 * @param {tag_t&} wso - The workspace object
 * @param {vector<string>&} defaultLocales - A vector of default locales
 * @param {bool&} isValidMasterLocale - False if current user session locale is not available in localized LOVs
 * @returns Error code
 */
int sr5AskObjectNameDefaultLocales(tag_t& wso, vector<string>& defaultLocales, bool& isValidMasterLocale) {
	int countDefaultLocales{ 0 };
	char** valuesDefaultLocales{ nullptr };
	ITK_CALL(PREF_ask_char_values("SR5_object_name_default_locales", &countDefaultLocales, &valuesDefaultLocales));
	for (int i = 0; i < countDefaultLocales; i++) {
		defaultLocales.push_back(valuesDefaultLocales[i]);
	}
	char* objectNameMasterLocale{ "" };
	isValidMasterLocale = false;
	ITK_CALL(AOM_ask_property_master_locale(wso, "object_name", &objectNameMasterLocale));
	for (unsigned ii = 0; ii < defaultLocales.size(); ii++) {
		if (strcmp(defaultLocales[ii].c_str(), objectNameMasterLocale) == 0) {
			std::swap(defaultLocales[ii], defaultLocales[0]);
			isValidMasterLocale = true;
			break;
		}
	}
	if (isValidMasterLocale == false) {
		defaultLocales.insert(defaultLocales.begin(), objectNameMasterLocale);
	}
	SAFE_SM_FREE(objectNameMasterLocale);
	SAFE_SM_FREE(valuesDefaultLocales);
	return 0;
}

/**
 * Check if the revision is enabled for localized object name.
 *
 * @param {tag_t&} rev - The workspace object
 * @returns result
 */
bool sr5CheckUseObjectNameTermLovsForRev(tag_t& rev) {
	char* objectType{ "" };
	ITK_CALL(WSOM_ask_object_type2(rev, &objectType));
	char* constantValue{ "" };
	ITK_CALL(CONSTANTS_get_type_constant_value("SR5UseObjectNameTermLovs", objectType, &constantValue));
	if (constantValue == NULL) {
		return false;
	}
	else if (strcmp(constantValue, "true") == 0) {
		return true;
	}
	else {
		return false;
	}
}

/**
 * Set localized object name of Item
 *
 * @param {tag_t&} item - The item for which to set the object name
 * @returns Error code
 */
int sr5SetLocalizedObjectNameItem(tag_t item) {
	tag_t* taItemRevisions{ NULL };
	int iCountItemRevisions{ 0 };
	vector<string> objectNameTermProps{ "sr5ObjectNameTerm1", "sr5ObjectNameTerm2", "sr5ObjectNameTerm3" };
	vector<string> defaultLocales;
	bool isValidMasterLocale{ false };
	bool isObjectNameUpdated{ false };

	ITK_CALL(ITEM_list_all_revs(item, &iCountItemRevisions, &taItemRevisions));
	if (iCountItemRevisions == 0) return 0;
	tag_t rev{ taItemRevisions[iCountItemRevisions - 1] };
	if (sr5CheckUseObjectNameTermLovsForRev(rev) == false) return 0;

	// Initialize WSO
	int iLockToken = POM_no_lock;
	bool lIsLoaded = false;
	ITK_CALL(POM_is_loaded(item, &lIsLoaded));
	if (!lIsLoaded)ITK_CALL(AOM_load(item));

	int iState = 0;
	ITK_CALL(POM_ask_instance_state(item, &iState));
	if (iState != POM_inst_is_new) ITK_CALL(POM_ask_instance_lock(item, &iLockToken));
	if (iLockToken == POM_no_lock) ITK_CALL(AOM_refresh(item, TRUE));

	// Handle localizations
	sr5AskObjectNameDefaultLocales(rev, defaultLocales, isValidMasterLocale);

	for (int i = 0; i < defaultLocales.size(); i++) {
		string objectNameLocalized{ "" };

		for (int j = 0; j < objectNameTermProps.size(); j++) {
			char* objectNameTerm{ " " };

			ITK_CALL(AOM_ask_value_string(rev, objectNameTermProps[j].c_str(), &objectNameTerm));
			if (strcmp(objectNameTerm, "") == 0) continue;

			tag_t objectNameTermLov{ NULL };
			ITK_CALL(AOM_ask_lov(rev, objectNameTermProps[j].c_str(), &objectNameTermLov));
			char* objectNameTermLocalized{ "" };
			sr5AskLovalizedLovValueString(objectNameTermLov, objectNameTerm, defaultLocales[i].c_str(), &objectNameTermLocalized);
			objectNameLocalized += objectNameTermLocalized;
			if (j != objectNameTermProps.size() - 1) {
				objectNameLocalized += " ";
			}
			SAFE_SM_FREE(objectNameTerm);
		}

		if (objectNameLocalized.size() > 0) {
			if (i == 0 && isValidMasterLocale == false) {
				objectNameLocalized = "Localization for " + defaultLocales[i] + " not available";
				ITK_CALL(AOM_UIF_set_localized_value_string(item, "object_name", defaultLocales[i].c_str(), objectNameLocalized.c_str(), TC_TRANSLATIONSTATUS_master, TRUE));
			} else if (i == 0) {
				ITK_CALL(AOM_UIF_set_localized_value_string(item, "object_name", defaultLocales[i].c_str(), objectNameLocalized.c_str(), TC_TRANSLATIONSTATUS_master, TRUE));
			} else {
				ITK_CALL(AOM_UIF_set_localized_value_string(item, "object_name", defaultLocales[i].c_str(), objectNameLocalized.c_str(), TC_TRANSLATIONSTATUS_approved, FALSE));
			}
			isObjectNameUpdated = true;
		}
	}

	if (isObjectNameUpdated) {
		ITK_CALL(AOM_save_without_extensions(item));
	}
	if (iLockToken == POM_no_lock) ITK_CALL(AOM_refresh(item, FALSE));

	SAFE_SM_FREE(taItemRevisions);

	return 0;
}

/**
 * Set localized object name of ItemRevision
 *
 * @param {tag_t&} itemRev - The item revision for which to set the object name
 * @returns Error code
 */
int sr5SetLocalizedObjectNameItemRev(tag_t itemRev) {
	if (sr5CheckUseObjectNameTermLovsForRev(itemRev) == false) return 0;
	vector<string> objectNameTermProps{ "sr5ObjectNameTerm1", "sr5ObjectNameTerm2", "sr5ObjectNameTerm3" };
	vector<string> defaultLocales;
	bool isValidMasterLocale{ false };
	bool isObjectNameUpdated{ false };

	// Initialize WSO
	int iLockToken = POM_no_lock;
	bool lIsLoaded = false;
	ITK_CALL(POM_is_loaded(itemRev, &lIsLoaded));
	if (!lIsLoaded)ITK_CALL(AOM_load(itemRev));

	int iState = 0;
	ITK_CALL(POM_ask_instance_state(itemRev, &iState));
	if (iState != POM_inst_is_new) ITK_CALL(POM_ask_instance_lock(itemRev, &iLockToken));
	if (iLockToken == POM_no_lock) ITK_CALL(AOM_refresh(itemRev, TRUE));

	// Handle localizations
	sr5AskObjectNameDefaultLocales(itemRev, defaultLocales, isValidMasterLocale);
	for (int i = 0; i < defaultLocales.size(); i++) {
		string objectNameLocalized{ "" };

		for (int j = 0; j < objectNameTermProps.size(); j++) {
			char* objectNameTerm{ "" };

			ITK_CALL(AOM_ask_value_string(itemRev, objectNameTermProps[j].c_str(), &objectNameTerm));
			if (strcmp(objectNameTerm, "") == 0) continue;

			tag_t objectNameTermLov{ NULL };
			ITK_CALL(AOM_ask_lov(itemRev, objectNameTermProps[j].c_str(), &objectNameTermLov));
			char* objectNameTermLocalized{ "" };
			sr5AskLovalizedLovValueString(objectNameTermLov, objectNameTerm, defaultLocales[i].c_str(), &objectNameTermLocalized);
			objectNameLocalized += objectNameTermLocalized;
			if (j != objectNameTermProps.size() - 1) {
				objectNameLocalized += " ";
			}
			SAFE_SM_FREE(objectNameTerm);
		}

		if(objectNameLocalized.size() > 0) {
			if (i == 0 && isValidMasterLocale == false) {
				objectNameLocalized = "Localization for " + defaultLocales[i] + " not available";
				ITK_CALL(AOM_UIF_set_localized_value_string(itemRev, "object_name", defaultLocales[i].c_str(), objectNameLocalized.c_str(), TC_TRANSLATIONSTATUS_master, TRUE));
			} else if (i == 0) {
				ITK_CALL(AOM_UIF_set_localized_value_string(itemRev, "object_name", defaultLocales[i].c_str(), objectNameLocalized.c_str(), TC_TRANSLATIONSTATUS_master, TRUE));
			} else {
				ITK_CALL(AOM_UIF_set_localized_value_string(itemRev, "object_name", defaultLocales[i].c_str(), objectNameLocalized.c_str(), TC_TRANSLATIONSTATUS_approved, FALSE));
			}
			isObjectNameUpdated = true;
		}
	}

	if (isObjectNameUpdated) {
		ITK_CALL(AOM_save_without_extensions(itemRev));
	}
	if (iLockToken == POM_no_lock) ITK_CALL(AOM_refresh(itemRev, FALSE));

	return 0;
}