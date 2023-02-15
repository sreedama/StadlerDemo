##
#===================================================
# LMtec swiss  GmbH
# Sonnenstrasse 9a, CH-8572 Berg
##
#==================================================
#
##
# Project:       T4S
# @file          ZPLM_TC_BOMVERS_MAINT.tcl
##
# 20210923

#
# @brief
# This testscript tests custom Stadler function module ZPLM_TC_BOMVERS_MAINT.tcl
#
# Parameters:
# ?debug (true/false)? ?debugfilepath?
#

# Description, comment, flavour.
::TestScript::setScriptDesc "Stadler - ZPLM_TC_BOMVERS_MAINT"
::TestScript::setScriptComment ""
::TestScript::setScriptFlavour "T4S"

#
# Testscript Gui
#
set actionVar             [::TestScript::defineScriptParamCombo "Action" "Action" [list "Read" "Write"] -external [list "Read Version BOM" "Create or Update Version BOM"] -required]
set sMaterialNumber       [::TestScript::defineScriptParamText "MaterialNumber" "Material Number" -required]
set sPlant                [::TestScript::defineScriptParamText "Plant" "Plant" -required]
set sUsage                [::TestScript::defineScriptParamText "Usage" "Usage" -required]
set sAlternative          [::TestScript::defineScriptParamText "Alternative" "sAlternative"]
set sVersion              [::TestScript::defineScriptParamText "Version" "Version" -required]
set sPositionMatNo        [::TestScript::defineScriptParamText "PositionMatNo" "Position Material Number"]
set sPositionType         [::TestScript::defineScriptParamText "PositionType" "Position Type"]
set sPositionQuantity     [::TestScript::defineScriptParamText "PositionQuantity" "Position Quantity"]
set sPositionUOM          [::TestScript::defineScriptParamText "PositionUOM" "Position Unit of Measure"]
set sPositionNumber       [::TestScript::defineScriptParamText "PositionNumber" "Position Number"]
set sPositionPlant        [::TestScript::defineScriptParamText "PositionPlant" "Position Plant"]
set sPositionECM          [::TestScript::defineScriptParamText "PositionECM" "Position ECM"]

set controlVar [::TestScript::defineScriptParamGroup $actionVar [list \
                [list -value "Read" $sMaterialNumber $sPlant $sUsage $sAlternative $sVersion] \
                [list -value "Write" $sMaterialNumber $sPlant $sUsage $sAlternative $sVersion $sPositionMatNo $sPositionType $sPositionQuantity $sPositionUOM $sPositionNumber $sPositionPlant $sPositionECM]]]
::TestScript::setScriptGui [list $controlVar]
::TestScript::checkTestParam $argv


     # set ::SAPDat(VersionBOM:IT_BOM_ITEMS:IDNRK:1) "000000002000000096"
        # set ::SAPDat(VersionBOM:IT_BOM_ITEMS:MEINS:1) "ST"
        # set ::SAPDat(VersionBOM:IT_BOM_ITEMS:MENGE:1) "1"
        # set ::SAPDat(VersionBOM:IT_BOM_ITEMS:SPOSN:1) "0010"
        # set ::SAPDat(VersionBOM:IT_BOM_ITEMS:POSNR:1) "0010"
        # set ::SAPDat(VersionBOM:IT_BOM_ITEMS:POSTP:1) "L"
        # set ::SAPDat(VersionBOM:IT_BOM_ITEMS:PSWRK:1) "DE10"
        # set ::SAPDat(VersionBOM:IT_BOM_ITEMS:AENNR:1) "500000000000"



#
# Get Script Input
#
  foreach {Parameter Value} [lrange $::argv 1 end] {
    switch -exact -- $Parameter {
      -Action           {set Action $Value}
      -MaterialNumber   {set MaterialNumber [string trim $Value]}
      -Plant            {set Plant $Value}
      -Usage            {set Usage $Value}
      -Alternative      {set Alternative $Value}
      -Version          {set Version $Value}
      -PositionMatNo    {set PositionMatNo $Value}
      -PositionType     {set PositionType $Value}
      -PositionQuantity {set PositionQuantity $Value}
      -PositionUOM      {set PositionUOM $Value}
      -PositionNumber   {set PositionNumber $Value}
      -PositionPlant    {set PositionPlant $Value}
      -PositionECM      {set PositionECM $Value}
    }
  }


# set dirnrVar        [::TestScript::defineScriptParamText "DirNr" "Document Nr"]
# set dirpartVar      [::TestScript::defineScriptParamText "DirPart" "Document Part"]
# set dirverVar       [::TestScript::defineScriptParamText "DirVer" "Document Version"]
# set netVar          [::TestScript::defineScriptParamText "NetworkId" "Network Id"]
# set activityVar     [::TestScript::defineScriptParamText "ActivityNr" "Activity Nr"]



#
# Check and Establish Connection to SAP
#
if {[::T4S::CONNECTION2SAP::testSAPLogin] == "ERROR" } {
  puts "No connection to SAP"
  exit 0
}


  # ---------------------------------------------------------------------
  ##
  # Method:         init_ZPLM_TC_BOMVERS_MAINT_PARAMETER
  # \tpinternal
  # \brief
  # \author         fs, 20210923
  # \return
  #
  #
  #
  proc init_ZPLM_TC_BOMVERS_MAINT_PARAMETER {args} {

    # ZPLM_TC_BOMVERS_MAINT PARAMETER.
    set ::SAPDat(VersionBOM:PARAMETER:IT_BOM_DIR) ""                ; # Document info record table of version BOM
    set ::SAPDat(VersionBOM:PARAMETER:IT_BOM_DMU_ITM) ""            ; # Transformation matrix table for each BOM item instance
    set ::SAPDat(VersionBOM:PARAMETER:IT_BOM_DMU_META) ""           ; # Metadata table for each BOM item instance
    set ::SAPDat(VersionBOM:PARAMETER:IT_BOM_EFFECTIVITY) ""        ; # Effectivity table for version BOM
    set ::SAPDat(VersionBOM:PARAMETER:IT_BOM_ITEMS) ""              ; # Version BOM item table for creation
    set ::SAPDat(VersionBOM:PARAMETER:IV_READ_ONLY) "ABAP_FALSE"    ; # Flag (X or Blank)
    set ::SAPDat(VersionBOM:PARAMETER:IV_TEST_ONLY) "ABAP_FALSE"    ; # X = Test only - no DB Update
  }

  # ---------------------------------------------------------------------
  ##
  # Method:         init_ZPLM_TC_BOMVERS_MAINT_IS_BOM_HEADER
  # \tpinternal
  # \brief 
  # \author         fs, 20210923
  # \return 
  #
  #
  #
  proc init_ZPLM_TC_BOMVERS_MAINT_IS_BOM_HEADER {args} {

    # IS_BOM_HEADER->Header fields for creating/ updating version BOM.
    set ::SAPDat(VersionBOM:IS_BOM_HEADER:MATNR) ""         ; # Material
    set ::SAPDat(VersionBOM:IS_BOM_HEADER:WERKS) ""         ; # Plant
    set ::SAPDat(VersionBOM:IS_BOM_HEADER:STLAN) ""         ; # BOM Usage
    set ::SAPDat(VersionBOM:IS_BOM_HEADER:STLAL) ""         ; # Alternative BOM
    set ::SAPDat(VersionBOM:IS_BOM_HEADER:STLNR) ""         ; # Bill of Material
    set ::SAPDat(VersionBOM:IS_BOM_HEADER:BOM_VERSN) ""     ; # BOM Version
    set ::SAPDat(VersionBOM:IS_BOM_HEADER:BMEIN) ""         ; # Base Unit of Measure
    set ::SAPDat(VersionBOM:IS_BOM_HEADER:BMENG) ""         ; # Base quantity
    set ::SAPDat(VersionBOM:IS_BOM_HEADER:CADKZ) ""         ; # CAD Indicator
    set ::SAPDat(VersionBOM:IS_BOM_HEADER:LABOR) ""         ; # Lab/Office
    set ::SAPDat(VersionBOM:IS_BOM_HEADER:LTXSP) ""         ; # Long Text Language
    set ::SAPDat(VersionBOM:IS_BOM_HEADER:STKTX) ""         ; # Alternative Text
    set ::SAPDat(VersionBOM:IS_BOM_HEADER:STLST) ""         ; # BOM Status
    set ::SAPDat(VersionBOM:IS_BOM_HEADER:ALEKZ) ""         ; # ALE indicator
    set ::SAPDat(VersionBOM:IS_BOM_HEADER:BOM_AIN_IND) ""   ; # Relevant for BOM to AIN Handover
    set ::SAPDat(VersionBOM:IS_BOM_HEADER:LTXKO) ""         ; # Alternative long txt
    set ::SAPDat(VersionBOM:IS_BOM_HEADER:EXSTL) ""         ; # BOM group
    set ::SAPDat(VersionBOM:IS_BOM_HEADER:STLBE) ""         ; # Authorization group
    set ::SAPDat(VersionBOM:IS_BOM_HEADER:ZTEXT) ""         ; # BOM Description
    set ::SAPDat(VersionBOM:IS_BOM_HEADER:KBAUS) ""         ; # Configurable BOM
    set ::SAPDat(VersionBOM:IS_BOM_HEADER:LTXZU) ""         ; # BOM long text
    set ::SAPDat(VersionBOM:IS_BOM_HEADER:TETYP) ""         ; # Technical type
    set ::SAPDat(VersionBOM:IS_BOM_HEADER:LOSVN) ""         ; # From Lot Size
    set ::SAPDat(VersionBOM:IS_BOM_HEADER:LOSBS) ""         ; # To Lot Size
    set ::SAPDat(VersionBOM:IS_BOM_HEADER:CSLTY) ""         ; # Configured material
  }

  ############################################################
  ##
  # Method:         callZPLM_TC_BOMVERS_MAINT
  # \tpinternal
  # \brief          Calls SAP function 'ZPLM_TC_BOMVERS_MAINT'.
  #
  # @todo1: Please add the needed additional status handling to the generated code
  # @todo1: and add additional entries to the 'SAPOutDataDict' dict!
  #
  # \author         fs, 20210923
  #
  # \return         dict structure with the following elements:
  #                  - Status OK|ERROR|JCO_ERROR
  #                  - JCoStatus OK|ERROR
  #                  - ErrorMessage last error message
  #                  - NoOfMessages number of messages
  #                  - LogMessageMessage(1 .. n)
  #                  - LogMessageSeverity(1 .. n)
  #                  @todo2: add additional entries to the 'SAPOutDataDict', if needed
  #
  proc callZPLM_TC_BOMVERS_MAINT {args} {

    # Set inputs.
    # dict set SAPInDataDict SAPFunction      ZPLM_TC_BOMVERS_MAINT              
    dict set SAPInDataDict SAPFunction      "/SRAIL/PLM_TC_BOMVERS_MAINT"        ;# new name according to SR SAP naming convention
    dict set SAPInDataDict SAPInDataArray   ::SAPDat
    dict set SAPInDataDict SAPOutDataArray  ::sap_result_array
    dict set SAPInDataDict Pattern          VersionBOM
    dict set SAPInDataDict Commit           false
    dict set SAPInDataDict CaloInit         false
    dict set SAPInDataDict UseSAPGui        false
    dict set SAPInDataDict UseSAPCallback   false
    dict set SAPInDataDict VerifyDataKeys   false
    dict set SAPInDataDict VerifyDataValues false
    dict set SAPInDataDict VerifyErrors     true
    dict set SAPInDataDict CloseConnection  false

    # Call.
    set SAPOutDataDict [::TPSAP::performSapCall $SAPInDataDict]

    # Get outputs.
    if { [dict get $SAPOutDataDict Status] eq "OK" } {

      ###################
      # todo3: based on the following export parameters or table result information you could define your requested resulting status
      ###################
      #
      #
      # ES_BOM_HEADER->Header fields for creating/ updating version BOM.
      # ::sap_result_array(ES_BOM_HEADER:MANDT)                  ; # Client
      # ::sap_result_array(ES_BOM_HEADER:STLTY)                  ; # BOM category
      # ::sap_result_array(ES_BOM_HEADER:STLNR)                  ; # Bill of Material
      # ::sap_result_array(ES_BOM_HEADER:STLAL)                  ; # Alternative BOM
      # ::sap_result_array(ES_BOM_HEADER:STKOZ)                  ; # Counter
      # ::sap_result_array(ES_BOM_HEADER:DATUV)                  ; # Valid From
      # ::sap_result_array(ES_BOM_HEADER:TECHV)                  ; # Tech status from
      # ::sap_result_array(ES_BOM_HEADER:AENNR)                  ; # Change Number
      # ::sap_result_array(ES_BOM_HEADER:LKENZ)                  ; # Deletion Indicator
      # ::sap_result_array(ES_BOM_HEADER:LOEKZ)                  ; # Deletion Flag
      # ::sap_result_array(ES_BOM_HEADER:VGKZL)                  ; # Prev header counter
      # ::sap_result_array(ES_BOM_HEADER:ANDAT)                  ; # Created On
      # ::sap_result_array(ES_BOM_HEADER:ANNAM)                  ; # Created by
      # ::sap_result_array(ES_BOM_HEADER:AEDAT)                  ; # Changed On
      # ::sap_result_array(ES_BOM_HEADER:AENAM)                  ; # Changed by
      # ::sap_result_array(ES_BOM_HEADER:BMEIN)                  ; # Base Unit of Measure
      # ::sap_result_array(ES_BOM_HEADER:BMENG)                  ; # Base quantity
      # ::sap_result_array(ES_BOM_HEADER:CADKZ)                  ; # CAD Indicator
      # ::sap_result_array(ES_BOM_HEADER:LABOR)                  ; # Lab/Office
      # ::sap_result_array(ES_BOM_HEADER:LTXSP)                  ; # Long Text Language
      # ::sap_result_array(ES_BOM_HEADER:STKTX)                  ; # Alternative Text
      # ::sap_result_array(ES_BOM_HEADER:STLST)                  ; # BOM Status
      # ::sap_result_array(ES_BOM_HEADER:WRKAN)                  ; # Created in plant
      # ::sap_result_array(ES_BOM_HEADER:DVDAT)                  ; # Scheduled on
      # ::sap_result_array(ES_BOM_HEADER:DVNAM)                  ; # Date shifted by
      # ::sap_result_array(ES_BOM_HEADER:AEHLP)                  ; # Helper Field
      # ::sap_result_array(ES_BOM_HEADER:ALEKZ)                  ; # ALE indicator
      # ::sap_result_array(ES_BOM_HEADER:GUIDX)                  ; # ID hdr chge status
      # ::sap_result_array(ES_BOM_HEADER:VALID_TO)               ; # Valid to
      # ::sap_result_array(ES_BOM_HEADER:ECN_TO)                 ; # Change Number To
      # ::sap_result_array(ES_BOM_HEADER:BOM_VERSN)              ; # BOM Version
      # ::sap_result_array(ES_BOM_HEADER:VERSNST)                ; # BOM Version Status
      # ::sap_result_array(ES_BOM_HEADER:VERSNLASTIND)           ; # Indicator: Latest Released BOM Version
      # ::sap_result_array(ES_BOM_HEADER:LASTCHANGEDATETIME)     ; # Time Stamp
      # ::sap_result_array(ES_BOM_HEADER:BOM_AIN_IND)            ; # Relevant for BOM to AIN Handover
      # ::sap_result_array(ES_BOM_HEADER:BOM_PREV_VERSN)         ; # Predecessor Version
      # ::sap_result_array(ES_BOM_HEADER:DUMMY_STKO_INCL_EEW_PS) ; # Ext. Include
      # ::sap_result_array(ES_BOM_HEADER:AENRA)                  ; # To change number
      # ::sap_result_array(ES_BOM_HEADER:DATUB)                  ; # Valid to
      # ::sap_result_array(ES_BOM_HEADER:LTXKO)                  ; # Alternative long txt
      # ::sap_result_array(ES_BOM_HEADER:EXSTL)                  ; # BOM group
      # ::sap_result_array(ES_BOM_HEADER:STLBE)                  ; # Authorization group
      # ::sap_result_array(ES_BOM_HEADER:ZTEXT)                  ; # BOM Description
      # ::sap_result_array(ES_BOM_HEADER:STLAN)                  ; # BOM Usage
      # ::sap_result_array(ES_BOM_HEADER:KBAUS)                  ; # Configurable BOM
      # ::sap_result_array(ES_BOM_HEADER:VERSNIND)               ; # Indicator: Versioning Allowed
      # ::sap_result_array(ES_BOM_HEADER:LTXZU)                  ; # BOM long text
      # ::sap_result_array(ES_BOM_HEADER:TETYP)                  ; # Technical type
      # ::sap_result_array(ES_BOM_HEADER:FLG_LOCK)               ; # BOM is locked
      # ::sap_result_array(ES_BOM_HEADER:HANDLE)                 ; # Int.ID
      # ::sap_result_array(ES_BOM_HEADER:MATNR)                  ; # Material
      # ::sap_result_array(ES_BOM_HEADER:WERKS)                  ; # Plant
      # ::sap_result_array(ES_BOM_HEADER:LOSVN)                  ; # From Lot Size
      # ::sap_result_array(ES_BOM_HEADER:LOSBS)                  ; # To Lot Size
      # ::sap_result_array(ES_BOM_HEADER:CSLTY)                  ; # Configured material
      # ::sap_result_array(ES_BOM_HEADER:UPDATE_TYPE)            ; # Type of Update
      # ::sap_result_array(ET_BOM_DIR)                           ; # Document info record table of version BOM
      # ::sap_result_array(ET_BOM_DMU_ITM)                       ; # Transformation matrix table for each BOM item instance
      # ::sap_result_array(ET_BOM_DMU_META)                      ; # Metadata table for each BOM item instance
      # ::sap_result_array(ET_BOM_EFFECTIVITY)                   ; # Effectivity table for version BOM
      # ::sap_result_array(ET_BOM_ITEMS)                         ; # Version BOM item table for creation
      # ::sap_result_array(ET_MESSAGES)                          ; # Message table for version BOM wrapper APIs
      # ::sap_result_array(EV_CHANGE_MODE)                       ; # determined change-mode for BOM
      # ::sap_result_array(EV_SUCCESS)                           ; # X = success blank = error
      #
      ###################
      # end of todo3
      ###################
    }

    return $SAPOutDataDict
  }



        # TODO temp set input parameter 

        set ::SAPDat(VersionBOM:IS_BOM_HEADER:MATNR) [::TPSAP::MM::getInternalMaterialNumber $MaterialNumber]        ; # Material  e.g. VCA_EITM001
        set ::SAPDat(VersionBOM:IS_BOM_HEADER:WERKS) $Plant                  ; # Plant e.g. DE10
        set ::SAPDat(VersionBOM:IS_BOM_HEADER:STLAN) $Usage                  ; # BOM Usage e.g. V
        set ::SAPDat(VersionBOM:IS_BOM_HEADER:STLAL) $Alternative            ; # Alternative BOM e.g. 01
        # set ::SAPDat(VersionBOM:IS_BOM_HEADER:STLNR) ""                       ; # Bill of Material
        set ::SAPDat(VersionBOM:IS_BOM_HEADER:BOM_VERSN) $Version            ; # BOM Version e.g. 0001


    if {$Action eq "Read"} {
        set ::SAPDat(VersionBOM:PARAMETER:IV_READ_ONLY) "X"
    } else {
        # set ::SAPDat(VersionBOM:IS_BOM_HEADER:MATNR) "000000002000000004"         ; # Material  e.g. VCA_EITM001
    
    
        set ::SAPDat(VersionBOM:IT_BOM_ITEMS:IDNRK:1) [::TPSAP::MM::getInternalMaterialNumber $PositionMatNo]
        set ::SAPDat(VersionBOM:IT_BOM_ITEMS:MEINS:1) $PositionUOM
        set ::SAPDat(VersionBOM:IT_BOM_ITEMS:MENGE:1) $PositionQuantity
        set ::SAPDat(VersionBOM:IT_BOM_ITEMS:SPOSN:1) $PositionNumber
        set ::SAPDat(VersionBOM:IT_BOM_ITEMS:POSNR:1) $PositionNumber
        set ::SAPDat(VersionBOM:IT_BOM_ITEMS:POSTP:1) $PositionType
        set ::SAPDat(VersionBOM:IT_BOM_ITEMS:PSWRK:1) $PositionPlant
        set ::SAPDat(VersionBOM:IT_BOM_ITEMS:AENNR:1) $PositionECM
        # set ::SAPDat(VersionBOM:IT_BOM_ITEMS:IDNRK:1) "000000002000000096"
        # set ::SAPDat(VersionBOM:IT_BOM_ITEMS:MEINS:1) "ST"
        # set ::SAPDat(VersionBOM:IT_BOM_ITEMS:MENGE:1) "1"
        # set ::SAPDat(VersionBOM:IT_BOM_ITEMS:SPOSN:1) "0010"
        # set ::SAPDat(VersionBOM:IT_BOM_ITEMS:POSNR:1) "0010"
        # set ::SAPDat(VersionBOM:IT_BOM_ITEMS:POSTP:1) "L"
        # set ::SAPDat(VersionBOM:IT_BOM_ITEMS:PSWRK:1) "DE10"
        # set ::SAPDat(VersionBOM:IT_BOM_ITEMS:AENNR:1) "500000000000"
        # set ::SAPDat(VersionBOM:IT_BOM_ITEMS:UPDATE_TYPE:1) "I"
    
    }


    # Call function module
    puts "Input for function module call:"
    foreach Element [array names ::SAPDat] {
        puts "-- ::SAPDat($Element) - $::SAPDat($Element)"
    }
    
    
    set lRc [callZPLM_TC_BOMVERS_MAINT]
    puts "callZPLM_TC_BOMVERS_MAINT returns >$lRc<"
    
    puts "++++++++++++++++++++++++++++++++++++++++++++++++++++"
    puts " ++++++ ::sap_result_array  ++++++++++++++++++++++++"
    puts "++++++++++++++++++++++++++++++++++++++++++++++++++++"


    puts "+"
    puts "+"
    puts "+ Header Information"
    foreach sElement [lsort -dictionary [array names ::sap_result_array ES_BOM_HEADER:*]] {
        puts "  ::sap_result_array($sElement)  $::sap_result_array($sElement)"
    }


    puts "+"
    puts "+"
    puts "+ Position Information"
    foreach sElement [::TPSAP::sortIndexedInterfaceTable [array names ::sap_result_array ET_BOM_ITEMS:*]] {
        puts "  ::sap_result_array($sElement)  $::sap_result_array($sElement)"
    }    
    
    
    puts "+"
    puts "+"
    puts "+ BAPI Return"
    foreach sElement [lsort -dictionary [array names ::sap_result_array ET_MESSAGES:*]] {
        puts "  ::sap_result_array($sElement)  $::sap_result_array($sElement)"
    }    
    

exit 0

