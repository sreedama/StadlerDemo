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
 * @module js/Mtw0ImportMaterials
 */
import app from 'app';
import messagingService from 'js/messagingService';
import eventBus from 'js/eventBus';
import localeService from 'js/localeService';
import commandPanelService from 'js/commandPanel.service';
import listBoxService from 'js/listBoxService';
import cdm from 'soa/kernel/clientDataModel';
import _ from 'lodash';
import appCtxSvc from 'js/appCtxService';
import AwPromiseService from 'js/awPromiseService';
import $ from 'jquery';
import soaSvc from 'soa/kernel/soaService';
import fmsUtils from 'js/fmsUtils';

var exports = {};
var importType2Extensions = new Map();

/**
 * This method sets the Relation and the Secondary object in context when xrt object-set 'Add to' command is
 * clicked.
 *
 * @param {data}{ctx} data , ctx
 * @return {ObjectArray} input data
 */
export let activateImportMaterialsPanel = function( commandId, location ) {
    
    commandPanelService.activateCommandPanel( commandId, location );
};

export let processMaterialCatalogues = function (response) {

    var materialCatlogList = [];
    var materialCatlogObj = {};
    materialCatlogObj.propDisplayValue = '';
    materialCatlogObj.dbValue = '';
    materialCatlogObj.uiValue = '';
    materialCatlogObj.dispValue = '';
    materialCatlogObj.propInternalValue = '';
    materialCatlogList.push(materialCatlogObj);
	
    for (var index in response.outputList[0].foundObjects) {
        var foundObjectUid = response.outputList[0].foundObjects[index].uid;
        var foundObject = cdm.getObject(foundObjectUid);
    
        var isCatalogModifiable = foundObject.props.is_modifiable.dbValues[0] == '1';    
        if (    isCatalogModifiable && 
                foundObject.modelType.typeHierarchyArray.indexOf('Mat1MatCatalog') > -1
            ) {
            var materialCatlogObj = {};
            materialCatlogObj.propDisplayValue = foundObject.props.object_name.dbValues[0];
            materialCatlogObj.dispValue = foundObject.props.object_name.uiValues[0];
            materialCatlogObj.propInternalValue = foundObject.uid;
            materialCatlogList.push(materialCatlogObj);
        }
    }

    return _.sortBy(materialCatlogList, ['dispValue']);
};

export let loadTypesFromPreference = function(data, ctx) {
    
	if(ctx.selected.modelType.typeHierarchyArray.indexOf('Mat1MatCatalogRevision') > -1){
		if( ctx && ctx.selected ){
			data.catalogListBox.dispValue = ctx.selected.props.object_name.dbValue;
			data.catalogListBox.dbValue = ctx.selected.props.items_tag.dbValue;
		}
	}
    
    var preferences = {};
    
    var materialTypes = data.preferences.IMM_IMPORT_WIZARD_OBJECT_TYPES;
    var materialList = [];
    var materialTypeMatmlEntry = {};

    for( var i in materialTypes){
        var dispValue = materialTypes[i];
        var internalVal = materialTypes[i];

        var materialTypeEntry = {};
        materialTypeEntry.propDisplayValue = dispValue;
        materialTypeEntry.dispValue = dispValue;
        materialTypeEntry.propInternalValue = internalVal;

        materialList.push(materialTypeEntry);        
    }
    preferences.materialTypes = listBoxService.createListModelObjects(materialList, 'dispValue', false);

    var substanceTypes = data.preferences.IMM_IMPORT_WIZARD_SUBSTANCE_TYPES;
    var substanceList = [];
    var substanceTypeMatmlEntry = {};
    for( var i in substanceTypes){
        var dispValue = substanceTypes[i];
        var internalVal = substanceTypes[i];

        var substanceTypeEntry = {};
        substanceTypeEntry.propDisplayValue = dispValue;
        substanceTypeEntry.dispValue = dispValue;
        substanceTypeEntry.propInternalValue = internalVal;

        substanceList.push(substanceTypeEntry);        
    }
    preferences.substanceTypes = listBoxService.createListModelObjects( substanceList, 'dispValue', false);

    var importFilters = data.preferences.IMM_IMPORT_FILTERS;
    var importTypeList = [];
    var importTypeMatmlEntry = {};
    importTypeMatmlEntry.propDisplayValue = "MATML";
    importTypeMatmlEntry.dispValue = "MATML";
    importTypeMatmlEntry.propInternalValue = "MATML";
    importTypeList.push(importTypeMatmlEntry);        
    importType2Extensions.set("MATML", ".xml");        
    preferences.extension = ".xml";

    for( var i in importFilters){
        
        //ANSYS;*.xml;DATASET:IMM_Mapping_Ansys2Matml;ANSYS
        var importFilterArray = importFilters[i].split(";");        
        if( importFilterArray.length == 4 ){
            
            if( importFilterArray[2].includes('DATASET:')){

                importType2Extensions.set(importFilterArray[3], importFilterArray[1].substr(1, importFilterArray[1].length-1));        
                var dispValue = importFilterArray[3];
                var internalVal = importFilterArray[0];

                var importTypeEntry = {};
                importTypeEntry.propDisplayValue = dispValue;
                importTypeEntry.dispValue = dispValue;
                importTypeEntry.propInternalValue = internalVal;

                importTypeList.push(importTypeEntry);        
            }
        }
    }
    preferences.importTypes = listBoxService.createListModelObjects( importTypeList, 'dispValue', false); 

    return preferences;
};

export let setExtension = function(data) {
    var importType = data.importTypeListBox.dbValue;     
    var extension = importType2Extensions.get(importType.dispValue);
    clearFileSelection(data);
    return extension;
};

export let clearFileSelection = function( fileData ) {
    appCtxSvc.ctx.HostedFileNameContext = undefined;
    // clear the form data
    $( '#fileUploadForm' )[ 0 ].reset();
    fileData.files = {};
    fileData.fileName = undefined;
    fileData.fileNameNoExt = undefined;
    fileData.validFile = false;
};


export let importMaterials = function(data){

    var deferred = AwPromiseService.instance.defer();
    var options = {
        'importType': data.importTypeListBox.uiValue,
        "catalogName": data.catalogName.dbValue,
        "materialType": data.materialTypesListBox.uiValue, 
        "substanceType": data.substanceTypesListBox.uiValue,
    };
    
    var svcInput = {
        'options' : options,
        "files": [data.fmsTicket],
        "materialCatalog": data.catalogListBox.dbValue
    };

    soaSvc.post('MaterialManagement-2021-06-MaterialManagement', 'importMaterialsData', {input:[svcInput]}).
    then(
        function(response) {
            if( response && response.transientFileReadTickets ) {
                var fileName = fmsUtils.getFilenameFromTicket( response.transientFileReadTickets[0] );
                fmsUtils.openFile( response.transientFileReadTickets[0], fileName );
                var localTextBundle = localeService.getLoadedText( 'MaterialMgmtMessages' );
                var fileImportedMessage = localTextBundle[ 'Mtw0ImportSuccessfull' ];
                messagingService.showInfo( fileImportedMessage );
            }
            
            if( response.partialErrors || response.PartialErrors ) {
                var err = soaSvc.createError( response.errors[0] );
                messagingService.showError( err.message );
                deferred.reject( err );
            }

            deferred.resolve( response );
        },
         function(err) {
            messagingService.showError( err.message );
            deferred.reject(err);
        }
    );
    
    // Close import panel
    var eventData = { source: 'toolAndInfoPanel' };
    eventBus.publish( 'complete', eventData );

    return deferred.promise;
}


export default exports = {
    activateImportMaterialsPanel,
    processMaterialCatalogues,
    loadTypesFromPreference,
    importMaterials,
    setExtension,
    clearFileSelection
};

app.factory( 'Mtw0ImportMaterials', () => exports);
