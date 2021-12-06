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
			write-host "New Site: $siteUrl" -foregroundcolor Magenta
			#write-Host Press Key ...
			#read-host
			$oldSiteSuffix = $spObj.OldSiteSuffix
			if ([string]::isNullOrEmpty($oldSiteSuffix)){
				$oldSiteSuffix = $spObj.oldSiteURL.split("/")[-2]
			}
						
		
			$fileNameSrc = ".\JSON\"+ $groupName+"-MenuDmp-Src.json"
			$fileNameDst = ".\JSON\"+ $groupName+"-MenuDmp-Dst.json"
			if ((Test-Path $fileNameSrc) -and
				(Test-Path $fileNameDst)){
					
					cls
					write-host "Procedure 8.Dump-Site.ps1 $groupName Was Created Files:" -f Green
					write-host "Reading file: $fileNameSrc" -f Yellow
					write-host "Reading file: $fileNameDst" -f Magenta
					
					$spSrc = get-content $fileNameSrc -encoding default | ConvertFrom-Json
					$spDst = get-content $fileNameDst -encoding default | ConvertFrom-Json
					
					$outReport = @()
					foreach($itemMenu in $spDst){
						forEach($itemSubm in $itemMenu.Items){
							if ($itemSubm.Type -eq "Lists" -or $itemSubm.Type -eq "DocLib" ){
								$listItemExists = $false
								# смотрим что мы еще не обрабатывали этот список.
								# проверяем в обекьте $outReport
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
					
					$outReport | Export-CSV $outFile -Encoding UTF8 -NoTypeInfo
					write-Host "Written file : $outFile"
					Invoke-Expression $outFile
					$outJson = ".\JSON\"+$groupName +"-Permissions.json"
					$outReport | ConvertTo-Json -Depth 100 | out-file $outJson -Encoding Default
					write-Host "Written file : $outJson"
					
			}
			else
			{
				write-host "$fileNameSrc Does Not Exist Or"  -foregroundcolor Yellow
				write-host "$fileNameDst Doesn't  Exist"  -foregroundcolor Yellow
			}			
		}
		
	}
	else
	{
		Write-Host "Group Name $groupName is not valid!" -foregroundcolor Yellow
	}	
		
}