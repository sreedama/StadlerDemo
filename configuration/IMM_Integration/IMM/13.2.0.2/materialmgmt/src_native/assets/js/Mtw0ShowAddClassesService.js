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
 * @module js/Mtw0ShowAddClassesService
 */
import appCtxSvc from 'js/appCtxService';
import cdm from 'soa/kernel/clientDataModel';
import dmSvc1 from 'soa/dataManagementService';
import modelPropertySvc from 'js/modelPropertyService';
import eventBus from 'js/eventBus';

import app from 'app';
import soaSvc from 'soa/kernel/soaService';
import commandPanelService from 'js/commandPanel.service';
import _ from 'lodash';
import listBoxSvc from 'js/listBoxService';
import addObjectUtils from 'js/addObjectUtils';
import AwPromiseService from 'js/awPromiseService';

var exports = {};

export let getGlobalClasses = function (propertyPolicyOverride) {
    let inputData = {
        'findList': [
            {
                'criterias': [
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

export let processMaterialClassification = function (response) {
    var materialGlobalClassesList = [];
    var globalClassObj = {};

    for (var index in response.outputList[0].foundObjects) {
        var unitAltNameUid = response.outputList[0].foundObjects[index].uid;
        var unitAltNameObj = cdm.getObject(unitAltNameUid);

        if (unitAltNameObj.modelType.typeHierarchyArray.indexOf('Mat1MatClassification') > -1) {
            //var materialClassObj = {};
            var matClassUid = response.outputList[0].foundObjects[index].uid;
            var matClassVM = cdm.getObject(matClassUid);
			
			if ( (matClassVM.props.mat1MatCatalog.dbValues.length === 1) && 
					(matClassVM.props.mat1MatCatalog.dbValues[0] === null)
			) // This is global classes check
            {
                //globalClassObj[matClassVM.props.mat1RealName.dbValues[0]] = matClassUid;
                globalClassObj[matClassUid] = { "name": matClassVM.props.object_name.dbValues[0] };
            }
        }
    }

    buildGlobalClassTree(globalClassObj, materialGlobalClassesList);

    var orderedGlbClsList = _.sortBy(materialGlobalClassesList, [function (o) { return _.toLower(o.label); }]);
    return orderedGlbClsList;
};

export let removeClassFromMaterial =  function(data, ctx){	
	var i = 0;
	var oldValues = [];
	
	oldValues = ctx.pselected.props.mat1MatClassifications.dbValue;

	var newValues = oldValues;
	for( var i = 0; i < newValues.length; i++){     
        if ( ctx.mselected && newValues[i] === ctx.mselected[0].uid) { 
            newValues.splice(i, 1); 
        }
    }
    
	if(ctx.pselected){
		dmSvc1.setProperties([{
					object: ctx.pselected,
					vecNameVal: [{
							name: 'mat1MatClassifications',
							values: newValues
						}]
				}]);
	}
	
    var eventData = { source: 'toolAndInfoPanel' };
    eventBus.publish( 'complete', eventData );
			
	return AwPromiseService.instance.resolve();		
}

export let setMaterialClassification = function(data, ctx){
	
	var i = 0;
	var oldValues = [];
		
	oldValues = ctx.selected.props.mat1MatClassifications.dbValue;
	
	var newValues = oldValues;	
	newValues.push(data.mat1GlobalClsList[0].uid);
	if(ctx.selected){
		dmSvc1.setProperties([{
					object: ctx.selected,
					vecNameVal: [{
							name: 'mat1MatClassifications',
							values: newValues
						}]
				}]);
	}

    var eventData = { source: 'toolAndInfoPanel' };
    eventBus.publish( 'complete', eventData );

	return AwPromiseService.instance.resolve();		
}

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

export let setSelectedTreeNode = function (currentNode) {
    var globalClsObj = {};

    var classUid = cdm.getObject(currentNode.node.value);
	var _mat1GlobalClsList = [];
    _mat1GlobalClsList.push(classUid);
    return _mat1GlobalClsList;
};

export default exports = {
	getGlobalClasses,
	setSelectedTreeNode,
	processMaterialClassification,
	buildGlobalClassTree,
	setMaterialClassification,
	removeClassFromMaterial
};

app.factory('Mtw0ShowAddClassesService', () => exports);
