
param([string] $groupName = "")

Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.Portable.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Publishing.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Search.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.UserProfiles.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"

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
			
			
			$newSite    = get-CreatedSiteName $spObj
			$oldSite 	= $spObj.oldSiteURL
			#write-host "Old Site: $oldSite" -foregroundcolor Cyan
			write-host "New Site: $newSite" -foregroundcolor Green
			write-host "Pause..." -foregroundcolor Cyan
			#read-host 
	

			$ListName = "ResponseLetters"
			$listTemplateName = "RespLettr"

			$siteName = get-UrlNoF5 $newSite
			
			$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
			$ctx.Credentials = $Credentials
		 
		 
			$Lists = $Ctx.Web.Lists
			$Ctx.Load($Lists)
			#Get the Custom list template
			$Site = $ctx.site
			$Ctx.Load($Site)
			$Ctx.ExecuteQuery()
			#$site | fl
			
			
			$RootWeb = $site.RootWeb
			$Ctx.Load($RootWeb)
			$Ctx.ExecuteQuery()
			$RootWeb | gm
			
			$ListTemplates=$Ctx.site.GetCustomListTemplates($Ctx.site.RootWeb)
			#$ListTemplates=$Ctx.site.GetCustomListTemplates($RootWeb)
			$Ctx.Load($ListTemplates)
			$Ctx.ExecuteQuery()
			
			
			$olistTemplateCollection = $ctx.Web.ListTemplates;
			 $ctx.Load($olistTemplateCollection);
			 $ctx.ExecuteQuery();
 			#$olistTemplateCollection
			write-Host $listTemplateName -f Yellow
			foreach ($Templ in $ListTemplates )
			{
				# write-Host $($Templ.InternalName) -f Yellow
			}
			#Filter Specific List Template
			$ListTemplate = $ListTemplates | where { $_.Name -eq $listTemplateName } 
			If($ListTemplate -ne $Null)
			{
				#Check if the given List exists
				$List = $Lists | where {$_.Title -eq $ListName}
				If($List -eq $Null)
				{
					#Create new list from custom list template
					$ListCreation = New-Object Microsoft.SharePoint.Client.ListCreationInformation
					$ListCreation.Title = $ListName
					$ListCreation.ListTemplate = $ListTemplate
					$List = $Lists.Add($ListCreation)
					$Ctx.ExecuteQuery()
					Write-host -f Green "List Created from Custom List Template Successfully!"
				}
				else
				{
					Write-host -f Yellow "List '$($ListName)' Already Exists!"
				}
			}
			else
			{
				Write-host -f Yellow "List Template '$($ListTemplateName)' Not Found!"
			}


			#Create-ListFromTemplate $newSite $ListName $listTemplateName
			

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