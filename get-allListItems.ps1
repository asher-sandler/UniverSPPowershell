param([string] $site = "", $list= "")
$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
	
if ([string]::IsNullOrEmpty($site) -or [string]::IsNullOrEmpty($list)){
	write-host
	write-host Site Or List not Specified. -ForegroundColor Yellow
	write-host
}
else
{

	$userName = "ekmd\ashersa"
	$userPWD = "GrapeFloor789"




	get-allListItemsByID $site $list
}