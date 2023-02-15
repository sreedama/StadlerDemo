// Copyright 2018 Siemens Product Lifecycle Management Software Inc.

/* global define */

/**
 * @module js/Mtw0ShowSmartCurveTable
 * JS file to supply data for line and column chart
 *
 */
import app from 'app';

import tcViewModelObjectSvc from 'js/tcViewModelObjectService';
import uwPropertySvc from 'js/uwPropertyService';
import eventBus from 'js/eventBus';
import awColumnSvc from 'js/awColumnService';
import AwPromiseService from 'js/awPromiseService';
import clientDataMgmt from 'soa/kernel/clientDataModel';
import dmSvc1 from 'soa/dataManagementService';

/*
 * Global Variables
 */
var exports = {};
var gData = null;
var gMtw0SelectedSmartCurve = null;

/*
 * Constants
 */
var xAxisName = "X";
var yAxisName = "Y";
var smartCurveTableColumnWidth = 100;

/**
 * Populate Smart-Curve table from SOA Response.
 * We need not validate data.
 * No sorting.
 *
 *
 * @param {*} data
 * @param {*} Mtw0SelectedSmartCurve
 */
export let Mtw0GetSmartCurveTableData = function (response, data, ctx) {

    gData = data;
    var mObjects = response.modelObjects;
    var vmRows = [];

    if (mObjects) {
        for (var key in response.modelObjects) {
            var mo = mObjects[key];

            /**
             * We expect only one Mat1SmartCurve in SOA Response.
             */
            if (mo.type === "Mat1SmartCurve") {

                var curveModelObject = mo;
                gMtw0SelectedSmartCurve = mo;

                var xvalues = curveModelObject.props.mat1ValuesX.uiValues;
                var yvalues = curveModelObject.props.mat1ValuesY.uiValues;

                var rows = [];
                if (yvalues.length > 0 && xvalues.length > 0 && (yvalues.length === xvalues.length)) {
                    for (var i = 0; i < yvalues.length; i++) {
                        var row = {};
                        row.X = parseFloat(parseFloat(xvalues[i]).toFixed(10)); //.toExponential(3); ;
                        row.Y = parseFloat(parseFloat(yvalues[i]).toExponential(3));
                        rows.push(row);
                    }
                    /*
                    rows.sort( function( a, b ) {
                    var ax = a.X;
                    var bx = b.X;
                    if( ax > bx ) {
                    return 1
                    } else if( ax < bx ) {
                    return -1
                    } else {
                    return 0;
                    }
                    // return a.X > b.X;
                    } );
                     */
                }

                for (var i = 0; i < rows.length; i++) {

                    var valueX = rows[i].X;
                    var valueY = rows[i].Y;

                    /**
                     * Create X & Y Double property.
                     */
                    var xColumn = null;
                    xColumn = uwPropertySvc.createViewModelProperty(xAxisName, xAxisName, 'DOUBLE', parseFloat(valueX), parseFloat(valueX));

                    /*
                     * Convert values to String values. Curve values are stored as double in DB.
                     * We need them to be string as ui value.
                     */
                    xColumn.uiValue = valueX + '';
                    xColumn.isEnabled = true;
                    xColumn.isRequired = true;
                    xColumn.isAutoAssignable = true;

                    var yColumn = null;
                    yColumn = uwPropertySvc.createViewModelProperty(yAxisName, yAxisName, 'DOUBLE', parseFloat(valueY), parseFloat(valueY));
                    yColumn.uiValue = valueY + '';
                    yColumn.isEnabled = true;
                    yColumn.isRequired = true;
                    yColumn.isAutoAssignable = true;

                    /**
                     * Create VMO for each row and populate it with X & Y VMP.
                     */
                    var vmObject = tcViewModelObjectSvc.createViewModelObjectById(i);
                    vmObject.type = 'SmartCurvePoints';
                    vmObject.identifier = i + '';
                    vmObject.typeIconURL = '';
                    vmObject.tableName = 'smartCurveTable';
                    vmObject.props[xAxisName] = xColumn;
                    vmObject.props[yAxisName] = yColumn;
                    vmRows.push(vmObject);
                }
                break;
            }
        }
    }

    /**
     * Create return object, fill in data and return
     * Also mark Chart as renderable now.
     */

    var retObject = new Object();

    data.Mtw0ShowSmartCurveInChart = true;
    retObject.totalFound = vmRows.length;
    retObject.rows = vmRows;
    return retObject;
};

/**
 * Render Chart data for the Smart-Table.
 * Chart would be rendered in 2 cases.
 * 1. Initial load from table data
 * 2. Table updated in case of Add/Edit/Remove rows.
 *
 * In 2nd case, table SaveEdits would trigger chart rendering and we would not have chartProvider.
 * So we need to rely on global variable to
 *
 * @param {*} Mtw0SmartCurvesChartProvider - Chart Provider which needs to be populated with chart points
 * @param {*} data - View Data model.
 * @param {*} renderChartFromVM
 */
export let Mtw0LoadSmartCurvesData = function (Mtw0SmartCurvesChartProvider, data, renderChartFromVM) {

    /**
     * if chart provider is null or undefined, pick it from global.
     */
    if (Mtw0SmartCurvesChartProvider === null || Mtw0SmartCurvesChartProvider === undefined) {
        Mtw0SmartCurvesChartProvider = gData.chartProviders.Mtw0SmartCurvesChartProvider;
    }

    /**
     * We don't know what we have in X & Y axis. SmartCurve does not have this information.
     * So we would hardcode it to X & Y.
     */
    Mtw0SmartCurvesChartProvider.chartConfig.xAxisLabel = xAxisName;
    Mtw0SmartCurvesChartProvider.chartConfig.yAxisLabel = yAxisName;

    var arrayOfSeriesDataForChart = [];
    var xvalues = [];
    var yvalues = [];
    var curveModelObject = clientDataMgmt.getObject(gMtw0SelectedSmartCurve.uid);

    /**
     * If rendering is called after a table save, X & Y values would be picked from ViewModel.
     * Otherwise, values to be read from Smart Curve object
     */
    if (renderChartFromVM === true) {

        var vmc = gData.dataProviders.Mtw0SmartCurveTableDataProvider.viewModelCollection;
        var vmObjects = vmc.loadedVMObjects;

        for (var i = 0; i < vmObjects.length; i++) {
            xvalues.push(vmObjects[i].props['X'].uiValue);
            yvalues.push(vmObjects[i].props['Y'].uiValue);
        }
    } else {

        if (curveModelObject) {
            xvalues = curveModelObject.props.mat1ValuesX.uiValues;
            yvalues = curveModelObject.props.mat1ValuesY.uiValues;
        }
    }
    var name = curveModelObject.props.object_name.uiValues[0];

    /**
     * Populate chart points
     */
    var chartPoints = [];
    if (yvalues.length > 0 && xvalues.length > 0 && (yvalues.length === xvalues.length)) {
        for (var i = 0; i < yvalues.length; i++) {
            var row = {};
            row.X = parseFloat(parseFloat(xvalues[i]).toFixed(10));
            row.Y = parseFloat(parseFloat(yvalues[i]).toExponential(3));
            chartPoints.push(row);
        }
        var keyValueDataForChart = [];

        for (var i = 0; i < chartPoints.length; i++) {
            var xval = parseFloat(chartPoints[i].X);
            var yval = parseFloat(chartPoints[i].Y);

            /**
             * X axis is currently string and not mathematical value. So we need to convert value to string.
             */
            keyValueDataForChart.push({
                label: parseFloat(xval).toString(),
                value: yval
            });
        }

        if (keyValueDataForChart.length > 0) {
            arrayOfSeriesDataForChart.push({
                seriesName: name,
                uid: curveModelObject.uid,
                keyValueDataForChart: keyValueDataForChart
            });
        }
    }

    Mtw0SmartCurvesChartProvider.chartPoints = arrayOfSeriesDataForChart;
};

/**
 * Populate Smart-Curve table Columns.
 * @param {*} tableDataProvider
 */
export let Mtw0GetSmartCurveTableColumns = function (tableDataProvider) {
    var deferred = AwPromiseService.instance.defer();

    /*
     * We only have 2 Columns = X & Y.
     * Names of those are driven by Chart's X & Y axis names
     */
    var awColumnInfos = [{

            name: xAxisName,
            displayName: xAxisName,
            typeName: xAxisName,
            width: smartCurveTableColumnWidth,
            isTreeNavigation: false,
            enableColumnMoving: false,
            enableColumnResizing: true
        }, {

            name: yAxisName,
            displayName: yAxisName,
            typeName: yAxisName,
            width: smartCurveTableColumnWidth,
            isTreeNavigation: false,
            enableColumnMoving: false,
            enableColumnResizing: true
        }
    ];

    awColumnSvc.createColumnInfo(awColumnInfos);

    tableDataProvider.columnConfig = {
        columns: awColumnInfos
    };

    deferred.resolve({
        columnInfos: awColumnInfos
    });

    return deferred.promise;
};

/**
 * Start edit of the table.
 *
 * @param {*} data
 */
export let Mtw0SmartCurveTableStartEdits = function (data) {
    console.log("Mtw0SmartCurveTableStartEdits");
};

/**
 * Save the current data in table to databse.
 * 1. Vaidate the table data
 * 2. Call setProperties to save data to TC.
 * 3. Rerender chart.
 *
 * @param {*} data
 * @param {*} context
 * @param {*} eventData
 */
export let Mtw0SmartCurveTableSaveEdits = function (data, context, eventData) {
    var curveModelObject = gMtw0SelectedSmartCurve;

    var valuesX = [];
    var valuesY = [];

    /**
     * Get all the points, call setProperties and save TC Object.
     */
    var vmObjects = gData.dataProviders.Mtw0SmartCurveTableDataProvider.viewModelCollection.loadedVMObjects;
    for (var i = 0; i < vmObjects.length; i++) {
        valuesX.push(vmObjects[i].props['X'].dbValue + '');
        valuesY.push(vmObjects[i].props['Y'].dbValue + '');
    }
    dmSvc1.setProperties([{
                object: curveModelObject,
                vecNameVal: [{
                        name: 'mat1ValuesX',
                        values: valuesX
                    }, {
                        name: 'mat1ValuesY',
                        values: valuesY
                    }
                ]
            }
        ]).then(function () {
        console.log("DONE");
        // eventBus.publish('Mtw0SmartCurvesChartProvider.selected');
        // eventBus.publish( 'performSelNotesSearch.reset' );
        // var editHandler = editHandlerSvc.getEditHandler( 'INFO_PANEL_CONTEXT' );
        // editHandler.cancelEdits( true, false );
        // editHandler.startEdit();
        // appCtxSvc.unRegisterCtx( 'noteTxtValues' );
    });

    var renderChartFromVM = true;
    this.Mtw0LoadSmartCurvesData(null, data, renderChartFromVM);
    return AwPromiseService.instance.resolve();
};

/**
 *
 * Cancel table edits. WIP.
 * This should restore the original VMO
 *
 * @param {*} data
 * @param {*} context
 * @param {*} eventData
 * @param {*} commandContext
 */
export let Mtw0SmartCurveTableCancelEdits = function (data, context, eventData, commandContext) {
    if (data.dataProviders.Mtw0SmartCurveTableDataProvider.isDirty()) {
        console.log("Mtw0SmartCurveTableDataProvider Dirty");
    } else {
        console.log("Mtw0SmartCurveTableDataProvider Not Dirty");
    }

    if (data.isDirty()) {
        console.log("data Dirty");
    } else {
        console.log("data Not Dirty");
    }

    console.log("Mtw0SmartCurveTableCancelEditsAction");
};

/**
 * Add a row to Smart-Curve table data.
 * 1. If a row is selcted in table, add new row after selection otherwise, add row to the top of table.
 * 2. Call startEdit to bring table in Edit-Mode.
 *
 * @param {*} data
 * @param {*} eventData
 */
export let Mtw0SmartCurveTableAddRow = function (data, eventData) {

    var vmc = gData.dataProviders.Mtw0SmartCurveTableDataProvider.viewModelCollection;
    var vmObjects = vmc.loadedVMObjects;

    var xColumn = uwPropertySvc.createViewModelProperty(xAxisName, xAxisName, 'DOUBLE', parseFloat(0), parseFloat(0));
    xColumn.uiValue = 0 + '';
    xColumn.isEnabled = true;
    xColumn.isRequired = true;
    xColumn.isAutoAssignable = true;
    // making this true is making ui value blank if we do cancel edits.
    // xColumn.valueUpdated = true;

    var yColumn = uwPropertySvc.createViewModelProperty(yAxisName, yAxisName, 'DOUBLE', parseFloat(0), parseFloat(0));
    yColumn.uiValue = 0 + '';
    yColumn.isEnabled = true;
    yColumn.isRequired = true;
    yColumn.isAutoAssignable = true;
    // making this true is making ui value blank if we do cancel edits.
    // yColumn.valueUpdated = true;

    var vmObject = tcViewModelObjectSvc.createViewModelObjectById(9999);
    vmObject.type = 'SmartCurvePoints';
    vmObject.identifier = 9999;
    vmObject.typeIconURL = '';
    vmObject.tableName = 'smartCurveTable';

    vmObject.props[xAxisName] = xColumn;
    vmObject.props[yAxisName] = yColumn;

    /**
     * We need to add row after the selected row. If there is no selection, add row to the start of table.
     */
    if (gData.dataProviders.Mtw0SmartCurveTableDataProvider.selectedObjects.length === 1) {
        var selectedObjectIndex = vmObjects.indexOf(gData.dataProviders.Mtw0SmartCurveTableDataProvider.selectedObjects[0]);
        vmObjects.splice(selectedObjectIndex + 1, 0, vmObject);

    } else {
        vmObjects.unshift(vmObject);
    }

    vmc.clear();
    vmc.setTotalObjectsFound(vmObjects.length);
    vmc.updateModelObjects(vmObjects, null, gData.dataProviders.Mtw0SmartCurveTableDataProvider.preSelection);
    gData.dataProviders.Mtw0SmartCurveTableDataProvider.selectedObjects.length = 0;
    eventData.ctx.selected = null;

    /**
     * Bring table to edit mode to update the recently added values.
     */
    eventBus.publish('Mtw0.SmartCurveTable.StartEdit');
};

/**
 * Duplicate the selected rows from Smart-Curve table.
 * 1. It adds new row after the selected row.
 *    If more than one row is selected, all rows are duplicated and new rows are added after the corresponding selected row.
 * 2. Call SaveEdits to save the duplicated rows.
 *
 * @param {*} data
 * @param {*} context
 * @param {*} eventData
 */
export let Mtw0SmartCurveTableDuplicateRows = function (data, context, eventData) {
    var vmc = gData.dataProviders.Mtw0SmartCurveTableDataProvider.viewModelCollection;
    var vmObjects = vmc.loadedVMObjects;
    for (var i = 0; i < gData.dataProviders.Mtw0SmartCurveTableDataProvider.selectedObjects.length; i++) {
        var indexOfObjectToBeDuplicated = vmObjects.indexOf(gData.dataProviders.Mtw0SmartCurveTableDataProvider.selectedObjects[i]);

        /**
         * Shallow Copy
         */
        // var vmObject = Object.assign({},vmObjects[indexOfObjectToBeDuplicated]);

        /**
         * Deep Copy
         */
        var vmObject = JSON.parse(JSON.stringify(vmObjects[indexOfObjectToBeDuplicated]));
        vmObjects.splice(indexOfObjectToBeDuplicated + 1, 0, vmObject);
    }

    vmc.clear();
    vmc.setTotalObjectsFound(vmObjects.length);
    vmc.updateModelObjects(vmObjects, null, gData.dataProviders.Mtw0SmartCurveTableDataProvider.preSelection);
    // gData.dataProviders.Mtw0SmartCurveTableDataProvider.selectedObjects.length = 0;
    // eventData.ctx.selected = null;

    /**
     * This should do the save. But even though event is getting fired, it is not getting catched by JS.
     */
    eventBus.publish("Mtw0.SmartCurveTable.SaveEdits");

    this.Mtw0SmartCurveTableSaveEdits(data, context);
};

/**
 * Remove selected rows from Smart-Curve table
 * 1. Remove the selected rows
 * 2. Call SaveEdits to update the TC Object
 *
 * @param {*} data
 * @param {*} context
 * @param {*} eventData
 */
export let Mtw0SmartCurveTableRemoveRows = function (data, context, eventData) {
    var vmc = gData.dataProviders.Mtw0SmartCurveTableDataProvider.viewModelCollection;
    var vmObjects = vmc.loadedVMObjects;
    for (var i = 0; i < gData.dataProviders.Mtw0SmartCurveTableDataProvider.selectedObjects.length; i++) {
        var indexOfObjectToBeRemoved = vmObjects.indexOf(gData.dataProviders.Mtw0SmartCurveTableDataProvider.selectedObjects[i]);
        vmObjects.splice(indexOfObjectToBeRemoved, 1);
    }

    vmc.clear();
    vmc.setTotalObjectsFound(vmObjects.length);
    vmc.updateModelObjects(vmObjects, null, gData.dataProviders.Mtw0SmartCurveTableDataProvider.preSelection);
    gData.dataProviders.Mtw0SmartCurveTableDataProvider.selectedObjects.length = 0;
    eventData.ctx.selected = null;

    /**
     * This should do the save. But even though event is getting fired, it is not getting catched by JS.
     * So we have to manually call corresponding JS method.
     */
    eventBus.publish("Mtw0.SmartCurveTable.SaveEdits");

    this.Mtw0SmartCurveTableSaveEdits(data, context);
};

export default exports = {
    Mtw0GetSmartCurveTableColumns,
    Mtw0LoadSmartCurvesData,
    Mtw0GetSmartCurveTableData,
    Mtw0SmartCurveTableStartEdits,
    Mtw0SmartCurveTableSaveEdits,
    Mtw0SmartCurveTableCancelEdits,
    Mtw0SmartCurveTableAddRow,
    Mtw0SmartCurveTableDuplicateRows,
    Mtw0SmartCurveTableRemoveRows
};

app.factory('Mtw0ShowSmartCurveTable', () => exports);
