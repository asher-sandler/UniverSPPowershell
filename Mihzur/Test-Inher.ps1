function Inher-MasterPage($srcSiteURL, $archSiteURL){
	$topSPWeb  = get-SPweb $srcSiteURL
	$archSPWeb = get-SPweb $archSiteURL
	
	
	#$archSPWeb.AllProperties["__InheritsCustomMasterUrl"]
	#$archSPWeb.AllProperties["__InheritsMasterUrl"]
	
	#$topSPWeb.MasterUrl
	#$topSPWeb.CustomMasterUrl;
	$archSPWeb.CustomMasterUrl = $topSPWeb.CustomMasterUrl;
    $archSPWeb.AllProperties["__InheritsCustomMasterUrl"] = "True";
    $archSPWeb.MasterUrl = $topSPWeb.MasterUrl;
    $archSPWeb.AllProperties["__InheritsMasterUrl"] = "True";
    $archSPWeb.AlternateCssUrl = $topSPWeb.AlternateCssUrl;
    $archSPWeb.AllProperties["__InheritsAlternateCssUrl"] = "True";
    $archSPWeb.Update();	
}
Add-PsSnapin Microsoft.SharePoint.PowerShell

$srcSiteUrl = "https://gss2.ekmd.huji.ac.il/home/Humanities/HUM13-2020"
$archSubSite = "" | Select URL
$archSubSite.URL = "https://gss2.ekmd.huji.ac.il/home/Humanities/HUM13-2020/Archive-2022-08-18"
Inher-MasterPage $srcSiteUrl $archSubSite.URL
