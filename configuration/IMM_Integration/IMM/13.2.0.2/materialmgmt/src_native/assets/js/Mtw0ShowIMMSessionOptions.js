// Copyright 2020 Siemens Product Lifecycle Management Software Inc.

/* global define */

/**
 * Note: This module does not return an API object. The API is only available when the service defined this module is
 * injected by AngularJS.
 *
 * @module js/Mtw0ShowIMMSessionOptions
 */
import app from 'app';
import AwPromiseService from 'js/awPromiseService';
import appCtxSvc from 'js/appCtxService';
import localeSvc from 'js/localeService';
import lovService from 'js/lovService';
import _ from 'lodash';
import browserUtils from 'js/browserUtils';

var exports = {};

/**
 *
 * @param {*} response
 * @param {*} data
 */
export let Mtw0GetSelectedSessionUnitY = function (response, data) {
    data.cm0GlobalChangeContext.displayName = response.preferences[0].values[0];
    data.cm0GlobalChangeContext.uiValue = response.preferences[0].values[0];
    return data.cm0GlobalChangeContext;
};

/**
 *
 * @param {*} data
 * @param {*} eventData
 */
export let Mtw0GetSelectedSessionUnitX = function (data, eventData) {
    data.cm0GlobalChangeContext.displayName = eventData.property.dbValue.propDisplayValue;
    data.cm0GlobalChangeContext.uiValue = eventData.property.dbValue.propDisplayValue;
    var preferenceValues = [];
    preferenceValues.push(eventData.property.dbValue.propDisplayValue);
    return preferenceValues;
};

/**
 * Add "No Session Units" List to values
 *
 * @param {Object} response - response of LOV SOA
 */
export let Mtw0UpdateSessionUnitsLOV = function (response, data) {
    var deferedLOV = AwPromiseService.instance.defer();

    if (response.outputList !== null && response.outputList[0] !== null && response.outputList[0].foundObjects.length > 0) {

        var foundSessionUnits = response.outputList[0].foundObjects;
        data.dataProviders.changeContextLinkLOV.validateLOV = function () {
            // no op
        };

        lovService.getInitialValues('', deferedLOV, appCtxSvc.ctx.userSession.props.user_id,
            'Create', appCtxSvc.ctx.userSession, 100, 100, '', '');

        /**
         * Process response when LOV 'getInitialValues' has been performed.
         */
        return deferedLOV.promise.then(function (lovResponse) {
            data.listofEcns = [];
            for (var ii = 0; ii < foundSessionUnits.length; ii++) {
                var noChangeContextEntry1 = {};
                noChangeContextEntry1.propDisplayValue = foundSessionUnits[ii].props['object_name'].uiValues[0];
                noChangeContextEntry1.propInternalValue = '';
                data.listofEcns.push(noChangeContextEntry1);
            }
        }, function (lovResponse) {
            data.listofEcns = [];
            for (var ii = 0; ii < foundSessionUnits.length; ii++) {
                var noChangeContextEntry1 = {};
                noChangeContextEntry1.propDisplayValue = foundSessionUnits[ii].props['object_name'].uiValues[0];
                noChangeContextEntry1.propInternalValue = '';
                data.listofEcns.push(noChangeContextEntry1);
            }
        });
    }
};

export default exports = {
    Mtw0UpdateSessionUnitsLOV,
    Mtw0GetSelectedSessionUnitX,
    Mtw0GetSelectedSessionUnitY
};
/**
 * @member Cm1CreateChangeService
 * @memberof NgServices
 */
app.factory('changeMgmtUtils', () => exports);
