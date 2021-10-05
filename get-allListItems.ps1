param([string] $site = "", $list= "")
$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
$site = "https://grs.ekmd.huji.ac.il/home/SocialSciences/SOC36-2020"
$listName = "/home/socialSciences/SOC36-2020/haredi"
	
if ([string]::IsNullOrEmpty($site) -or [string]::IsNullOrEmpty($listName)){
	write-host
	write-host Site Or List not Specified. -ForegroundColor Yellow
	write-host
}
else
{

	
	
	$cred = get-SCred
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($site) 
	$ctx.Credentials = $cred
 	
	$Web = $Ctx.Web
	$ctx.Load($Web)
	$Ctx.ExecuteQuery()
	

    $list = $Web.GetList($listName);
	$ctx.Load($list)
	$Ctx.ExecuteQuery()
		
	$list.Title

	#get-allListItemsByID $site $list
}