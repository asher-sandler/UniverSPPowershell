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
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

 $tenantAdmin = "ekmd\ashersa"
 $tenantAdminPassword = "GrapeFloor789"
 $secureAdminPassword = $(convertto-securestring $tenantAdminPassword -asplaintext -force)
 $siteURL = "https://portals.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace";
 $ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl) 
 # $credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($tenantAdmin, $secureAdminPassword)  
 $ctx.Credentials = New-Object System.Net.NetworkCredential($tenantAdmin, $tenantAdminPassword)
    

# LogSection "Add Manual Correction WebPart to Page"
GetDocLib $ctx $relUrl