#include "sr5_register_callbacks.h"


//-----------------------------------------------------------------------
// Function    : sr5AltRepList
// Description : 
//

// Returns     : The tag array of mbom revisions.
//-----------------------------------------------------------------------
// Written by   
// Changes :    
// Date        By      Reason
//-----------------------------------------------------------------------

int sr5AltRepList( METHOD_message_t *msg, va_list args)
{
	int iStat = ITK_ok;

	tag_t propTag = va_arg(args, tag_t);    // Run-time parameter
	int *returnCount = va_arg(args, int*); // Run-time parameter
	tag_t **returnValue = va_arg(args, tag_t**); // Run-time parameter

	tag_t tArticle = NULLTAG;

	METHOD_PROP_MESSAGE_OBJECT(msg, tArticle);
	if (tArticle != NULLTAG) {
		std::string sItemID = "";
		std::vector<tag_t> vecSearchResults;
		std::vector<tag_t> vecAltReps;

		sr5ReadAttrValue_STRING(tArticle, SR5_TYPE_Item, "item_id", &sItemID);
		if (sItemID.empty() == false) {
			sr5QryAttr_STRING(SR5_TYPE_Item, "item_id", sItemID.c_str(), &vecSearchResults);
			if (vecSearchResults.size() > 0) {

				std::string sOwnObjectType = "";
				sr5ReadAttrValue_STRING(tArticle, SR5_TYPE_WorkspaceObject, "object_type", &sOwnObjectType);

				for (int i = 0; i < vecSearchResults.size(); i++) {
					if (tArticle == vecSearchResults.at(i)) continue;

					std::string sObjectType = "";
					sr5ReadAttrValue_STRING(vecSearchResults.at(i), SR5_TYPE_WorkspaceObject, "object_type", &sObjectType);
					if (sOwnObjectType.compare(SR5_TYPE_SR5EngArticle) == 0 || sOwnObjectType.compare(SR5_TYPE_SR5EngArticleAR) == 0) {
						if (sObjectType.compare(SR5_TYPE_SR5EngArticle) == 0 || sObjectType.compare(SR5_TYPE_SR5EngArticleAR) == 0) {
							tag_t tTmpLatestRev = NULLTAG;
							ITK_CALL(ITEM_ask_latest_rev(vecSearchResults.at(i), &tTmpLatestRev));
							vecAltReps.push_back(tTmpLatestRev);
						}
					}
					else if (sOwnObjectType.compare(SR5_TYPE_SR5CatDefArticle) == 0 || sOwnObjectType.compare(SR5_TYPE_SR5CatDefArtAR) == 0) {
						if (sObjectType.compare(SR5_TYPE_SR5CatDefArticle) == 0 || sObjectType.compare(SR5_TYPE_SR5CatDefArtAR) == 0) {
							tag_t tTmpLatestRev = NULLTAG;
							ITK_CALL(ITEM_ask_latest_rev(vecSearchResults.at(i), &tTmpLatestRev));
							vecAltReps.push_back(tTmpLatestRev);
						}
					}
					else if (sOwnObjectType.compare(SR5_TYPE_SR5GenCatPart) == 0 || sOwnObjectType.compare(SR5_TYPE_SR5GenCatPartAR) == 0) {
						if (sObjectType.compare(SR5_TYPE_SR5GenCatPart) == 0 || sObjectType.compare(SR5_TYPE_SR5GenCatPartAR) == 0) {
							tag_t tTmpLatestRev = NULLTAG;
							ITK_CALL(ITEM_ask_latest_rev(vecSearchResults.at(i), &tTmpLatestRev));
							vecAltReps.push_back(tTmpLatestRev);
						}
					}
				}
			}
		}

		*returnValue = (tag_t*)MEM_alloc(vecAltReps.size() * sizeof(tag_t));
		*returnCount = vecAltReps.size();

		for (int i = 0; i < vecAltReps.size(); i++) {
			(*returnValue)[i] = vecAltReps.at(i);
		}
	}

	return iStat;
}

int sr5ItemIdAltRepCounter(METHOD_message_t* msg, va_list args)
{
	int iStat = ITK_ok;

	tag_t propTag = va_arg(args, tag_t);    // Run-time parameter
	char** returnValue = va_arg(args, char**); // Run-time parameter
	*returnValue = NULL;

	tag_t tArticle = NULLTAG;

	METHOD_PROP_MESSAGE_OBJECT(msg, tArticle);
	if (tArticle != NULLTAG) {
		std::string sItemID = "";
		std::string sAltRepCounter = "";

		sr5ReadAttrValue_STRING(tArticle, SR5_TYPE_Item, "item_id", &sItemID);
		sr5ReadAttrValue_STRING(tArticle, SR5_TYPE_SR5GenEngObj, "sr5AltRepCounter", &sAltRepCounter);

		std::stringstream ssItemIdAltRepCounter;
		ssItemIdAltRepCounter << sItemID << "_" << sAltRepCounter;

		(*returnValue) = (char*)MEM_alloc((tc_strlen(ssItemIdAltRepCounter.str().c_str()) + 1));
		tc_strcpy(*returnValue, ssItemIdAltRepCounter.str().c_str());
	}

	return iStat;
}


int sr5CATIAReferencedBy(METHOD_message_t* msg, va_list args)
{
	//---------------------------------------------------------------------------------------------------------------------------------------
	//Returns the Article Revisions of all CATIA datasets which point to the CATIA datasets of this part  (This)<-(x)
	//---------------------------------------------------------------------------------------------------------------------------------------
	int iStat = ITK_ok;

	tag_t propTag = va_arg(args, tag_t);			// Run-time parameter
	int* returnCount = va_arg(args, int*);			// Run-time parameter
	tag_t** returnValue = va_arg(args, tag_t**);	// Run-time parameter

	tag_t tArticle = NULLTAG;

	METHOD_PROP_MESSAGE_OBJECT(msg, tArticle);
	if (tArticle != NULLTAG) {


		std::vector<tag_t> vecDatasets;
		std::vector<tag_t> vecResults;
		
		sr5AskPrimaryObjects(tArticle, "catiaV5_MML", "CATPart"	, &vecDatasets);
		sr5AskPrimaryObjects(tArticle, "catiaV5_MMLAssy", "CATPart"	, &vecDatasets);
		sr5AskPrimaryObjects(tArticle, "catiaV5_MML", "CATProduct", &vecDatasets);
		sr5AskPrimaryObjects(tArticle, "catiaV5_MMLAssy", "CATProduct"	, &vecDatasets);
		sr5AskPrimaryObjects(tArticle, "catiaV5_DWGLink", "CATDrawing"	, &vecDatasets);
	
		for (int j = 0; j < vecDatasets.size(); j++) {

			sr5AskPrimaryObjects(vecDatasets[j], REL_TYPE_IMAN_specification, SR5_TYPE_SR5EngArticleRevision,		&vecResults);
			sr5AskPrimaryObjects(vecDatasets[j], REL_TYPE_IMAN_specification, SR5_TYPE_SR5EngArticleARRevision,	&vecResults);
			sr5AskPrimaryObjects(vecDatasets[j], REL_TYPE_IMAN_specification, SR5_TYPE_SR5NonERPArticleRevision,	&vecResults);
			sr5AskPrimaryObjects(vecDatasets[j], REL_TYPE_IMAN_specification, SR5_TYPE_SR5CatDefArticleRevision,	&vecResults);
			sr5AskPrimaryObjects(vecDatasets[j], REL_TYPE_IMAN_specification, SR5_TYPE_SR5CatDefArtARRevision,		&vecResults);
			sr5AskPrimaryObjects(vecDatasets[j], REL_TYPE_IMAN_specification, SR5_TYPE_SR5GenCatPartRevision,		&vecResults);
			sr5AskPrimaryObjects(vecDatasets[j], REL_TYPE_IMAN_specification, SR5_TYPE_SR5GenCatPartARRevision,	&vecResults);


		}

		std::vector<tag_t> vecCheckedResults;
		for (int l = 0; l < vecResults.size(); l++) {

			bool exists = false;
			for (int k = 0; k < vecCheckedResults.size(); k++) {
				if (vecResults[l] == vecCheckedResults[k]) {
					exists = true;
					break;
				}
			}
			if(!exists) {
				if (vecResults[l] != tArticle)
				{
					vecCheckedResults.push_back(vecResults[l]);
				}
			}
		}

		*returnValue = (tag_t*)MEM_alloc(vecCheckedResults.size() * sizeof(tag_t));
		*returnCount = vecCheckedResults.size();


		for (int m = 0; m < vecCheckedResults.size(); m++) {
			(*returnValue)[m] = vecCheckedResults.at(m);
		}
	}

	return iStat;
}


int sr5CATIAReferenceTo(METHOD_message_t* msg, va_list args)
{
	//-------------------------------------------------------------------------------------------------------------------
	//Returns the Article Revisions of all CATIA datasets to which the CATIA datasets of this part point to (x)<-(This)
	//-------------------------------------------------------------------------------------------------------------------

	int iStat = ITK_ok;

	tag_t propTag = va_arg(args, tag_t);			// Run-time parameter
	int* returnCount = va_arg(args, int*);			// Run-time parameter
	tag_t** returnValue = va_arg(args, tag_t**);	// Run-time parameter

	tag_t tArticle = NULLTAG;

	METHOD_PROP_MESSAGE_OBJECT(msg, tArticle);
	if (tArticle != NULLTAG) {


		std::vector<tag_t> vecDatasets;
		sr5AskSecondaryObjects(tArticle, REL_TYPE_IMAN_specification, "CATPart", &vecDatasets);
		sr5AskSecondaryObjects(tArticle, REL_TYPE_IMAN_specification, "CATProduct", &vecDatasets);
		sr5AskSecondaryObjects(tArticle, REL_TYPE_IMAN_specification, "CATDrawing", &vecDatasets);

		std::vector<tag_t> vecResults;
		for (int j = 0; j < vecDatasets.size(); j++) {

			tag_t tDataset = vecDatasets[j];

			tag_t objType = NULLTAG;
			char* typeName = NULL;
			ITK_CALL(TCTYPE_ask_object_type(tDataset, &objType));
			ITK_CALL(TCTYPE_ask_name2(objType, &typeName));

			if (tc_strcmp(typeName, "CATPart") == 0 || tc_strcmp(typeName, "CATProduct") == 0) {
				sr5AskSecondaryObjects(tDataset, "catiaV5_MML", SR5_TYPE_SR5EngArticleRevision,		&vecResults);
				sr5AskSecondaryObjects(tDataset, "catiaV5_MML", SR5_TYPE_SR5EngArticleARRevision,	&vecResults);
				sr5AskSecondaryObjects(tDataset, "catiaV5_MML", SR5_TYPE_SR5NonERPArticleRevision,	&vecResults);
				sr5AskSecondaryObjects(tDataset, "catiaV5_MML", SR5_TYPE_SR5CatDefArticleRevision,	&vecResults);
				sr5AskSecondaryObjects(tDataset, "catiaV5_MML", SR5_TYPE_SR5CatDefArtARRevision,	&vecResults);
				sr5AskSecondaryObjects(tDataset, "catiaV5_MML", SR5_TYPE_SR5GenCatPartRevision,		&vecResults);
				sr5AskSecondaryObjects(tDataset, "catiaV5_MML", SR5_TYPE_SR5GenCatPartARRevision,	&vecResults);

				sr5AskSecondaryObjects(tDataset, "catiaV5_MMLAssy", SR5_TYPE_SR5EngArticleRevision,		&vecResults);
				sr5AskSecondaryObjects(tDataset, "catiaV5_MMLAssy", SR5_TYPE_SR5EngArticleARRevision,	&vecResults);
				sr5AskSecondaryObjects(tDataset, "catiaV5_MMLAssy", SR5_TYPE_SR5NonERPArticleRevision,	&vecResults);
				sr5AskSecondaryObjects(tDataset, "catiaV5_MMLAssy", SR5_TYPE_SR5CatDefArticleRevision,	&vecResults);
				sr5AskSecondaryObjects(tDataset, "catiaV5_MMLAssy", SR5_TYPE_SR5CatDefArtARRevision,	&vecResults);
				sr5AskSecondaryObjects(tDataset, "catiaV5_MMLAssy", SR5_TYPE_SR5GenCatPartRevision,		&vecResults);
				sr5AskSecondaryObjects(tDataset, "catiaV5_MMLAssy", SR5_TYPE_SR5GenCatPartARRevision,	&vecResults);
			}

			if (tc_strcmp(typeName, "CATDrawing") == 0) {

				sr5AskSecondaryObjects(tDataset, "catiaV5_DWGLink", SR5_TYPE_SR5EngArticleRevision,		&vecResults);
				sr5AskSecondaryObjects(tDataset, "catiaV5_DWGLink", SR5_TYPE_SR5EngArticleARRevision,	&vecResults);
				sr5AskSecondaryObjects(tDataset, "catiaV5_DWGLink", SR5_TYPE_SR5NonERPArticleRevision,	&vecResults);
				sr5AskSecondaryObjects(tDataset, "catiaV5_DWGLink", SR5_TYPE_SR5CatDefArticleRevision,	&vecResults);
				sr5AskSecondaryObjects(tDataset, "catiaV5_DWGLink", SR5_TYPE_SR5CatDefArtARRevision,	&vecResults);
				sr5AskSecondaryObjects(tDataset, "catiaV5_DWGLink", SR5_TYPE_SR5GenCatPartRevision,		&vecResults);
				sr5AskSecondaryObjects(tDataset, "catiaV5_DWGLink", SR5_TYPE_SR5GenCatPartARRevision,	&vecResults);
			}
		}

		std::vector<tag_t> vecCheckedResults;
		for (int l = 0; l < vecResults.size(); l++) {

			bool exists = false;
			for (int k = 0; k < vecCheckedResults.size(); k++) {
				if (vecResults[l] == vecCheckedResults[k]) {
					exists = true;
					break;
				}
			}
			if (!exists) {
				if(vecResults[l]!=tArticle)
				{
					vecCheckedResults.push_back(vecResults[l]);
				}
			}
		}

		*returnValue = (tag_t*)MEM_alloc(vecCheckedResults.size() * sizeof(tag_t));
		*returnCount = vecCheckedResults.size();


		for (int m = 0; m < vecCheckedResults.size(); m++) {
			(*returnValue)[m] = vecCheckedResults.at(m);
		}
	}

	return iStat;
}




int sr5MaterialNorm(METHOD_message_t* msg, va_list args)
{
	//-------------------------------------------------------------------------------------------------------------------
	//Returns the Material Norm which is defined on the Parameter (string) with name MaterialNorm
	//-------------------------------------------------------------------------------------------------------------------
	int iStat = ITK_ok;

	tag_t propTag = va_arg(args, tag_t);    // Run-time parameter
	char** returnValue = va_arg(args, char**); // Run-time parameter
	*returnValue = NULL;

	tag_t tArticle = NULLTAG;

	METHOD_PROP_MESSAGE_OBJECT(msg, tArticle);
	if (tArticle != NULLTAG) {

		int numParams = 0;
		tag_t* Params = NULL;
		ITK_CALL(AOM_ask_value_tags(tArticle,"mat1Parameters",&numParams ,&Params));

		char* value = NULL;

		for (int i = 0; i < numParams;i++) {
			char* ParamRealName = NULL;
			ITK_CALL(AOM_ask_value_string(Params[i],"mat1RealName",&ParamRealName));
			if(tc_strcmp(ParamRealName,"MaterialNorm")==0 ) {
				ITK_CALL(AOM_ask_value_string(Params[i], "mat1Value", &value));
				break;
			}
		}

		(*returnValue) = (char*)MEM_alloc((tc_strlen(value) + 1));
		tc_strcpy(*returnValue, value);

	}

	return iStat;
}

//int sr5WeightInKG(METHOD_message_t* msg, va_list args)
//{
//	//-------------------------------------------------------------------------------------------------------------------
//	//Returns the Material Norm which is defined on the Parameter (string) with name MaterialNorm
//	//-------------------------------------------------------------------------------------------------------------------
//	int iStat = ITK_ok;
//
//	tag_t propTag = va_arg(args, tag_t);    // Run-time parameter
//	double* returnValue = va_arg(args, double*); // Run-time parameter
//	*returnValue = NULL;
//
//	tag_t tArticle = NULLTAG;
//
//	METHOD_PROP_MESSAGE_OBJECT(msg, tArticle);
//
//
//
//	if (tArticle != NULLTAG) {
//
//		//int numParams = 0;
//		//tag_t* Params = NULL;
//
//		//Get Material Assignment of TopLine
//		double massValueInGrams = NULL;
//		ITK_CALL(AOM_ask_value_double(tArticle, "mat1CumulativeMaterialsMass", &massValueInGrams));
//
//		double massValueInKG = massValueInGrams / 1000.0;
//
//		//check if topline has Children
//		tag_t* viewChildren = NULL;
//		int nChildren = NULL;
//		ITK_CALL(AOM_ask_value_tags(tArticle,"view",&nChildren, &viewChildren));
//
//		if (nChildren > 0)
//		{
//			//create BOM Window for whole structure
//			tag_t itemTag = NULLTAG;
//			//
//			ITK_CALL(ITEM_ask_item_of_rev(tArticle, &itemTag));
//			tag_t window = NULL;
//			tag_t rule = NULLTAG;
//			tag_t topline = NULLTAG;
//			ITK_CALL(BOM_create_window(&window));
//			ITK_CALL(BOM_set_window_top_line(window, itemTag, tArticle, NULLTAG, &topline));
//			ITK_CALL(CFM_find(SR5_REVRULE_LatestWorking, &rule));
//			ITK_CALL(BOM_set_window_config_rule(window, rule));
//			ITK_CALL(BOM_window_hide_unconfigured(window));
//
//			//get sub Material weights
//			massValueInKG += get_sublevel_weight(topline, SR5_REVRULE_LatestWorking);
//		}
//		*returnValue = massValueInKG;
//	}
//	return iStat;
//}

int sr5FullDimension(METHOD_message_t* msg, va_list args)
{
	//-------------------------------------------------------------------------------------------------------------------
	//Returns the Full Dimension value, concatenated from the value on the CatDefArticle in the BOM and the dimension value on the own object.
	//-------------------------------------------------------------------------------------------------------------------
	int iStat = ITK_ok;

	tag_t propTag = va_arg(args, tag_t);    // Run-time parameter
	char** returnValue = va_arg(args, char**); // Run-time parameter
	*returnValue = NULL;

	tag_t tArticle = NULLTAG;

	METHOD_PROP_MESSAGE_OBJECT(msg, tArticle);

	//Check if the object is a part or an assembly
	//vector<tag_t> vecSecondary;
	//sr5AskSecondaryObjects(tArticle, TC_specification_rtype, "CATPart", &vecSecondary);

	if (tArticle != NULLTAG) {
	//if (vecSecondary.size() > 0) {

			//check if topline has Children
			tag_t* viewChildren = NULL;
			int nChildren = NULL;
			ITK_CALL(AOM_ask_value_tags(tArticle, "view", &nChildren, &viewChildren));

			//check if an SR5CatDefArticle is attached
			if (nChildren > 0)
			{
				//get Dimension value from Article
				std::string articleDim;

				int iFail = sr5ReadAttrValue_STRING(tArticle, SR5_TYPE_SR5EngArticleRevision, "sr5Dimension", &articleDim);

				//create BOM Window for whole structure
				tag_t itemTag = NULLTAG;
				ITK_CALL(ITEM_ask_item_of_rev(tArticle, &itemTag));
				tag_t window = NULL;
				tag_t rule = NULLTAG;
				tag_t topline = NULLTAG;
				ITK_CALL(BOM_create_window(&window));
				ITK_CALL(BOM_set_window_top_line(window, itemTag, tArticle, NULLTAG, &topline));
				ITK_CALL(CFM_find(SR5_REVRULE_LatestWorking, &rule));
				ITK_CALL(BOM_set_window_config_rule(window, rule));
				ITK_CALL(BOM_window_hide_unconfigured(window));


				int nChildren = NULL;
				tag_t* children = NULL;

				//ask if children exist in general (irrespective of revrule)
				ITK_CALL(BOM_line_ask_child_lines(topline, &nChildren, &children));

				if(nChildren==1)
				{ 
				//for (int k = 0; k < nChildren; k++) {

					int n_props = 0;
					tag_t tRev = NULLTAG;

					//Check if BOMLine has configured revision
					ITK_CALL(AOM_ask_value_tag(children[0], "bl_revision", &tRev));

					if (tRev != NULLTAG)
					{

						std::string strChildObjectType="";
						std::string catDefDim="";
						std::string value="";
						sr5ReadAttrValue_STRING(tRev, "WorkspaceObject", "object_type", &strChildObjectType);
						if (strChildObjectType.compare(SR5_TYPE_SR5CatDefArticleRevision) == 0)
						{
							//get Dimension value from CatDefArticle
							int iFail = sr5ReadAttrValue_STRING(tRev, SR5_TYPE_SR5CatDefArticleRevision, "sr5Dimension", &catDefDim);


							char** qtyvalue = NULL;
							char** uomvalue = NULL;

							ITK_CALL(AOM_ask_displayable_values(children[0], "bl_quantity", &n_props, &qtyvalue));
							ITK_CALL(AOM_ask_displayable_values(children[0], "bl_uom", &n_props, &uomvalue));
							double dblQTY = strtod(qtyvalue[0], NULL);
							if (dblQTY == 0.0) { dblQTY = 1.0; }


							if (tc_strcmp(uomvalue[0], "M") == 0)
							{ // get full Dimension from CatDef Dimension and quantity value of CatDef BOMline for tubes, hoses, profiles etc with only one free dimension.
								value.append(catDefDim);
								//Nach Absprache mit Tina Weissenborn soll die Laenge nicht in der Dimension stehen, da sie aus der BOMLine gezogen werden kann
								/*value.append("x");
								dblQTY = dblQTY * 1000;
								dblQTY = dblQTY + 0.5 - (dblQTY < 0);
								int qty = (int)dblQTY;
								value.append(to_string(qty));*/

								*returnValue = (char*)MEM_alloc(tc_strlen(value.c_str()) + 1);
								tc_strcpy(*returnValue, value.c_str());
							}
							else
							{ // get full Dimension from CatDef Dimension and Article Dimension  for plates with two free dimensions.
								if (catDefDim.compare("") != 0 && articleDim.compare("") != 0)
								{

									value.append(catDefDim);
									value.append("x");
									value.append(articleDim);

									*returnValue = (char*)MEM_alloc(tc_strlen(value.c_str()) + 1);
									tc_strcpy(*returnValue, value.c_str());
								}

							}


							SAFE_SM_FREE(qtyvalue);
							SAFE_SM_FREE(uomvalue);
						}
					}
				}
				else 
				{

					std::string value="";
					value.append(articleDim);

					*returnValue = (char*)MEM_alloc(tc_strlen(value.c_str()) + 1);
					tc_strcpy(*returnValue, value.c_str());

				}

				SAFE_SM_FREE(children);

			}

			SAFE_SM_FREE(viewChildren);
		//}
	}
	return iStat;
}

int sr5ChangeAttr_Line1(METHOD_message_t* msg, va_list args)
{
	//-------------------------------------------------------------------------------------------------------------------
	//Returns the string for the first line in the change table on the drawing
	//-------------------------------------------------------------------------------------------------------------------
	int iStat = ITK_ok;

	tag_t propTag = va_arg(args, tag_t);    // Run-time parameter
	char** returnValue = va_arg(args, char**); // Run-time parameter
	*returnValue = NULL;


	tag_t tArticle = NULLTAG;
	METHOD_PROP_MESSAGE_OBJECT(msg, tArticle);

	if (tArticle != NULLTAG) {

		int Number = 1;
		string myString = "";

		CalculateString(tArticle, Number, &myString);

		*returnValue = (char*)MEM_alloc(tc_strlen(myString.c_str()) + 1);
		tc_strcpy(*returnValue, myString.c_str());
	}
	return iStat;
}

int sr5ChangeAttr_Line2(METHOD_message_t* msg, va_list args)
{
	//-------------------------------------------------------------------------------------------------------------------
	//Returns the string for the 2nd line in the change table on the drawing
	//-------------------------------------------------------------------------------------------------------------------
	int iStat = ITK_ok;

	tag_t propTag = va_arg(args, tag_t);    // Run-time parameter
	char** returnValue = va_arg(args, char**); // Run-time parameter
	*returnValue = NULL;

	tag_t tArticle = NULLTAG;
	METHOD_PROP_MESSAGE_OBJECT(msg, tArticle);

	if (tArticle != NULLTAG) {

		int Number = 2;
		string myString = "";

		CalculateString(tArticle, Number, &myString);

		*returnValue = (char*)MEM_alloc(tc_strlen(myString.c_str()) + 1);
		tc_strcpy(*returnValue, myString.c_str());
	}
	return iStat;
}

int sr5ChangeAttr_Line3(METHOD_message_t* msg, va_list args)
{
	//-------------------------------------------------------------------------------------------------------------------
	//Returns the string for the 3rd line in the change table on the drawing
	//-------------------------------------------------------------------------------------------------------------------
	int iStat = ITK_ok;

	tag_t propTag = va_arg(args, tag_t);    // Run-time parameter
	char** returnValue = va_arg(args, char**); // Run-time parameter
	*returnValue = NULL;

	tag_t tArticle = NULLTAG;
	METHOD_PROP_MESSAGE_OBJECT(msg, tArticle);

	if (tArticle != NULLTAG) {

		int Number = 3;
		string myString = "";

		CalculateString(tArticle, Number, &myString);

		*returnValue = (char*)MEM_alloc(tc_strlen(myString.c_str()) + 1);
		tc_strcpy(*returnValue, myString.c_str());
	}
	return iStat;
}

int sr5ChangeAttr_Line4(METHOD_message_t* msg, va_list args)
{
	//-------------------------------------------------------------------------------------------------------------------
	//Returns the string for the 4th line in the change table on the drawing
	//-------------------------------------------------------------------------------------------------------------------
	int iStat = ITK_ok;

	tag_t propTag = va_arg(args, tag_t);    // Run-time parameter
	char** returnValue = va_arg(args, char**); // Run-time parameter
	*returnValue = NULL;

	tag_t tArticle = NULLTAG;
	METHOD_PROP_MESSAGE_OBJECT(msg, tArticle);

	if (tArticle != NULLTAG) {

		int Number = 4;
		string myString = "";

		CalculateString(tArticle, Number, &myString);

		*returnValue = (char*)MEM_alloc(tc_strlen(myString.c_str()) + 1);
		tc_strcpy(*returnValue, myString.c_str());
	}
	return iStat;
}

int sr5ChangeAttr_Line5(METHOD_message_t* msg, va_list args)
{
	//-------------------------------------------------------------------------------------------------------------------
	//Returns the string for the 5th line in the change table on the drawing
	//-------------------------------------------------------------------------------------------------------------------
	int iStat = ITK_ok;

	tag_t propTag = va_arg(args, tag_t);    // Run-time parameter
	char** returnValue = va_arg(args, char**); // Run-time parameter
	*returnValue = NULL;

	tag_t tArticle = NULLTAG;
	METHOD_PROP_MESSAGE_OBJECT(msg, tArticle);

	if (tArticle != NULLTAG) {

		int Number = 5;
		string myString = "";

		CalculateString(tArticle, Number, &myString);

		*returnValue = (char*)MEM_alloc(tc_strlen(myString.c_str()) + 1);
		tc_strcpy(*returnValue, myString.c_str());
	}
	return iStat;
}

int sr5ChangeAttr_Line6(METHOD_message_t* msg, va_list args)
{
	//-------------------------------------------------------------------------------------------------------------------
	//Returns the string for the 6th line in the change table on the drawing
	//-------------------------------------------------------------------------------------------------------------------
	int iStat = ITK_ok;

	tag_t propTag = va_arg(args, tag_t);    // Run-time parameter
	char** returnValue = va_arg(args, char**); // Run-time parameter
	*returnValue = NULL;

	tag_t tArticle = NULLTAG;
	METHOD_PROP_MESSAGE_OBJECT(msg, tArticle);

	if (tArticle != NULLTAG) {

		int Number = 6;
		string myString = "";

		CalculateString(tArticle, Number, &myString);


		*returnValue = (char*)MEM_alloc(tc_strlen(myString.c_str()) + 1);
		tc_strcpy(*returnValue, myString.c_str());
	}
	return iStat;
}

int sr5ChangeAttr_Line7(METHOD_message_t* msg, va_list args)
{
	//-------------------------------------------------------------------------------------------------------------------
	//Returns the string for the 7th line in the change table on the drawing
	//-------------------------------------------------------------------------------------------------------------------
	int iStat = ITK_ok;

	tag_t propTag = va_arg(args, tag_t);    // Run-time parameter
	char** returnValue = va_arg(args, char**); // Run-time parameter
	*returnValue = NULL;

	tag_t tArticle = NULLTAG;
	METHOD_PROP_MESSAGE_OBJECT(msg, tArticle);

	if (tArticle != NULLTAG) {

		int Number = 7;
		string myString = "";

		CalculateString(tArticle, Number, &myString);


		*returnValue = (char*)MEM_alloc(tc_strlen(myString.c_str()) + 1);
		tc_strcpy(*returnValue, myString.c_str());
	}
	return iStat;
}

int sr5ChangeAttr_Line8(METHOD_message_t* msg, va_list args)
{
	//-------------------------------------------------------------------------------------------------------------------
	//Returns the string for the 8th line in the change table on the drawing
	//-------------------------------------------------------------------------------------------------------------------
	int iStat = ITK_ok;

	tag_t propTag = va_arg(args, tag_t);    // Run-time parameter
	char** returnValue = va_arg(args, char**); // Run-time parameter
	*returnValue = NULL;

	tag_t tArticle = NULLTAG;
	METHOD_PROP_MESSAGE_OBJECT(msg, tArticle);

	if (tArticle != NULLTAG) {

		int Number = 8;
		string myString = "";

		CalculateString(tArticle, Number, &myString);

		*returnValue = (char*)MEM_alloc(tc_strlen(myString.c_str()) + 1);
		tc_strcpy(*returnValue, myString.c_str());
	}
	return iStat;
}

/**
 * @brief Check the expiry date of a document against system timestamp.
 *
 * @param METHOD_message_t* msg
 * @param va_list args
 *
 * @return Validation result.
 */
extern int sr5IsExpired(METHOD_message_t* msg, va_list args)
{
	int iStat{ ITK_ok };
	tag_t propTag{ va_arg(args, tag_t) };
	int* returnValue{ va_arg(args, int*) };
	*returnValue = NULL;
	date_t currentDateTime{ NULLDATE };
	sr5GetCurrentDateTime(&currentDateTime);
	tag_t tDocumentRevision{ NULLTAG };
	METHOD_PROP_MESSAGE_OBJECT(msg, tDocumentRevision);
	date_t expiryDate{ NULLDATE };
	ITK_CALL(AOM_ask_value_date(tDocumentRevision, "sr5ExpiryDate", &expiryDate));
	if (expiryDate.year == 0 && expiryDate.month == 0 && expiryDate.day == 0)
	{
		*returnValue = 0;
		return iStat;
	}
	int isExpired{ 0 };
	isExpired = sr5CompareDates(&expiryDate, &currentDateTime);
	*returnValue = isExpired > 0 ? 0 : 1;
	return iStat;
}


int sr5CATIADisplayName(METHOD_message_t* msg, va_list args)
{    //-------------------------------------------------------------------------------------------------------------------
	//Returns the object name + norm no + dimension for mapping to CATIA
	//-------------------------------------------------------------------------------------------------------------------
	int iStat = ITK_ok;

	tag_t propTag = va_arg(args, tag_t);    // Run-time parameter
	char** returnValue = va_arg(args, char**); // Run-time parameter
	*returnValue = NULL;

	tag_t tArticle = NULLTAG;

	METHOD_PROP_MESSAGE_OBJECT(msg, tArticle);

	if (tArticle != NULLTAG)
	{
		std::string fullString = "";
		std::string rObjName = "";
		std::string rNorm = "";
		ITK_CALL(sr5ReadAttrValue_STRING(tArticle, SR5_TYPE_SR5GenEngObjRevision, "object_name", &rObjName));
		ITK_CALL(sr5ReadAttrValue_STRING(tArticle, SR5_TYPE_SR5GenEngObjRevision, "sr5NormNo", &rNorm));
		fullString.append(rObjName);
		if (rNorm.size() != NULL && tc_strcmp(rNorm.c_str(), "") != 0) {
			fullString.append(" ");
			fullString.append(rNorm);
		}
		char* FullDim = NULL;
		ITK_CALL(AOM_ask_value_string(tArticle, "sr5FullDimension", &FullDim));

		if (FullDim != NULL && tc_strcmp(FullDim, "") != 0)
		{
			fullString.append(" ");
			fullString.append(FullDim);
		}

		*returnValue = (char*)MEM_alloc(tc_strlen(fullString.c_str()) + 1);
		tc_strcpy(*returnValue, fullString.c_str());

	}
	return iStat;

}



std::string trim(const std::string& str,
	const std::string& whitespace = " \t")
{
	const auto strBegin = str.find_first_not_of(whitespace);
	if (strBegin == std::string::npos)
		return ""; // no content

	const auto strEnd = str.find_last_not_of(whitespace);
	const auto strRange = strEnd - strBegin + 1;

	return str.substr(strBegin, strRange);
}

std::string reduce(const std::string& str,
	const std::string& fill = " ",
	const std::string& whitespace = " \t")
{
	// trim first
	auto result = trim(str, whitespace);

	// replace sub ranges
	auto beginSpace = result.find_first_of(whitespace);
	while (beginSpace != std::string::npos)
	{
		const auto endSpace = result.find_first_not_of(whitespace, beginSpace);
		const auto range = endSpace - beginSpace;

		result.replace(beginSpace, range, fill);

		const auto newStart = beginSpace + fill.length();
		beginSpace = result.find_first_of(whitespace, newStart);
	}

	return result;
}



int sr5CATIAName1(METHOD_message_t* msg, va_list args)
{ //-------------------------------------------------------------------------------------------------------------------
	//Returns the first string of the FSF drawing naming
	//-------------------------------------------------------------------------------------------------------------------
	int iStat = ITK_ok;

	tag_t propTag = va_arg(args, tag_t);    // Run-time parameter
	char** returnValue = va_arg(args, char**); // Run-time parameter
	*returnValue = NULL;

	tag_t tArticle = NULLTAG;

	METHOD_PROP_MESSAGE_OBJECT(msg, tArticle);

	if (tArticle != NULLTAG)
	{
		std::string rObjName = "";
		ITK_CALL(sr5ReadAttrValue_STRING(tArticle, SR5_TYPE_SR5GenEngObjRevision, "object_name", &rObjName));

		/*char* objNameDE = NULL;
		char DELocStatus = NULL;
		logical mDEMaster = false;
		AOM_UIF_ask_localized_value_string(tArticle,"object_name","de_DE",&objNameDE,&DELocStatus,&mDEMaster);*/

		if (rObjName.size()>0)
		{
			if (rObjName.size() > 25)
			{
				std::string first = "";
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


				//std::size_t found = sMiddle.find_first_of(" ");
				std::size_t found = sMiddle.find_last_of(" ");
				if (found != std::string::npos)
				{
					//if (rObjName.size() < 40)
					//{
						first = rObjName.substr(0, FirstBorder + found);
					/*}
					else
					{
						first = rObjName.substr(0, 25);
					}*/

					*returnValue = (char*)MEM_alloc(tc_strlen(reduce(first).c_str()) + 1);
					tc_strcpy(*returnValue, reduce(first).c_str());
				}
				else
				{

					first = rObjName.substr(0, 25);


					*returnValue = (char*)MEM_alloc(tc_strlen(reduce(first).c_str()) + 1);
					tc_strcpy(*returnValue, reduce(first).c_str());

				}
			}
			else 
			{
				*returnValue = (char*)MEM_alloc(tc_strlen(reduce(rObjName).c_str()) + 1);
				tc_strcpy(*returnValue, reduce(rObjName).c_str());
			}
		}
	}
	return iStat;
}


int sr5CATIAName2(METHOD_message_t* msg, va_list args)
{ //-------------------------------------------------------------------------------------------------------------------
	//Returns the second string of the FSF drawing naming
	//-------------------------------------------------------------------------------------------------------------------
	int iStat = ITK_ok;

	tag_t propTag = va_arg(args, tag_t);    // Run-time parameter
	char** returnValue = va_arg(args, char**); // Run-time parameter
	*returnValue = NULL;

	tag_t tArticle = NULLTAG;

	METHOD_PROP_MESSAGE_OBJECT(msg, tArticle);

	if (tArticle != NULLTAG)
	{
		std::string rObjName = "";
		ITK_CALL(sr5ReadAttrValue_STRING(tArticle, SR5_TYPE_SR5GenEngObjRevision, "object_name", &rObjName));

		/*char* objNameDE = NULL;
		char DELocStatus = NULL;
		logical mDEMaster = false;
		AOM_UIF_ask_localized_value_string(tArticle,"object_name","de_DE",&objNameDE,&DELocStatus,&mDEMaster);*/

		if (rObjName.size() > 0)
		{
			if (rObjName.size() > 25)
			{
				std::string second = "";
				//int sizeStr = rObjName.size();
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


				//std::size_t found = sMiddle.find_first_of(" ");
				std::size_t found = sMiddle.find_last_of(" ");
				if (found != std::string::npos)
				{
					second = rObjName.substr(found + FirstBorder);
					//if (rObjName.size() < 40)
					//{
						second = rObjName.substr(found + FirstBorder);
					//}
					//else
				//	{
					//	second = rObjName.substr(25, 15);
					//}

					*returnValue = (char*)MEM_alloc(tc_strlen(reduce(second).c_str()) + 1);
					tc_strcpy(*returnValue, reduce(second).c_str());
				}
				else
				{

					second = rObjName.substr(25, 15);


					*returnValue = (char*)MEM_alloc(tc_strlen(reduce(second).c_str()) + 1);
					tc_strcpy(*returnValue, reduce(second).c_str());

				}
			}
			else
			{

				return iStat;
			}
		}
	}
	return iStat;

}

extern int sr5ProposedObjectName(METHOD_message_t* msg, va_list args) {
	int iStat{ ITK_ok };
	tag_t propTag{ va_arg(args, tag_t) };
	char** returnValue{ va_arg(args, char**) };
	*returnValue = NULL;
	tag_t requestForm{ NULLTAG };
	METHOD_PROP_MESSAGE_OBJECT(msg, requestForm);

	char* sCurrentLocale{ "" };
	ITK_CALL(TC_text_get_current_W3C_locale(&sCurrentLocale));

	char* nameTerm1{ "" };
	ITK_CALL(AOM_ask_value_string(requestForm, "sr5ObjectNameTerm1", &nameTerm1));
	tag_t objectNameTerm1Lov{ NULLTAG };
	ITK_CALL(AOM_ask_lov(requestForm, "sr5ObjectNameTerm1", &objectNameTerm1Lov));
	char* nameTerm1DispValue{ "" };
	sr5AskLovalizedLovValueString(objectNameTerm1Lov, nameTerm1, sCurrentLocale, &nameTerm1DispValue);
	std::string nameTerm1String{ nameTerm1DispValue };

	char* nameTerm2{ "" };
	ITK_CALL(AOM_ask_value_string(requestForm, "sr5ObjectNameTerm2", &nameTerm2));
	std::string nameTerm2String{ "" };
	if (strcmp(nameTerm2, "") != 0) {
		tag_t objectNameTerm2Lov{ NULLTAG };
		ITK_CALL(AOM_ask_lov(requestForm, "sr5ObjectNameTerm2", &objectNameTerm2Lov));
		char* nameTerm2DispValue{ "" };
		sr5AskLovalizedLovValueString(objectNameTerm2Lov, nameTerm2, sCurrentLocale, &nameTerm2DispValue);
		nameTerm2String = nameTerm2DispValue;
	}

	char* nameTerm3{ "" };
	ITK_CALL(AOM_ask_value_string(requestForm, "sr5ObjectNameTerm3", &nameTerm3));
	std::string nameTerm3String{ "" };
	if (strcmp(nameTerm3, "") != 0) {
		tag_t objectNameTerm3Lov{ NULLTAG };
		ITK_CALL(AOM_ask_lov(requestForm, "sr5ObjectNameTerm3", &objectNameTerm3Lov));
		char* nameTerm3DispValue{ "" };
		sr5AskLovalizedLovValueString(objectNameTerm3Lov, nameTerm3, sCurrentLocale, &nameTerm3DispValue);
		nameTerm3String = nameTerm3DispValue;
	}

	std::string proposedObjectName{ nameTerm1String };
	if (nameTerm2String != "") {
		proposedObjectName += " ";
		proposedObjectName += nameTerm2String;
	}
	if (nameTerm3String != "") {
		proposedObjectName += " ";
		proposedObjectName += nameTerm3String;
	}

	*returnValue = (char*)MEM_alloc(tc_strlen(proposedObjectName.c_str()) + 1);
	tc_strcpy(*returnValue, proposedObjectName.c_str());

	SAFE_SM_FREE(sCurrentLocale);
	SAFE_SM_FREE(nameTerm1);
	SAFE_SM_FREE(nameTerm2);
	SAFE_SM_FREE(nameTerm3);

	return iStat;
}