function DelDocLib ($ctx) {

		Write-Host "Get Doc Lib" -ForegroundColor Yellow
		
		
		$found = $true
		while($found){
			$Lists = $Ctx.Web.Lists
			$Ctx.Load($Lists)
			$Ctx.ExecuteQuery()
			$found = $false
				
			ForEach($list in $Lists)
			{
				# העלאת מסמכים - Dan Testman 56565656
				$hebrDocLibName = "העלאת מסמכים"
				if ($list.Title.contains("Documents Upload") -or 
					$list.Title.contains($hebrDocLibName)){
					$found = $true	
					write-host "Found: $($list.Title)" -ForegroundColor Yellow
					write-host "Deleting..."
					#read-host
				 
					#Delete the Document Library - Send to Recycle bin
					$list.DeleteObject() | Out-Null  #To permanently delete, call: $Library.DeleteObject()
					$Ctx.ExecuteQuery()				
					
					break
				}
			}		
		
				
		}

		
	

}

start-transcript "DelDocLib.log"
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

		 $siteURL = "https://portals.ekmd.huji.ac.il/home/tap/CSE/CSE12-2022_Archive";
		 
		 
        		 
		 #$xUrl=Import-Csv .\JSON\HSS_Sites.csv
		 
		 #foreach($siteURL in $xUrl.URL) { 	 
<#
https://crs2.ekmd.huji.ac.il/home/murshe/2019

https://crs2.ekmd.huji.ac.il/home/services/2019

https://crs2.ekmd.huji.ac.il/home/exempt/2019



#>		 
		 write-host $siteURL -ForegroundColor Yellow
		 $siteNameN = get-UrlNoF5 $siteURL
		 $ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteNameN) 

		 $ctx.Credentials = $Credentials
	
	 	DelDocLib $ctx 
	#}
	}
Stop-Transcript
.\DelDocLib.log
 