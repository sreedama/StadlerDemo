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
 * @module js/Mtw0ExportMaterials
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
export let activateExportMaterialsPanel = function( commandId, location ) {
    
    commandPanelService.activateCommandPanel( commandId, location );
};

export let loadTypesFromPreference = function(data, ctx) {
    
    var preferences = {};
    
    var exportFilters = data.preferences.IMM_EXPORT_FILTERS;
    var exportTypeList = [];
    var exportTypeMatmlEntry = {};
    exportTypeMatmlEntry.propDisplayValue = "MATML";
    exportTypeMatmlEntry.dispValue = "MATML";
    exportTypeMatmlEntry.propInternalValue = "MATML";
    exportTypeList.push(exportTypeMatmlEntry);        

    for( var i in exportFilters){
        
        //AnsysMATML;DATASET:IMM_Mapping_Matml2Ansys;Ansys;Ansys MatML
        var exportFilterArray = exportFilters[i].split(";");        
        if( exportFilterArray.length == 4 ){
            
            if( exportFilterArray[1].includes('DATASET:')){

                var dispValue = exportFilterArray[3];
                var internalVal = exportFilterArray[0];

				if(exportTypeMatmlEntry.dispValue != dispValue){
					var exportTypeEntry = {};
					exportTypeEntry.propDisplayValue = dispValue;
					exportTypeEntry.dispValue = dispValue;
					exportTypeEntry.propInternalValue = internalVal;

					exportTypeList.push(exportTypeEntry);        
				}
            }
        }
    }
    preferences.exportTypes = listBoxService.createListModelObjects( exportTypeList, 'dispValue', false); 

    return preferences;
};

export let exportMaterials = function(data, ctx){

    var deferred = AwPromiseService.instance.defer();
	var materialRevisions = [];
	
	if(ctx.pselected && ctx.pselected.type == 'Mat1MaterialRevision'){
		materialRevisions.push(ctx.pselected.uid);
	}
	if(ctx.mselected && ctx.mselected.length > 0 && ctx.mselected[0].type == 'Mat1MaterialRevision'){
		for(var i=0 ; i<ctx.mselected.length ; i++){
		  materialRevisions.push(ctx.mselected[i].uid) ;
		}
	}
	
    var options = {
        'exportType': data.exportTypeListBox.dbValue.propInternalValue
    };
    
    var svcInput = {
        'options' : options,
        "materialData" : materialRevisions 
    };

    soaSvc.post('MaterialManagement-2021-06-MaterialManagement', 'exportMaterialsData', {input:[svcInput]}).
    then(
        function(response) {
            if( response && response.transientFileReadTickets ) {
                var fileName = fmsUtils.getFilenameFromTicket( response.transientFileReadTickets[0] );
                fmsUtils.openFile( response.transientFileReadTickets[0], fileName );
                var localTextBundle = localeService.getLoadedText( 'MaterialMgmtMessages' );
                var fileExportedMessage = localTextBundle[ 'Mtw0ExportSuccessfull' ];
                messagingService.showInfo( fileExportedMessage );
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
    
    // Close export panel
    var eventData = { source: 'toolAndInfoPanel' };
    eventBus.publish( 'complete', eventData );

    return deferred.promise;
}


export default exports = {
    activateExportMaterialsPanel,
    loadTypesFromPreference,
    exportMaterials
};

app.factory( 'Mtw0ExportMaterials', () => exports);
