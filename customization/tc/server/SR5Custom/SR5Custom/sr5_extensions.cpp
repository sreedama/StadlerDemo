#include "sr5_register_callbacks.h"


//-----------------------------------------------------------------------
// Function    : xxxx
// Description : xxxx               
// Returns     : xxxx
//-----------------------------------------------------------------------
// Date            By                       Reason
// xx-xxx-2021	   Sebastian Falkenberg     Initial creation
//-----------------------------------------------------------------------
extern USER_EXT_DLL_API int SR5Extension_BOMLineAdd_Precondition(METHOD_message_t* msg, va_list args)
{
	int ifail = ITK_ok;

	va_list largs;
	va_copy(largs, args);

	tag_t parent = va_arg(largs, tag_t);			//The line to which the component is to be added.
	tag_t item = va_arg(largs, tag_t);				//Item to add.It can be #NULLTAG.
	tag_t item_revision = va_arg(largs, tag_t);		//Item Revision to add.This is only used if @p pitem is #NULLTAG.
	tag_t bom_view = va_arg(largs, tag_t);			//View to use.If #NULLTAG, the default view is used.
	char* occurrence_type = va_arg(largs, char*);	//The Occurrence type.
	tag_t* new_bom_line = va_arg(largs, tag_t*);	//The created BOM Line.
	tag_t gde = va_arg(largs, tag_t);				//The General Design Element(GDE) line to add.
	tag_t occ_create_input = va_arg(largs, tag_t);	//The create input object for the Occurrence to be created.

	va_end(largs);

	// Check child type
	tag_t tParentRev = NULLTAG;
	ITK_CALL(AOM_ask_value_tag(parent, "bl_revision", &tParentRev));
	vector<tag_t> vecSecondary;
	sr5AskSecondaryObjects(tParentRev, TC_specification_rtype, "CATPart", &vecSecondary);
	if (vecSecondary.size() > 0) {
		std::string strChildObjectType;
		sr5ReadAttrValue_STRING(item_revision, "WorkspaceObject", "object_type", &strChildObjectType);


		if (strChildObjectType.compare(SR5_TYPE_SR5CatDefArticleRevision) != 0 && strChildObjectType.compare(SR5_TYPE_SR5EngArticleRevision) != 0 && strChildObjectType.compare(SR5_TYPE_SR5EngRawArticleRevision) != 0)
		{
			//If an article with a CATPart shall have a child attached, it must be a SR5CatDefArticleRevision or SR5EngArticleRevision
			ifail = 919100;
			return ifail;
		}

		//check if topline already has Children
		tag_t* viewChildren = NULL;
		int nChildren = NULL;
		ITK_CALL(AOM_ask_value_tags(tParentRev, "view", &nChildren, &viewChildren));
		if (nChildren > 0)
		{
			//If an Article has a CATPart and already has a child, then the attachment is wrong. Only one CATDefArticleRevision or SR5EngArticleRevision allowed and other structure also not allowed
			ifail = 919104;
			return ifail;

		}
	}

	// Normalize Child Object
	if (ifail == ITK_ok) {
		tag_t tChildRevision = item_revision;
		if (item != NULLTAG) ITK_CALL(ITEM_ask_latest_rev(item, &tChildRevision));

		if (sr5IsValidLLObject(tParentRev) == true && sr4IsValidEBOMObject(tChildRevision) == true) {
			// Scenario: Add E-BOM Element to LL-BOM
			logical lHasStatus30 = false;
			logical lHasStatus40 = false;
			logical lHasStatus50 = false;

			if (!lHasStatus30 && !lHasStatus40 && !lHasStatus50) sr5HasStatus(tChildRevision, RELSTAT_30, &lHasStatus30);
			if (!lHasStatus30 && !lHasStatus40 && !lHasStatus50) sr5HasStatus(tChildRevision, RELSTAT_40, &lHasStatus40);
			if (!lHasStatus30 && !lHasStatus40 && !lHasStatus50) sr5HasStatus(tChildRevision, RELSTAT_50, &lHasStatus50);

			if (!lHasStatus30 && !lHasStatus40 && !lHasStatus50) {
				ifail = 919102;
			}
		} else if (sr5IsValidMfgAssy(tParentRev) == true && sr4IsValidEBOMObject(tChildRevision) == true) {
			// Scenario: Add E-BOM Element to MBOM
			logical lHasStatus40 = false;
			logical lHasStatus50 = false;

			if (!lHasStatus40 && !lHasStatus50) sr5HasStatus(tChildRevision, RELSTAT_40, &lHasStatus40);
			if (!lHasStatus40 && !lHasStatus50) sr5HasStatus(tChildRevision, RELSTAT_50, &lHasStatus50);

			if (!lHasStatus40 && !lHasStatus50) {
				ifail = 919102;
			}
		}

		// Scenario: Add localized MFG child to localized MFG parent
		if (sr5IsValidMfgAssy(tChildRevision) == true) {
			// Read parent plant
			tag_t tParentItem = NULLTAG;
			ITK_CALL(AOM_ask_value_tag(parent, "bl_item", &tParentItem));
			if (sr5IsValidMfgAssy(tParentItem) == true) {
				std::string sParentPlant, sChildPlant;
				sr5ReadAttrValue_STRING(tParentItem, "SR5GenMfgObj", "sr5Plant", &sParentPlant);
				sr5ReadAttrValue_STRING(item, "SR5GenMfgObj", "sr5Plant", &sChildPlant);

				if (sParentPlant.empty() == false && (sParentPlant.compare(sChildPlant) != 0)) {
					if (sChildPlant.empty() == false) {
						// TODO: Error Code
						ifail = 919101;
					}
				}
			}
		}
	}

	return ifail;
}

//-----------------------------------------------------------------------
// Function    : xxxx
// Description : xxxx               
// Returns     : xxxx
//-----------------------------------------------------------------------
// Date            By                       Reason
// xx-xxx-2021	   Sebastian Falkenberg     Initial creation
//-----------------------------------------------------------------------
extern USER_EXT_DLL_API int SR5Extension_BOMLineAdd_PostAction(METHOD_message_t* msg, va_list args)
{
	int ifail = ITK_ok;

	va_list largs;
	va_copy(largs, args);

	tag_t parent = va_arg(largs, tag_t);			//The line to which the component is to be added.
	tag_t item = va_arg(largs, tag_t);				//Item to add.It can be #NULLTAG.
	tag_t item_revision = va_arg(largs, tag_t);		//Item Revision to add.This is only used if @p pitem is #NULLTAG.
	tag_t bom_view = va_arg(largs, tag_t);			//View to use.If #NULLTAG, the default view is used.
	char* occurrence_type = va_arg(largs, char*);	//The Occurrence type.
	tag_t* new_bom_line = va_arg(largs, tag_t*);	//The created BOM Line.
	tag_t gde = va_arg(largs, tag_t);				//The General Design Element(GDE) line to add.
	tag_t occ_create_input = va_arg(largs, tag_t);	//The create input object for the Occurrence to be created.

	va_end(largs);

	// Normalize Child Object
	tag_t tChildRevision = item_revision;
	if (item != NULLTAG) ITK_CALL(ITEM_ask_latest_rev(item, &tChildRevision));

	// Is Manufacturing Object
	string strChildObjectType = "";
	sr5ReadAttrValue_STRING(tChildRevision, "WorkspaceObject", "object_type", &strChildObjectType);

	if (strChildObjectType.compare(SR5_TYPE_SR5MfgInstallKitRevision) == 0) {
		char* sParentObjectType = NULL;
		
		ITK_CALL(AOM_ask_value_string(parent, "bl_rev_object_type", &sParentObjectType));
		if (tc_strcmp(sParentObjectType, SR5_TYPE_SR5MfgMajorAssyRevision) == 0) {
			char* sParentSAPMatType = NULL;
			
			ITK_CALL(AOM_ask_value_string(parent, "bl_SR5GenPart_sr5SAPMaterialType", &sParentSAPMatType));
			if (tc_strcmp(sParentSAPMatType, "MASS") != 0) {
				tag_t tParentItem = NULLTAG;

				ITK_CALL(AOM_ask_value_tag(parent, "bl_item", &tParentItem));

				if (tParentItem != NULLTAG) {
					sr5PrepareObjForModify(tParentItem, "Item");
					ITK_CALL(AOM_set_value_string(tParentItem, "sr5SAPMaterialType", "MASS"));
					ITK_CALL(AOM_save_without_extensions(tParentItem));
					ITK_CALL(AOM_refresh(tParentItem, false));
					sr5UnloadInstances(1, &tParentItem);
				}
			}
		}

		SAFE_SM_FREE(sParentObjectType);
	}

	return ifail;
}

extern USER_EXT_DLL_API int SR5_USER_ask_new_seqno(int* decision, va_list args)
{
	int ifail = ITK_ok;
	*decision = ALL_CUSTOMIZATIONS;

	va_list largs;
	va_copy(largs, args);
		tag_t  tParentBVR = va_arg(largs, tag_t);
		tag_t  tNewChildObj = va_arg(largs, tag_t);
		char** sReturnSeqNo = va_arg(largs, char**);
	va_end(largs);

	char* sequence_no = "";

	if (tParentBVR == NULLTAG) {
		sequence_no = "10";
		*decision = ONLY_CURRENT_CUSTOMIZATION;
	} else {
		std::string strChildObjectType = "";

		sr5ReadAttrValue_STRING(tNewChildObj, SR5_TYPE_WorkspaceObject, SR5_ATTR_objectType, &strChildObjectType);

		if (strChildObjectType.compare(SR5_TYPE_SR5EngArticleAR) == 0 || strChildObjectType.compare(SR5_TYPE_SR5EngArticleARRevision) == 0) {
			// Alternate Representation
			int n_occurrences = 0;
			tag_t* t_occurrences = NULL;
			logical lMatch = false;

			std::string strARItemID = "";

			if (strChildObjectType.compare(SR5_TYPE_SR5EngArticleAR) == 0) {
				sr5ReadAttrValue_STRING(tNewChildObj, SR5_TYPE_Item, "item_id", &strARItemID);
			} else if (strChildObjectType.compare(SR5_TYPE_SR5EngArticleARRevision) == 0) {
				tag_t tTmpChildItem = NULLTAG;

				sr5ReadAttrValue_TAG(tNewChildObj, SR5_TYPE_ItemRev, "items_tag", &tTmpChildItem);
				sr5ReadAttrValue_STRING(tTmpChildItem, SR5_TYPE_Item, "item_id", &strARItemID);
			}

			ifail = PS_list_occurrences_of_bvr(tParentBVR, &n_occurrences, &t_occurrences);
			if (ifail != ITK_ok) return ifail;

			// Traverse Occurrences
			for (int i = 0; i < n_occurrences; i++) {
				tag_t tChildObject, tChildBVR;
				ITK_CALL(PS_ask_occurrence_child(tParentBVR, t_occurrences[i], &tChildObject, &tChildBVR));

				std::string strTmpChildObjectType = "", strTmpChildItemID = "";
				sr5ReadAttrValue_STRING(tChildObject, SR5_TYPE_WorkspaceObject, SR5_ATTR_objectType, &strTmpChildObjectType);

				if (strTmpChildObjectType.compare(SR5_TYPE_SR5EngArticle) == 0) {
					sr5ReadAttrValue_STRING(tChildObject, SR5_TYPE_Item, "item_id", &strTmpChildItemID);
				} else if (strChildObjectType.compare(SR5_TYPE_SR5EngArticleRevision) == 0) {
					tag_t tTmpChildItem = NULLTAG;

					sr5ReadAttrValue_TAG(tChildObject, SR5_TYPE_ItemRev, "items_tag", &tTmpChildItem);
					sr5ReadAttrValue_STRING(tTmpChildItem, SR5_TYPE_Item, "item_id", &strTmpChildItemID);
				}

				if (strTmpChildItemID.compare(strARItemID) == 0) {
					ITK_CALL(PS_ask_seq_no(tParentBVR, t_occurrences[i], &sequence_no));
					*decision = ONLY_CURRENT_CUSTOMIZATION;

					break;
				}
			}

			SAFE_SM_FREE(t_occurrences);
		}

		if (tc_strcmp(sequence_no, "") == 0) {
			// Regular case, no Alternate Representation
			ifail = PS_bvr_ask_default_next_seq_no(tParentBVR, tNewChildObj, &sequence_no);
			if (ifail != ITK_ok) {
				if (ifail != PS_no_seq_no) {
					return ITK_ok;
				}
				else if (ifail != ITK_ok) {
					ITK_CALL(EMH_clear_last_error(PS_no_seq_no));
				}
			}
		}
	}

	if (tc_strcmp(sequence_no, "") != 0) {
		*sReturnSeqNo = (char*)MEM_alloc(strlen(sequence_no) + 1);
		tc_strcpy(*sReturnSeqNo, sequence_no);
	}

	return ifail;
}

//---------------------------------------------------------------------------
// Function    : SR5Extension_BMFQRYCustomExecute_BaseAction
// Description : This extension provides a user query for checked-out objects  
//               based on selected object type, checked-out user, checked-out
//               date before and checked-out date after.             
// Returns     : int
//---------------------------------------------------------------------------
// Date            By                       Reason
// 22-Mar-2022	   Dino Pergola             Initial creation
//---------------------------------------------------------------------------
extern USER_EXT_DLL_API int SR5Extension_BMFQRYCustomExecute_BaseAction(METHOD_message_t* msg, va_list args) {

	int ifail = ITK_ok;

	va_list largs;
	va_copy(largs, args);
	char* qName = va_arg(largs, char*); // The name of our query, used to check the query context
	int   num_args = va_arg(largs, int); // Number of arguments
	char** names = va_arg(largs, char**); // The names of the search criteria defined in the query definition
	char** values = va_arg(largs, char**); // The values of the search criteria definded in the query definition
	int* num_found = va_arg(largs, int*); // The number of search results to return
	tag_t** found = va_arg(largs, tag_t**); // The objects to return
	va_end(largs);

	// We need to check if the performed search is the "Checked-Out Objects by Type" saved search.
	if (strcmp(qName, "Checked-Out Objects by Type") == 0) {

		// First we check which search criteria was provided since emtpy fields are not passed as part of the names and values arguments
		char
			* pObjectType = NULL,
			* pCheckedOutBefore = NULL,
			* pCheckedOutAfter = NULL,
			* pCheckedOutUser = NULL,
			* pObjectName = NULL;

		for (int i = 0; i < num_args; i++) {
			if (strcmp(names[i], "Type") == 0 || strcmp(names[i], "Typ") == 0) pObjectType = values[i];
			if (strcmp(names[i], "Checked-Out Before") == 0 || strcmp(names[i], "Ausgecheckt vor") == 0) pCheckedOutBefore = values[i];
			if (strcmp(names[i], "Checked-Out After") == 0 || strcmp(names[i], "Ausgecheckt nach") == 0) pCheckedOutAfter = values[i];
			if (strcmp(names[i], "Checked-Out by User") == 0 || strcmp(names[i], "Ausgecheckt durch Benutzer") == 0) pCheckedOutUser = values[i];
			if (strcmp(names[i], "Name") == 0) pObjectName = values[i];
		}

		// Here we define the attributes, class and expressions for the main query and its sub queries.
		// The main query returns the UIDs of all objects matching the search criteria
		const char
			* pMainQry = "Query1",
			* pMainClass = "ImanRelation",
			* pMainExp1 = "Expression1",
			* pMainExp2 = "Expression2",
			* pMainExp3 = "Expression3",
			* pMainExp4 = "Expression4",
			* pMainSelectAttrs[] = { "primary_object" };

		tag_t objectTag = NULLTAG;
		void*** ppReport = NULL;
		int rows = 0;
		int cols = 0;

		// We use the SubQuery1 to narrow down the ImanRelation table to entries where the secondary object is of type IMAN_RES_checkout
		const char
			* pSubQry1 = "SubQuery1",
			* pSub1Class = "ImanType",
			* pSub1Exp1 = "Sub1Expression1",
			* pSub1SelectAttrs[] = { "puid" };

		// We use the SubQuery2 to narrow doen the ImanRelation table to entries where the primary object is of the specified type.
		const char
			* pSubQry2 = "SubQuery2",
			* pSub2Class = "WorkspaceObject",
			* pSub2Exp1 = "Sub2Expression1",
			* pSub2SelectAttrs[] = { "puid" };

		// We use the SubQuery3 to narrow down the ImanRelation table to entries where the creation date of Reservation objects
		// is between the specified dates and the owning user of the Reservation object is the specified user.
		const char
			* pSubQry3 = "SubQuery3",
			* pSub3Class = "ImanReservation",
			* pSub3Exp1 = "Sub3Expression1",
			* pSub3Exp2 = "Sub3Expression2",
			* pSub3Exp3 = "Sub3Expression3",
			* pSub3SelectAttrs[] = { "puid" };

		// We need the SubQuery4 to acces the user id of the specified user.
		const char
			* pSubQry4 = "SubQuery4",
			* pSub4Class = "POM_user",
			* pSub4Exp1 = "Sub4Expression1",
			* pSub4SelectAttrs[] = { "puid" };

		// We need the SubQuery5 to narrow down the ImanRelation table to entries where the name of the primary object is equal to the
		// name of the value specified by the user.
		const char
			* pSubQry5 = "SubQuery5",
			* pSub5Class = "WorkspaceObject",
			* pSub5Exp1 = "Sub5Expression1",
			* pSub5SelectAttrs[] = { "puid" };

		try {
			// We have to check if the Main-Query already exists since only one instance of a given ID can exist.
			logical lExist = false;

			ITK_CALL(POM_enquiry_does_query_exists(pMainQry, &lExist));
			if (lExist) ITK_CALL(POM_enquiry_delete(pMainQry));

			// We create the main query and set the sub queries
			ITK_CALL(POM_enquiry_create(pMainQry));
			ITK_CALL(POM_enquiry_set_sub_enquiry(pMainQry, pSubQry1));
			ITK_CALL(POM_enquiry_set_sub_enquiry(pMainQry, pSubQry2));
			ITK_CALL(POM_enquiry_set_sub_enquiry(pMainQry, pSubQry3));
			ITK_CALL(POM_enquiry_set_sub_enquiry(pMainQry, pSubQry4));
			ITK_CALL(POM_enquiry_set_sub_enquiry(pMainQry, pSubQry5));

			// We perform the first sub query. This sub query is always executed.
			ITK_CALL(POM_enquiry_add_select_attrs(pSubQry1, pSub1Class, 1, pSub1SelectAttrs));
			ITK_CALL(POM_enquiry_set_string_expr(pSubQry1, pSub1Exp1, pSub1Class, "type_name", POM_enquiry_equal, "IMAN_RES_checkout"));
			ITK_CALL(POM_enquiry_set_where_expr(pSubQry1, pSub1Exp1));

			// We perform the second sub query only if a object type was provided in the search criteria.
			// Otherwise we select all objects where the UID is not NULL.
			ITK_CALL(POM_enquiry_add_select_attrs(pSubQry2, pSub2Class, 1, pSub2SelectAttrs));
			if (pObjectType != NULL) {
				ITK_CALL(POM_enquiry_set_string_expr(pSubQry2, pSub2Exp1, pSub2Class, "object_type", POM_enquiry_equal, pObjectType));
			}
			else {
				ITK_CALL(POM_enquiry_set_attr_expr(pSubQry2, pSub2Exp1, pSub2Class, "object_type", POM_enquiry_is_not_null, ""));
			};
			ITK_CALL(POM_enquiry_set_where_expr(pSubQry2, pSub2Exp1));

			// We create the third subquery. It contains three expressions.
			ITK_CALL(POM_enquiry_add_select_attrs(pSubQry3, pSub3Class, 1, pSub3SelectAttrs));

			// We set the first expression to the checked-out date after if provided in the search criteria.
			// Otherwise we select all objects where the date is not NULL.
			if (pCheckedOutAfter != NULL) {
				date_t dCheckedOutAfter;
				ITK_CALL(ITK_string_to_date(pCheckedOutAfter, &dCheckedOutAfter)); //values[2]
				ITK_CALL(POM_enquiry_set_date_value(pSubQry3, "dateAfter", 1, &dCheckedOutAfter, POM_enquiry_const_value));
				ITK_CALL(POM_enquiry_set_attr_expr(pSubQry3, pSub3Exp2, pSub3Class, "date", POM_enquiry_greater_than_or_eq, "dateAfter"));
			}
			else {
				ITK_CALL(POM_enquiry_set_attr_expr(pSubQry3, pSub3Exp2, pSub3Class, "date", POM_enquiry_is_not_null, ""));
			};

			// We set the second expression to the checked-out date before if provided in the search criteria.
			// Otherwise we select all objects where the date is not NULL.
			if (pCheckedOutBefore != NULL) {
				date_t dCheckedOutBefore;
				ITK_CALL(ITK_string_to_date(pCheckedOutBefore, &dCheckedOutBefore));
				ITK_CALL(POM_enquiry_set_date_value(pSubQry3, "dateBefore", 1, &dCheckedOutBefore, POM_enquiry_const_value));
				ITK_CALL(POM_enquiry_set_attr_expr(pSubQry3, pSub3Exp3, pSub3Class, "date", POM_enquiry_less_than_or_eq, "dateBefore"));
			}
			else {
				ITK_CALL(POM_enquiry_set_attr_expr(pSubQry3, pSub3Exp3, pSub3Class, "date", POM_enquiry_is_not_null, ""));
			};

			// We set the third expression to the user if provided in the search criteria.
			// Otherwise we select all objects where the user object is not NULL.
			if (pCheckedOutUser != NULL) {
				ITK_CALL(POM_enquiry_add_select_attrs(pSubQry4, pSub4Class, 1, pSub4SelectAttrs));
				ITK_CALL(POM_enquiry_set_string_expr(pSubQry4, pSub4Exp1, pSub4Class, "user_id", POM_enquiry_equal, pCheckedOutUser));
				ITK_CALL(POM_enquiry_set_where_expr(pSubQry4, pSub4Exp1));
				ITK_CALL(POM_enquiry_set_attr_expr(pSubQry3, pSub3Exp1, pSub3Class, "user_object", POM_enquiry_in, pSubQry4));
			}
			else {
				ITK_CALL(POM_enquiry_set_attr_expr(pSubQry3, pSub3Exp1, pSub3Class, "user_object", POM_enquiry_is_not_null, ""));
			};

			// We combine all there expressions and set the where clause of the third sub query
			ITK_CALL(POM_enquiry_set_expr(pSubQry3, "Sub3Exp1Exp2", pSub3Exp1, POM_enquiry_and, pSub3Exp2));
			ITK_CALL(POM_enquiry_set_expr(pSubQry3, "Sub3Exp1Exp2Exp3", "Sub3Exp1Exp2", POM_enquiry_and, pSub3Exp3));
			ITK_CALL(POM_enquiry_set_where_expr(pSubQry3, "Sub3Exp1Exp2Exp3"));

			// We build the fifth sub query to search by the name of the object we are looking for
			ITK_CALL(POM_enquiry_add_select_attrs(pSubQry5, pSub5Class, 1, pSub5SelectAttrs));
			if (pObjectName != NULL) {
				ITK_CALL(POM_enquiry_set_string_expr(pSubQry5, pSub5Exp1, pSub5Class, "object_name", POM_enquiry_like, pObjectName));
			}
			else {
				ITK_CALL(POM_enquiry_set_attr_expr(pSubQry5, pSub5Exp1, pSub5Class, "object_name", POM_enquiry_is_not_null, ""));
			}
			ITK_CALL(POM_enquiry_set_where_expr(pSubQry5, pSub5Exp1));

			// We build the main query, combine all three expressions and se the where clause.
			ITK_CALL(POM_enquiry_add_select_attrs(pMainQry, pMainClass, 1, pMainSelectAttrs));
			ITK_CALL(POM_enquiry_set_attr_expr(pMainQry, pMainExp1, pMainClass, "relation_type", POM_enquiry_in, pSubQry1));
			ITK_CALL(POM_enquiry_set_attr_expr(pMainQry, pMainExp2, pMainClass, "primary_object", POM_enquiry_in, pSubQry2));
			ITK_CALL(POM_enquiry_set_attr_expr(pMainQry, pMainExp3, pMainClass, "secondary_object", POM_enquiry_in, pSubQry3));
			ITK_CALL(POM_enquiry_set_attr_expr(pMainQry, pMainExp4, pMainClass, "primary_object", POM_enquiry_in, pSubQry5));

			ITK_CALL(POM_enquiry_set_expr(pMainQry, "MainExp1Exp2", pMainExp1, POM_enquiry_and, pMainExp2));
			ITK_CALL(POM_enquiry_set_expr(pMainQry, "MainExp1Exp2Exp3", "MainExp1Exp2", POM_enquiry_and, pMainExp3));
			ITK_CALL(POM_enquiry_set_expr(pMainQry, "MainExp1Exp2Exp3Exp4", "MainExp1Exp2Exp3", POM_enquiry_and, pMainExp4));
			ITK_CALL(POM_enquiry_set_where_expr(pMainQry, "MainExp1Exp2Exp3Exp4"));

			// Lastly we perform the main query.

			ITK_CALL(POM_enquiry_execute(pMainQry, &rows, &cols, &ppReport));

			*found = (tag_t*)MEM_alloc(rows * sizeof(tag_t));

			for (int j = 0; j < rows; j++) {
				objectTag = *((tag_t*)ppReport[j][0]);
				(*found)[j] = objectTag;
				*num_found += 1;
			};


			ITK_CALL(POM_enquiry_delete(pMainQry));
		}
		catch (...) {
			logical lExist = false;
			ITK_CALL(POM_enquiry_does_query_exists(pMainQry, &lExist));
			if (lExist) ITK_CALL(POM_enquiry_delete(pMainQry));
		}

		SAFE_SM_FREE(ppReport);
	};

	return ifail;
}

extern USER_EXT_DLL_API int SR5Extension_BOMLine_AssignChild_PostAction(METHOD_message_t* method, va_list arg) {
	int ifail = ITK_ok;

	va_list largs;
	va_copy(largs, arg);
	tag_t sourceBOMLineTag = va_arg(largs, tag_t);
	char* occTypeName = va_arg(largs, char*);
	tag_t* newChildBOMLineTag = va_arg(largs, tag_t*);
	va_end(largs);

	if (*newChildBOMLineTag != NULLTAG) {
		stringstream ssMBOMPosInfo;
		tag_t tSourceOcc = NULLTAG;
		tag_t tSourceParentBVR = NULLTAG;

		ITK_CALL(AOM_ask_value_tag(sourceBOMLineTag, "bl_real_occurrence", &tSourceOcc));
		ITK_CALL(AOM_ask_value_tag(tSourceOcc, "parent_bvr", &tSourceParentBVR));

		vector<tag_t>vecSourceParentItemRevivions;
		sr5QryAttr_TAG("ItemRevision", "structure_revisions", tSourceParentBVR, &vecSourceParentItemRevivions, true);
		if (vecSourceParentItemRevivions.size() > 0) {
			char* sSourceSeqNo = NULL;
			char* sSourceParentItemID = NULL;

			ITK_CALL(AOM_ask_value_string(sourceBOMLineTag, "bl_sequence_no", &sSourceSeqNo));
			ITK_CALL(AOM_ask_value_string(vecSourceParentItemRevivions.at(0), "item_id", &sSourceParentItemID));

			// SR-1233 : Format changed to an updated format
			ssMBOMPosInfo << sSourceParentItemID << " - " << sSourceSeqNo;

			SAFE_SM_FREE(sSourceSeqNo);
			SAFE_SM_FREE(sSourceParentItemID);
		}

		ITK_CALL(AOM_UIF_set_value(*newChildBOMLineTag, "bl_occ_sr5MBOMPosInfoOcc", ssMBOMPosInfo.str().c_str()));
	}

	return ifail;
}

/**
 * @brief Increment the external revision.
 *
 * @param METHOD_message_t* msg
 * @param va_list args
 *
 * @return Error code.
 */
extern USER_EXT_DLL_API int SR5Extension_ITEM_deep_copy_PostAction(METHOD_message_t* msg, va_list args)
{
	int ifail{ ITK_ok };

	va_list largs{ nullptr };
	va_copy(largs, args);

	tag_t new_rev{ va_arg(largs, tag_t) };
	char* operation{ va_arg(largs, char*) };
	tag_t parent_rev{ va_arg(largs, tag_t) };
	int* copyCount{ va_arg(largs, int*) };
	ITEM_deepcopy_info_t* copyInfo{ va_arg(largs, ITEM_deepcopy_info_t*) };
	int* count{ va_arg(largs, int*) };
	tag_t** copied_objects{ va_arg(largs, tag_t**) };

	va_end(largs);

	sr5SetLocalizedObjectNameItemRev(new_rev);
	tag_t tItem{ NULLTAG };
	ITK_CALL(ITEM_ask_item_of_rev(new_rev, &tItem));
	sr5SetLocalizedObjectNameItem(tItem);

	if (tc_strcmp(operation, "Revise") != 0) return ifail;

	// Check if object type should be respected for external revision
	char* objectType{ "" };
	logical isRespectedObjectType{ false };
	ITK_CALL(WSOM_ask_object_type2(new_rev, &objectType));
	char** asRespectedObjectTypes{ nullptr };
	int iCountRespectedObjectTypes{ 0 };
	ITK_CALL(PREF_ask_char_values("SR5_external_revision_respect_types", &iCountRespectedObjectTypes, &asRespectedObjectTypes));
	for (int jj = 0; jj < iCountRespectedObjectTypes; jj++)
	{
		if (tc_strcmp(objectType, asRespectedObjectTypes[jj]) == 0)
		{
			isRespectedObjectType = true;
			break;
		}
	}
	SAFE_SM_FREE(asRespectedObjectTypes);
	SAFE_SM_FREE(objectType);

	if (!isRespectedObjectType) return ifail;

	// Check if the latest rev has a status listed in the SR5_external_revision_respect_status site preference
	tag_t* taRevisionList{ nullptr };
	int iCountRevisions{ 0 };
	ITK_CALL(ITEM_list_all_revs(tItem, &iCountRevisions, &taRevisionList));
	tag_t tLatestRevision{ taRevisionList[iCountRevisions-2] };
	SAFE_SM_FREE(taRevisionList);

	char** asRespectedStatus{ nullptr };
	int iCountRespectedStatus{ 0 };
	ITK_CALL(PREF_ask_char_values("SR5_external_revision_respect_status", &iCountRespectedStatus, &asRespectedStatus));
	logical lHasRespectedStatus{ false };
	for (int ii = 0; ii < iCountRespectedStatus; ii++)
	{
		sr5HasStatus(tLatestRevision, asRespectedStatus[ii], &lHasRespectedStatus);
		if (lHasRespectedStatus)
			break;
	}
	SAFE_SM_FREE(asRespectedStatus);

	// Copy external revision of latest rev to current rev (CopyFromOriginal BO constant = FALSE)
	if (!lHasRespectedStatus)
	{
		char* sExternalRevisionLatestRev{ "" };
		ITK_CALL(AOM_ask_value_string(tLatestRevision, "sr5ExternalRevision", &sExternalRevisionLatestRev));
		ITK_CALL(AOM_refresh(new_rev, TRUE));
		ITK_CALL(AOM_set_value_string(new_rev, "sr5ExternalRevision", sExternalRevisionLatestRev));
		SAFE_SM_FREE(sExternalRevisionLatestRev);
		ITK_CALL(AOM_save_without_extensions(new_rev)); // Use AOM_save_without_extensions to prevent inifinite loop
		ITK_CALL(AOM_refresh(new_rev, TRUE));
		
		return ifail;
	}

	// Increase to next alphabetical external revision
	char* sExternalRevision{ "" };
	ITK_CALL(AOM_ask_value_string(tLatestRevision, "sr5ExternalRevision", &sExternalRevision));
	std::string strExternalRevision{ sExternalRevision };
	SAFE_SM_FREE(sExternalRevision);
	char* sExcludeChars{ "" };
	ITK_CALL(PREF_ask_char_value("SR5_external_revision_exclude_chars", 0, &sExcludeChars));
	std::string strExcludeChars{ sExcludeChars };
	SAFE_SM_FREE(sExcludeChars);
	sr5IncrementAlphabeticalRevision(strExternalRevision, strExcludeChars);

	ITK_CALL(AOM_refresh(new_rev, TRUE));
	ITK_CALL(AOM_set_value_string(new_rev, "sr5ExternalRevision", strExternalRevision.c_str()));
	ITK_CALL(AOM_save_without_extensions(new_rev)); // Use AOM_save_without_extensions to prevent inifinite loop
	ITK_CALL(AOM_refresh(new_rev, TRUE));

	return ifail;
}


//-----------------------------------------------------------------------
// Function    : SR5Extension_CATPart_Save_PostAction
// Description : Post Action on save of CATPart to trigger JT creation. This function is only triggered when the CATPart is modified, not on initial creation.          
// Returns     : ifail
//-----------------------------------------------------------------------
// Date            By                       Reason
// 26-Sep-2022	   Johannes Buddeberg		Initial creation
//-----------------------------------------------------------------------
extern USER_EXT_DLL_API int SR5Extension_CATPart_Save_PostAction(METHOD_message_t* msg, va_list args)
{
	int ifail = ITK_ok;

	va_list largs;
	va_copy(largs, args);
	tag_t  object_tag = va_arg(largs, tag_t);
	logical  isNew = va_arg(largs, logical);
	va_end(largs);
	/*
	if (object_tag != NULLTAG) {
		std::string sDatasetName = "";
		sr5ReadAttrValue_STRING(object_tag,"CATPart","object_name",&sDatasetName);


		tag_t tRelType = NULLTAG;
		ITK_CALL(TCTYPE_ask_type("IMAN_specification",&tRelType));
		int iPrim = 0;
		tag_t* tPrim = NULL;
		ITK_CALL(GRM_list_primary_objects_only(object_tag, tRelType,&iPrim, &tPrim));

		if (iPrim > 0)
		{
			for (int k=0;k < iPrim; k++)
			{
				std::string PrimObjType = "";
				sr5ReadAttrValue_STRING(tPrim[k], "WorkspaceObject", "object_type", &PrimObjType);
				char* className = NULL;
				tag_t tType = NULLTAG;
				ITK_CALL(TCTYPE_ask_type(PrimObjType.c_str(),&tType));
				ITK_CALL(TCTYPE_ask_class_name2(tType, &className));

				if (tc_strcmp(className, SR5_TYPE_SR5GenEngObjRevision) == 0)
				{

					vector<tag_t> vecDirectModels;
					sr5AskSecondaryObjects(tPrim[k], "IMAN_rendering", "DirectModel", &vecDirectModels);
					if (vecDirectModels.size() > 0)
					{
						tag_t request = NULLTAG;


						ITK_CALL(DISPATCHER_create_request("SIEMENS", "catiav5tojt", 3, time(NULL), time(NULL), 0, 1, &object_tag, &tPrim[k], 0, NULL, "TRANSLATION", 0, NULL, NULL, &request));

						//int interval = 10;           // Check status after every 10 seconds
						//int wait = 0;                // 0 means wait until complete
						//logical is_complete = false;
						//ITK_CALL(DISPATCHER_wait_for_request(request, interval, wait, &is_complete));
						//if (is_complete) cout << endl << "   Translation is completed!" << endl;


					}
					else
					{
						tag_t request = NULLTAG;

						ITK_CALL(DISPATCHER_create_request("SIEMENS", "catiav5tojt", 1, time(NULL), time(NULL), 0, 1, &object_tag, &tPrim[k], 0, NULL, "TRANSLATION", 0, NULL, NULL, &request));

						//int interval = 10;           // Check status after every 10 seconds
						//int wait = 0;                // 0 means wait until complete
						//logical is_complete = false;
						//ITK_CALL(DISPATCHER_wait_for_request(request, interval, wait, &is_complete));
						//if (is_complete) cout << endl << "   Translation is completed!" << endl;

					}
					break;
				}
			}
		}
	}
	*/
	
	return ifail;

}


//-----------------------------------------------------------------------
// Function    : SR5Extension_FSF_object_name_PROP_PostAction
// Description : Property Post Action on object name to write the string to the Benennung_1 and Benennung_2 attributes on modification.           
// Returns     : ifail
//-----------------------------------------------------------------------
// Date            By                       Reason
// 21-Sep-2022	   Johannes Buddeberg		Initial creation
//-----------------------------------------------------------------------
extern USER_EXT_DLL_API int SR5Extension_FSF_object_name_PROP_PostAction (METHOD_message_t* msg, va_list args)
{

	int ifail = ITK_ok;
	va_list largs;
	va_copy(largs, args);

	tag_t       propTag		= va_arg(args, tag_t);
	char*		sUserValue	= va_arg(args, char*);
	const char* sPropName	= msg->prop_name;
	tag_t       tObject		= msg->object_tag;

	va_end(largs);
	/*
	if (tObject != NULLTAG) {

		std::string rObjName = sUserValue;
	
		if (rObjName.size() > 0)
		{

			if (rObjName.size() > 25)
			{
				std::string first = "";
				std::string second = "";
				std::string sMiddle = "";
				int FirstBorder = 0;
				int SecondBorder = 0;

				if (rObjName.size() > 40)
				{
					rObjName = rObjName.substr(0,40);
				}

				FirstBorder = rObjName.size() - 25;
				SecondBorder = 50 - rObjName.size();

				sMiddle = rObjName.substr(FirstBorder, SecondBorder);

				std::size_t found = sMiddle.find_last_of(" ");

				if (found != std::string::npos)
				{
					first = rObjName.substr(0, FirstBorder + found);

					ITK_CALL(AOM_set_value_string(tObject, "sr5CATIAFSFName1", first.c_str()));

					second = rObjName.substr(found + FirstBorder+1);
					
					ITK_CALL(AOM_set_value_string(tObject, "sr5CATIAFSFName2", second.c_str()));
				}
				else
				{

					first = rObjName.substr(0, 25);
					ITK_CALL(AOM_set_value_string(tObject, "sr5CATIAFSFName1", first.c_str()));

					second = rObjName.substr(25, 15);
					ITK_CALL(AOM_set_value_string(tObject, "sr5CATIAFSFName2", second.c_str()));
				}
			}
			else
			{
				ITK_CALL(AOM_set_value_string(tObject, "sr5CATIAFSFName1", rObjName.c_str()));
			}
		}

	ITK_CALL(AOM_save_without_extensions(tObject));
	ITK_CALL(AOM_refresh(tObject, TRUE));
	}
	*/
	
	return ifail;
}


//-----------------------------------------------------------------------
// Function    : SR5Extension_GRM_create_PostAction
// Description : Post Action forcreation of IMAN_specification relation to trigger JT creation             
// Returns     : ifail
//-----------------------------------------------------------------------
// Date            By                       Reason
// 26-Sep-2022	   Johannes Buddeberg		Initial creation
//-----------------------------------------------------------------------
extern DLLAPI int SR5Extension_GRM_create_PostAction(METHOD_message_t* m, va_list args)
{

	int ifail = ITK_ok;

	va_list largs;
	va_copy(largs, args);

	tag_t  primary_object = va_arg(largs, tag_t);
	tag_t  secondary_object = va_arg(largs, tag_t);
	tag_t  relation_type = va_arg(largs, tag_t);
	tag_t  user_data = va_arg(largs, tag_t);
	tag_t* new_relation = va_arg(largs, tag_t*);

	va_end(largs);
	/*
	
	tag_t secObjType = NULLTAG;
	ITK_CALL(TCTYPE_ask_object_type(secondary_object, &secObjType));
	char* type_name = NULL;
	ITK_CALL(TCTYPE_ask_name2(secObjType, &type_name));

	if (secondary_object != NULLTAG && tc_strcmp(type_name,"CATPart")==0) {
		if (primary_object!= NULLTAG)
		{
			std::string PrimObjType = "";
			sr5ReadAttrValue_STRING(primary_object, "WorkspaceObject", "object_type", &PrimObjType);
			char* className = NULL;
			tag_t tType = NULLTAG;
			ITK_CALL(TCTYPE_ask_type(PrimObjType.c_str(), &tType));
			ITK_CALL(TCTYPE_ask_class_name2(tType, &className));

			if (tc_strcmp(className, SR5_TYPE_SR5GenEngObjRevision) == 0)
			{


				tag_t newDispReqTag = NULLTAG;
  
				  // GET Dispatcher Request TYPE
				  tag_t   DispReqTypeTag = NULLTAG;
				  ERROR_CHECK( TCTYPE_find_type( "DispatcherRequest", NULL, &DispReqTypeTag) );
  
				  // CREATE INPUT OBJECTS FOR OBJECT TYPE
				  tag_t   DispReqCreInTag = NULLTAG;
				  ERROR_CHECK( TCTYPE_construct_create_input( DispReqTypeTag, &DispReqCreInTag) );

				  // POPULATE DISPATCHER REQUEST MANDATORY PROPERTIES

				  // TaskID is autoassigned
				  // char* pcTaskID = NULL;
				  // pcTaskID= "XXX";
				  // ERROR_CHECK( TCTYPE_set_create_display_value( DispReqCreInTag, "taskID", 1, (const char**)&pcTaskID) );
  
				  char* pcProviderName = NULL;
				  pcProviderName= "SIEMENS" ;
				  ERROR_CHECK( TCTYPE_set_create_display_value( DispReqCreInTag, "providerName", 1, (const char**)&pcProviderName) );
  
				  char* pcServiceName = NULL;
				  pcServiceName= "tozipfile";
				  ERROR_CHECK( TCTYPE_set_create_display_value( DispReqCreInTag, "serviceName", 1, (const char**)&pcServiceName) );

				  ERROR_CHECK( TCTYPE_set_create_display_value( DispReqCreInTag, "primaryObjects", 1, (const char**)&pcDatasetUid ) );
				  ERROR_CHECK( TCTYPE_set_create_display_value( DispReqCreInTag, "secondaryObjects", 1, (const char**)&pcItemRevisionUid ) );
  
				  char* pcPriority = NULL;
				  pcPriority= "3";
				  ERROR_CHECK( TCTYPE_set_create_display_value( DispReqCreInTag, "priority", 1, (const char**)&pcPriority) );
  
				  // CREATE OBJECT
				  ERROR_CHECK( TCTYPE_create_object( DispReqCreInTag, &newDispReqTag) );
				  ERROR_CHECK( AOM_save_without_extensions(newDispReqTag) );
				  ERROR_CHECK( AOM_unlock(newDispReqTag) );



				tag_t request = NULLTAG;

				ITK_CALL(DISPATCHER_create_request("SIEMENS", "catiav5tojt", 3, time(NULL), time(NULL), 0, 1, &secondary_object, &primary_object, 0, NULL, "TRANSLATION", 0, NULL, NULL, &request));

				//int interval = 10;           // Check status after every 10 seconds
				//int wait = 0;                // 0 means wait until complete
				//logical is_complete = false;
				//ITK_CALL(DISPATCHER_wait_for_request(request, interval, wait, &is_complete));
				//if (is_complete) cout << endl << "   Translation is completed!" << endl;

			}
		}
	}
	*/
	return ifail;

}


//-----------------------------------------------------------------------
// Function    : SR5Extension_ITEM_create_rev_PostAction
// Description : Post Action for creation of SR5GenEngObjRevision.                
// Returns     : ifail
//-----------------------------------------------------------------------
// Date            By                       Reason
// 26-Sep-2022	   Johannes Buddeberg		Initial creation
//-----------------------------------------------------------------------
extern USER_EXT_DLL_API int SR5Extension_ITEM_create_rev_PostAction(METHOD_message_t* msg, va_list args)
{		
	// This PostAction writes the attributes Benennung_1 and Benennung_2 according to the split requirement, on Rev creation.
	int ifail = ITK_ok;

	va_list largs;
	va_copy(largs, args);

	tag_t  item = va_arg(args, tag_t);
	char* rev_id = va_arg(args, char*);
	tag_t* new_rev = va_arg(args, tag_t*);
	tag_t  item_rev_master_form = va_arg(args, tag_t);

	va_end(largs);

	sr5SetLocalizedObjectNameItemRev(*new_rev);
	sr5SetLocalizedObjectNameItem(item);

	/*
	std::string rObjName = "";
	char* objname = NULL;
	ITK_CALL(AOM_ask_value_string(*new_rev, "object_name", &objname));
	rObjName = objname;
	if (rObjName.size() > 25)
	{
		std::string first = "";
		std::string second = "";
		std::string sMiddle = "";
		int FirstBorder = 0;
		int SecondBorder = 0;

		if (rObjName.size() > 40)
		{
			rObjName = rObjName.substr(0, 40);
		}

		FirstBorder = rObjName.size() - 25;
		SecondBorder = 50 - rObjName.size();

		sMiddle = rObjName.substr(FirstBorder, SecondBorder);

		std::size_t found = sMiddle.find_last_of(" ");

		if (found != std::string::npos)
		{
			ITK_CALL(AOM_refresh(*new_rev, FALSE));
			first = rObjName.substr(0, FirstBorder + found);

			ITK_CALL(AOM_set_value_string(*new_rev, "sr5CATIAFSFName1", first.c_str()));

			second = rObjName.substr(found + FirstBorder + 1);

			ITK_CALL(AOM_set_value_string(*new_rev, "sr5CATIAFSFName2", second.c_str()));
			ITK_CALL(AOM_save_without_extensions(*new_rev));
			ITK_CALL(AOM_refresh(*new_rev, TRUE));
		}
		else
		{

			ITK_CALL(AOM_refresh(*new_rev, FALSE));
			first = rObjName.substr(0, 25);
			ITK_CALL(AOM_set_value_string(*new_rev, "sr5CATIAFSFName1", first.c_str()));

			second = rObjName.substr(25, 15);
			ITK_CALL(AOM_set_value_string(*new_rev, "sr5CATIAFSFName2", second.c_str()));
			ITK_CALL(AOM_save_without_extensions(*new_rev));
			ITK_CALL(AOM_refresh(*new_rev, TRUE));
		}
	}
	else
	{
		ITK_CALL(AOM_refresh(*new_rev, FALSE));
		ITK_CALL(AOM_set_value_string(*new_rev, "sr5CATIAFSFName1", rObjName.c_str()));
		tag_t myTag = *new_rev;
		ITK_CALL(AOM_save_without_extensions(myTag));
		ITK_CALL(AOM_refresh(*new_rev, TRUE));
	}
	*/
		
	return ifail;
}

/**
 * @brief Set the data entry locale to the current user session W3C locale.
 *
 * @param char* sNewLocale
 *
 * @return Error code.
 */
int sr5UpdateUserDataEntryLanguage(char* sNewLocale) {
	int ifail = ITK_ok;

	char* sPrefName = "TC_language_localized_property_value_entry";

	int iValueCount = 0;
	ITK_CALL(PREF_ask_value_count(sPrefName, &iValueCount));

	if (iValueCount > 0) {
		ITK_CALL(PREF_set_char_values(sPrefName, 1, &sNewLocale));
		ITK_CALL(PREF_refresh(sPrefName));
	}
	else {
		tag_t tCurrentGroupmember = NULLTAG;
		tag_t tCurrentGroup = NULLTAG;
		char* sCurrentGroupName = NULL;

		SA_ask_current_groupmember(&tCurrentGroupmember);
		SA_ask_groupmember_group(tCurrentGroupmember, &tCurrentGroup);
		SA_ask_group_name2(tCurrentGroup, &sCurrentGroupName);

		if (strcmp(sCurrentGroupName, "dba") == 0) {
			PREF_preference_object_t preference_object;
			PREF_preference_definition_t preferenceDefinition;
			PREF_preference_context_values_t contextValue;

			preferenceDefinition.preferenceName = sPrefName;
			preferenceDefinition.preferenceCategory = "Localization";
			preferenceDefinition.preferenceDescription = "Data entry language";
			preferenceDefinition.preferenceScope = TC_preference_user;
			preferenceDefinition.preferenceType = PREF_preference_string;
			preferenceDefinition.isArray = false;
			preferenceDefinition.isDisabled = false;

			contextValue.contextName = "Teamcenter";
			contextValue.numberOfValues = 1;
			contextValue.values = &sNewLocale;

			preference_object.numberOfContexts = 1;
			preference_object.contextValues = &contextValue;
			preference_object.preferenceDefinition = preferenceDefinition;

			ITK_CALL(PREF_set_definition(sPrefName, preference_object, false));
			ITK_CALL(PREF_refresh(sPrefName));
		}

		SAFE_SM_FREE(sCurrentGroupName);
	}

	return ifail;
}


/**
@brief In case of manual creation of a MPart (e.g. Pre-Assembly), the system shall automatically create an EPart, set it to "20" and link it to the newly created MPart

@param METHOD_message_t* msg
@param va_list args

@return Error code
*/
extern USER_EXT_DLL_API int SR5Extension_SR5MfgObject_create_PostAction(METHOD_message_t* msg, va_list args)
{
	int ifail = ITK_ok;

	va_list largs;
	va_copy(largs, args);

	char*	item_id = va_arg(args, char*);
	char*	item_name = va_arg(args, char*);
	char*	type_name = va_arg(args, char*);
	char*	rev_id = va_arg(args, char*);
	tag_t	*new_item = va_arg(args, tag_t*);
	tag_t	*new_rev = va_arg(args, tag_t*);

	va_end(largs);

	// Is M-Part
	if (tc_strcmp(type_name, SR5_TYPE_SR5MfgObject) == 0) {
		vector<tag_t> vecTmpObjects;
		logical lEPartExists = false;
		
		// Find existing E-Part
		sr5QryAttr_STRING("Item", "item_id", item_id, &vecTmpObjects);
		for (int i = 0; i < vecTmpObjects.size(); i++) {
			std::string strTmpType = "";
			sr5ReadAttrValue_STRING(vecTmpObjects.at(i), SR5_TYPE_WorkspaceObject, "object_type", &strTmpType);
			if (strTmpType.compare(SR5_TYPE_SR5EngArticle) == 0) {
				lEPartExists = true;

				break;
			}
		}

		// Create new E-Part
		if (lEPartExists == false) {
			tag_t tEItem = NULLTAG;
			tag_t tTmpLatestEPartRev = NULLTAG;

			createEPart(SR5_TYPE_SR5EngArticle, SR5_TYPE_SR5EngArticleRevision, item_id, item_name, &tEItem);
			if (tEItem != NULLTAG) {
				tag_t tStatus20 = NULLTAG;

				ITK_CALL(ITEM_ask_latest_rev(tEItem, &tTmpLatestEPartRev));
				ITK_CALL(RELSTAT_create_release_status(RELSTAT_20, &tStatus20));
				ITK_CALL(RELSTAT_add_release_status(tStatus20, 1, &tTmpLatestEPartRev, false));
				createRelation(*new_rev, tTmpLatestEPartRev, REL_TYPE_TC_Is_Represented_By_rtype, "");
			}
		}
	}

	return ifail;
}
/**
@brief Extension to automatically also revise the other part if the part to revise is a mirror part (original or mirrored part).

@param METHOD_message_t* msg, va_list args

@return Error code
*/
extern DLLAPI int SR5Extension_SR5EngArticleRevision_ITEM_copy_rev_PostAction(METHOD_message_t* m, va_list args)
{

	int ifail = ITK_ok;

	va_list largs;
	va_copy(largs, args);

	tag_t  source_rev = va_arg(largs, tag_t);
	char* rev_id = va_arg(largs, char*);
	tag_t* new_rev = va_arg(largs, tag_t*);
	tag_t  item_rev_master_form = va_arg(largs, tag_t);

	va_end(largs);
	/*
	logical	lHasBypass = false;

	// Set bypass
	ITK_CALL(ITK_ask_bypass(&lHasBypass));
	AM__set_application_bypass(true);


	tag_t NewRev = *new_rev;
	char* newRevID = "";
	char* ItemID = "";
	AOM_ask_value_string(NewRev, "item_revision_id", &newRevID);
	AOM_ask_value_string(NewRev, "item_id", &ItemID);

	std::string ObjType = "";
	std::string currRevID = "";
	sr5ReadAttrValue_STRING(source_rev, "WorkspaceObject", "object_type", &ObjType);
	sr5ReadAttrValue_STRING(source_rev, "ItemRevision", "item_revision_id", &currRevID);
	char* className = NULL;
	tag_t tType = NULLTAG;

	//revise also mirrored or original part

	if (ObjType.compare(SR5_TYPE_SR5EngArticleRevision) == 0)
	{
		

		if (source_rev != NULLTAG)
		{

			tag_t relTypeCATIAV5_DWGLink = NULLTAG;
			GRM_find_relation_type("catiaV5_DWGLink", &relTypeCATIAV5_DWGLink);

			//original part with drawing
			vector<tag_t> vecSecondary;
			sr5AskSecondaryObjects(source_rev, TC_specification_rtype, "CATDrawing", &vecSecondary);
			if (vecSecondary.size() > 0)
			{
				int secObj = 0;
				tag_t* tSecObjects = NULL;
				GRM_list_secondary_objects_only(vecSecondary[0], relTypeCATIAV5_DWGLink, &secObj, &tSecObjects);

				if (secObj > 0)
				{

					logical allArticles = true;
					for (int i = 0;i < secObj;i++)
					{

						char* secObjType = "";
						AOM_ask_value_string(tSecObjects[i], "object_type", &secObjType);
						if (tc_strcmp(secObjType, SR5_TYPE_SR5EngArticleRevision) != 0)
						{
							allArticles = false;
						}
					}
					if (allArticles)
					{
						for (int l = 0;l < secObj;l++)
						{
							if (tSecObjects[l] != source_rev)
							{
								char* itemRevID = NULL;
								AOM_ask_value_string(tSecObjects[l], "item_revision_id", &itemRevID);
								char* ItemID = NULL;
								AOM_ask_value_string(tSecObjects[l], "item_id", &ItemID);
								char* objName = NULL;
								AOM_ask_value_string(tSecObjects[l], "object_name", &objName);
								if (tc_strcmp(itemRevID, newRevID) != 0)
								{
									tag_t newCreatedRev = NULLTAG;
									ITEM_copy_rev(tSecObjects[l], newRevID, &newCreatedRev);
									//ITK_CALL(ITEM_save_rev(newCreatedRev));
								}
							}
						}

					}
				}

			}

			//mirrored Part

			int iPrimObj = 0;
			tag_t* tPrimObjects = NULL;
			GRM_list_primary_objects_only(source_rev, relTypeCATIAV5_DWGLink, &iPrimObj, &tPrimObjects);

			if (iPrimObj > 0 && iPrimObj == 1)
			{

				//for (int k = 0;k < iPrimObj;k++)
				//{
				char* dstType = "";
				AOM_ask_value_string(tPrimObjects[0], "object_type", &dstType);
				if (tc_strcmp(dstType, "CATDrawing") == 0)
				{
					int secObj2 = 0;
					tag_t* tSecObjects2 = NULL;
					GRM_list_secondary_objects_only(tPrimObjects[0], relTypeCATIAV5_DWGLink, &secObj2, &tSecObjects2);

					logical allArticles = true;
					for (int l = 0;l < secObj2;l++)
					{
						char* secObjType = "";
						AOM_ask_value_string(tSecObjects2[l], "object_type", &secObjType);
						if (tc_strcmp(secObjType, SR5_TYPE_SR5EngArticleRevision) != 0)
						{
							allArticles = false;
						}
					}
					if (allArticles)
					{
						for (int l = 0;l < secObj2;l++)
						{
							char* objName = NULL;
							char* revID = NULL;
							AOM_ask_value_string(tSecObjects2[l], "object_name", &objName);
							AOM_ask_value_string(tSecObjects2[l], "item_revision_id", &revID);
							if (tSecObjects2[l] != source_rev)
							{
								char* itemRevID = "";
								AOM_ask_value_string(tSecObjects2[l], "item_revision_id", &itemRevID);
								if (tc_strcmp(itemRevID, newRevID) != 0)
								{
									tag_t newCreatedRev = NULLTAG;
									ITEM_copy_rev(tSecObjects2[l], newRevID, &newCreatedRev);
									//ITK_CALL(ITEM_save_rev(newCreatedRev));
								}
							}
						}
					}
				}

			}

		}

	}
	*/

	return ifail;
}

/**
 * @brief Localize the object name of Item and ItemRevision based on selected terms.
 * 
 * @param METHOD_message_t* msg, va_list args
 * @return Error code
 */
extern USER_EXT_DLL_API int SR5Extension_sr5ObjectNameTerm_PROP_PostAction(METHOD_message_t* msg, va_list args) {
	int iStat{ ITK_ok };
	va_list largs{ "" };
	va_copy(largs, args);
	tag_t			propTag{ va_arg(args, tag_t) };
	char* sUserValue{ va_arg(args, char*) };
	const char* sPropName{ msg->prop_name };
	tag_t			tObject{ msg->object_tag };
	va_end(largs);
	sr5SetLocalizedObjectNameItemRev(tObject);
	tag_t tItem{ NULLTAG };
	ITK_CALL(ITEM_ask_item_of_rev(tObject, &tItem));
	sr5SetLocalizedObjectNameItem(tItem);
	return iStat;
}

/**
 * @brief PostAction  trigger weight calculation if a new IMM Material is attached
 *
 * @param METHOD_message_t* msg, va_list args
 *
 * @return Error code.
 */
extern USER_EXT_DLL_API int SR5Extension_IMAN_Save_Mat1UsesMaterial_PostAction(METHOD_message_t* msg, va_list args)
{
	int ifail = ITK_ok;
	/**** va_list for IMAN_save_msg ***/
	va_list largs;
	va_copy(largs, args);
	tag_t  object_tag = va_arg(largs, tag_t);
	logical  isNew = va_arg(largs, logical);
	va_end(largs);

	tag_t primObject = NULLTAG;

	ITK_CALL(AOM_ask_value_tag(object_tag, "primary_object", &primObject));


	std::vector<tag_t> vecCATParts;
	sr5AskSecondaryObjects(primObject, REL_TYPE_IMAN_specification, "CATPart", &vecCATParts);
	if (vecCATParts.size() > 0)
	{
		tag_t Mat1UsesMaterialType = NULLTAG;
		ITK_CALL(GRM_find_relation_type("Mat1UsesMaterial", &Mat1UsesMaterialType));

		double totalMassinKG = 0.0;
		std::vector<tag_t> vecMaterials;
		sr5AskSecondaryObjects(primObject, "Mat1UsesMaterial", "Mat1MaterialRevision", &vecMaterials);
		for (int i = 0; i < vecMaterials.size(); i++) {
			tag_t tRel = NULLTAG;

			double mat1mass = 0.0;
			ITK_CALL(GRM_find_relation(primObject, vecMaterials[i], Mat1UsesMaterialType, &tRel));
			ITK_CALL(AOM_ask_value_double(tRel, "mat1mass_in_grams", &mat1mass));
			tag_t primObject = NULLTAG;

			totalMassinKG += mat1mass / 1000;

		}

		double adjTotalWeight = 0.0;
		ITK_CALL(AOM_ask_value_double(primObject, "sr5AdjustedWeight", &adjTotalWeight));
		double adjCalcWeight = 0.0;
		ITK_CALL(AOM_ask_value_double(primObject, "sr5CalculatedWeight", &adjCalcWeight));



		ITK_CALL(AOM_refresh(primObject, TRUE));
		ITK_CALL(AOM_set_value_double(primObject, "sr5CalculatedWeight", totalMassinKG));
		if (adjTotalWeight == adjCalcWeight)
		{
			ITK_CALL(AOM_set_value_double(primObject, "sr5AdjustedWeight", totalMassinKG));
		}
		ITK_CALL(AOM_save_without_extensions(primObject));
		ITK_CALL(AOM_refresh(primObject, FALSE));
		ITK_CALL(AOM_unlock(primObject));
	}

	return ifail;

}


/* Global Variables */
tag_t primary_object;
tag_t secondary_object;

/**
 * @brief PostAction to write primary and secondary objects of Mat1UsesMaterial relation if material attachment is removed, to trigger calculation again with SR5Extension_IMAN_Delete_Mat1UsesMaterial_PostAction
 *
 * @param METHOD_message_t* msg, va_list args
 *
 * @return Error code.
 */
int SR5Extension_IMAN_Delete_Mat1UsesMaterial_PreAction(METHOD_message_t* /*msg*/, va_list args)
{
	int ifail = ITK_ok;

	va_list largs;
	va_copy(largs, args);
	tag_t relation = va_arg(largs, tag_t);
	va_end(largs);

	ITK_CALL(GRM_ask_primary(relation, &primary_object));
	ITK_CALL(GRM_ask_secondary(relation, &secondary_object));

	return ifail;
}


/**
 * @brief PostAction to trigger weight calculation on part again if a material attachment is removed.
 *
 * @param METHOD_message_t* msg, va_list args
 *
 * @return Error code.
 */
extern USER_EXT_DLL_API int SR5Extension_IMAN_Delete_Mat1UsesMaterial_PostAction(METHOD_message_t * msg, va_list args)
{
	int ifail = ITK_ok;
	/**** va_list for IMAN_delete_msg ***/
	va_list largs;
	va_copy(largs, args);
	tag_t  object_tag = va_arg(largs, tag_t);
	va_end(largs);


	


	std::vector<tag_t> vecCATParts;
	sr5AskSecondaryObjects(primary_object, REL_TYPE_IMAN_specification, "CATPart", &vecCATParts);

	tag_t* viewChildren = NULL;
	int nChildren = 0;
	ITK_CALL(AOM_ask_value_tags(primary_object, "view", &nChildren, &viewChildren));
	if (vecCATParts.size() > 0 || nChildren == 0)
	{
		tag_t Mat1UsesMaterialType = NULLTAG;
		ITK_CALL(GRM_find_relation_type("Mat1UsesMaterial", &Mat1UsesMaterialType));

		double totalMassinKG = 0.0;
		std::vector<tag_t> vecMaterials;
		sr5AskSecondaryObjects(primary_object, "Mat1UsesMaterial", "Mat1MaterialRevision", &vecMaterials);
		for (int i = 0; i < vecMaterials.size(); i++) {
			tag_t tRel = NULLTAG;

			double mat1mass = 0.0;
			ITK_CALL(GRM_find_relation(primary_object, vecMaterials[i], Mat1UsesMaterialType, &tRel));
			ITK_CALL(AOM_ask_value_double(tRel, "mat1mass_in_grams", &mat1mass));
			tag_t primObject = NULLTAG;

			totalMassinKG += mat1mass / 1000;

		}

		double adjTotalWeight = 0.0;
		ITK_CALL(AOM_ask_value_double(primary_object, "sr5AdjustedWeight", &adjTotalWeight));
		double adjCalcWeight = 0.0;
		ITK_CALL(AOM_ask_value_double(primary_object, "sr5CalculatedWeight", &adjCalcWeight));



		ITK_CALL(AOM_refresh(primary_object, TRUE));
		ITK_CALL(AOM_set_value_double(primary_object, "sr5CalculatedWeight", totalMassinKG));
		if (adjTotalWeight == adjCalcWeight)
		{
			ITK_CALL(AOM_set_value_double(primary_object, "sr5AdjustedWeight", totalMassinKG));
		}
		ITK_CALL(AOM_save_without_extensions(primary_object));
		ITK_CALL(AOM_refresh(primary_object, FALSE));
		ITK_CALL(AOM_unlock(primary_object));
	}
	else
	{

		double adjTotalWeight = 0.0;
		ITK_CALL(AOM_ask_value_double(primary_object, "sr5AdjustedWeight", &adjTotalWeight));
		double adjCalcWeight = 0.0;
		ITK_CALL(AOM_ask_value_double(primary_object, "sr5CalculatedWeight", &adjCalcWeight));

		ITK_CALL(AOM_refresh(primary_object, TRUE));
		ITK_CALL(AOM_set_value_double(primary_object, "sr5CalculatedWeight", 0.0));
		if (adjTotalWeight == adjCalcWeight)
		{
			ITK_CALL(AOM_set_value_double(primary_object, "sr5AdjustedWeight", 0.0));
		}
		ITK_CALL(AOM_save_without_extensions(primary_object));
		ITK_CALL(AOM_refresh(primary_object, FALSE));
		ITK_CALL(AOM_unlock(primary_object));

	}

	return ifail;
}




/**
 * @brief Perform PostAction on revise of Engineering Installation to also revise attached Engineering Environments
 *
 * @param METHOD_message_t* msg, va_list args
 *
 * @return Error code.
 */
extern USER_EXT_DLL_API int SR5Extension_SR5EngInstallLocRev_ITEM_copy_rev_PostAction(METHOD_message_t* msg, va_list args)
{
	int ifail = ITK_ok;

	va_list largs;
	va_copy(largs, args);

	tag_t  source_rev = va_arg(largs, tag_t);
	char* rev_id = va_arg(largs, char*);
	tag_t* new_rev = va_arg(largs, tag_t*);
	tag_t  item_rev_master_form = va_arg(largs, tag_t);

	va_end(largs);

	vector<tag_t> vecEngEnvironments;
	sr5AskSecondaryObjects(source_rev, REL_TYPE_SR5HasEngEnvironment,"SR5EngEnv",&vecEngEnvironments);


	for (int i = 0; i < vecEngEnvironments.size(); i++) 
	{
		tag_t latestRev = NULLTAG;
		ITK_CALL(ITEM_ask_latest_rev(vecEngEnvironments[i], &latestRev));

		logical lHasStatus30 = false;
		logical lHasStatus40 = false;
		logical lHasStatus50 = false;

		if (!lHasStatus30 && !lHasStatus40 && !lHasStatus50) sr5HasStatus(latestRev, RELSTAT_30, &lHasStatus30);
		if (!lHasStatus30 && !lHasStatus40 && !lHasStatus50) sr5HasStatus(latestRev, RELSTAT_40, &lHasStatus40);
		if (!lHasStatus30 && !lHasStatus40 && !lHasStatus50) sr5HasStatus(latestRev, RELSTAT_50, &lHasStatus50);

		if (!lHasStatus30 && !lHasStatus40 && !lHasStatus50) {
			continue;
		}
		else
		{

			char* itemRevID = NULL;
			ITK_CALL(AOM_ask_value_string(latestRev, "item_revision_id", &itemRevID));
			char* ItemID = NULL;
			ITK_CALL(AOM_ask_value_string(latestRev, "item_id", &ItemID));
			char* objName = NULL;
			ITK_CALL(AOM_ask_value_string(latestRev, "object_name", &objName));
				
			//Create new revision for EngEnv
			tag_t newCreatedEngEnvRev = NULLTAG;
			ITK_CALL(ITEM_copy_rev(latestRev, NULL, &newCreatedEngEnvRev));
			ITK_CALL(ITEM_save_rev(newCreatedEngEnvRev));

			//Set old revision to status 70

			tag_t tStatus70 = NULLTAG;
			ITK_CALL(RELSTAT_create_release_status(RELSTAT_70, &tStatus70));
			ITK_CALL(RELSTAT_add_release_status(tStatus70, 1, &latestRev, false));


		}

	}

	return ifail;
}




/**
 * @brief Perform PostAction on CATIA reference save to delete QChecker result if the peart is not yet released
 *
 * @param METHOD_message_t* msg, va_list args
 *
 * @return Error code.
 */
extern USER_EXT_DLL_API int SR5Extension_QChecker_Save_PostAction(METHOD_message_t* msg, va_list args)
{
	int ifail = ITK_ok;

	va_list largs;
	va_copy(largs, args);
	tag_t  object_tag = va_arg(largs, tag_t);
	logical  isNew = va_arg(largs, logical);
	va_end(largs);

	/*
	
	if (object_tag != NULLTAG) {

		vector<tag_t> primObjects;
		sr5AskPrimaryObjects2(object_tag, REL_TYPE_IMAN_specification, &primObjects);

		if (primObjects.size() != 0)
		{
			for (int i = 0;i < primObjects.size();i++)
			{

				logical isDerivedEngObj = false;
				isDerivedEngObj = sr5IsDerivedFromClass(primObjects[i], SR5_TYPE_SR5GenEngObjRevision);


				if (isDerivedEngObj) {
					std::string strChildObjectType;
					char* objType = NULL;
					char* ReleaseDate = NULL;
					WSOM_ask_object_type2(primObjects[i],&objType);
					AOM_ask_value_string(primObjects[i], "sr5CPEngineeringReleaseDate", &ReleaseDate);

					if (tc_strcmp(ReleaseDate,"")==0) {

						std::string sDatasetName = "";
						AOM_set_value_string(object_tag, "sr5QCheckEvaluation", "KO");

						ITK_CALL(AOM_save_without_extensions(object_tag));
						ITK_CALL(AOM_refresh(object_tag, false));
						break;
					}
				}
			}
		}
	}
	
	*/
	return ifail;

}