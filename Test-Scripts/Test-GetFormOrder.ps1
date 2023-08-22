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
. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"

$cred = get-SCred

 $siteURL = "https://portals.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace";
 $siteURL = "https://forms.ekmd.huji.ac.il/home/avneiPina";
 #$siteURL = "https://portals.ekmd.huji.ac.il/home/EDU/stdFolders";
 
 $listName = "FRM_AVP01_List"
 write-host "URL: $siteURL" -foregroundcolor Yellow
 
 $applicantsFieldsOrder = get-FormFieldsOrder $listName $siteURL
 #$applicantsFieldsOrder
 
	 $JsonFile =   ".\JSON\"+$listName+"-FormOrder.json"
	 $applicantsFieldsOrder | ConvertTo-Json -Depth 100 | out-file $JsonFile
	 write-host "$JsonFile was written" -f Yellow
 
<# 
 [array]::Reverse($applicantsFieldsOrder) 
 $applicantsFieldsOrder	
 
 $resArr = checkForArrElExists $applicantsFieldsOrder $applicantsFieldsOrder
 reorder-FormFields "testOrder"	$siteURL $resArr
 
 
 $oldSite = "https://grs2.ekmd.huji.ac.il/home/Education/EDU57-2021/"
 $newSite = "https://grs2.ekmd.huji.ac.il/home/Education/EDU60-2021"
 $listName = "Applicants"
 $objViews = Get-AllViews $listName $oldSite
 
 $objViews | ConvertTo-Json -Depth 100 | out-file $("JSON\Applicants-Views.json")
 
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
		 #$listName = "testOrder"
		 #$titl = "All Items"
		 #$newSite = "https://portals.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace"
		 #$firstField = "Name"
		 #remove-AllFieldsFromViewButOne $listName $titl $newSite $firstField
		 Add-FieldsToView $listName $($viewExists.Title) $newSite $($view.Fields)
		 #add other view
		 Rename-View $listName $($viewExists.Title) $newSite $($view.Title)
	 }
	 else
	 {
		
		$viewName = $($view.Title)
		if ([string]::isNullOrEmpty($viewName)){
			$viewName = $($view.ServerRelativeUrl.Split("/")[-1]).Replace(".aspx","")
			
		}
		write-host "view $viewName does Not exists on $newSite" -foregroundcolor Yellow
		$viewDefault = $false
		Create-NewView $newSite $listName $viewName  $($view.Fields) $($view.Query) $($view.Aggregations) $viewDefault
	 }
 }
 #>