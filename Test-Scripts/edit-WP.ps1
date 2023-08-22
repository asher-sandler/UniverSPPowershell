function EdtWebPartContext ($ctx, $sitesURL, $xmlContent) {

	$pageUrl = "/Pages/WPTest.aspx"
	$wpZoneID = "Left"
	$wpZoneOrder= 0
	
    #$ctx.Load($ctx.Web);  
    #$ctx.ExecuteQuery();  
    $page = $ctx.Web.GetFileByServerRelativeUrl($pageURL)
	$ctx.Load($page); 
	$ctx.Load($page.ListItemAllFields);
	$ctx.ExecuteQuery();  	
}	
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

 $tenantAdmin = "ekmd\ashersa"
 $tenantAdminPassword = "GrapeFloor789"
 $secureAdminPassword = $(convertto-securestring $tenantAdminPassword -asplaintext -force)
 $siteURL = "https://portals.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace";
 $ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl) 
 # $credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($tenantAdmin, $secureAdminPassword)  
 $ctx.Credentials = New-Object System.Net.NetworkCredential($tenantAdmin, $tenantAdminPassword)
    
######################################
# Set Add WebPart to Page Parameters #
######################################
$relUrl = "/home/huca/EinKarem/ekcc/QA/AsherSpace"
$xmlContent = get-content SimchaContent.dwp -encoding Default
#EdtWebPartContext $ctx $relUrl $xmlContent

	$pageUrl = "/Pages/WPTest.aspx"
	$pageFullUrl = $relUrl + $pageUrl
	$wpZoneID = "Left"
	$wpZoneOrder= 0
	
    #$ctx.Load($ctx.Web);  
    #$ctx.ExecuteQuery();  
    $page = $ctx.Web.GetFileByServerRelativeUrl($pageFullUrl)
	
	$ctx.Load($page); 
	#$ctx.Load($page.ListItemAllFields);
	$ctx.ExecuteQuery();  	