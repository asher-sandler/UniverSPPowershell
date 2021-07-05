param([string] $groupName = "")

$userName = "ekmd\ashersa"
$userPWD = "GrapeFloor789"


$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
if ([string]::isNullOrEmpty($groupName))
{
	write-host groupName Must be specified 
	write-host in format hss_HUM164-2021 
	
}
else
{
	if (Test-CurrentSystem $groupName){	
	    $currentSystem = Get-CurrentSystem $groupName
		
		$wrkSite = $currentSystem.appHomeUrl
		$wrkList = $currentSystem.listName
		 
		
		
		$spRequestsListObj = get-RequestListObject
		
		
		
		if ($spRequestsListObj.GroupName.ToUpper() -eq $groupName.Trim().ToUpper()){
			$siteUrlC = get-CreatedSiteName $spRequestsListObj
			#write-host "Get Created Site Name: $siteUrlC"
			#read-host
			if (![string]::IsNullOrEmpty($siteUrlC)){
				
				change-ListApplicantsDeadLine 	$siteUrlC $spRequestsListObj
				add-ListApplicants  			$siteUrlC $spRequestsListObj
				change-siteSetting				$siteUrlC
				change-siteTitle $siteUrlC $($spRequestsListObj.siteName)
				#write-host "Old Site Name1 : $($spRequestsListObj.oldSiteURL)"
				#read-host
				if (![string]::isNullOrEmpty($spRequestsListObj.oldSiteURL)){
					$contactUsContent =  get-OldContactUs $($spRequestsListObj.oldSiteURL)
					edt-ContactUs $siteUrlC $contactUsContent
				}
				# write-host $contactUsContent
				
				write-host "Done."	
			}
			else{
				write-host "Site is not created, yet."	
			}
		}	
	}
	else
	{
		Write-Host "Group Name $groupname is not valid!"
	}	
}