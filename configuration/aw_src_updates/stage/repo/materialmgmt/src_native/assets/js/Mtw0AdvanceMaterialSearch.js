// @<COPYRIGHT>@
// ==================================================
// Copyright 2020.
// Siemens Product Lifecycle Management Software Inc.
// All Rights Reserved.
// ==================================================
// @<COPYRIGHT>@

/*global
define
 */

/**
 * @module js/Mtw0AdvanceMaterialSearch
 */
import app from 'app';
import appCtxSvc from 'js/appCtxService';
import _ from 'lodash';
import cdm from 'soa/kernel/clientDataModel';
import listBoxSvc from 'js/listBoxService';
import modelPropertySvc from 'js/modelPropertyService';
import _dateTimeSvc from 'js/dateTimeService';
import AwPromiseService from 'js/awPromiseService';
import soaSvc from 'soa/kernel/soaService';
var exports = {};

var _metParamList = [];
var _baseUnitCollection;
var _selectedMaterialType = "Material Revision";
var _customAttrList = [];
var _mat1GlobalClsList = [];
var _mat1CatlogueClsList = [];
var _groupByCatlogue;

/**
 * This method is to get material catalogue list
 *
 * @param {response}  response object
 * @return {ObjectArray} input data
 */

export let processMaterialCatalogues = function (response) {

    var materialCatlogList = [];
    for (var index in response.outputList[0].foundObjects) {
        var unitAltNameUid = response.outputList[0].foundObjects[index].uid;
        var unitAltNameObj = cdm.getObject(unitAltNameUid);
        if (unitAltNameObj.modelType.typeHierarchyArray.indexOf('Mat1MatCatalog') > -1) {
            var materialCatlogObj = {};
            var matcatlogUid = response.outputList[0].foundObjects[index].uid;
            var matcatlogVM = cdm.getObject(matcatlogUid);
            materialCatlogObj.propDisplayValue = matcatlogVM.props.object_name.dbValues[0];
            materialCatlogObj.dispValue = matcatlogVM.props.object_name.uiValues[0];
            materialCatlogObj.propInternalValue = matcatlogUid;
            materialCatlogList.push(materialCatlogObj);
        }

    }
    return _.sortBy(materialCatlogList, ['dispValue']);
};

export let processMaterialClassifiction = function (response) {
    var materialCatlogueClassesList = [];
    var materialGlobalClassesList = [];
    var globalClassObj = {};
    var catalogueClassObj = {};
    for (var index in response.outputList[0].foundObjects) {
        var unitAltNameUid = response.outputList[0].foundObjects[index].uid;
        var unitAltNameObj = cdm.getObject(unitAltNameUid);
        if (unitAltNameObj.modelType.typeHierarchyArray.indexOf('Mat1MatClassification') > -1) {
            //var materialClassObj = {};
            var matClassUid = response.outputList[0].foundObjects[index].uid;
            var matClassVM = cdm.getObject(matClassUid);
            if (matClassVM.props.mat1MatCatalog.dbValues.length === 1 && matClassVM.props.mat1MatCatalog.dbValues[0] === null) // This is global classes check
            {
                //globalClassObj[matClassVM.props.mat1RealName.dbValues[0]] = matClassUid;
                globalClassObj[matClassUid] = { "name": matClassVM.props.object_name.dbValues[0] };
            }
            else {
                //catalogueClassObj[matClassVM.props.mat1RealName.dbValues[0]] = matClassUid;
                catalogueClassObj[matClassUid] = {
                    "name": matClassVM.props.object_name.dbValues[0],
                    "catalogueUid": matClassVM.props.mat1MatCatalog.dbValues[0],
                    "matcatlogueClsUid": matClassUid
                };
            }
            // globalClassObj[matClassUid] = { "name": matClassVM.props.mat1RealName.dbValues[0] };

        }

    }
    buildGlobalClassTree(globalClassObj, materialGlobalClassesList);
    var filteredByCatlogue = _.filter(catalogueClassObj, 'catalogueUid');
    _groupByCatlogue = _.groupBy(filteredByCatlogue, function (item) {
        return item.catalogueUid;
    });
    //var foundCatalogue =_groupByCatlogue['DEW9I6nTJRyArB'];
    //var orderedGlbClsList =_.orderBy(materialGlobalClassesList,['label'],['asc']);
    var orderedGlbClsList = _.sortBy(materialGlobalClassesList, [function (o) { return _.toLower(o.label); }]);
    return orderedGlbClsList;
};

export let buildGlobalClassTree = function (globalClassObj, materialGlobalClassesList) {
    var parentClassObject = {};
    for (let key in globalClassObj) {
        //var clsObj = cdm.getObject(globalClassObj[key]);
        var clsObj = cdm.getObject(key);

        if (clsObj.props.mat1ParentClassification.dbValues[0] === null || clsObj.props.mat1ParentClassification.dbValues[0].trim().length === 0) //it is parent class
        {
            if (parentClassObject[key] === undefined) //parent node not found
            {
                var node = {};
                node.label = globalClassObj[key].name;
                node.value = key;
                node.children = [];
                materialGlobalClassesList.push(node); //push parents to list
                parentClassObject[key] = node;

            } else { //parent class already defined

                var parentNode = parentClassObject[key];// get parent node
                materialGlobalClassesList.push(parentNode); //push parents to list               
            }
        }
        else { // it is child class
            //get parent class
            var parentUid = clsObj.props.mat1ParentClassification.dbValues[0];
            var parentObj = cdm.getObject(parentUid);
            //check if parent class already defined
            if (parentClassObject[parentUid] === undefined) //parent class for child not defined
            {
                //create parent class
                var parentNode = {};
                parentNode.label = parentObj.props.object_name.dbValues[0];
                parentNode.value = parentUid;
                parentNode.children = [];
                //set parent node
                parentClassObject[parentUid] = parentNode;
                //creat child node
                if (parentClassObject[clsObj.uid] === undefined) //check if child node already exists
                {
                    var childNode = {};
                    childNode.label = clsObj.props.object_name.dbValues[0];
                    childNode.value = clsObj.uid;
                    childNode.children = [];
                    parentNode.children.push(childNode);
                    parentNode.children = _.sortBy(parentNode.children, [function (o) { return _.toLower(o.label); }]);
                    parentClassObject[clsObj.uid] = childNode;
                } else {
                    var childNode = parentClassObject[clsObj.uid];
                    parentNode.children.push(childNode);
                    parentNode.children = _.sortBy(parentNode.children, [function (o) { return _.toLower(o.label); }]);
                    parentClassObject[clsObj.uid] = childNode;
                }


                //add parent class
            }
            else { //parent class for child defined
                var parentNode = parentClassObject[parentUid];
                // parentClassObject[parentUid]=parentNode;
                if (parentClassObject[clsObj.uid] === undefined) //check if child node already exists
                {
                    //creat child node
                    var childNode = {};
                    childNode.label = clsObj.props.object_name.dbValues[0];
                    childNode.value = clsObj.uid;
                    childNode.children = [];
                    parentNode.children.push(childNode);
                    parentNode.children = _.sortBy(parentNode.children, [function (o) { return _.toLower(o.label); }]);
                    parentClassObject[clsObj.uid] = childNode;
                } else {
                    var childNode = parentClassObject[clsObj.uid];
                    parentNode.children.push(childNode);
                    parentNode.children = _.sortBy(parentNode.children, [function (o) { return _.toLower(o.label); }]);
                    parentClassObject[clsObj.uid] = childNode;
                }
            }
        }

    }
};
/**
 *
 */
export let loadMaterialMetaParameters = function (data) {
    var materialParameterList = [];
    var mat1ParamAndCatlogueObj = {};
    _metParamList.splice(0, _metParamList.length);
    RemoveAllAction(data);
    var selectedcatlogue = data.materialCatlog.dbValue; //data.materialCatlog.selectedLovEntries[0].propInternalValue;
    var matcatlog = cdm.getObject(selectedcatlogue);
    //var matcatlogVM = cdm.getObject( matcatlogUid );

    var metaParmeterList = matcatlog.props.mat1MetaParameters.dbValues;
    for (var metaparamIndex in metaParmeterList) {
        var metaParamVO = cdm.getObject(metaParmeterList[metaparamIndex]);
        //add only Mat1MetaSingleParameter type parameter
        if (metaParamVO.modelType.typeHierarchyArray.indexOf('Mat1MetaSingleParameter') > -1) {
            materialParameterList.push(metaParamVO);
        }
    }
    var sortedMaterialParameterList = _.sortBy(materialParameterList, ['props.object_name.dbValues[0]']);

    mat1ParamAndCatlogueObj.materialParameterList = listBoxSvc.createListModelObjects(sortedMaterialParameterList, 'props.object_name', true);
    if (_groupByCatlogue[selectedcatlogue] === undefined) {
        mat1ParamAndCatlogueObj.catlogueCls = {};
    }
    else {
        var catLogueList = buildCatalogueClassTree(_groupByCatlogue[selectedcatlogue]);
        mat1ParamAndCatlogueObj.catlogueClsList = catLogueList;
    }
    //return listBoxSvc.createListModelObjects(sortedMaterialParameterList, 'props.object_name', true);
    return mat1ParamAndCatlogueObj;

};

export let addToParameterList = function (data) {

    if (data.materialParameter.selectedLovEntries.length > 0) {
		var selectedParameter = data.materialParameter.selectedLovEntries[0].propInternalValue;
		var match = false;
		if(_metParamList.length >= 1) {
			for (let key in _metParamList) {
				if(_metParamList[key].propertyName.props.object_name.uiValues[0] == selectedParameter.props.object_name.uiValues[0]) {
					match = true;
					break;
				}
			}
		}
		if(!match) {
			var unitList = getDerived(selectedParameter.props.mat1UnitAliasName.dbValues[0]);

			var metaStringPropVMP;
			if (selectedParameter.props.mat1DataType.dbValues[0] === 'String') // this is for data type string
			{
				var metaStringProperty = {};
				metaStringProperty = {
					"displayName": selectedParameter.props.object_name.uiValues[0],
					"propInternalValue": data.i18n.maxParamValue,
					"type": "STRING",
					"isRequired": "false",
					"isEditable": "true",
					"isArray": "false",
					"propertyLabelDisplay": "NO_PROPERTY_LABEL"
				};

				metaStringPropVMP = modelPropertySvc.createViewModelProperty(metaStringProperty);
				metaStringPropVMP.propertyLabelDisplay = 'NO_PROPERTY_LABEL';
			}

			var metaUnitPropertyMin = {
				"displayName": data.i18n.uomDispValue,
				"type": "STRING",
				"isRequired": "false",
				"renderingHint": "textfield",
				"isEditable": "true",
				"isArray": "false",
				"hasLov": true,
				"dbValues": selectedParameter.props.mat1UnitAliasName.dbValues,
				"dbValue": selectedParameter.props.mat1UnitAliasName.dbValues[0],
				"uiValue": selectedParameter.props.mat1UnitAliasName.uiValues,
				"uiValues": selectedParameter.props.mat1UnitAliasName.uiValues[0],
				"lovValues": selectedParameter.props.mat1UnitAliasName.dbValues,
				"propertyLabelDisplay": 'PROPERTY_LABEL_AT_SIDE'

			};
			var metaUnitPropertyMax = {
				"displayName": data.i18n.uomDispValue,
				"type": "STRING",
				"isRequired": "false",
				"renderingHint": "textfield",
				"isEditable": "true",
				"isArray": "false",
				"hasLov": true,
				"dbValues": unitList,
				"dbValue": unitList,
				"listValues": unitList,
				"propertyLabelDisplay": 'PROPERTY_LABEL_AT_SIDE'

			};
			var minParamValue = {
				"displayName": data.i18n.minParamValue,
				"propInternalValue": data.i18n.minParamValue,
				"type": "DOUBLE",
				"isRequired": "false",
				"isEditable": "true",
				"isArray": "false",
				"propertyLabelDisplay": 'PROPERTY_LABEL_AT_SIDE'

			};
			var maxParamValue = {
				"displayName": data.i18n.maxParamValue,
				"propInternalValue": data.i18n.maxParamValue,
				"type": "DOUBLE",
				"isRequired": "false",
				"isEditable": "true",
				"isArray": "false",
				"propertyLabelDisplay": 'PROPERTY_LABEL_AT_SIDE'

			};

			//metaProperty.uid = selectedParameter.uid;
			//var metaUnitPropertyDesc1 = modelPropertySvc.createViewModelProperty(metaUnitPropertyDesc);
			var minParamValueProp = modelPropertySvc.createViewModelProperty(minParamValue);
			var maxParamValueProp = modelPropertySvc.createViewModelProperty(maxParamValue);
			var metaUnitPropertyMinProp = modelPropertySvc.createViewModelProperty(metaUnitPropertyMin);
			metaUnitPropertyMinProp.listValues = unitList;
			var metaUnitPropertyMaxProp = modelPropertySvc.createViewModelProperty(metaUnitPropertyMax);
			metaUnitPropertyMaxProp.listValues = unitList;

			_metParamList.push({
				"propertyName": selectedParameter,
				"metaStringProperty": metaStringPropVMP,
				"minValue": minParamValueProp,
				"maxValue": maxParamValueProp,
				"mat1DerivedValueMin": metaUnitPropertyMinProp,
				"mat1DerivedValueMax": metaUnitPropertyMaxProp
			});
		}
        //_metParamList.push(metaUnitPropertyDesc1);
    }
    return _metParamList;

};

export let RemoveAllAction = function (data) {
    if (data.addMetaParamList) {
        data.addMetaParamList.splice(0, data.addMetaParamList.length);
    }
    if (data.addMetaParamList) {
        data.materialParameter.dbValues = [];
        data.materialParameter.displayValues = [''];
        data.materialParameter.uiValue = '';
        data.materialParameter.uiValues = [''];
        data.materialParameter.value = null;
        data.materialParameter.selectedLovEntries = [];
    }

    if (data.mat1CatalogueClsList) {
        data.mat1CatalogueClsList.splice(0, data.mat1CatalogueClsList.length);
    }

};

export let clearAllAction = function (data) {
    RemoveAllAction(data);
    var searchParamList = [];
    searchParamList.push(data.Mtw0MaterialName);
    searchParamList.push(data.Mtw0MaterialDescription);
    searchParamList.push(data.Mtw0MaterialStatus);
    searchParamList.push(data.Mtw0MaterialObjectType);
    searchParamList.push(data.materialCatlog);

    var searchAttr = _customAttrList.concat(searchParamList);

    _.forEach(searchAttr, function (prop) {
        prop.searchText = '';
        if (prop.type === 'DATE') {
            prop.newDisplayValues = [''];
            prop.newValue = _dateTimeSvc.getNullDate();
            prop.dbValue = _dateTimeSvc.getNullDate();
            prop.dateApi.dateObject = null;
            prop.dateApi.dateValue = '';
            prop.dateApi.timeValue = '';
            prop.dbValues = [];
            prop.displayValues = [''];
            prop.uiValue = '';
            prop.uiValues = [''];
            prop.value = 0;
        } 
        else if (prop.type === 'STRINGARRAY') {
            prop.dbValue = [];
            prop.dbValues = [];
            prop.displayValues = [''];
            prop.uiValue = '';
            prop.uiValues = [''];
            prop.value = null;
        }
        else {
            var propName = prop.propertyName;
            var propDisplayName = prop.propertyDisplayName;
            if (propName && propDisplayName && prop.dbValue !== 'undefined' && prop.dbValue !== null) {
                if (prop.propertyDescriptor && prop.propertyDescriptor.lovCategory === 1) {
                    prop.dbValue = [];
                } else {
                    prop.dbValue = null;
                }
                prop.dbValues = [];
                prop.displayValues = [''];
                prop.uiValue = '';
                prop.uiValues = [''];
                prop.value = null;
            }
        }
    });

    if (data.mat1GlobalClsList) {
        data.mat1GlobalClsList.splice(0, data.mat1GlobalClsList.length);
    }
    if (data.mat1CatalogueClsList) {
        data.mat1CatalogueClsList.splice(0, data.mat1CatalogueClsList.length);
    }
    if (data.mat1ParamAndCatlogueObj && data.mat1ParamAndCatlogueObj.catlogueClsList) {
        data.mat1ParamAndCatlogueObj.catlogueClsList.splice(0, data.mat1ParamAndCatlogueObj.catlogueClsList.length);
    }

    //reset search Input in context when user clears all
    var ctx = appCtxSvc.getCtx('materialSearch');
    if (ctx) {
        ctx.materialSearchInput = "";
        appCtxSvc.updateCtx('materialsearch', ctx);
    }

};


export let processDerivedUnit = function (response) {
    //loop through u Mat1UnitAltName

    var baseUnits = [];
    for (var index in response.outputList[0].foundObjects) {
        var unitAltNameUid = response.outputList[0].foundObjects[index].uid;
        var unitAltNameObj = cdm.getObject(unitAltNameUid);
        if (unitAltNameObj.modelType.typeHierarchyArray.indexOf('Mat1UnitAltName') > -1) {
            //get derived unit object
            var derivedUnitObj = cdm.getObject(unitAltNameObj.props.mat1DerivedUnit.dbValues[0]);
            if (derivedUnitObj !== null && derivedUnitObj !== undefined) {
                var baseUnitObj = cdm.getObject(derivedUnitObj.props.mat1BaseUnit.dbValues[0]);
                if (baseUnitObj !== null && baseUnitObj !== undefined) {
                    var tempObj = {
                        "baseUnitUid": {
                            "uid": baseUnitObj.uid,
                            "derivedUnitObj": {
                                "uid": derivedUnitObj.uid,
                                "unitAltNameObj": {
                                    "uid": unitAltNameObj.uid,
                                    "name": unitAltNameObj.props.object_name.uiValues[0],
                                    "dbValue": unitAltNameObj.props.object_name.dbValues[0]
                                }

                            }

                        }

                    };
                    baseUnits.push(tempObj);
                }
            }

        }

    }
    _baseUnitCollection = _.groupBy(baseUnits, 'baseUnitUid.uid');
    //var matchingObject1 = _.find(_baseUnitCollection, _.matchesProperty('baseUnitUid.derivedUnitObj.unitAltNameObj.name', 'Test_Second'));
    //getDerived('kg/mm^3');
    return _baseUnitCollection;
};

export let getDerivedList = function (baseunitKey) {
    var unitList = [];
    var derivedUnitList = _baseUnitCollection[baseunitKey];
    for (var indx in derivedUnitList) {
        var paramUnit = {};
        paramUnit.propDisplayValue = derivedUnitList[indx].baseUnitUid.derivedUnitObj.unitAltNameObj.dbValue;
        paramUnit.dispValue = derivedUnitList[indx].baseUnitUid.derivedUnitObj.unitAltNameObj.dbValue;
        paramUnit.propInternalValue = derivedUnitList[indx].baseUnitUid.derivedUnitObj.unitAltNameObj.uid;
        paramUnit.baseunitUid = derivedUnitList[indx].uid;

        unitList.push(paramUnit);
    }

    return listBoxSvc.createListModelObjects(unitList, 'dispValue', false);
};

export let getDerived = function (unitAltName) {
    var unitList = [];
    _.forEach(_baseUnitCollection, function (value, key) {
        // console.log(key);
        //console.log(value);
        for (var index in value) {
            var name = value[index].baseUnitUid.derivedUnitObj.unitAltNameObj.dbValue;
            if (name === unitAltName) {
                //console.log('matching found');
                // now find all the units listed under base units
                unitList = getDerivedList(key);
                break;
            }
        }
    });

    return unitList;

};
export let setMaterialType = function (data) {
    _selectedMaterialType = data.Mtw0MaterialObjectType.dbValue.propInternalValue;
};
export let procesMaterialSearchResult = function (response, data) {
    var materialSearchResultList = [];
    var searchResults = response.plain;

    for (var indx in searchResults) {
        var vmo = cdm.getObject(searchResults[indx]);
        if (_selectedMaterialType === 'Material' || _selectedMaterialType === 'Compound Material') {
            var itemUid = vmo.props.items_tag.dbValues[0];
            vmo = cdm.getObject(itemUid);
        }

        materialSearchResultList.push(vmo);
    }
    var uniqueMaterialSearchResultList = _.uniqBy(materialSearchResultList, 'uid');
    var sortedMaterialSearchResultList = _.sortBy(uniqueMaterialSearchResultList, ['props.object_string.dbValues[0]']);
    return sortedMaterialSearchResultList;

};

export let setMaterialSearchCriteriaToCtx = function (data) {
    var ctx = appCtxSvc.getCtx('materialSearch');
    var parameterString = "MATERIAL_PARA";

    var materialSearchString = "";

    //material name
    if (data.Mtw0MaterialName.dbValue !== null && data.Mtw0MaterialName.dbValue.length > 0) {
        materialSearchString = "MATERIAL_NAME;" + data.Mtw0MaterialName.dbValue + "\n";
    }
    if (data.Mtw0MaterialDescription.dbValue !== null && data.Mtw0MaterialDescription.dbValue.length > 0) {
        materialSearchString = "MATERIAL_DESCRIPTION;" + data.Mtw0MaterialDescription.dbValue + "\n";
    }
    //get selected release status
    if (data.Mtw0MaterialStatus.dbValue !== null && data.Mtw0MaterialStatus.dbValue.length > 0) {
        var interReleaseStatusVal="";
        _.forEach(data.Mtw0MaterialStatus.dbValue, function (relStatusObj, indx) {
            if(interReleaseStatusVal.length === 0)
            {
                interReleaseStatusVal =interReleaseStatusVal + relStatusObj.propInternalValue;
            }
            else {
                interReleaseStatusVal = interReleaseStatusVal +","+ relStatusObj.propInternalValue;
            }

        }); 
        if(interReleaseStatusVal.length > 0){      
            materialSearchString = materialSearchString + "MATERIAL_RELEASESTATUS;" + interReleaseStatusVal + "\n";
        }
    }
    //get selected Material type
    if (data.Mtw0MaterialObjectType.dbValue !== null && data.Mtw0MaterialObjectType.dbValue.propInternalValue.length > 0) {
        materialSearchString = materialSearchString + "MATERIAL_TYPE;" + data.Mtw0MaterialObjectType.dbValue.propInternalValue + "\n";
    }

    //custom attribute

    _.forEach(data.immPreferences.ImmCustomAttrList, function (cusVMP) {
        if (cusVMP.type === 'DATE') {
            if (cusVMP.uiValue.length > 0) {
                materialSearchString = materialSearchString + "MATERIAL_CUSTOM_ATTR;" + _.toLower(cusVMP.type) + ";" + cusVMP.propertyName + ";" + cusVMP.uiValue + ";" + "=" + "\n";
            }
        } else {
            if (cusVMP.dbValue !== null && cusVMP.dbValue.length > 0) {
                materialSearchString = materialSearchString + "MATERIAL_CUSTOM_ATTR;" + _.toLower(cusVMP.type) + ";" + cusVMP.propertyName + ";" + cusVMP.dbValues[0] + "\n";
            }
        }
    });
    //get selected catalogue uid
    if (data.materialCatlog.dbValue !== null && data.materialCatlog.dbValue.length > 0) {
        var catalogueUid = data.materialCatlog.dbValue;
        materialSearchString = materialSearchString + "MATERIAL_CATALOG;" + catalogueUid + "\n";

        //get array of parameterList
        _.forEach(data.addMetaParamList, function (metaParam, indx) {

            var paramDataType = metaParam.propertyName.props.mat1DataType.dbValues[0];

            if (paramDataType === 'Double') {
                //include the parameter if one of the value is specified
                if (metaParam.minValue.dbValues.length > 0 || metaParam.maxValue.dbValues.length > 0) {
                    var minValue = "-1E125"; //default value
                    if (metaParam.minValue.dbValues.length > 0) {
                        minValue = metaParam.minValue.dbValues[0];
                    }
                    var maxValue = "1E125";
                    if (metaParam.maxValue.dbValues.length > 0) {
                        maxValue = metaParam.maxValue.dbValues[0];
                    }
                    materialSearchString = materialSearchString + parameterString + indx + ";" + metaParam.propertyName.uid + ";"
                        + minValue + ":" + maxValue + ";" + metaParam.mat1DerivedValueMax.dbValue.dispValue + "\n";

                }
            } else if (paramDataType === 'String' && metaParam.metaStringProperty.dbValue !== null && metaParam.metaStringProperty.dbValue.length > 0) {

                materialSearchString = materialSearchString + parameterString + indx + ";" + metaParam.propertyName.uid + ";" + metaParam.metaStringProperty.dbValue + ";" + "\n";
            }

            //MATERIAL_PARA0;iiS9BtRo5gMmEC;0.0:100.0;
        });
    }
    _.forEach(data.mat1GlobalClsList, function (matGlobalClsProp) {
        if (matGlobalClsProp.uiValue.length > 0) {
            materialSearchString = materialSearchString + "MATERIAL_CLASS;" + matGlobalClsProp.dbValue + "\n";
        }

    });
    _.forEach(data.mat1CatalogueClsList, function (matCatClsProp) {
        if (matCatClsProp.uiValue.length > 0) {
            materialSearchString = materialSearchString + "MATERIAL_CLASS;" + matCatClsProp.dbValue + "\n";
        }

    });
    //materialSearchString = "MATERIAL_NAME;Alu*\nMATERIAL_PARA0;iiS9BtRo5gMmEC;0.0:100.0;";
    ctx.materialSearchInput = materialSearchString;
    appCtxSvc.updateCtx('materialsearch', ctx);
};

export let getMaterialSearchCriteriaFromCtx = function () {
    var ctxMaterialSearch = appCtxSvc.getCtx('materialSearch');
    var materialSearchString = "";
    if (ctxMaterialSearch) {

        materialSearchString = ctxMaterialSearch.materialSearchInput;
    }
    return materialSearchString;
};

export let processIMMPreferences = function (data, ctx) {
    var immPreferences = {};
    var immStatusPrefValue = data.preferences.IMM_TC_Display_Statuses[0];
    var immCustomAttributePrefValue = data.preferences.IMM_SEARCH_MATREV_CUSTOM_ATTR;
    var statusObjList = [];
    var immStatusList = immStatusPrefValue.split(';');
    _customAttrList.splice(0, _customAttrList.length);

    for (var indx in immStatusList) {
        var releaseStatusObj = {};
        var start = immStatusList[indx].indexOf("(");
        var end = immStatusList[indx].indexOf(")");

        var dispValue = immStatusList[indx].substring(0, start);
        var internalVal = immStatusList[indx].substring(start + 1, end);

        releaseStatusObj.propDisplayValue = dispValue;
        releaseStatusObj.dispValue = dispValue;
        releaseStatusObj.propInternalValue = internalVal;

        statusObjList.push(releaseStatusObj);
    }

    for (var indx1 in immCustomAttributePrefValue) {

        if (immCustomAttributePrefValue[indx1].indexOf("#") > 0) {
            var hasIndx = immCustomAttributePrefValue[indx1].indexOf("#");
            var attributeStr = immCustomAttributePrefValue[indx1].substring(hasIndx + 1);
            var displayStr = immCustomAttributePrefValue[indx1].substring(0, hasIndx);
            var attributeList = attributeStr.split(";");

            var dataType = "STRING";
            var attrInternalName = "";

            for (var i in attributeList) {
                if (i === "0") //internal name
                {
                    attrInternalName = attributeList[i];
                } else { // data type
                    dataType = _.toUpper(attributeList[i]);
                }
            }
            var customAttr = {};
            customAttr.displayName = displayStr;

            customAttr.propName = attrInternalName;
            customAttr.type = dataType;
            customAttr.dbValue = "";
            customAttr.dispValue = displayStr;
            customAttr.uiValue = "";
            customAttr.isEditable = "true";
            customAttr.isEnabled = "true";
            customAttr.isRequired = "false";

            var customVMP = modelPropertySvc.createViewModelProperty(customAttr);
            _customAttrList.push(customVMP);

        }

    }
    immPreferences.ImmCustomAttrList = _customAttrList;
    immPreferences.ImmTcDispStatusList = listBoxSvc.createListModelObjects(statusObjList, 'dispValue', false);

    return immPreferences;
};

export let setStatusSearchParameter = function(data){

   if(data.immPreferences.ImmTcDispStatusList.length > 0){
	   data.Mtw0MaterialStatus.dbValue = [data.immPreferences.ImmTcDispStatusList[0].propInternalValue];
	   data.Mtw0MaterialStatus.uiValue = data.immPreferences.ImmTcDispStatusList[0].propDisplayValue;
   }
}

export let populatedObjectTypeList1 = function (data, ctx) {

    var ctxMaterialTypeSearch = appCtxSvc.getCtx("mtw0MaterialTypesForSearch");
    if (ctxMaterialTypeSearch) {
        return ctxMaterialTypeSearch;
    }
    var deferred = AwPromiseService.instance.defer();
    var inputData = {
        inBOTypeNames: [{
            "typeName": "Mat1MaterialRevision",
            "contextName": "subtypes",
            "exclusionPreference": ""
        }, {
            "typeName": "Mat1Material",
            "contextName": "subtypes",
            "exclusionPreference": ""
        }
        ]
    };

    var promise = soaSvc.post('Core-2013-05-DataManagement', 'getSubTypeNames',
        inputData);

    promise.then(function (response) {
        //populatedObjectTypeList
        var populateAllowedTypes = exports.populatedObjectTypeList(response);

        deferred.resolve(populateAllowedTypes);
        appCtxSvc.registerCtx("mtw0MaterialTypesForSearch", populateAllowedTypes);
    });

    return deferred.promise;
};

export let populatedObjectTypeList = function (response) {
    var materialTypeList = [];
    if (response.output) {
        for (var ii = 0; ii < response.output.length; ii++) {
            var displayableBOTypeNames = response.output[ii].displayableSubTypeNames;

            for (var jj = 0; jj < displayableBOTypeNames.length; jj++) {
                var materialObjectType = {};
                materialObjectType.propDisplayValue = displayableBOTypeNames[jj];
                materialObjectType.dispValue = displayableBOTypeNames[jj];
                materialObjectType.propInternalValue = displayableBOTypeNames[jj]; //internalBOTypeNames[jj];

                materialTypeList.push(materialObjectType);
            }
        }
    }
    //get additional material types
    var materialTypeArray = ["Latest Material Revision", "Last Material Revision with Status"];
    _.forEach(materialTypeArray, function (materialType, indx) {

        var materialObjectType = {};
        materialObjectType.propDisplayValue = materialType;
        materialObjectType.dispValue = materialType;
        materialObjectType.propInternalValue = materialType;

        materialTypeList.push(materialObjectType);
    });
    //sort in descending order
    var sortedMaterialTypeList = _.sortBy(materialTypeList, ['dispValue']).reverse();

    return listBoxSvc.createListModelObjects(sortedMaterialTypeList, 'dispValue', false);
};

/**
 * to remove parameter
 * @returns {Object} exclusion Object
 */
export let removeMetaParameter = function (commandContext) {
    if (commandContext.metaParamList) {
        commandContext.metaParamList.splice(commandContext.index, 1);
    }
};
export let setSelectedTreeNode = function (currentNode) {
    //var name =currentNode;

    var globalClsObj = {};

    var matGlobalClsVM = cdm.getObject(currentNode.node.value);
    globalClsObj.propDisplayValue = matGlobalClsVM.props.mat1MatClassPath.dbValues[0];
    globalClsObj.dispValue = matGlobalClsVM.props.object_name.uiValues[0];
    globalClsObj.propInternalValue = currentNode.node.value;
    globalClsObj.type = "STRING";
    globalClsObj.propName = currentNode.node.label;
    globalClsObj.isEditable = "false";
    globalClsObj.isEnabled = "true";
    globalClsObj.propertyLabelDisplay = 'NO_PROPERTY_LABEL';
    globalClsObj.dbValue = matGlobalClsVM.props.mat1MatClassPath.dbValues[0];
    var globalClsVMP = modelPropertySvc.createViewModelProperty(globalClsObj);
    _mat1GlobalClsList.push(globalClsVMP);
    return _mat1GlobalClsList;
};

export let loadCatalogueCls = function (data) {
    var materialParameterList = [];

    _metParamList.splice(0, _metParamList.length);
    RemoveAllAction(data);
    var selectedcatlogue = data.materialCatlog.dbValue; //data.materialCatlog.selectedLovEntries[0].propInternalValue;
    var matcatlog = cdm.getObject(selectedcatlogue);
    //var matcatlogVM = cdm.getObject( matcatlogUid );

    var metaParmeterList = matcatlog.props.mat1MetaParameters.dbValues;
    for (var metaparamIndex in metaParmeterList) {
        var metaParamVO = cdm.getObject(metaParmeterList[metaparamIndex]);
        //add only Mat1MetaSingleParameter type parameter
        if (metaParamVO.modelType.typeHierarchyArray.indexOf('Mat1MetaSingleParameter') > -1) {
            materialParameterList.push(metaParamVO);
        }
    }
    var sortedMaterialParameterList = _.sortBy(materialParameterList, ['props.object_string.dbValues[0]']);
    return listBoxSvc.createListModelObjects(sortedMaterialParameterList, 'props.object_string', true);

};

export let buildCatalogueClassTree = function (catlogueClsObjList) {
    var materialCatlogueList = [];
    var parentClassObject = {};
    for (let key in catlogueClsObjList) {

        var clsObj = cdm.getObject(catlogueClsObjList[key].matcatlogueClsUid);

        if (clsObj.props.mat1ParentClassification.dbValues[0] === null || clsObj.props.mat1ParentClassification.dbValues[0].trim().length === 0) //it is parent class
        {
            if (parentClassObject[catlogueClsObjList[key].matcatlogueClsUid] === undefined) //parent node not found
            {
                var node = {};
                node.label = catlogueClsObjList[key].name;                
                node.value = catlogueClsObjList[key].matcatlogueClsUid;
                node.children = [];
                materialCatlogueList.push(node); //push parents to list
                parentClassObject[catlogueClsObjList[key].matcatlogueClsUid] = node;

            } else { //parent class already defined

                var parentNode = parentClassObject[catlogueClsObjList[key].matcatlogueClsUid];// get parent node
                materialCatlogueList.push(parentNode); //push parents to list               
            }
        }
        else { // it is child class
            //get parent class
            var parentUid = clsObj.props.mat1ParentClassification.dbValues[0];
            var parentObj = cdm.getObject(parentUid);
            //check if parent class already defined
            if (parentClassObject[parentUid] === undefined) //parent class for child not defined
            {
                //create parent class
                var parentNode = {};
                parentNode.label = parentObj.props.object_name.dbValues[0];
                parentNode.value = parentUid;
                parentNode.children = [];
                //set parent node
                parentClassObject[parentUid] = parentNode;
                //creat child node
                if (parentClassObject[clsObj.uid] === undefined) //check if child node already exists
                {
                    var childNode = {};
                    childNode.label = clsObj.props.object_name.dbValues[0];
                    childNode.value = clsObj.uid;
                    childNode.children = [];
                    parentNode.children.push(childNode);
                    parentNode.children = _.sortBy(parentNode.children, [function (o) { return _.toLower(o.label); }]);
                    parentClassObject[clsObj.uid] = childNode;
                } else {
                    var childNode = parentClassObject[clsObj.uid];
                    parentNode.children.push(childNode);
                    parentClassObject[clsObj.uid] = childNode;
                    parentNode.children = _.sortBy(parentNode.children, [function (o) { return _.toLower(o.label); }]);
                }


                //add parent class
            }
            else { //parent class for child defined
                var parentNode = parentClassObject[parentUid];
                // parentClassObject[parentUid]=parentNode;
                if (parentClassObject[clsObj.uid] === undefined) //check if child node already exists
                {
                    //creat child node
                    var childNode = {};
                    childNode.label = clsObj.props.object_name.dbValues[0];
                    childNode.value = clsObj.uid;
                    childNode.children = [];
                    parentNode.children.push(childNode);
                    parentNode.children = _.sortBy(parentNode.children, [function (o) { return _.toLower(o.label); }]);
                    parentClassObject[clsObj.uid] = childNode;
                } else {
                    var childNode = parentClassObject[clsObj.uid];
                    parentNode.children.push(childNode);
                    parentNode.children = _.sortBy(parentNode.children, [function (o) { return _.toLower(o.label); }]);
                    parentClassObject[clsObj.uid] = childNode;
                }
            }
        }

    }
    var orderedCatClsList = _.sortBy(materialCatlogueList, [function (o) { return _.toLower(o.label); }]);
    return orderedCatClsList;
};

export let setSelectedCatalogueTreeNode = function (currentNode) {

    var match = false;
	if(_mat1CatlogueClsList.length >= 1) {
		for (let key in _mat1CatlogueClsList) {
			if(_mat1CatlogueClsList[key].uiValue == currentNode.node.label) {
				match = true;
				break;
			}
		}
	}
	if(!match) {
	    var catlogueClsObj = {};
		var matCatlogueClsVM = cdm.getObject(currentNode.node.value);
		catlogueClsObj.propDisplayValue = matCatlogueClsVM.props.mat1MatClassPath.dbValues[0];
		catlogueClsObj.dispValue = matCatlogueClsVM.props.object_name.uiValues[0];
		catlogueClsObj.propInternalValue = currentNode.node.value;
		catlogueClsObj.type = "STRING";
		catlogueClsObj.propName = currentNode.node.label;
		catlogueClsObj.isEditable = "false";
		catlogueClsObj.isEnabled = "true";
		catlogueClsObj.propertyLabelDisplay = 'NO_PROPERTY_LABEL';
		catlogueClsObj.dbValue = currentNode.node.label;
		var catalogueClsVMP = modelPropertySvc.createViewModelProperty(catlogueClsObj);
        _mat1CatlogueClsList.push(catalogueClsVMP);
	}
    return _mat1CatlogueClsList;
};

/**
 * Call SOA for getMaterialSearchAttributes with Property Policy Override
 *
 * @param {Object} propertyPolicyOverride Property Policy
 * @returns {Object} - Json object
 */
export let getMaterialSearchAttributes = function (propertyPolicyOverride) {
    let inputData = {
        'findList': [
            {
                'criterias': [
                    {
                        'objectType': 'Mat1UnitAltName',
                        'objectName': '',
                        'scope': 'WSO_scope_All',
                        'owner': '',
                        'group': '',
                        'createdBefore': '',
                        'modifiedBefore': '',
                        'releasedBefore': '',
                        'createdAfter': '',
                        'modifiedAfter': '',
                        'releasedAfter': ''
                    },
                    {
                        'objectType': 'Mat1MatCatalog',
                        'objectName': '',
                        'scope': 'WSO_scope_All',
                        'owner': '',
                        'group': '',
                        'createdBefore': '',
                        'modifiedBefore': '',
                        'releasedBefore': '',
                        'createdAfter': '',
                        'modifiedAfter': '',
                        'releasedAfter': ''
                    },
                    {
                        'objectType': 'Mat1MatClassification',
                        'objectName': '',
                        'scope': 'WSO_scope_All',
                        'owner': '',
                        'group': '',
                        'createdBefore': '',
                        'modifiedBefore': '',
                        'releasedBefore': '',
                        'createdAfter': '',
                        'modifiedAfter': '',
                        'releasedAfter': ''
                    }
                ]
            }
        ]
    };
    return soaSvc.post('Query-2007-06-Finder', 'findWorkspaceObjects', inputData, propertyPolicyOverride);
};

/**
 * Call SOA for searchMaterialAsychc with Property Policy Override
 *
 * @param {Object} inputData Input Data for SOA call
 * @param {Object} propertyPolicyOverride Property Policy
 * @returns {Object} - Json object
 */
export let searchMaterialAsychc = function (inputData, propertyPolicyOverride) {
    return soaSvc.post('IMM-2017-05-IMMSearch', 'searchMaterial', inputData, propertyPolicyOverride);
};


export default exports = {
    processMaterialCatalogues,
    loadMaterialMetaParameters,
    addToParameterList,
    RemoveAllAction,
    processDerivedUnit,
    getDerived,
    getDerivedList,
    procesMaterialSearchResult,
    setMaterialSearchCriteriaToCtx,
    getMaterialSearchCriteriaFromCtx,
    processIMMPreferences,
    populatedObjectTypeList,
    setMaterialType,
    removeMetaParameter,
    clearAllAction,
    populatedObjectTypeList1,
    processMaterialClassifiction,
    buildGlobalClassTree,
    setSelectedTreeNode,
    loadCatalogueCls,
    buildCatalogueClassTree,
    setSelectedCatalogueTreeNode,
    getMaterialSearchAttributes,
    searchMaterialAsychc,
    setStatusSearchParameter
};

app.factory('Mtw0AdvanceMaterialSearch', () => exports);
