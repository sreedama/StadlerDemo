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
 * Defines the {@link NgControllers.MaterialSearchSubLocationCtrl}
 *
 * @module js/aw.materialSearch.sublocation.controller
 * @requires app
 * @requires angular
 * @requires js/eventBus
 * @requires js/aw.default.location.controller
 */
import app from 'app';
import ngModule from 'angular';
import eventBus from 'js/eventBus';
import 'js/aw.native.sublocation.controller';
import 'js/appCtxService';
import 'js/localeService';
import 'js/command.service';

'use strict';
/*eslint-disable-next-line valid-jsdoc*/
/**
 * Material search sublocation controller.
 * @memberOf NgControllers
 */
app
.controller(
    'MaterialSearchSubLocationCtrl',
    [
        '$scope',
        '$state',
        '$controller',
        '$timeout',
        'appCtxService',
        'commandService',
        function ($scope, $state, $controller, $timeout, appCtxService, commandService) {
            var ctrl = this;
            var panelOpen = false;
            //DefaultSubLocationCtrl will handle setting up context correctly
            ngModule.extend(ctrl, $controller('NativeSubLocationCtrl', {
                    $scope: $scope
                }));

            // var ctxMaterialSearch = appCtxService.getCtx( "materialSearch" );
            //reset search Input when user navigates to this
            var materialSearch = {
                materialSearchInput: ""
            };
            appCtxService.registerCtx("materialSearch", materialSearch);
            /* if( ctxMaterialSearch ) {
            var materialSearch = {
            materialSearchInput: ""
            };
            appCtxService.registerCtx( "materialSearch", materialSearch );
            } */

            if (!appCtxService.ctx.activeNavigationCommand) {
                commandService.executeCommand('Mtw0MaterialSearch', null, $scope);
                panelOpen = true;
            }
            var doSearchListener = eventBus.subscribe('search.doMaterialSearch', function (eventData) {
                if ($scope.provider && $scope.provider.params) {
                    $scope.provider.params.searchCriteria = eventData;
                }
                eventBus.publish('Mtw0MaterialSearchList.showData');
            });

            var openPanel = function () {
                if (!(appCtxService.ctx.activeNavigationCommand && appCtxService.ctx.activeNavigationCommand.commandId === 'Mtw0MaterialSearch')) {
                    var ctxMaterialSearch = appCtxService.getCtx("materialSearch");
                    if (!(typeof ctxMaterialSearch !== 'undefined' && ctxMaterialSearch.totalFound > 0) && !panelOpen) {
                        $timeout(function () {
                            commandService.executeCommand('Mtw0MaterialSearch', null, $scope);
                        }, 300);
                    }
                }
            };

            //Remove listeners on destroy
            $scope.$on('$destroy', function () {
                eventBus.unsubscribe(doSearchListener);
            });

            //When a state parameter changes
            $scope.$on('$locationChangeSuccess', function () {
                //Update the provider

                openPanel();
                /* var context = appCtxService.getCtx( 'materialSearch' );
                if( context && context.searchCriteria && $scope.provider && $scope.provider.params ) {
                $scope.provider.params.searchCriteria = context.searchCriteria.uiValue;
                } */
            });
        }
    ]);
