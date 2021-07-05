<xsl:stylesheet version="1.0" xmlns:t="http://www.w3.org/2005/Atom" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xslFormatting="urn:xslFormatting">

    <xsl:output method="html" indent="no"/>

    <xsl:template match="/t:search-results">
 
 <html>
 <body>	
 <table  align="center" border="1">	
 
 <xsl:for-each select="t:entry">
		    <tr>
				<td>
					<xsl:value-of select="*[local-name()='creator']"/> 
					<br/>
					<b>
					<xsl:value-of select="*[local-name()='title']"/>
					</b>
                    <br/>
					<xsl:value-of select="*[local-name()='publicationName']"/>					
					<br/>
					<xsl:value-of select="*[local-name()='volume']"/>					
					<br/>
					<xsl:value-of select="*[local-name()='pageRange']"/>					
					<br/>
					<xsl:value-of select="*[local-name()='coverDisplayDate']"/>					
					<br/>
					<xsl:value-of select="*[local-name()='doi']"/>					
					<br/>
					<hr/>


					
				</td>
			</tr>
        </xsl:for-each>

  </table>

</body>
</html>  

    </xsl:template>

</xsl:stylesheet>