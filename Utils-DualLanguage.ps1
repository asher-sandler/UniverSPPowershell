function check-DLangTemplInfrastruct($siteUrlC, $spRequestsListObj){

	$cpath = "TemplInf\"+$spRequestsListObj.GroupName
	
	write-host "Check for Template Infrastructure:  $cpath" -foregroundcolor Green
	

	$pages = "CancelCandidacy","SubmissionStatus","Recommendations","Form","Default"
	
	foreach($page in $pages){
		$pagePath = $cpath+"\"+$page
		#write-host $pagePath
		if (!$(Test-Path $pagePath)){
			new-item $pagePath -Type Directory | Out-Null
		}
	}
	

	foreach($page in $pages){
		$pagePath = $cpath+"\"+$page+"\OriginEn.txt"
		if (!$(Test-Path $pagePath)){
			$content = Get-PageContent $siteUrlC $page 
			$content | out-File $pagePath -Encoding Default
		}
		$pagePath = $cpath+"\"+$page+"\OriginHe.txt"
		if (!$(Test-Path $pagePath)){
			$content = Get-PageContent $siteUrlC $($page+"He") 
			$content | out-File $pagePath -Encoding Default
		}		
	}
	
	write-CancelCandidacy $cpath $siteUrlC
	$relUrl   = get-RelURL $siteUrlC
	write-SubmissionStatus $cpath $siteUrlC $relUrl

}

function write-CancelCandidacy($cpath,$siteUrlC){
 	$crlf = [char][int]13 + [char][int]10   
	$CurrPage = "CancelCandidacy"
	
	# ================== English ======================
    $contentCancelCandEn =  CancelCandidacyContentEn

    #write-host 	$contentCancelCandHe
    #write-host 	$contentCancelCandEn
	
	
	#$pagePath = $cpath+"\"+$CurrPage+"\ContentEn.txt"
	#$contentCancelCandEn | Out-File $pagePath -encoding Default
	
	
	
	#$oWP = Get-WPfromContent
	$originContentPathEn  = $cpath+"\"+$CurrPage+"\OriginEn.txt"
	$contentWpEn = get-content $originContentPathEn -Raw -Encoding Default
	
	$oWPEn = Get-WPfromContent $contentWpEn
    $i = 1
	
	$editContent = ""
	
	foreach ($wp in $oWPEn){
		if ($wp.isWP){
			$editContent += $wp.Content 
		}
		if ($i -eq 1){
			$editContent += $crlf + $contentCancelCandEn + $crlf
		}
		$i++
	}
	$editContentPathEn  = $cpath+"\"+$CurrPage+"\editEn.txt"
	$editContent | Out-File $editContentPathEn -encoding Default

    # ========================= Hebrew =================
	$contentCancelCandHe =  CancelCandidacyContentHe	
	
	$originContentPathHe  = $cpath+"\"+$CurrPage+"\OriginHe.txt"
	$contentWpHe = get-content $originContentPathHe -Raw -Encoding Default
	
	$oWPHe = Get-WPfromContent $contentWpHe
    $i = 1
	
	$editContent = ""
	
	foreach ($wp in $oWPHe){
		if ($wp.isWP){
			$editContent += $wp.Content 
		}
		if ($i -eq 1){
			$editContent += $crlf + $contentCancelCandHe + $crlf
		}
		$i++
	}
	$editContentPathHe  = $cpath+"\"+$CurrPage+"\editHe.txt"
	$editContent | Out-File $editContentPathHe -encoding Default
	
	# ======================== Switch to Lang ===================
	$sName = get-SiteNameFromNote $siteUrlC
	$swHe = SwitchToHeb $CurrPage $sName
	$editContentPathHe  = $cpath+"\"+$CurrPage+"\switchHe.txt"
	$swHe | Out-File $editContentPathHe -encoding Default
	
	$swEn = SwitchToEng $CurrPage $sName
	$editContentPathEn  = $cpath+"\"+$CurrPage+"\switchEn.txt"
	$swEn | Out-File $editContentPathEn -encoding Default
	
	

	#$pagePath = $cpath+"\"+$CurrPage+"\ContentHe.txt"
	#$contentCancelCandHe | Out-File $pagePath -encoding Default
	
	
		
	return $null
}


function write-SubmissionStatus($cpath,$siteUrlC, $relUrl){
 	$crlf = [char][int]13 + [char][int]10   
	$CurrPage = "SubmissionStatus"
	
	# ================== English ======================
    $contentSubmissionEn1 =  SubmissionStatusContentEn1 $relUrl
    $contentSubmissionEn2 =  SubmissionStatusContentEn2 

    
	$originContentPathEn  = $cpath+"\"+$CurrPage+"\OriginEn.txt"
	$contentWpEn = get-content $originContentPathEn -Raw -Encoding Default
	
	$oWPEn = Get-WPfromContent $contentWpEn
    $i = 1
	
	$editContent = ""
	
	foreach ($wp in $oWPEn){
		if ($wp.isWP){
			$editContent += $wp.Content 
		}
		if ($i -eq 1){
			$editContent += $crlf + $contentSubmissionEn1 + $crlf
		}
		if ($i -eq 3){
			$editContent += $crlf + $contentSubmissionEn2 + $crlf
		}		
		$i++
	}
	$editContentPathEn  = $cpath+"\"+$CurrPage+"\editEn.txt"
	$editContent | Out-File $editContentPathEn -encoding Default

    # ========================= Hebrew =================
    $contentSubmissionHe1 =  SubmissionStatusContentHe1 $relUrl
    $contentSubmissionHe2 =  SubmissionStatusContentHe2 
	
	$originContentPathHe  = $cpath+"\"+$CurrPage+"\OriginHe.txt"
	$contentWpHe = get-content $originContentPathHe -Raw -Encoding Default
	
	$oWPHe = Get-WPfromContent $contentWpHe
    $i = 1
	
	$editContent = ""
	
	foreach ($wp in $oWPHe){
		if ($wp.isWP){
			$editContent += $wp.Content 
		}
		if ($i -eq 1){
			$editContent += $crlf + $contentSubmissionHe1 + $crlf
		}
		if ($i -eq 3){
			$editContent += $crlf + $contentSubmissionHe2 + $crlf
		}		
		$i++
	}
	$editContentPathHe  = $cpath+"\"+$CurrPage+"\editHe.txt"
	$editContent | Out-File $editContentPathHe -encoding Default
	
	# ======================== Switch to Lang ===================
	$sName = get-SiteNameFromNote $siteUrlC
	$swHe = SwitchToHeb $CurrPage $sName
	$editContentPathHe  = $cpath+"\"+$CurrPage+"\switchHe.txt"
	$swHe | Out-File $editContentPathHe -encoding Default
	
	$swEn = SwitchToEng $CurrPage $sName
	$editContentPathEn  = $cpath+"\"+$CurrPage+"\switchEn.txt"
	$swEn | Out-File $editContentPathEn -encoding Default
	
	

	#$pagePath = $cpath+"\"+$CurrPage+"\ContentHe.txt"
	#$contentCancelCandHe | Out-File $pagePath -encoding Default
	
	
		
	return $null
}


function Get-PageContent($SiteName, $page){
	$PageContent = ""
	$siteNameN = get-UrlNoF5 $SiteName
	$siteNameNew = get-SiteNameFromNote $siteNameN
	$relUrl = get-RelURL $siteNameNew

	$relUrl   = get-RelURL $siteName
	
	$pageURL  = $relUrl + "Pages/"+ $page + ".aspx"
	
	write-host "Page URL: $pageURL"
	write-host "site Name: $siteNameNew"
	
	
	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteNameNew)
	$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)

	$page = $ctx.Web.GetFileByServerRelativeUrl($pageURL);
	$ctx.Load($page);
    $ctx.Load($page.ListItemAllFields);
    $ctx.ExecuteQuery();


	$page.CheckOut()
	$pageFields = $page.ListItemAllFields

	$PageContent = $pageFields["PublishingPageContent"]
	
	$page.UndoCheckOut()
	
	$ctx.ExecuteQuery()	
		
	write-host "Get Content of: $page" -foregroundcolor Yellow
	
	
	return $PageContent
}


$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"

$userName = "ekmd\ashersa"
$userPWD = "GrapeFloor789"


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
	
$siteUrlC = "https://scholarships2.ekmd.huji.ac.il/home/agriculture/AGR158-2021/Pages/Default.aspx"
$spRequestsListObj = "" | select-Object GroupName 
$spRequestsListObj.GroupName = "HSS_AGR158-2021"
check-DLangTemplInfrastruct $siteUrlC $spRequestsListObj 

