Add-PsSnapin Microsoft.SharePoint.PowerShell
function get-ListSchema($siteURL,$listName){
	
	$fieldsSchema = @()
	$spWeb = get-SPWeb $siteUrl
	$List = $spWeb.lists[$ListName]

	foreach($field in $List.Fields){
		# write-host "$($field.Title) : Hidden : $($field.Hidden)"
		if ($field.SchemaXml.Contains('ReadOnly="TRUE"')){
		}
		else{
			if ($field.SchemaXml.Contains('Group="_Hidden"')){
			}
			else{
		
				If (!($field.Hidden -or $field.ReadOnly )){
					$fieldsSchema += $field.SchemaXml
				}
			}
		}	
	}	
	return $fieldsSchema
}
function get-SchemaDifference($scSrc, $scDst){
	# difference между schema source и schema destination. Чего не хватает в destination
	$fieldsSchema = @()	
	$crlf = [char][int]13+[char][int]10
	
	
	$FieldXMLSrc = '<Fields>'+$crlf
	foreach($elSrc in $scSrc){
		$FieldXMLSrc += $elSrc+$crlf
	}
	$FieldXMLSrc += '</Fields>'

	$FieldXMLDst = '<Fields>'+$crlf
	foreach($elDst in $scDst){
		$FieldXMLDst += $elDst+$crlf
	}
	$FieldXMLDst += '</Fields>'
 
	$sourceFields = Select-Xml -Content $FieldXMLSrc  -XPath "/Fields/Field" | ForEach-Object {
		 $_.Node.DisplayName.Trim().ToLower()
	}
	$destFields = Select-Xml -Content $FieldXMLDst  -XPath "/Fields/Field" | ForEach-Object {
		$_.Node.DisplayName.Trim().ToLower()
	}
	
	$idx =0
    foreach($srcEl in $sourceFields){
		$fieldExistsInDest = $false
		foreach($dstEl in $destFields){
			if ($srcEl -eq $dstEl){
				$fieldExistsInDest = $true
				break
			}
		}
	    if (!$fieldExistsInDest){
			
			 $fieldsSchema += $scSrc[$idx]
		}		
		$idx++
		
	}
	
	return $fieldsSchema	
}
function add-SchemaField($siteURL,$listName,$fieldsSchema){
	$spWebX = Get-SPWeb $siteURL
	$listX = $spWebX.Lists[$listName]
    #Check if the column exists in list already
    $FieldsX = $listX.Fields

	$DisplayName = Select-Xml -Content $fieldsSchema  -XPath "/Field" | ForEach-Object {
			 $_.Node.DisplayName
	}
	$NewField = $FieldsX | where {($_.Title -eq $DisplayName)}
    if($NewField -ne $NULL) 
    {
        Write-host "Column $DisplayName already exists in the List!" -f Yellow
    }
    else
    {
		$newField = $listX.Fields.AddFieldAsXml($fieldsSchema, $True,[Microsoft.SharePoint.SPAddFieldOptions]::AddFieldToDefaultView)
		
		Write-host "Column $DisplayName was Add to the $listName Successfully!" -ForegroundColor Green
	}	
	return $null
 	
}
function Copy-DefaultQuery($srcURL, $dstURL, $listName){
	$spWebSrc = Get-SPWeb  $srcURL
	$spWebDst = Get-SPWeb  $dstURL
	
    $listSrc = 	$spWebSrc.Lists[$listName]
	$listDst =  $spWebDst.Lists[$listName]
	
	$aggrSrc = $listSrc.DefaultView.Aggregations
	
	$dstDefView = $listDst.DefaultView
	$dstDefView.ViewFields.DeleteAll();
	foreach($xF in $listSrc.DefaultView.ViewFields){
		write-Host $xF
		$dstDefView.ViewFields.Add($xF)	
	}	
	$dstDefView.Query = $listSrc.DefaultView.Query
	$dstDefView.Aggregations = $aggrSrc
	
	$dstDefView.Update()
	$listDst.Update()

}
<#
#$objViews = Get-AllViews $srcdocLibName $siteUrl
function Get-AllViews($siteURL, $listName){
	$arrViews = @()
	$spWebX = Get-SPWeb $siteURL
	$listX = $spWebX.Lists[$listName]
	
	
	$viewCollection = $ListX.Views
		
	foreach($view in $viewCollection){
		$viewFieldsColl = $view.ViewFields

		$objView = "" | Select-Object DefaultView,Aggregations,Title, ServerRelativeUrl,ViewQuery,Fields
		$objView.DefaultView = $view.DefaultView
		$objView.Aggregations =  $view.Aggregations
		$objView.Title =  $view.Title
		$objView.ServerRelativeUrl =  $view.ServerRelativeUrl
		$objView.ViewQuery =  $view.ViewQuery
		
		$arrFields = @()
		foreach($fld in $viewFieldsColl)
		{
			$arrFields += $fld
		}
		$objView.Fields = $arrFields
		
		#$view | gm
		#$view | fl
		#write-Host $view.Title
		$arrViews += $objView
	}
	return $arrViews	
}
function Check-ViewExists($siteURL,$listName,$viewObj){
	$viewExists = "" | Select-Object Exists, Title, TitleOld
	$viewExists.Exists = $false
	$viewExists.Title = $null
	
	$spWebX = Get-SPWeb $siteURL
	$listX = $spWebX.Lists[$listName]
	
	$viewCollection = $ListX.Views
	foreach($view in $viewCollection){
		$relUrls = $view.ServerRelativeUrl.split("/")[-1]
		# write-Host $relUrls -> AllItems.aspx
		$relUrlo = $viewObj.ServerRelativeUrl.split("/")[-1]
		
		if (($relUrls -eq $relUrlo) -or ($view.Title -eq $viewObj.Title)){
			#Write-Host "Site View : $relUrls"
			#Write-Host "Obj View : $relUrlo"
			$viewExists.Exists = $true
			$viewExists.Title = $view.Title
			$viewExists.TitleOld = $viewObj.Title
			break
		}
		
	}
	#write-Host 5206
	#read-host
	return $viewExists
}
function Copy-QueryFields($srcURL, $dstURL, $listName){
	$spWebSrc = Get-SPWeb  $srcURL
	$spWebDst = Get-SPWeb  $dstURL
	
    $listSrc = 	$spWebSrc.Lists[$listName]
	$listDst =  $spWebDst.Lists[$listName]

	$schemaListDst1 =  get-ListSchema $dstURL $listName
 
	$dstListObj = get-SchemaObject $schemaListDst1
	$outFileName =$listName+"-ListDest.json"
	$dstListObj | ConvertTo-Json -Depth 100 | out-file $outFileName
	Write-Host "Created File : $outFileName"
 
   	$dstDefView.ViewFields.DeleteAll();


    $outFileName = $listName+"-Views.json" 

	$objViews = Get-AllViews $srcURL $listName
	$objViews | ConvertTo-Json -Depth 100 | out-file $($outFileName) 
	write-Host "Views was saved as $outFileName"


	foreach($view in $objViews){
		if ($view.DefaultView){
			$allFieldsExistsOnDest = Check-ForFieldsExistsOnDest $view.Fields $dstListObj
			if (!$allFieldsExistsOnDest.AllFieldExists){
				Write-Host "Error 220: Fields not existing on Destination List $listName :" -f Yellow
				foreach($f in $allFieldsExistsOnDest.FieldNotExistsList){
					write-host $f -f Yellow
				}			
			}
		}		
	}  
	#foreach($view in $objViews){
	#	$viewExists = Check-ViewExists   $dstURL $docLibName $view 
		
	
	
}
function Check-ForFieldsExistsOnDest ($vFields, $dstListObj){
	$outObj = "" | Select AllFieldExists, FieldNotExistsList
	$outObj.AllFieldExists = $true
	$outObj.FieldNotExistsList = @()
	foreach($fld in $vFields){
		$fldExist = $false
		foreach($dstField in $dstListObj){
			if ($dstField.Name -eq $fld){
				$fldExist = $true
				break
			}
		}
		if (!$fldExist){
			if (($fld -eq "Created") -or $($fld -eq "Modified") -or
				($fld -eq "Edit")    -or $($fld -eq "DocIcon")  -or 
				($fld -eq "Editor")  -or $($fld -eq "LinkFilename")){
			}
			else{	
				$outObj.AllFieldExists = $false
				$outObj.FieldNotExistsList += $fld
			}
		}
	}
	return $outObj
}
function get-SchemaObject($schema)
{
	$schemaObj = @()
	foreach($line in $schema){
				$fieldObj = "" | Select-Object Name,Type,DisplayName,Schema,Choice,Required,Format
				$fieldObj.Schema = $line
				$fieldObj.Required = "FALSE"
				
				$FieldXMLSrc = '<Fields>'+  $line	 + '</Fields>'
				
				$fieldObj.Name = Select-Xml -Content $FieldXMLSrc  -XPath "/Fields/Field" | ForEach-Object {
					$_.Node.Name
				}
				$fieldObj.Type =  Select-Xml -Content $FieldXMLSrc  -XPath "/Fields/Field" | ForEach-Object {
					$_.Node.Type
				}
				$fieldObj.DisplayName =  Select-Xml -Content $FieldXMLSrc  -XPath "/Fields/Field" | ForEach-Object {
					$_.Node.DisplayName
				}
				$fieldRequiered =  Select-Xml -Content $FieldXMLSrc  -XPath "/Fields/Field" | ForEach-Object {
					$_.Node.DRequired
				} 	
				
				if (![string]::IsNullOrEmpty($fieldRequiered)){
					If ($fieldRequiered -eq "TRUE"){
						$fieldObj.Required = "TRUE"
					}
				}
				
				if ($fieldObj.Type -eq "Choice"){
					$fieldObj.Choice = get-ChoiceOption $line
					$fieldObj.Format =  Select-Xml -Content $FieldXMLSrc  -XPath "/Fields/Field" | ForEach-Object {
					$_.Node.Format
					} 
					
				}
				$schemaObj += $fieldObj

			}
    return $schemaObj
}
#>
$siteURL = "https://gss2.ekmd.huji.ac.il/home/Humanities/HUM13-2020"
$siteURLArch = "https://gss2.ekmd.huji.ac.il/home/Humanities/HUM13-2020/Archive-2022-09-30-3"

$listName = "EKMDSemiixiiiH1"
$listName = "העלאת מסמכים - SemIIXIII HumXIII 987654313"
#$listURL = "/Lists/"+$listName
#$spsite = Get-SPSite $siteURL
$spWeb = Get-SPWeb $siteURL
#$doclib = $spweb.GetList($listURL)
#$doclib = $spWeb.GetList($spWeb.ServerRelativeUrl+$listURL)
$doclib = $spWeb.Lists[$listName]

write-host $doclib

$dstDefView = $doclib.DefaultView

$dstDefView.Query

$finalListName = "Final"
$listSchemaOrigin  = get-ListSchema $siteURL $finalListName
$listSchemaArchive = get-ListSchema $siteURLArch $finalListName

$schemaDiff = get-SchemaDifference $listSchemaOrigin $listSchemaArchive

foreach($fieldsSchema in $schemaDiff){
	#write-Host $fieldschema -f Yellow
	add-SchemaField  $siteURLArch $finalListName $fieldsSchema
}

Copy-DefaultQuery $siteURL $siteURLArch $finalListName
#Copy-QueryFields  $siteURL $siteURLArch $finalListName



