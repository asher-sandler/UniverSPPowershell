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

 
 $siteName = "https://gss2.ekmd.huji.ac.il/home/general/GEN35-2022";
 $siteName = "https://grs2.ekmd.huji.ac.il/home/dental/DNT46-2022";
 $siteName = "https://portals2.ekmd.huji.ac.il/home/tap/CSE/CSE12-2022";
 $siteName = "https://scholarships2.ekmd.huji.ac.il/home/Humanities/HUM203-2022";
 $siteName = "https://scholarships2.ekmd.huji.ac.il/home/NaturalScience/SCI93-2022";
 $siteName = "https://scholarships2.ekmd.huji.ac.il/home/NaturalScience/SCI92-2022";
 $siteName = "https://scholarships2.ekmd.huji.ac.il/home/NaturalScience/SCI94-2022";
 
 $siteUrl = get-UrlNoF5 $siteName

 write-host "URL: $siteURL" -foregroundcolor Yellow
 
 
 $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
 $Ctx.Credentials = $Credentials
	$Web = $Ctx.Web
	$ctx.Load($Web)
	$Ctx.ExecuteQuery()
	$Lists = $Ctx.Web.lists	

	$ctx.Load($Lists)
	$Ctx.ExecuteQuery()
	foreach ($list in $Lists)
	{
		$RF = $list.RootFolder
		$ctx.Load($RF)
		$Ctx.ExecuteQuery()

		Write-Host  $RF.Name 
		Write-Host  $list.Title
		write-host "-------------------"
	}
	
 #$listUrl = "/home/General/GEN171-2022/Pages"
 # $Web.GetList($listUrl)
 