import app from "app";
import soaSvc from "soa/kernel/soaService";

let exports = {};

/**
 * This function calls a custom SOA to perform a recursive weight roll-up
 * for the selected object.
 * @param {Object} ctx - the current application context
 * @returns {Object} - The calculated weight for the given UID
 */
export const setCalculatedWeight = async (ctx) => {
    const selectedUid =
        ctx.selected.modelType.typeHierarchyArray.indexOf("Awb0Element") > -1
            ? ctx.selected.props.awb0UnderlyingObject.dbValues[0]
            : ctx.selected.uid;
    const soaInput = {
        uid: selectedUid,
    };
    try {
        const response = await soaSvc.postUnchecked(
            "Custom-2021-12-WeightManagement",
            "calculateAndSetWeight",
            soaInput
        );
        const errorCode = response.errorResponse.errorCode.toString();
        if (errorCode !== "0") {
            return {
                calculatedWeight: "-",
                weightErrorCode: errorCode,
                weightErrorText: response.errorResponse.errorText,
            };
        }
        const calculatedWeight = response.dataResponse.weight.toFixed(2);
        return {
            calculatedWeight: calculatedWeight,
            weightErrorCode: errorCode,
            weightErrorText: "-",
        };
    } catch (err) {
        return {
            calculatedWeight: "-",
            weightErrorCode: "N/A",
            weightErrorText: err.message,
        };
    }
};

export default exports = {
    setCalculatedWeight,
};

app.factory("sr5WeightManagementService", () => exports);
