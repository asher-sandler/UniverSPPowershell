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
Write-IniFile "yes"

$cred = get-SCred

  $siteURL = "https://scholarships.ekmd.huji.ac.il/home/SocialSciences/SOC250-2022";
 #$siteURL = "https://portals.ekmd.huji.ac.il/home/EDU/stdFolders";
 
 write-host "URL: $siteURL" -foregroundcolor Yellow
 $ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl) 
 $ctx.Credentials = $cred
 
 
	$Lists = $Ctx.Web.Lists
	$Ctx.Load($Lists)
	$Ctx.ExecuteQuery()
	Write-host  -foregroundcolor Yellow
    Write-host "--------------- List of Lists --------------------" -foregroundcolor Yellow
	Write-host  -foregroundcolor Yellow
	ForEach($list in $Lists)
	{
		Write-Host $list.Title -foregroundcolor Green
			
		
	}
