/*global

 */

/**
 * This service provides functions to display and edit forms attached to BOs
 * @module js/displayFormService
 */
import app from 'app';
import _cdm from 'soa/kernel/clientDataModel';
import eventBus from 'js/eventBus';
import dmSvc from 'soa/dataManagementService';
import _ from 'lodash';
import editHandlerService from 'js/editHandlerService';

var exports = {};

/**
 * Get selected Items
 * @param {object} selection - the selected intermediary object in ctx
 * @returns {object} the underlying archerype of the selected intermediary object
 */
export let getSelectedItem = function (selection) {
    const selectedObj = _cdm.getObject(selection.uid);
    const underlyingObj = _cdm.getObject(selectedObj.props.awb0UnderlyingObject.dbValues[0]);
    const selectedItems = [underlyingObj];
    return selectedItems
};

/**
 * Get Part Master of selected occurrence
 * @param {object} response - the response object from the getProperties REST call to TcSOA based on selected item
 * @returns {string} the uid for the Part Master
 */
export let getIMANMasterForm = function (response) {
    const modelObjects = _.toArray(response.modelObjects);
    return modelObjects.filter((item) => _cdm.getObject(item.uid).modelType.typeHierarchyArray.indexOf('Part Master') > -1)[0]
};

/**
 * Get Plant Form of selected occurrence - with method chaining
 * @param {object} response - the response object from the getProperties REST call to TcSOA based on selected item
 * @returns {string} the uid for the Plant Form
 */
export let getPlantForm = function (response) {
    const modelObjects = _.toArray(response.modelObjects);
    return modelObjects.filter((item) => _cdm.getObject(item.uid).modelType.typeHierarchyArray.indexOf('SR5PlantForm') > -1)[0]
};

/**
 * Show the confirmation dialog
 * @param {object} data - viewModel data
 * @returns {promise}
 */
export let showConfirmationDialog = function (data) {
    var editHandler = editHandlerService.getEditHandler('INFO_PANEL_CONTEXT');
    var dataSrc = editHandler.getDataSource();
    var modifiedViewModelProperties = dataSrc.getAllModifiedProperties();

    var propsArra = [];
    _.forEach(modifiedViewModelProperties, function (propertyObj) {
        var prop = {};
        prop['name'] = propertyObj.propertyName;
        prop['values'] = propertyObj.dbValues;
        propsArra.push(prop);

    });

    return dmSvc.setProperties([{
        object: data.selectedBomLine,
        vecNameVal: propsArra
    }]).then(function () {
        editHandler.cancelEdits(true, false);
        eventBus.publish('treeStructure.plTable.reload');
    });
};

/**
 * displayFormService service utility
 *
 * @memberof NgServices
 * @member displayFormService.js
 */
export default exports = {
    getSelectedItem,
    getIMANMasterForm,
    getPlantForm,
    showConfirmationDialog
};

app.factory('displayFormService', () => exports);
