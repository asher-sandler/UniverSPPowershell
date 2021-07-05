param([string] $groupName = "")


$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
$wrkSite 		=  "https://portals.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace"
$productionSite =  "https://hss.ekmd.huji.ac.il/home"

$userName = "ekmd\ashersa"
$userPWD = "GrapeFloor789"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"


if ([string]::isNullOrEmpty($groupName))
{
	write-host groupName Must be specified 
	write-host in format hss_HUM164-2021 
	
}
else
{

	#Load SharePoint CSOM Assemblies

	$crlf = [char][int]13+[char][int]10
	if (Test-CurrentSystem $groupName){	

		$spRequestsListObj = get-RequestListObject
		# $spRequestsListObj

		if ($spRequestsListObj.GroupName.ToUpper()  -eq $groupName.Trim().ToUpper()){
			
			if (Test-ScholarShipItemExist $spRequestsListObj ){
				$currentSystem = Get-CurrentSystem $groupName
				$currentList = $currentSystem.appHomeUrl + "lists/"+$currentSystem.listName
				$isImplemented = $currentSystem.isImplemented

				

				Write-Host "CurrentSystem: $($currentSystem.appTitle)" -foregroundcolor Yellow
				Write-Host "CurrentList: $(get-UrlWithF5 $currentList)" -foregroundcolor Yellow
				Write-Host "Implemented: $isImplemented" -foregroundcolor Yellow
				
				
				$facultyList = Get-FacultyList $($currentSystem.appHomeUrl)
				
				#write-Host $facultyList
				
				Write-TextConfig $spRequestsListObj $groupName
				$spRequestsListObj | ConvertTo-Json -Depth 100 | out-file $("JSON\"+$groupName+".json")
				
				Add-SiteList $spRequestsListObj[0] $facultyList
				Change-GroupDescription $groupName $spRequestsListObj[0].siteNameEn
				Add-GroupMember $groupName $spRequestsListObj[0].contactEmail $spRequestsListObj[0].userName
			}
			else
			{
				write-Host "$groupName already exists in $($($spRequestsListObj[0]).systemListUrl)." -foregroundcolor Yellow
				write-Host "No items were added." -foregroundcolor Yellow
			}
		}
		else
		{
			Write-Host "Group $groupName not found in spRequestsList." -foregroundcolor Yellow
		}
	}
	else
	{
		Write-Host "Group Name $groupname is not valid!"
	}
}	

