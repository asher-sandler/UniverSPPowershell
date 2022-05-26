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
			
			write-host "Old Site: $oldSiteURL" -foregroundcolor Cyan
			write-host "New Site: $siteUrl" -foregroundcolor Green
			#write-Host Press Key ...
			#read-host
			
			$oldSuffix = $spObj.OldSiteSuffix

			if ([string]::isNullOrEmpty($oldSuffix)){
				$oldSuffix = $spObj.oldSiteURL.split("/")[-2]
			}
			
			$newSuffix = $spObj.RelURL
			
			$flagOldMenu =  $True
			$menuDumpSrc = Collect-Navigation $oldSiteURL $flagOldMenu
			$outfile = ".\JSON\"+ $groupName+"-MenuDmp-Src.json"
			#$menuDumpSrc = get-content $outfile -encoding default | ConvertFrom-Json	
			$menuDumpSrc | ConvertTo-Json -Depth 100 | out-file $outfile -Encoding Default
		
			
			$menuDumpDst = Collect-Navigation $siteUrl $flagOldMenu
			$outfile = ".\JSON\"+ $groupName+"-MenuDmp-Dst.json"
			#$menuDumpDst = get-content $outfile -encoding default | ConvertFrom-Json
			$menuDumpDst | ConvertTo-Json -Depth 100 | out-file $outfile -Encoding Default
						
			
			$menuNewItemsX = Compare-Navig $menuDumpSrc $menuDumpDst $oldSuffix $newSuffix
			$menuNewItems  = Check-SubNavOldItems  $menuDumpSrc $menuNewItemsX $oldSuffix $newSuffix
		
			$outfile = ".\JSON\"+ $groupName+"-MenuDmp-NewX.json"
			$menuNewItemsX | ConvertTo-Json -Depth 100 | out-file $outfile -Encoding Default
			
			
			$outfile = ".\JSON\"+ $groupName+"-MenuDmp-New.json"	
			Create-MainMenu $siteUrl $menuNewItems
			
			
			#also Creates Document Libraries
			$menuNewItems = Get-DocLibCollectionsRealNames  $menuNewItems $oldSiteURL $siteUrl
			
			$menuNewItems | ConvertTo-Json -Depth 100 | out-file $outfile -Encoding Default
			
			write-Host "$outfile Created..."
			#write-Host "Press any key..."
			#read-host
			write-Host "Create-NavDocLibs..."
			$menuNewItems = Create-NavDocLibs  $menuNewItems  $oldSiteURL $siteUrl
			
			change-ApplicantsFieldAndViews $groupName $spObj $oldSiteURL $siteUrl
			change-AllListFieldAndViews $menuNewItems $groupName $spObj $oldSiteURL $siteUrl
			
			$menuNewItems = Create-NavSubMenu  $menuNewItems $siteUrl
			$menuNewItems | ConvertTo-Json -Depth 100 | out-file $outfile -Encoding Default
			write-Host "81: Written $outfile"
			
			write-Host "Create Publishing Pages..."
			Create-PublishingPages 	$siteURL $oldSiteURL $menuNewItems
			
			write-Host "Something NEW!!!"
			
			$siteDumpObj = "" | Select-Object Source, Destination
			$sourceObj   = "" | Select-Object URL, RelPath, Lists, Pages      
			$DestObj     = "" | Select-Object URL, RelPath, Lists, Pages
			$RelURLSrc = get-RelURL $siteUrl
			
			$sourceObj.Url = $oldSiteURL
			$sourceObj.RelPath = get-RelURL $oldSiteURL
			#$sourceObj.Lists = Collect-libs $oldSiteURL
				
			$DestObj.URL   = $siteUrl
			$DestObj.RelPath = $RelURLSrc
			#$DestObj.Lists   = Collect-libs $siteUrl
			
			#Dest
			$PagesName = getListOrDocName $siteUrl $($RelURLSrc+"Pages") "DocLib"
			$SitePagesName = getListOrDocName $siteUrl $($RelURLSrc+"SitePages") "DocLib"
		
		
			#Write-Host $PagesName -f Yellow
			$pageItems = get-allListItemsByID $siteUrl $PagesName
			#$pageItems
		
			$SPages = @()
		
			foreach ($itm in $pageItems){
				$pgObj = "" | Select-Object URL, Name, InnerName
				$pgObj.URL = $itm["FileRef"]
				$pgObj.Name = $pgObj.URL.split("/")[-2]+"/"+$pgObj.URL.split("/")[-1]
				$pgObj.InnerName = $pgObj.URL.split("/")[-1].Replace(".aspx","")
				#$pgObj.WebParts = get-PageWebPartAll $siteUrl $pgObj.URL
				$SPages += $pgObj
			}			
		
			#Write-Host $SitePagesName -f Yellow
			$sitePageItems = get-allListItemsByID $siteUrl $SitePagesName
		
			foreach ($itm in $sitePageItems){
				$pgObj = "" | Select-Object URL, Name, InnerName
				$pgObj.URL = $itm["FileRef"]
				$pgObj.Name = $pgObj.URL.split("/")[-2]+"/"+$pgObj.URL.split("/")[-1]
				$pgObj.InnerName = $pgObj.URL.split("/")[-1].Replace(".aspx","")
				#$pgObj.WebParts = get-PageWebPartAll $siteUrl $pgObj.URL
				$SPages += $pgObj
			}
			
			$DestObj.Pages = $SPages
			#write-host 170 -f Yellow


			#Source
			$RelURL = get-RelURL $oldSiteURL
			$PagesName = getListOrDocName $oldSiteURL $($RelURL+"Pages") "DocLib"
			$SitePagesName = getListOrDocName $oldSiteURL $($RelURL+"SitePages") "DocLib"
		
		
			#Write-Host $PagesName -f Yellow
			$pageItems = get-allListItemsByID $oldSiteURL $PagesName
			#$pageItems
		
			$SPages = @()
		
			foreach ($itm in $pageItems){
				$pgObj = "" | Select-Object URL, Name, InnerName
				$pgObj.URL = $itm["FileRef"]
				$pgObj.Name = $pgObj.URL.split("/")[-2]+"/"+$pgObj.URL.split("/")[-1]
				$pgObj.InnerName = $pgObj.URL.split("/")[-1].Replace(".aspx","")
				#$pgObj.WebParts = get-PageWebPartAll $oldSiteURL $pgObj.URL
				$SPages += $pgObj
			}			
		
			#Write-Host $SitePagesName -f Yellow
			$sitePageItems = get-allListItemsByID $oldSiteURL $SitePagesName
		
			foreach ($itm in $sitePageItems){
				$pgObj = "" | Select-Object URL, Name, InnerName
				$pgObj.URL = $itm["FileRef"]
				$pgObj.Name = $pgObj.URL.split("/")[-2]+"/"+$pgObj.URL.split("/")[-1]
				$pgObj.InnerName = $pgObj.URL.split("/")[-1].Replace(".aspx","")
				#$pgObj.WebParts = get-PageWebPartAll $oldSiteURL $pgObj.URL
				$SPages += $pgObj
			}
			
			$sourceObj.Pages = $SPages


			$siteDumpObj.Source = $sourceObj
			$siteDumpObj.Destination = $DestObj
			
			
			$siteDumpFileName = ".\JSON\"+ $groupName+"-PagesDump.json"			
	
			$siteDumpObj | ConvertTo-Json -Depth 100 | out-file $siteDumpFileName -Encoding Default			
			write-Host "$siteDumpFileName Created..."
			
			$PagesToCreate = @()
			foreach($itemSrc in $siteDumpObj.Source.Pages){
				$itemExistsOnDest = $false
				foreach($itemDst in $siteDumpObj.Destination.Pages){
					if ($itemSrc.Name -eq $itemDst.Name)
					{
						$itemExistsOnDest = $true
						break
					}
				}
				if (!$itemExistsOnDest){
					if (!$itemSrc.Name.Contains("SitePages/")){
						$itemToCreate = "" | Select-Object Name, InnerName
						$itemToCreate.Name = $itemSrc.Name
						$itemToCreate.InnerName = $itemSrc.InnerName
					
						$PagesToCreate += $itemToCreate
					}
				}
			}
			
			$siteDumpFileName = ".\JSON\"+ $groupName+"-PagesToCreate.json"			
	
			$PagesToCreate | ConvertTo-Json -Depth 100 | out-file $siteDumpFileName -Encoding Default	
			write-Host "205: $siteDumpFileName Created..."
	
			foreach($itm in $PagesToCreate){
				Create-WPPage $siteURL $itm.InnerName $itm.InnerName
				write-Host "209: oldSiteURL : $oldSiteURL" -f Cyan
				write-Host "210: Page : $($itm.InnerName)" -f Cyan
				
			}
			#Create-WPPage $siteURL $itm.InnerName $itm.Title
			
			
		
			#$menuNewItems | ConvertTo-Json -Depth 100 | out-file $outfile -Encoding Default

			
		}
		else
		{
			Write-Host "File $jsonFile does not exists." -foregroundcolor Yellow
			Write-Host "Run 1.Get-SPRequest.ps1 first. " -foregroundcolor Yellow
		}
	}
	else
	{
		Write-Host "Group Name $groupName is not valid!" -foregroundcolor Yellow
	}
}	