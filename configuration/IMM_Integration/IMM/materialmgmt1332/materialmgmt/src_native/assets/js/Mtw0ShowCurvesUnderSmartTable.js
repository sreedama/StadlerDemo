// Copyright 2018 Siemens Product Lifecycle Management Software Inc.

/* global define */

/**
 * @module js/Mtw0ShowCurvesUnderSmartTable
 * JS file to supply data for line and column chart
 *
 */
import app from 'app';
import dmSrv from 'soa/dataManagementService';
import clientDataMgmt from 'soa/kernel/clientDataModel';
import logger from 'js/logger';
import propertyPolicySrv from 'soa/kernel/propertyPolicyService';

var exports = {};

var keyValueDataForChart = [];
var arrayOfSeriesDataForChart = [];
var countOfSeriesData = 1;
var mat1ListOfCurves;

/**
 * Create Chart with single series data for chart .
 *
 * @param {String} data the view model data
 */
export let createChartFromArrayOfSeries = function (selectedObj, chartProvider) {

    arrayOfSeriesDataForChart = [];
    if (selectedObj) {
        /**
         * Register property policy.
         */
        var policyId = propertyPolicySrv.register({
            types: [{
                    name: 'BusinessObject',
                    properties: [{
                            name: 'object_string'
                        }, {
                            name: 'object_type'
                        }, {
                            name: 'object_name'
                        }
                    ]
                }, {
                    name: 'Mat1SmartCurve',
                    properties: [{
                            name: 'mat1ValuesX'
                        }, {
                            name: 'mat1ValuesY'
                        }, {
                            name: 'mat1ListOfRefParameters',
                            modifiers: [{
                                    name: 'withProperties',
                                    Value: 'true'
                                }
                            ]
                        }, {
                            name: 'mat1MathFormula'
                        }
                    ]
                }, {
                    name: 'Mat1ParameterSmartTable',
                    properties: [{
                            name: 'mat1ListOfCurves',
                            modifiers: [{
                                    name: 'withProperties',
                                    Value: 'true'
                                }
                            ]
                        }, {
                            name: 'mat1UnitXAliasName'
                        }, {
                            name: 'mat1UnitYAliasName'
                        }, {
                            name: 'mat1RealName'
                        }
                    ]
                }, {
                    name: 'Mat1ParameterDouble',
                    properties: [{
                            name: 'mat1Value'
                        }, {
                            name: 'mat1ValueMax'
                        }
                    ]
                }, {
                    name: 'Mat1ParameterString',
                    properties: [{
                            name: 'mat1Value'
                        }
                    ]
                }
            ]
        });

        dmSrv.getTCSessionInfo().then(function () {
            // Loading curve properties
            return dmSrv.getProperties([selectedObj.uid], ['mat1ListOfCurves', 'mat1UnitXAliasName', 'mat1UnitYAliasName', 'mat1RealName', 'object_name']);
        }).then(function () {

            //var object_name = selectedObj.props.object_name;
            //var object_type = selectedObj.props.object_type;
            //var mat1RealName = selectedObj.props.mat1RealName;
            //var material = selectedObj.props.mat1OwningMaterialRevision;
            //var mat1UnitXAliasName = selectedObj.props.mat1UnitXAliasName;
            //var mat1UnitYAliasName = selectedObj.props.mat1UnitYAliasName;

            mat1ListOfCurves = selectedObj.props.mat1ListOfCurves;
            if (mat1ListOfCurves) {
                var listOfCurveValues = mat1ListOfCurves.dbValues;
                if (listOfCurveValues && listOfCurveValues.length > 0) {
                    //console.log("curves: " + listOfCurveValues.length);

                    for (var j = 0; j < listOfCurveValues.length; j++) {
                        var curveModelObject = clientDataMgmt.getObject(listOfCurveValues[j]);
                        if (curveModelObject) {

                            var xvalues = curveModelObject.props.mat1ValuesX.uiValues;
                            var yvalues = curveModelObject.props.mat1ValuesY.uiValues;
                            var name = curveModelObject.props.object_name.uiValues[0];

                            if (curveModelObject.props.mat1ListOfRefParameters) {
                                var mat1ListOfRefParameters = curveModelObject.props.mat1ListOfRefParameters.dbValues;
                                if (mat1ListOfRefParameters && mat1ListOfRefParameters.length > 0) {
                                    console.log("mat1ListOfRefParameters: " + mat1ListOfRefParameters.length);
                                    for (var k = 0; k < mat1ListOfRefParameters.length; k++) {
                                        var refParamModelObject = clientDataMgmt.getObject(mat1ListOfRefParameters[k]);
                                        var refParamName = refParamModelObject.props.object_name.uiValues[0];
                                        var refParamValue = refParamModelObject.props.mat1Value.uiValues[0];
                                        name = name + "[" + refParamName + ":" + refParamValue + "]";
                                    }
                                }
                            }
                            if (xvalues && yvalues) {
                                countOfSeriesData = 1;
                                keyValueDataForChart = [];
                                if (yvalues.length > 0 && xvalues.length > 0 && (yvalues.length === xvalues.length)) {
                                    for (var i = 0; i < yvalues.length; i++) {
                                        var xval = parseFloat(xvalues[i]).toExponential(3);
                                        var yval = parseFloat(yvalues[i]).toExponential(3); //.toExponential(2)
                                        //console.log(xval + " - " +yval);
                                        keyValueDataForChart.push({
                                            label: parseFloat(xval).toString(), // this is important since Siemens has changed the controler to use only strings in categories
                                            value: parseFloat(yval)
                                        });
                                    }
                                }
                                if (keyValueDataForChart.length > 0) {
                                    arrayOfSeriesDataForChart.push({
                                        seriesName: name,
                                        keyValueDataForChart: keyValueDataForChart
                                    });
                                }
                            }
                        }
                    }
                }
            }
            //return null;

        }, function (err) {
            logger.error('getProperties failed:\n\t' + err.message);
            return null;

        }).then(function () {
            propertyPolicySrv.unregister(policyId);
            //return 'OK';
            return arrayOfSeriesDataForChart;
        });

        //if(object_type === "Mat1SmartCurve" ){
        //}else if(object_type === "Mat1ParameterSmartTable" ){
        //}

    }
    return arrayOfSeriesDataForChart;
};

export default exports = {
    createChartFromArrayOfSeries
};

app.factory('Mtw0ShowCurvesUnderSmartTable', () => exports);
