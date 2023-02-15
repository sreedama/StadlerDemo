## Disable Excel Import

**OOTB Module:** occmgmt  
**Affected files:**

- module.json

### Description of change

Users not belonging to the dba, TC Admin or Project Management group should not be allowed to
use the "import Structure" command aka Excel Loader. An additional condition "isValidGroupForExcelImport" is added to the visibility condition of the command to only show the command for these three groups

#### JSON before

```json
"checkModelType": {
    "expression": "(ctx.selected.modelType.typeHierarchyArray.indexOf( 'Folder' ) > -1 || ctx.selected.modelType.typeHierarchyArray.indexOf( 'Awb0Element' ) > -1)"
},
"enableImportBOMCommand": {
    "expression": "conditions.isImportCmdVisible && conditions.checkModelType"
},
```

#### JSON after

```json
"checkModelType": {
    "expression": "(ctx.selected.modelType.typeHierarchyArray.indexOf( 'Folder' ) > -1 || ctx.selected.modelType.typeHierarchyArray.indexOf( 'Awb0Element' ) > -1)"
},
"isValidGroupForExcelImport": {
    "expression": "ctx.userSession.props.group_name.dbValues[0] === 'dba' || ctx.userSession.props.group_name.dbValues[0] === 'Project Management' || ctx.userSession.props.group_name.dbValues[0] === 'TC Admin'"
},
"enableImportBOMCommand": {
    "expression": "conditions.isImportCmdVisible && conditions.checkModelType && conditions.isValidGroupForExcelImport"
},

```

---

## Set default value for run in background to false

**OOTB Module:** occmgmt  
**Affected files:**

- Awb0ImportFromExcelSubViewModel.json

### Description of change

OOTB the default value for "Run in Background" in the Excel Import panel is set to true.
This customization changes the default value to false.

#### JSON before

```json
"data": {
    "runInBackgroundExcel": {
        "displayName": "{{i18n.runinBG}}",
        "type": "BOOLEAN",
        "isRequired": "true",
        "dbValue": true,
        "labelPosition": "PROPERTY_LABEL_AT_RIGHT"
    }
}

```

#### JSON after

```json
"data": {
    "runInBackgroundExcel": {
        "displayName": "{{i18n.runinBG}}",
        "type": "BOOLEAN",
        "isRequired": "true",
        "dbValue": false,
        "labelPosition": "PROPERTY_LABEL_AT_RIGHT"
    }
}

```

---

## Disable date effecticity

**OOTB Module:** occmgmt  
**Affected files:**

- AuthorEffectivityViewModel.json
- Awb0AceEffectivityView.html

### Description of change

OOTB the user can choose to set unit or date effectivity.
The option to set a date effectivity is removed.

#### AuthorEffectivityViewModel.json before

```json
"data": {
    "dateOrUnitEffectivityTypeRadioButton":
        {
            "type": "BOOLEAN",
            "isRequired": "true",
            "propertyRadioTrueText": "{{i18n.dateEffectivity}}",
            "propertyRadioFalseText":"{{i18n.unitEffectivity}}",
            "dbValue": true,
            "labelPosition": "PROPERTY_LABEL_AT_RIGHT"
        },
}

```

#### AuthorEffectivityViewModel.json after

```json
"data": {
    "dateOrUnitEffectivityTypeRadioButton":
        {
            "type": "BOOLEAN",
            "isRequired": "true",
            "propertyRadioTrueText": "{{i18n.dateEffectivity}}",
            "propertyRadioFalseText":"{{i18n.unitEffectivity}}",
            "dbValue": false,
            "labelPosition": "PROPERTY_LABEL_AT_RIGHT"
        },
}

```

#### Awb0AceEffectivityView.html before

```html
<aw-flex-column width="12">
    <aw-flex-row>
        <aw-flex-column width="12">
            </br>
            <aw-radiobutton prop="data.dateOrUnitEffectivityTypeRadioButton"></aw-radiobutton>
            <aw-checkbox prop="data.isShared"></aw-checkbox>
            <aw-textbox prop="data.nameBox" exist-when="data.isShared.dbValue"></aw-textbox>
        </aw-flex-column>
    </aw-flex-row>
    <aw-flex-row>

    ...

    <aw-flex-column width="12">
        <aw-checkbox prop="data.isProtected"></aw-checkbox>
        <div exist-when="(conditions.isNewTabSelected || conditions.isSearchTabSelected) && conditions.isValidEffectivityPanel">

```

#### Awb0AceEffectivityView.html after

```html
<aw-flex-column width="12">
  <aw-flex-row>
    <!-- <aw-flex-column width="12">
            </br>
            <aw-radiobutton prop="data.dateOrUnitEffectivityTypeRadioButton"></aw-radiobutton>
            <aw-checkbox prop="data.isShared"></aw-checkbox>
            <aw-textbox prop="data.nameBox" exist-when="data.isShared.dbValue"></aw-textbox>
        </aw-flex-column> -->
  </aw-flex-row>s
  <aw-flex-row>
    ...

    <aw-flex-column width="12">
      <!-- <aw-checkbox prop="data.isProtected"></aw-checkbox> -->
      <div
        exist-when="(conditions.isNewTabSelected || conditions.isSearchTabSelected) && conditions.isValidEffectivityPanel"
      ></div></aw-flex-column></aw-flex-row
></aw-flex-column>
```

---
