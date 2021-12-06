param([string] $groupName = "")

$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"
if ([string]::isNullOrEmpty($groupName))
{
	write-host groupName Must be specified  -foregroundcolor Yellow
	write-host in format hss_HUM164-2021  -foregroundcolor Yellow
	
}
else
{
	if (Test-CurrentSystem $groupName){
		$jsonFile = "JSON\"+$groupName+".json"
		if (Test-Path $jsonFile){
			write-host "Group: $groupName" -foregroundcolor Green
			$Credentials = get-SCred	
			
			$spObj = get-content $jsonFile -encoding default | ConvertFrom-Json
			
			
			$siteUrl    = get-CreatedSiteName $spObj
			$oldSiteURL = $spObj.oldSiteURL
			$RelURL = get-RelURL $siteUrl
			$oldSiteSuffix = $spObj.OldSiteSuffix
			if ([string]::isNullOrEmpty($oldSiteSuffix)){
				$oldSiteSuffix = $spObj.oldSiteURL.split("/")[-2]
			}
				
			write-host "Old Site: $oldSiteURL" -foregroundcolor Cyan
			write-host "New Site: $siteUrl" -foregroundcolor Magenta
			write-host "RelURL:   $RelURL" -foregroundcolor Yellow
			#write-Host Press Key ...
			#read-host
			$siteDumpFileName = ".\JSON\"+ $groupName+"-WPErrors.json"
			If (Test-Path $siteDumpFileName){
				write-Host 
				write-Host "Object file: $siteDumpFileName" -f Yellow
				
				$siteDumpObj = get-content $siteDumpFileName -encoding default | ConvertFrom-Json	
				
				$currentDestPage = ""
				$changeArry = @()
				foreach($item in $siteDumpObj){
					
					if (!$item.WebPartValueDST.contains($spObj.RelURL)){
						
						$webPartName = $item.WebPartName
						$wpKey = $item.WebPartKey
						$wpValue = $item.WebPartValueSRC
						if ($wpValue.contains($spObj.OldSiteSuffix)){
							$wpValue = $wpValue.Replace($spObj.OldSiteSuffix,$spObj.RelURL )
						}
						$pg =  $item.DestPageURL # -Replace $RelURL , ""
						
						write-Host 
						write-Host "--------------" -f Green
						write-Host $pg -f Green
						
						if (!$wpValue.Contains("Switch")){ # pass WP Switch Language
						    if (!($wpKey -eq "InstallDate")){  # pass WP AE Banner Rotator
								edt-WPPage $siteUrl  $pg $webPartName $wpKey  $wpValue
							}
						}
						#write-Host "Press any key..."
						#Read-host
						
					}
				}
				Write-Host "Done..." -f Green
				write-Host "To Collect new Dump Run: " -noNewLine -foregroundcolor Yellow
				write-Host ".\10.Compar-Sites.ps1 $groupName -DeleteJson Yes" -foregroundcolor Cyan
							
			}
			else
			{
			    write-Host 
			    write-Host "Object file: $siteDumpFileName Not Found!" -f Yellow
				write-Host "To Collect this file Run Procedure. " -foregroundcolor Yellow
				write-Host ".\10.Compar-Sites.ps1 $groupName" -foregroundcolor Cyan
			
			}
		
		}
		
	}
	else
	{
		Write-Host "Group Name $groupName is not valid!" -foregroundcolor Yellow
	}	
		
}