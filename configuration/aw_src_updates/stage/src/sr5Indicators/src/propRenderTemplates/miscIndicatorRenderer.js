/**
 * global
 * define
 */

/**
 * Property renderer for custom indicator column sr5IndicatorsAW
 * 
 * @module propRenderTemplates/miscIndicatorRenderer
 * @requires app
 */

import app from 'app';
import cdm from 'soa/kernel/clientDataModel';
import dataManagementService from 'soa/dataManagementService';
import propPolicySvc from 'soa/kernel/propertyPolicyService';

let exports = {};

/**
 * Renderer function for checked out status of item revision and related datasets
 * with iman_specification relation, BOMView Revisions and in process flag
 * 
 * @param {object} vmo - ViewModelObject for which indicators are being rendered
 * @param {object} containerElement - The container DOM Element inside which the indicators will be placed
 * @returns void
 */

export let renderPropertyIndicators = (vmo, containerElement) => {

    const object = cdm.getObject(vmo.uid);

    if (object && object.props && object.props.awb0UnderlyingObject) {

        const policy = {
            types: [{
                    name: 'Dataset',
                    properties: [{
                        name: 'checked_out'
                    }]
                },
                {
                    name: 'PSBOMViewRevision',
                    properties: [{
                            name: 'checked_out'
                        },
                        {
                            name: 'checked_out_date'
                        },
                        {
                            name: 'checked_out_user'
                        }
                    ]
                },
                {
                    name: 'SR5GenPartRevision',
                    properties: [{
                        name: 'structure_revisions',
                        modifiers: [{
                            name: 'withProperties',
                            Value: 'true'
                        }]
                    }]
                }

            ]
        };

        const policyId = propPolicySvc.register(policy);

        dataManagementService.getProperties(object.props.awb0UnderlyingObject.dbValues, ['checked_out', 'fnd0InProcess', 'release_status_list', 'IMAN_specification', 'structure_revisions']).then(() => {

            if (policyId) propPolicySvc.unregister(policyId);

            const underlyingObj = cdm.getObject(object.props.awb0UnderlyingObject.dbValues[0]);

            // Create DOM Elements for CATPart, CATProduct and CATDrawing dataset checked out status related with IMAN_specification

            if (underlyingObj.props && underlyingObj.props.IMAN_specification) {
                const imanSpecificationUids = underlyingObj.props.IMAN_specification.dbValues;
                const cadDatasets = imanSpecificationUids.reduce((filtered, imanSpecificationUid) => {
                    let relatedObject = cdm.getObject(imanSpecificationUid);
                    if ((relatedObject.modelType.typeHierarchyArray.indexOf('CATPart') > -1 || relatedObject.modelType.typeHierarchyArray.indexOf('CATProduct') > -1 || relatedObject.modelType.typeHierarchyArray.indexOf('CATDrawing') > -1) && (relatedObject.props.checked_out && relatedObject.props.checked_out.dbValues[0] === 'Y')) {
                        filtered.push(relatedObject);
                    }
                    return filtered;
                }, []);
                if (cadDatasets.length) {
                    let tooltip = "";
                    cadDatasets.forEach((cadDataset, index) => {
                        tooltip += cadDataset.modelType.displayName;
                        if (index < cadDatasets.length - 1) tooltip += ', ';
                    });
                    let imagePath = `${app.getBaseUrlPath()}/image/indicatorCheckedOutDataset16.svg`;
                    let cellImg = createCellImg(imagePath, tooltip);
                    containerElement.appendChild(cellImg);
                }
            }

            // Create DOM Elements for BOMViews checked out status
            if (underlyingObj.props && underlyingObj.props.structure_revisions) {
                const bomViewUids = underlyingObj.props.structure_revisions.dbValues;
                bomViewUids.forEach(bomViewUid => {
                    let bomView = cdm.getObject(bomViewUid);
                    if (bomView.props.checked_out && bomView.props.checked_out.dbValues[0] === 'Y') {
                        let tooltip = `${bomView.props.checked_out_user.propertyDescriptor.displayName}: ${bomView.props.checked_out_user.uiValues[0]}\n`;
                        tooltip += `${bomView.props.checked_out_date.propertyDescriptor.displayName}: ${bomView.props.checked_out_date.uiValues[0]}`;

                        let imagePath = `${app.getBaseUrlPath()}/image/indicatorCheckedOutBomView16.svg`;
                        let cellImg = createCellImg(imagePath, tooltip);
                        containerElement.appendChild(cellImg);
                    }
                })
            }

            // Create DOM Element for vmo checked out status
            if (underlyingObj.props && underlyingObj.props.checked_out && underlyingObj.props.checked_out.dbValues[0] === 'Y') {

                let tooltip = `${underlyingObj.props.checked_out_user.propertyDescriptor.displayName}: ${underlyingObj.props.checked_out_user.uiValues[0]}\n`;
                tooltip += `${underlyingObj.props.checked_out_date.propertyDescriptor.displayName}: ${underlyingObj.props.checked_out_date.uiValues[0]}`;

                let imagePath = `${app.getBaseUrlPath()}/image/indicatorCheckedOut16.svg`;
                let cellImg = createCellImg(imagePath, tooltip);
                containerElement.appendChild(cellImg);

            }

            // Create DOM Element for vmo when in process
            if (underlyingObj.props && underlyingObj.props.fnd0InProcess && underlyingObj.props.fnd0InProcess.dbValues[0] === '1') {

                let tooltip = `${underlyingObj.props.fnd0InProcess.propertyDescriptor.displayName}: ${underlyingObj.props.fnd0InProcess.uiValues[0]}`;

                let imagePath = `${app.getBaseUrlPath()}/image/indicatorWorkflow16.svg`;
                let cellImg = createCellImg(imagePath, tooltip);
                containerElement.appendChild(cellImg);
            }
        })
    }
};

/**
 * Helper function to create the DOM Element to append to the container element
 * 
 * @param {string} imagePath - The path to the indicator svg file
 * @param {string} tooltip - The tooltip to display when mouse over indicator
 * @returns {object} - The DOM Element to append
 */

let createCellImg = (imagePath, tooltip) => {
    // !! ToDo !! - Alternative text when svg is not available
    let cellImg = document.createElement('img');
    cellImg.className = 'aw-visual-indicator';
    cellImg.title = tooltip;
    cellImg.src = imagePath;
    return cellImg;
};

export default exports = {
    renderPropertyIndicators
};

app.factory('miscIndicatorRenderer', () => exports);