<?xml version="1.0" encoding="ISO-8859-1"?>
	<!-- ================================================================ -->
	<!--                                                                  -->
	<!-- SIEMENS PLM Copyright (c) 2010                                   -->
	<!-- Unpublished - All rights reserved                                -->
	<!--                                                                  -->
	<!-- File name: filtertypes2xls.xsl                                   -->
	<!--                                                                  -->
	<!-- Description:                                                     -->
	<!-- 11-May-2010 Christian Günther Initial Creation                   -->
	<!-- $HISTORY$                                                        -->
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

			<xsl:call-template name="extractTypes">
				<xsl:with-param name="pContent">TcStandardType</xsl:with-param>
			</xsl:call-template>

		</Workbook>
	</xsl:template>


	<xsl:template name="extractTypes">
		<!-- start parameter -->
		<xsl:param name="pContent" />
		
		<!-- end parameter -->
		<!-- start declarations -->
		<xsl:variable name="sWorksheetName">types</xsl:variable>
		<xsl:variable name="sTitleID1">type name</xsl:variable>
		<xsl:variable name="sTitleID2">class name</xsl:variable>
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
				</xsl:element>
				<!-- end header line -->
				<!-- start extract content -->

					<xsl:call-template name="extractContent4Type">
						<xsl:with-param name="pContent" select="$pContent" />
				        <xsl:with-param name="pClassName">Item</xsl:with-param>
					</xsl:call-template>

					<xsl:call-template name="extractContent4DatasetType"/>

					<xsl:call-template name="extractContent4Type">
						<xsl:with-param name="pContent" select="$pContent" />
				        <xsl:with-param name="pClassName">Folder</xsl:with-param>
					</xsl:call-template>

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
							<xsl:with-param name="pContent" select="@typeClassName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
					</xsl:element>
				</xsl:for-each>
				<!-- start extract forms-->
			</xsl:element>
			<!-- end table -->
		</xsl:element>
		<!-- end sheet -->
	</xsl:template>

	<xsl:template name="extractContent4Type">
		<!-- start parameter -->
		<xsl:param name="pContent" />
		<xsl:param name="pClassName" />
				<xsl:for-each select="//child::*/child::*[local-name() = $pContent and @parentTypeName = $pClassName ]">
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
					</xsl:element>
				</xsl:for-each>
	</xsl:template>

	<xsl:template name="extractContent4DatasetType">
		<!-- start parameter -->
		<xsl:param name="pContent" />
		<xsl:param name="pClassName" />
				<xsl:for-each
					select="//child::*/child::*[local-name() = 'TcDataset']">
					<xsl:sort select="@typeName" />
					<xsl:element name="Row">
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID1" />
							<xsl:with-param name="pContent"
								select="@typeName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
						<xsl:call-template name="generateTableCell">
							<xsl:with-param name="pColumn" select="$sColID2" />
							<xsl:with-param name="pContent"
								select="@parentTypeName" />
							<xsl:with-param name="pDataType" select="$sDataType" />
						</xsl:call-template>
					</xsl:element>
				</xsl:for-each>
	</xsl:template>
<!--
				-->
		
			
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