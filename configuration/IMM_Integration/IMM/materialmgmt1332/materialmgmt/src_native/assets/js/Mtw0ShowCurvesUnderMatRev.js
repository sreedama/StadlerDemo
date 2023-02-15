// Copyright 2018 Siemens Product Lifecycle Management Software Inc.

/* global define */

/**
 * @module js/Mtw0ShowCurvesUnderMatRev
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
var arrayOfSeriesDataForChart = [];
var gMtw0SelectedSmartCurve = null;
var gMtw0SelectedSmartTable = null;
var gData = null;
/*
 * Constants
 */
var xAxisName = "X";
var yAxisName = "Y";
var categoryLabel = "Category";
var smartCurveTableColumnWidth = 250;

/**
 *
 * @param {*} response Properties of Mat1MaterialRevision from getProperties SOA
 */

export let Mtw0GetSmartTablesFromMaterialRevision = function (response, data) {
    gData = data;
    var mObjects = response.modelObjects;

    var mat1ListOfSmartTableDbValues = [];
	var mat1ListOfInheritedTableDbValues = [];
	
    var i = 0;
    if (mObjects) {
        for (var key in response.modelObjects) {
            var mo = mObjects[key];
            if (mo.type === "Mat1ParameterSmartTable") {
				data.Mtw0SelectedInheritedTable = false;
                // set ui values
                mo.props.awp0CellProperties.uiValues.pop();
                mo.props.awp0CellProperties.dbValues.push(categoryLabel + "\\:" + mo.props.mat1Category.uiValues[0]);
                mat1ListOfSmartTableDbValues.push(mo);

            }
            if (mo.type === "Mat1InheritedParamSmrtTbl") {
				data.Mtw0SelectedInheritedTable = true;
                // set ui values
                mo.props.awp0CellProperties.uiValues.pop();
                mo.props.awp0CellProperties.dbValues.push(categoryLabel + "\\:" + mo.props.mat1Category.uiValues[0]);
                mat1ListOfInheritedTableDbValues.push(mo);

            }
        }
    }
	
    var smartTableObject = new Object();
    smartTableObject.nbOfTables = mat1ListOfSmartTableDbValues.length;
    smartTableObject.existingtables = mat1ListOfSmartTableDbValues;

    var interitedTableObject = new Object();
    interitedTableObject.nbOfTables = mat1ListOfInheritedTableDbValues.length;
    interitedTableObject.existingtables = mat1ListOfInheritedTableDbValues;

	var response = new Object();
    response.smartTableList = smartTableObject;
	response.inheritedTableList = interitedTableObject;
	
    return response;
};

/**
 *
 * @param {*} response Properties of Mat1MaterialRevision from getProperties SOA
 */

export let Mtw0GetInheritedTablesFromMaterialRevision = function (response, data) {
    gData = data;
    var mObjects = response.modelObjects;
    var retObject = new Object();

    var mat1ListOfInheritedTableDbValues = [];
    var i = 0;
    if (mObjects) {
        for (var key in response.modelObjects) {
            var mo = mObjects[key];
            if (mo.type === "Mat1InheritedParamSmrtTbl") {
                // set ui values
                mo.props.awp0CellProperties.uiValues.pop();
                mo.props.awp0CellProperties.dbValues.push(categoryLabel + "\\:" + mo.props.mat1Category.uiValues[0]);
                mat1ListOfInheritedTableDbValues.push(mo);

            }
        }
    }
    retObject.nbOfTables = mat1ListOfInheritedTableDbValues.length;
    retObject.existingtables = mat1ListOfInheritedTableDbValues;
    return retObject;
};

/**
 *
 * Create Chart data for the Smart-Table (selectedObj)
 *
 * @param {*} selectedObj - selected Smart Table whose chart is to be displayed
 * @param {*} Mtw0SmartCurvesChartProvider - Chart Provider which needs to be populated with chart points
 * @param {*} data - View Data model.
 */
export let Mtw0LoadSmartCurvesData = function (selectedObj, Mtw0SmartCurvesChartProvider, data) {

    /**
     * if already selected smart table not same as currently selected one,
     * only then we need to re-render the chart.
     * smart table selection is changed when we select a row in smart curve table
     */
    if (gMtw0SelectedSmartTable !== selectedObj && selectedObj) {

        arrayOfSeriesDataForChart = [];
        var keyValueDataForChart = [];

        gMtw0SelectedSmartTable = selectedObj;
        Mtw0SmartCurvesChartProvider.chartConfig.xAxisLabel = selectedObj.props.mat1UnitXAliasName.uiValues[0];
        Mtw0SmartCurvesChartProvider.chartConfig.yAxisLabel = selectedObj.props.mat1UnitYAliasName.uiValues[0];
        var mat1ListOfCurves = selectedObj.props.mat1ListOfCurves;
        if (mat1ListOfCurves) {
            var listOfCurveValues = mat1ListOfCurves.dbValues;
            if (listOfCurveValues && listOfCurveValues.length > 0) {

                /**
                 * If there are more than one Smart-Curve in Smart-Table,
                 * collect data of all curves.
                 */
                for (var j = 0; j < listOfCurveValues.length; j++) {
                    var curveModelObject = clientDataMgmt.getObject(listOfCurveValues[j]);
                    if (curveModelObject) {

                        var xvalues = curveModelObject.props.mat1ValuesX.uiValues;
                        var yvalues = curveModelObject.props.mat1ValuesY.uiValues;
                        var name = curveModelObject.props.object_name.uiValues[0];

                        if (curveModelObject.props.mat1ListOfRefParameters) {
                            var mat1ListOfRefParameters = curveModelObject.props.mat1ListOfRefParameters.dbValues;
                            if (mat1ListOfRefParameters && mat1ListOfRefParameters.length > 0) {
                                for (var k = 0; k < mat1ListOfRefParameters.length; k++) {
                                    var refParamModelObject = clientDataMgmt.getObject(mat1ListOfRefParameters[k]);
                                    var refParamName = refParamModelObject.props.object_name.uiValues[0];
                                    var refParamValue = refParamModelObject.props.mat1Value.uiValues[0];
                                    name = name + "[" + refParamName + ":" + refParamValue + "]";
                                }
                            }
                        }

                        /*
                         * We can not feed the db data as is to chart. Single chart is rendered for all curves.
                         * Problem with HighChart or AW Chart is that it starts to populate chart point with first curve's values
                         * and if some other curve contains X values which could appear before or after first curve, those are
                         * plotted separately on chart which looks dirty.
                         *
                         * But we need not play with data. Feed the data as is to chart. This would be corrected when charting bug is fixed.
                         */
                        var chartPoints = [];
                        if (yvalues.length > 0 && xvalues.length > 0 && (yvalues.length === xvalues.length)) {
                            for (var i = 0; i < yvalues.length; i++) {
                                var row = {};
                                row.X = parseFloat(parseFloat(xvalues[i]).toFixed(10));
                                row.Y = parseFloat(parseFloat(yvalues[i]).toExponential(3));
                                chartPoints.push(row);
                            }

                            keyValueDataForChart = [];

                            for (var i = 0; i < chartPoints.length; i++) {
                                var xval = parseFloat(chartPoints[i].X);
                                var yval = parseFloat(chartPoints[i].Y);

                                keyValueDataForChart.push({
                                    label: parseFloat(xval).toString(), // Label is 'X' axis and currntly it only accepts string values.
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

                    }
                }

            } else {
                keyValueDataForChart.push({
                    label: "",
                    value: ""
                });
                arrayOfSeriesDataForChart.push({
                    seriesName: "-",
                    uid: "",
                    keyValueDataForChart: keyValueDataForChart
                });
            }
        } else {
            keyValueDataForChart.push({
                label: "",
                value: ""
            });
            arrayOfSeriesDataForChart.push({
                seriesName: "-",
                uid: "",
                keyValueDataForChart: keyValueDataForChart
            });
        }

        /*
         * Find minimum value from all curves.
         */
        var minimumXValue;
        var minimumXValueIndex;
        for (var i = 0; i < arrayOfSeriesDataForChart.length; i++) {
            if (i === 0) {
                minimumXValue = parseFloat(arrayOfSeriesDataForChart[i].keyValueDataForChart[0].label);
            }
            var minimumValueFromCurve = parseFloat(arrayOfSeriesDataForChart[i].keyValueDataForChart[0].label);
            minimumXValue = minimumXValue < minimumValueFromCurve ? minimumXValue : minimumValueFromCurve;
            minimumXValueIndex = minimumXValue < minimumValueFromCurve ? minimumXValueIndex : i;
        }

        if (minimumXValueIndex !== 0) {
            var tempObject = arrayOfSeriesDataForChart[0];
            arrayOfSeriesDataForChart[0] = arrayOfSeriesDataForChart[minimumXValueIndex];
            arrayOfSeriesDataForChart[minimumXValueIndex] = tempObject;
        }

        /**
         * If there is only one curve, then update global variable saying it is selected Curve.
         * ANd call method to show table containing its points.
         * Otherwise, wait for user's curve selection
         */
        if (selectedObj.props.mat1ListOfCurves.dbValues.length === 1) {
            gMtw0SelectedSmartCurve = arrayOfSeriesDataForChart[0];
            this.Mtw0AddUpdateSmartCurveTable(gData);
        } else {
            gData.Mtw0ShowSmartCurveValuesInTable = false;
        }

        Mtw0SmartCurvesChartProvider.chartPoints = arrayOfSeriesDataForChart;
        gData.Mtw0SelectedSmartTableName = selectedObj.props['object_string'].displayValues[0];
    }
};

/**
 * Populate Smart-Curve table Columns.
 * X & Y Axis are populated in chart already. Same names are fed to columns of table.
 * @param {*} tableDataProvider
 * @param {*} xAxisLabel
 * @param {*} yAxisLabel
 */
export let Mtw0GetSmartCurveTableColumns = function (tableDataProvider, xAxisLabel, yAxisLabel) {
    var deferred = AwPromiseService.instance.defer();

    /*
     * We only have 2 Columns = X & Y.
     * Names of those are driven by Chart's X & Y axis names
     */
    var awColumnInfos = [{

            name: xAxisName,
            displayName: xAxisLabel,
            typeName: xAxisName,
            width: smartCurveTableColumnWidth,
            isTreeNavigation: false,
            enableColumnMoving: false,
            enableColumnResizing: true
        }, {

            name: yAxisName,
            displayName: yAxisLabel,
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
 * Add/Update Smart-Curve table when a Curve is selected in chart.
 *
 * @param {*} data
 */
export let Mtw0AddUpdateSmartCurveTable = function (data) {
    data.Mtw0ShowSmartCurveValuesInTable = true;
    eventBus.publish('Mtw0SmartCurveTable.plTable.reload');
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
 * This is Smart-Table selection change event.
 * Add/Update Chart per selected Smart-Table
 *
 * @param {*} smartTableSelectedObject
 * @param {*} smartCurveSelectedRow
 * @param {*} data
 */
export let Mtw0AddRemoveSmartCurvesChart = function (smartTableSelectedObject, smartCurveSelectedRow, data) {
    if (!(!smartTableSelectedObject && smartCurveSelectedRow)) {
        if (smartTableSelectedObject) {
            if (data.Mtw0ShowSmartCurveInChart === true) {
                /**
                 * By Default hide the Points table.
                 * If Smart-Table contains only one Curve, points table is rendered. This is driven while loading Curve data.
                 * So clear out even data related to curve selection & make everything false/null.
                 */
                data.Mtw0ShowSmartCurveValuesInTable = false;
                gMtw0SelectedSmartCurve = null;
                delete gData.eventMap['Mtw0SmartCurvesChartProvider.selected'];
                this.Mtw0LoadSmartCurvesData(smartTableSelectedObject, data.chartProviders.Mtw0SmartCurvesChartProvider, data.dataProviders.Mtw0SmartCurveTableDataProvider, data);

                /**
                 * This is to capture dirty table data.
                 */
                /*
                var promise = data.dataProviders.Mtw0SmartCurveTableDataProvider.isDirty();
                if( promise.$$state.value === true ) {
                console.log( "1" );
                } else {
                console.log( "2" );

                }
                promise = data.isDirty();
                if( promise.$$state.value === true ) {
                console.log( "3" );
                } else {
                console.log( "4" );

                }
                eventBus.publish( 'Mtw0.SmartCurveTable.CancelEdits' );
                 */
            } else {
                data.Mtw0ShowSmartCurveInChart = true;
            }
        } else {
            data.Mtw0ShowSmartCurveInChart = false;
            data.Mtw0ShowSmartCurveValuesInTable = false;
            eventBus.publish('Mtw0.SmartCurveTable.CancelEdits');
        }
    }
};

/**
 * Populate Smart-Curve table with values of selected Curve from Chart.
 *
 * @param {*} data
 * @param {*} Mtw0SelectedSmartCurve
 */
export let Mtw0GetSmartCurveTableData = function (data, Mtw0SelectedSmartCurve) {
    var selectedSmartCurve = null;
    data.filterResults3 = [];
    var vmRows = [];
    if (arrayOfSeriesDataForChart.length > 0) {
        /**
         * If Mtw0SelectedSmartCurve is null, it means table rendering is being called from Smart-Table itself.
         * Otherwise, Curve selection in Chart populates event data with selected Smart-Curve. In this case, rely on
         * Smart-Curve selected global variable which should be set on selection of Smart-Table.
         */
        if (Mtw0SelectedSmartCurve === undefined || Mtw0SelectedSmartCurve === null) {
            selectedSmartCurve = gMtw0SelectedSmartCurve;
        } else {
            selectedSmartCurve = Mtw0SelectedSmartCurve;
        }

        /*
         * Find the selected Smart Curve from the list of Curves available on the selected Smart-Table.
         * Smart-Curves information is maintained in arrayOfSeriesDataForChart when Smart-Table is selected.
         *
         */
        var obj = null;
        for (var i = 0; i < arrayOfSeriesDataForChart.length; i++) {
            if (arrayOfSeriesDataForChart[i].seriesName === selectedSmartCurve.seriesName) {
                obj = arrayOfSeriesDataForChart[i];
                gMtw0SelectedSmartCurve = arrayOfSeriesDataForChart[i];
                break;
            }
        }

        /**
         * We can populate Smart-Curve Table from the Chart-Points of selected Curve.
         * But Curve may have addiitonal/less values than those in DB.
         * So we query the Smart-Curve object, read X & Y values and populate the Smart-Curve table.
         */
        var curveModelObject = clientDataMgmt.getObject(obj.uid);
        if (curveModelObject) {

            var xvalues = curveModelObject.props.mat1ValuesX.uiValues;
            var yvalues = curveModelObject.props.mat1ValuesY.uiValues;

            /**
             * We can not feed the db data as is to chart. Single chart is rendered for all curves.
             * Problem with HighChart or AW Chart is that it starts to populate chart point with first curve's values
             * and if some other curve contains X values which could appear before or after first curve, those are
             * plotted separately on chart which looks dirty.
             *
             * So we need to make sure, all the curve or atleast the first curve fed to chart has the maximum X & Y value coverage.
             */
            var rows = [];
            if (yvalues.length > 0 && xvalues.length > 0 && (yvalues.length === xvalues.length)) {
                for (var i = 0; i < yvalues.length; i++) {
                    var row = {};
                    row.X = parseFloat(parseFloat(xvalues[i]).toFixed(10)); //.toExponential(3); ;
                    row.Y = parseFloat(parseFloat(yvalues[i]).toExponential(3));
                    rows.push(row);
                }
            }

            for (var i = 0; i < rows.length; i++) {

                var valueX = rows[i].X;
                var valueY = rows[i].Y;

                /*
                 * We need not check if both values are present.
                 * Table can show all values. So we are not checking for null or 0 values.
                 *
                 * Create VMO for each row and VMP for each cell.
                 */
                var xColumn = null;
                xColumn = uwPropertySvc.createViewModelProperty(xAxisName, xAxisName, 'DOUBLE', parseFloat(valueX), parseFloat(valueX));

                /*
                 * Convert values to String values. Typically curve values are stored as double in DB.
                 * We need them to be string for time being.
                 */
                xColumn.uiValue = valueX + '';
                xColumn.isEnabled = true;
                xColumn.isRequired = true;
                xColumn.isAutoAssignable = true;

                var yColumn = null;
                yColumn = uwPropertySvc.createViewModelProperty(yAxisName, yAxisName, 'DOUBLE', parseFloat(valueY), parseFloat(valueY));

                /*
                 * Convert values to String values. Typically curve values are stored as double in DB.
                 * We need them to be string for time being.
                 */
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
        }
    } else {
        vmRows = [];
    }

    data.totalFound = vmRows.length;
    data.filterResults3 = vmRows;
    data.Mtw0SelectedSmartCurveName = "Curve : " + selectedSmartCurve.seriesName;
};

export let Mtw0SmartCurveTableCancelEdits = function (data, context, eventData, commandContext) {
    if (gData.dataProviders.Mtw0SmartCurveTableDataProvider.isDirty()) {
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
 * Update Smart-Curve Table edits.
 *
 * @param {*} data
 * @param {*} context
 * @param {*} eventData
 * @param {*} commandContext
 */
export let Mtw0SmartCurveTableSaveEdits = function (data, context, eventData, commandContext) {
    var curveModelObject = clientDataMgmt.getObject(gMtw0SelectedSmartCurve.uid);

    var valuesX = [];
    var valuesY = [];
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
    return AwPromiseService.instance.resolve();
    // console.log("nasaTableSaveEdit");
};

export let Mtw0SmartCurveTableStartEdits = function (data, eventData) {
    console.log("Mtw0SmartCurveTableStartEdits");
};

export default exports = {
    Mtw0GetSmartCurveTableColumns,
    Mtw0GetSmartTablesFromMaterialRevision,
    Mtw0LoadSmartCurvesData,
    Mtw0AddUpdateSmartCurveTable,
    Mtw0AddRemoveSmartCurvesChart,
    Mtw0GetSmartCurveTableData,
    Mtw0SmartCurveTableStartEdits,
    Mtw0SmartCurveTableSaveEdits,
    Mtw0SmartCurveTableCancelEdits,
    Mtw0SmartCurveTableAddRow,
    Mtw0SmartCurveTableDuplicateRows,
    Mtw0SmartCurveTableRemoveRows
};

app.factory('Mtw0ShowCurvesUnderMatRev', () => exports);
