<#
Please create views of data in the researchers list, by the fields of the forms (links attached).

Data list:
https://portals2.ekmd.huji.ac.il/home/sci/malag/Lists/researchers/AllItems.aspx

Forms:
https://portals2.ekmd.huji.ac.il/home/sci/malag/Pages/PersonalDetailsForm.aspx
https://portals2.ekmd.huji.ac.il/home/sci/malag/Pages/ResearchInterestsForm.aspx
https://portals2.ekmd.huji.ac.il/home/sci/malag/Pages/HIndex.aspx
https://portals2.ekmd.huji.ac.il/home/sci/malag/Pages/ResearchInfrastructureAndServicesForm.aspx
https://portals2.ekmd.huji.ac.il/home/sci/malag/Pages/NumberOfStudentsInYourGroupForm.aspx
Thank you,
Yevgenia



#>

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
function Create-NewViewX($siteURL,$listName,$viewTitle,$viewFields,$viewQuery, $viewAggregations, $viewDefault)
{
	write-host "Site	     : $siteURL"    -f Yellow
	write-host "List   		 : $listName"   -f Yellow
	write-host "View 		 : $viewTitle"  -f Yellow
	write-host "Fields		 : $viewFields" -f Yellow
	write-host "Query  		 : $viewQuery"  -f Yellow
	write-host "Aggregation  : $viewAggregations"  -f Yellow
	write-host "Default      : $viewDefault"  -f Yellow
	write-host "================="  -f Yellow
	write-host
	$siteName = get-UrlNoF5 $siteURL
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
	$ctx.Credentials = $Credentials
 
	$Lists = $Ctx.Web.Lists
	$Ctx.Load($Lists)
	$Ctx.ExecuteQuery()
	$List = $Ctx.Web.lists.GetByTitle($listName)
	
	$ViewCreationInfo = New-Object Microsoft.SharePoint.Client.ViewCreationInformation
	
    $ViewCreationInfo.Title = $viewTitle
    $ViewCreationInfo.Query = $viewQuery
    $ViewCreationInfo.ViewFields = $viewFields
    $ViewCreationInfo.SetAsDefaultView = $viewDefault
   
    $NewView =$List.Views.Add($ViewCreationInfo)
    $Ctx.ExecuteQuery() 

    if (![string]::isNullOrEmpty($viewAggregations)){
		$NewView.Aggregations = $viewAggregations
	}
	$NewView.Update()
	$Ctx.ExecuteQuery()	
 	
	return $null	

	
}
function Change-ViewX($siteURL,$listName,$viewTitle,$viewFields,$viewQuery, $viewAggregations, $viewDefault){
	write-host "Site	     : $siteURL"    -f Green
	write-host "List   		 : $listName"   -f Green
	write-host "View 		 : $viewTitle"  -f Green
	write-host "Fields		 : $viewFields" -f Green
	write-host "Query  		 : $viewQuery"  -f Green
	write-host "Aggregation  : $viewAggregations"  -f Green
	write-host "Default      : $viewDefault"  -f Green
	write-host "================="  -f Green
	write-host 


	$siteName = get-UrlNoF5 $siteURL
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
	$ctx.Credentials = $Credentials
 
	$Lists = $Ctx.Web.Lists
	$Ctx.Load($Lists)
	$Ctx.ExecuteQuery()
	
	$List = $Ctx.Web.lists.GetByTitle($listName)
	$view = $List.Views.getByTitle($viewTitle)

    
    $Ctx.Load($view) 
    $Ctx.ExecuteQuery() 
	
	
	#$view | gm
	#$view.ListViewXML
	$view.ViewQuery = $viewQuery	
	$view.Update()
	$Ctx.ExecuteQuery()
	return $null	
	
}
function get-PageWebPartAll($SiteURL,$pageURL){
	$siteName = get-UrlNoF5 $SiteURL
	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	
	$Ctx.Credentials = $Credentials



	$page = $ctx.Web.GetFileByServerRelativeUrl($pageURL);
	
	$ctx.Load($page);
    $ctx.Load($page.ListItemAllFields);
    $ctx.ExecuteQuery();


	$page.CheckOut()
	$pageFields = $page.ListItemAllFields

	$webpartManager = $page.GetLimitedWebPartManager([Microsoft.Sharepoint.Client.WebParts.PersonalizationScope]::Shared);	
	
	Write-Host "Get webparts on the page : $pageURL" -ForegroundColor Green

	
	$WebParts = $webpartManager.WebParts
	$ctx.Load($webpartManager);
	$ctx.Load($WebParts);
	$ctx.ExecuteQuery();
	
	$wpsObject = @()	
	
	foreach($wp in $webparts){
			
			
			
			$ctx.Load($wp.WebPart.Properties)
			$ctx.Load($wp.WebPart)
			$ctx.Load($wp)
			$ctx.ExecuteQuery() 
			write-host $wp.WebPart.Title
			$wps = "" | Select-Object Title, Properties
			$wps.Title = $wp.WebPart.Title
			$wps.Properties = $wp.WebPart.Properties.FieldValues
			$wpsObject += $wps
			<#
			if ($wp.WebPart.Title -eq $wpName){
				$wp.WebPart.Properties["WP_Language"] = $lang
				$wp.WebPart.Properties["EmailTemplatePath"] = $spObj.MailPath
				
				$wp.WebPart.Properties["EmailTemplateName"] = $spObj.MailFile;
				
				$wp.SaveWebPartChanges();				
			}
			#>
	}
	#$PageContent = $pageFields["PublishingPageContent"]
	
	$page.UndoCheckOut()
	
	$ctx.ExecuteQuery()	
	return $wpsObject

}



$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "..\Utils-Request.ps1"
. "..\Utils-DualLanguage.ps1"

$Credentials = get-SCred

$malagFormsStr = 'https://portals2.ekmd.huji.ac.il/home/sci/malag/Pages/PersonalDetailsForm.aspx,
https://portals2.ekmd.huji.ac.il/home/sci/malag/Pages/ResearchInterestsForm.aspx,
https://portals2.ekmd.huji.ac.il/home/sci/malag/Pages/HIndex.aspx,
https://portals2.ekmd.huji.ac.il/home/sci/malag/Pages/ResearchInfrastructureAndServicesForm.aspx,
https://portals2.ekmd.huji.ac.il/home/sci/malag/Pages/NumberOfStudentsInYourGroupForm.aspx'

$malagForms = $malagFormsStr.split(',')

 $docLibName = "researchers"
 $siteName = "https://portals2.ekmd.huji.ac.il/home/sci/malag";
 
 $siteUrl = get-UrlNoF5 $siteName

 write-host "URL: $siteURL" -foregroundcolor Yellow
 
 
 $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
 $Ctx.Credentials = $Credentials
 $jsonFileName = ".\JSON\WebParts.json" 
 if (!(Test-Path $jsonFileName)){
	 $webPartArr = @()
	 foreach($mform in $malagForms){
		 $RelURL = get-RelURL $mform

		 
		 $domain = $mform.split('/')[2]
		 $webURL = "https://"+$domain+$RelURL
		 
		 $page = $mform.split('/')[-1]
		 $pageURL = $RelURL + "Pages/"+$page
		 $pgObj = "" | Select-Object URL,PageURL,ViewName, WebParts
		 
		 #write-host $webURL -f Green
		 #write-host $pageURL -f Yellow
		 $pgObj.URL = $webURL
		 $pgObj.PageURL = $PageURL
		 $pgObj.ViewName = $page.Replace('.aspx',"").Replace("Form","")
		 $pgObj.WebParts = get-PageWebPartAll $webURL $PageURL
		 $webPartArr += $pgObj
	 }
	 #$webPartArr | fl

	 $webPartArr | ConvertTo-Json -Depth 100 | out-file $jsonFileName -Encoding Default
	 Write-Host "Written file $jsonFileName" -f Cyan
 }
 else
 {
	$webPartArr = get-content $jsonFileName -encoding default | ConvertFrom-Json 
 }
  $viewsAndFields = @()
  foreach($wpElem in $webPartArr){
	  #$wpElem
	  $viewObj = "" | Select-Object Title,XMLFileName,Fields,ServerRelativeUrl,ViewQuery,Aggregations,DefaultView
	  $viewObj.Title = $wpElem.ViewName
	  $viewObj.ServerRelativeUrl = $siteURL
	  $viewObj.ViewQuery = '<OrderBy><FieldRef Name="ID" /></OrderBy>'
	  $viewObj.Aggregations = ''
	  $viewObj.DefaultView = $false
	  $viewObj.Fields = @()
	  $viewObj.Fields += "Edit"
	  $wrkFileName = $wpElem.WebParts.Properties.filePath + "\"+$wpElem.WebParts.Properties.fileName
	  if (Test-Path $wrkFileName){
		  
		$isXML = [bool]((Get-Content $wrkFileName) -as [xml])
		# file is XML type
		
		if ($isXML){
		  
		$viewObj.XMLFileName = $wrkFileName
		write-host $wrkFileName -f Green
		$xmlNodeData = Select-Xml -Path $wrkFileName -XPath "/rows/row/control" | ForEach-Object {$_.Node.Data}

		$arrDataTag = @()
		$isError = $false
			
		# adding tags to array 
		foreach ($line in $xmlNodeData)
		{
					
				if (![String]::IsNullOrEmpty($line)){
					$itemToAdd = $line.toString().Trim()
					$itArr = "" | Select Item
					$itArr.Item = $itemToAdd
					if ($itemToAdd -ne 'MyCustomLabel'){		
						$viewObj.Fields +=  $itArr.Item
					}
				}
			}
		}
		$viewsAndFields += $viewObj
	  }
  }
 $jsonFileName = ".\JSON\WebPartsFields.json" 
 $viewsAndFields | ConvertTo-Json -Depth 100 | out-file $jsonFileName -Encoding Default
 Write-Host "Written file $jsonFileName" -f Cyan
  
 # $viewsAndFields
 $objViews = Get-AllViews $docLibName $siteName
 $fileName = "JSON\"+$docLibName+"-Views.json" 			 
 $objViews | ConvertTo-Json -Depth 100 | out-file $fileName
 write-host "Created File : $fileName" -f Cyan
 
 #foreach($ovX in $objViews){
#	 write-host $ovx.ViewQuery
 #}
 
 foreach($viewObjx in $viewsAndFields)
 {
	  
	 $viewExists = Check-ViewExists $docLibName  $siteURL $viewObjx
     if (!$($viewExists.Exists)){ 
        write-host "Create new Query $($viewObjx.Title)" -f Cyan
	    #write-host $viewObjx.Title
	    #write-host $viewObjx.ViewQuery
	    #write-host $viewExists
		
		Create-NewViewX $siteUrl $docLibName $viewObjx.Title $viewObjx.Fields $viewObjx.ViewQuery $viewObjx.Aggregations $viewObjx.DefaultView 
        read-host
	 }
	 else
	 {
        write-host "Change Query $($viewObjx.Title)" -f Cyan
		 
		Change-ViewX $siteUrl $docLibName $viewObjx.Title $viewObjx.Fields $viewObjx.ViewQuery $viewObjx.Aggregations $viewObjx.DefaultView 
		 
	 }
	 
 }
 
 