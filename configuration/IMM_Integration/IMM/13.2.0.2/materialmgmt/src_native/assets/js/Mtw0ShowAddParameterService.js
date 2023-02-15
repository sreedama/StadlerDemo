// @<COPYRIGHT>@
// ==================================================
// Copyright 2018.
// Siemens Product Lifecycle Management Software Inc.
// All Rights Reserved.
// ==================================================
// @<COPYRIGHT>@

/*global
define
 */

/**
 * @module js/Mtw0ShowAddParameterService
 */
import app from 'app';
import _ from 'lodash';
import appCtxSvc from 'js/appCtxService';
import commandPanelService from 'js/commandPanel.service';
import addObjectUtils from 'js/addObjectUtils';
import adapterSvc from 'js/adapterService';
import localeSvc from 'js/localeService';
import dmSrv from 'soa/dataManagementService';
import propertyPolicySrv from 'soa/kernel/propertyPolicyService';
import clientDataMgmt from 'soa/kernel/clientDataModel';
import soaSvc from 'soa/kernel/soaService';
import eventBus from 'js/eventBus';

var exports = {};

var mat1Parameters = [];
var mat1InHeritedParameters = [];
var unitLabel = "Unit";
var typeLabel = "Type";
var smartTableType = "SmartTable";
var categoryLabel = "Category";

var gCommandId = null;
/**
 * This method sets the Relation and the Secondary object in context when xrt object-set 'Add to' command is
 * clicked.
 *
 * @param {data}{ctx} data , ctx
 * @return {ObjectArray} input data
 */
export let activateShowAddParameterPanel = function (commandId, location, data, ctx, objectSetSource) {

    gCommandId = commandId;
    localeSvc.getLocalizedText(app.getBaseUrlPath() + "/i18n/MaterialMgmtMessages",
        "PropType").then(function (result) {
        typeLabel = result;
    });
    localeSvc.getLocalizedText(app.getBaseUrlPath() + "/i18n/MaterialMgmtMessages",
        "Unit").then(function (result) {
        unitLabel = result;
    });
    localeSvc.getLocalizedText(app.getBaseUrlPath() + "/i18n/MaterialMgmtMessages",
        "SmartTableType").then(function (result) {
        smartTableType = result;
    });
    localeSvc.getLocalizedText(app.getBaseUrlPath() + "/i18n/MaterialMgmtMessages",
        "Category").then(function (result) {
        categoryLabel = result;
    });

    if (commandId === 'Mtw0AddSmartTable') {
        /**
         * We are reusing "Add Parameter" panel
         * So need to fool system by saying command is "Mtw0ShowAddParameter"
         */
        commandId = "Mtw0ShowAddParameter";
    }
    commandPanelService.activateCommandPanel(commandId, location);

};

/**
 * This method sets the Relation and the Secondary object in context when xrt object-set 'Add to' command is
 * clicked.
 *
 * @param {data}{ctx} data , ctx
 * @return {ObjectArray} input data
 */
export let activateShowAddParameterDescriptorPanel = function (commandId, location, data, ctx, objectSetSource) {
    var inputData = [];
    var secondaryObjFromObjectSource = null;
    var secondaryObjForXrtCreate = null;
    var relationSecondaryObjArr = objectSetSource.split(".");
    secondaryObjFromObjectSource = relationSecondaryObjArr[1];
    if (_.endsWith(secondaryObjFromObjectSource, 'Revision')) {
        var a = secondaryObjFromObjectSource.indexOf("Revision");
        secondaryObjForXrtCreate = secondaryObjFromObjectSource.substring(0, a).trim();

    } else {
        secondaryObjForXrtCreate = secondaryObjFromObjectSource;
    }
    ctx.secondaryObjFromObjectSource = secondaryObjFromObjectSource;
    ctx.secondaryObjForXrtCreate = secondaryObjForXrtCreate;
    ctx.relation = relationSecondaryObjArr[0];
    commandPanelService.activateCommandPanel(commandId, location);

};

/**
 * This method sets the Relation and the Secondary object in context when xrt object-set 'Add to' command is
 * clicked.
 *
 * @param {data}{ctx} data , ctx
 * @return {ObjectArray} input data
 */
export let activateShowAddSmartTableParameterDescriptorPanel = function (commandId, location, data, ctx, objectSetSource) {
    var inputData = [];
    var secondaryObjFromObjectSource = null;
    var secondaryObjForXrtCreate = null;
    var relationSecondaryObjArr = objectSetSource.split(".");
    secondaryObjFromObjectSource = relationSecondaryObjArr[1];
    if (_.endsWith(secondaryObjFromObjectSource, 'Revision')) {
        var a = secondaryObjFromObjectSource.indexOf("Revision");
        secondaryObjForXrtCreate = secondaryObjFromObjectSource.substring(0, a).trim();

    } else {
        secondaryObjForXrtCreate = secondaryObjFromObjectSource;
    }
    ctx.secondaryObjFromObjectSource = secondaryObjFromObjectSource;
    ctx.secondaryObjForXrtCreate = secondaryObjForXrtCreate;
    ctx.relation = relationSecondaryObjArr[0];
    commandPanelService.activateCommandPanel(commandId, location);

};

/**
 * This method prepares secondary object and the relation object data when the 'New' panel comes up.
 *
 * @param {data}{ctx} data , ctx
 * @return {ObjectArray} input data
 */
export let prepareDataOnEachXrtLoad = function (data, ctx) {
    var inputData = [];
    var secondaryObjectInfo = {};
    if (data.objCreateInfo.createType !== ctx.relation) {
        data.secondaryObjectInfo = data.objCreateInfo;
    } else {
        data.relationObjectInfo = data.objCreateInfo;
    }
};

/**
 * This method prepares input for Secondary object for createRelateAndSubmit SOA.
 *
 * @param {Object} data - The panel's view model object
 */
export let getSecondaryObjectCreateInput = function (data) {

    data.objCreateInfo = data.secondaryObjectInfo;
    var inputs = addObjectUtils.getCreateInput(data);
    return inputs;
};

/**
 * This method returns output of createRelateAndSubmit SOA operation.
 *
 * @param {Object} data - The panel's view model object
 */
export let getCreatedSecondaryObject = function (response) {
    var newObjects = [];
    newObjects = addObjectUtils.getCreatedObject(response);
    return newObjects;
};

/**
 * This method creates input data required for "createObjects" SOA for relating secondary object with primary
 * object.
 *
 * @param {data}{ctx} data , ctx
 * @return {ObjectArray} input data
 */
export let getInputForCreateObjectSOA = function (data, ctx) {
    var inputData = [];
    var dataVal = prepareDataForCreateObjectSOA(data, ctx);
    var input = {
        clientId: "",
        data: dataVal
    };
    inputData.push(input);
    return inputData;

};

/**
 * Private method to create input data required for "createObjects" SOA.
 *
 * @param {data}{ctx} data , ctx
 * @return {ObjectArray} input data
 */
var prepareDataForCreateObjectSOA = function (data, ctx) {
    var doubleObj = {};
    var boolObj = {};
    var strObj = {};
    var tagObj = {};

    if (data.selectedTab.panelId === 'Mtw0ShowAddObjectPaletteTab' ||
        data.selectedTab.panelId === 'Mtw0ShowAddObjectSearchResultsTab') {
        data.relationObjectInfo = data.objCreateInfo;
    }

    _.forEach(data.relationObjectInfo.propNamesForCreate, function (propName) {
        var vmProp = _.get(data, propName);
        if (vmProp.type === 'DOUBLE') {
            doubleObj[vmProp.propertyName] = vmProp.dbValue;
        }
        if (vmProp.type === 'BOOLEAN') {
            boolObj[vmProp.propertyName] = vmProp.dbValue;
        }
        if (vmProp.type === 'STRING') {
            strObj[vmProp.propertyName] = vmProp.dbValue;
        }
    });

    var primaryObjInfo = {
        uid: ctx.mselected[0].uid,
        type: ctx.mselected[0].type
    };
    var secondary_object = {};
    if (data.selectedTab.panelId === 'Mtw0ShowAddObjectNewTab') {
        if (_.endsWith(ctx.secondaryObjFromObjectSource, 'Revision')) {
            secondary_object = {
                uid: data.createdObject.uid,
                type: data.createdObject.type
            };
        } else {
            secondary_object = {
                uid: data.createdMainObject.uid,
                type: data.createdMainObject.type
            };
        }
    } else if (data.selectedTab.panelId === 'Mtw0ShowAddObjectPaletteTab') {
        secondary_object = getClipboardFavouriteRecentSelection(ctx);
    } else if (data.selectedTab.panelId === 'Mtw0ShowAddObjectSearchResultsTab') {
        secondary_object = {
            uid: data.dataProviders.performSearch.selectedObjects[0].uid,
            type: data.dataProviders.performSearch.selectedObjects[0].type
        };
    }

    tagObj = {
        primary_object: primaryObjInfo,
        secondary_object: secondary_object
    };
    var createInputRelObject = {
        boName: ctx.relation,
        doubleProps: doubleObj,
        boolProps: boolObj,
        stringProps: strObj,
        tagProps: tagObj
    };
    return createInputRelObject;
};

/**
 * This private function gets the selected Secondary Object to be related from the various
 * Clipboard/Favourites/Recent Providers
 *
 * @param {Object} ctx
 */
var getClipboardFavouriteRecentSelection = function (ctx) {
    var selectedPaletteObj = {};

    if (ctx.getClipboardProvider.selectedObjects.length > 0) {
        selectedPaletteObj = {
            uid: ctx.getClipboardProvider.selectedObjects[0].uid,
            type: ctx.getClipboardProvider.selectedObjects[0].type
        };
    }
    if (ctx.getFavoriteProvider.selectedObjects.length > 0) {
        selectedPaletteObj = {
            uid: ctx.getFavoriteProvider.selectedObjects[0].uid,
            type: ctx.getFavoriteProvider.selectedObjects[0].type
        };
    }
    if (ctx.getRecentObjsProvider.selectedObjects.length > 0) {
        selectedPaletteObj = {
            uid: ctx.getRecentObjsProvider.selectedObjects[0].uid,
            type: ctx.getRecentObjsProvider.selectedObjects[0].type
        };
    }
    return selectedPaletteObj;
};
/**
 * JS function to set type filter to be used for search
 *
 * @param {Object} data - The panel's view model object
 * @param {Object} typeFilter - object type
 */
export let setTypefilterAndSearch = function (data, typefilter) {
    if (data) {
        data.typeFilter = typefilter;
        addObjectUtils.findSubBusinessObjectsAndInvokeSearch(data);
    }

};

export let getSelectedObject = function (selectedObject, data) {
    var retObject = new Object();
    
    if (selectedObject.type === 'Mat1ParameterSmartTable') {
        selectedObject = clientDataMgmt.getObject(selectedObject.props.mat1OwningMaterialRevision.dbValues[0]);
    }
	
	  retObject = selectedObject;
    exports.filterValue = data.filterBox.dbValue;	
	  return selectedObject;
    
};

/**
 * get metaParametersArray from catalog property
 */
export let getMetaParametersArray = function (response) {

    var objects = response.modelObjects;
    var retObject = new Object();
    var metaParametersArray = [];
    var i = 0;
    var j = 0;

    for (var key in response.modelObjects) {
        var object = objects[key];

        /**
         * If we are showing single parameter, we don't show smart-table
         * and if we are adding Smart-Table, then we do not show any other parameters.
         */
        if ((gCommandId === 'Mtw0ShowAddParameter' && object.type === "Mat1MetaSingleParameter") || (gCommandId === 'Mtw0AddSmartTable' && object.type === "Mat1MetaSmartTable")) {
            var regExp = new RegExp(exports.filterValue.toUpperCase().replace("*", ".*"));

            if (object.props.object_string.uiValues[0].toUpperCase().match(regExp)) {

                // remove unwanted properties
                object.props.awp0CellProperties.dbValues.pop();
                object.props.awp0CellProperties.dbValues.pop();

                // add new dbValues
                if (object.type === "Mat1MetaSmartTable") {
                    object.props.awp0CellProperties.dbValues.push(unitLabel + "\\:" + object.props.mat1UnitYAliasName.dbValues[0] + ' Vs ' + object.props.mat1UnitXAliasName.dbValues[0]);
                    object.props.awp0CellProperties.dbValues.push(typeLabel + "\\:" + smartTableType);
                } else {
                    object.props.awp0CellProperties.dbValues.push(unitLabel + "\\:" + object.props.mat1UnitAliasName.dbValues[0]);
                    object.props.awp0CellProperties.dbValues.push(typeLabel + "\\:" + object.props.mat1DataType.dbValues[0]);
                }
                var categoryDBValue = object.props.mat1Category.isNulls ? "" : object.props.mat1Category.dbValues[0];
                object.props.awp0CellProperties.dbValues.push(categoryLabel + "\\:" + categoryDBValue);

                // set ui values
                object.props.awp0CellProperties.uiValues.pop();
                object.props.awp0CellProperties.uiValues.pop();
                if (object.type === "Mat1MetaSmartTable") {
                    object.props.awp0CellProperties.uiValues.push(unitLabel + "\\:" + object.props.mat1UnitYAliasName.uiValues[0] + ' Vs ' + object.props.mat1UnitXAliasName.uiValues[0]);
                    object.props.awp0CellProperties.uiValues.push(typeLabel + "\\:" + smartTableType);
                } else {
                    object.props.awp0CellProperties.uiValues.push(unitLabel + "\\:" + object.props.mat1UnitAliasName.uiValues[0]);
                    object.props.awp0CellProperties.uiValues.push(typeLabel + "\\:" + object.props.mat1DataType.uiValues[0]);
                }
                var categoryUIValue = object.props.mat1Category.isNulls ? "" : object.props.mat1Category.uiValues[0];
                object.props.awp0CellProperties.uiValues.push(categoryLabel + "\\:" + categoryUIValue);

                metaParametersArray[j] = object;
                j++;
            }

            i++;
        }
    }

    retObject.totalResults = j;
    retObject.searchResults = metaParametersArray;
    return retObject;
};

/**
 * get  export let getReferenceMetaParametersArray = function (response) {
 from catalog property
 */
export let getReferenceMetaParametersArray = function (response) {

    var objects = response.modelObjects;
    var retObject = new Object();
    var metaParametersArray = [];
    var i = 0;
    var j = 0;

    for (var key in response.modelObjects) {
        var object = objects[key];

        /**
         * If we are showing single parameter, we don't show smart-table
         * and if we are adding Smart-Table, then we do not show any other parameters.
         */
        if ((object.type === "Mat1MetaSingleParameter")) {
            var regExp = new RegExp(exports.filterValue.toUpperCase().replace("*", ".*"));

            if (object.props.object_string.uiValues[0].toUpperCase().match(regExp)) {

                // remove unwanted properties
                object.props.awp0CellProperties.dbValues.pop();
                object.props.awp0CellProperties.dbValues.pop();

                // add new dbValues
                /*if (object.type === "Mat1MetaSmartTable") {
                    object.props.awp0CellProperties.dbValues.push(unitLabel + "\\:" + object.props.mat1UnitYAliasName.dbValues[0] + ' Vs ' + object.props.mat1UnitXAliasName.dbValues[0]);
                    object.props.awp0CellProperties.dbValues.push(typeLabel + "\\:" + smartTableType);*/
                // } else {
                object.props.awp0CellProperties.dbValues.push(unitLabel + "\\:" + object.props.mat1UnitAliasName.dbValues[0]);
                object.props.awp0CellProperties.dbValues.push(typeLabel + "\\:" + object.props.mat1DataType.dbValues[0]);
                //}
                var categoryDBValue = object.props.mat1Category.isNulls ? "" : object.props.mat1Category.dbValues[0];
                object.props.awp0CellProperties.dbValues.push(categoryLabel + "\\:" + categoryDBValue);

                // set ui values
                object.props.awp0CellProperties.uiValues.pop();
                object.props.awp0CellProperties.uiValues.pop();
                /**if (object.type === "Mat1MetaSmartTable") {
                    object.props.awp0CellProperties.uiValues.push(unitLabel + "\\:" + object.props.mat1UnitYAliasName.uiValues[0] + ' Vs ' + object.props.mat1UnitXAliasName.uiValues[0]);
                    object.props.awp0CellProperties.uiValues.push(typeLabel + "\\:" + smartTableType);
                } else { **/
                object.props.awp0CellProperties.uiValues.push(unitLabel + "\\:" + object.props.mat1UnitAliasName.uiValues[0]);
                object.props.awp0CellProperties.uiValues.push(typeLabel + "\\:" + object.props.mat1DataType.uiValues[0]);
                // }
                var categoryUIValue = object.props.mat1Category.isNulls ? "" : object.props.mat1Category.uiValues[0];
                object.props.awp0CellProperties.uiValues.push(categoryLabel + "\\:" + categoryUIValue);

                metaParametersArray[j] = object;
                j++;
            }

            i++;
        }
    }

    retObject.totalResults = j;
    retObject.searchResults = metaParametersArray;
    return retObject;
};

/**
 * get underlying BO for relatedModified
 *
 * @return {input} adapted object
 */
export let adaptedRelatedModifiedInput = function () {
    return adapterSvc.getAdaptedObjectsSync([appCtxSvc.ctx.pselected]);
};

export let getSelectedParametersArray = function (objects) {
    var selectedParameters = [];

    if (objects !== null) {

        for (var i in objects) {

            var selectedObject = objects[i];
            var selectedParametersIp = {
                "type": selectedObject.type,
                "uid": selectedObject.uid
            };

            selectedParameters.push(selectedParametersIp);
        }
    }

    return selectedParameters;
};

/**
 * get selected metaParameters from list
 */
export let getSelectedMetaParametersArray = function (response) {

    var selectedMetaParameters = [];

    if (response && response.dataProviders !== null &&
        response.dataProviders.performSearch && response.dataProviders.performSearch !== null &&
        response.dataProviders.performSearch.selectedObjects && response.dataProviders.performSearch.selectedObjects !== null) {

        for (var i in response.dataProviders.performSearch.selectedObjects) {

            var selectedObject = response.dataProviders.performSearch.selectedObjects[i];
            var selectedMetaParametersIp = {
                "type": selectedObject.type,
                "uid": selectedObject.uid
            };

            selectedMetaParameters.push(selectedMetaParametersIp);

        }

    }

    return selectedMetaParameters;
};

/***
 * Overrides the selected InheritedParameters.
 *
 * sequence of SOAs
 * 1. getProperties - to retrieve details of inherted parameter, its' parameter, its' metaparameter
 * 2. createRelateAndSubmitObjects2 - to create new child of Mat1Parameter either double or string or table depending on selected Inherited Parameter
 * 3. setProperties - to set values on newly created Mat1Parameter. To-Do - smart table is not yet handled.
 * 4. deleteObjects - to delete the selected inherited parameters, as those are now overriden.
 */
export let overrideInheritedParameters = function (response, ctx, data) {

    var policyId = propertyPolicySrv.register({
        types: [{
                name: 'BusinessObject',
                properties: [{
                        name: 'object_string'
                    }, {
                        name: 'object_type'
                    }, {
                        name: 'object_name'
                    }
                ]
            }, {
                name: 'Mat1Parameter',
                properties: [{
                        name: 'mat1MetaParameter',
                        modifiers: [{
                                name: 'withProperties',
                                Value: 'true'
                            }
                        ]
                    }
                ]
            }, {
                name: 'Mat1ParameterDouble',
                properties: [{
                        name: 'mat1Value'
                    }, {
                        name: 'mat1ValueMax'
                    }, {
                        name: 'mat1IsInRange'
                    }
                ]
            }, {
                name: 'Mat1ParameterString',
                properties: [{
                        name: 'mat1Value'
                    }
                ]
            }
        ]
    });

    var selectedMetaParameters = [];
    mat1Parameters = [];
    mat1InHeritedParameters = [];

    if (ctx && ctx.mselected !== null) {

        var selectedInheritedParameters = [];
        var createInputsArr = [];
        for (var i in ctx.mselected) {
            selectedInheritedParameters.push(ctx.mselected[i].uid);
            var mat1InHeritedParameter = clientDataMgmt.getObject(ctx.mselected[i].uid);
            var mat1Parameter = clientDataMgmt.getObject(mat1InHeritedParameter.props.mat1Parameter.dbValues[0]);
            var mat1MetaParameter = clientDataMgmt.getObject(mat1Parameter.props.mat1MetaParameter.dbValues[0]);

            mat1InHeritedParameters.push(mat1InHeritedParameter);
            mat1Parameters.push(mat1Parameter);
            var selectedMetaParametersIp = {
                "type": mat1MetaParameter.type,
                "uid": mat1MetaParameter.uid
            };

            selectedMetaParameters.push(selectedMetaParametersIp);

            var createInput = {
                dataToBeRelated: "",
                pasteProp: "",
                targetObject: "",
                clientId: "CreateObject",
                createData: {
                    boName: mat1Parameter.type,
                    propertyNameValues: {
                        object_name: [mat1Parameter.props.object_name.dbValues[0]],
                        mat1MetaParameter: [mat1MetaParameter.uid],
                        mat1OwningMaterialRevision: [ctx.pselected.uid]
                    },
                    compoundCreateInput: ""
                }
            };
            createInputsArr.push(createInput);
        }
        var createInputs = {
            createInputs: createInputsArr
        };

        return soaSvc.post('Core-2015-07-DataManagement', 'createRelateAndSubmitObjects2', createInputs).then(function (response) {
            var createdParameters = response.ServiceData.created;
            if (createdParameters !== null) {
                var setPropertiesInput = [];
                for (var ii in createdParameters) {
                    var mat1Parameter = response.ServiceData.modelObjects[createdParameters[ii]];
                    for (var jj in mat1Parameters) {
                        var mat1MetaParameter = clientDataMgmt.getObject(mat1Parameters[jj].props.mat1MetaParameter.dbValues[0]);
                        if (mat1Parameter.props.mat1MetaParameter.dbValues[0] === mat1MetaParameter.uid) {
                            var vecNameVal = [];
                            if (mat1Parameter.type === 'Mat1ParameterDouble') {
                                vecNameVal = [{
                                        name: 'mat1Value',
                                        values: [mat1Parameters[jj].props.mat1Value.dbValues[0]]
                                    }, {
                                        name: 'mat1ValueMax',
                                        values: [mat1Parameters[jj].props.mat1ValueMax.dbValues[0]]
                                    }
                                ];
                            } else {
                                vecNameVal = [{
                                        name: 'mat1Value',
                                        values: [mat1Parameters[jj].props.mat1Value.dbValues[0]]
                                    }
                                ];

                            }
                            var paramUpdateInput = {
                                object: {
                                    uid: mat1Parameter.uid,
                                    type: mat1Parameter.type
                                },
                                vecNameVal: vecNameVal,
                                timestamp: ""
                            };
                            setPropertiesInput.push(paramUpdateInput);
                        }
                    }
                }

                return dmSrv.setProperties(setPropertiesInput).then(function () {
                    return soaSvc.post('Core-2006-03-DataManagement', 'deleteObjects', {
                        objects: mat1InHeritedParameters
                    }).then(function () {
                        eventBus.publish('cdm.relatedModified', {
                            relatedModified: [appCtxSvc.ctx.pselected]
                            // We could pass refreshLocationFlag: true
                            // But then it would refresh the 'Parameters' page, which is not needed.
                            // this even will cause rows to be refreshed in the table, rather than need to refresh entire page.
                        });
                    });
                });
                propertyPolicySrv.unregister(policyId);
            }
            return mat1Parameters;
        });
    }
};

/**
 * Handle Import command select
 * @param {Object} data The panel's view model object
 */
export let setSelectedTypeSelectionJs = function (data) {
    var selectedType = data.dataProviders.performSearch.selectedObjects;
    if (selectedType && selectedType.length > 0) {
        data.selectedType.dbValue = selectedType[0].internalName;
        /**appCtxSvc.registerCtx( "mtw0SelectedRefParameter", {
           "mtw0RefParamName":selectedType[0]
        } );*/
        data.mat1RefDataType.dbValue = selectedType[0].props.mat1DataType.dbValues[0];
        data.mat1RefDataType.dispValue = selectedType[0].props.mat1DataType.uiValues[0]

        data.mat1RefParamName.dbValue = selectedType[0].props.object_string.dbValues[0];
        data.mat1RefParamName.dbValue = selectedType[0].props.object_string.dbValues[0];

    }
};

/**
 * Clear selected type when user click on back button on create form
 * @param {Object} data - The create change panel's view model object
 */
export let clearSelectedType = function (data) {
    data.selectedType.dbValue = '';
    data.mat1RefDataType.dbValue = "";
    data.mat1RefDataType.dispValue = "";

    data.mat1RefParamName.dbValue = "";
    data.mat1RefParamName.dispValue = "";
    data.mat1RefParamStringValue.dbValue = "";
    data.mat1RefParamStringValue.dispValue = "";
    data.mat1RefParamValueMax.dbValue = "";
    data.mat1RefParamValueMax.dispValue = "";
    data.mat1RefParamValue.dbValue = "";
    data.mat1RefParamValue.dispValue = "";
    data.mat1RefParamUnit.dbValue = "";
    data.mat1RefParamUnit.dispValue = "";
    //appCtxSvc.unRegisterCtx( "mtw0SelectedRefParameter");
};

/**
 * Private method to create input data required for "createObjects" SOA.
 *
 * @param {data}{ctx} data , ctx
 * @return {ObjectArray} input data
 */
export let createAndAddReferenceParameter = function (data, ctx) {
    var doubleObj = {};
    var strObj = {};
    var boolObj = {};
    var tagObj = {};
    var boType;

    //Mat1ParameterString

    if (data.mat1RefDataType.dbValue === 'String') {
        boType = 'Mat1ParameterString';
        strObj['mat1Value'] = data.mat1RefParamStringValue.dbValue;
        strObj['object_name'] = data.mat1RefParamName.dbValue;
    } else {
        boType = 'Mat1ParameterDouble';
        strObj['object_name'] = data.mat1RefParamName.dbValue;
        doubleObj['mat1Value'] = parseFloat(data.mat1RefParamValue.dbValue);
        doubleObj['mat1ValueMax'] = parseFloat(data.mat1RefParamValueMax.dbValue);
        strObj['mat1UnitName'] = data.mat1RefParamUnit.dbValue;
        boolObj['mat1IsInRange'] = true;


    }

    return dmSrv.createObjects([{
        data: {
            boName: boType,
            doubleProps: doubleObj,
            stringProps: strObj,
            boolProps: boolObj
        }
    }]).then(
        function (response) {
            var refParamObj = response.output[0].objects[0]
            if (refParamObj !== null) {
                var params = ctx.mselected[0].props.mat1ListOfRefParameters.dbValues;
                var refParams = [];
                for(var key in params) {
                    refParams.push(params[key]);
                }
                refParams.push(refParamObj.uid);
                var setPropertiesInput = [
                    {
                        "object": {
                            "uid": ctx.mselected[0].uid,
                            "type": ctx.mselected[0].type
                        },
                        "vecNameVal": [
                            {
                                "name": "mat1ListOfRefParameters",
                                "values": refParams
                            }
                        ]
                    }
                ];
            
	    // Close export panel
	    var eventData = { source: 'toolAndInfoPanel' };
	    eventBus.publish( 'complete', eventData );

            return dmSrv.setProperties(setPropertiesInput).then(function () {
                eventBus.publish('cdm.relatedModified', {
                    relatedModified: [appCtxSvc.ctx.selected]
                    // We could pass refreshLocationFlag: true
                    // But then it would refresh the 'Parameters' page, which is not needed.
                    // this even will cause rows to be refreshed in the table, rather than need to refresh entire page.

                });
            });
        }
        });


};

export default exports = {
    activateShowAddParameterPanel,
    activateShowAddParameterDescriptorPanel,
    activateShowAddSmartTableParameterDescriptorPanel,
    prepareDataOnEachXrtLoad,
    getSecondaryObjectCreateInput,
    getCreatedSecondaryObject,
    getInputForCreateObjectSOA,
    setTypefilterAndSearch,
    getSelectedObject,
    getMetaParametersArray,
    adaptedRelatedModifiedInput,
    getSelectedParametersArray,
    getSelectedMetaParametersArray,
    overrideInheritedParameters,
    getReferenceMetaParametersArray,
    setSelectedTypeSelectionJs,
    clearSelectedType,
    createAndAddReferenceParameter
};
/**
 * Show Add object panel service utility
 *
 * @memberof NgServices
 * @member Mtw0ShowAddObjectService
 */
app.factory('Mtw0ShowAddParameterService', () => exports);
