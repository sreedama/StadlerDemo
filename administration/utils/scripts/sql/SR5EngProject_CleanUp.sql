/* Engineering Project Cleanup */
USE tc;
/* Delete relation SR5HasCustomer */
DELETE
FROM PPOM_OBJECT
WHERE puid IN (
        SELECT PIMANRELATION.puid
        FROM PIMANRELATION INNER JOIN PIMANTYPE ON PIMANRELATION.rrelation_typeu = PIMANTYPE.puid
            AND PIMANTYPE.ptype_name = 'SR5HasCustomer');

DELETE
FROM PSR5HASCUSTOMER
WHERE puid IN (
        SELECT PIMANRELATION.puid
        FROM PIMANRELATION INNER JOIN PIMANTYPE ON PIMANRELATION.rrelation_typeu = PIMANTYPE.puid
         AND PIMANTYPE.ptype_name = 'SR5HasCustomer');

DELETE
FROM PIMANRELATION
WHERE puid IN (
        SELECT PIMANRELATION.puid
        FROM PIMANRELATION INNER JOIN PIMANTYPE ON PIMANRELATION.rrelation_typeu = PIMANTYPE.puid
            AND PIMANTYPE.ptype_name = 'SR5HasCustomer');

/* Delete relation SR5HasPlant */
DELETE
FROM PPOM_OBJECT
WHERE puid IN (
        SELECT PIMANRELATION.puid
        FROM PIMANRELATION INNER JOIN PIMANTYPE ON PIMANRELATION.rrelation_typeu = PIMANTYPE.puid
            AND PIMANTYPE.ptype_name = 'SR5HasPlant');

DELETE
FROM PSR5HASPLANT
WHERE puid IN (
        SELECT PIMANRELATION.puid
        FROM PIMANRELATION INNER JOIN PIMANTYPE ON PIMANRELATION.rrelation_typeu = PIMANTYPE.puid
         AND PIMANTYPE.ptype_name = 'SR5HasPlant');

DELETE
FROM PIMANRELATION
WHERE puid IN (
        SELECT PIMANRELATION.puid
        FROM PIMANRELATION INNER JOIN PIMANTYPE ON PIMANRELATION.rrelation_typeu = PIMANTYPE.puid
            AND PIMANTYPE.ptype_name = 'SR5HasPlant');

/* Purge sr5CPCustRefNo, sr5ContractNumber, sr5VehicleType on SR5EngProjectRevision */
UPDATE PSR5ENGPROJECTREVISION
SET psr5CustRefNo = NULL, psr5ContractNumber = NULL, psr5VehicleType = NULL;

/* Purge psr5CustDocHead1, psr5CustDocHead2, psr5CustDocHead3 on SR5CustomerRevision */
UPDATE PSR5CUSTOMERREVISION
SET psr5CustDocHead1 = NULL, psr5CustDocHead2 = NULL, psr5CustDocHead3 = NULL;

/* Purge psr5LocationAddress, psr5LocationName on SR5PlantRevision */
UPDATE PSR5PLANTREVISION
SET psr5LocationAddress = NULL, psr5LocationName = NULL;