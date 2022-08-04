param(
	
	[string]$srcPageURL = "https://ttp2.ekmd.huji.ac.il/home/NaturalScience/SCI31-2020/Pages/RefereesForm.aspx",
	#[string]$srcPageURL = "https://ttp2.ekmd.huji.ac.il/home/NaturalScience/SCI31-2020/Pages/DocumentsUpload.aspx",
	
	[string]$dstPageURL = "https://ttp2.ekmd.huji.ac.il/home/NaturalScience/SCI37-2022/Pages/RefereesForm.aspx"
	#[string]$dstPageURL = "https://ttp2.ekmd.huji.ac.il/home/NaturalScience/SCI37-2022/Pages/DocumentsUpload.aspx"
	)

function get-PageWebPartAll($SiteURL,$pageURL){
	
	$wpsObject = $null
	if ($pageURL.contains(".aspx")){
		
			$siteName = get-UrlNoF5 $SiteURL
		
		write-Host $pageURL -f Cyan
		$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
		$Ctx.Credentials = $Credentials
		$page = $ctx.Web.GetFileByServerRelativeUrl($pageURL);
		
		$ctx.Load($page);
		$ctx.Load($page.ListItemAllFields);
		$ctx.ExecuteQuery();

		$page.CheckOut()
		$pageFields = $page.ListItemAllFields

		$webpartManager = $page.GetLimitedWebPartManager([Microsoft.Sharepoint.Client.WebParts.PersonalizationScope]::Shared);	
		
		Write-Host "Get webparts on the page : $pageURL" -ForegroundColor Green

		
		$WebParts = $webpartManager.WebParts
		$ctx.Load($webpartManager);
		$ctx.Load($WebParts);
		$ctx.ExecuteQuery();
		
		$wpsObject = @()	
		
		foreach($wp in $webparts){
				
				
				
				$ctx.Load($wp.WebPart.Properties)
				$ctx.Load($wp.WebPart)
				$ctx.Load($wp)
				$ctx.ExecuteQuery() 
				write-host $wp.WebPart.Title
				$wps = "" | Select-Object Title, Properties
				$wps.Title = $wp.WebPart.Title
				
				$props = @()
				$keys = @()
				$values = @()
				foreach($fv in $wp.WebPart.Properties.FieldValues){
					foreach($fkey in $fv.Keys){
						$keys  += $fkey
					}
					foreach($fval in $fv.Values){
						$values += $fval
					}
				}
				for($i=0;$i -lt $keys.Count;$i++){
					$prop = "" | Select Key,Value
					$prop.Key = $keys[$i]
					$prop.Value = $values[$i]
					$props += $prop
				}
				$wps.Properties = $props
				$wpsObject += $wps
				<#
				if ($wp.WebPart.Title -eq $wpName){
					$wp.WebPart.Properties["WP_Language"] = $lang
					$wp.WebPart.Properties["EmailTemplatePath"] = $spObj.MailPath
					
					$wp.WebPart.Properties["EmailTemplateName"] = $spObj.MailFile;
					
					$wp.SaveWebPartChanges();				
				}
				#>
		}
		#$PageContent = $pageFields["PublishingPageContent"]
		
		$page.UndoCheckOut()
		
		$ctx.ExecuteQuery()	
	}
	return $wpsObject

}
function CompareWPProps( $siteURL, $PageURL,$webPartDst, $webPartSrc){
	$errorWP = @()
	#$wpPropsDst =  CreatePropsArr $webPartDst.Properties
	#$wpPropsSrc =  CreatePropsArr $webPartSrc.Properties
	foreach($wpDST in  $webPartDst.WP){
		$wpdstTitle = $wpDST.Title
		$destTemplate = $webPartDst.Template.ToUpper()
		$srcTemplate = $webPartSrc.Template.ToUpper()
		write-Host "Destin Template: $destTemplate" -f Yellow
		write-Host "Source Template: $srcTemplate" -f Yellow
		write-Host 
		foreach($wpSrc in  $webPartSrc.WP){
			$wpSrcTitle = $wpSrc.Title
			$notMatch = $false
			if ($wpdstTitle -eq $wpSrcTitle){
				write-host "Destination WP Title: $wpdstTitle"	
				foreach($dstProps in $wpDST.Properties){
					$dstKey = $dstProps.Key
					$dstValue = $dstProps.Value
					if (![string]::IsNullOrEmpty($dstValue)){
						if ($dstValue.GetType().Name -eq "String"){
							$dstValue = $dstValue.ToUpper()
						}
					}
					foreach($srcProps in $wpSrc.Properties){
						$srcKey = $srcProps.Key
						#Write-Host "Source Key : $srcKey"
						$srcValue = $srcProps.Value
						if (![string]::IsNullOrEmpty($srcValue)){
							if ($srcValue.GetType().Name -eq "String"){
								$srcValue = $srcValue.ToUpper().Replace($srcTemplate,$destTemplate)
							}
						}
						
						if ($srcKey -eq $dstKey){
							if ($srcValue -ne $dstValue){
								write-Host "Key: $dstKey"
								write-Host "Source Value: $srcValue"
								write-Host "Destin Value: $dstValue"
								$itmNotMatch = "" | Select Site, Page, WPTitle, Key, Value, PrevValue
								$itmNotMatch.Site = $siteURL
								$itmNotMatch.Page = $PageURL
								$itmNotMatch.WPTitle = $wpdstTitle
								$itmNotMatch.Key = $dstKey
								$itmNotMatch.Value = $srcProps.Value # $srcValue
								$itmNotMatch.PrevValue = $dstProps.Value # $dstValue
								$errorWP += $itmNotMatch
								$notMatch = $true
							}
						}
					}						
				}
			}
			if (!$notMatch){
				write-Host "All Fields in WP are equals." -f Green
			}
		}
		
			
	}
		
	return $errorWP
	
}
<#
function Find-WebParts($src,    $webPart, $dstRelPath){
	$srcRelPath = $src.RelPath
	#write-Host $srcRelPath -f Magenta
	#write-Host $dstRelPath -f Magenta
	#read-host
	$eWP = @()
	foreach($wpsrc in $src.WP){
		if ($wpsrc.Title -eq $webPart.Title){
			write-Host "Compare WP : $($wpsrc.Title) "
			$eWPEl = CompareWPProps $webPart $wpsrc $srcPage $dstPage.URL
			$eWP += $eWPEl
		}
	}	
	return $eWP
}
#>
<#
function check-WebParts($src,$dst){
	$dstRelPath = $dst.RelPath
	$cWP = @()
	
	$dstWP   = $dst.WP
	if (![string]::isNullOrEmpty($dstWP)){
			
			$dstWP.Properties

		write-Host "DestPage  : $dstPage" -f Green
		foreach($wpItem in $dstWP){
			write-Host $wpItem
			$webPartName = $wpItem.Title
			write-Host "webPartName : $webPartName" -f Cyan
			#read-host
			$cElWP = Find-WebParts $src  $wpItem $dstRelPath
			$cWP += $cElWP
		}
	}
	
	return $cWP
}
#>
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

$Credentials = get-SCred

 
 $siteName = "";
 
 $siteUrlSRC = get-UrlNoF5 $srcPageURL
 $siteUrlDST = get-UrlNoF5 $dstPageURL

 $dnsNameSRC = [System.Uri]$siteUrlSRC
 $dnsNameDST = [System.Uri]$siteUrlDST
 $pagePathSRC  = $dnsNameSRC.AbsolutePath
 $pagePathDST  = $dnsNameDST.AbsolutePath
 $validParam = $false
 if ($pagePathSRC.ToUpper().Contains("/PAGES/") -and
	 $pagePathSRC.ToUpper().Contains(".ASPX"))
	 {$validParam = $true
	 }
 if ($validParam){	 
	if ($pagePathDST.ToUpper().Contains("/PAGES/") -and
		$pagePathDST.ToUpper().Contains(".ASPX"))
		{$validParam = $true
		}
 }
 if ($validParam){
	    $srcURL = $siteUrlSRC.Substring(0,$siteUrlSRC.ToUpper().IndexOf("/PAGES"))
	    $dstURL = $siteUrlDST.Substring(0,$siteUrlDST.ToUpper().IndexOf("/PAGES"))
		
		write-host "Source URL: $srcURL" -foregroundcolor Cyan
		write-host "Destin URL: $dstURL" -foregroundcolor Magenta
 
		write-host "Source Page: $pagePathSRC" -foregroundcolor Cyan
		write-host "Destin Page: $pagePathDST" -foregroundcolor Magenta
 
		#read-host

		$siteDumpObj = "" | Select-Object Source, Destination
		$sourceObj   = "" | Select-Object URL, RelPath, Template, pagePath, WP      
		$DestObj     = "" | Select-Object URL, RelPath, Template,pagePath, WP     

		$sourceObj.Url = $srcURL
		$sourceObj.RelPath = get-RelURL $srcURL
		$sourceObj.Template = $sourceObj.RelPath.Split("/")[-2]
		$sourceObj.pagePath = $pagePathSRC
		$sourceObj.WP = get-PageWebPartAll $srcURL $sourceObj.pagePath

		$DestObj.Url = $dstURL
		$DestObj.RelPath = get-RelURL $dstURL
		$DestObj.Template = $DestObj.RelPath.Split("/")[-2]
		$DestObj.pagePath = $pagePathDST
		$DestObj.WP = get-PageWebPartAll $dstURL $DestObj.pagePath

		$siteDumpObj.Source = $sourceObj
		$siteDumpObj.Destination = $DestObj
		
		#$WPNotEquals = check-WebParts $sourceObj $DestObj		
		
		$siteDumpFileName = ".\JSON\"+$sourceObj.Template+"-ComparePages.json"
		$siteDumpObj | ConvertTo-Json -Depth 100 | out-file $siteDumpFileName -Encoding Default
		write-host "written file $siteDumpFileName"	

		if (!$wpValue.Contains("Switch")){ # pass WP Switch Language
						    if (!($wpKey -eq "InstallDate")){  # pass WP AE Banner Rotator = CompareWPProps $dstURL $pagePathDST $DestObj $sourceObj
		
		$siteDumpFileName = ".\JSON\"+$sourceObj.Template+"-WPNotMatches.json"
		$NotValidateWPProps | ConvertTo-Json -Depth 100 | out-file $siteDumpFileName -Encoding Default
		write-host "written file $siteDumpFileName"	
		
		foreach($wpitem in $NotValidateWPProps){
		
			if (!$wpitem.Value.Contains("Switch")){ # pass WP Switch Language
				if (!($wpitem.Key -eq "InstallDate")){  # pass WP AE Banner Rotator
					edt-WPPage $wpitem.Site  $wpitem.Page $wpitem.WPTitle $wpitem.Key  $wpitem.Value
				}
			}
		}
		
		
 }
 else
 {
	 write-host "Source Site And Destination site must contains full path to " -f Yellow
	 write-host "Source And Destination pages"  -f Yellow
	 write-host "i.e 'https://ttp2.ekmd.huji.ac.il/home/NaturalScience/SCI37-2022/Pages/RefereesForm.aspx'"  -f Yellow
 }
	 
 