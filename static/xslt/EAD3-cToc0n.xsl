<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xpath-default-namespace="http://ead3.archivists.org/schema/"
    xmlns="http://ead3.archivists.org/schema/"
    version="2.0">

<!--EAD3 convert numbered  c0n elements into unnumbered <c> elements
    for EADSAA: EAD3toHTML stylesheet --> 

    <xsl:template match="@*|node()"><!-- identity transform -->
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="c" >
        <xsl:variable name="ccount" select="count(./ancestor-or-self::c)"/>
        <xsl:element name="{concat( 'c0' , string($ccount))}">
            <xsl:apply-templates select="@*|node()" />
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>