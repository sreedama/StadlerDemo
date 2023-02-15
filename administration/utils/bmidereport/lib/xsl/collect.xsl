<?xml version="1.0" encoding="iso-8859-1"?>
	<!-- parameter -->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:plmxml_bus="http://www.plmxml.org/Schemas/PLMXMLBusinessSchema"
	xmlns:plm="http://www.plmxml.org/Schemas/PLMXMLBusinessSchema">

	<xsl:strip-space elements="*" />

	<xsl:output method="xml" indent="yes" />
	
	<xsl:param name="P_BMIDE_PROJECT_DIR" />

	<xsl:template match="/">
	<xsl:element name="Root">
		<xsl:for-each select="//child::*[local-name() = 'include']">
			<xsl:variable name="sBMIDEProjectBaseDir" select="$P_BMIDE_PROJECT_DIR"/>
			<xsl:variable name="sBMIDEConfiurationFileName" select="@file"/>
			<xsl:variable name="sSourceFile" select="concat( $sBMIDEProjectBaseDir, $sBMIDEConfiurationFileName)"/>
			<xsl:message>
				<xsl:value-of select="$sSourceFile" />
			</xsl:message>
			<xsl:for-each select="document($sSourceFile)//child::*/child::*/child::*">
			<xsl:copy-of select="." />
			</xsl:for-each>
			
		</xsl:for-each>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>

