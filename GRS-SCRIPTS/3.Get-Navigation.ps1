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
			
			
			
			write-host "Old Site: $oldSiteURL" -foregroundcolor Cyan
			write-host "New Site: $siteUrl" -foregroundcolor Green
			write-host "Pause..."
			read-host
			
			$navMenu = Get-NavigationMenu  $spObj.oldSiteURL
			
			#$navMenu
			$hebrDocLibName = "העלאת מסמכים"
			$EngDocLibName  = "Documents Upload"
			foreach($item in $navMenu)
			{
				If ($item.Title.Contains($hebrDocLibName) -or
					$item.Title.Contains($EngDocLibName)  -or
					$item.Url.Contains("applicants")      -or
					$item.Url.Contains("Submitted")       -or
					$item.Url.Contains("DocType")         -or
					$item.Url.Contains("Final")){
						
				}
				else
				{
					if ($item.Url.Contains("AllItems.aspx")){
						if ($item.Url.Contains("Forms")){
							$idx = -3
						}
						else
						{
							$idx = -2
						}
						$docLibName = $item.Url.Split("/")[$idx]
						write-host "-----------------"
						write-host $item.Title
						write-host $item.Url
						write-host $docLibName
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