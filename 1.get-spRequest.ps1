param([string] $groupName = "",

	[Parameter(Mandatory=$false)]
	[ValidateSet("No", "Yes")]
	[string[]]$Force = "No",
	
	[ValidateSet("No", "Yes")]
	[string[]]$InitUser = "No"
	
	)
# https://www.nuget.org/packages/Microsoft.SharePointOnline.CSOM#versions-body-tab
# dotnet add package Microsoft.SharePointOnline.CSOM --version 16.1.21812.12000	
# nuget.exe install Microsoft.SharePointOnline.CSOM
# cd \AdminDir\nuget
# Install-Package -Name 'Microsoft.SharePointOnline.CSOM' -Source .\Microsoft.SharePointOnline.CSOM.16.1.21812.12000
#Import-Module 'C:\nuget\Microsoft.SharePointOnline.CSOM.16.1.21812.12000\lib\net45\Microsoft.SharePoint.Client.dll
write-host "Init User: $InitUser"
$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
$wrkSite 		=  "https://portals.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace"
$productionSite =  "https://hss.ekmd.huji.ac.il/home"

#$userName = "ekmd\ashersa"
#$userPWD = ""


Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"


if ([string]::isNullOrEmpty($groupName))
{
	write-host groupName Must be specified 
	write-host in format hss_HUM164-2021 
	
}
else
{
	$isIniExists = Write-IniFile $InitUser
    if ($isIniExists){	
	    $Credentials = get-SCred
		$currentYear = $(Get-Date).Year.ToString()
		if ($GroupName.Contains($currentYear) -or $Force.ToUpper() -eq "YES"){

			#Load SharePoint CSOM Assemblies

			$crlf = [char][int]13+[char][int]10
			if (Test-CurrentSystem $groupName){	

				$spRequestsListObj = get-RequestListObject
				if (!$spRequestsListObj.isUserContactEmpty ){
					# $spRequestsListObj
					write-Host $spRequestsListObj.GroupName
					#read-host
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
							Save-spRequestsFileAttachements $spRequestsListObj[0]
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
					Write-Host "Contacts not Found! Please Fill User Contact Fields in spRequestsList!" -foregroundcolor Yellow
				}
			}
			else
			{
					Write-Host "Group Name $groupname is not valid!"
			}		
		}else
		{
			write-Host "Group $groupName contains not current year." -foregroundcolor Yellow
			write-Host "Current year is: $currentYear." -foregroundcolor Yellow
			write-Host "If you still want to use this group, use switch -Force YES." -foregroundcolor Yellow
		}
	}
}

	

