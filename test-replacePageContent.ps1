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
function copy-ImgLibX($siteURL,$oldSiteURL){
   $oldSiteURL = 	 get-UrlNoF5 $oldSiteURL
   $siteUrl    =   get-UrlNoF5 $siteUrl
 
   write-host "URL: $siteURL" -foregroundcolor Yellow
   write-host "URL: $oldSiteURL" -foregroundcolor Yellow
 

   $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
   $Ctx.Credentials = $Credentials
 

	
	$siteDumpObj = "" | Select-Object Source, Destination
	$sourceObj   = "" | Select-Object URL, RelPath, Lists, Pages      
	$DestObj     = "" | Select-Object URL, RelPath, Lists, Pages
	$RelURLSrc =  get-RelURL $siteUrl
	
	$sourceObj.Url = $oldSiteURL
	$sourceObj.RelPath = get-RelURL $oldSiteURL
	#$sourceObj.Lists = Collect-libs $oldSiteURL
		
	$DestObj.URL   = $siteUrl
	$DestObj.RelPath = $RelURLSrc
	#$DestObj.Lists   = Collect-libs $siteUrl

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
	
	
	$siteDumpFileName = ".\JSON\RPL-PagesDump.json"			

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
	
	$siteDumpFileName = ".\JSON\RPL-PagesToCreate.json"			

	$PagesToCreate | ConvertTo-Json -Depth 100 | out-file $siteDumpFileName -Encoding Default	
	write-Host "$siteDumpFileName Created..."

	foreach($itm in $PagesToCreate){
		#if ($itm.InnerName -eq "WritingInstructions"){
		if ($itm.InnerName -eq "Default"){
			write-Host $itm.InnerName -f Cyan
			$objPageCont = get-PageAndTitleContent $oldSiteURL $itm.Name
			
			$OutFileName = ".\JSON\RPL-PageCV.json"			
			$objPageCont | ConvertTo-Json -Depth 100 | out-file $OutFileName -Encoding Default	
			write-Host "$OutFileName Created..."
			
			write-Host "203: $RelURL"    -f Cyan
			write-Host "204: $RelURLSrc" -f Magenta
			
			
			$contNew = $objPageCont.Content -Replace $RelURL,$RelURLSrc
			$titl =  $objPageCont.Title 
			write-Host $titl  -f Green
			#write-Host $contNew -f Yellow
			
			#$aTagsNew = get-AllAnchorTags $contNew 				 $siteName
			#$aTagsOld = get-AllAnchorTags $objPageCont.Content	 $oldSiteURL
			
			
			$aImgsNew = get-ImgDocLib	$contNew 				 $siteName		
			$aImgsOld = get-ImgDocLib	$objPageCont.Content	 $oldSiteURL	
 			
			<#
			foreach($itmN in $aTagsNew){
				$doclibURL = "/"$itmN.href
				$libRealName = getListOrDocName $siteName $doclibURL "DocLib"
				write-Host $libRealName -f Cyan
			}
			#>
			
			copy-ImgFiles $aImgsOld $aImgsNew 
            write-Host 203
			
			foreach($itmN in $aTagsOld){
				write-Host "225: $($itmN.href)" -f Cyan
				if ($itmN.href.contains(".doc") -or $itmN.href.contains(".pdf")){
					
					$doclibURL = "/"+$itmN.href
					#$libRealName = getListOrDocName $oldSiteURL $doclibURL "DocLib"
					#write-Host $libRealName -f Cyan
					# create-DocLib $siteName $libRealName ""
					
					#$listRelUrlNew = get-ListURL $siteName $libRealName
					#write-Host $listRelUrlNew -f Magenta
					#write-Host $siteName -f Magenta
					
					#$listRelUrlOld = get-ListURL $oldSiteURL $libRealName
					#write-Host $([System.Uri]$listRelUrlOld).Host -f Yellow
					#write-Host $([System.Uri]$oldSiteURL).Host -f Yellow
				}
			}
			
			
			
				
			#$aTagsNew | fl
			#$aTagsOld | fl
			
			
			
			
			
			#Create-WPPage $siteURL $itm.InnerName $itm.InnerName
		}
	}
	}
function get-AllAnchorTags($htmlContent, $siteURL){
	
	$siteDomain = $([System.Uri]$siteURL).Host
	$aHtmlTags = @()

	$HTML = New-Object -Com "HTMLFile"
	$HTML.IHTMLDocument2_write($htmlContent)

		$HTML.All.Tags('a') | ForEach-Object{
		 $aTag = "" | Select-Object href,docLib,docLibName,docName,DNSHost
		     
			$aTag.href = [uri]::UnescapeDataString($_.href)
			$aTag.docName = [uri]::UnescapeDataString($_.nameProp)
			$aTag.docLib = [uri]::UnescapeDataString($_.search).replace("?","").replace($aTag.docName,"").replace("SourceUrl=","")
			$aTag.href = [uri]::UnescapeDataString($_.href).replace("about:","")
			
			$aTag.DNSHost =  $([System.Uri]$aTag.docLib).Host
			
			
			if ([string]::isNullOrEmpty($aTag.docLib)){
				$aTag.docLib = $aTag.href.replace($aTag.docName,"")
			}
			if ([string]::isNullOrEmpty($aTag.DNSHost)){
				$aTag.DNSHost = $siteDomain
			}
			#$aTag.foundInFile = $fileCont.ToLower().contains($_.parentNode.outerHTML.ToLower())
			if (!$aTag.docLib.contains("http")){
				$libRealName = getListOrDocName $siteURL $aTag.docLib "DocLib"
				$aTag.docLibName = $libRealName
				
				if ($aTag.docName.contains(".pdf") -or
					$aTag.docName.contains(".doc") ){
						$aHtmlTags += $aTag
					}
			}	
		}
	$OutFileName = ".\JSON\RPL-"+$siteDomain+"-aHtmlTags.json"			
	$aHtmlTags | ConvertTo-Json -Depth 100 | out-file $OutFileName -Encoding Default	
	write-Host "$OutFileName Created..."

	return $aHtmlTags		

}	
function test-HtmlObj(){
	$OutFileName = ".\JSON\RPL-PageCV.json"
	$spObj = get-content $outFileName -encoding default | ConvertFrom-Json
	$HTML = New-Object -Com "HTMLFile"
	$HTML.IHTMLDocument2_write($spObj.Content)
	$HTML.All.Tags('a')
}	
$Credentials = get-SCred

 
 $oldSiteURL = "https://grs2.ekmd.huji.ac.il/home/socialSciences/SOC37-2020/";
 $oldSiteURL = "https://scholarships2.ekmd.huji.ac.il/home/NaturalScience/SCI49-2020/";
 $oldSiteURL = "https://ttp2.ekmd.huji.ac.il/home/Humanities/HUM21-2020/";
 $oldSiteURL = "https://scholarships2.ekmd.huji.ac.il/home/Humanities/HUM150-2021";
 $oldSiteURL = "https://scholarships2.ekmd.huji.ac.il/home/humanities/HUM156-2021";
 $siteName   = "https://portals2.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace"
 $siteName   = "https://scholarships2.ekmd.huji.ac.il/home/Humanities/HUM186-2021"
 copy-ImgLibX $siteName $oldSiteURL
 
