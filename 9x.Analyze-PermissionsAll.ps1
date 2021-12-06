
$groups = get-content .\grsList.txt

$groups
#read-host

$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"
foreach($groupName in $groups)	
{
	if (Test-CurrentSystem $groupName){
		$jsonFile = "JSON\"+$groupName+".json"
		if (Test-Path $jsonFile){
			write-host "Group: $groupName" -foregroundcolor Green
			$Credentials = get-SCred	
			
			$spObj = get-content $jsonFile -encoding default | ConvertFrom-Json
			
			
			$siteUrl    = get-CreatedSiteName $spObj
			$oldSiteURL = $spObj.oldSiteURL
			$oldSiteSuffix = $spObj.OldSiteSuffix
			if ([string]::isNullOrEmpty($oldSiteSuffix)){
				$oldSiteSuffix = $spObj.oldSiteURL.split("/")[-2]
			}
			
			write-Host	$oldSiteSuffix -foregroundcolor Yellow
			write-host "Old Site: $oldSiteURL" -foregroundcolor Cyan
			write-host "New Site: $siteUrl" -foregroundcolor Magenta
			#write-Host Press Key ...
			#read-host
			
			if (![string]::isNullOrEmpty($oldSiteSuffix)){
					
			
			
				$fileNameSrc = ".\JSON\"+ $groupName+"-MenuDmp-Src.json"
				$fileNameDst = ".\JSON\"+ $groupName+"-MenuDmp-Dst.json"
				if ((Test-Path $fileNameSrc) -and
					(Test-Path $fileNameDst)){
						
						$spSrc = get-content $fileNameSrc -encoding default | ConvertFrom-Json
						$spDst = get-content $fileNameDst -encoding default | ConvertFrom-Json
						
						$outReport = @()
						foreach($itemMenu in $spDst){
							forEach($itemSubm in $itemMenu.Items){
								if ($itemSubm.Type -eq "Lists" -or $itemSubm.Type -eq "DocLib" ){
									$listItemExists = $false
									forEach($rp in $outReport){
										if ($rp.List -eq $itemSubm.Name){
											$listItemExists = $true
											break;
										}
									}
									if (!$listItemExists){
										
										$permDiff = get-DestListObjPerm $spObj.RelURL $oldSiteSuffix  $spSrc $itemSubm.Name $itemSubm.ListPermissons
										if (![string]::IsNullOrEmpty($permDiff)){
											$repObj = "" | Select Group, SiteSource, SiteDest, List ,PermDifference
											$repObj.Group = $groupName
											$repObj.SiteSource = $siteUrl
											$repObj.SiteDest = $oldSiteURL
											$repObj.List = $itemSubm.Name
											$repObj.PermDifference = $permDiff
											$outReport += $repObj 
										}
									}
								}
							}
							
						}
						#$w1255File = 
						$outFile =".\SiteReport\"+$groupName +".csv"
						$outReport | Export-CSV $outFile -Encoding UTF8
						
				}
				else
				{
					write-host "$fileNameSrc Does Not Exist Or"  -foregroundcolor Yellow
					write-host "$fileNameDst Doesn't  Exist"  -foregroundcolor Yellow
				}			
			}
		}	
	}
	else
	{
		Write-Host "Group Name $groupName is not valid!" -foregroundcolor Yellow
	}	
		
}