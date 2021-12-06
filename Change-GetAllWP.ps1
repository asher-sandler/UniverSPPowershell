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
function edt-WPPropSubmit($siteUrlC ,$pageURL, $wpName ,$wpKey, $wpValue){
	$siteName = get-UrlNoF5 $siteUrlC
	write-host "Change WP $wpName " -foregroundcolor Yellow 
	write-host "On $pageURL " -foregroundcolor Yellow
	write-host "on Site: $siteName" -foregroundcolor Yellow
	
	write-Host "$wpKey, $wpValue" -f Cyan

	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials

	$page = $ctx.Web.GetFileByServerRelativeUrl($pageURL);
	$webpartManager = $page.GetLimitedWebPartManager([Microsoft.Sharepoint.Client.WebParts.PersonalizationScope]::Shared);	
	
	# Write-Host 'Updating webpart "'+$wpName+'" on the page ' + $pageName -ForegroundColor Green
	$page.CheckOut()	
	$WebParts = $webpartManager.WebParts
	$ctx.Load($webpartManager);
	$ctx.Load($WebParts);
	$ctx.ExecuteQuery();
	foreach($wp in $webparts){
			
			$ctx.Load($wp.WebPart.Properties)
			$ctx.Load($wp.WebPart)
			$ctx.Load($wp)
			$ctx.ExecuteQuery() 
			if ($wp.WebPart.Title -eq $wpName){

				[Int32]$OutNumber = $null

				if ([Int32]::TryParse($wpValue, [ref]$OutNumber)){
					#Write-Host "Valid Number"
					$wpValue = $OutNumber
				} else {
						
					if ($wpValue -eq "True"){
						$wpValue = $true
					}
					if ($wpValue -eq "False"){
						$wpValue = $false
					}
				}
				$wp.WebPart.Properties[$wpKey] = $wpValue
				if ($wp.WebPart.Title -eq "Dynamic Form - v 2.0"){
					
					$wp.WebPart.Properties["addColumns"] = $true;
					$wp.WebPart.Properties["addLists"] = $true;
					
				}
				
				$wp.SaveWebPartChanges();				
			}		
	}
	$page.CheckIn("Change '"+$wpName+"'", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
	$page.Publish("Change '"+$wpName+"'")
	$ctx.ExecuteQuery()
	
	
}

$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"

$cred = get-SCred

 
 $siteURL = "https://grs2.ekmd.huji.ac.il/home/OverseasApplicantsUnit/GEN31-2021";
 #$pageURL = "/home/OverseasApplicantsUnit/GEN32-2022/Pages/academicFrom.aspx"
 
 write-host "URL : $siteURL" -foregroundcolor Yellow
 write-host "Page: $pageURL" -foregroundcolor Yellow

 #$outObj = get-PageWebPartAll $siteURL $pageURL
 #$outJson = ".\JSON\Test-GetAllWP.json"
 $RelURL = get-RelURL $siteURL
 $PagesName = getListOrDocName $siteUrl $($RelURL+"Pages") "DocLib" 
 $pageItems = get-allListItemsByID $siteUrl $PagesName
 
 $SPages = @()
			
	foreach ($itm in $pageItems){
		$pgObj = "" | Select-Object URL, WebParts
		$pgObj.URL = $itm["FileRef"]
		#$pgObj.WebParts = get-PageWebPartAll $oldSiteURL $pgObj.URL
		$SPages += $pgObj
	}
 $outJson = ".\JSON\Change-GetAllPages.json"
 
 $webPartName = "Dynamic Form - v 2.0"
 $wpKey = "submit"
 $wpValue =  "True"
 $i=0
 
 
 #
 foreach($pageItm in $SPages){
	 if ($pageItm.Url.Contains(".aspx")){
		 $pageURL = $pageItm.Url
		 write-host $pageURL -f Cyan
		 write-Host $i
		 edt-WPPage $siteUrl  $pageURL $webPartName $wpKey  $wpValue
		 $i++
		 
		 #if ($i -ge 10){
		#	break 
		 #}
		 
	 }
 }
 #
 
 $SPages | ConvertTo-Json -Depth 100 | out-file $outJson -Encoding Default
