Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.Portable.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Publishing.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Search.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.UserProfiles.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"

	$0 = $myInvocation.MyCommand.Definition
	$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "..\Utils-Request.ps1"
. "..\Utils-DualLanguage.ps1"

 $Credentials = get-SCred	
 $newRelURL = "GEN31-2021"
 $oldRelURL = "GEN32-2022"
				#https://grs2.ekmd.huji.ac.il/home/OverseasApplicantsUnit
 $newSite    = "https://grs2.ekmd.huji.ac.il/home/OverseasApplicantsUnit/" + $newRelURL
 $oldSite 	= "https://grs2.ekmd.huji.ac.il/home/OverseasApplicantsUnit/"+$oldRelURL
 
 write-host "Old Site: $oldSite" -foregroundcolor Cyan
 write-host "New Site: $newSite" -foregroundcolor Green

 $listName = "Applicants"
 $objViews = Get-AllViews $listName $oldSite
 $objViewsnew = Get-AllViews $listName $newSite 

 $outFileName = "..\JSON\"+$oldRelURL+"-Applicants-Views.json"	 
 #$objViews = get-content $outFileName -encoding default | ConvertFrom-Json

 $objViews | ConvertTo-Json -Depth 100 | out-file $outFileName
 write-host "$outFileName was created" -f Green
 
 $outFileName = "..\JSON\"+$newRelURL+"-Applicants-Views.json"	 
 #$objViewsnew  = get-content $outFileName -encoding default | ConvertFrom-Json
 $objViewsnew | ConvertTo-Json -Depth 100 | out-file $outFileName
 write-host "$outFileName was created" -f Green
 write-host 
 write-host 
 
 
 $badFields = @()
 
 foreach($viewOld in $objViews){
	$viewFound =  $false
	$oldViewTitle = $viewOld.Title
	#write-host $oldViewTitle -f Yellow
	
	foreach ($viewNew in $objViewsnew){
		
		 if ($oldViewTitle -eq $viewNew.Title){
			 $fieldsInOldView = $viewOld.Fields
			 $fieldsInNewView = $viewNew.Fields
			 
			 $fieldsNotFound = "" | Select-Object ViewName, Fields
			 $fieldsNotFound.ViewName = $oldViewTitle
			 $fieldsNotFound.Fields = @()
			 
			 
			 $fieldFound = $false
			 foreach($fieldOld in $fieldsInOldView)
			 {
				foreach($fieldNew in $fieldsInNewView){
					if ($fieldOld -eq $fieldNew){
						$fieldFound = $true
						break
					}
				}
				if (!$fieldFound){
					$fieldsNotFound.Fields += $fieldOld
				}
			 }
			 $badFields += $fieldsNotFound
			 $viewFound = $true
			 break
		 }
		
	 }
	 if (!$viewFound){
			 write-host "$($viewOld.Title) not found in $newSite" -f Cyan
	 }
	
	

	 
 }
 
 $outFileName = "..\JSON\"+$newRelURL+"-BadFields.json"	 
 $badFields | ConvertTo-Json -Depth 100 | out-file $outFileName
 write-host "$outFileName was created" -f Green
 write-host 
 write-host
 
 $outFileName = "..\JSON\"+$newRelURL+"-schema.json"	 
 
 	$newListSchema = get-ListSchema $newSite $listName
 $newListSchema | ConvertTo-Json -Depth 100 | out-file $outFileName
 write-host "$outFileName was created" -f Green
$outFileName = "..\JSON\"+$oldRelURL+"-schema.json"	 
 	
	$oldListSchema = get-ListSchema $oldSite $listName
 $oldListSchema | ConvertTo-Json -Depth 100 | out-file $outFileName
 write-host "$outFileName was created" -f Green
	
	
	$schemaDifference = get-SchemaDifference $oldListSchema $newListSchema
 $outFileName = "..\JSON\"+$newRelURL+"-schemaDiff.json"	 
 $schemaDifference | ConvertTo-Json -Depth 100 | out-file $outFileName
 write-host "$outFileName was created" -f Green
 	
$fieldsToCreate = @()	
foreach($itm in $schemaDifference){
	$fieldToCreateObj = "" | Select-Object Name, Type, DisplayName, Schema, Choice, Required, Format
	
	$fieldToCreateObj.DisplayName = Select-Xml -Content $itm  -XPath "/Field" | ForEach-Object {$_.Node.DisplayName}
	$fieldToCreateObj.Name = Select-Xml -Content $itm  -XPath "/Field" | ForEach-Object {$_.Node.Name}
	$fieldToCreateObj.Type = Select-Xml -Content $itm  -XPath "/Field" | ForEach-Object {$_.Node.Type}
	$fieldToCreateObj.Required = Select-Xml -Content $itm  -XPath "/Field" | ForEach-Object {$_.Node.Required}
	$fieldToCreateObj.Format = Select-Xml -Content $itm  -XPath "/Field" | ForEach-Object {$_.Node.Format}
	$fieldsToCreate += $fieldToCreateObj
	
	
	 

}
write-host "Not found in $newSite"
$fieldsToCreate | fl



write-host 132
write-host "fieldsToCreate :" $fieldsToCreate.Count
#read-host
foreach($fld in $fieldsToCreate){
				$type= $fld.Type
				switch ($type)
				{
						"Text" {
							Write-Host "It is Text.";
							add-TextFields $newSite $listName $fld;
							Break
							}
						
						"Choice" {
							Write-Host "It is Choice.";
							add-ChoiceFields $newSite $listName $fld;
							Break
							}
							
						"Note" {
							Write-Host  "It is Note.";
							add-NoteFields $newSite $listName $fld;
							Break}
							
						"Boolean" {
							Write-Host  "It is Boolean.";
							add-BooleanFields $newSite $listName $fld;
							Break}
							
						"DateTime" {
							Write-Host  "It is DateTime.";
							add-DateTimeFields $newSite $listName $fld;
							Break}
							
						Default {
							Write-Host "No matches"
								}
				}	
}


<#
 $newRelURL = "GEN31-2021"
 $oldRelURL = "GEN32-2022"

 $newSite    = "https://grs2.ekmd.huji.ac.il/home/OverseasApplicantsUnit/" + $newRelURL
 $oldSite 	= "https://grs2.ekmd.huji.ac.il/home/OverseasApplicantsUnit/"+$oldRelURL
 
 write-host "Old Site: $oldSite" -foregroundcolor Cyan
 write-host "New Site: $newSite" -foregroundcolor Green

 $listName = "Applicants"
#>
		    #$SrcFieldsOrder = get-FormFieldsOrder $listName $oldSite

 $outFileName = ".\JSON\"+$oldRelURL+"-FormFields.json"	
$SrcFieldsOrder = get-content ".\JSON\GEN32-2022-FormFields-Makor.json" -encoding default | ConvertFrom-Json 
 $SrcFieldsOrder | ConvertTo-Json -Depth 100 | out-file $outFileName
 write-host "$outFileName was created" -f Green
			
			$DestFieldOrder    = get-FormFieldsOrder $listName $newSite
 $outFileName = ".\JSON\"+$newRelURL+"-FormFields.json"	 
 $DestFieldOrder | ConvertTo-Json -Depth 100 | out-file $outFileName
 write-host "$outFileName was created" -f Green

			
			#check for Field in Destination exist in Source
			$newFieldOrder = checkForArrElExists $SrcFieldsOrder $DestFieldOrder
 $outFileName = ".\JSON\New-FormFields.json"	 
 $newFieldOrder | ConvertTo-Json -Depth 100 | out-file $outFileName
 write-host "$outFileName was created" -f Green

			
			reorder-FormFields $listName	$newSite $newFieldOrder
 write-host 198
read-host


	foreach($view in $objViews){
		$viewExists = Check-ViewExists $listName  $newSite $view 
		if ($viewExists.Exists){
			write-host "view $($view.Title) exists on $newSite" -foregroundcolor Green
			#check if first field in source view is on destination view
			$firstField = $view.Fields[0]
			write-host "First field in source view : $firstField"
			$fieldInView = check-FieldInView  $listName $($viewExists.Title) $newSite $firstField
			write-host "$firstField on View : $fieldInView"
			#if not {add this field}
			if (!$fieldInView){
				Add-FieldInView $listName $($viewExists.Title) $newSite $firstField
				
			}
			#delete all fields in destination from view but first field in source
			 
			remove-AllFieldsFromViewButOne $listName $($viewExists.Title) $newSite $firstField
			Add-FieldsToView $listName $($viewExists.Title) $newSite $($view.Fields)
			#add other view
			Rename-View $listName $($viewExists.Title) $newSite $($view.Title) $($view.ViewQuery)
		}
		else
		{
			
			$viewName = $($view.Title)
			if ([string]::isNullOrEmpty($viewName)){
				$viewName = $($view.ServerRelativeUrl.Split("/")[-1]).Replace(".aspx","")
				
			}
			write-host "view $viewName does Not exists on $newSite" -foregroundcolor Yellow
			write-host "ViewQuery : $($view.ViewQuery)"
			write-host "Check for View! "
			
			$viewDefault = $false
			Create-NewView $newSite $listName $viewName  $($view.Fields) $($view.ViewQuery) $($view.Aggregations) $viewDefault
		}
	}
