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
 * @module js/Mtw0UtilService
 */
import app from 'app';
import appCtxSvc from 'js/appCtxService';
import _ from 'lodash';
import cdm from 'soa/kernel/clientDataModel';
import listBoxSvc from 'js/listBoxService';
import modelPropertySvc from 'js/modelPropertyService';
import soaSvc from 'soa/kernel/soaService';
var exports = {};

/*
 * Override substance is just setting typedref attribute mat1OriginalUsesSubstance to null.
 */
export let mtw0OverrideSubstanceAction = function( modelObjs ) {
    var inputData = {
        info: [{
            object: appCtxSvc.ctx.relationContext.relationInfo[0].relationObject,
            vecNameVal: [{
                name: 'mat1OriginalUsesSubstance',
                values: null
            }]
        }]
    };
    return soaSvc.post('Core-2010-09-DataManagement', 'setProperties', inputData);
};

export let Mtw0GetObjectsUIDType = function (modelObjs) {
    var objects = [];
    for (var i in modelObjs) {
        var vmo = modelObjs[i];
        var obj={};
        obj.uid = vmo.uid;
        obj.type = vmo.type;
        objects.push(obj);
    }
    return objects;
};

export let processIMMExportPreference = function (data) {
    var immPreferences = {};
    /*
     * Preference is in AWC_StartupPreferences. So we can directly read the value.
     * Preference value 4 values separated by ;
     * Export Key ; Translator ; Session Unit Name ; Name of the Export
     */
    var immExportPrefValue = data.preferences.IMM_EXPORT_FILTERS;
    var exportTypeObjList = [];
    var exportTypeFullMatML = {};
    exportTypeFullMatML.propDisplayValue = "Full MatML";
    exportTypeFullMatML.dispValue = "Full MatML";
    exportTypeFullMatML.propInternalValue = "";
    exportTypeObjList.push(exportTypeFullMatML);
    for (var i in immExportPrefValue) {

        var immExportList = immExportPrefValue[i].split(';');
            var exportTypeObj = {};
            var dispValue = immExportList[3]
            var internalVal = immExportList[0]
            exportTypeObj.propDisplayValue = dispValue;
            exportTypeObj.dispValue = dispValue;
            exportTypeObj.propInternalValue = internalVal;
            exportTypeObjList.push(exportTypeObj);
    }
    immPreferences.ImmExportTypes = listBoxSvc.createListModelObjects(exportTypeObjList, 'dispValue', false);
    return immPreferences;
};

export default exports = {
    mtw0OverrideSubstanceAction,
    processIMMExportPreference,
    Mtw0GetObjectsUIDType

};

app.factory('Mtw0UtilService', () => exports);
