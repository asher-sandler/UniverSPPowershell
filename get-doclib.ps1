function GetDocLib ($ctx) {

		Write-Host "Get Doc Lib" -ForegroundColor Yellow
		
		$Lists = $Ctx.Web.Lists
		$Ctx.Load($Lists)
        $Ctx.ExecuteQuery()
		
		ForEach($list in $Lists)
		{
			# העלאת מסמכים - Dan Testman 56565656
			$hebrDocLibName = "העלאת מסמכים"
			if ($list.Title.contains("Documents Upload") -or 
				$list.Title.contains($hebrDocLibName)){
				write-host "Found: $($list.Title)" -ForegroundColor Yellow
				$List.OnQuickLaunch = $false;
				
				$List.Update()
				$Ctx.ExecuteQuery()
				
			}
		}

		
	

}

start-transcript "HideDocLib.log"
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
	$isIniExists = Write-IniFile "No"
	if ($isIniExists){	
		$Credentials = get-SCred

		 $siteURL = "https://scholarships.ekmd.huji.ac.il/home/SocialSciences/SOC36-2015";
		 $siteURL = "https://scholarships2.ekmd.huji.ac.il/home/Agriculture/AGR36-2015";
		 $siteURL = "https://crs.ekmd.huji.ac.il/home/exempt/2019";
		 
<#
https://crs2.ekmd.huji.ac.il/home/murshe/2019

https://crs2.ekmd.huji.ac.il/home/services/2019

https://crs2.ekmd.huji.ac.il/home/exempt/2019



#>		 
		 write-host $siteURL -ForegroundColor Yellow
		 $siteNameN = get-UrlNoF5 $siteURL
		 $ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteNameN) 

		 $ctx.Credentials = $Credentials
	
	 	GetDocLib $ctx 
	}
Stop-Transcript
.\HideDocLib.log
 