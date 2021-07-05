<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/search-results">
 <html>
 <body>
  <h1 align="center">Students' Basic Details</h1>
  <table  align="center" border="1">
  <xsl:for-each select="opensearch:totalResults">
   <tr>
    
    <td><xsl:value-of select="."/></td>
    
   </tr>
    
  </xsl:for-each>
  </table>
   <table  align="center" border="1">
   <tr bgcolor="#9acd32">
    <th>Name</th>
    <th>Branch</th>
    <th>Age</th>
    <th>City</th>
   </tr>
    <xsl:for-each select="entry">
   <tr>
    
    <td><xsl:value-of select="title"/></td>
    
   </tr>
    </xsl:for-each>
    </table>
</body>
</html>
</xsl:template>
</xsl:stylesheet>