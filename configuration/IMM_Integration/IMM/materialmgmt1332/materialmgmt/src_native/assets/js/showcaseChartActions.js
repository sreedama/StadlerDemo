// Copyright 2018 Siemens Product Lifecycle Management Software Inc.

/* global define */

/**
 * @module js/showcaseChartActions
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

        // 41.01, 152, 190, 366, 255, 314, 122, 155, 180 ;
        //yvalues.forEach( function( val ) {
        //yvaluesArr.push(parseFloat(val).toExponential(2));

        //} );
        countOfSeriesData = 1;
        keyValueDataForChart = [];
        if (yvalues.length > 0 && xvalues.length > 0 && (yvalues.length === xvalues.length)) {
            for (var i = 0; i < yvalues.length; i++) {
                var xval = parseFloat(xvalues[i]).toExponential(10);
                var yval = parseFloat(yvalues[i]).toExponential(10); //.toExponential(2)
                //console.log(xval + " - " +yval);
                keyValueDataForChart.push({
                    label: parseFloat(xval),
                    value: parseFloat(yval)
                });
            }
        }
        if (keyValueDataForChart.length > 0) {
            arrayOfSeriesDataForChart.push({
                seriesName: "Series 1",
                keyValueDataForChart: keyValueDataForChart
            });
        }

        return arrayOfSeriesDataForChart;

    }
};

/**
 * Update Chart by incrementing the series data when the 'Add another series' button is clicked.
 *
 * @param {String} data the view model data
 */

export let addSeriesToCurve = function () {
    var dummyValuesForSecondSeries = [49, 220, 143, 242, 150, 141, 547, 356];
    countOfSeriesData++;
    keyValueDataForChart = [];
    if (countOfSeriesData === 2) {
        for (var i = 1; i < 9; i++) {
            keyValueDataForChart.push({
                label: String.fromCharCode(65 + keyValueDataForChart.length),
                value: dummyValuesForSecondSeries[i - 1]
            });
        }
    } else {
        for (var i = 1; i < 9; i++) {
            keyValueDataForChart.push({
                label: String.fromCharCode(65 + keyValueDataForChart.length),
                value: Math.ceil(i * Math.random() * 100)
            });
        }
    }
    arrayOfSeriesDataForChart.push({
        seriesName: "Series " + countOfSeriesData,
        keyValueDataForChart: keyValueDataForChart
    });

};

/**
 * Update Chart by decrementing the series data when the 'Remove a series' button is clicked.
 *
 * @param {String} data the view model data
 */

export let removeSeriesFromCurve = function () {
    if (arrayOfSeriesDataForChart.length !== 1) {
        arrayOfSeriesDataForChart.pop();
        countOfSeriesData--;
    }
};

export default exports = {
    createChartFromArrayOfSeries,
    addSeriesToCurve,
    removeSeriesFromCurve
};

app.factory('showcaseChartActions', () => exports);
