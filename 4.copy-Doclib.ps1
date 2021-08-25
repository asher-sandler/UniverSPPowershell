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
			
			$siteUrl
			$oldSiteURL
			
			$docLibName = "סמירה עליאן"
			$schemaDocLibSrc1 =  get-ListSchema $oldSiteURL $docLibName
			
			#$schemaDocLib1 | ConvertTo-Json -Depth 100 | out-file $("JSON\"+$groupName+"-DocLib1.json")
	        $sourceDocObj = get-SchemaObject $schemaDocLibSrc1 
			$sourceDocObj | ConvertTo-Json -Depth 100 | out-file $("JSON\"+$groupName+"-DocLibSrc1.json")
			
			
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