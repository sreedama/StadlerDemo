##
#===================================================
# \copyright     2014-2019
#                Siemens Product Lifecycle Management Software Inc.
#                All Rights Reserved.
#===================================================
##

#==================================================
#
##
# Project:       T4S
# @file           sap_call_function_MPE_VERSNBOM_CREATE_VERSION.tcl
##
# jw, 20040530

#
# @brief
# This testscript demonstrates how to call a generic SAP function (BAPI)
#
# Parameters:
# 1) BAPI-Name
# 2) Input as TclStream
# 3) SAP Commit (true/false)
#
# Example:
# 1) BAPI_MATERIAL_GETALL
# 2) set test(JCO:PARAMETER:MATERIAL) \"000000000000002338\"
# 3) false

# Description, comment, flavour.
::TestScript::setScriptDesc "SAP call generic function (MPE_VERSNBOM_CREATE_VERSION)"
::TestScript::setScriptComment "This script demonstrates how to call a generic SAP function (BAPI/ABAP). For a valid input stream, use a TCL array and add all parameters you want to transfer. Normal INPUT parameters are stored in the the default section JCO:PARAMETER followed by the real field name.<br /><br /><strong>Example:</strong><br />set MyArray(JCO:PARAMETER:FIELD1) VALUE1&#59 set MyArray(JCO:PARAMETER:FIELD2) VALUE2..."
::TestScript::setScriptFlavour "T4S"
catch {
  ::TestScript::setScriptCategoryList [list "Miscellaneous"]
}

# Gui.
set functionNameVar [::TestScript::defineScriptParamText "SapCall" "SAP function name" -required]
set functionInputVar [::TestScript::defineScriptParamText "TclStream" "SAP function input (tcl stream)"]
set commitVar [::TestScript::defineScriptParamCombo "Commit" "SAP Commit" [list "false" "true"]]
set caloVar [::TestScript::defineScriptParamCombo "Calo" "SAP Calo Init API" [list "false" "true"]]
set debugVar [::TestScript::defineScriptParamCombo "DebugFlag" "SAP Debug" [list "false" "true"]]
set debugLogVar [::TestScript::defineScriptParamText "DebugLogFile" "Debug log file"]
::TestScript::setScriptGui [list $functionNameVar $functionInputVar $commitVar $caloVar $debugVar $debugLogVar]
::TestScript::checkTestParam $argv

proc printUsage {} {
  puts "usage:"
  puts "  [lindex $::argv 0] -SapCall SapFunctionName -TclStream InputParam -Commit (true/false) -Calo SAP_Calo_Init_API (true/false)"
  exit 0
}

# Parse commandline arguments
foreach {Flag Value} [lrange $::argv 1 end] {
  switch -exact -- $Flag {
    -SapCall      {set SapCall $Value}
    -TclStream    {set TclStream $Value}
    -Commit       {set Commit $Value}
    -Calo         {set Calo $Value}
    -DebugFlag    {set DebugFlag $Value}
    -DebugLogFile {set DebugLogFile $Value}
    -post {;# ignore}
    +language {;# ignore}
    default {
      puts "Invalid flag $Flag"
      printUsage
    }
  }
}

# Test that all needed parameters have been passed in
foreach Parameter {SapCall TclStream Commit Calo DebugFlag DebugLogFile} {
  if {![info exists $Parameter]} {
    puts "Missing $Parameter"
    printUsage
  }
}
#

if { $TclStream == "" } {
  set strArrayName "JCO"
  set strPatternName "JCO"
} else {
  #
  # Compute ArrayName out of given TclStream
  #
  set tmpArray1 [split $TclStream "("]
  set tmpArray2 [split [lindex $tmpArray1 0] " "]
  set strArrayName [lindex $tmpArray2 end]

  set strPatternName [split [lindex $tmpArray1 1] ":"]
  set strPatternName [lindex $strPatternName 0]
	
	puts "tmpArray1 = $tmpArray1"
	puts "tmpArray2 = $tmpArray2"
	puts "strArrayName = $strArrayName"
	puts "strPatternName = $strPatternName"

  if { [catch {eval $TclStream}] != 0 } {
    printUsage
  }
}

if {[::T4X::CONNECTION2EA::testEALogin T4S] == "ERROR" } {
  exit 0
}

# set JCO variables
set strArrayName    ::SAPDat
set strArrayPattern VERSNBOM
set ResultArray     ::RLMoveResultDat

# MPE_VERSNBOM_CREATE_VERSION PARAMETER.
set ::SAPDat(VERSNBOM:PARAMETER:IV_NO_COMMIT) "X" ; # # X = No Commit / " " = Commit

# IS_BOM_HEADER_IN->BOM Header Values for New Version.
set ::SAPDat(VERSNBOM:IS_BOM_HEADER_IN:MATNR) "000000000000008177" ; # Material
set ::SAPDat(VERSNBOM:IS_BOM_HEADER_IN:WERKS) "" ; # Plant
set ::SAPDat(VERSNBOM:IS_BOM_HEADER_IN:STLAN) "E" ; # BOM Usage
set ::SAPDat(VERSNBOM:IS_BOM_HEADER_IN:STLAL) "05" ; # Alternative BOM
set ::SAPDat(VERSNBOM:IS_BOM_HEADER_IN:STLNR) "" ; # Bill of Material
set ::SAPDat(VERSNBOM:IS_BOM_HEADER_IN:BOM_VERSN) "0002" ; # BOM Version

set Index 1

# T_EFFECTIVITY_IN->Effectivity Values for Version BOM.
set ::SAPDat(VERSNBOM:T_EFFECTIVITY_IN:NEW_ITEM_IDENT:$Index) "000001" ; # Unique Identifier for New Item
set ::SAPDat(VERSNBOM:T_EFFECTIVITY_IN:AENNR:$Index) "500000000002" ; # Change Number

# # T_BOM_ITEMS->Items of New BOM Version.
# set ::SAPDat(VERSNBOM:T_BOM_ITEMS:AENNR:$Index) "500000000002" ; # Change Number
# set ::SAPDat(VERSNBOM:T_BOM_ITEMS:NEW_ITEM_IDENT:$Index) "000001" ; # Unique Identifier for New Item

# # T_BOM_ITEMS_IN->BOM Items to Be Updated in New Version.
# set ::SAPDat(VERSNBOM:T_BOM_ITEMS_IN:UPDATE_TYPE:$Index) "U" ; # Type of Update
# set ::SAPDat(VERSNBOM:T_BOM_ITEMS_IN:NEW_ITEM_IDENT:$Index) "000001" ; # Unique Identifier for New Item
# set ::SAPDat(VERSNBOM:T_BOM_ITEMS_IN:IDNRK:$Index) "000000000000008154" ; # BOM component
# set ::SAPDat(VERSNBOM:T_BOM_ITEMS_IN:POSTP:$Index) "L" ; # Item category (bill of material)
# set ::SAPDat(VERSNBOM:T_BOM_ITEMS_IN:POSNR:$Index) "0010" ; # BOM Item Number
# set ::SAPDat(VERSNBOM:T_BOM_ITEMS_IN:MEINS:$Index) "ST" ; # Component Unit of Measure
# set ::SAPDat(VERSNBOM:T_BOM_ITEMS_IN:MENGE:$Index) "1" ; # Component Quantity

# Set inputs.
dict set SAPInDataDict SAPFunction      $SapCall
dict set SAPInDataDict SAPInDataArray   ::SAPDat
dict set SAPInDataDict SAPOutDataArray  ::sap_result_array
dict set SAPInDataDict Pattern          VERSNBOM
dict set SAPInDataDict Commit           false
dict set SAPInDataDict CaloInit         false
dict set SAPInDataDict UseSAPGui        false
dict set SAPInDataDict UseSAPCallback   false
dict set SAPInDataDict VerifyDataKeys   false
dict set SAPInDataDict VerifyDataValues false
dict set SAPInDataDict VerifyErrors     true
dict set SAPInDataDict CloseConnection  true

#
# Call SAP
#
# puts "Call function ::TPSAP::JCO::performGenericSapCall $SapCall $strArrayName $strPatternName $Commit $Calo $DebugFlag $DebugLogFile"
# set rc [::TPSAP::JCO::performGenericSapCall $SapCall $strArrayName $strPatternName $Commit $Calo $DebugFlag $DebugLogFile]
puts "Call function ::TPSAP::performSapCall $SAPInDataDict"
set rc [::TPSAP::performSapCall $SAPInDataDict]
#
puts "::TPSAP::JCO::JCO finished with >$rc<"

#
# Debug
#
foreach elem [array names ::sap_result_array] {
  puts "::sap_result_array($elem) = $::sap_result_array($elem)"
}
#
::T4X::JAVASERVER::tpcontrol ::TPSAP::MISCELLANEOUS::jco3JavaServer "stop"
#
exit 0
