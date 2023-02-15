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
 * @module js/Mtw0ShowAddMetaSingleParameterService
 */
import app from 'app';
import soaSvc from 'soa/kernel/soaService';
import commandPanelService from 'js/commandPanel.service';
import _ from 'lodash';
import listBoxSvc from 'js/listBoxService';
import addObjectUtils from 'js/addObjectUtils';
import AwPromiseService from 'js/awPromiseService';

var exports = {};

/**
 * This method sets the Relation and the Secondary object in context when xrt object-set 'Add to' command is
 * clicked.
 *
 * @param {data}{ctx} data , ctx
 * @return {ObjectArray} input data
 */
export let activateShowAddMetaSingleParameterPanel = function (commandId, location, data, ctx, objectSetSource) {
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
    retObject = selectedObject;
    exports.filterValue = data.filterBox.dbValue === "" ? "*" : data.filterBox.dbValue;
    return selectedObject;
};

export let populateListBoxes = function (data) {
    var deferred = AwPromiseService.instance.defer();
    soaSvc.post('IMM-2018-12-AWCMaterialMgmtService', 'getMetaParamDetails', {}).then(
        function (response) {

        if (response && response.categories) {

            var categories = [];
            data.categories.type = "STRING";

            for (var i in response.categories) {

                var category = response.categories[i];

                var categoryEntry = {};
                categoryEntry.propDisplayValue = category;
                categoryEntry.propDisplayDescription = category;
                categoryEntry.dispValue = category;
                categoryEntry.propInternalValue = category;

                data.categories.dbValue.push(categoryEntry);
            }
        }

        if (response && response.dimensions) {

            var dimensions = [];
            data.dimensions.type = "STRING";

            for (var i in response.dimensions) {

                var dimension = response.dimensions[i];

                var dimensionEntry = {};
                dimensionEntry.propDisplayValue = dimension;
                dimensionEntry.propDisplayDescription = dimension;
                dimensionEntry.dispValue = dimension;
                dimensionEntry.propInternalValue = dimension;

                data.dimensions.dbValue.push(dimensionEntry);
            }
        }

    },
        function (err) {
        deferred.reject(err);
    });

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

        if (object.type === "Mat1MetaSmartTable" || object.type === "Mat1MetaSmartTable" || object.type === "Mat1MetaSingleParameter") {
            var regExp = new RegExp(exports.filterValue.replace("*", ".*"));

            if (object.props.object_string.uiValues[0].match(regExp)) {
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

export default exports = {
    activateShowAddMetaSingleParameterPanel,
    prepareDataOnEachXrtLoad,
    getSecondaryObjectCreateInput,
    getCreatedSecondaryObject,
    getInputForCreateObjectSOA,
    setTypefilterAndSearch,
    getSelectedObject,
    populateListBoxes,
    getMetaParametersArray,
    getSelectedParametersArray
};

app.factory('Mtw0ShowAddMetaSingleParameterService', () => exports);
