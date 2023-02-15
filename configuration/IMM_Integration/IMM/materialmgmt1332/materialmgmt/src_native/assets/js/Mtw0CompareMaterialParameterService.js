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
 * @module js/Mtw0CompareMaterialParameterService
 */
import app from 'app';
import appCtxSvc from 'js/appCtxService';
import _ from 'lodash';
import cdm from 'soa/kernel/clientDataModel';
import listBoxSvc from 'js/listBoxService';
import modelPropertySvc from 'js/modelPropertyService';
var exports = {};

var _metParamList = [];

/**
 * Compare Widget it kind of table but inverted one. So columns of table become rows in compare and rows become column.
 * So we need to add parameters as columns to table.
 */

export let processSelectedObjects = function (ctx) {
    var selectedObject = [];
    var inputGetProperties = [];
    var selObject = [];
    inputGetProperties.push(appCtxSvc.ctx.user);
    selectedObject = _.clone(appCtxSvc.ctx.selected);
    for (var i = 0; i < selectedObject.length; i++) {
        inputGetProperties.push(selectedObject[i]);
        selObject.push(selectedObject[i]);
    }
    //exports.setContext( null, selObject );
    return inputGetProperties;
};

/**
 * Builds data for the compare section.
 * Parameter names are built on the fly
 * Name is attached with unit and in case of reference parameters, those are attached to original parameter name.
 *
 * @param {*} response
 */
export let Mtw0GenerateMaterialComparatorData = function (response) {

    var materialObjectList = new Object();
    var materialArray = [];
    for (var index in response.plain) {
        var testMO = cdm.getObject(response.plain[index]);

        var matParameters = testMO.props.mat1Parameters.dbValues;
        for (var paramIndex in matParameters) {
            var matParamMO = cdm.getObject(matParameters[paramIndex]);
            /*
             * We only compare string & double parameters.
             */
            if (matParamMO && matParamMO.modelType && (matParamMO.modelType.typeHierarchyArray.indexOf('Mat1ParameterString') > -1 || matParamMO.modelType.typeHierarchyArray.indexOf(
                        'Mat1ParameterDouble') > -1)) {

                /*
                 * Get parameter name.
                 */
                var paramName = buildParamName(matParamMO);
                if (matParamMO.modelType.typeHierarchyArray.indexOf('Mat1ParameterString') > -1) {
                    /*
                     * In case of string parameter, it can only have value. No unit or min-max
                     */
                    testMO.props[paramName] = {
                        "dbValues": matParamMO.props.mat1Value.dbValues,
                        "uiValues": matParamMO.props.mat1Value.uiValues
                    };
                } else if (matParamMO.modelType.typeHierarchyArray.indexOf('Mat1ParameterDouble') > -1) {
                    var minValue = matParamMO.props.mat1SessionValue.uiValues[0];
                    var maxValue = matParamMO.props.mat1SessionValueMax.uiValues[0];

                    /*
                     * In case of string double, if min != max, then we show both values
                     * otherwise we just show min value.
                     */
                    if (minValue === maxValue) {
                        testMO.props[paramName] = {
                            "dbValues": [minValue],
                            "uiValues": [minValue]
                        };
                    } else {
                        testMO.props[paramName] = {
                            "dbValues": [''.concat(minValue, " - ", maxValue)],
                            "uiValues": [''.concat(minValue, " - ", maxValue)]
                        };
                    }
                }
            }
        }

        /*
         * Inherited parameters are treated as normal parameters in case of compare. So logic is same as above.
         */
        var matinheritedParameters = testMO.props.mat1InheritedParameters.dbValues;
        for (var paramIndex in matinheritedParameters) {
            var matInheritedParamMO = cdm.getObject(matinheritedParameters[paramIndex]);
            if (matInheritedParamMO && matInheritedParamMO.modelType && (matInheritedParamMO.modelType.typeHierarchyArray.indexOf('Mat1InheritedParamString') > -1 || matInheritedParamMO.modelType
                    .typeHierarchyArray.indexOf('Mat1InheritedParamDouble') > -1)) {

                var inheritedParam = matInheritedParamMO.props.mat1Parameter.dbValues[0];
                var matParamMO1 = cdm.getObject(inheritedParam);
                /*
                 * Get parameter name. Inherited param name is same as original name.
                 * so we get it from original param.
                 */
                var paramName = buildParamName(matParamMO1);

                if (matInheritedParamMO.modelType.typeHierarchyArray.indexOf('Mat1InheritedParamString') > -1) {
                    /*
                     * In case of string parameter, it can only have value. No unit or min-max
                     */
                    testMO.props[paramName] = {
                        "dbValues": matParamMO1.props.mat1Value.dbValues,
                        "uiValues": matParamMO1.props.mat1Value.uiValues
                    };
                } else if (matInheritedParamMO.modelType.typeHierarchyArray.indexOf('Mat1InheritedParamDouble') > -1) {
                    var minValue = matParamMO1.props.mat1SessionValue.uiValues[0];
                    var maxValue = matParamMO1.props.mat1SessionValueMax.uiValues[0];

                    /*
                     * In case of string double, if min != max, then we show both values
                     * otherwise we just show min value.
                     */
                    if (minValue === maxValue) {
                        testMO.props[paramName] = {
                            "dbValues": [minValue],
                            "uiValues": [minValue]
                        };
                    } else {
                        testMO.props[paramName] = {
                            "dbValues": [''.concat(minValue, " - ", maxValue)],
                            "uiValues": [''.concat(minValue, " - ", maxValue)]
                        };
                    }
                }
            }
        }
        materialArray.push(testMO);
    }

    materialObjectList.totalResults = materialArray.length;
    materialObjectList.searchResults = materialArray;
    return materialObjectList;
};

/**
 * decides which properties are displayed in compare tab.
 * Mtw0GenerateMaterialComparatorData pushes additional props which needs to be displayed as parameters.
 * we filter those and return.
 *
 * @param {*} response
 */
export let Mtw0MaterialParameterList = function (response) {
    var materialObjectList = new Object();
    var materialParameterArray = [];

    for (var index in response.plain) {
        var testMO = cdm.getObject(response.plain[index]);

        var matParameters = testMO.props.mat1Parameters.dbValues;
        for (var paramIndex in matParameters) {
            var matParamMO = cdm.getObject(matParameters[paramIndex]);
            /*
             * We only compare string & double parameters.
             */
            if (matParamMO && matParamMO.modelType && (matParamMO.modelType.typeHierarchyArray.indexOf('Mat1ParameterString') > -1 || matParamMO.modelType.typeHierarchyArray.indexOf(
                        'Mat1ParameterDouble') > -1)) {

                var paramName = buildParamName(matParamMO);
                materialParameterArray.push({
                    "name": paramName,
                    "displayName": paramName
                });
            }
        }

        /*
         * For inherited parameters as well, We only compare string & double parameters.
         */

        var matInheritedParameters = testMO.props.mat1InheritedParameters.dbValues;
        for (var paramIndex in matInheritedParameters) {
            var matInheritedParamMO = cdm.getObject(matInheritedParameters[paramIndex]);
            if (matInheritedParamMO && matInheritedParamMO.modelType && (matInheritedParamMO.modelType.typeHierarchyArray.indexOf('Mat1InheritedParamString') > -1 || matInheritedParamMO.modelType
                    .typeHierarchyArray.indexOf('Mat1InheritedParamDouble') > -1)) {

                var inheritedParam = matInheritedParamMO.props.mat1Parameter.dbValues[0];
                var inheritedParamMO = cdm.getObject(inheritedParam);
                /*
                 * Get parameter name. Inherited param name is same as original name.
                 * so we get it from original param.
                 */
                var paramName = buildParamName(inheritedParamMO);

                materialParameterArray.push({
                    "name": paramName,
                    "displayName": paramName
                });
            }
        }
    }

    /*
     * Sort parameters by name. otherwise they are scattered and not easily searchable.
     */
    materialParameterArray.sort(GetSortOrder("name"));

    materialObjectList.columns = materialParameterArray;
    materialObjectList.totalResults = materialParameterArray.length;
    materialObjectList.searchResults = materialParameterArray;
    return materialObjectList;
};

/**
 * returns parameter name appended with session-unit and session-value.
 * e.g. Length parameter name could be returned as Length (5km)
 *
 * such parameter name is built for reference parameter.
 *
 * @param {*} parameter
 */
function getParamNameAppendedWithUnitAndValue(parameter) {
    /*
     * Get Name first
     */
    var parameterName = parameter.props.object_name.uiValues[0];

    /*
     * If it is string parameter, then append it with value
     */
    if (parameter.modelType.typeHierarchyArray.indexOf('Mat1ParameterString') > -1) {
        var paramValue = parameter.props.mat1Value.uiValues;
        if (paramValue !== '') {
            parameterName = parameterName.concat(" (", paramValue, ")");
        }
    } else if (parameter.modelType.typeHierarchyArray.indexOf('Mat1ParameterDouble') > -1) {
        /*
         * If it is double parameter, then append it with min & max value and unit
         */
        var minValue = parameter.props.mat1SessionValue.uiValues[0];
        var maxValue = parameter.props.mat1SessionValueMax.uiValues[0];

        var tempValue = "";
        if (minValue !== '' && minValue === maxValue) {
            tempValue = "".concat("(", minValue, ")");
        } else if (minValue !== '' && minValue !== maxValue) {
            tempValue = "".concat("(", minValue, " - ", maxValue, ")");
        }

        if (parameter.props.mat1SessionUnit.uiValues[0] !== '' && parameter.props.mat1SessionUnit.uiValues[0] !== 'UNITLESS') {
            var derivedUnit = cdm.getObject(parameter.props.mat1SessionUnit.dbValues[0]);
            var unit = derivedUnit.props.mat1DerivedUnitSymbol.uiValues[0];
            tempValue = "".concat("(", tempValue, "(", unit, "))");
        }
        parameterName = parameterName.concat(" ", tempValue);
    }
    return parameterName;
}

/**
 * returns parameter name appended with session-unit.
 * e.g. Length parameter name could be returned as Length (km)
 *
 * such parameter name is built for normal parameter.
 *
 * @param {*} parameter
 */
function getParamNameAppendedWithUnit(parameter) {
    /*
     * Get Name first
     */
    var parameterName = parameter.props.object_name.uiValues[0];

    /*
     * If it is string parameter, name is already assigned. nothing to do.
     * otherwise for double, we need to append it with unit
     */
    if (parameter.modelType.typeHierarchyArray.indexOf('Mat1ParameterDouble') > -1) {
        if (parameter.props.mat1SessionUnit.uiValues[0] !== '' && parameter.props.mat1SessionUnit.uiValues[0] !== 'UNITLESS') {
            var derivedUnit = cdm.getObject(parameter.props.mat1SessionUnit.dbValues[0]);
            var unit = derivedUnit.props.mat1DerivedUnitSymbol.uiValues[0];
            parameterName = parameterName.concat(" (", unit, ")");
        }
    }

    return parameterName;
}

/**
/**
 * returns parameter name appended with session-unit & then reference parameters along with session-unit & session value.
 * e.g. Length parameter has session-unit 'km' and 2 reference parameters
 *                         Parameter X with session-value '1' and session-unit 'K'
 *                         Parameter Y with value 1
 * parameter name would be
 *  Length (km)
 *  X (1(k))
 *  Y (1)
 *
 * Each reference parameter (with session-value & session unit) would appear on a new line after parameter name.
 * if reference parameter is double with min & max values, both values would displayed with '-' as separator.
 *
 * @param {*} parameter
 */
function buildParamName(parameter) {

    var paramName = getParamNameAppendedWithUnit(parameter);

    //var referenceParamNames = "";

    var hasReferenceParameters = true;
    var referenceParamNames = [];
    if (parameter.props['mat1ListOfRefParameters'] && parameter.props.mat1ListOfRefParameters.uiValues.length > 0) {
        /*
         * Parameter has a reference parameter. So we need to get it's names.
         */
        for (var ii in parameter.props.mat1ListOfRefParameters.uiValues) {
            var referenceParameter = cdm.getObject(parameter.props.mat1ListOfRefParameters.dbValues[ii]);
            var referenceParamName = getParamNameAppendedWithUnitAndValue(referenceParameter);
            referenceParamNames.push(referenceParamName);
        }
    }
    /*
     * We MUST sort reference parameter names before appending to parameter name.
     * reason ->
     *              param X1 has 2 reference parameters
     *                      Parameter Y with value 1
     *                      Parameter Z with value 1
     *              param X2 has 2 reference parameters
     *                      Parameter Z with value 1
     *                      Parameter Y with value 1
     * reference parameters are same and values are also same. but order is different.
     * so if we don't sort, then param names would look like
     * Param X1 ( Y(1) Z(1) )
     * Param X2 ( Z(1) Y(1) )
     * and even though those are same, those would be shown in different rows in compare.
     * So we must sort it, so order of reference parameters doesn't interfere with actual names.
     */
    referenceParamNames.sort();

    /*
     * Append reference parameter names with original parameter name.
     */
    for (var ii in referenceParamNames) {
        paramName = paramName.concat("\n", referenceParamNames[ii]);
    }
    return paramName;

}

/**
 * Sort a json object array based on given prop
 * @param {*} prop
 */
function GetSortOrder(prop) {
    return function (a, b) {
        if (a[prop] > b[prop]) {
            return 1;
        } else if (a[prop] < b[prop]) {
            return -1;
        }
        return 0;
    };
}

export let getSelectedInheritedMaterial = function (data, ctx) {
    var selectedItem = null;

    if (data.selectedTab.panelId === 'paletteTabPageSub') {
        if (ctx.getClipboardProvider.selectedObjects.length > 0) {
            selectedItem = ctx.getClipboardProvider.selectedObjects[0];
        } else if (ctx.getRecentObjsProvider.selectedObjects.length > 0) {
            selectedItem = ctx.getRecentObjsProvider.selectedObjects[0];
        } else if (ctx.getFavoriteProvider.selectedObjects.length > 0) {
            selectedItem = ctx.getFavoriteProvider.selectedObjects[0];
        }
    } else {
        if (data.dataProviders.performSearch.selectedObjects.length > 0) {
            selectedItem = data.dataProviders.performSearch.selectedObjects[0];
        }
    }

    data.selectedProblemItem = selectedItem;
    return selectedItem.uid;

};

export let processMaterialCatalogues = function (response) {
    var materialCatlogList = [];
    for (var index in response.outputList[0].foundObjects) {
        var materialCatlogObj = {};
        var matcatlogUid = response.outputList[0].foundObjects[index].uid;
        var matcatlogVM = cdm.getObject(matcatlogUid);
        materialCatlogObj.propDisplayValue = matcatlogVM.props.object_name.dbValues[0];
        materialCatlogObj.dispValue = matcatlogVM.props.object_name.uiValues[0];
        materialCatlogObj.propInternalValue = matcatlogUid;
        materialCatlogList.push(materialCatlogObj);

    }
    return materialCatlogList;
};

export let loadMaterialMetaParameters = function (data) {
    var materialParameterList = [];
    var selectedcatlogue = data.materialCatlog.selectedLovEntries[0].propInternalValue;
    var matcatlog = cdm.getObject(selectedcatlogue);
    //var matcatlogVM = cdm.getObject( matcatlogUid );

    var metaParmeterList = matcatlog.props.mat1MetaParameters.dbValues;
    for (var metaparamIndex in metaParmeterList) {
        var metaParamVO = cdm.getObject(metaParmeterList[metaparamIndex]);
        materialParameterList.push(metaParamVO);
    }
    return listBoxSvc.createListModelObjects(materialParameterList, 'props.object_string', false);

};

export let addToParameterList = function (data) {

    var selectedcatlogue = data.materialParameter.selectedLovEntries[0].propInternalValue;

    var metaPropertyDesc = {
        "displayName": selectedcatlogue.props.object_name.dbValues[0],
        "type": selectedcatlogue.props.mat1DataType.dbValues,
        "isRequired": "false",
        "isEditable": "true",
        "isArray": "false",
        "labelPosition": "PROPERTY_LABEL_AT_TOP"
    };
    var metaProperty = modelPropertySvc.createViewModelProperty(metaPropertyDesc);
    _metParamList.push(metaProperty);
    return _metParamList;

};

export default exports = {
    processSelectedObjects,
    Mtw0GenerateMaterialComparatorData,
    Mtw0MaterialParameterList,
    getSelectedInheritedMaterial,
    processMaterialCatalogues,
    loadMaterialMetaParameters,
    addToParameterList
};

app.factory('Mtw0CompareMaterialParameterService', () => exports);
