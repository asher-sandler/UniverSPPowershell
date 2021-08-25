param([string] $groupName = "")


$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "..\Utils-Request.ps1"
. "..\Utils-DualLanguage.ps1"
if ([string]::isNullOrEmpty($groupName))
{
	write-host groupName Must be specified  -foregroundcolor Yellow
	write-host in format hss_HUM164-2021  -foregroundcolor Yellow
	
}
else
{
	if (Test-CurrentSystem $groupName){
		$jsonFile = "..\JSON\"+$groupName+".json"
		if (Test-Path $jsonFile){
			write-host "Group: $groupName" -foregroundcolor Green
			$Credentials = get-SCred	
			
			$spObj = get-content $jsonFile -encoding default | ConvertFrom-Json
			
			
			$siteUrl    = get-CreatedSiteName $spObj
			$oldSiteURL = $spObj.oldSiteURL
			
			$siteUrl
			$oldSiteURL
			$docLibNames = @()
			$docLibNames += "עדי בן-דוד"
			$docLibNames += "בועז צבר"
			$docLibNames += "סמירה עליאן"
			$docLibNames += "אסמהאן מסרי-חרזאללה"
			$docLibNames += "פרידה ניסים-אמיתי"
            foreach($docLibName in $docLibNames){ 
				$SrcFieldsOrder = get-FormFieldsOrder $docLibName $oldSiteURL
				
				
				$DestFieldOrder    = get-FormFieldsOrder $docLibName $siteURL
				#write-host $DestFieldOrder
				#check for Field in Destination exist in Source
				$newFieldOrder = checkForArrElExists $SrcFieldsOrder $DestFieldOrder
				if ($false){
					ConvHexFieldToName "_x05de__x05e1__x05dc__x05d5__x05dc_"
					write-host "==============="
					$xNewOrd = @()
					for($i =0; $i -lt $newFieldOrder.count;$i++){
						$xNewOrd += $newFieldOrder[$i]
						if ($i -eq 2){
							$xNewOrd += "_x05de__x05e1__x05dc__x05d5__x05dc__x05d9__x05dd_"
						}
						#write-host $newFieldOrder[$i]
						#If ($newFieldOrder[$i].contains("_x")){
						#	Write-Host $(ConvHexFieldToName $newFieldOrder[$i] )
						#}
						#if ($newFieldOrder[$i].contains("_x05de__x05e1__x05dc__x05d5__x05dc_")){
							
						#	$newFieldOrder[$i] = "_x05de__x05e1__x05dc__x05d5__x05dc_"
						#}
					}
					reorder-FormFields $docLibName	$siteURL $xNewOrd
				}
				else
				{
					reorder-FormFields $docLibName	$siteURL $newFieldOrder
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