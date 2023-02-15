<?xml version="1.0" encoding="UTF-8"?>
<!--
This file was generated by Altova MapForce 2017sp2

YOU SHOULD NOT MODIFY THIS FILE, BECAUSE IT WILL BE
OVERWRITTEN WHEN YOU RE-RUN CODE GENERATION.

Refer to the Altova MapForce Documentation for further details.
http://www.altova.com/mapforce
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:vmf="http://www.altova.com/MapForce/UDF/vmf" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="vmf xs" xmlns:xalan="http://xml.apache.org/xalan">
	<xsl:template name="vmf:vmf1_inputtoresult">
		<xsl:param name="input" select="/.."/>
		<xsl:choose>
			<xsl:when test="$input='Mass Density (RHO)_6' or $input='Mass Density (RHO)_1'">
				<xsl:value-of select="'MassDensity'"/>
			</xsl:when>
			<xsl:when test="$input='Specific Heat (CP)_23' or $input='Specific Heat (CP)_3'">
				<xsl:value-of select="'Specific Heat'"/>
			</xsl:when>
			<xsl:when test="$input='Thermal Conductivity (K)_2' or $input='Thermal Conductivity (K)_35'">
				<xsl:value-of select="'ThermalConductivity'"/>
			</xsl:when>
			<xsl:when test="$input='Dynamic Viscosity_4'">
				<xsl:value-of select="'DynamicViscosity'"/>
			</xsl:when>
			<xsl:when test="$input='Thermal Expansion Coefficient' or $input='Average Thermal Expansion Coefficient'">
				<xsl:value-of select="'ThermalExpansion'"/>
			</xsl:when>
			<xsl:when test="$input='Molar Mass_60'">
				<xsl:value-of select="'MolarMass'"/>
			</xsl:when>
			<xsl:when test="$input='Gas Constant_61'">
				<xsl:value-of select="'GasConstant'"/>
			</xsl:when>
			<xsl:when test="$input='Yield Strength_32'">
				<xsl:value-of select="'Yield Strength'"/>
			</xsl:when>
			<xsl:when test="$input='Poisson´s Ratio' or $input='Poisson Ratio'">
				<xsl:value-of select="'PoissonsRatio'"/>
			</xsl:when>
			<xsl:when test="$input='Youngs Modulus (E)_31'">
				<xsl:value-of select="'Youngs Modulus'"/>
			</xsl:when>
			<xsl:when test="$input='Youngs Modulus (E)_31'">
				<xsl:value-of select="'Youngs Modulus'"/>
			</xsl:when>
			<xsl:when test="$input='Thermal Expansion (A)_34'">
				<xsl:value-of select="'Thermal ExpansionA'"/>
			</xsl:when>
			<xsl:when test="$input='Strain' or $input='Stress Vs Strain' or $input='Stress vs Strain'">
				<xsl:value-of select="'StressStrainCurve'"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$input"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:output method="xml" encoding="UTF-8" indent="yes"  xalan:indent-amount="4"/>
	<xsl:template match="/">
		<xsl:variable name="var1_initial" select="."/>
		<MatML_Doc>
			<xsl:for-each select="MatML_Doc">
				<xsl:variable name="var2_cur" select="."/>
				<xsl:for-each select="Material">
					<xsl:variable name="var3_cur" select="."/>
					<Material>
						<BulkDetails>
							<Notes/>
							<Name>
								<xsl:value-of select="BulkDetails/Name"/>
							</Name>
							<Class>
								<Name>
									<xsl:value-of select="BulkDetails/Class/Name"/>
								</Name>
							</Class>
							<Source>
								<xsl:attribute name="source">
									<xsl:value-of select="BulkDetails/Source/@source"/>
								</xsl:attribute>
							</Source>
							<xsl:for-each select="BulkDetails/PropertyData">
								<xsl:variable name="var4_cur" select="."/>
								<PropertyData>
									<xsl:attribute name="property">
										<xsl:value-of select="@property"/>
									</xsl:attribute>
									  <Data>
										<xsl:attribute name="format">
										  <xsl:value-of select="Data/@format"/>
										</xsl:attribute>
										<!--<xsl:value-of select="Data"/>-->
										<xsl:choose>
										  <xsl:when test="ParameterValue or Data/@format='string'">
											<xsl:value-of select="Data"/>               
										  </xsl:when>
										  <xsl:otherwise>
											<xsl:call-template name="GetFirstValueOnly">
											  <xsl:with-param name="value" select="Data" />
											  <xsl:with-param name="separator" select="','" />
											</xsl:call-template>
										  </xsl:otherwise>
										</xsl:choose>
									  </Data>
									<xsl:for-each select="Qualifier">
										<xsl:variable name="var5_cur" select="."/>
										<Qualifier>
											<xsl:value-of select="."/>
										</Qualifier>
									</xsl:for-each>
									<xsl:for-each select="ParameterValue">
										<xsl:variable name="var6_cur" select="."/>
										<ParameterValue>
											<xsl:attribute name="format">
												<xsl:value-of select="@format"/>
											</xsl:attribute>
											<xsl:attribute name="parameter">
												<xsl:value-of select="@parameter"/>
											</xsl:attribute>
											<Data>
												<xsl:value-of select="Data"/>
											</Data>
										</ParameterValue>
									</xsl:for-each>
								</PropertyData>
							</xsl:for-each>
						</BulkDetails>
					</Material>
				</xsl:for-each>
				<Metadata>
					<xsl:for-each select="Metadata/PropertyDetails">
						<xsl:variable name="var8_cur" select="."/>
						<PropertyDetails>
							<xsl:attribute name="id">
								<xsl:value-of select="@id"/>
							</xsl:attribute>
							<xsl:attribute name="type">
								<xsl:value-of select="@type"/>
							</xsl:attribute>
							<Name>
								<xsl:variable name="var9_nested">
									<xsl:call-template name="vmf:vmf1_inputtoresult">
										<xsl:with-param name="input" select="string(Name)"/>
									</xsl:call-template>
								</xsl:variable>
								<xsl:value-of select="$var9_nested"/>
							</Name>
							<xsl:for-each select="Unitless">
								<xsl:variable name="var10_cur" select="."/>
								<Unitless/>
							</xsl:for-each>
							<xsl:for-each select="Units">
								<xsl:variable name="var11_cur" select="."/>
								<Units>
									<xsl:attribute name="name">
										<xsl:value-of select="@name"/>
									</xsl:attribute>
									<Unit>
										<Name>
											<xsl:value-of select="Unit/Name"/>
										</Name>
									</Unit>
								</Units>
							</xsl:for-each>
						</PropertyDetails>
					</xsl:for-each>
					<xsl:for-each select="Metadata/ParameterDetails">
						<xsl:variable name="var12_cur" select="."/>
						<ParameterDetails>
							<xsl:attribute name="id">
								<xsl:value-of select="@id"/>
							</xsl:attribute>
							<xsl:attribute name="type">
								<xsl:value-of select="@type"/>
							</xsl:attribute>
							<Name>
								<xsl:variable name="var13_nested">
									<xsl:call-template name="vmf:vmf1_inputtoresult">
										<xsl:with-param name="input" select="string(Name)"/>
									</xsl:call-template>
								</xsl:variable>
								<xsl:value-of select="$var13_nested"/>
							</Name>
							<Units>
								<xsl:attribute name="name">
									<xsl:value-of select="Units/@name"/>
								</xsl:attribute>
								<Unit>
									<Name>
										<xsl:value-of select="Units/Unit/Name"/>
									</Name>
								</Unit>
							</Units>
						</ParameterDetails>
					</xsl:for-each>
				</Metadata>
			</xsl:for-each>
		</MatML_Doc>
	</xsl:template>
  <xsl:template name="GetFirstValueOnly">
    <xsl:param name="value" />
    <xsl:param name="separator" select="','" />
    <xsl:choose>
      <xsl:when test="contains($value, $separator)">
        <xsl:call-template name="GetFirstValueOnly">
          <xsl:with-param name="value" select="substring-before($value, $separator)" />
          <xsl:with-param name="separator" select="$separator" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$value" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
