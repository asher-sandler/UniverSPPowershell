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
			#write-Host Press Key ...
			#read-host
			
			$oldSuffix = $spObj.OldSiteSuffix
			$newSuffix = $spObj.RelURL
			
			$flagOldMenu =  $True
			$menuDumpSrc = Collect-Navigation $oldSiteURL $flagOldMenu
			$outfile = ".\JSON\"+ $groupName+"-MenuDmp-Src.json"
			#$menuDumpSrc = get-content $outfile -encoding default | ConvertFrom-Json	
			$menuDumpSrc | ConvertTo-Json -Depth 100 | out-file $outfile -Encoding Default
		
			
			$menuDumpDst = Collect-Navigation $siteUrl $flagOldMenu
			$outfile = ".\JSON\"+ $groupName+"-MenuDmp-Dst.json"
			#$menuDumpDst = get-content $outfile -encoding default | ConvertFrom-Json
			$menuDumpDst | ConvertTo-Json -Depth 100 | out-file $outfile -Encoding Default
						
		
			
	
			#$menuNewItems | ConvertTo-Json -Depth 100 | out-file $outfile -Encoding Default

			
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