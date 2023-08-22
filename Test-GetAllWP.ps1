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
. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"

$cred = get-SCred

 
 $siteURL = "https://grs2.ekmd.huji.ac.il/home/OverseasApplicantsUnit/GEN31-2021";
 $siteURL = "https://scholarships2.ekmd.huji.ac.il/home/General/GEN156-2021";
 $siteURL = "https://scholarships2.ekmd.huji.ac.il/home/humanities/HUM201-2022";
 $pageURL = "/home/OverseasApplicantsUnit/GEN31-2021/Pages/declarationFormRU.aspx"
 $pageURL = "/home/General/GEN156-2021/Pages/DocumentsUpload.aspx"
 $pageURL = "/home/humanities/HUM201-2022/Pages/DocumentsUpload.aspx"
 
 write-host "URL : $siteURL" -foregroundcolor Yellow
 write-host "Page: $pageURL" -foregroundcolor Yellow

#"submit":  true,
 $outObj = get-PageWebPartAll $siteURL $pageURL
 $outJson = ".\JSON\Test-GetAllWP.json"
 
 $outObj | ConvertTo-Json -Depth 100 | out-file $outJson -Encoding Default
