#         MIHZUR
function Get-SiteName($siteName){
	
	$siteUrl = get-UrlNoF5 $siteName
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
	$Ctx.Credentials = $Credentials
	
    #Get the Site from URL
    $Web = $Ctx.web
    $Ctx.Load($web)
    $Ctx.ExecuteQuery()

	return $web.title
}