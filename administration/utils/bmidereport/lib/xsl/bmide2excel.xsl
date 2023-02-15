<?xml version="1.0" encoding="ISO-8859-1"?>
	<!-- ================================================================ -->
	<!--                                                                  -->
	<!-- SIEMENS PLM Copyright (c) 2010                                   -->
	<!-- Unpublished - All rights reserved                                -->
	<!--                                                                  -->
	<!-- File name: bmide2xls.xsl                                         -->
	<!--                                                                  -->
	<!-- Description:                                                     -->
	<!-- 27-Jan-2010 Christian Günther Initial Creation                   -->
	<!-- $HISTORY$                                                        -->
	<!-- 28-Jan-2010 Christian Günther add extension rules                -->
	<!-- 27-Jan-2010 Christian Günther add display rules                  -->
	<!-- ================================================================ -->
<xsl:stylesheet xmlns:plm="http://www.plmxml.org/Schemas/PLMXMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:lxslt="http://xml.apache.org/xslt"
	xmlns:xalan="http://xml.apache.org/xalan" version="1.0"
	xmlns="urn:schemas-microsoft-com:office:spreadsheet"
	exclude-result-prefixes="  plm xalan">
	<xsl:strip-space elements="Cell,Data,*" />

	<xsl:output method="xml" indent="yes" />

	<!-- start section parameter -->
	<xsl:param name="P_CONFIG_FILE" />
	<!-- end section parameter -->
	<!-- start section global constants -->
	<xsl:variable name="sDataType">String</xsl:variable>
	<xsl:variable name="sColID1">1</xsl:variable>
	<xsl:variable name="sColID2">2</xsl:variable>
	<xsl:variable name="sColID3">3</xsl:variable>
	<xsl:variable name="sColID4">4</xsl:variable>
	<xsl:variable name="sColID5">5</xsl:variable>
	<xsl:variable name="sColID6">6</xsl:variable>
	<xsl:variable name="sColID7">7</xsl:variable>
	<xsl:variable name="sColID8">8</xsl:variable>
	<xsl:variable name="sColID9">9</xsl:variable>
	<xsl:variable name="sColID10">10</xsl:variable>
	<xsl:variable name="sColID11">11</xsl:variable>
	<xsl:variable name="sColID12">12</xsl:variable>
	<xsl:variable name="sColID13">13</xsl:variable>
	<xsl:variable name="sColID14">14</xsl:variable>
	<xsl:variable name="sColID15">15</xsl:variable>
	<xsl:variable name="sColID16">16</xsl:variable>
	<xsl:variable name="sColID17">17</xsl:variable>
	<xsl:variable name="sColID18">18</xsl:variable>
	<!-- end section global constants -->

	<!-- main program starts here -->
	<xsl:template match="/">
		<xsl:processing-instruction name="mso-application">
			<xsl:text>progid="Excel.Sheet"</xsl:text>
		</xsl:processing-instruction>
		<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
			xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel"
			xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">
			<?mso-application progid="Excel.Sheet"?>
<!-- 
			<xsl:call-template name="extractContent">
				<xsl:with-param name="pContent">extractContent</xsl:with-param>
			</xsl:call-template>
 -->

			<xsl:call-template name="extractAttributes">
				<xsl:with-param name="pContent">TcAttribute</xsl:with-param>
			</xsl:call-template>

			<xsl:call-template name="extractTypes">
				<xsl:with-param name="pContent">TcStandardType</xsl:with-param>
			</xsl:call-template>

			<xsl:call-template name="extractOccurenceNotes">
				<xsl:with-param name="pContent">extractOccurenceNotes</xsl:with-param>
			</xsl:call-template>

			<xsl:call-template name="extractPropertyRules">
				<xsl:with-param name="pContent">extractPropertyRules</xsl:with-param>
			</xsl:call-template>

			<xsl:call-template name="extractPropertyConstants">
				<xsl:with-param name="pContent">extractPropertyConstants</xsl:with-param>
			</xsl:call-template>

			<xsl:call-template name="extractCompoundPropertyRules">
				<xsl:with-param name="pContent">extractCompoundPropertyRules</xsl:with-param>
			</xsl:call-template>

			<xsl:call-template name="extractDatasetTypes">
				<xsl:with-param name="pContent">extractDatasetTypes</xsl:with-param>
			</xsl:call-template>

			<xsl:call-template name="extractDatasetActions">
				<xsl:with-param name="pContent">extractDatasetActions</xsl:with-param>
			</xsl:call-template>
			
			<xsl:call-template name="extractTools">
				<xsl:with-param name="pContent">extractTools</xsl:with-param>
			</xsl:call-template>

			<xsl:call-template name="extractToolAssignments">
				<xsl:with-param name="pContent">extractToolAssignments</xsl:with-param>
			</xsl:call-template>

			<xsl:call-template name="extractClassicChanges">
				<xsl:with-param name="pContent">extractClassicChanges</xsl:with-param>
			</xsl:call-template>
			
			<xsl:call-template name="extractExtensionsValidity">
				<xsl:with-param name="pContent">extractExtensionsValidity</xsl:with-param>
			</xsl:call-template>

			<xsl:call-template name="extractExtensionsParameter">
				<xsl:with-param name="pContent">extractExtensionsParameter</xsl:with-param>
			</xsl:call-template>

			<xsl:call-template name="extractExtensionsAttach">
				<xsl:with-param name="pContent">extractExtensionsAttach</xsl:with-param>
			</xsl:call-template>

			<xsl:call-template name="extractReleaseStatus">
				<xsl:with-param name="pContent">extractReleaseStatus</xsl:with-param>
			</xsl:call-template>
			
			<xsl:call-template name="extractConditions">
				<xsl:with-param name="pContent">extractConditions</xsl:with-param>
			</xsl:call-template>
			

			<xsl:call-template name="extractUnitOfMeasure">
				<xsl:with-param name="pContent">extractUnitOfMeasure</xsl:with-param>
			</xsl:call-template>

			<xsl:call-template name="extractLOVs">
				<xsl:with-param name="pContent">extractLOVs</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="extractLOVAttach">
				<xsl:with-param name="pContent">extractLOVAttach attach</xsl:with-param>
			</xsl:call-template>
			
			<xsl:call-template name="extractLOVValues">
				<xsl:with-param name="pContent">extractLOVValues</xsl:with-param>
			</xsl:call-template>

			<xsl:call-template name="extractDeepCopyRules">
				<xsl:with-param name="pContent">extractDeepCopyRules</xsl:with-param>
			</xsl:call-template>
			
			<xsl:call-template name="extractGRMRules">
				<xsl:with-param name="pContent">extractGRMRules</xsl:with-param>
			</xsl:call-template>

			<xsl:call-template name="extractNamingRules">
				<xsl:with-param name="pContent">extractNamingRules</xsl:with-param>
			</xsl:call-template>
			
			<xsl:call-template name="extractTypeDisplayRules">
				<xsl:with-param name="pContent">extractTypeDisplayRules</xsl:with-param>
			</xsl:call-template>
<!-- 
-->
		</Workbook>
	</xsl:template>

	<xsl:template name="extractContent">
		<xsl:param name="pContent" />

		<xsl:element name="Worksheet">
			<!-- sheet name -->
			<xsl:attribute name="ss:Name">
						<xsl:value-of select="$pContent" />
					</xsl:attribute>
			<!-- start table -->
			<xsl:element name="Table">
				<!-- start column definition -->
				<!-- level -->
				<xsl:element name="Column">
					<xsl:attribute name="ss:Width">30</xsl:attribute>
				</xsl:element>
				<!-- task name -->
				<xsl:element name="Column">
					<xsl:attribute name="ss:Width">150</xsl:attribute>
				</xsl:element>
				<!-- end table -->
			</xsl:element>
			<!-- end sheet -->
		</xsl:element>
	</xsl:template>

	<xsl:template name="extractTypes">
		<!-- start parameter -->
		<xsl:param name="pContent" />
		<!-- end parameter -->
		<!-- start declarations -->
		<xsl:variable name="sWorksheetName">types</xsl:variable>
		<xsl:variable name="sTitleID1">type name</xsl:variable>
		<xsl:variable name="sTitleID2">parent type name</xsl:variable>
		<xsl:variable name="sTitleID3">storage class</xsl:variable>
		<!-- end declarations -->
		<xsl:element name="Worksheet">
			<!-- sheet name -->
			<xsl:attribute name="ss:Name">
						<xsl:value-of select="$sWorksheetName" />
					</xsl:attribute>
			<!-- start table -->
			<xsl:element name="Table">
				<!-- start column definition -->
				<!-- typeName -->
				<xsl:call-template name="setupColumn" />
				<!-- parentTypeName -->
				<xsl:call-template name="setupColumn" />
				<!-- storage class name -->
				<xsl:call-template name="setupColumn" />
				<!-- end column definition -->
				<!-- start header line -->
				<xsl:element name="Row">
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID1" />
						<xsl:with-param name="pContent" select="$sTitleID1" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID2" />
						<xsl:with-param name="pContent" select="$sTitleID2" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID3" />
						<xsl:with-param name="pContent" select="$sTitleID3" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
				</xsl:element>
				<!-- end header line -->
				<!-- start extract content
				
				<xsl:for-each select="//child::*/child::*[local-name() = 'TcStandardType']">
				-->
				<xsl:for-each select="//child::*/child::*[local-name() = $pContent ]">
					<xsl:sort select="@parentTypeName" />
					<xsl:sort select="@typeName" />
					<xsl:sort select="@typeClassName" />
					<xsl:element name="Row">
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID1" />
							<xsl:with-param name="pContent" select="@typeName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID2" />
							<xsl:with-param name="pContent" select="@parentTypeName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID3" />
							<xsl:with-param name="pContent" select="@typeClassName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
					</xsl:element>
				</xsl:for-each>
				<!-- start extract forms-->
				<xsl:for-each select="//child::*/child::*[local-name() = 'TcForm']">
					<xsl:sort select="@typeName" />
					<xsl:sort select="@typeClassName" />
					<xsl:element name="Row">
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID1" />
							<xsl:with-param name="pContent" select="@typeName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID2" />
							<xsl:with-param name="pContent" select="@parentTypeName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID3" />
							<xsl:with-param name="pContent" select="@formStorageClassName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
					</xsl:element>
					<!--
						end extract forms typeName="ProjectMaster" parentTypeName="Form"
						typeClassName="Form" formStorageClassName="ProjectMasterStorage"
					-->
				</xsl:for-each>
			</xsl:element>
			<!-- end table -->

		</xsl:element>
		<!-- end sheet -->
	</xsl:template>


	<xsl:template name="extractGRMRules">
		<!-- start parameter -->
		<xsl:param name="pContent" />
		<!-- end parameter -->
		<!-- start declarations -->
		<xsl:variable name="sWorksheetName">GRM rules</xsl:variable>
		<xsl:variable name="sTitleID1">primary</xsl:variable>
		<xsl:variable name="sTitleID2">secondary</xsl:variable>
		<xsl:variable name="sTitleID3">relation</xsl:variable>
		<xsl:variable name="sTitleID4">primaryCardinality</xsl:variable>
		<xsl:variable name="sTitleID5">secondaryCardinality</xsl:variable>
		<xsl:variable name="sTitleID6">secured</xsl:variable>
		<xsl:variable name="sTitleID7">attachability</xsl:variable>
		<xsl:variable name="sTitleID8">changeability</xsl:variable>
		<xsl:variable name="sTitleID9">detachability</xsl:variable>

		<!-- end declarations -->
		<xsl:element name="Worksheet">
			<!-- sheet name -->
			<xsl:attribute name="ss:Name">
						<xsl:value-of select="$sWorksheetName" />
					</xsl:attribute>
			<!-- start table -->
			<xsl:element name="Table">
				<!-- start column definition -->
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<!-- end column definition -->
				<!-- start header line -->
				<xsl:element name="Row">
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID1" />
						<xsl:with-param name="pContent" select="$sTitleID1" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID2" />
						<xsl:with-param name="pContent" select="$sTitleID2" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID3" />
						<xsl:with-param name="pContent" select="$sTitleID3" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID4" />
						<xsl:with-param name="pContent" select="$sTitleID4" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID5" />
						<xsl:with-param name="pContent" select="$sTitleID5" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID6" />
						<xsl:with-param name="pContent" select="$sTitleID6" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID7" />
						<xsl:with-param name="pContent" select="$sTitleID7" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID8" />
						<xsl:with-param name="pContent" select="$sTitleID8" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID9" />
						<xsl:with-param name="pContent" select="$sTitleID9" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
				</xsl:element>
				<!-- end header line -->


				<!-- start extract content-->
				<xsl:for-each select="//child::*/child::*[local-name() = 'TcGRMRule']">
					<xsl:sort select="@primaryTypeName" />
					<xsl:sort select="@secondaryTypeName" />
					<xsl:sort select="@relationTypeName" />

					<xsl:element name="Row">
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID1" />
							<xsl:with-param name="pContent" select="@primaryTypeName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID2" />
							<xsl:with-param name="pContent" select="@secondaryTypeName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID3" />
							<xsl:with-param name="pContent" select="@relationTypeName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID4" />
							<xsl:with-param name="pContent" select="@primaryCardinality" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID5" />
							<xsl:with-param name="pContent" select="@secondaryCardinality" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID6" />
							<xsl:with-param name="pContent" select="@secured" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID7" />
							<xsl:with-param name="pContent" select="@attachability" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID8" />
							<xsl:with-param name="pContent" select="@changeability" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID9" />
							<xsl:with-param name="pContent" select="@detachability" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>

					</xsl:element>
				</xsl:for-each>
				<!-- end extract content-->

			</xsl:element>
			<!-- end table -->

		</xsl:element>
		<!-- end sheet -->
	</xsl:template>

	<xsl:template name="extractNamingRules">
		<!-- start parameter -->
		<xsl:param name="pContent" />
		<!-- end parameter -->
		<!-- start declarations -->
		<xsl:variable name="sWorksheetName">NR rules</xsl:variable>
		<xsl:variable name="sTitleID1">name</xsl:variable>
		<xsl:variable name="sTitleID2">description</xsl:variable>
		<xsl:variable name="sTitleID3">pattern</xsl:variable>
		<xsl:variable name="sTitleID4">counter</xsl:variable>
		<xsl:variable name="sTitleID5">initial value</xsl:variable>
		<xsl:variable name="sTitleID6">max value</xsl:variable>

		<!-- end declarations -->
		<xsl:element name="Worksheet">
			<!-- sheet name -->
			<xsl:attribute name="ss:Name">
						<xsl:value-of select="$sWorksheetName" />
					</xsl:attribute>
			<!-- start table -->
			<xsl:element name="Table">
				<!-- start column definition -->
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />

				<!-- end column definition -->
				<!-- start header line -->
				<xsl:element name="Row">
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID1" />
						<xsl:with-param name="pContent" select="$sTitleID1" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID2" />
						<xsl:with-param name="pContent" select="$sTitleID2" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID3" />
						<xsl:with-param name="pContent" select="$sTitleID3" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID4" />
						<xsl:with-param name="pContent" select="$sTitleID4" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID5" />
						<xsl:with-param name="pContent" select="$sTitleID5" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID6" />
						<xsl:with-param name="pContent" select="$sTitleID6" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>

				</xsl:element>
				<!-- end header line -->
				<!-- start extract content-->
				<xsl:for-each
					select="//child::*/child::*[local-name() = 'TcNamingRule']/child::*[local-name() = 'TcPattern' and @generateCounters = 'true']">
					<xsl:sort select="parent::*/@name" />

					<xsl:element name="Row">
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID1" />
							<xsl:with-param name="pContent" select="parent::*/@name" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID2" />
							<xsl:with-param name="pContent" select="@decription" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID3" />
							<xsl:with-param name="pContent" select="@patternString" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID4" />
							<xsl:with-param name="pContent" select="@generateCounters" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID5" />
							<xsl:with-param name="pContent"
								select="parent::*/child::*/child::*/@initialValue" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID6" />
							<xsl:with-param name="pContent"
								select="parent::*/child::*/child::*/@maximumValue" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
					</xsl:element>
				</xsl:for-each>

				<xsl:for-each
					select="//child::*/child::*[local-name() = 'TcNamingRule' and @generateCounters = 'false']/child::*[local-name() = 'TcPattern']">
					<xsl:sort select="parent::*/@name" />

					<xsl:element name="Row">
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID1" />
							<xsl:with-param name="pContent" select="parent::*/@name" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID2" />
							<xsl:with-param name="pContent" select="parent::*/@decription" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID3" />
							<xsl:with-param name="pContent" select="@patternString" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID4" />
							<xsl:with-param name="pContent" select="parent::*/@generateCounters" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
					</xsl:element>
				</xsl:for-each>				<!-- end extract content-->

			</xsl:element>
			<!-- end table -->

		</xsl:element>
		<!-- end sheet -->
	</xsl:template>


	<xsl:template name="extractDatasetTypes">
		<!-- start parameter -->
		<xsl:param name="pContent" />
		<!-- end parameter -->
		<!-- start declarations -->
		<xsl:variable name="sWorksheetName">dataset</xsl:variable>
		<xsl:variable name="sTitleID1">type name</xsl:variable>
		<xsl:variable name="sTitleID2">parent type name</xsl:variable>
		<xsl:variable name="sTitleID3">typeClassName</xsl:variable>
		<xsl:variable name="sTitleID4">nref name</xsl:variable>
		<xsl:variable name="sTitleID5">nref extension</xsl:variable>
		<xsl:variable name="sTitleID6">nref format</xsl:variable>

		<!-- end declarations -->
		<xsl:element name="Worksheet">
			<!-- sheet name -->
			<xsl:attribute name="ss:Name">
						<xsl:value-of select="$sWorksheetName" />
					</xsl:attribute>
			<!-- start table -->
			<xsl:element name="Table">
				<!-- start column definition -->
				<!-- typeName -->
				<xsl:call-template name="setupColumn" />
				<!-- parentTypeName -->
				<xsl:call-template name="setupColumn" />
				<!-- storage class name -->
				<xsl:call-template name="setupColumn" />

				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<!-- end column definition -->
				<!-- start header line -->
				<xsl:element name="Row">
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID1" />
						<xsl:with-param name="pContent" select="$sTitleID1" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID2" />
						<xsl:with-param name="pContent" select="$sTitleID2" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID3" />
						<xsl:with-param name="pContent" select="$sTitleID3" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID4" />
						<xsl:with-param name="pContent" select="$sTitleID4" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID5" />
						<xsl:with-param name="pContent" select="$sTitleID5" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID6" />
						<xsl:with-param name="pContent" select="$sTitleID6" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
				</xsl:element>
				<!-- end header line -->
				<!-- start extract content-->
				<xsl:for-each
					select="//child::*/child::*[local-name() = 'TcDataset']/child::*[local-name() = 'TcDatasetReference']/child::*[local-name() = 'TcDatasetReferenceInfo']">
					<xsl:sort select="parent::*/parent::*/@typeName" />
					<xsl:element name="Row">
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID1" />
							<xsl:with-param name="pContent"
								select="parent::*/parent::*/@typeName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID2" />
							<xsl:with-param name="pContent"
								select="parent::*/parent::*/@parentTypeName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID3" />
							<xsl:with-param name="pContent"
								select="parent::*/parent::*/@typeClassName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID4" />
							<xsl:with-param name="pContent" select="parent::*/@name" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID5" />
							<xsl:with-param name="pContent" select="@template" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID6" />
							<xsl:with-param name="pContent" select="@format" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
					</xsl:element>
				</xsl:for-each>
				<!-- start extract content-->

			</xsl:element>
			<!-- end table -->

		</xsl:element>
		<!-- end sheet -->
	</xsl:template>

	<xsl:template name="extractLOVAttach">
		<!-- start parameter -->
		<xsl:param name="pContent" />
		<!-- end parameter -->
		<!-- start declarations -->
		<xsl:variable name="sWorksheetName">lov attach</xsl:variable>
		<xsl:variable name="sTitleID1">lov name</xsl:variable>
		<xsl:variable name="sTitleID2">type name</xsl:variable>
		<xsl:variable name="sTitleID3">property name</xsl:variable>
		<xsl:variable name="sTitleID4">level</xsl:variable>
		
		<!-- end declarations -->
		<xsl:element name="Worksheet">
			<!-- sheet name -->
			<xsl:attribute name="ss:Name">
						<xsl:value-of select="$sWorksheetName" />
					</xsl:attribute>
			<!-- start table -->
			<xsl:element name="Table">
				<!-- start column definition -->
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<!-- end column definition -->
				<!-- start header line -->
				<xsl:element name="Row">
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID1" />
						<xsl:with-param name="pContent" select="$sTitleID1" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID2" />
						<xsl:with-param name="pContent" select="$sTitleID2" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID3" />
						<xsl:with-param name="pContent" select="$sTitleID3" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID4" />
						<xsl:with-param name="pContent" select="$sTitleID4" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
				</xsl:element>
				<!-- end header line -->
				<!-- start extract content-->
				<xsl:for-each select="//child::*/child::*[local-name() = 'TcLOVAttach']">
					<xsl:sort select="@typeName" />
					<xsl:sort select="@lovName" />
					<xsl:element name="Row">
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID1" />
							<xsl:with-param name="pContent" select="@lovName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID2" />
							<xsl:with-param name="pContent" select="@typeName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID3" />
							<xsl:with-param name="pContent" select="child::*/@valuePropertyName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID4" />
							<xsl:with-param name="pContent" select="child::*/@level" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
					</xsl:element>
				</xsl:for-each>
				<xsl:for-each
					select="//child::*/child::*[local-name() = 'TcLOVValueSubLOVAttach']">
					<xsl:sort select="@subLOVName" />
					<xsl:sort select="@targetLOVName" />
					<xsl:element name="Row">
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID1" />
							<xsl:with-param name="pContent" select="@subLOVName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID2" />
							<xsl:with-param name="pContent" select="@targetLOVName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID3" />
							<xsl:with-param name="pContent" select="@targetValue" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID4" />
							<xsl:with-param name="pContent">0</xsl:with-param>
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
					</xsl:element>
				</xsl:for-each>				<!-- start extract content-->
			</xsl:element>
			<!-- end table -->
		</xsl:element>
		<!-- end sheet -->
	</xsl:template>

	<xsl:template name="extractAttributes">
		<!-- start parameter -->
		<xsl:param name="pContent" />
		<!-- end parameter -->
		<!-- start declarations -->
		<xsl:variable name="sWorksheetName">attributes</xsl:variable>
		<xsl:variable name="sTitleID1">class name</xsl:variable>
		<xsl:variable name="sTitleID2">attribute name</xsl:variable>
		<xsl:variable name="sTitleID3">attribute type</xsl:variable>
		<xsl:variable name="sTitleID4">max length</xsl:variable>
		<xsl:variable name="sTitleID5">is array</xsl:variable>
		<xsl:variable name="sTitleID6">null allowed</xsl:variable>
		<xsl:variable name="sTitleID7">pulic read</xsl:variable>
		<xsl:variable name="sTitleID8">pulic write</xsl:variable>
		<xsl:variable name="sTitleID9">unique</xsl:variable>
		<xsl:variable name="sTitleID10">candidate key</xsl:variable>
		<xsl:variable name="sTitleID11">transient</xsl:variable>
		<xsl:variable name="sTitleID12">export as string</xsl:variable>
		<xsl:variable name="sTitleID13">no back pointer</xsl:variable>
		<xsl:variable name="sTitleID14">initial value</xsl:variable>
		<xsl:variable name="sTitleID15">lower bound value</xsl:variable>
		<xsl:variable name="sTitleID16">upper bound value</xsl:variable>
		<xsl:variable name="sTitleID17">follow on export</xsl:variable>
		<xsl:variable name="sTitleID18">array size</xsl:variable>
		<!-- end declarations -->
		<xsl:element name="Worksheet">
			<!-- sheet name -->
			<xsl:attribute name="ss:Name">
						<xsl:value-of select="$sWorksheetName" />
					</xsl:attribute>
			<!-- start table -->
			<xsl:element name="Table">
				<!-- start column definition -->
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<!-- end column definition -->
				<!-- start header line -->
				<xsl:element name="Row">
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID1" />
						<xsl:with-param name="pContent" select="$sTitleID1" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID2" />
						<xsl:with-param name="pContent" select="$sTitleID2" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID3" />
						<xsl:with-param name="pContent" select="$sTitleID3" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID4" />
						<xsl:with-param name="pContent" select="$sTitleID4" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID5" />
						<xsl:with-param name="pContent" select="$sTitleID5" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID6" />
						<xsl:with-param name="pContent" select="$sTitleID6" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID7" />
						<xsl:with-param name="pContent" select="$sTitleID7" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID8" />
						<xsl:with-param name="pContent" select="$sTitleID8" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID9" />
						<xsl:with-param name="pContent" select="$sTitleID9" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID10" />
						<xsl:with-param name="pContent" select="$sTitleID10" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID11" />
						<xsl:with-param name="pContent" select="$sTitleID11" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID12" />
						<xsl:with-param name="pContent" select="$sTitleID12" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID13" />
						<xsl:with-param name="pContent" select="$sTitleID13" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID14" />
						<xsl:with-param name="pContent" select="$sTitleID14" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID15" />
						<xsl:with-param name="pContent" select="$sTitleID15" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID16" />
						<xsl:with-param name="pContent" select="$sTitleID16" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID17" />
						<xsl:with-param name="pContent" select="$sTitleID17" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID18" />
						<xsl:with-param name="pContent" select="$sTitleID18" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
				</xsl:element>
				<!-- end header line -->
				<!-- start extract content-->
				<xsl:for-each
					select="//child::*/child::*/child::*[local-name() = 'TcAttribute']">
					<xsl:sort select="@parentTypeName" />
					<xsl:sort select="@typeName" />
					<xsl:sort select="@typeClassName" />
					<xsl:element name="Row">
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID1" />
							<xsl:with-param name="pContent" select="parent::*/@className" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID2" />
							<xsl:with-param name="pContent" select="@attributeName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID3" />
							<xsl:with-param name="pContent" select="@attributeType" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID4" />
							<xsl:with-param name="pContent" select="@maxStringLength" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID5" />
							<xsl:with-param name="pContent" select="@isArray" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID6" />
							<xsl:with-param name="pContent" select="@arrayLength" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID7" />
							<xsl:with-param name="pContent" select="@isPublicRead" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID8" />
							<xsl:with-param name="pContent" select="@isPublicWrite" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID9" />
							<xsl:with-param name="pContent" select="@isUnique" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID10" />
							<xsl:with-param name="pContent" select="@isCandidateKey" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID11" />
							<xsl:with-param name="pContent" select="@isTransient" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID12" />
							<xsl:with-param name="pContent" select="@exportAsString" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID13" />
							<xsl:with-param name="pContent" select="@noBackpointer" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID14" />
							<xsl:with-param name="pContent" select="@initialValue" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID15" />
							<xsl:with-param name="pContent" select="@lowerBoundValue" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID16" />
							<xsl:with-param name="pContent" select="@upperBoundValue" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID17" />
							<xsl:with-param name="pContent" select="@followOnExport" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID18" />
							<xsl:with-param name="pContent" select="@arrayLength" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
					</xsl:element>
				</xsl:for-each>
				<!-- start extract content-->
			</xsl:element>
			<!-- end table -->
		</xsl:element>
		<!-- end sheet -->
	</xsl:template>

	<xsl:template name="extractExtensionsValidity">
		<!-- start parameter -->
		<xsl:param name="pContent" />
		<!-- end parameter -->
		<!-- start declarations -->
		<xsl:variable name="sWorksheetName">extensions validity</xsl:variable>
		<xsl:variable name="sTitleID1">name</xsl:variable>
		<xsl:variable name="sTitleID2">libraryName</xsl:variable>
		<xsl:variable name="sTitleID3">internal</xsl:variable>
		<xsl:variable name="sTitleID4">cannedExtension</xsl:variable>
		<xsl:variable name="sTitleID5">languageType</xsl:variable>
		<xsl:variable name="sTitleID6">description</xsl:variable>
		<xsl:variable name="sTitleID7">Validity</xsl:variable>
		<!-- end declarations -->
		<xsl:element name="Worksheet">
			<!-- sheet name -->
			<xsl:attribute name="ss:Name">
						<xsl:value-of select="$sWorksheetName" />
					</xsl:attribute>
			<!-- start table -->
			<xsl:element name="Table">
				<!-- start column definition -->
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<!-- end column definition -->
				<!-- start header line -->
				<xsl:element name="Row">
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID1" />
						<xsl:with-param name="pContent" select="$sTitleID1" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID2" />
						<xsl:with-param name="pContent" select="$sTitleID2" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID3" />
						<xsl:with-param name="pContent" select="$sTitleID3" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID4" />
						<xsl:with-param name="pContent" select="$sTitleID4" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID5" />
						<xsl:with-param name="pContent" select="$sTitleID5" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID6" />
						<xsl:with-param name="pContent" select="$sTitleID6" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID7" />
						<xsl:with-param name="pContent" select="$sTitleID7" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
				</xsl:element>
				<!-- end header line -->
				<!-- start extract content-->
				<xsl:for-each
					select="//child::*/child::*[local-name() = 'TcExtension']/child::*[local-name() = 'TcExtensionValidity']">
					<xsl:sort select="parent::*/@name" />
					<xsl:element name="Row">
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID1" />
							<xsl:with-param name="pContent" select="parent::*/@name" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID2" />
							<xsl:with-param name="pContent" select="parent::*/@libraryName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID3" />
							<xsl:with-param name="pContent" select="parent::*/@internal" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID4" />
							<xsl:with-param name="pContent" select="parent::*/@cannedExtension" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID5" />
							<xsl:with-param name="pContent" select="parent::*/@languageType" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID6" />
							<xsl:with-param name="pContent" select="parent::*/@description" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID7" />
							<xsl:with-param name="pContent" select="@parameter" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
					</xsl:element>
				</xsl:for-each>
				<!-- end extract content-->
			</xsl:element>
			<!-- end table -->
		</xsl:element>
		<!-- end sheet -->
	</xsl:template>

	<xsl:template name="extractExtensionsParameter">
		<!-- start parameter -->
		<xsl:param name="pContent" />
		<!-- end parameter -->
		<!-- start declarations -->
		<xsl:variable name="sWorksheetName">extensions parameter</xsl:variable>
		<xsl:variable name="sTitleID1">name</xsl:variable>
		<xsl:variable name="sTitleID2">libraryName</xsl:variable>
		<xsl:variable name="sTitleID3">internal</xsl:variable>
		<xsl:variable name="sTitleID4">cannedExtension</xsl:variable>
		<xsl:variable name="sTitleID5">languageType</xsl:variable>
		<xsl:variable name="sTitleID6">description</xsl:variable>
		<xsl:variable name="sTitleID7">parameter</xsl:variable>
		<!-- end declarations -->
		<xsl:element name="Worksheet">
			<!-- sheet name -->
			<xsl:attribute name="ss:Name">
			    <xsl:value-of select="$sWorksheetName" />
			</xsl:attribute>
			<!-- start table -->
			<xsl:element name="Table">
				<!-- start column definition -->
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<!-- end column definition -->
				<!-- start header line -->
				<xsl:element name="Row">
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID1" />
						<xsl:with-param name="pContent" select="$sTitleID1" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID2" />
						<xsl:with-param name="pContent" select="$sTitleID2" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID3" />
						<xsl:with-param name="pContent" select="$sTitleID3" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID4" />
						<xsl:with-param name="pContent" select="$sTitleID4" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID5" />
						<xsl:with-param name="pContent" select="$sTitleID5" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID6" />
						<xsl:with-param name="pContent" select="$sTitleID6" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID7" />
						<xsl:with-param name="pContent" select="$sTitleID7" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
				</xsl:element>
				<!-- end header line -->
				<!-- start extract content-->
				<xsl:for-each
					select="//child::*/child::*[local-name() = 'TcExtension']/child::*[local-name() = 'TcExtensionParameter']">
					<xsl:sort select="parent::*/@name" />
					<xsl:element name="Row">
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID1" />
							<xsl:with-param name="pContent" select="parent::*/@name" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID2" />
							<xsl:with-param name="pContent" select="parent::*/@libraryName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID3" />
							<xsl:with-param name="pContent" select="parent::*/@internal" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID4" />
							<xsl:with-param name="pContent" select="parent::*/@cannedExtension" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID5" />
							<xsl:with-param name="pContent" select="parent::*/@languageType" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID6" />
							<xsl:with-param name="pContent" select="parent::*/@description" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID7" />
							<xsl:with-param name="pContent" select="@parameter" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
					</xsl:element>
				</xsl:for-each>
				<!-- end extract content-->
			</xsl:element>
			<!-- end table -->
		</xsl:element>
		<!-- end sheet -->
	</xsl:template>

	<xsl:template name="extractTools">
		<!-- start parameter -->
		<xsl:param name="pContent" />
		<!-- end parameter -->
		<!-- start declarations -->
		<xsl:variable name="sWorksheetName">tools</xsl:variable>
		<xsl:variable name="sTitleID1">name</xsl:variable>
		<xsl:variable name="sTitleID2">mime type</xsl:variable>
		<xsl:variable name="sTitleID3">symbol</xsl:variable>
		<xsl:variable name="sTitleID4">input</xsl:variable>
		<xsl:variable name="sTitleID5">output</xsl:variable>
		<xsl:variable name="sTitleID6">version</xsl:variable>
		<xsl:variable name="sTitleID7">vendor</xsl:variable>

		<!-- end declarations -->
		<xsl:element name="Worksheet">
			<!-- sheet name -->
	    <xsl:attribute name="ss:Name">
	    	<xsl:value-of select="$sWorksheetName" />
		</xsl:attribute>
			<!-- start table -->
			<xsl:element name="Table">
				<!-- start column definition -->
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<!-- end column definition -->
				<!-- start header line -->
				<xsl:element name="Row">
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID1" />
						<xsl:with-param name="pContent" select="$sTitleID1" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID2" />
						<xsl:with-param name="pContent" select="$sTitleID2" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID3" />
						<xsl:with-param name="pContent" select="$sTitleID3" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID4" />
						<xsl:with-param name="pContent" select="$sTitleID4" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID5" />
						<xsl:with-param name="pContent" select="$sTitleID5" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID6" />
						<xsl:with-param name="pContent" select="$sTitleID6" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID7" />
						<xsl:with-param name="pContent" select="$sTitleID7" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
				</xsl:element>
				<!-- end header line -->
				<!-- start extract content-->
				<xsl:for-each select="//child::*/child::*[local-name() = 'TcTool']">
					<xsl:sort select="@toolName" />
					<xsl:element name="Row">
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID1" />
							<xsl:with-param name="pContent" select="@toolName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID2" />
							<xsl:with-param name="pContent" select="@toolMimeType" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID3" />
							<xsl:with-param name="pContent" select="@toolSymbol" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID4" />
							<xsl:with-param name="pContent"
								select="child::*[local-name() = 'TcToolInputFormat']/@formatName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID5" />
							<xsl:with-param name="pContent"
								select="child::*[local-name() = 'TcToolOutputFormat']/@formatName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID6" />
							<xsl:with-param name="pContent" select="@toolVersion" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID7" />
							<xsl:with-param name="pContent" select="@toolVendorName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
					</xsl:element>
				</xsl:for-each>
				<!-- end extract content-->
			</xsl:element>
			<!-- end table -->
		</xsl:element>
		<!-- end sheet -->
	</xsl:template>

	<xsl:template name="extractDatasetActions">
		<!-- start parameter -->
		<xsl:param name="pContent" />
		<!-- end parameter -->
		<!-- start declarations -->
		<xsl:variable name="sWorksheetName">dataset actions</xsl:variable>
		<xsl:variable name="sTitleID1">dataset</xsl:variable>
		<xsl:variable name="sTitleID2">action</xsl:variable>
		<xsl:variable name="sTitleID3">tool</xsl:variable>
		<xsl:variable name="sTitleID4">reference name</xsl:variable>
		<xsl:variable name="sTitleID5">parameter</xsl:variable>
		<xsl:variable name="sTitleID6">export</xsl:variable>
		<!-- end declarations -->
		<xsl:element name="Worksheet">
			<!-- sheet name -->
			<xsl:attribute name="ss:Name">
						<xsl:value-of select="$sWorksheetName" />
					</xsl:attribute>
			<!-- start table -->
			<xsl:element name="Table">
				<!-- start column definition -->
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<!-- end column definition -->
				<!-- start header line -->
				<xsl:element name="Row">
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID1" />
						<xsl:with-param name="pContent" select="$sTitleID1" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID2" />
						<xsl:with-param name="pContent" select="$sTitleID2" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID3" />
						<xsl:with-param name="pContent" select="$sTitleID3" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID4" />
						<xsl:with-param name="pContent" select="$sTitleID4" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID5" />
						<xsl:with-param name="pContent" select="$sTitleID5" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID6" />
						<xsl:with-param name="pContent" select="$sTitleID6" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
				</xsl:element>
				<!-- end header line -->
				<!-- start extract content-->
				<xsl:for-each
					select="//child::*/child::*[local-name() = 'TcDataset']/child::*[local-name() = 'TcDatasetToolAction']">
					<xsl:sort select="parent::*/@typeName" />
					<xsl:sort select="@action" />
					<xsl:sort select="@tool" />
					<xsl:element name="Row">
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID1" />
							<xsl:with-param name="pContent" select="parent::*/@typeName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID2" />
							<xsl:with-param name="pContent" select="@action" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID3" />
							<xsl:with-param name="pContent" select="@tool" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID4" />
							<xsl:with-param name="pContent"
								select="child::*[local-name() = 'TcToolActionReference']/@referenceName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID5" />
							<xsl:with-param name="pContent"
								select="child::*[local-name() = 'TcToolParameter']/@name" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID6" />
							<xsl:with-param name="pContent"
								select="child::*[local-name() = 'TcToolActionReference']/@export" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID7" />
							<xsl:with-param name="pContent" select="@toolVendorName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
					</xsl:element>
				</xsl:for-each>
				<!-- end extract content-->
			</xsl:element>
			<!-- end table -->
		</xsl:element>
		<!-- end sheet -->
	</xsl:template>

	<xsl:template name="extractClassicChanges">
		<!-- start parameter -->
		<xsl:param name="pContent" />
		<!-- end parameter -->
		<!-- start declarations -->
		<xsl:variable name="sWorksheetName">classic change</xsl:variable>
		<xsl:variable name="sTitleID1">change</xsl:variable>
		<xsl:variable name="sTitleID2">description</xsl:variable>
		<xsl:variable name="sTitleID3">assignment type</xsl:variable>
		<xsl:variable name="sTitleID4">assignment value</xsl:variable>
		<xsl:variable name="sTitleID5">range</xsl:variable>
		<xsl:variable name="sTitleID6">value</xsl:variable>
		<!-- end declarations -->
		<xsl:element name="Worksheet">
			<!-- sheet name -->
			<xsl:attribute name="ss:Name">
						<xsl:value-of select="$sWorksheetName" />
					</xsl:attribute>
			<!-- start table -->
			<xsl:element name="Table">
				<!-- start column definition -->
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<!-- end column definition -->
				<!-- start header line -->
				<xsl:element name="Row">
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID1" />
						<xsl:with-param name="pContent" select="$sTitleID1" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID2" />
						<xsl:with-param name="pContent" select="$sTitleID2" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID3" />
						<xsl:with-param name="pContent" select="$sTitleID3" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID4" />
						<xsl:with-param name="pContent" select="$sTitleID4" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID5" />
						<xsl:with-param name="pContent" select="$sTitleID5" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID6" />
						<xsl:with-param name="pContent" select="$sTitleID6" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
				</xsl:element>
				<!-- end header line -->
                <!-- start extract content-->
				<xsl:for-each select="//child::*/child::*[local-name() = 'TcChange']">
					<xsl:sort select="@changeName" />
					<xsl:element name="Row">
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID1" />
							<xsl:with-param name="pContent" select="@changeName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID2" />
							<xsl:with-param name="pContent" select="@description" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID3" />
							<xsl:with-param name="pContent">shared effectivity</xsl:with-param>
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID4" />
							<xsl:with-param name="pContent" select="@isEffectivityShared" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID5" />
							<xsl:with-param name="pContent">na</xsl:with-param>
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID6" />
							<xsl:with-param name="pContent">na</xsl:with-param>
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
					</xsl:element>
					<!-- start extract forms-->
					<xsl:for-each select="child::*[local-name() = 'TcChangeForm']">
						<xsl:sort select="parent::*/@typeName" />
						<xsl:sort select="@name" />
						<xsl:element name="Row">
							<xsl:call-template name="generateTableCell">
								<xsl:with-param name="pColumn" select="$sColID1" />
								<xsl:with-param name="pContent" select="parent::*/@changeName" />
								<xsl:with-param name="pDataType" select="$sDataType" />
							</xsl:call-template>
							<xsl:call-template name="generateTableCell">
								<xsl:with-param name="pColumn" select="$sColID2" />
								<xsl:with-param name="pContent" select="parent::*/@description" />
								<xsl:with-param name="pDataType" select="$sDataType" />
							</xsl:call-template>
							<xsl:call-template name="generateTableCell">
								<xsl:with-param name="pColumn" select="$sColID3" />
								<xsl:with-param name="pContent">Form</xsl:with-param>
								<xsl:with-param name="pDataType" select="$sDataType" />
							</xsl:call-template>
							<xsl:call-template name="generateTableCell">
								<xsl:with-param name="pColumn" select="$sColID4" />
								<xsl:with-param name="pContent" select="@formTypeName" />
								<xsl:with-param name="pDataType" select="$sDataType" />
							</xsl:call-template>
							<xsl:call-template name="generateTableCell">
								<xsl:with-param name="pColumn" select="$sColID5" />
								<xsl:with-param name="pContent">na</xsl:with-param>
								<xsl:with-param name="pDataType" select="$sDataType" />
							</xsl:call-template>
							<xsl:call-template name="generateTableCell">
								<xsl:with-param name="pColumn" select="$sColID6" />
								<xsl:with-param name="pContent">na</xsl:with-param>
								<xsl:with-param name="pDataType" select="$sDataType" />
							</xsl:call-template>
						</xsl:element>
					</xsl:for-each>
					<!-- end extract forms-->
					<!-- start extract processes-->
					<xsl:for-each select="child::*[local-name() = 'TcChangeProcessTemplate']">
						<xsl:sort select="parent::*/@typeName" />
						<xsl:sort select="@name" />
						<xsl:element name="Row">
							<xsl:call-template name="generateTableCell">
								<xsl:with-param name="pColumn" select="$sColID1" />
								<xsl:with-param name="pContent" select="parent::*/@changeName" />
								<xsl:with-param name="pDataType" select="$sDataType" />
							</xsl:call-template>
							<xsl:call-template name="generateTableCell">
								<xsl:with-param name="pColumn" select="$sColID2" />
								<xsl:with-param name="pContent" select="parent::*/@description" />
								<xsl:with-param name="pDataType" select="$sDataType" />
							</xsl:call-template>
							<xsl:call-template name="generateTableCell">
								<xsl:with-param name="pColumn" select="$sColID3" />
								<xsl:with-param name="pContent">Process</xsl:with-param>
								<xsl:with-param name="pDataType" select="$sDataType" />
							</xsl:call-template>
							<xsl:call-template name="generateTableCell">
								<xsl:with-param name="pColumn" select="$sColID4" />
								<xsl:with-param name="pContent" select="@processTemplateName" />
								<xsl:with-param name="pDataType" select="$sDataType" />
							</xsl:call-template>
							<xsl:call-template name="generateTableCell">
								<xsl:with-param name="pColumn" select="$sColID5" />
								<xsl:with-param name="pContent">na</xsl:with-param>
								<xsl:with-param name="pDataType" select="$sDataType" />
							</xsl:call-template>
							<xsl:call-template name="generateTableCell">
								<xsl:with-param name="pColumn" select="$sColID6" />
								<xsl:with-param name="pContent">na</xsl:with-param>
								<xsl:with-param name="pDataType" select="$sDataType" />
							</xsl:call-template>
						</xsl:element>
					</xsl:for-each>
					<!-- end extract processes-->
					<!-- start extract item id naming rules-->
					<xsl:for-each select="child::*[local-name() = 'TcChangeIdFormat']">
						<xsl:sort select="parent::*/@typeName" />
						<xsl:element name="Row">
							<xsl:call-template name="generateTableCell">
								<xsl:with-param name="pColumn" select="$sColID1" />
								<xsl:with-param name="pContent" select="parent::*/@changeName" />
								<xsl:with-param name="pDataType" select="$sDataType" />
							</xsl:call-template>
							<xsl:call-template name="generateTableCell">
								<xsl:with-param name="pColumn" select="$sColID2" />
								<xsl:with-param name="pContent" select="parent::*/@description" />
								<xsl:with-param name="pDataType" select="$sDataType" />
							</xsl:call-template>
							<xsl:call-template name="generateTableCell">
								<xsl:with-param name="pColumn" select="$sColID3" />
								<xsl:with-param name="pContent">ID Format</xsl:with-param>
								<xsl:with-param name="pDataType" select="$sDataType" />
							</xsl:call-template>
							<xsl:call-template name="generateTableCell">
								<xsl:with-param name="pColumn" select="$sColID4" />
								<xsl:with-param name="pContent" select="@formatElementType" />
								<xsl:with-param name="pDataType" select="$sDataType" />
							</xsl:call-template>
							<xsl:call-template name="generateTableCell">
								<xsl:with-param name="pColumn" select="$sColID5" />
								<xsl:with-param name="pContent" select="@formatElementRange" />
								<xsl:with-param name="pDataType" select="$sDataType" />
							</xsl:call-template>
							<xsl:call-template name="generateTableCell">
								<xsl:with-param name="pColumn" select="$sColID6" />
								<xsl:with-param name="pContent" select="@formatElementValue" />
								<xsl:with-param name="pDataType" select="$sDataType" />
							</xsl:call-template>
						</xsl:element>
					</xsl:for-each>
					<!-- end extract item id naming rules-->
					<!-- start extract item id naming rules-->
					<xsl:for-each select="child::*[local-name() = 'TcChangeRevIdFormat']">
						<xsl:sort select="parent::*/@typeName" />
						<xsl:element name="Row">
							<xsl:call-template name="generateTableCell">
								<xsl:with-param name="pColumn" select="$sColID1" />
								<xsl:with-param name="pContent" select="parent::*/@changeName" />
								<xsl:with-param name="pDataType" select="$sDataType" />
							</xsl:call-template>
							<xsl:call-template name="generateTableCell">
								<xsl:with-param name="pColumn" select="$sColID2" />
								<xsl:with-param name="pContent" select="parent::*/@description" />
								<xsl:with-param name="pDataType" select="$sDataType" />
							</xsl:call-template>
							<xsl:call-template name="generateTableCell">
								<xsl:with-param name="pColumn" select="$sColID3" />
								<xsl:with-param name="pContent">Rev ID Format</xsl:with-param>
								<xsl:with-param name="pDataType" select="$sDataType" />
							</xsl:call-template>
							<xsl:call-template name="generateTableCell">
								<xsl:with-param name="pColumn" select="$sColID4" />
								<xsl:with-param name="pContent" select="@formatElementType" />
								<xsl:with-param name="pDataType" select="$sDataType" />
							</xsl:call-template>
							<xsl:call-template name="generateTableCell">
								<xsl:with-param name="pColumn" select="$sColID5" />
								<xsl:with-param name="pContent" select="@formatElementRange" />
								<xsl:with-param name="pDataType" select="$sDataType" />
							</xsl:call-template>
							<xsl:call-template name="generateTableCell">
								<xsl:with-param name="pColumn" select="$sColID6" />
								<xsl:with-param name="pContent" select="@formatElementValue" />
								<xsl:with-param name="pDataType" select="$sDataType" />
							</xsl:call-template>
						</xsl:element>
					</xsl:for-each>
					<!-- end extract item id naming rules-->
				</xsl:for-each>
				<!-- end extract content-->
			</xsl:element>
			<!-- end table -->
		</xsl:element>
		<!-- end sheet -->
	</xsl:template>
	<xsl:template name="extractToolAssignments">
		<!-- start parameter -->
		<xsl:param name="pContent" />
		<!-- end parameter -->
		<!-- start declarations -->
		<xsl:variable name="sWorksheetName">tool assigments</xsl:variable>
		<xsl:variable name="sTitleID1">dataset</xsl:variable>
		<xsl:variable name="sTitleID2">tool</xsl:variable>
		<xsl:variable name="sTitleID3">usage</xsl:variable>
		<!-- end declarations -->
		<xsl:element name="Worksheet">
			<!-- sheet name -->
			<xsl:attribute name="ss:Name">
						<xsl:value-of select="$sWorksheetName" />
					</xsl:attribute>
			<!-- start table -->
			<xsl:element name="Table">
				<!-- start column definition -->
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<!-- end column definition -->
				<!-- start header line -->
				<xsl:element name="Row">
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID1" />
						<xsl:with-param name="pContent" select="$sTitleID1" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID2" />
						<xsl:with-param name="pContent" select="$sTitleID2" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID3" />
						<xsl:with-param name="pContent" select="$sTitleID3" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
				</xsl:element>
				<!-- end header line -->
				<!-- start extract content view -->
				<xsl:for-each
					select="//child::*/child::*[local-name() = 'TcDataset']/child::*[local-name() = 'TcDSViewTool']">
					<xsl:sort select="parent::*/@typeName" />
					<xsl:sort select="@name" />

					<xsl:element name="Row">
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID1" />
							<xsl:with-param name="pContent" select="parent::*/@typeName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID2" />
							<xsl:with-param name="pContent" select="@name" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID3" />
							<xsl:with-param name="pContent">view</xsl:with-param>
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
					</xsl:element>
				</xsl:for-each>
				<xsl:for-each
					select="//child::*/child::*[local-name() = 'TcDataset']/child::*[local-name() = 'TcDSEditTool']">
					<xsl:sort select="parent::*/@typeName" />
					<xsl:sort select="@name" />
					<xsl:element name="Row">
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID1" />
							<xsl:with-param name="pContent" select="parent::*/@typeName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID2" />
							<xsl:with-param name="pContent" select="@name" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID3" />
							<xsl:with-param name="pContent">edit</xsl:with-param>
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
					</xsl:element>
				</xsl:for-each>
				<!-- end extract content-->
			</xsl:element>
			<!-- end table -->
		</xsl:element>
		<!-- end sheet -->
	</xsl:template>

	<xsl:template name="extractToolUsage">
		<!-- start parameter -->
		<xsl:param name="pContent" />
		<!-- end parameter -->
		<!-- start declarations -->
		<xsl:variable name="sWorksheetName">tool usage</xsl:variable>
		<xsl:variable name="sTitleID1">dataset name</xsl:variable>
		<xsl:variable name="sTitleID2">mime type</xsl:variable>
		<xsl:variable name="sTitleID3">symbol</xsl:variable>
		<xsl:variable name="sTitleID4">input</xsl:variable>
		<xsl:variable name="sTitleID5">output</xsl:variable>
		<xsl:variable name="sTitleID6">version</xsl:variable>
		<xsl:variable name="sTitleID7">vendor</xsl:variable>
		<!-- end declarations -->
		<xsl:element name="Worksheet">
			<!-- sheet name -->
			<xsl:attribute name="ss:Name">
						<xsl:value-of select="$sWorksheetName" />
					</xsl:attribute>
			<!-- start table -->
			<xsl:element name="Table">
				<!-- start column definition -->
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<!-- end column definition -->
				<!-- start header line -->
				<xsl:element name="Row">
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID1" />
						<xsl:with-param name="pContent" select="$sTitleID1" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID2" />
						<xsl:with-param name="pContent" select="$sTitleID2" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID3" />
						<xsl:with-param name="pContent" select="$sTitleID3" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID4" />
						<xsl:with-param name="pContent" select="$sTitleID4" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID5" />
						<xsl:with-param name="pContent" select="$sTitleID5" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID6" />
						<xsl:with-param name="pContent" select="$sTitleID6" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID7" />
						<xsl:with-param name="pContent" select="$sTitleID7" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
				</xsl:element>
				<!-- end header line -->
				<!-- start extract content-->
				<xsl:for-each select="//child::*/child::*[local-name() = 'TcTool']">
					<xsl:sort select="@toolName" />
					<xsl:element name="Row">
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID1" />
							<xsl:with-param name="pContent" select="@toolName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID2" />
							<xsl:with-param name="pContent" select="@toolMimeType" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID3" />
							<xsl:with-param name="pContent" select="@toolSymbol" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID4" />
							<xsl:with-param name="pContent"
								select="child::*[local-name() = 'TcToolInputFormat']/@formatName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID5" />
							<xsl:with-param name="pContent"
								select="child::*[local-name() = 'TcToolOutputFormat']/@formatName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID6" />
							<xsl:with-param name="pContent" select="@toolVersion" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID7" />
							<xsl:with-param name="pContent" select="@toolVendorName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
					</xsl:element>
				</xsl:for-each>
				<!-- end extract content-->
			</xsl:element>
			<!-- end table -->
		</xsl:element>
		<!-- end sheet -->
	</xsl:template>

	<xsl:template name="extractExtensionsAttach">
		<!-- start parameter -->
		<xsl:param name="pContent" />
		<!-- end parameter -->
		<!-- start declarations -->
		<xsl:variable name="sWorksheetName">extensions attaches</xsl:variable>
		<xsl:variable name="sTitleID1">extensionName</xsl:variable>
		<xsl:variable name="sTitleID2">operationName</xsl:variable>
		<xsl:variable name="sTitleID3">extensionPointType</xsl:variable>
		<xsl:variable name="sTitleID4">extendableElementName</xsl:variable>
		<xsl:variable name="sTitleID5">extendableElementType</xsl:variable>
		<xsl:variable name="sTitleID6">isActive</xsl:variable>
		<xsl:variable name="sTitleID7">arguments</xsl:variable>
		<!-- end declarations -->
		<xsl:element name="Worksheet">
			<!-- sheet name -->
			<xsl:attribute name="ss:Name">
						<xsl:value-of select="$sWorksheetName" />
					</xsl:attribute>
			<!-- start table -->
			<xsl:element name="Table">
				<!-- start column definition -->
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<!-- end column definition -->
				<!-- start header line -->
				<xsl:element name="Row">
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID1" />
						<xsl:with-param name="pContent" select="$sTitleID1" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID2" />
						<xsl:with-param name="pContent" select="$sTitleID2" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID3" />
						<xsl:with-param name="pContent" select="$sTitleID3" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID4" />
						<xsl:with-param name="pContent" select="$sTitleID4" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID5" />
						<xsl:with-param name="pContent" select="$sTitleID5" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID6" />
						<xsl:with-param name="pContent" select="$sTitleID6" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID7" />
						<xsl:with-param name="pContent" select="$sTitleID7" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
				</xsl:element>
				<!-- end header line -->
				<!-- start extract content-->
				<xsl:for-each
					select="//child::*/child::*[local-name() = 'TcExtensionAttach']">
					<xsl:sort select="@extensionName" />
					<xsl:element name="Row">
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID1" />
							<xsl:with-param name="pContent" select="@extensionName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID2" />
							<xsl:with-param name="pContent" select="@operationName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID3" />
							<xsl:with-param name="pContent" select="@extensionPointType" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID4" />
							<xsl:with-param name="pContent" select="@extendableElementName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID5" />
							<xsl:with-param name="pContent" select="@extendableElementType" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID6" />
							<xsl:with-param name="pContent" select="@isActive" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID7" />
							<xsl:with-param name="pContent"
								select="child::*[local-name() = 'TcExtensionArguments']/@parameter" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
					</xsl:element>
				</xsl:for-each>
				<!-- end extract content-->
			</xsl:element>
			<!-- end table -->
		</xsl:element>
		<!-- end sheet -->
	</xsl:template>

	<xsl:template name="extractDeepCopyRules">
		<!-- start parameter -->
		<xsl:param name="pContent" />
		<!-- end parameter -->
		<!-- start declarations -->
		<xsl:variable name="sWorksheetName">deep copy rules</xsl:variable>
		<xsl:variable name="sTitleID1">typeName</xsl:variable>
		<xsl:variable name="sTitleID2">relationTypeName</xsl:variable>
		<xsl:variable name="sTitleID3">objectTypeName</xsl:variable>
		<xsl:variable name="sTitleID4">operationName</xsl:variable>
		<xsl:variable name="sTitleID5">copyType</xsl:variable>
		<xsl:variable name="sTitleID6">isRequired</xsl:variable>
		<!-- end declarations -->
		<xsl:element name="Worksheet">
			<!-- sheet name -->
			<xsl:attribute name="ss:Name">
						<xsl:value-of select="$sWorksheetName" />
					</xsl:attribute>
			<!-- start table -->
			<xsl:element name="Table">
				<!-- start column definition -->
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<!-- end column definition -->
				<!-- start header line -->
				<xsl:element name="Row">
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID1" />
						<xsl:with-param name="pContent" select="$sTitleID1" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID2" />
						<xsl:with-param name="pContent" select="$sTitleID2" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID3" />
						<xsl:with-param name="pContent" select="$sTitleID3" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID4" />
						<xsl:with-param name="pContent" select="$sTitleID4" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID5" />
						<xsl:with-param name="pContent" select="$sTitleID5" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID6" />
						<xsl:with-param name="pContent" select="$sTitleID6" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
				</xsl:element>
				<!-- end header line -->
				<!-- start extract content-->
				<xsl:for-each select="//child::*/child::*[local-name() = 'TcDeepCopyRule']">
					<xsl:sort select="@typeName" />
					<xsl:sort select="@operationName" />
					<xsl:element name="Row">
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID1" />
							<xsl:with-param name="pContent" select="@typeName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID2" />
							<xsl:with-param name="pContent" select="@relationTypeName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID3" />
							<xsl:with-param name="pContent" select="@objectTypeName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID4" />
							<xsl:with-param name="pContent" select="@operationName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID5" />
							<xsl:with-param name="pContent" select="@copyType" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID6" />
							<xsl:with-param name="pContent" select="@isRequired" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
					</xsl:element>
				</xsl:for-each>
				<!-- end extract content-->
			</xsl:element>
			<!-- end table -->
		</xsl:element>
		<!-- end sheet -->
	</xsl:template>

	<xsl:template name="extractPropertyRules">
		<!-- start parameter -->
		<xsl:param name="pContent" />
		<!-- end parameter -->
		<!-- start declarations -->
		<xsl:variable name="sWorksheetName">property rules</xsl:variable>
		<xsl:variable name="sTitleID1">typename</xsl:variable>
		<xsl:variable name="sTitleID2">required</xsl:variable>
		<xsl:variable name="sTitleID3">enabled</xsl:variable>
		<xsl:variable name="sTitleID4">visible</xsl:variable>
		<xsl:variable name="sTitleID5">inital value</xsl:variable>
		<xsl:variable name="sTitleID6">modifiable</xsl:variable>
		<xsl:variable name="sTitleID7">combination property</xsl:variable>
		<!-- end declarations -->
		<xsl:element name="Worksheet">
			<!-- sheet name -->
			<xsl:attribute name="ss:Name">
						<xsl:value-of select="$sWorksheetName" />
					</xsl:attribute>
			<!-- start table -->
			<xsl:element name="Table">
				<!-- start column definition -->
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<!-- end column definition -->
				<!-- start header line -->
				<xsl:element name="Row">
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID1" />
						<xsl:with-param name="pContent" select="$sTitleID1" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID2" />
						<xsl:with-param name="pContent" select="$sTitleID2" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID3" />
						<xsl:with-param name="pContent" select="$sTitleID3" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID4" />
						<xsl:with-param name="pContent" select="$sTitleID4" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID5" />
						<xsl:with-param name="pContent" select="$sTitleID5" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID6" />
						<xsl:with-param name="pContent" select="$sTitleID6" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID7" />
						<xsl:with-param name="pContent" select="$sTitleID7" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
				</xsl:element>
				<!-- end header line -->
				<!-- start extract content-->
				<xsl:for-each select="//child::*/child::*[local-name() = 'TcPropertyRule']">
					<xsl:sort select="@typeName" />
					<xsl:sort select="@propertyName" />
					<xsl:element name="Row">
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID1" />
							<xsl:with-param name="pContent" select="@typeName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID2" />
							<xsl:with-param name="pContent" select="@propertyName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID3" />
							<xsl:with-param name="pContent" select="@isRequired" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID4" />
							<xsl:with-param name="pContent" select="@isEnabled" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID5" />
							<xsl:with-param name="pContent" select="@isVisible" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID6" />
							<xsl:with-param name="pContent" select="@isModifiable" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID7" />
							<xsl:with-param name="pContent" select="@combinationProperty" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
					</xsl:element>
				</xsl:for-each>
				<!-- end extract content-->
			</xsl:element>
			<!-- end table -->
		</xsl:element>
		<!-- end sheet -->
	</xsl:template>

	<xsl:template name="extractPropertyConstants">
		<!-- start parameter -->
		<xsl:param name="pContent" />
		<!-- end parameter -->
		<!-- start declarations -->
		<xsl:variable name="sWorksheetName">property constants</xsl:variable>
		<xsl:variable name="sTitleID1">typename</xsl:variable>
		<xsl:variable name="sTitleID2">property name</xsl:variable>
		<xsl:variable name="sTitleID3">constant name</xsl:variable>
		<xsl:variable name="sTitleID4">constant value</xsl:variable>
		<!-- end declarations -->
		<xsl:element name="Worksheet">
			<!-- sheet name -->
			<xsl:attribute name="ss:Name">
						<xsl:value-of select="$sWorksheetName" />
					</xsl:attribute>
			<!-- start table -->
			<xsl:element name="Table">
				<!-- start column definition -->
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<!-- end column definition -->
				<!-- start header line -->
				<xsl:element name="Row">
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID1" />
						<xsl:with-param name="pContent" select="$sTitleID1" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID2" />
						<xsl:with-param name="pContent" select="$sTitleID2" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID3" />
						<xsl:with-param name="pContent" select="$sTitleID3" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID4" />
						<xsl:with-param name="pContent" select="$sTitleID4" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
				</xsl:element>
				<!-- end header line -->
				<!-- start extract content-->
				<xsl:for-each
					select="//child::*/child::*[local-name() = 'TcPropertyConstantAttach']">
					<xsl:sort select="@typeName" />
					<xsl:sort select="@propertyName" />
					<xsl:element name="Row">
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID1" />
							<xsl:with-param name="pContent" select="@typeName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID2" />
							<xsl:with-param name="pContent" select="@propertyName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID3" />
							<xsl:with-param name="pContent" select="@constantName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID4" />
							<xsl:with-param name="pContent" select="@value" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
					</xsl:element>
				</xsl:for-each>
				<!-- end extract content-->
			</xsl:element>
			<!-- end table -->
		</xsl:element>
		<!-- end sheet -->
	</xsl:template>

	<xsl:template name="extractLOVValues">
		<!-- start parameter -->
		<xsl:param name="pContent" />
		<!-- end parameter -->
		<!-- start declarations -->
		<xsl:variable name="sWorksheetName">lov values</xsl:variable>
		<xsl:variable name="sTitleID1">lov name</xsl:variable>
		<xsl:variable name="sTitleID2">value</xsl:variable>
		<xsl:variable name="sTitleID3">description</xsl:variable>
		<xsl:variable name="sTitleID4">conditionName</xsl:variable>
		<!-- end declarations -->
		<xsl:element name="Worksheet">
			<!-- sheet name -->
			<xsl:attribute name="ss:Name">
						<xsl:value-of select="$sWorksheetName" />
					</xsl:attribute>
			<!-- start table -->
			<xsl:element name="Table">
				<!-- start column definition -->
				<!-- typeName -->
				<xsl:call-template name="setupColumn" />
				<!-- parentTypeName -->
				<xsl:call-template name="setupColumn" />
				<!-- storage class name -->
				<xsl:call-template name="setupColumn" />
				<!-- end column definition -->
				<!-- start header line -->
				<xsl:element name="Row">
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID1" />
						<xsl:with-param name="pContent" select="$sTitleID1" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID2" />
						<xsl:with-param name="pContent" select="$sTitleID2" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID3" />
						<xsl:with-param name="pContent" select="$sTitleID3" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID4" />
						<xsl:with-param name="pContent" select="$sTitleID4" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
				</xsl:element>
				<!-- end header line -->
				<!-- start extract content -->
				<xsl:for-each
					select="//child::*/child::*[local-name() = 'TcLOV']/child::*[local-name() = 'TcLOVValue']">
					<xsl:sort select="parent::*/@name" />
					<xsl:sort select="@value" />
					<xsl:element name="Row">
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID1" />
							<xsl:with-param name="pContent" select="parent::*/@name" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID2" />
							<xsl:with-param name="pContent" select="@value" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID3" />
							<xsl:with-param name="pContent" select="@description" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID4" />
							<xsl:with-param name="pContent" select="@conditionName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
					</xsl:element>
				</xsl:for-each>
				<!-- start extract content-->
			</xsl:element>
			<!-- end table -->
		</xsl:element>
		<!-- end sheet -->
	</xsl:template>

	<xsl:template name="extractLOVs">
		<!-- start parameter -->
		<xsl:param name="pContent" />
		<!-- end parameter -->
		<!-- start declarations -->
		<xsl:variable name="sWorksheetName">lov</xsl:variable>
		<xsl:variable name="sTitleID1">name</xsl:variable>
		<xsl:variable name="sTitleID2">description</xsl:variable>
		<xsl:variable name="sTitleID3">lovType</xsl:variable>
		<xsl:variable name="sTitleID4">usage</xsl:variable>
		<!-- end declarations -->
		<xsl:element name="Worksheet">
			<!-- sheet name -->
			<xsl:attribute name="ss:Name">
						<xsl:value-of select="$sWorksheetName" />
					</xsl:attribute>
			<!-- start table -->
			<xsl:element name="Table">
				<!-- start column definition -->
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<!-- end column definition -->
				<!-- start header line -->
				<xsl:element name="Row">
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID1" />
						<xsl:with-param name="pContent" select="$sTitleID1" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID2" />
						<xsl:with-param name="pContent" select="$sTitleID2" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID3" />
						<xsl:with-param name="pContent" select="$sTitleID3" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID4" />
						<xsl:with-param name="pContent" select="$sTitleID4" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
				</xsl:element>
				<!-- end header line -->
				<!-- start extract content-->
				<xsl:for-each select="//child::*/child::*[local-name() = 'TcLOV']">
					<xsl:sort select="@name" />
					<xsl:element name="Row">
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID1" />
							<xsl:with-param name="pContent" select="@name" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID2" />
							<xsl:with-param name="pContent" select="@description" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID3" />
							<xsl:with-param name="pContent" select="@lovType" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID4" />
							<xsl:with-param name="pContent" select="@usage" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
					</xsl:element>
				</xsl:for-each>
				<!-- end extract content-->
			</xsl:element>
			<!-- end table -->
		</xsl:element>
		<!-- end sheet -->
	</xsl:template>

	<xsl:template name="extractReleaseStatus">
		<!-- start parameter -->
		<xsl:param name="pContent" />
		<!-- end parameter -->
		<!-- start declarations -->
		<xsl:variable name="sWorksheetName">release status</xsl:variable>
		<xsl:variable name="sTitleID1">name</xsl:variable>
		<xsl:variable name="sTitleID2">description</xsl:variable>
		<!-- end declarations -->
		<xsl:element name="Worksheet">
			<!-- sheet name -->
			<xsl:attribute name="ss:Name">
						<xsl:value-of select="$sWorksheetName" />
					</xsl:attribute>
			<!-- start table -->
			<xsl:element name="Table">
				<!-- start column definition -->
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<!-- end column definition -->
				<!-- start header line -->
				<xsl:element name="Row">
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID1" />
						<xsl:with-param name="pContent" select="$sTitleID1" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID2" />
						<xsl:with-param name="pContent" select="$sTitleID2" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
				</xsl:element>
				<!-- end header line -->
				<!-- start extract content-->
				<xsl:for-each select="//child::*/child::*[local-name() = 'TcStatus']">
					<xsl:sort select="@statusName" />
					<xsl:element name="Row">
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID1" />
							<xsl:with-param name="pContent" select="@statusName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID2" />
							<xsl:with-param name="pContent" select="@description" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
					</xsl:element>
				</xsl:for-each>
				<!-- end extract content-->
			</xsl:element>
			<!-- end table -->
		</xsl:element>
		<!-- end sheet -->
	</xsl:template>
	
	<xsl:template name="extractConditions">
		<!-- start parameter -->
		<xsl:param name="pContent" />
		<!-- end parameter -->
		<!-- start declarations -->
		<xsl:variable name="sWorksheetName">conditions</xsl:variable>
		<xsl:variable name="sTitleID1">name</xsl:variable>
		<xsl:variable name="sTitleID2">description</xsl:variable>
		<xsl:variable name="sTitleID3">expression</xsl:variable>
		<!-- end declarations -->
		<xsl:element name="Worksheet">
			<!-- sheet name -->
			<xsl:attribute name="ss:Name">
						<xsl:value-of select="$sWorksheetName" />
					</xsl:attribute>
			<!-- start table -->
			<xsl:element name="Table">
				<!-- start column definition -->
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<!-- end column definition -->
				<!-- start header line -->
				<xsl:element name="Row">
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID1" />
						<xsl:with-param name="pContent" select="$sTitleID1" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID2" />
						<xsl:with-param name="pContent" select="$sTitleID2" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID3" />
						<xsl:with-param name="pContent" select="$sTitleID3" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
				</xsl:element>
				<!-- end header line -->
				<!-- start extract content-->
				<xsl:for-each select="//child::*/child::*[local-name() = 'Condition']">
					<xsl:sort select="@name" />
					<xsl:element name="Row">
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID1" />
							<xsl:with-param name="pContent" select="@name" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID2" />
							<xsl:with-param name="pContent" select="@description" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID3" />
							<xsl:with-param name="pContent" select="@expression" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
					</xsl:element>
				</xsl:for-each>
				<!-- end extract content-->
			</xsl:element>
			<!-- end table -->
		</xsl:element>
		<!-- end sheet -->
	</xsl:template>

	<xsl:template name="extractUnitOfMeasure">
		<!-- start parameter -->
		<xsl:param name="pContent" />
		<!-- end parameter -->
		<!-- start declarations -->
		<xsl:variable name="sWorksheetName">UnitOfMeasure</xsl:variable>
		<xsl:variable name="sTitleID1">name</xsl:variable>
		<xsl:variable name="sTitleID2">symbol</xsl:variable>

		<!-- end declarations -->
		<xsl:element name="Worksheet">
			<!-- sheet name -->
			<xsl:attribute name="ss:Name">
						<xsl:value-of select="$sWorksheetName" />
					</xsl:attribute>
			<!-- start table -->
			<xsl:element name="Table">
				<!-- start column definition -->
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<!-- end column definition -->
				<!-- start header line -->
				<xsl:element name="Row">
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID1" />
						<xsl:with-param name="pContent" select="$sTitleID1" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID2" />
						<xsl:with-param name="pContent" select="$sTitleID2" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
				</xsl:element>
				<!-- end header line -->
				<!-- start extract content-->
				<xsl:for-each
					select="//child::*/child::*[local-name() = 'TcUnitOfMeasure']">
					<xsl:sort select="@unitOfMeasureName" />
					<xsl:element name="Row">
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID1" />
							<xsl:with-param name="pContent" select="@unitOfMeasureName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID2" />
							<xsl:with-param name="pContent" select="@unitOfMeasureSymbol" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
					</xsl:element>
				</xsl:for-each>
				<!-- end extract content-->
			</xsl:element>
			<!-- end table -->
		</xsl:element>
		<!-- end sheet -->
	</xsl:template>

	<xsl:template name="extractOccurenceNotes">
		<!-- start parameter -->
		<xsl:param name="pContent" />
		<!-- end parameter -->
		<!-- start declarations -->
		<xsl:variable name="sWorksheetName">occurence notes</xsl:variable>
		<xsl:variable name="sTitleID1">name</xsl:variable>
		<xsl:variable name="sTitleID2">description</xsl:variable>
		<xsl:variable name="sTitleID3">default value</xsl:variable>
		<xsl:variable name="sTitleID4">lov attached</xsl:variable>
		<!-- end declarations -->
		<xsl:element name="Worksheet">
			<!-- sheet name -->
			<xsl:attribute name="ss:Name">
						<xsl:value-of select="$sWorksheetName" />
					</xsl:attribute>
			<!-- start table -->
			<xsl:element name="Table">
				<!-- start column definition -->
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<!-- end column definition -->
				<!-- start header line -->
				<xsl:element name="Row">
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID1" />
						<xsl:with-param name="pContent" select="$sTitleID1" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID2" />
						<xsl:with-param name="pContent" select="$sTitleID2" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID3" />
						<xsl:with-param name="pContent" select="$sTitleID3" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID4" />
						<xsl:with-param name="pContent" select="$sTitleID4" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
				</xsl:element>
				<!-- end header line -->
				<!-- start extract content-->
				<xsl:for-each select="//child::*/child::*[local-name() = 'TcNoteType']">
					<xsl:sort select="@noteTypeName" />
					<xsl:element name="Row">
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID1" />
							<xsl:with-param name="pContent" select="@noteTypeName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID2" />
							<xsl:with-param name="pContent" select="@description" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID3" />
							<xsl:with-param name="pContent" select="@noteTypeDefaultValue" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID4" />
							<xsl:with-param name="pContent" select="@lovName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
					</xsl:element>
				</xsl:for-each>
				<!-- end extract content-->
			</xsl:element>
			<!-- end table -->
		</xsl:element>
		<!-- end sheet -->
	</xsl:template>


	<xsl:template name="extractCompoundPropertyRules">
		<!-- start parameter -->
		<xsl:param name="pContent" />
		<!-- end parameter -->
		<!-- start declarations -->
		<xsl:variable name="sWorksheetName">compound property</xsl:variable>
		<xsl:variable name="sTitleID1">type name</xsl:variable>
		<xsl:variable name="sTitleID2">property name</xsl:variable>
		<xsl:variable name="sTitleID3">read only</xsl:variable>
		<xsl:variable name="sTitleID4">source type</xsl:variable>
		<xsl:variable name="sTitleID5">source property</xsl:variable>
		<xsl:variable name="sTitleID6">path</xsl:variable>
		<!-- end declarations -->
		<xsl:element name="Worksheet">
			<!-- sheet name -->
			<xsl:attribute name="ss:Name">
				<xsl:value-of select="$sWorksheetName" />
			</xsl:attribute>
			<!-- start table -->
			<xsl:element name="Table">
				<!-- start column definition -->
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<!-- end column definition -->
				<!-- start header line -->
				<xsl:element name="Row">
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID1" />
						<xsl:with-param name="pContent" select="$sTitleID1" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID2" />
						<xsl:with-param name="pContent" select="$sTitleID2" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID3" />
						<xsl:with-param name="pContent" select="$sTitleID3" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID4" />
						<xsl:with-param name="pContent" select="$sTitleID4" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID5" />
						<xsl:with-param name="pContent" select="$sTitleID5" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID6" />
						<xsl:with-param name="pContent" select="$sTitleID6" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
				</xsl:element>
				<!-- end header line -->
				<!-- start extract content-->
				<xsl:for-each
					select="//child::*/child::*[local-name() = 'TcCompoundPropertyRule']">
					<xsl:sort select="@destTypeName" />
					<xsl:sort select="@destPropertyName" />
					<xsl:element name="Row">
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID1" />
							<xsl:with-param name="pContent" select="@destTypeName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID2" />
							<xsl:with-param name="pContent" select="@destPropertyName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID3" />
							<xsl:with-param name="pContent" select="@sourceTypeName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID4" />
							<xsl:with-param name="pContent" select="@sourcePropertyName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID5" />
							<xsl:with-param name="pContent" select="@isReadOnly" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID6" />
							<xsl:with-param name="pContent" select="@pathToSource" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
					</xsl:element>
				</xsl:for-each>
				<!-- end extract content-->
			</xsl:element>
			<!-- end table -->
		</xsl:element>
		<!-- end sheet -->
	</xsl:template>

	<xsl:template name="extractTypeDisplayRules">
		<!-- start parameter -->
		<xsl:param name="pContent" />
		<!-- end parameter -->
		<!-- start declarations -->
		<xsl:variable name="sWorksheetName">display rules</xsl:variable>
		<xsl:variable name="sTitleID1">type</xsl:variable>
		<xsl:variable name="sTitleID2">accessor name</xsl:variable>
		<xsl:variable name="sTitleID3">accessor type</xsl:variable>
		<xsl:variable name="sTitleID4">condition</xsl:variable>
		<xsl:variable name="sTitleID5">description</xsl:variable>
		<!-- end declarations -->
		<xsl:element name="Worksheet">
			<!-- sheet name -->
			<xsl:attribute name="ss:Name">
						<xsl:value-of select="$sWorksheetName" />
					</xsl:attribute>
			<!-- start table -->
			<xsl:element name="Table">
				<!-- start column definition -->
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<xsl:call-template name="setupColumn" />
				<!-- end column definition -->
				<!-- start header line -->
				<xsl:element name="Row">
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID1" />
						<xsl:with-param name="pContent" select="$sTitleID1" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID2" />
						<xsl:with-param name="pContent" select="$sTitleID2" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID3" />
						<xsl:with-param name="pContent" select="$sTitleID3" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID4" />
						<xsl:with-param name="pContent" select="$sTitleID4" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>                    
					<xsl:call-template name="generateTableCell">
						<xsl:with-param name="pColumn" select="$sColID5" />
						<xsl:with-param name="pContent" select="$sTitleID5" />
						<xsl:with-param name="pDataType" select="$sDataType" />
					</xsl:call-template>
				</xsl:element>
				<!-- end header line -->
				<!-- start extract content-->
				<xsl:for-each
					select="//child::*/child::*[local-name() = 'TcTypeDisplayRule']">
					<xsl:sort select="@hiddenTypeName" />
					<xsl:sort select="@accessorName" />
					<xsl:sort select="@accessorType" />
					<xsl:element name="Row">
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID1" />
							<xsl:with-param name="pContent" select="@hiddenTypeName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID2" />
							<xsl:with-param name="pContent" select="@accessorName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID3" />
							<xsl:with-param name="pContent" select="@accessorType" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID4" />
							<xsl:with-param name="pContent" select="@conditionName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID5" />
							<xsl:with-param name="pContent" select="@description" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
					</xsl:element>
				</xsl:for-each>
				<!-- end extract content-->
			</xsl:element>
			<!-- end table -->
		</xsl:element>
		<!-- end sheet -->
	</xsl:template>

	<xsl:template name="generateTableCell">
		<xsl:param name="pColumn" />
		<xsl:param name="pContent" />
		<xsl:param name="pDataType" />
		<xsl:element name="Cell">
			<xsl:attribute name="ss:Index"><xsl:value-of select="$pColumn" /></xsl:attribute>
			<xsl:element name="Data">
				<xsl:attribute name="ss:Type"><xsl:value-of select="$pDataType" /></xsl:attribute>
				<xsl:value-of select="normalize-space($pContent)" />
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="setupColumn">
		<xsl:element name="Column">
			<xsl:attribute name="ss:Width">130</xsl:attribute>
		</xsl:element>
	</xsl:template>
	
</xsl:stylesheet>