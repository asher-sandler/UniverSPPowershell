param([string] $groupName = "")


$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"
if ([string]::isNullOrEmpty($groupName))
{
	write-host groupName Must be specified  -foregroundcolor Yellow
	write-host in format hss_HUM164-2021  -foregroundcolor Yellow
	
}
else
{
	if (Test-CurrentSystem $groupName){
		$jsonFile = "JSON\"+$groupName+".json"
		if (Test-Path $jsonFile){
			write-host "Group: $groupName" -foregroundcolor Green
			$Credentials = get-SCred	
			
			$spObj = get-content $jsonFile -encoding default | ConvertFrom-Json
			
			
			$siteUrl    = get-CreatedSiteName $spObj
			$oldSiteURL = $spObj.oldSiteURL
			
			write-host "Old Site: $oldSiteURL" -foregroundcolor Cyan
			write-host "New Site: $siteUrl" -foregroundcolor Green
			write-Host Press Key ...
			read-host
			# $docLibName = "סמירה עליאן"
			$docLibNames =  @()
			#$docLibNames += "ResponseLetters"
			# $docLibNames += "Biotechnology (890)"
			
			#$docLibNames += "Computer Science (521)"
			#$docLibNames += "Computational Biology (532)"
			#$docLibNames += "Bioengineering (582)"
			#$docLibNames += "אסמהאן מסרי-חרזאללה"
			#$docLibNames += "פרידה ניסים-אמיתי"
			$docLibNames += "applicantsCV"
			#$docLibNames += "C MA and PhD students"
			
			
			foreach($docLibName in $docLibNames){
			
				$schemaDocLibSrc1 =  get-ListSchema $oldSiteURL $docLibName
				write-Host 48
				read-host
				#$schemaDocLib1 | ConvertTo-Json -Depth 100 | out-file $("JSON\"+$groupName+"-DocLib1.json")
				$sourceDocObj = get-SchemaObject $schemaDocLibSrc1 
				$sourceDocObj | ConvertTo-Json -Depth 100 | out-file $("JSON\"+$groupName+"-DocLibSrc1.json")
				create-DocLib $siteUrl $docLibName
				
				# ======================= new DocLib
				$schemaDocLibDst1 =  get-ListSchema $siteUrl $docLibName
				$dstDocObj = get-SchemaObject $schemaDocLibDst1 
				$dstDocObj | ConvertTo-Json -Depth 100 | out-file $("JSON\"+$groupName+"-DocLibDst1.json")
					
				foreach($srcEl in $sourceDocObj){
						$fieldExists = $false
						foreach($dstEl in $dstDocObj){
							if ($srcEl.Name -eq $dstEl.Name){
								write-Host "$($dstEl.Name) Exists in Destination List" -foregroundcolor Yellow
								$fieldExists = $true
								break
							}
							
						}
						if (!$fieldExists){
							write-Host "Add $($srcEl.DisplayName) to Destination List" -foregroundcolor Green
							$type= $srcEl.Type
							switch ($type)
							{
								"Text" {
									Write-Host "It is Text.";
									add-TextFields $siteUrl $docLibName $srcEl;
									Break
									}
								
								"Choice" {
									Write-Host "It is Choice.";
									add-ChoiceFields $siteUrl $docLibName $srcEl;
									Break
									}
									
								"Note" {
									Write-Host  "It is Note.";
									add-NoteFields $siteUrl $docLibName $srcEl;
									Break}
									
								"Boolean" {
									Write-Host  "It is Boolean.";
									add-BooleanFields $siteUrl $docLibName $srcEl;
									Break}
									
								"DateTime" {
									Write-Host  "It is DateTime.";
									add-DateTimeFields $siteUrl $docLibName $srcEl;
									Break}
									
								Default {
									Write-Host "No matches"
										}
							}					
						}
									
					}
					$SrcFieldsOrder = get-FormFieldsOrder $docLibName $oldSiteURL
					
					$DestFieldOrder    = get-FormFieldsOrder $docLibName $siteURL
					
					#check for Field in Destination exist in Source
					$newFieldOrder = checkForArrElExists $SrcFieldsOrder $DestFieldOrder
					reorder-FormFields $docLibName	$siteURL $newFieldOrder
					
					$objViews = Get-AllViews $docLibName $oldSiteURL
			 
					$objViews | ConvertTo-Json -Depth 100 | out-file $("JSON\"+$docLibName+"-Views.json")
					
					foreach($view in $objViews){
						$viewExists = Check-ViewExists $docLibName  $siteURL $view 
						if ($viewExists.Exists){
							write-host "view $($view.Title) exists on $newSite" -foregroundcolor Green
							#check if first field in source view is on destination view
							$firstField = $view.Fields[0]
							write-host "First field in source view : $firstField"
							$fieldInView = check-FieldInView  $docLibName $($viewExists.Title) $siteURL $firstField
							write-host "$firstField on View : $fieldInView"
							#if not {add this field}
							if (!$fieldInView){
								Add-FieldInView $docLibName $($viewExists.Title) $siteURL $firstField
								
							}
							#delete all fields in destination from view but first field in source
							 
							remove-AllFieldsFromViewButOne $docLibName $($viewExists.Title) $siteURL $firstField
							Add-FieldsToView $docLibName $($viewExists.Title) $siteURL $($view.Fields)
							#add other view
							Rename-View $docLibName $($viewExists.Title) $siteURL $($view.Title) $($view.ViewQuery)
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
							Create-NewView $siteURL $docLibName $viewName  $($view.Fields) $($view.ViewQuery) $($view.Aggregations) $viewDefault
						}
					}
								
					


			}	
	
			
		}
		else
		{
			Write-Host "File $jsonFile does not exists." -foregroundcolor Yellow
			Write-Host "Run 1.Get-SPRequest.ps1 first. " -foregroundcolor Yellow
		}
	}
	else
	{
		Write-Host "Group Name $groupName is not valid!" -foregroundcolor Yellow
	}
}	