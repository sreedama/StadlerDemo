<?xml version="1.0" encoding="iso-8859-1"?>
	<!-- parameter -->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:plmxml_bus="http://www.plmxml.org/Schemas/PLMXMLBusinessSchema"
	xmlns:plm="http://www.plmxml.org/Schemas/PLMXMLBusinessSchema">

	<xsl:strip-space elements="*" />

	<xsl:output method="xml" indent="yes" />
	
	<xsl:param name="P_BMIDE_PROJECT_DIR" />
	<xsl:param name="P_BMIDE_TEMPLATE_DIR" />
	<xsl:param name="P_DEPENDECY_COLLECTION" />
	<xsl:param name="P_EXTENSTION_NAME" />

	<xsl:template match="/">
	<xsl:element name="Root">
	<xsl:element name="extension">
	<xsl:attribute name="name"><xsl:value-of select="$P_EXTENSTION_NAME" /></xsl:attribute>
		<xsl:for-each select="//child::*[local-name() = 'include']">
			<xsl:variable name="sBMIDEProjectBaseDir" select="$P_BMIDE_PROJECT_DIR"/>
			<xsl:variable name="sBMIDEConfiurationFileName" select="@file"/>
			<xsl:variable name="sSourceFile" select="concat( $sBMIDEProjectBaseDir, $sBMIDEConfiurationFileName)"/>
			<xsl:message>
				<xsl:value-of select="$sSourceFile" />
			</xsl:message>
			<!--
			<xsl:for-each select="document($sSourceFile)//child::*/child::*/child::*[local-name() = 'TcDatasetReference']">
			-->
			<xsl:for-each select="document($sSourceFile)//child::*/child::*[local-name() = 'TcDataset']">
			
			<xsl:copy-of select="." />
			</xsl:for-each>
			
		</xsl:for-each>
		</xsl:element>

		<xsl:for-each select="document($P_DEPENDECY_COLLECTION)//child::*[local-name() = 'include']">
			<xsl:variable name="sBMIDETemplateBaseDir" select="$P_BMIDE_TEMPLATE_DIR"/>
			<xsl:variable name="sBMIDEConfiurationFileName" select="@file"/>
			<xsl:variable name="sSourceFile" select="concat( $sBMIDETemplateBaseDir, $sBMIDEConfiurationFileName)"/>
			<xsl:message>
				<xsl:value-of select="$sSourceFile" />
			</xsl:message>
			<xsl:variable name="sTemplateName"
					select="substring-before($sBMIDEConfiurationFileName,'_')" />
	<xsl:element name="extension">
	<xsl:attribute name="name"><xsl:value-of select="$sTemplateName" /></xsl:attribute>
					
			<!--
			<xsl:for-each select="document($sSourceFile)//child::*/child::*/child::*[local-name() = 'TcDatasetReference']">
			-->
			<xsl:for-each select="document($sSourceFile)//child::*/child::*[local-name() = 'TcDataset']">
			
			<xsl:copy-of select="." />
			</xsl:for-each>
		</xsl:element>
			
		</xsl:for-each>

		</xsl:element>
	</xsl:template>
</xsl:stylesheet>

