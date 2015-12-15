<?xml version="1.0" encoding="UTF-8"?><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
  
  
  <xsl:import href="dita2tiddlywikiImpl.xsl"/>
 
  <xsl:import href="ut-d.xsl"/>
  <xsl:import href="sw-d.xsl"/>
  <xsl:import href="pr-d.xsl"/>
  <xsl:import href="ui-d.xsl"/>
  <xsl:import href="hi-d.xsl"/>
  <xsl:import href="markup-d.xsl"/>
  <xsl:import href="xml-d.xsl"/>
  
  <xsl:output method="text" encoding="utf-8"/>
  
  <xsl:template match="/">
  	<xsl:text>created: </xsl:text>
	<xsl:value-of select="format-dateTime(current-dateTime(),'[Y][M01][D01][H01][m01][s02][f001]')"/>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>modified: </xsl:text>
	<xsl:value-of select="format-dateTime(current-dateTime(),'[Y][M01][D01][H01][m01][s02][f001]')"/>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>tags: DITA</xsl:text>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>title: </xsl:text>
	<xsl:value-of select="//title"/>
	<xsl:text>&#xA;</xsl:text>
	<xsl:text>type: text/vnd.tiddlywiki&#xA;</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>
  
</xsl:stylesheet>