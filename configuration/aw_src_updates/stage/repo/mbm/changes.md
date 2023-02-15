## Check-in selected scope after disabling focus mode

**OOTB Module:** mbm  
**Affected files:**
- module.json

### Description of change
When entering focus mode in Easy Plan EBOM-MBOM Alignment the selected scope must be checked out in order to assign new childs. After leaving focus mode the selected scope and corresponding BOMView Revisions do not get checked in.  
This modification adds an additional step to the focus toggle command to check-in the current scope including its BOMView Revision.
Additionaly it skips the check-out step if the selected scope has a release status.


#### JSON before

```json
"mbmEvaluateForCheckoutCondition": {
    "expression": "ctx.preferences.MBMCheckoutCheckForFocus[0] === 'true' && (!ctx.mbmFocusModeSelected || ctx.mbmFocusModeSelected === false)"


```
```json
"mbmFocusCommandToggleBatchAction": {
        "actionType": "batchJob",
        "steps": [
          {
            "action": "mbmUpdateFocusCommandToggleAction"
          },
          {
            "action": "mbmFocus",
            "condition": "conditions.isFocusCommandSelect"
          },
          {
            "action": "mbmUnFocus",
            "condition": "conditions.isUnFocusCommandSelect"
          },
          {
            "action": "mbmEvaluateOnDemandCompareToggleInfo",
            "condition": "conditions.isMbmOnDemandComparePreference"
          },
          {
            "action": "mbmSetOnDemandCompareToggleInfo",
            "condition": "conditions.isMbmOnDemandComparePreference"
          },
          {
            "action": "updateStructureSearchConfig"
          },
          {
            "action": "closeFindPanel"
          }
        ]
      }
```

#### JSON after

```json
"mbmEvaluateForCheckoutCondition": {
    "expression": "ctx.preferences.MBMCheckoutCheckForFocus[0] === 'true' && (!ctx.mbmFocusModeSelected || ctx.mbmFocusModeSelected === false) && !(ctx.mbomContext.selectedModelObjects[0].props.awb0ArchetypeRevRelStatus && ctx.mbomContext.selectedModelObjects[0].props.awb0ArchetypeRevRelStatus.dbValues.length > 0)"


```
```json
"mbmFocusCommandToggleBatchAction": {
        "actionType": "batchJob",
        "steps": [
          {
            "action": "mbmUpdateFocusCommandToggleAction"
          },
          {
            "action": "mbmFocus",
            "condition": "conditions.isFocusCommandSelect"
          },
          {
            "action": "mbmUnFocus",
            "condition": "conditions.isUnFocusCommandSelect"
          },
          {
            "action": "checkEditInProgressBeforeCheckin",
            "condition": "conditions.isUnFocusCommandSelect"
          },
          {
            "action": "mbmEvaluateOnDemandCompareToggleInfo",
            "condition": "conditions.isMbmOnDemandComparePreference"
          },
          {
            "action": "mbmSetOnDemandCompareToggleInfo",
            "condition": "conditions.isMbmOnDemandComparePreference"
          },
          {
            "action": "updateStructureSearchConfig"
          },
          {
            "action": "closeFindPanel"
          }
        ]
      }
```

---