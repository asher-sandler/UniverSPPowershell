function get-LookupArray( $fa){
	$FieldArr = @()
	foreach($fld in $fa){
		if (!$fld.Hidden){	
			$isServiceField = $false
			foreach($srvLF in $ServiceLookupFields){
				if ($srvLF -eq $fld.InternalName){
					$isServiceField = $true
					break
				}
			}
			if (!$isServiceField){	
				if ($fld.Type.ToString().Contains("Lookup")){
			
					$xmlF = "<Fields>"+$fld.SchemaXml+"</Fields>"
					$isXMLsrc = [bool]$($xmlF -as [xml])
					if ($isXMLsrc){
						$SourceListID = Select-Xml -Content $xmlF  -XPath "/Fields/Field" | ForEach-Object { $_.Node.List}
						$SourceListName = $homeweb.Lists | Where{$SourceListID.Contains($_.ID) }
						#write-host
						$fieldItm = "" | Select FieldTitle, FieldInternalName	,SourceListID,SourceListTitle
						$fieldItm.SourceListID = $SourceListID					
						$fieldItm.SourceListTitle = $SourceListName.Title					
						$fieldItm.FieldTitle = $fld.Title					
						$fieldItm.FieldInternalName = $fld.InternalName		
						$FieldArr += $fieldItm
						
					}
				}
			}
		}
	}
	return $FieldArr	
}

	$srcSiteUrl   = "https://gss.ekmd.huji.ac.il/home/Humanities/HUM16-2020/"
 $homeweb = Get-SPWeb  $srcSiteUrl
$listName="applicants"
$listName="סוג מסלול"
$listName="נכסים של אתר"
$listName="FolderPDF"
$listName="applicants"
$appl = $homeweb.Lists[$listName]
$fa=$appl.Fields | Select Title,Type,Hidden,InternalName,SchemaXml 
	$ServiceLookupFields = "ItemChildCount","FolderChildCount","AppAuthor","AppEditor",
							"ParentVersionString","ParentLeafName","_CheckinComment","ContentType"

$FieldArr = get-LookupArray $fa
$FieldArr
#$fa | where{!$_.Hidden -and $_.Type.ToString() -eq 'Lookup'}



