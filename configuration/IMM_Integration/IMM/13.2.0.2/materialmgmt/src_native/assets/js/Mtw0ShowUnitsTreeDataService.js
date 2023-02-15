// Copyright (c) 2020 Siemens

/**
 * @module js/Mtw0ShowUnitsTreeDataService
 */
import app from 'app';
import _ from 'lodash';
import cdm from 'soa/kernel/clientDataModel';
import _dateTimeSvc from 'js/dateTimeService';
import awTableSvc from 'js/awTableService';
import AwPromiseService from 'js/awPromiseService';
import appCtxService from 'js/appCtxService';
import awColumnService from 'js/awColumnService';
import addObjectUtils from 'js/addObjectUtils';
import soaSvc from 'soa/kernel/soaService';


var exports = {};
var _baseUnitCollection;



/**
 * @param {TreeLoadInput} treeLoadInput - Parameters for the operation.
 * @param {searchResults} searchResults new TreeLoadResult object containing result/status information.
 *
 * @return {object} response
 */
export let loadUnitsTreeTableData = function (searchResults, treeLoadInput) {

    // This is the "root" node of the tree or the node that was selected for expansion

    var unitList = processDerivedUnit(searchResults);


    var parentNode = treeLoadInput.parentNode;

    var levelNdx = parentNode.levelNdx + 1;

    var vmNodes = [];

    for (var childNdx = 0; childNdx < unitList.length; childNdx++) {

        //var object = searchResults[ childNdx ];
        var proxyObject = unitList[childNdx];

        var displayName = proxyObject.props.object_name.uiValues[0];
        var objType = proxyObject.type;
        var objUid = proxyObject.uid;
        var iconURL = app.getBaseUrlPath() + "/image/typeUnitCategory48.svg";

        var vmNode = awTableSvc
            .createViewModelTreeNode(objUid, objType, displayName, levelNdx, childNdx, iconURL);

        var hasChildren = 0;
        vmNode.isLeaf = hasChildren === "0";
        vmNode.props = {};
        vmNode.props.type = {
            "name": "type",
            "type": "STRING",
            "value": proxyObject.props.object_type.uiValues[0],
            "uiValue": proxyObject.props.object_type.uiValues[0],
            "dbValue": proxyObject.props.object_type.dbValues[0],
            "isEnabled": true,
            "propertyName": "type",
            "displayValues": [
                proxyObject.props.object_type.uiValues[0]
            ]
        };

        if (vmNode) {
            vmNodes.push(vmNode);
        }
    }
    var sortedVmNodes = _.sortBy(vmNodes, ['displayName']);
    treeLoadInput.pageSize = sortedVmNodes.length;
    return awTableSvc.buildTreeLoadResult(treeLoadInput, sortedVmNodes, false, true, true, null);
};

let getAllDerivedUnit = function (baseUnitUid) {
    var derivedUnits = [];
    _.forEach(_baseUnitCollection, function (value, key) {
        for (var i in value) {
            if (value[i].baseUnitUid.uid === baseUnitUid && value[i].baseUnitUid.derivedUnitObj !== undefined) {
                derivedUnits.push(value[i].baseUnitUid.derivedUnitObj.uid);
            }
        }
    });
    return _.uniq(derivedUnits);
};

let getUnitAlias = function (derivedUnitUid) {
    var unitAliases = [];
    _.forEach(_baseUnitCollection, function (value, key) {
        for (var i in value) {
            if (value[i].baseUnitUid.derivedUnitObj !== undefined && value[i].baseUnitUid.derivedUnitObj.uid === derivedUnitUid) {
                if (value[i].baseUnitUid.derivedUnitObj.unitAltNameObj !== undefined) {
                    unitAliases.push(value[i].baseUnitUid.derivedUnitObj.unitAltNameObj.uid);
                }
            }
        }

    });
    return _.uniq(unitAliases);
};
export let processDerivedUnit = function (response) {
    //loop through u Mat1UnitAltName

    var baseUnits = [];
    for (var index in response.outputList[0].foundObjects) {
        var foundObjectUid = response.outputList[0].foundObjects[index].uid;
        //console.log(index + " :: " + foundObjectUid);
        var foundObject = cdm.getObject(foundObjectUid);
        if (foundObject.modelType.typeHierarchyArray.indexOf('Mat1UnitAltName') > -1) {
            //get derived unit object
            var derivedUnitObj = cdm.getObject(foundObject.props.mat1DerivedUnit.dbValues[0]);

            if (derivedUnitObj !== null && derivedUnitObj !== undefined) {
                var baseUnitObj = cdm.getObject(derivedUnitObj.props.mat1BaseUnit.dbValues[0]);
                if (baseUnitObj !== null && baseUnitObj !== undefined) {
                    var tempObj = {
                        "baseUnitUid": {
                            "uid": baseUnitObj.uid,
                            "unitCategoryUid": baseUnitObj.props.mat1UnitCategory.dbValues[0],
                            "derivedUnitObj": {
                                "uid": derivedUnitObj.uid,
                                "unitAltNameObj": {
                                    "uid": foundObject.uid,
                                    "name": foundObject.props.object_name.uiValues[0],
                                    "dbValue": foundObject.props.object_name.dbValues[0]
                                }

                            }

                        }

                    };
                    baseUnits.push(tempObj);
                }
            }
        }
        else if (foundObject.modelType.typeHierarchyArray.indexOf('Mat1DerivedUnit') > -1) {

            var baseUnitObj = cdm.getObject(foundObject.props.mat1BaseUnit.dbValues[0]);

            var foundDerivedObj = _.find(baseUnits, function (obj) {
                obj.baseUnitUid.uid === baseUnitObj.uid && obj.baseUnitUid.derivedUnitObj.uid === foundObjectUid;
            });
            if (_.isUndefined(foundDerivedObj)) {
                var tempObj1 = {
                    "baseUnitUid": {
                        "uid": baseUnitObj.uid,
                        "unitCategoryUid": baseUnitObj.props.mat1UnitCategory.dbValues[0],
                        "derivedUnitObj": {
                            "uid": foundObjectUid

                        }

                    }

                };
                baseUnits.push(tempObj1);
            }


        }
        else if (foundObject.modelType.typeHierarchyArray.indexOf('Mat1BaseUnit') > -1) {

            var baseUnitObj = cdm.getObject(foundObjectUid);

            var foundBaseUnitObj = _.find(baseUnits, function (obj) {
                obj.baseUnitUid.uid === foundObjectUid;// && obj.baseUnitUid.unitCategoryUid === baseUnitObj.props.mat1UnitCategory.dbValues[0];
            });
            if (_.isUndefined(foundBaseUnitObj)) {
                var tempObj1 = {
                    "baseUnitUid": {
                        "uid": baseUnitObj.uid,
                        "unitCategoryUid": baseUnitObj.props.mat1UnitCategory.dbValues[0]

                    }

                };
                baseUnits.push(tempObj1);
            }
        }
        else if (foundObject.modelType.typeHierarchyArray.indexOf('Mat1UnitCategory') > -1) {


            var baseUnitObj = cdm.getObject(foundObjectUid);

            var foundUnitCatgoryObj = _.find(baseUnits, function (obj) {
                obj.baseUnitUid.unitCategoryUid === foundObjectUid;
            });
            if (_.isUndefined(foundUnitCatgoryObj)) {
                var tempObj1 = {
                    "baseUnitUid": {
                        "unitCategoryUid": foundObjectUid

                    }

                };
                var temp = tempObj1;
                baseUnits.push(tempObj1);
            }
        }

    }
    _baseUnitCollection = _.groupBy(baseUnits, 'baseUnitUid.unitCategoryUid');

    var treeSummary = {};
    treeSummary.parent = [];
    var children = [];
    var unitList = [];
    _.forEach(_baseUnitCollection, function (value, key) {
        //get unit category
        unitList.push(cdm.getObject(key));
    });
    //var sortedVmNodes= _.sortBy(unitList,[ displayValues [0]]);
    treeSummary.parent = unitList;
    return unitList;
};


export let inputNodeForChild = function (treeLoadInput) {
    var rootNode = treeLoadInput;
    return rootNode;

};

export let loadTreeTableChildData = function (treeLoadInput, depth, data) {

    // This is the "root" node of the tree or the node that was selected for expansion
    var parentNode = treeLoadInput.parentNode;
    var selectedTreeNode = cdm.getObject(parentNode.id);
    var levelNdx = parentNode.levelNdx + 1;
    var vmNodes = [];
    if (selectedTreeNode.type === 'Mat1UnitCategory') {
        var baseunits = _baseUnitCollection[parentNode.id];
        var baseunitsUnique = _.uniqBy(baseunits, 'baseUnitUid.uid');
        for (var childNdx = 0; childNdx < baseunitsUnique.length; childNdx++) {

            //var object = searchResults[ childNdx ];
            if (baseunitsUnique[childNdx].baseUnitUid.uid !== undefined) {
                var proxyObject = cdm.getObject(baseunitsUnique[childNdx].baseUnitUid.uid);

                var displayName = proxyObject.props.object_name.uiValues[0];
                var objType = proxyObject.type;
                var objUid = proxyObject.uid;

                var iconURL = app.getBaseUrlPath() + "/image/typeBaseUnit48.svg";


                var vmNode = awTableSvc
                    .createViewModelTreeNode(objUid, objType, displayName, levelNdx, childNdx, iconURL);
                var hasChildren = 0;
                vmNode.isLeaf = hasChildren === "0";
                vmNode.props = {};
                vmNode.props.type = {
                    "name": "type",
                    "type": "STRING",
                    "value": proxyObject.props.object_type.uiValues[0],
                    "uiValue": proxyObject.props.object_type.uiValues[0],
                    "dbValue": proxyObject.props.object_type.dbValues[0],
                    "isEnabled": true,
                    "propertyName": "type",
                    "displayValues": [
                        proxyObject.props.object_type.uiValues[0]
                    ]
                };
                if (vmNode) {
                    vmNodes.push(vmNode);
                }
            }
            //break;
        }
    } else if (selectedTreeNode.type === 'Mat1BaseUnit') {
        var derviedUnitList = getAllDerivedUnit(parentNode.id);
        for (var childNdx = 0; childNdx < derviedUnitList.length; childNdx++) {

            //var object = searchResults[ childNdx ];
            var proxyObject = cdm.getObject(derviedUnitList[childNdx]);

            var displayName = proxyObject.props.object_name.uiValues[0];
            var objType = proxyObject.type;
            var objUid = proxyObject.uid;

            var iconURL = app.getBaseUrlPath() + "/image/typeDerivedUnit48.svg";


            var vmNode = awTableSvc
                .createViewModelTreeNode(objUid, objType, displayName, levelNdx, childNdx, iconURL);
            var hasChildren = 0;
            vmNode.isLeaf = hasChildren === "0";
            vmNode.props = {};
            vmNode.props.type = {
                "name": "type",
                "type": "STRING",
                "value": proxyObject.props.object_type.uiValues[0],
                "uiValue": proxyObject.props.object_type.uiValues[0],
                "dbValue": proxyObject.props.object_type.dbValues[0],
                "isEnabled": true,
                "propertyName": "type",
                "displayValues": [
                    proxyObject.props.object_type.uiValues[0]
                ]

            };
            if (vmNode) {
                vmNodes.push(vmNode);
            }
            //break;
        }
    }
    else if (selectedTreeNode.type === 'Mat1DerivedUnit') {
        var derviedUnitList = getUnitAlias(parentNode.id);
        for (var childNdx = 0; childNdx < derviedUnitList.length; childNdx++) {

            //var object = searchResults[ childNdx ];
            var proxyObject = cdm.getObject(derviedUnitList[childNdx]);
            var displayName = proxyObject.props.object_name.uiValues[0];
            var objType = proxyObject.type;
            var objUid = proxyObject.uid;

            var iconURL = app.getBaseUrlPath() + "/image/typeUnitAlternateName48.svg";


            var vmNode = awTableSvc
                .createViewModelTreeNode(objUid, objType, displayName, levelNdx, childNdx, iconURL);

            vmNode.isLeaf = true;
            vmNode.props = {};
            vmNode.props.type = {
                "name": "type",
                "type": "STRING",
                "value": proxyObject.props.object_type.uiValues[0],
                "uiValue": proxyObject.props.object_type.uiValues[0],
                "dbValue": proxyObject.props.object_type.dbValues[0],
                "isEnabled": true,
                "propertyName": "type",
                "displayValues": [
                    proxyObject.props.object_type.uiValues[0]
                ]

            };

            if (vmNode) {
                vmNodes.push(vmNode);
            }
            //break;
        }
    }
    var sortedVmNodes = _.sortBy(vmNodes, ['displayName']);
    treeLoadInput.pageSize = sortedVmNodes.length;
    return awTableSvc.buildTreeLoadResult(treeLoadInput, sortedVmNodes, false, true, true, null);
};
/**
 * Load properties to be shown in the tree structure
 * @param {object} data The view model data object
 * @return {object} Output of loadTableProperties
 */
export let loadPropertiesJS = function (data) {
    var viewModelCollection = data.dataProviders.getUnitsPropertyProvider.getViewModelCollection();
    var loadedVMOs = viewModelCollection.getLoadedViewModelObjects();
    /**
     * Extract action parameters from the arguments to this function.
     */
    var propertyLoadInput = awTableSvc.findPropertyLoadInput(arguments);

    /**
     * Load the 'child' nodes for the 'parent' node.
     */
    if (propertyLoadInput !== null &&
        propertyLoadInput !== undefined &&
        propertyLoadInput !== 'undefined') {
        return exports.loadTableProperties(propertyLoadInput, loadedVMOs);
    }
};

/**
 * load Properties required to show in tables'
 * @param {Object} propertyLoadInput - Property Load Input
 * @param {Array} loadedVMOs - Loaded View Model Objects
 * @return {Object} propertyLoadResult
 */
export let loadTableProperties = function (propertyLoadInput) {
    var allChildNodes = [];
    _.forEach(propertyLoadInput.propertyLoadRequests, function (propertyLoadRequest) {
        _.forEach(propertyLoadRequest.childNodes, function (childNode) {
            if (!childNode.props) {
                childNode.props = {};
            }

            if (childNode.id !== 'top') {
                allChildNodes.push(childNode);
            }
        });
    });

    var propertyLoadResult = awTableSvc.createPropertyLoadResult(allChildNodes);

    return AwPromiseService.instance.resolve({
        propertyLoadResult: propertyLoadResult
    });
};
/**
 * Loads columns for the column
 * @param {object} uwDataProvider data provider
 * @param {Object} data vmData
 * @return {object} promise for async call
 */
export let loadColumns = function (uwDataProvider, data) {
    var deferred = AwPromiseService.instance.defer();

    var awColumnInfos = [];

    awColumnInfos.push(awColumnService.createColumnInfo({

        name: "object_name",
        displayName: data.i18n.Name,
        typeName: 'String',
        width: 300,
        isTreeNavigation: true,
        isTableCommand: false,
        enableSorting: false,
        enableCellEdit: false,
        enableColumnMoving: false,
        enableFiltering: false,
        frozenColumnIndex: -1

    }));

    awColumnInfos.push(awColumnService.createColumnInfo({

        name: "type",
        displayName: data.i18n.Type,
        typeName: 'String',
        width: 300,
        isTreeNavigation: false,
        isTableCommand: false,
        enableSorting: false,
        enableCellEdit: false,
        enableColumnMoving: false,
        enableFiltering: false,
        frozenColumnIndex: -1

    }));


    uwDataProvider.columnConfig = {
        columns: awColumnInfos
    };

    deferred.resolve({
        columnInfos: awColumnInfos
    });
    data.initialExpand = false;
    return deferred.promise;
};
export let constructCreateInputforUnitAltName = function (data) {
    var inputs = addObjectUtils.getCreateInput(data);
    //inputs[0].createData.propertyNameValues.mat1DerivedUnit = [appCtxService.ctx.selected.uid];
    return inputs;
};
export let constructCreateInputforDerivedUnit = function (data) {
    var inputs = addObjectUtils.getCreateInput(data);
    inputs[0].createData.propertyNameValues.mat1BaseUnit = [appCtxService.ctx.selected.uid];
    return inputs;
};
export let constructCreateInputforBaseUnit = function (data) {
    var inputs = addObjectUtils.getCreateInput(data);
    inputs[0].createData.propertyNameValues.mat1UnitCategory = [appCtxService.ctx.selected.uid];
    return inputs;
};
export let constructCreateInputforUnitCategory = function (data) {
    var inputs = addObjectUtils.getCreateInput(data);

    return inputs;
};
/**
 * Call SOA for findWorkspaceObjects with Property Policy Override
 *
 * @param {Object} propertyPolicyOverride Property Policy
 * @returns {Object} - Json object
 */
export let getMaterialUnitsAttributes = function (propertyPolicyOverride) {
    let inputData = {
        "findList": [
            {
                "criterias": [
                    {
                        "objectType": "Mat1UnitAltName",
                        "objectName": "",
                        "scope": "WSO_scope_All",
                        "owner": "",
                        "group": "",
                        "createdBefore": "",
                        "modifiedBefore": "",
                        "releasedBefore": "",
                        "createdAfter": "",
                        "modifiedAfter": "",
                        "releasedAfter": ""
                    },
                    {
                        "objectType": "Mat1DerivedUnit",
                        "objectName": "",
                        "scope": "WSO_scope_All",
                        "owner": "",
                        "group": "",
                        "createdBefore": "",
                        "modifiedBefore": "",
                        "releasedBefore": "",
                        "createdAfter": "",
                        "modifiedAfter": "",
                        "releasedAfter": ""
                    },
                    {
                        "objectType": "Mat1BaseUnit",
                        "objectName": "",
                        "scope": "WSO_scope_All",
                        "owner": "",
                        "group": "",
                        "createdBefore": "",
                        "modifiedBefore": "",
                        "releasedBefore": "",
                        "createdAfter": "",
                        "modifiedAfter": "",
                        "releasedAfter": ""
                    },
                    {
                        "objectType": "Mat1UnitCategory",
                        "objectName": "",
                        "scope": "WSO_scope_All",
                        "owner": "",
                        "group": "",
                        "createdBefore": "",
                        "modifiedBefore": "",
                        "releasedBefore": "",
                        "createdAfter": "",
                        "modifiedAfter": "",
                        "releasedAfter": ""
                    }
                ]
            }
        ]
    };
    return soaSvc.post('Query-2007-06-Finder', 'findWorkspaceObjects', inputData, propertyPolicyOverride);
};

export default {
    loadUnitsTreeTableData,
    processDerivedUnit,
    inputNodeForChild,
    loadTreeTableChildData,
    loadTableProperties,
    loadPropertiesJS,
    loadColumns,
    constructCreateInputforUnitAltName,
    constructCreateInputforDerivedUnit,
    constructCreateInputforBaseUnit,
    constructCreateInputforUnitCategory,
    getMaterialUnitsAttributes
};
