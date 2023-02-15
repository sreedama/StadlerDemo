/* $Id: cat_USER_bom_customize.c,v 1.18 2018/03/05 15:20:57 yte Exp $ */

#include "cat_USER_customize.h"
#include <stdlib.h>
/**************************************************************************/
/* Determines if the Item will be loaded in Catia as a Product or a Part  */
/* depending on specific conditions.                                      */
/* Four boolean  variables are defined  to help you to  define various    */
/* combinations in order to know which type of document will be loaded    */
/* in Catia. The four variables are the following:                        */
/* - ExistBVR :  Boolean variable  which is set  to true if  under the    */
/*      Item,  there is  a Bom  Wiew of  type defined  in  your tcic_preferences.xml file */
/*      (variable : CATIA_Bom_name)                                       */
/* - EmptyBvr : Boolean variable which  is set to true if the previous    */
/*      variable ExistBVR  is true and  the Bom View  Revision associated */
/*      doesn't contain occurences.                                       */
/* - ExistCATProduct : Boolean variable which  is set to true if under    */
/*      the Item revision, there  is a  dataset of  type defined  in your */
/*      catiav5properties.properties (variable : catProductDatasetType)   */
/* - ExistCATPart : Boolean variable which is set to true if under the    */
/*      Item  revision, there  is  a  dataset of  type  defined  in  your */
/*      catiav5properties.properties (variable : catPartDatasetType)      */
/*                                                                        */
/* In this function, a setting : CATIA_customize_load_process (defined    */
/* in your  tcic_preferences.xml file)  will be read  and filled in  the variable    */
/* VarCATIA_CUSTOM_LOAD to  determine which criterion  you want to  use for    */
/* the load in Catia.                                                     */
/* The first criterion (the CATIA_customize_load_process Option is set    */
/* to  0(default value)  in  your tcic_preferences.xml  file)  correspond to  the    */
/* previous behavior:                                                     */
/* When the  process analyses the branches  of the BOM  tree, it stops    */
/* when  a node  doesn't  contain a  valid  catia BOM.  In this  case,    */
/* cat_USER_hasChildren   returns  op_answer=FALSE   and  the   item  is    */
/* considered as a leaf of the tree ( component).                         */
/* The  second criterion  (the CATIA_customize_load_process  Option is    */
/* set to 1 in your tcic_preferences.xml file) analyses moreover type of datasets    */
/* under the given item revision and checks whether the Bom View revision */
/* contains  occurrences. The  cat_USER_hasChildren  function returns    */
/* op_answer=FALSE (so a Part will be loaded) in 3 cases :                   */
/* - there is a CATPart dataset, but neither CATProduct nor Bom View      */
/* - there is just an empty Bom View revision (containing no occurrences) */
/* - there is neither dataset nor Bom View                                */
extern int ExportedByCatiaCustom 
cat_USER_hasChildren(tag_t       i_bom_line,		/* <I> Tag of the BomLine */
					  tag_t       i_item_rev_tag, 	/* <I> Tag of the Item Revision */
                      tag_t       i_bvr_tag, 		/* <I> Tag of the BomViewRev */
                      logical     *op_answer)		/* <O> TRUE if the sub-assembly is valid */
{
     tag_t                    ClassId = NULLTAG;
     tag_t                    RefClassId = NULLTAG;
     char*                    WsoType = NULL;
     char                    *ViewTypeName = NULL;
     tag_t 					  ViewType = NULLTAG;
     int                      FailCode = 0, NbObjects = 0, i = 0;
     tag_t                   *ObjectList = NULL;
     logical                  ExistBvr = FALSE, EmptyBvr = FALSE;
	 logical 		          hasOnlyCatDef = FALSE;
     logical                  ExistCATProduct = FALSE, ExistCATPart = FALSE;
     logical                  has_children = FALSE;  
     int 					  bl_bomview_attribID = 0;
     tag_t  				  bl_bomview_tag = NULLTAG;
     tag_t                    bomline_type_tag = NULLTAG;
	 tag_t 					  relTypeIMAN_specification = NULLTAG;
	 int 					  iChildren=0;
	 tag_t* 				  tChildren=NULLTAG;
	 char* 					  typeName = NULL;
	 tag_t 					  tRev=NULLTAG;

     *op_answer = TRUE ;

     /* */
     /* needed in order to prevent TcEng hanging */
    if (i_item_rev_tag == NULLTAG)
    {
          *op_answer = FALSE;
          return ITK_ok;
    }
     /* Look for the Bom View Name. If it corresponds to the */
     /* CATIA_Bom_name value read in the tcic_preferences.xml file,     */
     /* the boolean  variable "ExistBvr" will be set to true */
    if(i_bvr_tag != NULLTAG) 
    {  
		 FailCode = GRM_find_relation_type("IMAN_specification", &relTypeIMAN_specification);
		
		
		POM_class_id_of_class("Dataset", &RefClassId);
			
        FailCode = GRM_list_secondary_objects_only(i_item_rev_tag, relTypeIMAN_specification, &NbObjects, &ObjectList);
        if (FailCode == ITK_ok && NbObjects > 0)
        {
            for (i = 0; i < NbObjects; i++) 
            {
	            ClassId = NULLTAG;
            	FailCode = POM_class_of_instance(ObjectList[i], &ClassId);
                if((FailCode == ITK_ok) && (ClassId != NULLTAG))
                {	
					if ( ClassId == RefClassId )
                	{
                		FailCode = WSOM_ask_object_type2(ObjectList[i], &WsoType);
                		if((FailCode == ITK_ok) && WsoType!=NULL && (tc_strcmp(WsoType, "") != 0))
                		{
                			if (strcmp(WsoType, "CATPart") == 0)
                			{
                				ExistCATPart = TRUE;
                			}
                			else if (strcmp(WsoType, "CATProduct") == 0)
                			{
                				ExistCATProduct = TRUE;
                			}
                		}
                	}
                	if (ExistCATPart && ExistCATProduct)
                		break;
				}
			}
		}
		
         FailCode = TCTYPE_find_type(bomClass_line, bomClass_line, &bomline_type_tag);
         if (FailCode == ITK_ok)
         {
             FailCode = TCTYPE_ask_property_by_name(bomline_type_tag, bomAttr_lineBvTag, &bl_bomview_attribID);
             if (FailCode == ITK_ok)
             {
				 
				FailCode = BOM_line_ask_child_lines(i_bom_line, &iChildren, &tChildren);
				if(iChildren!=0)
				{
					AOM_ask_value_tag(tChildren[0], "bl_revision", &tRev);
					if(tRev!=NULLTAG)
					{
						FailCode=AOM_ask_value_string(tRev,"object_type",&typeName);
						if(tc_strcmp(typeName, "SR5CatDefArticleRevision") == 0 && iChildren==1)
						{
							hasOnlyCatDef = TRUE;
						}
					}
				}
				 
                FailCode = AOM_ask_value_tag(i_bom_line, bomAttr_lineBvTag, &bl_bomview_tag);
				 
				if ((FailCode == ITK_ok) && (NULLTAG != bl_bomview_tag))
				{
					FailCode = PS_ask_bom_view_type(bl_bomview_tag, &ViewType);
					if (FailCode == ITK_ok)
					{
						FailCode = PS_ask_view_type_name(ViewType, &ViewTypeName);
						if (FailCode == ITK_ok)
						{
							if (strcmp(ViewTypeName, VarCATIA_BOM_NAME) == 0)
							{
							 ExistBvr = TRUE;
							}
						}
					}
					if (NULL != ViewTypeName)
					{
						MEM_free(ViewTypeName);
					}
				}
				
            }
        }
		if(ExistBvr) 
		{           
			FailCode = TCTYPE_find_type(bomClass_line, bomClass_line, &bomline_type_tag);
			if (FailCode == ITK_ok)
			{
				FailCode = TCTYPE_ask_property_by_name(bomline_type_tag, bomAttr_lineBvTag, &bl_bomview_attribID);
				if (FailCode == ITK_ok)
				{
					FailCode = AOM_ask_value_logical(i_bom_line, bomAttr_lineHasChildren, &has_children);
					if ((FailCode == ITK_ok) && (FALSE == has_children))
					{
						EmptyBvr = TRUE;
					}
				}
			}
		}
    }
	if  ( (ExistCATPart) && (!ExistCATProduct) && (!ExistBvr) )
	{
		*op_answer = FALSE;
	}
	if ( (ExistCATPart) && ( !ExistCATProduct) && (EmptyBvr) )
	{
		*op_answer = FALSE;
	}
	//if ( (!ExistCATPart) &&  (!ExistCATProduct)  && (!ExistBvr) )
	//{
	//	*op_answer = FALSE;
	//}
	if ( (ExistCATPart) && (hasOnlyCatDef) )
	{
		*op_answer = FALSE;
	}

    return (ITK_ok);
}

/*******************************************************/
/* This entry point is called to check if the instance */
/* corresponding to i_occ_tag have to be loaded or not.*/
/* This function is used during load processes.        */
/* By default, cat_USER_isOccurrenceToBeLoaded = true  */
extern ExportedByCatiaCustom
logical cat_USER_isOccurrenceToBeLoaded(
										tag_t i_top_line_item_rev_tag, /* <I> Tag of top Node (assembly context)*/
										char * i_occuid_path, 		   /* <I> Occuid path of current item*/
										tag_t i_parent_item_rev_tag,   /* <I> Tag of the parent Item Revision */
                                        tag_t i_parent_bomvr_tag,      /* <I> Tag of the parent bomview revision */
                                        tag_t i_item_rev_tag,          /* <I> Tag of the Item Revision */
                                        tag_t i_occ_tag)               /* <I> Tag of the occurence */
{      
     int    FailCode = 0;   
	
	char* typeName = NULL;
	FailCode = AOM_ask_value_string(i_item_rev_tag,"object_type",&typeName);
	
	if(tc_strcmp(typeName, "SR5CatDefArticleRevision") == 0)
	{
		return false;
	}
	else
	{
		return true;
	}
} 

extern logical ExportedByCatiaCustom
cat_USER_isOccurrenceNonCAD(tag_t i_bom_line_tag, 
                            char *** iop_message_tab,
                            int *iop_size_message_tab)
{
    return false;
}

/*********************************************************************
* This user exit is called after preliminary verification of the bomline
* is made for dataset creation from CATIAV5 menu.
*
* If the returned error value is not ITK_ok the processing of the structure
* will be aborted. The message returned will be reported as error.
* If it is okay and skipCreation value is set to true, then bomline will be skipped
* and the message will be reported to the user as a warning.
*********************************************************************/
extern int ExportedByCatiaCustom
cat_USER_verifyDatasetCreation (
    tag_t         bomline,        /* <I> */
    const char*   dsType ,        /* <I> */
    logical*      skipCreation,   /* <O> */
    char**        message )       /* <O> */
{
    int   status   = ITK_ok;

    return status;
}

/*
// Local Variables:
// c-file-style: "k&r"
// c-file-offsets: ( (inline-open . 0))
// comment-column: 40
// End:
*/
