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

$Credentials = get-SCred

 
 $siteName = "https://scholarships2.ekmd.huji.ac.il/home";
 
 $siteUrl = get-UrlNoF5 $siteName

 #write-host "URL: $siteURL" -foregroundcolor Yellow
 
 
 $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
 $Ctx.Credentials = $Credentials
	$Web = $Ctx.Web
	$grps = $web.SiteGroups
	$users = $web.SiteUsers
	$ctx.Load($Web)
	$ctx.Load($grps)
	$ctx.Load($users)
	$Ctx.ExecuteQuery()
	$groupCount = $grps.Count
	$usersCount = $users.Count
	$siteCollectionURL  = $Web.Url
	write-host "Site Collection URL: " $siteCollectionURL -f Yellow
	write-host "Groups Per Site Collection Count: " $groupCount -f Yellow
	write-host "Users  Per Site Collection Count: " $usersCount -f Yellow
 #$listUrl = "/home/General/GEN171-2022/Pages"
 # $Web.GetList($listUrl)
 