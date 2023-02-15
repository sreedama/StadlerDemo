// Copyright 2018 Siemens Product Lifecycle Management Software Inc.

/*global
define
 */

/**
 * @module js/aw-material-filter-category-numeric-range-filter.directive
 */
import app from 'app';
import 'js/viewModelService';
import 'js/uwPropertyService';
import 'js/aw-icon.directive';
import 'js/visible-when.directive';
import 'js/aw-repeat.directive';
import 'js/aw-date.directive';
import 'js/localeService';
import 'js/filterPanelService';
import 'js/filterPanelUtils';
import 'js/dateTimeService';
import 'js/aw-numeric.directive';
import 'js/aw-list.directive';
import 'js/aw-separator.directive';
import 'js/aw-flex-column.directive';
import 'js/aw-flex-row.directive';
import 'js/aw-widget.directive';
import 'js/aw-property-image.directive';
import "js/aw-scrollpanel.directive";

/**
 * Directive to display numeric range filter
 *
 * @example <aw-material-filter-category-numeric-range-filter1 ng-if="category.showNumericRangeFilter"
 *          search-action="searchAction" category= "category" > </aw-material-filter-category-numeric-range-filter1 >
 *
 * @member aw-material-filter-category-numeric-range-filter
 * @memberof NgElementDirectives
 */
app.directive('awMaterialFilterCategoryNumericRangeFilter', [
        'viewModelService',
        'uwPropertyService',
        'localeService',
        'filterPanelService',
        'filterPanelUtils',
        function (viewModelSvc, uwPropertyService, localeSvc, filterPanelSvc, filterPanelUtils) {
            return {
                transclude: true,
                restrict: 'E',
                scope: {
                    id: '@',
                    category: '='
                },
                controller: [
                    '$scope',
                    function ($scope) {
                        viewModelSvc.getViewModel($scope, true);
                    }
                ],

                templateUrl: app.getBaseUrlPath() + '/html/aw-material-filter-category-numeric-range-filter.directive.html'
            };
        }
    ]);
