
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
			write-host "Old Site: $oldSite" -foregroundcolor Cyan
			write-host "New Site: $newSite" -foregroundcolor Green

			$listName = "Applicants"
			$objViews = Get-AllViews $listName $oldSite
			 
			$objViews | ConvertTo-Json -Depth 100 | out-file $("..\JSON\Applicants-Views.json")
			write-host "Pause..."
			read-host 
			foreach($view in $objViews){
				$viewExists = Check-ViewExists $listName  $newSite $view 
				if ($viewExists.Exists){
					write-host "view $($view.Title) exists on $newSite" -foregroundcolor Green
					#check if first field in source view is on destination view
					$firstField = $view.Fields[0]
					write-host "First field in source view : $firstField"
					$fieldInView = check-FieldInView  $listName $($viewExists.Title) $newSite $firstField
					write-host "$firstField on View : $fieldInView"
					#if not {add this field}
					if (!$fieldInView){
						Add-FieldInView $listName $($viewExists.Title) $newSite $firstField
						
					}
					#delete all fields in destination from view but first field in source
					 
					remove-AllFieldsFromViewButOne $listName $($viewExists.Title) $newSite $firstField
					Add-FieldsToView $listName $($viewExists.Title) $newSite $($view.Fields)
					#add other view
					Rename-View $listName $($viewExists.Title) $newSite $($view.Title) $($view.ViewQuery)
				}
				else
				{
					
					$viewName = $($view.Title)
					if ([string]::isNullOrEmpty($viewName)){
						$viewName = $($view.ServerRelativeUrl.Split("/")[-1]).Replace(".aspx","")
						
					}
					write-host "view $viewName does Not exists on $newSite" -foregroundcolor Yellow
					write-host "ViewQuery : $($view.ViewQuery)"
					write-host "Check for View! "
					
					$viewDefault = $false
					Create-NewView $newSite $listName $viewName  $($view.Fields) $($view.ViewQuery) $($view.Aggregations) $viewDefault
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