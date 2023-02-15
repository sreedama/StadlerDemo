-- locate all mismatching dataset objects
select distinct pobject_name, pobject_type, dst.PDATASETTYPE_NAME 
from 
    pworkspaceobject wso
    INNER JOIN pdataset ds on ds.puid = wso.puid
    INNER JOIN pdatasettype dst on dst.puid = ds.RDATASET_TYPEU
WHERE not wso.pobject_type = dst.PDATASETTYPE_NAME
ORDER BY pobject_type;

-- update all dataset types in WSO based pdatasettype
UPDATE pworkspaceobject t1 
SET POBJECT_TYPE=(
        select distinct dst.PDATASETTYPE_NAME 
        from 
            pworkspaceobject wso
            INNER JOIN pdataset ds on ds.puid = wso.puid
            INNER JOIN pdatasettype dst on dst.puid = ds.RDATASET_TYPEU
        WHERE wso.puid = t1.puid
        )
where t1.puid IN (
    select wso.puid 
    from 
        pworkspaceobject wso
        INNER JOIN pdataset ds on ds.puid = wso.puid
        INNER JOIN pdatasettype dst on dst.puid = ds.RDATASET_TYPEU
    WHERE not wso.pobject_type = dst.PDATASETTYPE_NAME
)

COMMIT;
