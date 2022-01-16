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
function Create-NavSubMenuX($SiteURLNew, $menuTitle, $submenu){
	$siteName = get-UrlNoF5 $SiteURLNew
	write-host "Create Nav SubMenu: $siteURL" -foregroundcolor Green
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
	$ctx.Credentials = $Credentials
 	
	
	#Get the Quick Launch Navigation of the web
	$Navigation = $Ctx.Web.Navigation.QuickLaunch
	$Ctx.load($Navigation)
	$Ctx.ExecuteQuery()
	

	$ParentNode = $Navigation | Where-Object {$_.Title -eq $menuTitle}

		
	if (![string]::isNullOrEmpty($ParentNode)){
		if ($ParentNode.Count -gt 1){
			$ParentNode = $ParentNode[1]
		}	
		write-host "Main Menu Item $menuTitle found" -f Green
		$Ctx.Load($ParentNode)
		$Ctx.Load($ParentNode.Children)
		$Ctx.ExecuteQuery()
		
		$Node = $ParentNode.Children | Where-Object {$_.Title -eq $submenu.Title}
		if ([string]::isNullOrEmpty($Node)){
			write-host "Sub Menu Item $($submenu.Title) Not found" -f Green
			
			$NavigationNode = New-Object Microsoft.SharePoint.Client.NavigationNodeCreationInformation
			
			$NavigationNode.Title = $submenu.Title
			$NavigationNode.Url = $submenu.URL
			$NavigationNode.AsLastNode = $true

			$Ctx.Load($ParentNode.Children.Add($NavigationNode))
			$Ctx.ExecuteQuery()
			$titl = $submenu.Title
			Write-Host -f Green "New Navigation Node '$titl' Added to the Navigation Root!" 
			
		
		}
		else
		{
			write-host "Sub Menu Item '$($submenu.Title)' Already exists" -f Yellow
		}
	}
	else
	{
		write-host "Main Menu Item $menuTitle Not found" -f Yellow
		
	}


	
	
    return $Navigation	



}
function Get-PMenuTitle($menuDump,$listTitle){
	
	
	foreach($mainMenu in $menuDump){
		$pTitle = $null
		$menuParentFound = $false
		foreach($subMenu in $mainMenu.Items)
		{
			if ($subMenu.Url.ToLower().contains($listTitle.ToLower())){
				$menuParentFound = $true
				break;
			}
		}
		if ($menuParentFound){
			$pTitle = $mainMenu.Title
			break
		}
	}
	return $pTitle
}
$Credentials = get-SCred
$fileRules = ".\Diego\ViewLists.txt"
$fileList = Import-CSV $fileRules -Delimiter ";"
$parentsList = @()
foreach($itemList in $fileList){

	 $siteSuffix = $itemList.SUFFIX
	 $sitePrefix = $itemList.URL
	 $siteName = get-UrlNoF5 $($sitePrefix + $siteSuffix)
	 $docLibName = $itemList.List
	 $mainViewName = $itemList.mainViewName
	 $prevArchiveName = $itemList.PrevArchiveName
	 $prevYear = $itemList.PrevYear
	 $currentYear = $itemList.CurrentYear
	 $siteUrl = get-UrlNoF5 $siteName
	 $subMenuTitle = "נתונים - "+$prevYear
	 
	 write-host "URL: $siteURL" -foregroundcolor Yellow
	 write-host "ListName : $docLibName" -foregroundcolor Yellow
	 write-host "mainViewName : $mainViewName" -foregroundcolor Yellow
	 write-host "prevYear : $prevYear" -foregroundcolor Yellow
	 write-host "prevArchiveName : $prevArchiveName" -foregroundcolor Yellow
	 write-host "currentYear : $currentYear" -foregroundcolor Yellow
	 write-host "subMenuTitle : $subMenuTitle" -foregroundcolor Yellow
	 
	 #read-host

	 $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
	 $Ctx.Credentials = $Credentials
	 
	 $objViews = Get-AllViews $docLibName $siteName
	 $fileName = "JSON\"+$docLibName+"-Views.json" 			 
	 $objViews | ConvertTo-Json -Depth 100 | out-file $fileName
	 write-host "Created File : $fileName"
	 
	 foreach($view in $objViews){
		if ($view.Title -eq $mainViewName){ 
		     write-host "mainViewName Found" -f Yellow
		    $newQuery = $view.ViewQuery.Replace($prevYear,$currentYear)
		    $newQuery = '<OrderBy><FieldRef Name="ID" Ascending="FALSE" /></OrderBy><Where><Geq><FieldRef Name="Created" /><Value Type="DateTime">2022-01-01T00:00:00Z</Value></Geq></Where>'
			Change-ViewX $siteUrl $docLibName $view.Title $view.Fields $newQuery $view.Aggregations $view.DefaultView 
		}
		

	 }
	 $vObj = $objViews | Where{$_.Title -eq $prevArchiveName}
	 if (!$([string]::IsNullOrEmpty($vObj))){
		write-host "prevArchiveName not  Found" -f Yellow
		$v1 = "" | Select-Object DefaultView,Aggregations,Title, ServerRelativeUrl,ViewQuery,Fields
		
		
		$v1.DefaultView = $vObj.DefaultView
		$v1.Aggregations =  $vObj.Aggregations
		$v1.Title =  $prevYear
		$v1.ServerRelativeUrl =  $vObj.ServerRelativeUrl.Replace($prevArchiveName,$prevYear)
		# $v1.ViewQuery =  $vObj.ViewQuery.Replace("2021","2022").Replace("2020","2021")
		$v1.ViewQuery =  $vObj.ViewQuery.Replace($prevYear,$currentYear).Replace($prevArchiveName,$prevYear)
		$v1.Fields =  $vObj.Fields
			
		$viewExists = Check-ViewExists $docLibName  $siteURL $v1
		write-host "Exists : $viewExists"
		if (!$($viewExists.Exists)){ 
			Create-NewViewX $siteUrl $docLibName $v1.Title $v1.Fields $v1.ViewQuery $v1.Aggregations $v1.DefaultView 
	 
		}	 
	 }
	 else
	 {
		$newQuery = '<OrderBy><FieldRef Name="ID" Ascending="FALSE" /></OrderBy><Where><And><Geq><FieldRef Name="Created" /><Value Type="DateTime">2021-01-01T00:00:00Z</Value></Geq><Lt><FieldRef Name="Created" /><Value Type="DateTime">2022-01-01T00:00:00Z</Value></Lt></And></Where>'
		$aggr = '<FieldRef Name="folderLink" Type="COUNT" />'
		$flds  = $objViews[0].Fields
		Create-NewViewX $siteUrl $docLibName $prevYear $flds $newQuery $aggr $false
		
	 }
	 $outfile = ".\JSON\"+$siteSuffix+"-MenuDmp-Src.json"
	 
	 #if (Test-Path $outfile){
	#	$menuDumpSrc = get-content $outfile -encoding default | ConvertFrom-Json
		 
	 #}
	 #else
	 #{
		$menuDumpSrc = Collect-Navigation $siteUrl $flagOldMenu
        $menuDumpSrc | ConvertTo-Json -Depth 100 | out-file $outfile -Encoding Default

	 #}	
				
	 $ParentMenuTitle = Get-PMenuTitle $menuDumpSrc $docLibName
	 write-host $ParentMenuTitle -f Cyan
	 <#
	 $flagOldMenu =  $True
	 $menuDumpSrc = Collect-Navigation $siteUrl $flagOldMenu
	 #$menuDumpSrc = get-content $outfile -encoding default | ConvertFrom-Json	
	 $menuDumpSrc | ConvertTo-Json -Depth 100 | out-file $outfile -Encoding Default
	 #>
	 
	 #$siteTest = "https://portals2.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace"
	 $menuItem = "" | Select-Object Title, URL
	 $menuItem.Title =  $subMenuTitle
	 $menuItem.URL = get-UrlWithF5 $($siteName + "/Lists/" + $docLibName +"/"+ $prevYear + ".aspx")
	 
	 $menuItem
	 #/home/socialWork/Lists/FRM_SSW10_List/2021.aspx
	 # $siteName
	 # $ParentMenuTitle
	 $parentsList += $ParentMenuTitle
	 Create-NavSubMenuX  $siteName $ParentMenuTitle $menuItem | Out-Null
	 
} 

Write-Host "Items In Menus:"
foreach($plst in $parentsList){
	write-host $plst -f Cyan
}
 