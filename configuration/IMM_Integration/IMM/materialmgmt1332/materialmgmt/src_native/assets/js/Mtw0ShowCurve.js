// Copyright 2018 Siemens Product Lifecycle Management Software Inc.

/* global define */

/**
 * @module js/Mtw0ShowCurve
 * JS file to supply data for line and column chart
 *
 */
import app from 'app';

var exports = {};

var keyValueDataForChart = [];
var arrayOfSeriesDataForChart = [];
var countOfSeriesData = 1;

/**
 * Create Chart with single series data for chart .
 *
 * @param {String} data the view model data
 */
export let createChartFromArrayOfSeries = function (curveObj) {
    if (curveObj) {
        arrayOfSeriesDataForChart = [];
        var xvalues = curveObj.props.mat1ValuesX.dbValues;
        var yvalues = curveObj.props.mat1ValuesY.dbValues;
        countOfSeriesData = 1;
        keyValueDataForChart = [];
        if (yvalues.length > 0 && xvalues.length > 0 && (yvalues.length === xvalues.length)) {
            for (var i = 0; i < yvalues.length; i++) {
                var xval = parseFloat(xvalues[i]).toExponential(3);
                var yval = parseFloat(yvalues[i]).toExponential(3); //.toExponential(2)
                keyValueDataForChart.push({
                    label: parseFloat(xval),
                    value: parseFloat(yval)
                });
            }
        }
        if (keyValueDataForChart.length > 0) {
            arrayOfSeriesDataForChart.push({
                seriesName: curveObj.props.object_name.uiValues[0],
                keyValueDataForChart: keyValueDataForChart
            });
        }

        return arrayOfSeriesDataForChart;

    }
};

export default exports = {
    createChartFromArrayOfSeries
};

app.factory('Mtw0ShowCurve', () => exports);
