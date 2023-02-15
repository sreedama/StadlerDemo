#===================================================
# \copyright     2021
#                Siemens Product Lifecycle Management Software Inc.
#                All Rights Reserved.
#===================================================
#
##
# Project:        T4ST
# @file           stadler_4st_object_data_extraction_test.tcl
##
# @brief
# This testscript is used to test the mapping function based on a
# specified Tc object for the following SAP target object:
#                   * Material Master
#                   * Change Master
#                   * Document Info Record
#                   * Equipment Master
#                   * Functional Location
#

# Description, comment, flavour.
::TestScript::setScriptDesc "T4ST dataextraction configuration test (STADLER)"
::TestScript::setScriptComment "This testscript is used to test the mapping function based on a specified Tc object for the following SAP target object:<br><ul><li>Product Version</li><li>Document Version</li><li>Change Object</li><li>Structure Version</li></ul>"
::TestScript::setScriptFlavour "T4ST"
catch {
  ::TestScript::setScriptCategoryList [list "Mapping"]
}

# Gui.
set objectTypeVar [::TestScript::defineScriptParamCombo "MetaModelObjectType" "Meta Model Object Type" \
                    [list "ProductVersion" \
                          "DocumentVersion" \
                          "ChangeObject" \
                          "StructureVersion" \
                          "VariantDefinition" \
                          "VariantOption" \
                          "CUSTOM"] \
                    -external \
                    [list "Product Version" \
                          "Document Version" \
                          "Change Object" \
                          "Structure Version" \
                          "Variant Definition" \
                          "Variant Option" \
                          "Custom"]]

set funcObjectTypeVar [::TestScript::defineScriptParamCombo "FunctionalModelObjectType" "Functional Model Object Type" \
                        [list ChangeNotice \
                              ProblemReport \
                              ChangeRequest] \
                        -external \
                        [list "Change Notice" \
                              "Problem Report" \
                              "Change Request"]]
set mfkObjectTypeVar 	[::TestScript::defineScriptParamCombo "MfkObjectType" "MFK Object Type" \
												[list "" \
															"SR5MfgEndItemRevision" \
															"SR5MfgMajorAssyRevision" \
															"SR5MfgInstallKitRevision" \
															"SR5GenCatPartRevision" \
															"SR5EngArticleRevision" \
															"SR5MfgObjectRevision"] \
												-external \
												[list "" \
															"SR5MfgEndItemRevision" \
															"SR5MfgMajorAssyRevision" \
															"SR5MfgInstallKitRevision" \
															"SR5GenCatPartRevision" \
															"SR5EngArticleRevision" \
															"SR5MfgObjectRevision"]]
set itemVar [::TestScript::defineScriptParamText "IT" "Item Id" -required]
set itemRevisionVar [::TestScript::defineScriptParamText "IR" "Revision Id" -required]
set customTargetTypeVar [::TestScript::defineScriptParamText "CTT" "Custom Target Type" -required]
set bomWindowSwitchesVar [::TestScript::defineScriptParamText "BWS" "BOM Window Switches"]
set contextVar [::TestScript::defineScriptParamText "Context" "Dictionary / Product Context Id" -required]
set RevisionRuleVar [::TestScript::defineScriptParamEditCombo "RevisionRule" "Revision Rule" [list {} "Any Status; Working" "Any Status; No Working"]]

set optionFamilyVar [::TestScript::defineScriptParamText "OptionFamily" "Option Family Id" -required]

set groupVar [::TestScript::defineScriptParamGroup $objectTypeVar [list \
                [list -value "ProductVersion" $itemVar $itemRevisionVar $mfkObjectTypeVar] \
                [list -value "DocumentVersion" $itemVar $itemRevisionVar ] \
                [list -value "StructureVersion" $itemVar $itemRevisionVar $bomWindowSwitchesVar] \
                [list -value "ChangeObject" $funcObjectTypeVar $itemVar $itemRevisionVar] \
                [list -value "VariantDefinition" $contextVar $itemRevisionVar ] \
                [list -value "VariantOption" $contextVar $optionFamilyVar  $RevisionRuleVar ] \
                [list -value "CUSTOM" $customTargetTypeVar $itemVar $itemRevisionVar $mfkObjectTypeVar]]]
::TestScript::setScriptGui [list $groupVar]
::TestScript::checkTestParam $argv
#
set MetaModelObjectType ""
set FunctionalModelObjectType ""
set ObjectId            ""
set ObjectRevisionId    ""
set CustomTargetType    ""
set ObjectTag           ""
set BomWindowSwitches   ""
set BomViewRevTag       ""
set ContextId           ""
set OptionFamilyId      ""
set ContextTag          ""
set OptionFamilyTag     ""
set OptionFamilyFound   false
set ModelFamilyTag      ""
set ModuleFamilyFound   false
set RevisionRule        ""
set MfkObjectType       ""
#
if {[llength $argv] > 1} {
  foreach {Parameter Value} [lrange $::argv 1 end] {
    switch -exact -- $Parameter {
      -MetaModelObjectType       {set MetaModelObjectType $Value}
      -FunctionalModelObjectType {set FunctionalModelObjectType $Value}
			-MfkObjectType 						 {set MfkObjectType $Value}
      -Context                   {set ContextId $Value}
      -OptionFamily              {set OptionFamilyId $Value}
      -RevisionRule              {set RevisionRule $Value}
      -IT                        {set ObjectId            $Value}
      -IR                        {set ObjectRevisionId    $Value}
      -CTT                       {set CustomTargetType    $Value}
      -BWS                       {set BomWindowSwitches   $Value}
      +language {;# ignore}
    }
  }
} else {
  puts "wrong usage: [lindex $argv 0] -MetaModelObjectType ProductVersion|DocumentVersion|ChangeObject|StructureVersion -IT ItemId -IR ItemRevisionId"
  exit 0
}
#
# Define the maximum number of loops for the TestMappingSequence
#
set Connection [::ITK::connect2TcDB]
if {$Connection == 0} {
  puts "XXXX"
  puts "XXXX  Database available!"
  puts "XXXX"

  puts "XXXX"
  puts   "XXXX  MetaModelObjectType >$MetaModelObjectType<"
  if { $MetaModelObjectType eq "VariantOption" } {
    puts "XXXX  ContextId           >$ContextId<"
    puts "XXXX  OptionFamilyId      >$OptionFamilyId<"
  } elseif { $MetaModelObjectType eq "VariantDefinition" } {
    puts "XXXX  ContextId           >$ContextId<"
    puts "XXXX  RevisionId          >$ObjectRevisionId<"
    set ObjectId $ContextId
  } else {
    puts "XXXX  ObjectId            >$ObjectId<"
    puts "XXXX  RevisionId          >$ObjectRevisionId<"
  }
  puts "XXXX"

  if { $MetaModelObjectType eq "VariantOption" } {
    set ItkStatus [::ITK::ITEM_find_items_by_key_attributes "item_id" $ContextId]
    #
    if {[lindex $ItkStatus 0] == 0 && [lindex $ItkStatus 1] == 1} {
      set ContextTag [lindex [lindex $ItkStatus 2] 0]
      set ObjectTag $ContextTag
    }
    #
    # Load the ConfigPerspective for the given object
    #
    puts "Loading attached ConfigPerspective..."
    puts " "
    set rc_func2 [::ITK::getObjectPropertyByName $ContextTag cfg0ConfigPerspective]
    set cfg0ConfigPerspectiveTag [tpco_formatHEX16 [lindex $rc_func2 1]]
    #
    if { $cfg0ConfigPerspectiveTag ne "" } {
      puts "ConfigPerspective found... ($cfg0ConfigPerspectiveTag)"
      puts " "
    }
    #
    if {[string length $RevisionRule] > 0} {
      set RevisionRuleInfo [::ITK::CFM_find $RevisionRule]
      if {[llength $RevisionRuleInfo] == 2 && [lindex $RevisionRuleInfo 0] == 0} {
        set RevisionRuleTag [lindex $RevisionRuleInfo 1]
        puts "RevisionRule found... ($RevisionRuleTag)"
        set rc_setRule [::ITK::AOM_set_value $cfg0ConfigPerspectiveTag cfg0RevisionRule $RevisionRuleTag]
      }
    }
    #
    # Load all existing option families
    #
    if {[string length $RevisionRule] > 0} {
      puts "Loading attached list of option families... (based on '$RevisionRule' configuration)"
      puts " "
    }
    set rc_func2 [::ITK::getObjectPropertyByName $cfg0ConfigPerspectiveTag cfg0OptionFamilies]
    #
    set cfg0OptionFamilies [tpco_formatHEX16 [lindex $rc_func2 1]]
    #
    if { $cfg0OptionFamilies ne "" } {
      #
      puts "Option families found:"
      puts "##############################################"
      #
      foreach OptionFamilyTag [lindex $cfg0OptionFamilies 0] {
        set rc_func2 [::ITK::getObjectPropertyByName $OptionFamilyTag cfg0ObjectId]
        puts "[tpco_formatHEX16 [lindex $rc_func2 1]]"
        if {[tpco_formatHEX16 [lindex $rc_func2 1]] eq $OptionFamilyId} {
          puts "Option family $OptionFamilyId found"
          set OptionFamilyFound true
          set ValueResult [::ITK::CFG0_get_option_values $cfg0ConfigPerspectiveTag $OptionFamilyTag]
          puts "OptionValueResult $ValueResult"
          break
        }
      }
      puts "##############################################"
      set ValueResult [::ITK::CFG0_get_option_values $cfg0ConfigPerspectiveTag {*}[lindex $cfg0OptionFamilies 0]]
      puts "OptionValueResult For all Families $ValueResult"
      puts "##############################################"
    } else {
      puts "##############################################"
      puts "No Option families found (based on '$RevisionRule' configuration)"
      puts "##############################################"
    }
    #
    set rc_func2 [::ITK::getObjectPropertyByName $cfg0ConfigPerspectiveTag cfg0ModelFamilies]
    #
    set cfg0ModuleFamilies [tpco_formatHEX16 [lindex $rc_func2 1]]
    #
    if { $cfg0ModuleFamilies ne "" } {
      #
      puts "Model families found:"
      puts "##############################################"
      #
      foreach ModelFamilyTag [lindex $cfg0ModuleFamilies 0] {
        set rc_func2 [::ITK::getObjectPropertyByName $ModelFamilyTag cfg0ObjectId]
        puts "[tpco_formatHEX16 [lindex $rc_func2 1]]"
        if {[tpco_formatHEX16 [lindex $rc_func2 1]] eq $OptionFamilyId} {
          puts "Model family $OptionFamilyId found"
          set ModuleFamilyFound true
          set ValueResult [::ITK::CFG0_get_option_values $cfg0ConfigPerspectiveTag $ModelFamilyTag]
          puts "ModulenValueResult $ValueResult"
          break
        }
      }
      puts "##############################################"
      set ValueResult [::ITK::CFG0_get_option_values $cfg0ConfigPerspectiveTag {*}[lindex $cfg0ModuleFamilies 0]]
      puts "OptionValueResult For all Module Families $ValueResult"
      puts "##############################################"
    } else {
      puts "##############################################"
      puts "No Option families found (based on '$RevisionRule' configuration)"
      puts "##############################################"
    }
  } else {
    set ItkStatus [::ITK::ITEM_find_item_revs_by_key_attributes $ObjectRevisionId "item_id" $ObjectId]
    puts "ITEM_find_item_revs_by_key_attributes - $ItkStatus"
    if {[lindex $ItkStatus 0] == 0 && [lindex $ItkStatus 1] == "1"} {
      set ObjectTag [lindex [lindex $ItkStatus 2] 0]
		} else {
			puts "XXXX"
			puts "XXXX  Found [lindex $ItkStatus 1] Objects with ID = $ObjectId and Rev ID = $ObjectRevisionId -> Check object type..."
			puts "XXXX"
			# Loop over found objects
			foreach ItemRev [lindex $ItkStatus 2] {
				# Get objec type
				set ItemTypeStatus [::ITK::getObjectPropertyByName $ItemRev "object_type"]
				if {[::ITK::isITK_ok $ItemTypeStatus]} {
					set ObjectType [::ITK::getObjectValue $ItemTypeStatus]
					puts "ObjectType: $ObjectType"
					puts "MfkObjectType: $MfkObjectType"
					if {$ObjectType eq $MfkObjectType} {
						set ObjectTag $ItemRev
						puts "XXXX"
						puts "XXXX  Found Object with object type = $ObjectType"
						puts "XXXX"				
						break
					}
				} else {
					set ErrorNumber  [::ITK::getITKStatusNumber $ItemTypeStatus]
					set ErrorMessage [::ITK::getErrorMessage4Status $ItemTypeStatus]
					puts "ErrorNumber: $ErrorNumber --> ErrorMessage: ErrorMessage"
				}
			}		
		}
		if {[string length $ObjectTag] > 0} {
      # ---------------------------------------------
      # Get BVR
      # ---------------------------------------------
      if { $MetaModelObjectType eq "StructureVersion" } {
        puts "MetaModelObjectType >$MetaModelObjectType< -> get BVR ..."
        set BomViewStatus [::ITK::ITEM_rev_list_bom_view_revs $ObjectTag]
        puts "BomViewStatus: $BomViewStatus - is OK: [::ITK::isITK_ok $BomViewStatus]"
        
        if {[llength $BomViewStatus] == 2 && [lindex $BomViewStatus 0] == 0} {
          set lBVTAgList [lindex $BomViewStatus 1]
          if { [lindex $lBVTAgList 0] eq "" || [lindex $lBVTAgList 2] ne "" } {
            set sMsg "Only one BOMView supported. Found >$lBVTAgList<"
            puts "ERROR: $Msg"
            exit 1
          }
          set BomViewRevTag [lindex $lBVTAgList 0]
          puts "BomViewRevTag >$BomViewRevTag<"
        } else {
          set sMsg [::ITK::getErrorMessage4Status $BomViewStatus]
          puts "ERROR: getting IR BVR - Msg >$sMsg<"
          exit 1
        }
      }
    }
  }  
  
  #
  # now we check, if we need to use a sub object for the mapping
  #
  if {[string length $ObjectTag] > 0} {
    # ---------------------------------------------
    # call to get TC data
    # ---------------------------------------------
    puts "# get TC object data ..."
    puts " MetaModelObjectType >$MetaModelObjectType<"
    #
    switch -exact -- $MetaModelObjectType {
      DocumentVersion      {set ObjectDataStatus [::ITK::getObjectData $ObjectTag T4ST DV DocumentVersion]}
      ProductVersion       {set ObjectDataStatus [::ITK::getObjectData $ObjectTag T4ST PV ProductVersion]}
      ChangeObject         {
                              switch -exact -- $FunctionalModelObjectType {
                                ChangeNotice   {set ObjectDataStatus [::ITK::getObjectData $ObjectTag T4ST CN $FunctionalModelObjectType]}
                                ProblemReport  {set ObjectDataStatus [::ITK::getObjectData $ObjectTag T4ST PR $FunctionalModelObjectType]}
                                ChangeRequest  {set ObjectDataStatus [::ITK::getObjectData $ObjectTag T4ST CR $FunctionalModelObjectType]}
                                default        {set ObjectDataStatus "Unknown Functional Target Object Type"}
                              }
                           }
      StructureVersion     {
                             set BOMLineTargetType "ProductVersion"
                             set BOMHeaderTargetType "StructureVersion"
                             puts "get SV tc data BOMHeaderTargetType >$BOMHeaderTargetType< BOMLineTargetType >$BOMLineTargetType< >$BomWindowSwitches<"
                             set ObjectDataStatus [::ITK::getObjectData $BomViewRevTag T4ST SV ${BOMHeaderTargetType} ${BOMLineTargetType} {*}$BomWindowSwitches]
                           }
      VariantDefinition    {
                            #
                            # get object data
                            #
                            set ObjectDataStatus [::ITK::getObjectData $ObjectTag T4ST VD $MetaModelObjectType]
                          }
      VariantOption       {
                            if {[string length $cfg0ConfigPerspectiveTag] > 0} {
                              #
                              # get object data
                              #
                              if {$OptionFamilyFound} {
                                if {[string length $RevisionRule] > 0} {
                                  set ObjectDataStatus [::ITK::getConfiguratorObjectData $ContextTag  T4ST VO $MetaModelObjectType -revision_rule=$RevisionRule -Cfg0OptionFamily=$OptionFamilyTag]
                                } else {
                                  set ObjectDataStatus [::ITK::getConfiguratorObjectData $ContextTag  T4ST VO $MetaModelObjectType -Cfg0OptionFamily=$OptionFamilyTag]
                                }
                              } elseif {$ModuleFamilyFound} {
                                if {[string length $RevisionRule] > 0} {
                                  set ObjectDataStatus [::ITK::getConfiguratorObjectData $ContextTag  T4ST VO $MetaModelObjectType -revision_rule=$RevisionRule -Cfg0OptionFamily=$ModelFamilyTag]
                                } else {
                                  set ObjectDataStatus [::ITK::getConfiguratorObjectData $ContextTag  T4ST VO $MetaModelObjectType -Cfg0OptionFamily=$ModelFamilyTag]
                                }
                              } else {
                                # simulate error
                                puts "ERROR: Option family or ProductModelFamily $OptionFamilyId not found!"
                                set ObjectStatus [list 212103 [tpco_scanHEX16 "ERROR: Option family $OptionFamilyId not found!"]]
                              }
                            } else {
                              puts "XXXX"
                              puts "XXXX  Dictionary or Product Context not found!"
                              puts "XXXX"
                            }
                          }
      CUSTOM   {
                if {[string length $CustomTargetType] > 0} {
                  set ObjectDataStatus [::ITK::getObjectData $ObjectTag T4ST OBJECT $CustomTargetType]
                } else {
                  set ObjectDataStatus "Unknown Target Object Type"
                }
      }
      default  {set ObjectDataStatus "Unknown Target Object Type"}
    }
    puts "Dataextraction Status: $ObjectDataStatus"
    # ---------------------------------------------
    # Print TC Data
    # ---------------------------------------------
    puts "# print TC Data ...."
    if {[::ITK::isITK_ok $ObjectDataStatus]} {
      ::T4X::TC::MAPPING::printTcData TEST_MAPPING
      if {[info exists ::TcData(0:ItemInfo:TypeName)] || [info exists ::TcData(1:ItemInfo:Hirachy)]} {
        ::T4X::TC::MAPPING::printIndexTcData TEST_MAPPING
      }
    } else {
      set ErrorMesssage [::ITK::getErrorMessage4Status $ObjectDataStatus]
      puts "XXXX"
      puts "XXXX  Could not extract object data for mapping, reason: $ErrorMesssage"
      puts "XXXX"
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


#
# Now we disconnect the Tc Connection
#
catch {
  ::ITK::disconnectTcDB
}

exit 0
