function GetDocLib ($ctx, $sitesURL) {

		Write-Host "Get Doc Lib" -ForegroundColor Yellow
		
		$Lists = $Ctx.Web.Lists
		$Ctx.Load($Lists)
        $Ctx.ExecuteQuery()
		
		ForEach($list in $Lists)
		{
			if ($List.Title -eq "Documents Upload Asher 54321876"){
				write-host Found Asher Doc Lib
				$List.OnQuickLaunch = $false;
				
				$List.Update()
				$Ctx.ExecuteQuery()
				
			}
		}

		
	

}

$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"

	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"


	$userName = "ekmd\ashersa"
	$userPWD = "GrapeFloor789"

 
 $oldSite = "https://scholarships2.ekmd.huji.ac.il/home/humanities/HUM172-2021"
  $newSite = "https://portals2.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace"



# LogSection "Add Manual Correction WebPart to Page"
copy-DocTypeList $newSite  $oldSite