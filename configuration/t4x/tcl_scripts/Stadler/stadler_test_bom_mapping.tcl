#===================================================
# \copyright     2014-2019
#                Siemens Product Lifecycle Management Software Inc.
#                All Rights Reserved.
#===================================================
#
##
# Project:       T4S
# @file           stadler_test_bom_mapping.tcl
##
# This testscript is used to test the mapping function for the bill of material
# based on a specified Tc object.
#
# Parameters:
# 1) ObjType BillOfMaterial|OrderBillOfMaterial|EquiBillOfMaterial
# 1) Item Id
# 2) Item Rev Id
# 3) BomViewName (Optional, default "view"
#
##
# @bug 20051013-JS: changed to new ITK-Server Funcions
# @bug 20060913-JS: Bugfix for call 0006642: additional error messages included
# @bug 20061206-JS: Current SAP connection is new fetched from the Server
# @bug 20070110-JS: Handling for language depended BomViewTypeName included
# @bug 20071107-JS: Modified to support the new web based test environment
# @bug 20081223-JS: Add new config error message
# @bug 20090129-JS: Support of differnt SAP-Bom types included
##

# Description, comment, flavour.
::TestScript::setScriptDesc "BOM Mapping Test (STADLER)"
::TestScript::setScriptComment "<h1>T4S BOM Mapping Test</h1><p>This script tests the BOM mapping of objects from Teamcenter.</p><h2>Parameters</h2><h3>SAP Target Object Type</h3><ul><li>Specifies the SAP target object type of the processed mapping function. The following types are supported:</li><ul><li>Bill Of Material</li><li>Bill Of Material based on Relation Structure</li><li>Document Structure</li><li>Equipment Bill Of Material</li><li>Functional Location Bill Of Material</li><li>Work Breakdown Structure Bill Of Material</li><li>Order Bill Of Material</li><li>Generic Bill Of Material</li></ul></ul><h3>Item ID - ItemRevision ID</h3><ul><li>Specify the item ID and the item revision ID of the item.</li></ul><h3>BOM View Name</h3><ul><li>Specify the BOM view type name.</li></ul><h3>BOM View Name</h3><ul><li>Specify the BOM view type name.</li></ul><h3>BOM Window Switches</h3><ul><li>Here it is possible to define the same arguments as they are used in the action handler to control the BOM window behaviour during the data extraction before the mapping is processed.</li></ul><h3>Custom BOM Target Type and Custom BOMLine Target Type</h3><ul><li>If the <b>Generic Bill Of Material</b> mapping test is selected, there is a need to define these arguments in addition to specify the used preference sets for the data extraction.</li></ul>"
::TestScript::setScriptFlavour "T4S"
catch {
  ::TestScript::setScriptCategoryList [list "Mapping" "Bill of Material"]
}

# Gui.
set objectTypeVar [::TestScript::defineScriptParamCombo "ObjType" "SAP Target Object Type" \
                    [list "BillOfMaterial" \
                          "OrderBillOfMaterial" \
                          "EquiBillOfMaterial" \
                          "DocumentStructure" \
                          "FunctionalLocationBillOfMaterial" \
                          "WBS_BillOfMaterial" \
                          "BillOfMaterial4Relation" \
                          "GenericBillOfMaterial"] \
                    -external \
                    [list "Bill Of Material" \
                          "Order Bill Of Material" \
                          "Equipment Bill Of Material" \
                          "Document Structure" \
                          "Functional Location Bill of Material" \
                          "Work Breakdown Structure Bill Of Material" \
                          "Bill Of Material based on Relation Structure" \
                          "Generic Bill Of Material"]]
set bomTypeVar [::TestScript::defineScriptParamEditCombo "BOMType" "Stadler BOM Type" [list "SR5Eng*" "SR5Mfg*" "SR5LL*"] -external [list "Engineering BOM" "Manufacturing BOM" "Long Lead BOM"] -required]
set itemVar [::TestScript::defineScriptParamText "IT" "Tc Item Id" -required]
set itemRevisionVar [::TestScript::defineScriptParamText "IR" "Tc ItemRevision Id" -required]
set bomViewNameVar [::TestScript::defineScriptParamEditCombo "BV" "Bom View Name" [list "view"] -required]
set bomWindowSwitchesVar [::TestScript::defineScriptParamText "SW" "BOM Window Switches"]
set bomTargetTypeVar [::TestScript::defineScriptParamText "CBTT" "Custom BOM Target Type" -required]
set bomLineTargetTypeVar [::TestScript::defineScriptParamText "CLTT" "Custom BOMLine Target Type" -required]
set groupVar [::TestScript::defineScriptParamGroup $objectTypeVar [list \
                [list -value "BillOfMaterial" $itemVar $itemRevisionVar $bomViewNameVar $bomWindowSwitchesVar] \
                [list -value "BillOfMaterial4Relation" $itemVar $itemRevisionVar] \
                [list -value "OrderBillOfMaterial" $itemVar $itemRevisionVar $bomViewNameVar $bomWindowSwitchesVar] \
                [list -value "EquiBillOfMaterial" $itemVar $itemRevisionVar $bomViewNameVar $bomWindowSwitchesVar] \
                [list -value "DocumentStructure" $itemVar $itemRevisionVar $bomViewNameVar $bomWindowSwitchesVar] \
                [list -value "FunctionalLocationBillOfMaterial" $itemVar $itemRevisionVar $bomViewNameVar $bomWindowSwitchesVar] \
                [list -value "WBS_BillOfMaterial" $itemVar $itemRevisionVar $bomViewNameVar $bomWindowSwitchesVar] \
                [list -value "GenericBillOfMaterial" $bomTargetTypeVar $bomTypeVar $bomLineTargetTypeVar $itemVar $itemRevisionVar $bomViewNameVar $bomWindowSwitchesVar]]]
::TestScript::setScriptGui [list $groupVar]
::TestScript::checkTestParam $argv

set TcBomType               "Manufacturing BOM"
set ObjectId                ""
set ObjectRevisionId        ""
set BomViewName             "view"
set BomWindowSwitches       ""
set CustomBOMTargetType     ""
set CustomBOMLineTargetType ""
set ObjectTag               ""
#
if {[llength $argv] > 1} {
  foreach {Parameter Value} [lrange $::argv 1 end] {
    switch -exact -- $Parameter {
      -ObjType {set SapObjectType $Value}
			-BOMType {set TcBomType $Value}
      -IT   {set ObjectId $Value}
      -IR   {set ObjectRevisionId $Value}
      -BV   {set BomViewName $Value}
      -CBTT {set CustomBOMTargetType $Value}
      -CLTT {set CustomBOMLineTargetType $Value}
      -SW   {set BomWindowSwitches $Value}
      +language {;# ignore}
    }
  }
} else {
  puts "wrong usage: [lindex $argv 0] -ObjType BillOfMaterial|OrderBillOfMaterial|EquiBillOfMaterial -IT ItemId -IR ItemRevisionId ?-BV BomViewName? ?-SW BomWindowSwitches?"
  exit 0
}

#
# Get current SAP connection
#
::T4X::CONNECTION2EA::testEALogin T4S
#
set Connection [::ITK::connect2TcDB]
if {$Connection == 0} {
  puts "XXXX"
  puts "XXXX  Database available!"
  puts "XXXX"

  set ItkStatus [::ITK::ITEM_find_item_revs_by_key_attributes $ObjectRevisionId "item_id" $ObjectId]
  puts "ITEM_find_item_revs_by_key_attributes - $ItkStatus"
  if {[lindex $ItkStatus 0] == 0} {
		if {[lindex $ItkStatus 1] == "1"} {
			set ObjectTag [lindex [lindex $ItkStatus 2] 0]
		} else {
			set FoundObjectList [lindex $ItkStatus 2]
			foreach CurrentObjectTag $FoundObjectList {
				set ItemRevTypeStatus [::ITK::getObjectPropertyByName $CurrentObjectTag "object_type"]
				if {[::ITK::isITK_ok $ItemRevTypeStatus]} {
					set ItemRevType [::ITK::getObjectValue $ItemRevTypeStatus]
				} else {
					set ErrorNumber   [::ITK::getITKStatusNumber $ItemRevTypeStatus]
					set ErrorMessage	[::ITK::getErrorMessage4Status $ItemRevTypeStatus]
					puts "ErrorNumber: $ErrorNumber --> ErrorMessage: ErrorMessage"
				}
				if {[string match $TcBomType $ItemRevType] eq "1"} {
					set ObjectTag $CurrentObjectTag
				}
			}
		}
  }
  #
  # check if the corresponding item revision is available
  #
  if {[string length $ObjectTag] > 0} {
    if {$SapObjectType eq "BillOfMaterial4Relation"} {
      set ObjectDataStatus [::ITK::getObjectData $ObjectTag "T4S" "BOM" "BOM4Relation" "MaterialMaster"]
      puts "----- [::ITK::isITK_ok $ObjectDataStatus] -----"
      if {[::ITK::isITK_ok $ObjectDataStatus]} {
        ::T4X::TC::MAPPING::printIndexTcData TEST_MAPPING
        set Status [::T4S::BOM::MAPPING::TC_Object2SAP_BillOfMaterial TEST_MAPPING]
      }
    } else {
      set BomViewStatus [::ITK::ITEM_rev_list_bom_view_revs $ObjectTag]
      puts "BomViewStatus: $BomViewStatus - is OK: [::ITK::isITK_ok $BomViewStatus]"
      if {[::ITK::isITK_ok $BomViewStatus]} {
        set BomViewTagList [::ITK::getObjectTag $BomViewStatus]
      } else {
        set BomViewTagList [::ITK::getObjectTag [lindex $BomViewStatus 1]]
      }
      #
      # check for the relevant sub object (BOM View type) used for the mapping
      #
      if {[string length $BomViewTagList] > 0} {
        foreach BomViewTag $BomViewTagList {
            set ObjectStatus [::ITK::getObjectMetaData $BomViewTag]
            #puts "ObjectStatus $ObjectStatus"
            #puts "ObjectStatus [tpco_formatHEX16 [lindex [lindex $ObjectStatus 1] 0]]"
            #puts "ObjectStatus [tpco_formatHEX16 [lindex [lindex $ObjectStatus 1] 1]]"
            if {[::ITK::isITK_ok $ObjectStatus]} {
              set TcBomViewTypeName [tpco_formatHEX16 [lindex [lindex $ObjectStatus 1] 1]]
              if {[string equal $BomViewName $TcBomViewTypeName]} {
                puts "now we get the bom-data"
                switch -exact -- $SapObjectType {
                  BillOfMaterial      {set ObjectDataStatus [::ITK::getObjectData $BomViewTag T4S BOM $SapObjectType MaterialMaster {*}$BomWindowSwitches]}
                  WBS_BillOfMaterial  {set ObjectDataStatus [::ITK::getObjectData $BomViewTag T4S WBS_BOM $SapObjectType MaterialMaster {*}$BomWindowSwitches]}
                  OrderBillOfMaterial {set ObjectDataStatus [::ITK::getObjectData $BomViewTag T4S ORDERBOM $SapObjectType MaterialMaster {*}$BomWindowSwitches]}
                  EquiBillOfMaterial  {set ObjectDataStatus [::ITK::getObjectData $BomViewTag T4S EQUIBOM $SapObjectType MaterialMaster {*}$BomWindowSwitches]}
                  DocumentStructure   {set ObjectDataStatus [::ITK::getObjectData $BomViewTag T4S DIRBOM $SapObjectType DocumentInfoRecord {*}$BomWindowSwitches]}
                  FunctionalLocationBillOfMaterial  {set ObjectDataStatus [::ITK::getObjectData $BomViewTag T4S FUNCLOC_BOM $SapObjectType MaterialMaster {*}$BomWindowSwitches]}
                  GenericBillOfMaterial {
                                          if {[string length $CustomBOMTargetType] > 0} {
                                            if {[string length $CustomBOMLineTargetType] == 0} {
                                              set ObjectDataStatus [::ITK::getObjectData $BomViewTag T4S GENBOM $CustomBOMTargetType MaterialMaster {*}$BomWindowSwitches]
                                            } else {
                                              set ObjectDataStatus [::ITK::getObjectData $BomViewTag T4S GENBOM $CustomBOMTargetType $CustomBOMLineTargetType {*}$BomWindowSwitches]
                                            }
                                          } else {
                                            set ObjectDataStatus "Unknown Target Object Type"
                                          }
                  }
                  default {
                    set ObjectDataStatus {}
                  }
                }
                puts "----- [::ITK::isITK_ok $ObjectDataStatus] -----"
                if {[::ITK::isITK_ok $ObjectDataStatus]} {
                  ::T4X::TC::MAPPING::printIndexTcData TEST_MAPPING
                  switch -exact -- $SapObjectType {
                    BillOfMaterial      {set Status [::T4S::BOM::MAPPING::TC_Object2SAP_BillOfMaterial TEST_MAPPING]}
                    WBS_BillOfMaterial  {set Status [::T4S::WBS_BOM::MAPPING::TC_Object2SAP_WBS_BillOfMaterial TEST_MAPPING $CustomBOMTargetType]}
                    OrderBillOfMaterial {set Status [::T4S::ORDERBOM::MAPPING::TC_Object2SAP_BillOfMaterial TEST_MAPPING]}
                    EquiBillOfMaterial  {set Status [::T4S::EQUIBOM::MAPPING::TC_Object2SAP_EquiBillOfMaterial TEST_MAPPING]}
                    FunctionalLocationBillOfMaterial  {set Status [::T4S::FUNCLOC_BOM::MAPPING::TC_Object2SAP_FuncionalLocationBillOfMaterial TEST_MAPPING $SapObjectType]}
                    DocumentStructure   {set Status [::T4S::DIRBOM::MAPPING::TC_Object2SAP_DocumentStructure TEST_MAPPING]}
                    GenericBillOfMaterial {
                                            if {[string length $CustomBOMTargetType] > 0} {
                                              set Status [::T4S::GENBOM::MAPPING::TC_Object2SAP_Object TEST_MAPPING $CustomBOMTargetType]
                                            } else {
                                              set ObjectStatus "Unknown Target Object Type"
                                            }
                    }
                    default {
                      set Status "Invalid SAP Object Target"
                    }
                  }
                  #
                  puts "XXXX"
                  puts "XXXX  MappingStatus = $Status"
                  puts "XXXX"
                } else {
                  ::T4X::TC::MAPPING::printIndexTcData TEST_MAPPING
                  set ErrorMesssage [::ITK::getErrorMessage4Status $ObjectDataStatus]
                  puts "XXXX"
                  puts "XXXX  Could not extract object data for mapping, reason: $ErrorMesssage"
                  puts "XXXX"
                }
                break
              } else {
                puts "XXXX"
                puts "XXXX  Specified bom view name \"$BomViewName\" != found bom view name \"$TcBomViewTypeName\""
                puts "XXXX"
              }
            } else {
              puts "XXXX"
              puts "XXXX  $BomViewName not found!"
              puts "XXXX"
            }
        }
      } else {
        puts "XXXX"
        puts "XXXX  No BOM VIEWS found!"
        puts "XXXX"
      }
    }
  } else {
    puts "XXXX"
    puts "XXXX  ItemRevision not found!"
    puts "XXXX"
  }
} elseif {$Connection == 1} {
  puts "XXXX"
  puts "XXXX  No Database available!"
  puts "XXXX"
} else {
  puts "XXXX"
  if {[llength $Connection] == 2} {
    puts "+++ ERROR: No connection to Teamcenter! Status=[lindex $Connection 0] ([tpco_formatHEX16 [lindex $Connection 1]]) +++"
  } else {
    puts "+++ ERROR: No connection to Teamcenter! (Status=$Connection) +++"
  }
  puts "XXXX"
}
#
if {[info exists ::StatusInfo(NumberOfMessages)]} {
  puts "::StatusInfo(NumberOfMessages) - $::StatusInfo(NumberOfMessages)"
}

if {[llength [array names ::StatusInfo "Message:*"]] > 0} {
  foreach x [array names ::StatusInfo "Message:*"] {
    puts "::StatusInfo($x) - $::StatusInfo($x)"
  }
}

puts "Last Tcl error: $::errorInfo"
#
# Now we disconnect the Tc Connection
#
catch {
  ::ITK::disconnectTcDB
}

exit 0