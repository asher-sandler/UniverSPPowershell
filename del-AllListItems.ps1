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




	$listColl = get-allListItemsByID $site $list
	
	if ($listColl.count -gt 0){
		Write-Host
		Write-Host Caution!!! You are deleting ALL items -ForegroundColor Yellow
		Write-Host "on Site: [$site]" -ForegroundColor Yellow
		Write-Host "on List: [$List]" -ForegroundColor Yellow
		write-host "Items count on List is: $($listColl.count)" -ForegroundColor Yellow
		Write-Host
		Write-Host "Are you ABSOLUTELY sure? [Y]es or [N]o :" -ForegroundColor Yellow -NoNewLine
		if ($(Read-Host).ToLower() -eq 'y'){
		
			write-host Deleting... -ForegroundColor Yellow
			foreach($item in $listColl){
				delete-ListItemsByID $site  $list  $($item.id)
			}
			write-host Done. -ForegroundColor Yellow
		}
		else
		{
			Write-Host [N]o Choosed. -ForegroundColor Green
			Write-Host Have a nice day! -ForegroundColor Green
		}
		
		
		
	}
	else
	{
		write-host List is Empty. Nothing to Delete.
	}
	
}