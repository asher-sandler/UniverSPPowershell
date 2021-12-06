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
	$siteName = get-UrlNoF5 $siteURL
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
	$ctx.Credentials = $Credentials
 
	$Lists = $Ctx.Web.Lists
	$Ctx.Load($Lists)
	$Ctx.ExecuteQuery()
	$List = $Ctx.Web.lists.GetByTitle($listName)
	
	$ViewCreationInfo = New-Object Microsoft.SharePoint.Client.ViewCreationInformation
	
    $ViewCreationInfo.Title = $viewTitle
    #$ViewCreationInfo.Query = $viewQuery
    $ViewCreationInfo.ViewFields = $viewFields
    $ViewCreationInfo.SetAsDefaultView = $viewDefault
   
    $NewView =$List.Views.Add($ViewCreationInfo)
    $Ctx.ExecuteQuery() 

	#$NewView.Aggregations = $viewAggregations
	$NewView.Update()
	$Ctx.ExecuteQuery()	
 	
	return $null	
}
$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"

$cred = get-SCred

 
 $siteURL = "https://grs.ekmd.huji.ac.il/home/OverseasApplicantsUnit/GEN32-2022";
 $docLibName = "applicants"
 $view = "Rakefet"
 write-host "URL: $siteURL" -foregroundcolor Yellow
 $wrkFileName = ".\daniel\rakefet.xml"
 $isXML = [bool]((Get-Content $wrkFileName) -as [xml])
 if ($isXML){
	$xmlNodeData = Select-Xml -Path $wrkFileName -XPath "/ServiceCollection/Service/DataDetailsCollection/DataDetails/ParamCollection/Param" | ForEach-Object {$_.Node.SPColumnName}
	foreach ($line in $xmlNodeData ){
		write-host $line
	}
	
	$vObj = "" | Select Title,ServerRelativeUrl
	$vObj.Title = $view
	$vObj.ServerRelativeUrl = $view + ".aspx"
	
	$objViews = Get-AllViews $docLibName $siteURL
	
	 
	$viewExists = Check-ViewExists $docLibName  $siteURL $vObj
	if ($viewExists.Exists){
		write-host "view $viewName  exists on $newSite" -foregroundcolor Cyan
	}
	else
	{
		$viewName = $($vObj.Title)
		write-host "view $viewName does Not exists on $newSite" -foregroundcolor Green
		$viewDefault = $false
		Create-NewViewX $siteURL $docLibName $viewName  $xmlNodeData "" "" $viewDefault
	}
	
 }
 
 


