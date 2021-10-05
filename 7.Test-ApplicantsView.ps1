param([string] $groupName = "")

Start-Transcript "Test-Applicants-query.log"
$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"

$groups = "GRS_EDU60-2021", "GRS_EDU61-2021", "GRS_EDU62-2022", "GRS_EDU63-2022", "GRS_EDU64-2022", "GRS_EDU65-2022", "GRS_EDU66-2022", "GRS_EDU67-2022", "GRS_EDU68-2022"
$groups = "GRS_EDU69-2022"

foreach ($groupName in $groups){
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
				
				$listName = "Applicants"
				$objViews = Get-AllViews $listName $oldSiteURL
				$objViewsN = Get-AllViews $listName $siteUrl
				$oldSuffix = $oldSiteURL.split("/")[-2]
				write-host "Old Suffix : $oldSuffix" -foregroundcolor Yellow
				$objViews | ConvertTo-Json -Depth 100 | out-file $("JSON\"+$oldSuffix+"-Applicants-Views.json")
				$objViewsN | ConvertTo-Json -Depth 100 | out-file $("JSON\"+$groupName+"-Applicants-Views.json")
				write-host "Pause..."
				read-host 
				
				foreach($vObj in $objViews){
					$oldTitl =  $vObj.Title
					$oldVQuery = $vObj.ViewQuery
					foreach($vObjN in $objViewsN){
						$nwTitl = $vObjN.title
						
						If ($oldTitl -eq $nwTitl){
							write-host "-------------------" -f Yellow
							write-host "Query  $nwTitl" -f Green
							$nwQuery = $vObjN.ViewQuery
							if ($oldVQuery -eq $nwQuery){
								write-host "Query identical" -f Green
							}
							else
							{
								write-host "Query NOT identical" -f Yellow
								Write-Host "Old Qury: $oldVQuery"
								Write-Host "New Qury: $nwQuery"
							}
							
							break;
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
}
stop-transcript
.\"Test-Applicants-query.log"