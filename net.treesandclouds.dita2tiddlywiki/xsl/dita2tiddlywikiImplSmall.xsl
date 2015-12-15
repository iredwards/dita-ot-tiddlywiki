<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
<xsl:output method="text"/>
 
<xsl:template name="cleanText">
<!-- This removes or escapes text from the xml that is also wiki markup text -->
	<xsl:param name="text"/>
	<xsl:variable name="pass1"><xsl:value-of select="replace($text, '\[','\\[')"/></xsl:variable>
	<xsl:variable name="pass2"><xsl:value-of select="replace($pass1,'\]','\\]')"/></xsl:variable>
	<xsl:value-of select="$pass2"/>
</xsl:template>

<xsl:template match="fig">
	<xsl:choose>
		<xsl:when test="name(..)='li' or name(..)='step' or name(..)='substep' or name(..)='stepresult' or name(..)='p' or name(..)='stepxmp'"></xsl:when>
		<xsl:otherwise><xsl:text>&#xA;</xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:apply-templates select="title"/>
	<xsl:apply-templates select="image"/>
</xsl:template>

<xsl:template match="xref[matches(@href,'http.*|ftp.*')]">
	<xsl:text> [</xsl:text>
		<xsl:value-of select="."/>
	<xsl:text>|</xsl:text>
		<xsl:value-of select="@href"/>
	<xsl:text>] </xsl:text> 
</xsl:template>

<xsl:template match="codeph">
	<xsl:text> {{</xsl:text>
	<xsl:call-template name="cleanText">
		<xsl:with-param name="text"><xsl:value-of select="normalize-space(.)"/></xsl:with-param>
	</xsl:call-template>
	<xsl:text>}} </xsl:text>
</xsl:template>

<xsl:template match="codeblock">
	<xsl:text>{noformat}&#xA;</xsl:text>
	<xsl:value-of select="."/>
	<xsl:text>{noformat}</xsl:text>
 </xsl:template>

<xsl:template match="indexterm">
	<xsl:if test="count(//title)=0">
		<xsl:text> {{</xsl:text>
		<xsl:apply-templates select="text()|*"/>
		<xsl:text>}} </xsl:text>
	</xsl:if>
</xsl:template>

<xsl:template name="getListString">
	<xsl:param name="currentNode"/>
	<xsl:text>&#xA;</xsl:text>
	<xsl:for-each select="for $i in (ancestor::*) return $i">
		<xsl:if test="name(.)='ul'">
			<xsl:text>*</xsl:text>
		</xsl:if>
		<xsl:if test="name(.)='ol'">
			<xsl:text>#</xsl:text>
		</xsl:if>
	</xsl:for-each>
</xsl:template>
		
<xsl:template match="ul">
	<xsl:if test="name(..)!='li' and name(../..)!='step' and name(../..)!='substep'"> <!-- if the parent is not part of a list, we need an extra carriage return -->
		<xsl:text>&#xA;</xsl:text>
	</xsl:if>
	
	<xsl:apply-templates select="text()|*"/>
	<xsl:if test="name(..)='p'"> <!-- insert line break when inside of paragraph -->
		<xsl:text>&#xA;</xsl:text>
		<xsl:text>&#xA;</xsl:text>
	</xsl:if>
</xsl:template>

<xsl:template match="ol">
	<xsl:if test="name(..)!='li' and name(../..)!='step' and name(../..)!='substep'"> <!-- if the parent is not part of a list, we need an extra carriage return -->
		<xsl:text>&#xA;</xsl:text>
	</xsl:if>
    <xsl:apply-templates select="text()|*"/>
	<xsl:if test="name(..)='p'"> <!-- insert line break when inside of paragraph -->
		<xsl:text>&#xA;</xsl:text>
		<xsl:text>&#xA;</xsl:text>
	</xsl:if>
</xsl:template>
	
<xsl:template match="li">
	<xsl:call-template name="getListString">
		<xsl:with-param name="currentNode">
			<xsl:value-of select="."/>
		</xsl:with-param>
	</xsl:call-template>

	<xsl:if test="name(../../..)='substep'">
		<xsl:text>**</xsl:text>
	</xsl:if>

	<xsl:text> </xsl:text> <!-- we need a space after numbering clause before the actual text -->
	<xsl:apply-templates select="text()|*"/>
</xsl:template>

<xsl:template match="uicontrol">
	<xsl:text> *</xsl:text>
	<xsl:if test="preceding::uicontrol and name(..)='menucascade' and position()>1">
		<xsl:text>> </xsl:text>
	</xsl:if>
	<xsl:value-of select="normalize-space(.)"/>
	<xsl:text>* </xsl:text>
</xsl:template>

<xsl:template match="note">
	<xsl:if test="(preceding::table) and (name(..)!='li')"> 
		<xsl:text>&#xA;</xsl:text>
	</xsl:if>
	<xsl:text>{note:title=Note:}&#xA;</xsl:text>
	<xsl:apply-templates select="text()|*"/>
	<xsl:text>{note}</xsl:text>
</xsl:template>

<xsl:template match="image">
	<!-- if an image should be 'breaked', we need an extra carriage return -->
	<xsl:if test="(.[@placement = 'break'] or preceding::table) and (name(..)!='stepxmp' or name(..)!='stepresult') and name(..)!='entry' and name(..)!='p'"> 
		<xsl:text>&#xA;</xsl:text>
	</xsl:if>

	<xsl:text> !</xsl:text><xsl:value-of select="@href"/>

	<xsl:if test=".[@align != ''] or .[@width != ''] or .[@height != '']"> 
		<xsl:text>|</xsl:text>
		<xsl:if test=".[@align != '']"> 
			<xsl:text>align=</xsl:text><xsl:value-of select="@align"/>
		</xsl:if>
		<xsl:if test=".[@width != '']"> 
			<xsl:if test=".[@align != '']"> 
				<xsl:text>, </xsl:text>
			</xsl:if>
			<xsl:text>width=</xsl:text><xsl:value-of select="@width"/>
		</xsl:if>
		<xsl:if test=".[@height != '']"> 
			<xsl:if test=".[@align != ''] or .[@width != '']"> 
				<xsl:text>, </xsl:text>
			</xsl:if>
			<xsl:text>height=</xsl:text><xsl:value-of select="@height"/>
		</xsl:if>
	</xsl:if>
	
	<xsl:text>!\\ </xsl:text>
</xsl:template>

<xsl:template match="table">
	<!--	
|!Cell1 |!Cell2 |
|Cell3 |Cell3 |

Left aligned content |
| Right aligned content|
| Centred content |

-->	
	<xsl:for-each select="tgroup/thead/row">
		<xsl:for-each select="entry">
			<xsl:text>|!</xsl:text>
			<xsl:apply-templates select="./*|text()"/>
			<xsl:text> </xsl:text>
		</xsl:for-each>
		<xsl:text>|&#xA;</xsl:text>
	</xsl:for-each>
	
	<xsl:for-each select="tgroup/tbody/row">
		<xsl:for-each select="entry">
			<xsl:text>|</xsl:text>
			<xsl:apply-templates select="./*|text()"/>
			<xsl:text> </xsl:text>
		</xsl:for-each>
		<xsl:text>|&#xA;</xsl:text>
	</xsl:for-each>
</xsl:template>

<xsl:template name="table-cell-open">
	<xsl:text>&#xA;{table-cell:</xsl:text>
	<xsl:call-template name="checkColspan"/>
	<xsl:call-template name="checkRowspan"/>
	<xsl:call-template name="checkAlign"/>
	<xsl:call-template name="checkVertAlign"/>
	<xsl:text>}</xsl:text>
</xsl:template>

<xsl:template name="checkColspan">
	<xsl:if test=".[@colspan!='']">
		<xsl:text>colspan=</xsl:text>
		<xsl:value-of select="@colspan"/>
		<xsl:text>|</xsl:text>
	</xsl:if>
</xsl:template>

<xsl:template name="checkRowspan">
	<xsl:if test=".[@rowspan!='']">
		<xsl:text>rowspan=</xsl:text>
		<xsl:value-of select="@rowspan"/>
		<xsl:text>|</xsl:text>
	</xsl:if>
</xsl:template>

<xsl:template name="checkAlign">
	<xsl:if test=".[@align!='']">
		<xsl:text>align=</xsl:text>
		<xsl:value-of select="@align"/>
		<xsl:text>|</xsl:text>
	</xsl:if>
</xsl:template>

<xsl:template name="checkVertAlign">
	<xsl:if test=".[@valign!='']">
		<xsl:text>valign=</xsl:text>
		<xsl:value-of select="@valign"/>
		<xsl:text>|</xsl:text>
	</xsl:if>
</xsl:template>

<xsl:template name="checkTableFrame">
	<xsl:if test=".[@frame!='']">
		<xsl:text>frame=</xsl:text>
		<xsl:choose>
			<xsl:when test=".[@frame='top']">
				<xsl:text>above</xsl:text>
			</xsl:when>
			<xsl:when test=".[@frame='bottom']">
				<xsl:text>below</xsl:text>
			</xsl:when>
			<xsl:when test=".[@frame='topbot']">
				<xsl:text>hsides</xsl:text>
			</xsl:when>
			<xsl:when test=".[@frame='all']">
				<xsl:text>box</xsl:text>
			</xsl:when>
			<xsl:when test=".[@frame='sides']">
				<xsl:text>vsides</xsl:text>
			</xsl:when>
			<xsl:when test=".[@frame='none']">
				<xsl:text>void</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@frame"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>|</xsl:text>
	</xsl:if>
</xsl:template>

<xsl:template name="checkTableRules">
	<xsl:if test=".[@colsep!=''] or .[@rowsep!='']">
		<xsl:text>rules=</xsl:text>
		<xsl:choose>
			<xsl:when test=".[@colsep='0'] and .[@rowsep='0']">
				<xsl:text>none</xsl:text>
			</xsl:when>
			<xsl:when test=".[@colsep='0'] and (.[not(@rowsep)] or .[@rowsep!='0'])">
				<xsl:text>rows</xsl:text>
			</xsl:when>
			<xsl:when test=".[@rowsep='0'] and (.[not(@colsep)] or .[@colsep!='0'])">
				<xsl:text>cols</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>all</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>|</xsl:text>
	</xsl:if>
</xsl:template>

<xsl:template match="simpletable">
	<xsl:for-each select="sthead">
		<xsl:text>&#xA;</xsl:text>
		<xsl:text>||</xsl:text><!-- The | goes at the beginning of the line -->
		<xsl:for-each select="stentry">
			<xsl:apply-templates select="."/>
			<xsl:text> ||</xsl:text> <!-- Inserting extra space to correctly render empty cells -->
		</xsl:for-each>
	</xsl:for-each>
	<xsl:for-each select="strow">
		<xsl:text>&#xA;</xsl:text>
		<xsl:text>|</xsl:text><!-- The | goes at the beginning of the line -->
		<xsl:for-each select="stentry"><!-- Let's hope this works -->
		    <!-- wrapping list inside the table cell in a panel -->
			<xsl:if test="descendant::ol or descendant::ul">
			    <xsl:text>{panel: borderStyle=none| borderColor=#FFFFFF| bgColor=#FFFFFF}</xsl:text>
			</xsl:if>

		    <xsl:apply-templates select="./*|text()"/><!-- you never know what you will get -->
		    
		    <!-- wrapping list inside the table cell in a panel -->
			<xsl:if test="descendant::ol or descendant::ul">
			    <xsl:text>{panel}</xsl:text>
		    </xsl:if>
			<xsl:text> |</xsl:text> <!-- Inserting extra space to correctly render empty cells -->
		</xsl:for-each>
	</xsl:for-each>
</xsl:template>

<xsl:template name="font-bold" match="b">
	<xsl:text>*</xsl:text>
	<xsl:call-template name="cleanText">
		<xsl:with-param name="text"><xsl:value-of select="normalize-space(.)"/></xsl:with-param>
	</xsl:call-template>
	<xsl:text>* </xsl:text>
</xsl:template>

<xsl:template match="i">
	<xsl:text>_</xsl:text>
	<xsl:call-template name="cleanText">
		<xsl:with-param name="text"><xsl:value-of select="normalize-space(.)"/></xsl:with-param>
	</xsl:call-template>
	<xsl:text>_ </xsl:text>
</xsl:template>

<xsl:template name="paragraph" match="p">
	<xsl:call-template name="checkLineBreaks"/>
    <xsl:apply-templates select="text()|*"/>
 </xsl:template>

<xsl:template match="p[name(..)='li' and position()>1 and not(following-sibling::note)]">
	<!-- p tag whose parent is list containing several paragraphs - for this we need to be careful of carriage returns-->
	<xsl:text>&#xA;</xsl:text>
	<xsl:apply-templates select="text()|*"/>
</xsl:template>	

<xsl:template match="p[name(..)='stentry']">
	<!-- p tag whose parent is stentry - for this we need to be careful of carriage returns-->
	<xsl:apply-templates select="text()|*"/>
</xsl:template>	
	
<xsl:template match="p[name(..)='entry']">
	<!-- p tag whose parent is entry - for this we need to be careful of carriage returns-->
	<xsl:apply-templates select="text()|*"/>
</xsl:template>	
	
<xsl:template match="p[name(..)='stepxmp']">
	<!-- p tag whose parent is stepxmp - for this we need to be careful of carriage returns-->
	<xsl:apply-templates select="text()|*"/>
</xsl:template>	
	
<xsl:template match="p[name(..)='stepresult']">
	<!-- p tag whose parent is stepresult - for this we need to be careful of carriage returns-->
	<xsl:apply-templates select="text()|*"/>
</xsl:template>	
	
<xsl:template match="span">
		<xsl:apply-templates select="text()|*"/>
	
</xsl:template>	
	
<xsl:template match="ph">
	<xsl:text> {{</xsl:text>
	<xsl:value-of select="normalize-space(.)"/>
	<xsl:text>}} </xsl:text>
</xsl:template>

<xsl:template match="title">
	<xsl:choose>
		<xsl:when test="name(..)='section' or name(..)='task' or name(..)='concept'">
			<xsl:text>! </xsl:text><xsl:value-of select="."/>
		</xsl:when>
		<xsl:when test="name(..)='topic'">
			<!-- put nothing if a child of topic clause -->
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>&#xA;*</xsl:text><xsl:value-of select="normalize-space(.)"/><xsl:text>*&#xA;</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
	
<xsl:template match="section">
	<xsl:text>&#xA;</xsl:text>
    <xsl:apply-templates select="./*"/>
</xsl:template>

<!--<xsl:template match="text()[name(..)='p']" >
<!-\- Text where the parent is a p -\->
	<!-\- normalize out extra whitespace but we often at least need a trailing space	-\->
	<xsl:value-of select="normalize-space(.)"/><xsl:text> </xsl:text>
</xsl:template>-->

<xsl:template match="text()">
	<!-- if we have selected an empty text node, let's just ignore it -->
	<xsl:choose>
		<xsl:when test="string-length(normalize-space(.))=0"></xsl:when>
		<xsl:otherwise>
			<xsl:variable name="whitespace" select="'&#xD;&#xA;&#x9;&#x20;'"/>
			
			<!-- add leading space if there is leading whitespace in the original -->
			<xsl:variable name="firstchar" select="substring(., 1, 1)"/>
			<xsl:if test="contains($whitespace, $firstchar)">
				<xsl:text> </xsl:text>
			</xsl:if>
			
			<!-- add normalized text (ie: leading, trailing, and repeating white spaces stripped) -->
			<xsl:value-of select="normalize-space(.)"/>
			
			<!-- add trailing space if there is trailing whitespace in the original -->
			<xsl:variable name="lastchar" select="substring(., string-length(.), 1)"/>
			<xsl:if test="contains($whitespace, $lastchar)">
				<xsl:text> </xsl:text>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- The task templates -->
<xsl:template match="context">
	<xsl:apply-templates select="text()|*"/>
	<xsl:text>&#xA;</xsl:text>
</xsl:template>

<xsl:template match="cmd">
	<xsl:apply-templates select="text()|*"/>
</xsl:template>

<xsl:template match="info">
	<xsl:apply-templates select="text()|*"/>
</xsl:template>

<xsl:template match="stepxmp">
	<xsl:if test="preceding::stepxmp and not(descendant::fig) and not(descendant::p)">
		<xsl:text>&#xA;</xsl:text> 
	</xsl:if>
	<xsl:apply-templates select="text()|*"/>
</xsl:template>

<xsl:template match="stepresult">
	<xsl:if test="(preceding::stepresult or preceding::cmd) and not(descendant::fig or descendant::image)">
		<xsl:text>&#xA;</xsl:text> 
	</xsl:if>
	<xsl:apply-templates select="text()|*"/>
</xsl:template>

<xsl:template match="result">
	<xsl:if test="(preceding::stepresult or preceding::cmd) and not(descendant::fig) and not(descendant::p)">
		<xsl:text>&#xA;</xsl:text> 
	</xsl:if>
	<xsl:apply-templates select="text()|*"/>
</xsl:template>

<xsl:template match="steps">
	<xsl:for-each select="step">
		<xsl:text>&#xA;# </xsl:text>
		<xsl:apply-templates select="text()|*"/>
	</xsl:for-each>
	<xsl:if test="name(..)='p'"> <!-- insert line break when inside of paragraph -->
		<xsl:text>&#xA;</xsl:text>
		<xsl:text>&#xA;</xsl:text>
	</xsl:if>
</xsl:template>

<xsl:template match="substeps">
	<xsl:for-each select="substep">
		<xsl:text>&#xA;## </xsl:text>
		<xsl:apply-templates select="text()|*"/>
	</xsl:for-each>
</xsl:template>

<xsl:template match="choices">
	<xsl:for-each select="choice">
		<xsl:text>&#xA;</xsl:text> 
		<xsl:if test="name(../../..) = 'ol' or name(../..) = 'step' or name(../..) = 'substep'">
			<xsl:text>#</xsl:text> 
		</xsl:if>
		<xsl:if test="name(../..) = 'ul'">
			<xsl:text>*</xsl:text> 
		</xsl:if>
		<xsl:text>* </xsl:text>
		<xsl:apply-templates select="text()|*"/>
	</xsl:for-each>
</xsl:template>

<xsl:template match="refsyn">
	<xsl:apply-templates select="*"/>
	<xsl:text>&#xA;</xsl:text>
</xsl:template>

<xsl:template match="example">
	<xsl:apply-templates select="*"/>
	<xsl:text>&#xA;</xsl:text>
</xsl:template>
	
<xsl:template match="taskbody">
	<xsl:apply-templates select="*"/>
</xsl:template>
	
<xsl:template match="conbody">
	<xsl:apply-templates select="*"/>
</xsl:template>
	
<xsl:template match="tutorialinfo">
	<xsl:apply-templates select="text()|*"/>
</xsl:template>
	
<xsl:template match="refbody">
	<xsl:apply-templates select="*"/>
</xsl:template>
	
<xsl:template match="/concept">
	<xsl:apply-templates select="conbody"/>
</xsl:template>

<xsl:template match="/task">
    <xsl:apply-templates select="taskbody"/>
</xsl:template>

<xsl:template match="/reference">
    <xsl:apply-templates select="refbody"/>
</xsl:template>


	
<xsl:template match="/">
	<xsl:text>iiiiiiiiiiiiiiiii &#xA;</xsl:text>
	<xsl:apply-templates select="*"/>
</xsl:template>

<xsl:template match="shortdesc">
	<xsl:call-template name="checkLineBreaks"/>
	<xsl:value-of select="text()|*"/>
</xsl:template>

<xsl:template match="glossentry">
	<xsl:call-template name="checkLineBreaks"/>
	<!-- making glossterm bold -->
	<xsl:text> *</xsl:text>
	<xsl:value-of select="replace(glossterm, '&#xA;|&#xD;', '')" />
	<xsl:text>* &#xA;</xsl:text>
	<!-- adding definition text -->
	<xsl:value-of select="./glossdef"/>
</xsl:template>

<xsl:template name="checkLineBreaks">
	<xsl:if test="(name(..)!='li' and name(..)!='choice' and (preceding::p or preceding::table or preceding::ol or preceding::ul or preceding::title)) or (descendant::image and name(..)!='li' and name(..)!='step' and name(../..)!='step')">
		<xsl:text>&#xA;</xsl:text>
		<xsl:text>&#xA;</xsl:text>
	</xsl:if>
</xsl:template>

</xsl:stylesheet>
