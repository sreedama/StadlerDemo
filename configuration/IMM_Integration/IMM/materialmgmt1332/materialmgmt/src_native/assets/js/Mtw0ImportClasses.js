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
 * @module js/Mtw0ImportClasses
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

/**
 * This method sets the Relation and the Secondary object in context when xrt object-set 'Add to' command is
 * clicked.
 *
 * @param {data}{ctx} data , ctx
 * @return {ObjectArray} input data
 */
export let activateImportClassesPanel = function( commandId, location ) {
    
    commandPanelService.activateCommandPanel( commandId, location );
};

/*
export let clearFileSelection = function( fileData ) {
    appCtxSvc.ctx.HostedFileNameContext = undefined;
    
    $( '#fileUploadForm' )[ 0 ].reset();
    fileData.files = {};
    fileData.fileName = undefined;
    fileData.fileNameNoExt = undefined;
    fileData.validFile = false;
};
*/

export let importClasses = function(data){

    var deferred = AwPromiseService.instance.defer();
    var options = {
        'importType': 'CLASSES'
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
    activateImportClassesPanel,
    importClasses
};

app.factory( 'Mtw0ImportClasses', () => exports);