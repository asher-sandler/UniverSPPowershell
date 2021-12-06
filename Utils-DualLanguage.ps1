function check-DLangTemplInfrastruct($siteUrlC, $spRequestsListObj,$oldSiteExists, $oldSiteName){

	$cpath = Get-CPath $($spRequestsListObj.GroupName)
	
	write-host "Check for Template Infrastructure:  $cpath" -foregroundcolor Green
	

	$pages = "CancelCandidacy","SubmissionStatus","Recommendations","Form","Default"
	
	foreach($page in $pages){
		$pagePath = $cpath+"\"+$page
		#write-host $pagePath
		if (!$(Test-Path $pagePath)){
			new-item $pagePath -Type Directory | Out-Null
		}
	}
	$pagePath = $cpath+"\Switch"
	if (!$(Test-Path $pagePath)){
		new-item $pagePath -Type Directory | Out-Null
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
	write-Recommendations  $cpath $siteUrlC $relUrl
	write-Form			   $cpath $siteUrlC $relUrl 
	write-Default		   $cpath $siteUrlC $relUrl $($spRequestsListObj.deadLineText) $oldSiteExists $oldSiteName

}

function Get-CPath($groupName){
	return "TemplInf\"+$groupName
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
		if ($i -eq 2){
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
		if ($i -eq 2){
			$editContent += $crlf + $contentCancelCandHe + $crlf
		}
		$i++
	}
	
	$editContentPathHe  = $cpath+"\"+$CurrPage+"\editHe.txt"
	$editContent | Out-File $editContentPathHe -encoding Default
	
	# ======================== Switch to Lang ===================
	$sName = get-SiteNameFromNote $siteUrlC
	$swHe = SwitchToHeb $CurrPage $sName
	$HeStyle = CancelButtonHeStyle
	$swHe = $HeStyle + $swHe
	$editContentPathHe  = $cpath+"\"+$CurrPage+"\SwitchHe.txt"
	$swHe | Out-File $editContentPathHe -encoding Default
	$editContentPathHe  = $cpath+"\Switch\"+$CurrPage+"SwitchHe.txt"
	$swHe | Out-File $editContentPathHe -encoding Default
	
	$swEn = SwitchToEng $CurrPage $sName
	$editContentPathEn  = $cpath+"\"+$CurrPage+"\SwitchEn.txt"
	$swEn | Out-File $editContentPathEn -encoding Default
	$editContentPathEn  = $cpath+"\Switch\"+$CurrPage+"SwitchEn.txt"
	$swEn | Out-File $editContentPathEn -encoding Default
	
	

	#$pagePath = $cpath+"\"+$CurrPage+"\ContentHe.txt"
	#$contentCancelCandHe | Out-File $pagePath -encoding Default
	
	
		
	return $null
}

function CancelButtonHeStyle()
{
	return '<style unselectable="on">.cancelBtn {float: right;}</style>​​'
}
function write-SubmissionStatus($cpath,$siteUrlC, $relUrl){
 	$crlf = [char][int]13 + [char][int]10   
	$CurrPage = "SubmissionStatus"
	
	# ================== English ======================
    $contentSubmissionEn1 =  SubmissionStatusDLangContentEn1 $relUrl
    $contentSubmissionEn2 =  SubmissionStatusDLangContentEn2 

    
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
		if ($i -eq 2){
			$editContent += $crlf + $contentSubmissionEn2 + $crlf
		}		
		$i++
	}
	$editContentPathEn  = $cpath+"\"+$CurrPage+"\editEn.txt"
	$editContent | Out-File $editContentPathEn -encoding Default

    # ========================= Hebrew =================
    $contentSubmissionHe1 =  SubmissionStatusDLangContentHe1 $relUrl
    $contentSubmissionHe2 =  SubmissionStatusDLangContentHe2 
	
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
		if ($i -eq 2){
			$editContent += $crlf + $contentSubmissionHe2 + $crlf
		}		
		$i++
	}
	$editContentPathHe  = $cpath+"\"+$CurrPage+"\editHe.txt"
	$editContent | Out-File $editContentPathHe -encoding Default
	
	# ======================== Switch to Lang ===================
	$sName = get-SiteNameFromNote $siteUrlC
	$swHe = SwitchToHeb $CurrPage $sName
	$editContentPathHe  = $cpath+"\"+$CurrPage+"\SwitchHe.txt"
	$swHe | Out-File $editContentPathHe -encoding Default
	$editContentPathHe  = $cpath+"\Switch\"+$CurrPage+"SwitchHe.txt"
	$swHe | Out-File $editContentPathHe -encoding Default
	
	$swEn = SwitchToEng $CurrPage $sName
	$editContentPathEn  = $cpath+"\"+$CurrPage+"\SwitchEn.txt"
	$swEn | Out-File $editContentPathEn -encoding Default
	$editContentPathEn  = $cpath+"\Switch\"+$CurrPage+"SwitchEn.txt"
	$swEn | Out-File $editContentPathEn -encoding Default
	
	

	#$pagePath = $cpath+"\"+$CurrPage+"\ContentHe.txt"
	#$contentCancelCandHe | Out-File $pagePath -encoding Default
	
	
		
	return $null
}


function write-Recommendations($cpath,$siteUrlC, $relUrl){
 	$crlf = [char][int]13 + [char][int]10   
	$CurrPage = "Recommendations"
	
	# ================== English ======================
    $contentRecommendationsEn1 =  RecommendationsDLangContentEn1 
    $contentRecommendationsEn2 =  RecommendationsDLangContentEn2 

    
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
			$editContent +=  $crlf+ $crlf + $contentRecommendationsEn1 + $crlf+ $crlf
		}
		if ($i -eq 2){
			$editContent += $crlf+ $crlf + $contentRecommendationsEn2 + $crlf+ $crlf
		}		
		$i++
	}
	$editContentPathEn  = $cpath+"\"+$CurrPage+"\editEn.txt"
	$editContent | Out-File $editContentPathEn -encoding Default -Force 
	
    # ========================= Hebrew =================
    $contentRecommendationsHe1 =  RecommendationsDLangContentHe1 
    $contentRecommendationsHe2 =  RecommendationsDLangContentHe2 
	
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
			$editContent += $crlf+ $crlf + $contentRecommendationsHe1 + $crlf+ $crlf
		}
		if ($i -eq 2){
			$editContent += $crlf+ $crlf + $contentRecommendationsHe2 + $crlf+ $crlf
		}		
		$i++
	}
	$editContentPathHe  = $cpath+"\"+$CurrPage+"\editHe.txt"
	$editContent | Out-File $editContentPathHe -encoding Default
	
	# ======================== Switch to Lang ===================
	$sName = get-SiteNameFromNote $siteUrlC
	$swHe = SwitchToHeb $CurrPage $sName
	$editContentPathHe  = $cpath+"\"+$CurrPage+"\SwitchHe.txt"
	$swHe | Out-File $editContentPathHe -encoding Default
	$editContentPathHe  = $cpath+"\Switch\"+$CurrPage+"SwitchHe.txt"
	$swHe | Out-File $editContentPathHe -encoding Default
	
	$swEn = SwitchToEng $CurrPage $sName
	$editContentPathEn  = $cpath+"\"+$CurrPage+"\SwitchEn.txt"
	$swEn | Out-File $editContentPathEn -encoding Default
	$editContentPathEn  = $cpath+"\Switch\"+$CurrPage+"SwitchEn.txt"
	$swEn | Out-File $editContentPathEn -encoding Default
	
	

	#$pagePath = $cpath+"\"+$CurrPage+"\ContentHe.txt"
	#$contentCancelCandHe | Out-File $pagePath -encoding Default
	
	
		
	return $null
}

function write-Form ($cpath,$siteUrlC, $relUrl){
 	$crlf = [char][int]13 + [char][int]10   
	$CurrPage = "Form"
	
	# ================== English ======================
    
    
	$originContentPathEn  = $cpath+"\"+$CurrPage+"\OriginEn.txt"
	$contentWpEn = get-content $originContentPathEn -Raw -Encoding Default
	
	$oWPEn = Get-WPfromContent $contentWpEn
    $i = 1
	
	$editContent = ""
	
	foreach ($wp in $oWPEn){
		if ($wp.isWP){
			$editContent += $wp.Content 
		}
		
		$i++
	}
	$editContentPathEn  = $cpath+"\"+$CurrPage+"\editEn.txt"
	$editContent | Out-File $editContentPathEn -encoding Default

    # ========================= Hebrew =================
  
	$originContentPathHe  = $cpath+"\"+$CurrPage+"\OriginHe.txt"
	$contentWpHe = get-content $originContentPathHe -Raw -Encoding Default
	
	$oWPHe = Get-WPfromContent $contentWpHe
    $i = 1
	
	$editContent = ""
	
	foreach ($wp in $oWPHe){
		if ($wp.isWP){
			$editContent += $wp.Content 
		}
			
		$i++
	}
	$editContentPathHe  = $cpath+"\"+$CurrPage+"\editHe.txt"
	$editContent | Out-File $editContentPathHe -encoding Default
	
	# ======================== Switch to Lang ===================
	$sName = get-SiteNameFromNote $siteUrlC
	$swhe  =  DefaultHeStyle
	$swHe += SwitchToHeb $CurrPage $sName
	$editContentPathHe  = $cpath+"\"+$CurrPage+"\SwitchHe.txt"
	$swHe | Out-File $editContentPathHe -encoding Default
	$editContentPathHe  = $cpath+"\Switch\"+$CurrPage+"SwitchHe.txt"
	$swHe | Out-File $editContentPathHe -encoding Default
	
	#$swEn  =  DefaultHeStyle
	$swEn  = SwitchToEng $CurrPage $sName
	$editContentPathEn  = $cpath+"\"+$CurrPage+"\SwitchEn.txt"
	$swEn | Out-File $editContentPathEn -encoding Default
	$editContentPathEn  = $cpath+"\Switch\"+$CurrPage+"SwitchEn.txt"
	$swEn | Out-File $editContentPathEn -encoding Default
	
	return $null
}


function write-Default($cpath,$siteUrlC, $relUrl, $deadline, $oldSiteExists, $oldSiteName){
 	$crlf = [char][int]13 + [char][int]10   
	$CurrPage = "Default"
	
	$oldRelUrl = get-RelURL $oldSiteName
	# ================== English ======================
    $contentDefaultEn1 =  DefaultDLangContentEn1 $deadline
    $contentDefaultEn2 =  DefaultDLangContentEn2 $relUrl


	$editContent = ""
	$oldContentEnOrig = ""
	$oldContentHeOrig = ""
	$oldContentEn = ""
	$oldContentHe = ""	
	if ($oldSiteExists){
		$oldContentEnOrig = Get-PageContent $oldSiteName "Default" 
		$oldContentEnOrig = $oldContentEnOrig -Replace $oldRelUrl, $relUrl 
		$oldContentHeOrig = Get-PageContent $oldSiteName "DefaultHe"
		$oldContentHeOrig = $oldContentHeOrig -Replace $oldRelUrl, $relUrl 

        $oWPOldEn = Get-WPfromContent $oldContentEnOrig
        $oWPOldHe = Get-WPfromContent $oldContentHeOrig
		
		foreach($wp in $oWPOldEn){
			if (!$wp.isWP){
				$oldContentEn += $wp.Content
			}
		}
		#write-host $oldContentEn -f Cyan
		#read-host 
		
		foreach($wp in $oWPOldHe){
			if (!$wp.isWP){
				$oldContentHe += $wp.Content
			}
		}		
		
	}	
	
    
	$originContentPathEn  = $cpath+"\"+$CurrPage+"\OriginEn.txt"
	$contentWpEn = get-content $originContentPathEn -Raw -Encoding Default
	
	$oWPEn = Get-WPfromContent $contentWpEn
    $i = 1
	

	foreach ($wp in $oWPEn){
		
		if ($wp.isWP){
				$editContent += $wp.Content 
		}
		if (!$oldSiteExists){
			if ($i -eq 1){
				$editContent +=  $crlf+ $crlf + $contentDefaultEn1 + $crlf+ $crlf
			
				$editContent += $crlf+ $crlf + $contentDefaultEn2 + $crlf+ $crlf
			}
		}
		else
		{
			# need to get Old Site Default Content
			#write-host $wp
			#if (!$wp.isWP){
				#write-host "we are here"
				# get Old Site Content
			#	write-host $oldSiteName
			#	write-host $oldRelUrl
			#	$editContent += $wp.Content	-Replace $oldRelUrl, $relUrl
			#}
		}		
		$i++
	}
	$editContentPathEn  = $cpath+"\"+$CurrPage+"\editEn.txt"
	
	$editContent += $oldContentEn
	$editContent | Out-File $editContentPathEn -encoding Default
	$ContentR = Get-Content $editContentPathEn -encoding Default
	$ContentR1 = $ContentR.Replace( "&#58;", ":")
	$ContentR1 | Out-File $editContentPathEn -encoding Default -Force	

    # ========================= Hebrew =================
    $contentDefaultHe1 =  DefaultDLangContentHe1 $deadline
    $contentDefaultHe2 =  DefaultDLangContentHe2 $relUrl
	
	$originContentPathHe  = $cpath+"\"+$CurrPage+"\OriginHe.txt"
	$contentWpHe = get-content $originContentPathHe -Raw -Encoding Default
	
	$oWPHe = Get-WPfromContent $contentWpHe
    $i = 1
	
	$editContent = ""
	

	
	foreach ($wp in $oWPHe){
		if ($wp.isWP){
			$editContent += $wp.Content 
		}
		if (!$oldSiteExists){
			if ($i -eq 1){
				$editContent += $crlf+ $crlf + $contentDefaultHe1 + $crlf+ $crlf
		
				$editContent += $crlf+ $crlf + $contentDefaultHe2 + $crlf+ $crlf
			}
		}
		else
		{
			# need to get Old Site Default Content
			#if (!$wp.isWP){
			#	write-host $oldSiteName
			#	write-host $oldRelUrl
			#	$editContent += $wp.Content	-Replace $oldRelUrl, $relUrl
			#}			
		}	
		$i++
	}
	$editContentPathHe  = $cpath+"\"+$CurrPage+"\editHe.txt"
	$editContent += $oldContentHe
	$editContent | Out-File $editContentPathHe -encoding Default -Force
	$ContentR = Get-Content $editContentPathHe -encoding Default
	$ContentR1 = $ContentR.Replace( "&#58;", ":")
	$ContentR1 | Out-File $editContentPathHe -encoding Default -Force
	
	# ======================== Switch to Lang ===================
	$sName = get-SiteNameFromNote $siteUrlC

	$swHe = SwitchToHeb $CurrPage $sName
	
	
	$editContentPathHe  = $cpath+"\"+$CurrPage+"\SwitchHe.txt"
	$swHe | Out-File $editContentPathHe -encoding Default
	$editContentPathHe  = $cpath+"\Switch\"+$CurrPage+"SwitchHe.txt"
	$swHe | Out-File $editContentPathHe -encoding Default


	
	$swEn = SwitchToEng $CurrPage $sName
	$editContentPathEn  = $cpath+"\"+$CurrPage+"\SwitchEn.txt"
	$swEn | Out-File $editContentPathEn -encoding Default
	$editContentPathEn  = $cpath+"\Switch\"+$CurrPage+"SwitchEn.txt"
	$swEn | Out-File $editContentPathEn -encoding Default

	#$pagePath = $cpath+"\"+$CurrPage+"\ContentHe.txt"
	#$contentCancelCandHe | Out-File $pagePath -encoding Default
	
	return $null
}

function edt-SwitchPage2Lang($SiteName){
	
	$siteNameN = get-UrlNoF5 $SiteName
	$pages = "CancelCandidacy","SubmissionStatus","Recommendations","Form","Default"
	foreach($pg in $pages){
		$pageName = "Pages/"+$pg+".aspx"	
		$relUrl   = get-RelURL $siteNameN
		
		$pageURL  = $relUrl + $pageName
		write-host $pageURL -f Cyan
		
		
		$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteNameN) 
		$ctx.Credentials = $Credentials	
		$page = $ctx.Web.GetFileByServerRelativeUrl($pageURL);
		
		$webpartManager = $page.GetLimitedWebPartManager([Microsoft.Sharepoint.Client.WebParts.PersonalizationScope]::Shared);	
		
		Write-Host 'Updating webpart "ContentEditorWebPart"  from the page '+$pg+'.aspx' -ForegroundColor Green
		$page.CheckOut()	
		$WebParts = $webpartManager.WebParts
		$ctx.Load($webpartManager);
		$ctx.Load($WebParts);
		$ctx.ExecuteQuery();
		$contentEdited = $false
		foreach($wp in $webparts){
				
				$ctx.Load($wp.WebPart.Properties)
				$ctx.Load($wp.WebPart)
				$ctx.Load($wp)
				$ctx.ExecuteQuery() 
				if ($wp.WebPart.Title -eq "ContentEditorWebPart"){
					if ($contentEdited){
						$wp.WebPart.Properties["Hidden"] = $true
					}
					else
					{
						$wp.WebPart.Properties["ContentLink"] = $relUrl + "SwitchModule/"+$pg+"SwitchEn.txt"
						$contentEdited = $true
					}
					$wp.SaveWebPartChanges();
					#break;
				}		
		}
		$page.CheckIn("Change 'ContentEditorWebPart'", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
		$page.Publish("Change 'ContentEditorWebPart'")
		$ctx.ExecuteQuery()
		
		$pageName = "Pages/"+$pg+"He.aspx"	
		$relUrl   = get-RelURL $siteNameN
		
		$pageURL  = $relUrl + $pageName

		$page = $ctx.Web.GetFileByServerRelativeUrl($pageURL);
		
		$webpartManager = $page.GetLimitedWebPartManager([Microsoft.Sharepoint.Client.WebParts.PersonalizationScope]::Shared);	
		
		Write-Host 'Updating webpart "ContentEditorWebPart"  from the page '+$pg+'He.aspx' -ForegroundColor Green
		$page.CheckOut()	
		$WebParts = $webpartManager.WebParts
		$ctx.Load($webpartManager);
		$ctx.Load($WebParts);
		$ctx.ExecuteQuery();
		$contentEdited = $false
		foreach($wp in $webparts){
				
				$ctx.Load($wp.WebPart.Properties)
				$ctx.Load($wp.WebPart)
				$ctx.Load($wp)
				$ctx.ExecuteQuery() 
				if ($wp.WebPart.Title -eq "ContentEditorWebPart"){
					if ($contentEdited){
						$wp.WebPart.Properties["Hidden"] = $true
					}
					else
					{
						
						$wp.WebPart.Properties["ContentLink"] = $relUrl + "SwitchModule/"+$pg+"SwitchHe.txt"
						$contentEdited = $true
					}
					$wp.SaveWebPartChanges();
					
				}		
		}
		$page.CheckIn("Change 'ContentEditorWebPart'", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
		$page.Publish("Change 'ContentEditorWebPart'")
		$ctx.ExecuteQuery()
		
		
	}	
	
	
	return $null	
}
function get-NewDefault($newSiteName, $language, $deadline){
	$crlf = [char][int]13 + [char][int]10
	$result = ""
	$RelUrl = get-RelURL $newSiteName
	if ($language.ToLower().contains("en")){
		
		$contentDefault1 =  DefaultDLangContentEn1 $deadline
		$contentDefault2 =  DefaultDLangContentEn2 $relUrl
		
		$result +=  $crlf+ $crlf + $contentDefault1 + $crlf+ $crlf
		$result +=  $crlf+ $crlf + $contentDefault2 + $crlf+ $crlf		

	}
	else
	{
		$contentDefault1 =  DefaultDLangContentHe1 $deadline
		$contentDefault2 =  DefaultContentHe2 $relUrl

		$result +=  $crlf+ $crlf + $contentDefault1 + $crlf+ $crlf
		$result +=  $crlf+ $crlf + $contentDefault2 + $crlf+ $crlf		
		

	}
	return $result
}
function create-DocLib($SiteName, $ListName, $DisplayName=""){
	$siteNameN = get-UrlNoF5 $SiteName
    $Context = New-Object Microsoft.SharePoint.Client.ClientContext($siteNameN) 
    $Context.Credentials = $Credentials
	$LibExists = $true
	if ([string]::IsNullOrEmpty($DisplayName)){
		$LibExists = Check-ListExists $siteNameN  $ListName
	}
	else
	{	
		$LibExists = Check-ListExists $siteNameN  $DisplayName
	}
    if (!$LibExists){
		$ListInfo = New-Object Microsoft.SharePoint.Client.ListCreationInformation
		$ListInfo.Title = $ListName
		$ListInfo.TemplateType = 101 #Document Library
		$List = $Context.Web.Lists.Add($ListInfo)
		 
		#Set "New Experience" as list property
		#$List.ListExperienceOptions = "NewExperience" #Or ClassicExperience
		if (![string]::IsNullOrEmpty($DisplayName)){
			$List.Title = $DisplayName
		}
		$List.OnQuickLaunch = $false;
		$List.Update()
		$Context.ExecuteQuery()

		
	}
	<#
	$Web = $Ctx.web
	$FolderURL = "/"+$ListName
	$Folder = $Web.GetFolderByServerRelativeUrl($FolderURL)
	
    $Ctx.Load($Folder)
    $Ctx.ExecuteQuery()
     
    #Break Permission inheritence of the folder - Keep all existing folder permissions & keep Item level permissions
    $Folder.ListItemAllFields.BreakRoleInheritance($False,$True)
    $Ctx.ExecuteQuery()
    Write-host -f Yellow "Folder's Permission inheritance broken..."
	
    #Get the SharePoint Group & User
    $Group =$Web.SiteGroups.GetByName($GroupName)
    $User = $Web.EnsureUser($UserAccount)
    $Ctx.load($Group)
    $Ctx.load($User)
    $Ctx.ExecuteQuery()
 
    #sharepoint online powershell set permissions on folder
    #Get the role required
    $Role = $web.RoleDefinitions.GetByName($PermissionLevel)
    $RoleDB = New-Object Microsoft.SharePoint.Client.RoleDefinitionBindingCollection($Ctx)
    $RoleDB.Add($Role)
          
    #add sharepoint online group to folder using powershell
    $GroupPermissions = $Folder.ListItemAllFields.RoleAssignments.Add($Group,$RoleDB)
 
    #powershell add user to sharepoint online folder
    $UserPermissions = $Folder.ListItemAllFields.RoleAssignments.Add($User,$RoleDB)
    $Folder.Update()
    $Ctx.ExecuteQuery()
     
    Write-host "Permission Granted Successfully!" -ForegroundColor Green
    #>

	#Read more: https://www.sharepointdiary.com/2016/09/sharepoint-online-set-folder-permissions-powershell.html#ixzz75IjhppEC	
  
	return $null
}
#function get-FolderRelUrl($RelURL){
#	$lastEl = $RelURL.split("/")[-1]
#	$rlUrl = $RelURL.Replace("/"+$lastEl,"")
#	return $rlUrl
#}
function get-ListPermissions($siteURL, $RelURL){
	$siteName = get-UrlNoF5 $SiteURL
	
	#$rlUrl = get-FolderRelUrl $RelURL
	write-host "Collect ListPermissions: $relUrl" -foregroundcolor Green
	
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
	$ctx.Credentials = $Credentials
	
 	$Web = $Ctx.Web
	$ctx.Load($Web)
	$Ctx.ExecuteQuery()
	
	
	#$ListRel = $Ctx.Web.GetFolderByServerRelativeUrl($rlUrl)
	$List = $Web.GetList($relUrl)
	$Ctx.Load($List)
	$Ctx.ExecuteQuery()

	$RoleAssignments = $List.RoleAssignments
	$Ctx.Load($RoleAssignments)
	$Ctx.ExecuteQuery()

	#Loop through each permission assigned and extract details
	$PermissionCollection = @()
	
	$roleCount = $RoleAssignments.count
	write-host "Permissions role Count: $roleCount" -f Magenta
	$countDown = $roleCount
	#read-host
	if ($roleCount -lt 2000){
		Foreach($RoleAssignment in $RoleAssignments)
		{
			$Ctx.Load($RoleAssignment.Member)
			$Ctx.executeQuery()

			#Get the User Type
			$PermissionType = $RoleAssignment.Member.PrincipalType
			#write-host "751:" -f Magenta
			#Get the Permission Levels assigned
			$Ctx.Load($RoleAssignment.RoleDefinitionBindings)
			$Ctx.ExecuteQuery()
			$PermissionLevels = ($RoleAssignment.RoleDefinitionBindings | Select -ExpandProperty Name) -join ","
			 
			#Get the User/Group Name
			$Name = $RoleAssignment.Member.Title # $RoleAssignment.Member.LoginName
			#write-host "759:" -f Magenta
			#Add the Data to Object
			$Permissions = New-Object PSObject
			$Permissions | Add-Member NoteProperty Name($Name)
			$Permissions | Add-Member NoteProperty Type($PermissionType)
			$Permissions | Add-Member NoteProperty PermissionLevels($PermissionLevels)
			if (!$($Permissions.PermissionLevels -eq "Limited Access")){
				$PermissionCollection += $Permissions
			}
			$countDown--
			$sCountDown = $countDown.ToString().PadLeft(3," ")
			write-host "`r$sCountDown" -f Magenta -NoNewLine
		}
	}
	
	#write-host "768:" -f Magenta
	write-host 
	Return $PermissionCollection

}
function Collect-Navigation($siteURL,$isMenuOld){
	$siteName = get-UrlNoF5 $SiteURL
	write-host "Collect Navigation: $siteURL" -foregroundcolor Green
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
	$ctx.Credentials = $Credentials
 	
	$Web = $Ctx.Web
	$ctx.Load($Web)
	$Ctx.ExecuteQuery()
	
	$menuDump = @()
	
	$QuickLaunch = $Ctx.Web.Navigation.QuickLaunch
	
	$Ctx.load($QuickLaunch)
	$Ctx.ExecuteQuery()
 	
    foreach($QuickLaunchLink in $QuickLaunch){	
	    $menuItem =  "" | Select Title, Url, Items, IsOldMenu ,CandidateForDelete
		$Ctx.Load($QuickLaunchLink)
		$Ctx.Load($QuickLaunchLink.Children)
		$Ctx.ExecuteQuery()
		$menuItem.Title = $QuickLaunchLink.Title
		$menuItem.Url = $QuickLaunchLink.Url
		$menuItem.IsOldMenu = $isMenuOld
		$menuItem.CandidateForDelete = $false
		
		$docLibNameHe = "העלאת מסמכים"
		$docLibNameEn = "Documents Upload"
		if (($QuickLaunchLink.Title.Contains($docLibNameHe)) -or 
			($QuickLaunchLink.Title.Contains($docLibNameEn))){
			continue
		}
				
		#write-host $QuickLaunchLink.Url
		#write-host $QuickLaunchLink.Title

		$child = $QuickLaunchLink.Children
		$items = @() 
		foreach($childItem in $child) {
			$Ctx.Load($childItem)
			
			$Ctx.ExecuteQuery()
			$submenu = "" | Select Title, Url, OldUrl, Type, InnerName, Name,  IsOldMenu, CandidateForDelete, ListSchema, ListPermissons 
			$submenu.Title = $childItem.Title
			$submenu.Url = $childItem.Url
			$submenu.Type = getMenuItemType $submenu.Url 
			$submenu.InnerName = getMenuItemInnerName $submenu.Url $submenu.Type
			$submenu.Name = getListOrDocName $SiteURL $submenu.Url $submenu.Type
			
			if ($submenu.Type -eq "Lists" -or $submenu.Type -eq "DocLib"){
				#write-Host "762: $siteName $($submenu.Name)"
				#read-host
				$subMenu.ListSchema = get-ListSchema $siteName $submenu.Name
				#$subMenu.ListPermissons = @()
				$subMenu.ListPermissons = get-ListPermissions $siteName $submenu.URL 
			}
			
			
			
			$submenu.IsOldMenu = $isMenuOld
			$submenu.CandidateForDelete = $false
			$items += $submenu
			#$childItem | gm
			#$childItem 
		}
		$menuItem.Items = $items
		$menuDump += $menuItem
		
		#read-host
	}
	
	return $menuDump
	
	
}
function getListOrDocName ($SiteURL, $url, $itemType){
	$retValue = $null
	if ($itemType -eq "Lists" -or $itemType -eq "DocLib"){
		
		$siteName = get-UrlNoF5 $SiteURL
		#write-host "Get List  Or Doc Name : $siteURL" -foregroundcolor Green
		#write-host "Get List  Or Doc Name : $url" -foregroundcolor Green
		$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
		$ctx.Credentials = $Credentials
		
		$Web = $Ctx.Web
		$ctx.Load($Web)
		$Ctx.ExecuteQuery()
		$list = $Web.GetList($url);
		$ctx.Load($list)
		$Ctx.ExecuteQuery()
		#Error - error 
		#get real name list name
		$retValue +=  $list.Title 		
	}
	return $retValue
}
function Compare-Navig($menuSrc, $menuDst, $oldSuffix , $newSuffix){
	$menuW = @()
	#copy to buffer array
	foreach($menuD in $menuDst){
		$menuW += $menuD
	}	

	
	foreach($menuD in $menuDst){
		#write-host $menuD.Title -f Cyan

		$itemExists = $true
		foreach($menuS in $menuSrc){
			$menuItemS =  "" | Select Title, Url, OldUrl, Items, IsOldMenu , CandidateForDelete
			$menuItemS.Title = $menuS.Title
			$menuItemS.OldUrl = $menuS.Url		
			$menuItemS.Url = $menuS.Url.Replace($oldSuffix , $newSuffix)			
			$menuItemS.IsOldMenu = $false			
			
            $mItems = @()
			foreach($item in $menuS.Items)
            {
				$newItem = "" | Select Title, Url, OldUrl, Type, InnerName, Name,  IsOldMenu, CandidateForDelete, ListSchema, ListPermissons 
				$newItem.Title = $item.Title
				$newItem.OldUrl = $item.Url
				$newItem.Url = $item.Url.Replace($oldSuffix , $newSuffix)
				$newItem.Type = $item.Type
				$newItem.InnerName = $item.InnerName
				$newItem.Name = $item.Name
				$newItem.ListSchema = $item.ListSchema
				$newItem.ListPermissons = $item.ListPermissons
				$newItem.IsOldMenu = $false
				$newItem.CandidateForDelete = $false
				$mItems += $newItem
				
				
            }	
			$menuItemS.Items = $mItems			
			$menuItemS.CandidateForDelete = $false			
			if (!(menuMainItemExists $menuW $menuS)){
				#write-host $menuItemS.Title -f Yellow
				$itemExists = $false
				break
			}				
		}
		if (!$itemExists){
			#write-host "Item Menu Not Exists: $($menuItemS.Title)" -f Yellow
			#write-host $menuItemS -f Yellow
			$menuW += $menuItemS	
			
		}

	}	
	
	#$outfile = ".\JSON\"+ $groupName+"-MenuDmp-W.json"	
	#$menuW | ConvertTo-Json -Depth 100 | out-file $outfile -Encoding Default
    #write-host "menuw"	
	#read-host

	return $menuW
}
function Check-SubNavOldItems($menuSrc, $menuDst, $oldSuffix , $newSuffix){
	
	$menuW = @()
	#copy to buffer array
	foreach($menuD in $menuDst){
		$menuW += $menuD
	}


	foreach($menuD in $menuW){
		$titleMenuD = $menuD.Title
		$itemsD   = $menuD.Items
		
		foreach($menuS in $menuSrc){
			$titleMenuS = $menuS.Title
			
			if ($titleMenuD -eq $titleMenuS){
				#write-host "SubNav: $titleMenuD" -f Cyan
				$itemsS = $menuS.Items
				break
			}
		}
		$menuArr = @()
		foreach($itemS in $itemsS){
			$itemMenuExists = $false
			$itemSTitl = $itemS.Title
			foreach($itemD in $itemsD){
				$itemDTitl = $itemD.Title
				if ($itemDTitl -eq $itemSTitl){
					$itemMenuExists = $true
					break
				}
				 
				
			}
			
			if (!$itemMenuExists){
				$newItem = "" | Select Title, Url, OldUrl, Type, InnerName, Name,  IsOldMenu, CandidateForDelete, ListSchema, ListPermissons 
				
				$newItem.Title = $itemS.Title
				$newItem.OldUrl = $itemS.Url
				$newItem.Url = $itemS.Url.Replace($oldSuffix , $newSuffix)
				$newItem.Type = $itemS.Type
				$newItem.InnerName = $itemS.InnerName
				$newItem.Name = $itemS.Name
				$newItem.ListSchema = $itemS.ListSchema
				$newItem.ListPermissons = $itemS.ListPermissons
				$newItem.IsOldMenu = $false
				$newItem.CandidateForDelete = $false
				$menuArr += $newItem
								
				#write-host "SubNavItem: $itemSTitl" -f Green
			}
			else
			{
				$newItem = "" | Select Title, Url, OldUrl, Type, InnerName, Name,  IsOldMenu, CandidateForDelete, ListSchema, ListPermissons 
				
				$newItem.Title = $itemD.Title
				$newItem.OldUrl = $itemD.OldUrl
				$newItem.Url = $itemD.Url
				$newItem.Type = $itemD.Type
				$newItem.InnerName = $itemD.InnerName
				$newItem.Name = $itemD.Name
				$newItem.ListSchema = $itemD.ListSchema
				$newItem.ListPermissons = $itemD.ListPermissons
				$newItem.IsOldMenu =  $itemD.IsOldMenu
				$newItem.CandidateForDelete = $false
				$menuArr += $newItem
				
			}
		}
		$menuD.Items = $menuArr
		
	}
	return $menuW	
	
}
function Create-MainMenu($siteUrl, $menu){
	$siteName = get-UrlNoF5 $SiteURL
	write-host "Create Main Navigation: $siteURL" -foregroundcolor Green
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
	$ctx.Credentials = $Credentials
 	
	$Web = $Ctx.Web
	$ctx.Load($Web)
	$Ctx.ExecuteQuery()
	
	
	$QuickLaunch = $Ctx.Web.Navigation.QuickLaunch
	
	$Ctx.load($QuickLaunch)
	$Ctx.ExecuteQuery()
 	
	
	foreach($item in $menu){
		if (!$item.IsOldMenu){
			#new item. Create new
			write-host $("MenuItem Title:" + $item.Title) -f Cyan
			write-host $("MenuItem URL  :" + $item.Url) -f Cyan
			
			#Add link to Quick Launch Navigation
			$NavigationNode = New-Object Microsoft.SharePoint.Client.NavigationNodeCreationInformation
			$NavigationNode.Title = $item.Title
			$NavigationNode.Url = $item.Url
			$NavigationNode.AsLastNode = $True
			$Ctx.Load($QuickLaunch.Add($NavigationNode))
			$Ctx.ExecuteQuery()

		}
	}
}
function change-AllListFieldAndViews($menu,$groupName,$spObj, $oldSiteURL, $siteUrl){
	$siteName = get-UrlNoF5 $SiteURL
	write-host "change-AllListFieldAndViews DocLib: $siteURL" -foregroundcolor Green
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
	$ctx.Credentials = $Credentials
 	
	$Web = $Ctx.Web
	$ctx.Load($Web)
	$Ctx.ExecuteQuery()
		
	$docLibNames =  @()	
	foreach($item in $menu){
		foreach($subMenuItem in $item.Items)
		{
			if ($subMenuItem.Type -eq "DocLib"){
				write-host $("DocLibNames :" + $subMenuItem.Title) -f Cyan
				if (!(($subMenuItem.InnerName -eq "Submitted") -or 
					($subMenuItem.InnerName -eq "Final"))){
						$list = $Web.GetList($subMenuItem.Url);
						$ctx.Load($list)
						$Ctx.ExecuteQuery()
					    #Error - error 
						#get real name list name
						$docLibNames +=  $list.Title 
					}
			}
		}
	}	
	write-host "959: Press any key..."
	
   	foreach($docLibName in $docLibNames){
		write-Host $docLibName -f Cyan
	}
	
	write-host "965: Press any key..."
	#read-host
	
	foreach($docLibName in $docLibNames){
	
		$schemaDocLibSrc1 =  get-ListSchema $oldSiteURL $docLibName
		
		#$schemaDocLib1 | ConvertTo-Json -Depth 100 | out-file $("JSON\"+$groupName+"-DocLib1.json")
		$sourceDocObj = get-SchemaObject $schemaDocLibSrc1 
		$sourceDocObj | ConvertTo-Json -Depth 100 | out-file $("JSON\"+$groupName+"-Doc"+$docLibName+".json")
		create-DocLib $siteUrl $docLibName
		
		# ======================= new DocLib
		$schemaDocLibDst1 =  get-ListSchema $siteUrl $docLibName
		$dstDocObj = get-SchemaObject $schemaDocLibDst1 
		$dstDocObj | ConvertTo-Json -Depth 100 | out-file $("JSON\"+$groupName+"-DocLibDst1.json")
			
		foreach($srcEl in $sourceDocObj){
				$fieldExists = $false
				foreach($dstEl in $dstDocObj){
					if ($srcEl.Name -eq $dstEl.Name){
						write-Host "$($dstEl.Name) Exists in Destination List" -foregroundcolor Yellow
						$fieldExists = $true
						break
					}
					
				}
				if (!$fieldExists){
					write-Host "Add $($srcEl.DisplayName) to Destination List" -foregroundcolor Green
					$type= $srcEl.Type
					switch ($type)
					{
						"Text" {
							Write-Host "It is Text.";
							add-TextFields $siteUrl $docLibName $srcEl;
							Break
							}
						
						"Choice" {
							Write-Host "It is Choice.";
							add-ChoiceFields $siteUrl $docLibName $srcEl;
							Break
							}
							
						"Note" {
							Write-Host  "It is Note.";
							add-NoteFields $siteUrl $docLibName $srcEl;
							Break}
							
						"Boolean" {
							Write-Host  "It is Boolean.";
							add-BooleanFields $siteUrl $docLibName $srcEl;
							Break}
							
						"DateTime" {
							Write-Host  "It is DateTime.";
							add-DateTimeFields $siteUrl $docLibName $srcEl;
							Break}
							
						Default {
							Write-Host "No matches"
								}
					}					
				}
							
			}
			$SrcFieldsOrder = get-FormFieldsOrder $docLibName $oldSiteURL
			
			$DestFieldOrder    = get-FormFieldsOrder $docLibName $siteURL
			
			#check for Field in Destination exist in Source
			$newFieldOrder = checkForArrElExists $SrcFieldsOrder $DestFieldOrder
			reorder-FormFields $docLibName	$siteURL $newFieldOrder
			
			$objViews = Get-AllViews $docLibName $oldSiteURL
	 
			$objViews | ConvertTo-Json -Depth 100 | out-file $("JSON\"+$docLibName+"-Views.json")
			
			foreach($view in $objViews){
				$viewExists = Check-ViewExists $docLibName  $siteURL $view 
				if ($viewExists.Exists){
					write-host "view $($view.Title) exists on $newSite" -foregroundcolor Green
					#check if first field in source view is on destination view
					$firstField = $view.Fields[0]
					write-host "First field in source view : $firstField"
					$fieldInView = check-FieldInView  $docLibName $($viewExists.Title) $siteURL $firstField
					write-host "$firstField on View : $fieldInView"
					#if not {add this field}
					if (!$fieldInView){
						Add-FieldInView $docLibName $($viewExists.Title) $siteURL $firstField
						
					}
					#delete all fields in destination from view but first field in source
					 
					remove-AllFieldsFromViewButOne $docLibName $($viewExists.Title) $siteURL $firstField
					Add-FieldsToView $docLibName $($viewExists.Title) $siteURL $($view.Fields)
					#add other view
					Rename-View $docLibName $($viewExists.Title) $siteURL $($view.Title) $($view.ViewQuery)
				}
				else
				{
					
					$viewName = $($view.Title)
					if ([string]::isNullOrEmpty($viewName)){
						$viewName = $($view.ServerRelativeUrl.Split("/")[-1]).Replace(".aspx","")
						
					}
					write-host "view $viewName does Not exists on $newSite" -foregroundcolor Yellow
					write-host "ViewQuery : $($view.ViewQuery)"
					write-host "Check for View! "
					
					$viewDefault = $false
					Create-NewView $siteURL $docLibName $viewName  $($view.Fields) $($view.ViewQuery) $($view.Aggregations) $viewDefault
				}
			}
						
			


	}		
}
function change-ApplicantsFieldAndViews($groupName,$spObj, $oldSiteURL, $siteUrl){
	
	$applSchmSrc = get-ApplicantsSchema $oldSiteURL
	$applSchmDst = get-ApplicantsSchema $siteUrl
	$schemaDifference = get-SchemaDifference $applSchmSrc $applSchmDst
	$newSite = $siteUrl
	$oldSite = $oldSiteURL
		
	$xmlFiles = @()
	$xmlFiles    +=  $spObj.PathXML + "\" +  $spObj.XMLFile
	$xmlFiles    +=  $spObj.PathXML + "\" +  $spObj.XMLFileEn
	$xmlFiles    +=  $spObj.PathXML + "\" +  $spObj.XMLFileHe

	foreach($xmlFormPath in $xmlFiles){
		if ($(Test-Path $xmlFormPath)){
			
			write-Host $xmlFormPath -f Magenta
			$schemaDifference = get-SchemaDifference $applSchmSrc $applSchmDst 

			$listObj = Map-LookupFields $schemaDifference $oldSiteURL $xmlFormPath
			$listObj | ConvertTo-Json -Depth 100 | out-file $(".\JSON\"+$groupName+"-ApplFields.json")

			foreach($listName in $($listObj.LookupForm)){
				Clone-List   $siteUrl $oldSiteURL $listName
			}
			
			foreach($listName in $($listObj.LookupLists)){
				Clone-List   $siteUrl $oldSiteURL $listName
			}
		
					
			foreach($fieldObj in  $($listObj.FieldMap)){
				if ($fieldObj.Type -eq "Lookup"){
					#write-host $fieldObj.FieldObj.DisplayName
					add-LookupFields $siteUrl "Applicants" $($fieldObj.FieldObj) $($fieldObj.LookupTitle)
				}
			}
			
			foreach($fieldObj in  $($listObj.FieldMap)){
				if ($fieldObj.Type -eq "Choice"){
					#write-host $fieldObj.FieldObj.DisplayName
					add-ChoiceFields $siteUrl "Applicants" $($fieldObj.FieldObj) 
				}
			}

			foreach($fieldObj in  $($listObj.FieldMap)){
				if ($fieldObj.Type -eq "DateTime"){
					#write-host $fieldObj.FieldObj.DisplayName
					add-DateTimeFields $siteUrl "Applicants" $($fieldObj.FieldObj) 
				}
			}

			foreach($fieldObj in  $($listObj.FieldMap)){
				if ($fieldObj.Type -eq "Note"){
					#write-host $fieldObj.FieldObj.DisplayName
					add-NoteFields $siteUrl "Applicants" $($fieldObj.FieldObj) 
				}
			}

			foreach($fieldObj in  $($listObj.FieldMap)){
				if ($fieldObj.Type -eq "Text"){
					#write-host $fieldObj.FieldObj.DisplayName
					add-TextFields $siteUrl "Applicants" $($fieldObj.FieldObj) 
				}
			}
			
			foreach($fieldObj in  $($listObj.FieldMap)){
				if ($fieldObj.Type -eq "Boolean"){
					#write-host $fieldObj.FieldObj.DisplayName
					add-BooleanFields $siteUrl "Applicants" $($fieldObj.FieldObj) 
				}
			}

			#write-host "1016: Press any key..."
			#read-host
			
		}
	}
	
	$applSrcFieldsOrder = get-FormFieldsOrder "Applicants" $oldSiteURL
	
	$applDestFieldOrder    = get-FormFieldsOrder "Applicants" $siteURL
	
	#check for Field in Destination exist in Source
	$newFieldOrder = checkForArrElExists $applSrcFieldsOrder $applDestFieldOrder
	reorder-FormFields "Applicants"	$siteURL $newFieldOrder	

	
	$listName = "Applicants"
	$objViews = Get-AllViews $listName $oldSite
	 
	$objViews | ConvertTo-Json -Depth 100 | out-file $(".\JSON\Applicants-Views.json")
	#write-host "Pause..."
	#read-host 
	foreach($view in $objViews){
		$viewExists = Check-ViewExists $listName  $newSite $view 
		if ($viewExists.Exists){
			write-host "view $($view.Title) exists on $newSite" -foregroundcolor Green
			#check if first field in source view is on destination view
			$firstField = $view.Fields[0]
			write-host "First field in source view : $firstField"
			$fieldInView = check-FieldInView  $listName $($viewExists.Title) $newSite $firstField
			write-host "$firstField on View : $fieldInView"
			#if not {add this field}
			if (!$fieldInView){
				Add-FieldInView $listName $($viewExists.Title) $newSite $firstField
				
			}
			#delete all fields in destination from view but first field in source
			 
			remove-AllFieldsFromViewButOne $listName $($viewExists.Title) $newSite $firstField
			Add-FieldsToView $listName $($viewExists.Title) $newSite $($view.Fields)
			#add other view
			Rename-View $listName $($viewExists.Title) $newSite $($view.Title) $($view.ViewQuery)
		}
		else
		{
			
			$viewName = $($view.Title)
			if ([string]::isNullOrEmpty($viewName)){
				$viewName = $($view.ServerRelativeUrl.Split("/")[-1]).Replace(".aspx","")
				
			}
			write-host "view $viewName does Not exists on $newSite" -foregroundcolor Yellow
			write-host "ViewQuery : $($view.ViewQuery)"
			write-host "Check for View! "
			
			$viewDefault = $false
			Create-NewView $newSite $listName $viewName  $($view.Fields) $($view.ViewQuery) $($view.Aggregations) $viewDefault
		}
	}	
}
function Create-NavSubMenu($menu, $SiteURLNew){
	$siteName = get-UrlNoF5 $SiteURLNew
	write-host "Create Nav SubMenu: $siteURL" -foregroundcolor Green
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
	$ctx.Credentials = $Credentials
 	
	
	#Get the Quick Launch Navigation of the web
	$Navigation = $Ctx.Web.Navigation.QuickLaunch
	$Ctx.load($Navigation)
	$Ctx.ExecuteQuery()
	 


	foreach($item in $menu){
		foreach($subMenuItem in $item.Items)
		{
			if (!$subMenuItem.IsOldMenu){
				
				#Get the Parent Node
				$ParentNode = $Navigation | Where-Object {$_.Title -eq $item.Title}
				If($ParentNode -eq $null)
				{
					write-host write-host $("Menu Item Does Not Exist:" + $item.Title) -f Magenta
				}
				else
				{
					write-host $("Menu Item:" + $item.Title) -f Yellow
					write-host $("Create SubMenuItem Name:" + $subMenuItem.Title) -f Cyan
					write-host $("Create SubMenuItem Url :" + $subMenuItem.Url) -f Cyan
					write-host 					
				}
 



					
			}
		}
	}	
		
	return $menu
}
function Create-NavDocLibs($menu,  $oldSiteURL, $SiteURLNew){
	foreach($item in $menu){
		foreach($subMenuItem in $item.Items)
		{
			if (!$subMenuItem.IsOldMenu){
				if ($subMenuItem.Type -eq "DocLib"){
					write-host $("Create New DocLib:" + $subMenuItem.Title) -f Cyan
					
					create-DocLib $SiteURLNew $subMenuItem.InnerName $subMenuItem.Name
	
				}
				elseif ($subMenuItem.Type -eq "Lists")
				{
					create-ListfromOld   $SiteURLNew $oldSiteURL $subMenuItem.Title
				}
			}
		}
	}
	return $menu	
}
function Get-DocLibCollectionsRealNames($menu, $SiteURLOld, $SiteURLNew){
	$siteName = get-UrlNoF5 $SiteURLOld
	write-host "Populate DocLib: $siteURL" -foregroundcolor Green
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
	$ctx.Credentials = $Credentials
 	
	$Web = $Ctx.Web
	$ctx.Load($Web)
	$Ctx.ExecuteQuery()
	
	foreach($item in $menu){
		foreach($subMenuItem in $item.Items)
		{
			if (!$subMenuItem.IsOldMenu){
				if ($subMenuItem.Type -eq "DocLib"){
					if ([string]::IsNullOrEmpty($subMenuItem.Name)){
						write-host $("Strange, but we are here") -f Magenta
						write-host $("SubMenuItem Title:" + $subMenuItem.Title) -f Cyan
						write-host $("SubMenuItem URL  :" + $subMenuItem.OldUrl) -f Cyan
						$list = $Web.GetList($subMenuItem.OldUrl);
						$ctx.Load($list)
						$Ctx.ExecuteQuery()
						$subMenuItem.Name = $list.Title
						$subMenuItem.ListSchema = get-ListSchema $siteName $list.Title
						write-host $("Name   :" + $subMenuItem.InnerName) -f Cyan
						write-host $("Title  :" + $subMenuItem.Name) -f Cyan
						write-host $("Site  :" + $SiteURLNew) -f Cyan
					}
					
					
					

				}
			}
		}
	}
	return $menu
	
		
}
function menuMainItemExists( $outMenu, $menuS){
	$itemExists = $false
	foreach($mItm in $outMenu){
		if ($mItm.Title -eq $menuS.Title){
			$itemExists = $true
			break
		}
	}
	return $itemExists
}
function getMenuItemType($url){
	$aItems = $url.split("/")
	$retValue = ""
	if ($aItems.Count -ge 5){
		$retValue = $aItems[4]
		if (!(($retValue -eq "Lists") -or
			($retValue -eq "Pages"))){
			if (($aItems[-2] -eq "Forms") -and	
				($aItems[-1].contains(".aspx"))){
				$retValue = "DocLib"	
			} 
		}
	}
	return $retValue
}
function getMenuItemInnerName($url,$itemType){
	$aItems = $url.split("/")
	$retValue = ""
	if ($aItems.Count -ge 5){
		$retValue = $aItems[4]
		if ($itemType -eq "Pages"){
			$retValue = $aItems[-1]
		}
		if ($itemType -eq "Lists"){
			$retValue = $aItems[-2]
		}		
	}
	return $retValue
}
function Upload-SwitchFiles($siteName, $groupName){
	$cpath = "TemplInf\" + $groupName + "\Switch\*.txt" 
	$items = get-ChildItem $cpath | Select FullName
	foreach($item in $items){
		#write-host "Upload file $($item.FullName)" -f Yellow
		Upload-File $siteName "SwitchModule" $($item.FullName)
		#write-host "Done" -f Green
		#read-host
	}
	return $null
}
function Upload-File($siteName,$libName,$filePath){
	$siteNameN = get-UrlNoF5 $SiteName
    $Context = New-Object Microsoft.SharePoint.Client.ClientContext($siteNameN) 
    $Context.Credentials = $Credentials

	#Get the Library
	$Library =  $Context.Web.Lists.GetByTitle($libName)
	 
	#Get the file from disk
	$FileStream = ([System.IO.FileInfo] (Get-Item $filePath)).OpenRead()
	#Get File Name from source file path
	$SourceFileName = Split-path $filePath -leaf
	   
	#sharepoint online upload file powershell
	$FileCreationInfo = New-Object Microsoft.SharePoint.Client.FileCreationInformation
	$FileCreationInfo.Overwrite = $true
	$FileCreationInfo.ContentStream = $FileStream
	$FileCreationInfo.URL = $SourceFileName
	$FileUploaded = $Library.RootFolder.Files.Add($FileCreationInfo)
	  
	#powershell upload single file to sharepoint online
	$Context.Load($FileUploaded)
	$Context.ExecuteQuery()
	 
	#Close file stream
	$FileStream.Close()

		
}
Function Check-ListExists($SiteName, $ListName)
{
	$siteNameN = get-UrlNoF5 $SiteName
    #Setup the context
    $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteNameN)
    $Ctx.Credentials = $Credentials
 
    Try {
            $List = $Ctx.Web.Lists.GetByTitle($ListName)
            $Ctx.Load($List)
            $Ctx.ExecuteQuery()
            Return $True
        }
    Catch [Exception] {
      # Write-host $_.Exception.Message -f Red
      Return $False
     }
}

function Get-PageContent($SiteName, $pageName){
	$PageContent = ""
	$siteNameN = get-UrlNoF5 $SiteName
	$siteNameNew = get-SiteNameFromNote $siteNameN
	$relUrl = get-RelURL $siteNameNew

	$relUrl   = get-RelURL $siteName
	
	$pageURL  = $relUrl + "Pages/"+ $pageName + ".aspx"
	
	write-host "Page URL: $pageURL"
	write-host "Site Name: $siteNameNew"
	write-host "Page: $pageURL"
	
	
	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteNameNew)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials

	$page = $ctx.Web.GetFileByServerRelativeUrl($pageURL);
	$ctx.Load($page);
    $ctx.Load($page.ListItemAllFields);
    $ctx.ExecuteQuery();


	$page.CheckOut()
	$pageFields = $page.ListItemAllFields

	$PageContent = $pageFields["PublishingPageContent"]
	
	$page.UndoCheckOut()
	
	$ctx.ExecuteQuery()	
		
	write-host "Get Content of: $pageName" -foregroundcolor Yellow
	
	
	return $PageContent
}

function SubmissionStatusDLangContentEn1($relURL){
	$outStr = '<h1>​Document Status</h1><p><span class="ms-rteFontSize-2">Recommendation letters will be updated&#160;up to </span><strong class="ms-rteFontSize-2">two hours </strong><span class="ms-rteFontSize-2">after confirmation of arrival on the&#160;</span><a href="'+$relURL+'Pages/Recommendations.aspx"><span class="ms-rteFontSize-2" style="text-decoration-line: underline;"><font color="#0066cc">Recomme​​ndations</font></span></a><span class="ms-rteFontSize-2"> page.​</span></p>'
	return $outStr
}
function SubmissionStatusDLangContentEn2(){
	$outStr = '<div>
   <div>
      <h1>Submission</h1>
      <font class="ms-rteThemeFontFace-1 ms-rteFontSize-2"><span class="ms-rteThemeFontFace-1 ms-rteFontSize-2">You can press &#39;Submit&#39;, </span>
         <span class="ms-rteThemeFontFace-1 ms-rteFontSize-2">once you have carried out all the obligations according to the administrative guidelines.</span></font><span class="ms-rteThemeFontFace-1 ms-rteFontSize-2"> </span></div>
   <div>
      <span class="ms-rteThemeFontFace-1 ms-rteFontSize-2">
         
         <span class="ms-rteThemeFontFace-1 ms-rteFontSize-2">After&#160;the deadline,&#160;all the material in your &quot;Documents Upload&quot; folder will be read only.</span></span></div>
</div>'
	return $outStr
}
function SubmissionStatusDLangContentHe1($relURL){
		$outStr = '<div dir="rtl" style="text-align:right;"><h1 >סטטוס מסמכים</h1>
	
<div style="color: #000000; font-size: medium;"> 
   <font class="ms-rteFontSize-2">
      <font size="3">&#160;<span class="ms-rteFontSize-2"><font size="3">מכתבי המלצה יתעדכנו </font></span><font size="3"> 
            <strong class="ms-rteFontSize-2">כשעתיים</strong>
			<span class="ms-rteFontSize-2"> לאחר אישור קבלה בדף </span>
	  </font>
    </font> 
    <a href="'+$relURL+'Pages/RecommendationsHe.aspx"> 
         <span class="ms-rteFontSize-2" lang="HE" dir="rtl" style="text-decoration-line: underline;">
            <font color="#0066cc" size="3"> 
               <span style="text-decoration: underline;">הה​מלצות</span>
			</font>
		</span>
	  </a>
	  <span class="ms-rteFontSize-2">
		<font size="3">.
		</font>
	  </span>
	</font>
</div></div>'	
	return $outStr
}
function SubmissionStatusDLangContentHe2($relURL){
		$outStr = '<div dir="rtl" style="text-align:right;">
   <h1>
      <span aria-hidden="true"></span><span aria-hidden="true"></span><span aria-hidden="true"></span>הגשה</h1>
   <div class="ms-rteFontSize-2">בתום ביצוע כל חובות הבקשה בהתאם להנחיות המנהליות, תוכל/י ללחוץ &#39;הגשה&#39;. </div>
   <div class="ms-rteFontSize-2">
      <span lang="HE" dir="rtl">המידע שימצא בתיק המועמד/ת במועד הסגירה יהיה זמין לקריאה בלבד.<span aria-hidden="true"></span><span aria-hidden="true"></span></span></div>
</div>'
	return $outStr
}


function RecommendationsDLangContentEn1(){
	$outStr  ="<div>" 
    $outStr +=   "<h1>Recommendations</h1>"
	$outStr +=   '<div style="background: white;margin: 0cm 0cm 0pt;vertical-align: top;">' 
    $outStr +=   '<span class="ms-rteFontSize-2 ms-rteThemeFontFace-1">Please ask your referees to send their recommendation letters to the e-mail address appearing below.</span>'
	$outStr +='</div>'
	$outStr +='<div>' 
    $outStr +=   '<span class="ms-rteFontSize-2 ms-rteThemeFontFace-1">Letters arrive directly to the applicant' +"’" +'s folder automatically, a few moments after being sent.</span>'
	$outStr +='</div>'
	$outStr +='<div style="background:white;margin:0cm 0cm 0pt;vertical-align:top;">'
    $outStr +=	'<span class="ms-rteFontSize-2 ms-rteThemeFontFace-1">Please make sure your referees follow these guidelines:</span>'
	$outStr +='</div>'
	$outStr +=	'<ul>'
	$outStr +=		'<li>'
	$outStr +=			'<p><span class="ms-rteFontSize-2">Sending the letter as an attachment (all text in the email body will not be received by the system)</span></p>'
	$outStr +=		'</li>'
	$outStr +=	'</ul>'
	$outStr +=	'<ul>'
	$outStr +=		'<li>'
	$outStr +=			'<p><span class="ms-rteFontSize-2">The file size should not be larger than 5MB.</span></p>'
	$outStr +=		'</li>'
	$outStr +=	'</ul>'
	$outStr +=	'<ul>'
	$outStr +=		'<li>'
	$outStr +=			'<p><span class="ms-rteFontSize-2">The file name should not contain any special characters such as (“ ;).</span></p>'
	$outStr +=		'</li>'
	$outStr +=	'</ul>'
	$outStr +=	'<div style="background:white;margin:0cm 0cm 0pt;vertical-align:top;">' 
    $outStr +=		'<span class="ms-rteFontSize-2 ms-rteThemeFontFace-1">Your referee will receive confirmation within 24 hours.</span>'
	$outStr +=	'</div>'
	$outStr +=	'<div style="background:white;margin:0cm 0cm 0pt;vertical-align:top;">' 
    $outStr +=		'<span class="ms-rteFontSize-2 ms-rteThemeFontFace-1">Please inform the referees that <strong>you will not</strong> have access to these letters.</span>'
	$outStr +=	'</div>'
	$outStr +=	'<div style="background:white;margin:0cm 0cm 0pt;vertical-align:top;">' 
    $outStr +=		'<strong class="ms-rteFontSize-2"><br />Please ensure that the letters arrive before the deadline.</strong>'
	$outStr +=	'</div>'
	$outStr +=	'<h2>E-mail address for referees:​​​​​​</h2>'
	$outStr +='</div>'

	return $outStr
}
function RecommendationsDLangContentEn2(){
	$outStr = '<h2>Received recommendations:​</h2>​​​'
	return $outStr
}
function RecommendationsDLangContentHe1(){
	$outStr  = '<h1 dir="rtl" style="text-align:right;">המלצות</h1><div dir="rtl" style="text-align:right;">'
	$outStr += '<span class="ms-rteFontSize-2 ms-rteThemeFontFace-1">' 
    $outStr += '<span lang="HE">אנא בקשו מהממליצים שלכם לשלוח את מכתביהם לכתובת הדוא&quot;ל המופיעה מטה.</span><br>מכתבי המלצה מתקבלים אוטומטית במערכת ישירות לתיק המועמד/ת מספר דקות לאחר השליחה.</span></div>'
	$outStr += '<div dir="rtl" style="background:white;margin:0cm 0cm 0pt;text-align:right;vertical-align:top;unicode-bidi:embed;">'
    $outStr += '<span class="ms-rteFontSize-2 ms-rteThemeFontFace-1">' 
    $outStr += '<span lang="HE">אנא וודאו שהממליצים עוקבים אחר ההוראות הבאות:</span></span></div><ul dir="rtl" style="text-align:right;"><li><p>'
    $outStr += '<span class="ms-rteFontSize-2">' 
    $outStr += '<span lang="HE">שליחת מכתב ההמלצה כצרופה – </span>attachment' 
    $outStr += '<span lang="HE">(כל טקסט בגוף המייל לא ייקלט במערכת).</span></span></p></li><li><p>'
    $outStr += '<span class="ms-rteFontSize-2">' 
    $outStr += '<span lang="HE">גודל הקובץ לא יעלה על </span>          5MB<span lang="HE">.</span></span></p></li><li><p>'
    $outStr += '<span class="ms-rteFontSize-2">'
    $outStr += '<span lang="HE">על שם הקובץ לא להכיל תווים מיוחדים כגון&#160; (&quot; ;)</span></span></p></li></ul><div dir="rtl" style="background:white;margin:0cm 0cm 0pt;text-align:right;vertical-align:top;unicode-bidi:embed;">'
	$outStr += '<span class="ms-rteFontSize-2 ms-rteThemeFontFace-1" lang="HE">הממליץ יקבל אישור על שליחת המכתב תוך 24 שעות.</span></div><div dir="rtl" style="background:white;margin:0cm 0cm 0pt;text-align:right;vertical-align:top;unicode-bidi:embed;direction:rtl;"><div>'
    $outStr += '<span class="ms-rteFontSize-2 ms-rteThemeFontFace-1" lang="HE"></span>          </div><div style="margin:0cm 0cm 0pt;vertical-align:top;unicode-bidi:embed;">'
    $outStr += '<span class="ms-rteFontSize-2 ms-rteThemeFontFace-1"><span lang="HE">אנא הדגישו בפני הממליץ '
    $outStr += '<strong>שאין לכם גישה</strong> למכתב ההמלצה.</span></span></div></div><div dir="rtl" style="background:white;margin:0cm 0cm 0pt;text-align:right;vertical-align:top;unicode-bidi:embed;">'
    $outStr += '<strong class="ms-rteFontSize-2 ms-rteThemeFontFace-1">' 
    $outStr += '<span lang="HE">' 
    $outStr += '<br>באחריותכם לוודא שמכתבי ההמלצה הגיעו לפני מועד סגירת הרישום.​​<br></span></strong></div><div dir="rtl" style="background:white;margin:0cm 0cm 0pt;text-align:right;vertical-align:top;unicode-bidi:embed;">'
    $outStr += '<strong class="ms-rteFontSize-2 ms-rteThemeFontFace-1">' 
    $outStr += '<span lang="HE"></span></strong>&#160;</div><h2 dir="rtl" style="background:white;margin:0cm 0cm 0pt;text-align:right;vertical-align:top;unicode-bidi:embed;direction:rtl;">'
    $outStr += '<span lang="HE">​כתובת דוא&quot;ל למשלוח המלצות:</span></h2>'

	return $outStr
}

function RecommendationsDLangContentHe2(){
	$outStr = '<h2 dir="rtl" style="text-align:right;">
   <span lang="HE">המלצות שהתקבלו:</span></h2>'

	return $outStr
}

function DefaultDLangContentEn1($deadLineText){
	$outStr = '<div><h2 style="text-align:center;"><span class="ms-rteThemeForeColor-9-5 ms-rteFontSize-4"> 
      <strong>Submission deadline: '+ $deadLineText + '</strong></span></h2></div>'
	return $outStr	
}

function DefaultDLangContentEn2($relURL){
	$outStr  = '<h2>Application process</h2>'

	$outStr += '<ol start="1" style="text-align: justify; list-style-type: decimal;">'
   	$outStr += '<li>'
    $outStr += 	'<span class="ms-rteFontSize-2">Complete the </span>'
    $outStr += 		'<a href="' +$relURL + 'Pages/Form.aspx">'
	$outStr += 		'<span class="ms-rteFontSize-2" dir="ltr" style="text-decoration: underline;">' 
    $outStr += 		'<strong>online application form</strong></span>'
	$outStr += 		'</a>'
	$outStr += 	'</li>'
    $outStr += 	'<li>' 
    $outStr += 		'<span class="ms-rteFontSize-2">Upload all the following documents,</span><strong class="ms-rteFontSize-2"> in English </strong>' 
    $outStr += 		'<span class="ms-rteFontSize-2">to your personal documents folder according to </span>'
    $outStr += 		'<a href="/home/Pages/InstructionsEn.aspx" target="_blank">' 
    $outStr += 		'<span class="ms-rteFontSize-2" dir="ltr" style="text-decoration: underline;">' 
    $outStr += 		'<strong>these guidelines :</strong>'
	$outStr += 		'</span></a>'
	$outStr += 	'</li>'
	$outStr += 	'<ul style="list-style-type: disc;">'
    $outStr += 		'<li>' 
    $outStr +=      	'<span class="ms-rteFontSize-2">'
    $outStr +=      	'<strong>CV</strong> – First page should include the following personal information: First and last name, ID number (teudat zehut), Date of birth, Place of birth, Aliyah year, address, mobile phone number, Faculty, Department, Research topic, Name of PhD instructor</span>'
	$outStr +=      '</li>'
    $outStr +=      '<li>' 
    $outStr +=      	'<span class="ms-rteFontSize-2">'
    $outStr +=      	'<strong>List of Publications</strong> (including Impact Factor &amp; Impact Rank) , include also  attended conferences  and list of prizes and awards</span>'
	$outStr +=      '</li>'
    $outStr +=      '<li>' 
    $outStr +=      	'<span class="ms-rteFontSize-2">'
	$outStr += 		    '<strong>Grade transcripts</strong> (Higher education only, in English)&#160;</span>'
	$outStr += 		'</li>'
    $outStr +=      '<li>'
    $outStr +=      	'<span class="ms-rteFontSize-2">Cover letter which includes, among other things, details on social involvement (up to 2 pages)</span>'
	$outStr +=      '</li>'
    $outStr +=      '<li>' 
    $outStr +=      	'<span class="ms-rteFontSize-2"><strong>Research summary</strong> (1-2 pages)</span>'
	$outStr +=     	'</li>'
    $outStr += 	'</ul>'
	$outStr += 	'<li>' 
    $outStr += 		'<span class="ms-rteFontSize-2"><strong>Two letters of recommendation</strong>, one from present PhD supervisor (in the case of two PhD supervisors three letters should be provided) - should be uploaded according to </span>'
	$outStr += 		'<a href="' + $relURL + 'Pages/Recommendations.aspx">' 
    $outStr += 		'<span class="ms-rteFontSize-2" dir="ltr" style="text-decoration: underline;">' 
    $outStr += 		'<strong>these guidelines </strong></span></a>'
	$outStr += 	'</li>'
	$outStr += 	'<li>' 
    $outStr +=	 	'<span class="ms-rteFontSize-2">To complete the submission process go to the </span>'
	$outStr +=	 	'<a href="' + $relURL + 'Pages/SubmissionStatus.aspx">' 
    $outStr +=	 		'<span class="ms-rteFontSize-2" dir="ltr" style="text-decoration: underline;">' 
	$outStr +=		 	'<strong>Submission Status page and follow the guidelines</strong></span>'
	$outStr +=	 	'</a>'
	$outStr +=	 '</li>'
	$outStr +=	 '</ol>'
	$outStr +=	 '<p style="text-align: justify;">&#160;</p>'
	$outStr +=	 '<p style="text-align: justify;">' 
	$outStr +=	 '<strong class="ms-rteFontSize-2">Please make sure to complete the above instructions entirely and precisely -</strong></p>'
	$outStr +=	 '<p style="text-align: justify;">' 
	$outStr +=	 '<strong class="ms-rteFontSize-2">Files including incomplete forms or missing required documents will not be reviewed<span dir="ltr" style="text-decoration: underline;">&#160;</span></strong></p>'
	
	
	

	return $outStr	
}

function DefaultDLangContentHe1($deadLineText){
	$msg = " תאריך אחרון להגשת "  
	$outStr = '<div dir="rtl" style="text-align: center; text-decoration: underline;">' 
	$outStr += '<strong class="ms-rteFontSize-3 ms-rteForeColor-1" style="text-decoration: underline;">'
	$outStr += $msg + $deadLineText +"</strong></div>"
 
	return $outStr	
}

function DefaultDLangContentHe2($relURL){
	 $outStr  = '<h2 dir="rtl" style="text-align:right;">הליך הגשת בקשה</h2>'
  $outStr += '<p dir="rtl" style="text-align:right;">'
  $outStr += '<strong class="ms-rteFontSize-2">א. יש למלא את </strong>'
  $outStr += '<a href="' + $relURL + 'Pages/FormHe.aspx">'
  $outStr += '<span class="ms-rteFontSize-2" lang="HE" style="text-decoration:underline;">'
  $outStr += '<strong>טופס הבקשה המקוון</strong></span></a>'
  $outStr += '</p>'
  $outStr += '<p dir="rtl" style="text-align:right;">'
  $outStr += '<strong class="ms-rteFontSize-2">ב. להעלות את המסמכים הבאים לתיקיית העלאת מסמכים אישית לפי </strong>'
  $outStr += '<a href="/home/Pages/InstructionsHe.aspx" target="_blank">'
  $outStr += '<span class="ms-rteFontSize-2" lang="HE" style="text-decoration:underline;"><strong>ההוראות המופיעות כאן</strong></span>'
  $outStr += '</a>'
  $outStr += '</p>'
  $outStr += '<p dir="rtl" style="text-align:right;">&#160;</p>'
  $outStr += '<ul dir="rtl" style="text-align:right;">'
  $outStr += 	'<li>'
  $outStr += 	'<p><span class="ms-rteFontSize-2"><span class="ms-rteFontSize-2"><span aria-hidden="true"></span>קורות חיים ופרטים אישיים (על הפרטים האישיים לכלול: שם + משפחה, ת.ז, ת. לידה, מקום לידה, שנת עליה, כתובת מגורים, טלפון נייד, כותבת דוא&quot;ל, מצב משפחתי, פקולטה, מחלקה, נושא המחקר, שם המנחה)</span></span>'
  $outStr += 	'</p>'
  $outStr += 	'</li>'
  $outStr += 	'<li>'
  $outStr += 	'<p><span class="ms-rteFontSize-2"><span class="ms-rteFontSize-2"><span class="ms-rteFontSize-2">רשימת פרסומים (כולל הופעה בכנסים), רשימת פרסי הצטיינות</span></span></span>'
  $outStr += 	'</p>'
  $outStr += 	'</li>'
  $outStr += 	'<li>'
  $outStr += 	'<p><span class="ms-rteFontSize-2">גיליונות ציונים באנגלית מכל שנות הלימודים הגבוהים<br>מכתב פניה של המועמדת, הכולל בין היתר פרטים על עשייה חברתית (עד שני עמודים)<br>תקציר תכנית המחקר (עד שני עמודים)</span>'
  $outStr += 	'</p>'
  $outStr += 	'</li>'
  $outStr += 	'</ul>'
  $outStr += 	'<p dir="rtl" style="text-align:right;">'
  $outStr += 	'<strong class="ms-rteFontSize-2">ג. . שתי ההמלצות ישלחו לפי </strong>'
  $outStr += 	'<a href="' + $relURL + 'Pages/RecommendationsHe.aspx">'
  $outStr += 	'<span class="ms-rteFontSize-2" lang="HE" style="text-decoration:underline;">'
  $outStr += 	'<strong>המנגנון המתואר כאן</strong></span>'
  $outStr += 	'</a>'
  $outStr += 	'.&#160;<span class="ms-rteFontSize-2"> במידה ולמועמדת יש שני מנחים, יש לצרף שלוש המלצות - ההמלצות יישלחו לפי המנגנון המתואר כאן.</span></p>'
  $outStr += 	'<p dir="rtl" style="text-align:right;">'
  $outStr += 	'<strong class="ms-rteFontSize-2">'
  $outStr += 	"ד. לסיום התהליך יש לגשת לדף '</strong>"
  $outStr += 	'<a href="' + $relURL + 'Pages/SubmissionStatusHe.aspx">'
  $outStr += 	'<span class="ms-rteFontSize-2" lang="HE" style="text-decoration:underline;"><strong>סטטוס הגשה</strong></span>'
  $outStr += 	'</a>'
  $outStr += 	'<strong class="ms-rteFontSize-2">'
  $outStr += 	"' ולפעול לפי ההנחיות</strong>"
  $outStr += 	'</p>'
  
  $outStr += 	'<p style="text-align:right;">'
  $outStr += 	'&#160;&#160;&#160;</p><br>'
	return $outStr	
}

function DefaultContentHe2($relURL){
	 $outStr  = '<h2 dir="rtl" style="text-align:right;">הליך הגשת בקשה</h2>'
  $outStr += '<p dir="rtl" style="text-align:right;">'
  $outStr += '<strong class="ms-rteFontSize-2">א. יש למלא את </strong>'
  $outStr += '<a href="' + $relURL + 'Pages/Form.aspx">'
  $outStr += '<span class="ms-rteFontSize-2" lang="HE" style="text-decoration:underline;">'
  $outStr += '<strong>טופס הבקשה המקוון</strong></span></a>'
  $outStr += '</p>'
  $outStr += '<p dir="rtl" style="text-align:right;">'
  $outStr += '<strong class="ms-rteFontSize-2">ב. להעלות את המסמכים הבאים לתיקיית העלאת מסמכים אישית לפי </strong>'
  $outStr += '<a href="/home/Pages/InstructionsHe.aspx" target="_blank">'
  $outStr += '<span class="ms-rteFontSize-2" lang="HE" style="text-decoration:underline;"><strong>ההוראות המופיעות כאן</strong></span>'
  $outStr += '</a>'
  $outStr += '</p>'
  $outStr += '<p dir="rtl" style="text-align:right;">&#160;</p>'
  $outStr += '<ul dir="rtl" style="text-align:right;">'
  $outStr += 	'<li>'
  $outStr += 	'<p><span class="ms-rteFontSize-2"><span class="ms-rteFontSize-2"><span aria-hidden="true"></span>קורות חיים ופרטים אישיים (על הפרטים האישיים לכלול: שם + משפחה, ת.ז, ת. לידה, מקום לידה, שנת עליה, כתובת מגורים, טלפון נייד, כותבת דוא&quot;ל, מצב משפחתי, פקולטה, מחלקה, נושא המחקר, שם המנחה)</span></span>'
  $outStr += 	'</p>'
  $outStr += 	'</li>'
  $outStr += 	'<li>'
  $outStr += 	'<p><span class="ms-rteFontSize-2"><span class="ms-rteFontSize-2"><span class="ms-rteFontSize-2">רשימת פרסומים (כולל הופעה בכנסים), רשימת פרסי הצטיינות</span></span></span>'
  $outStr += 	'</p>'
  $outStr += 	'</li>'
  $outStr += 	'<li>'
  $outStr += 	'<p><span class="ms-rteFontSize-2">גיליונות ציונים באנגלית מכל שנות הלימודים הגבוהים<br>מכתב פניה של המועמדת, הכולל בין היתר פרטים על עשייה חברתית (עד שני עמודים)<br>תקציר תכנית המחקר (עד שני עמודים)</span>'
  $outStr += 	'</p>'
  $outStr += 	'</li>'
  $outStr += 	'</ul>'
  $outStr += 	'<p dir="rtl" style="text-align:right;">'
  $outStr += 	'<strong class="ms-rteFontSize-2">ג. . שתי ההמלצות ישלחו לפי </strong>'
  $outStr += 	'<a href="' + $relURL + 'Pages/Recommendations.aspx">'
  $outStr += 	'<span class="ms-rteFontSize-2" lang="HE" style="text-decoration:underline;">'
  $outStr += 	'<strong>המנגנון המתואר כאן</strong></span>'
  $outStr += 	'</a>'
  $outStr += 	'.&#160;<span class="ms-rteFontSize-2"> במידה ולמועמדת יש שני מנחים, יש לצרף שלוש המלצות - ההמלצות יישלחו לפי המנגנון המתואר כאן.</span></p>'
  $outStr += 	'<p dir="rtl" style="text-align:right;">'
  $outStr += 	'<strong class="ms-rteFontSize-2">'
  $outStr += 	"ד. לסיום התהליך יש לגשת לדף '</strong>"
  $outStr += 	'<a href="' + $relURL + 'Pages/SubmissionStatus.aspx">'
  $outStr += 	'<span class="ms-rteFontSize-2" lang="HE" style="text-decoration:underline;"><strong>סטטוס הגשה</strong></span>'
  $outStr += 	'</a>'
  $outStr += 	'<strong class="ms-rteFontSize-2">'
  $outStr += 	"' ולפעול לפי ההנחיות</strong>"
  $outStr += 	'</p>'
  
  $outStr += 	'<p style="text-align:right;">'
  $outStr += 	'&#160;&#160;&#160;</p><br>'
	return $outStr	
}

function DefaultHeStyle(){
	return '<style unselectable="on">body ' + $([char][int]35) +"contentBox {direction:rtl;}</style>"
}


function edt-SubmissionWP2Lang($siteUrlC , $spObj){
	$pageName = "Pages/SubmissionStatus.aspx"
	#$pageName = "ekcc/QA/AsherSpace/Pages/SubmissionStatus.aspx"


	$pageNameHe = "Pages/SubmissionStatusHe.aspx"
	#$pageNameHe = "ekcc/QA/AsherSpace/Pages/SubmissionStatusHe.aspx"
	
	$siteName = get-UrlNoF5 $siteUrlC
	#write-host "Change WP On $pageName on Site: $siteName" -foregroundcolor Yellow
	
	$relUrl   = get-RelURL $siteName
	
	$pageURL  = $relUrl + $pageName
	$pageURLHe  = $relUrl + $pageNameHe
	
	
	$wpName = "SubmissionButton WP"
	$lang = 1	
    
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials


    #write-host $pageURL
	$page = $ctx.Web.GetFileByServerRelativeUrl($pageURL);
		
	$webpartManager = $page.GetLimitedWebPartManager([Microsoft.Sharepoint.Client.WebParts.PersonalizationScope]::Shared);	
	
	Write-Host 'Updating webpart '+$wpName+' on the page ' + $pageName -ForegroundColor Green
	
	$page.CheckOut()	
	
	$WebParts = $webpartManager.WebParts
	#read-host
	$ctx.Load($webpartManager);
	$ctx.Load($WebParts);
	$ctx.ExecuteQuery();
	foreach($wp in $webparts){
			
			$ctx.Load($wp.WebPart.Properties)
			$ctx.Load($wp.WebPart)
			$ctx.Load($wp)
			$ctx.ExecuteQuery() 
			if ($wp.WebPart.Title -eq $wpName){
				#$wp.WebPart.Properties.FieldValues				
				$wp.WebPart.Properties["WP_Language"] = $lang
				$wp.WebPart.Properties["EmailTemplatePath"] = $spObj.MailPath
				$wp.WebPart.Properties["EmailTemplateName"] = $spObj.MailFileEn;
				
				$wp.SaveWebPartChanges();				
			}		
	}
	$page.CheckIn("Change '"+$wpName+"'", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
	$page.Publish("Change '"+$wpName+"'")
	$ctx.ExecuteQuery()

    #========================= Hebrew =================================
	$CtxHe = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	#$CtxHe.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$CtxHe.Credentials = $Credentials


    #write-host $pageURLHe
	$pageHe = $ctxHe.Web.GetFileByServerRelativeUrl($pageURLHe);
		
	$webpartManagerHe = $pageHe.GetLimitedWebPartManager([Microsoft.Sharepoint.Client.WebParts.PersonalizationScope]::Shared);	
	
	Write-Host 'Updating webpart "'+$wpName+'" on the page ' + $pageNameHe -ForegroundColor Green
	
	$pageHe.CheckOut()	
	
	$WebPartsHe = $webpartManagerHe.WebParts
	#read-host
	$ctxHe.Load($webpartManagerHe);
	$ctxHe.Load($WebPartsHe);
	$ctxHe.ExecuteQuery();
	foreach($wpHe in $WebPartsHe){
			
			$ctxHe.Load($wpHe.WebPart.Properties)
			$ctxHe.Load($wpHe.WebPart)
			$ctxHe.Load($wpHe)
			$ctxHe.ExecuteQuery() 
			if ($wpHe.WebPart.Title -eq $wpName){
				#$wpHe.WebPart.Properties.FieldValues				
				
				$wpHe.WebPart.Properties["EmailTemplatePath"] = $spObj.MailPath
				$wpHe.WebPart.Properties["EmailTemplateName"] = $spObj.MailFileHe;
				
				$wpHe.WebPart.Properties["SuccessMsgEn"] = $wpHe.WebPart.Properties["SuccessMsgHe"]
				$wpHe.WebPart.Properties["FailedMsgEn"] = $wpHe.WebPart.Properties["FailedMsgHe"]
				$wpHe.WebPart.Properties["NoSubmitMsgEn"] = $wpHe.WebPart.Properties["NoSubmitMsgHe"]
				$wpHe.WebPart.Properties["BtnTextEn"] = $wpHe.WebPart.Properties["BtnTextHe"]
				$wpHe.WebPart.Properties["EmailSubjectEn"] = $wpHe.WebPart.Properties["EmailSubjectHe"]
				<#
				SuccessMsgEn = SuccessMsgHe
				FailedMsgEn= FailedMsgHe
				NoSubmitMsgEn = NoSubmitMsgHe
				BtnTextEn = BtnTextHe
				EmailSubjectEn = EmailSubjectHe
				#>
				
				$wpHe.SaveWebPartChanges();				
			}		
	}
	$pageHe.CheckIn("Change '"+$wpName+"'", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
	$pageHe.Publish("Change '"+$wpName+"'")
	$ctxHe.ExecuteQuery()	
	
	return $null	

}
function edt-Form2LangWP($siteUrlC , $spObj){
	
	####################   ENGLISH #####################
	$pageName = "Pages/Form.aspx"
	
	$siteName = get-UrlNoF5 $siteUrlC
	write-host "Change WP On $pageName on Site: $siteName" -foregroundcolor Yellow
	
	$relUrl   = get-RelURL $siteName
	
	$pageURL  = $relUrl + $pageName
	
	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	$Ctx.Credentials = $Credentials

	$page = $ctx.Web.GetFileByServerRelativeUrl($pageURL);
	
	$webpartManager = $page.GetLimitedWebPartManager([Microsoft.Sharepoint.Client.WebParts.PersonalizationScope]::Shared);	
	
	Write-Host 'Updating webpart "Dynamic Form - v 2.0"  from the page Form.aspx' -ForegroundColor Green
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
			if ($wp.WebPart.Title -eq "Dynamic Form - v 2.0"){
				$wp.WebPart.Properties["filePath"] = $spObj.PathXML
				$wp.WebPart.Properties["fileName"] = $spObj.XMLFileEn
				
				$wp.WebPart.Properties["addColumns"] = $true;
				$wp.WebPart.Properties["addLists"] = $true;
				
				$textAlign = 1  # English
				$textDirection = 1
				
				$wp.WebPart.Properties["textAlign"] = $textAlign;
				$wp.WebPart.Properties["textDirection"] = $textDirection;
				$wp.SaveWebPartChanges();				
			}		
	}
	$page.CheckIn("Change 'Dynamic Form - v 2.0'", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
	$page.Publish("Change 'Dynamic Form - v 2.0'")
	$ctx.ExecuteQuery()

	####################   HEBREW #####################
	$pageName = "Pages/FormHe.aspx"
	
	# $siteName = get-UrlNoF5 $siteUrlC
	write-host "Change WP On $pageName on Site: $siteName" -foregroundcolor Yellow
	
	# $relUrl   = get-RelURL $siteName
	
	$pageURL  = $relUrl + $pageName

	
		
	#$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	#$Ctx.Credentials = $Credentials

	$page = $ctx.Web.GetFileByServerRelativeUrl($pageURL);
	
	$webpartManager = $page.GetLimitedWebPartManager([Microsoft.Sharepoint.Client.WebParts.PersonalizationScope]::Shared);	
	
	Write-Host 'Updating webpart "Dynamic Form - v 2.0"  from the page Form.aspx' -ForegroundColor Green
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
			if ($wp.WebPart.Title -eq "Dynamic Form - v 2.0"){
				$wp.WebPart.Properties["filePath"] = $spObj.PathXML
				$wp.WebPart.Properties["fileName"] = $spObj.XMLFileHe
				
				$wp.WebPart.Properties["addColumns"] = $true;
				$wp.WebPart.Properties["addLists"] = $true;
				$textAlign = 0 # Hebrew
				$textDirection = 0
				
				$wp.WebPart.Properties["textAlign"] = $textAlign;
				$wp.WebPart.Properties["textDirection"] = $textDirection;
				$wp.SaveWebPartChanges();				
			}		
	}
	$page.CheckIn("Change 'Dynamic Form - v 2.0'", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
	$page.Publish("Change 'Dynamic Form - v 2.0'")
	$ctx.ExecuteQuery()
		
}
function edt-Form2Lang($newSiteName){
	$pageName = "Pages/Form.aspx"
	
	$siteName = get-UrlNoF5 $newSiteName
	
	$relUrl   = get-RelURL $siteName
	
	$pageURL  = $relUrl + $pageName
	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials

	$page = $ctx.Web.GetFileByServerRelativeUrl($pageURL);
	
	$ctx.Load($page);
    $ctx.Load($page.ListItemAllFields);
    $ctx.ExecuteQuery();
	
	$page.CheckOut()
	
	$pageFields = $page.ListItemAllFields
	$pageTitle = "Application Form"
	$pageFields["Title"] = $pageTitle
	$pageFields.Update()
	
	$ctx.Load($pageFields)
	$ctx.ExecuteQuery();
	
	$page.CheckIn("",1)
	
	$ctx.ExecuteQuery()	
	write-host "$pageName Was Updated" -foregroundcolor Green
	
}
function edt-Default2Lang($newSiteName, $groupName){
	$CurrPage = "Default"
	$pageName = "Pages/"+$CurrPage + ".aspx"
	
	# Get Content for Saves Files
	$editContentPathEn  = $(Get-CPath $groupName)+"\"+$CurrPage+"\editEn.txt"
	$editContentPathHe  = $(Get-CPath $groupName)+"\"+$CurrPage+"\editHe.txt"
	$contentEn = Get-Content $editContentPathEn -encoding Default -Raw
	$contentHe = Get-Content $editContentPathHe -encoding Default -Raw
	
	# Connect to site
	$siteName = get-UrlNoF5 $newSiteName
	$relUrl   = get-RelURL $siteName
	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	$Ctx.Credentials = $Credentials
	
	################   ENGLISH  PAGE ################	
	$pageURL  = $relUrl + $pageName
	$page = $ctx.Web.GetFileByServerRelativeUrl($pageURL);
	
	$ctx.Load($page);
    $ctx.Load($page.ListItemAllFields);
    $ctx.ExecuteQuery();
	
	$page.CheckOut()
	
	$pageFields = $page.ListItemAllFields
	
	$pageFields["PublishingPageContent"] = $contentEn	
	$pageFields.Update()
	
	$ctx.Load($pageFields)
	$ctx.ExecuteQuery();
	
	$page.CheckIn("",1)
	
	$ctx.ExecuteQuery()	
	write-host "$pageName Was Updated" -foregroundcolor Green

	################   HEBREW ################
	
	$pageName = "Pages/"+$CurrPage + "He.aspx"
	$pageURL  = $relUrl + $pageName
	$page = $ctx.Web.GetFileByServerRelativeUrl($pageURL);
	
	$ctx.Load($page);
    $ctx.Load($page.ListItemAllFields);
    $ctx.ExecuteQuery();
	
	$page.CheckOut()
	
	$pageFields = $page.ListItemAllFields
	$pageFields["PublishingPageContent"] = $contentHe
	$pageFields.Update()
	
	$ctx.Load($pageFields)
	$ctx.ExecuteQuery();
	
	$page.CheckIn("",1)
	
	$ctx.ExecuteQuery()	
	write-host "$pageName Was Updated" -foregroundcolor Green
   	
		
}
function edt-SubmissionStatus2Lang($newSiteName, $groupName){
	$CurrPage = "SubmissionStatus"
	$pageName = "Pages/"+$CurrPage + ".aspx"
	
	# Get Content for Saves Files
	$editContentPathEn  = $(Get-CPath $groupName)+"\"+$CurrPage+"\editEn.txt"
	$editContentPathHe  = $(Get-CPath $groupName)+"\"+$CurrPage+"\editHe.txt"
	$contentEn = Get-Content $editContentPathEn -encoding Default -Raw
	$contentHe = Get-Content $editContentPathHe -encoding Default -Raw
	
	# Connect to site
	$siteName = get-UrlNoF5 $newSiteName
	$relUrl   = get-RelURL $siteName
	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	$Ctx.Credentials = $Credentials
	
	################   ENGLISH  PAGE ################	
	$pageURL  = $relUrl + $pageName
	$page = $ctx.Web.GetFileByServerRelativeUrl($pageURL);
	
	$ctx.Load($page);
    $ctx.Load($page.ListItemAllFields);
    $ctx.ExecuteQuery();
	
	$page.CheckOut()
	
	$pageFields = $page.ListItemAllFields
	$pageTitle = "Submission Status"
	$pageFields["Title"] = $pageTitle
	$pageFields["PublishingPageContent"] = $contentEn	
	$pageFields.Update()
	
	$ctx.Load($pageFields)
	$ctx.ExecuteQuery();
	
	$page.CheckIn("",1)
	
	$ctx.ExecuteQuery()	
	write-host "$pageName Was Updated" -foregroundcolor Green

	################   HEBREW ################
	
	$pageName = "Pages/"+$CurrPage + "He.aspx"
	$pageURL  = $relUrl + $pageName
	$page = $ctx.Web.GetFileByServerRelativeUrl($pageURL);
	
	$ctx.Load($page);
    $ctx.Load($page.ListItemAllFields);
    $ctx.ExecuteQuery();
	
	$page.CheckOut()
	
	$pageFields = $page.ListItemAllFields
	$pageFields["PublishingPageContent"] = $contentHe
	$pageFields.Update()
	
	$ctx.Load($pageFields)
	$ctx.ExecuteQuery();
	
	$page.CheckIn("",1)
	
	$ctx.ExecuteQuery()	
	write-host "$pageName Was Updated" -foregroundcolor Green
   	
		
}
function edt-Recommendations2Lang($newSiteName, $groupName){
	$CurrPage = "Recommendations"
	$pageName = "Pages/"+$CurrPage + ".aspx"
	
	# Get Content for Saves Files
	$editContentPathEn  = $(Get-CPath $groupName)+"\"+$CurrPage+"\editEn.txt"
	$editContentPathHe  = $(Get-CPath $groupName)+"\"+$CurrPage+"\editHe.txt"
	$contentEn = Get-Content $editContentPathEn -encoding Default -Raw
	$contentHe = Get-Content $editContentPathHe -encoding Default -Raw
	
	# Connect to site
	$siteName = get-UrlNoF5 $newSiteName
	$relUrl   = get-RelURL $siteName
	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	$Ctx.Credentials = $Credentials
	
	################   ENGLISH  PAGE ################	
	$pageURL  = $relUrl + $pageName
	$page = $ctx.Web.GetFileByServerRelativeUrl($pageURL);
	
	$ctx.Load($page);
    $ctx.Load($page.ListItemAllFields);
    $ctx.ExecuteQuery();
	
	$page.CheckOut()
	
	$pageFields = $page.ListItemAllFields
	# $pageTitle = "Submission Status"
	# $pageFields["Title"] = $pageTitle
	$pageFields["PublishingPageContent"] = $contentEn	
	$pageFields.Update()
	
	$ctx.Load($pageFields)
	$ctx.ExecuteQuery();
	
	$page.CheckIn("",1)
	
	$ctx.ExecuteQuery()	
	write-host "$pageName Was Updated" -foregroundcolor Green

	################   HEBREW ################
	
	$pageName = "Pages/"+$CurrPage + "He.aspx"
	$pageURL  = $relUrl + $pageName
	$page = $ctx.Web.GetFileByServerRelativeUrl($pageURL);
	
	$ctx.Load($page);
    $ctx.Load($page.ListItemAllFields);
    $ctx.ExecuteQuery();
	
	$page.CheckOut()
	
	$pageFields = $page.ListItemAllFields
	$pageFields["PublishingPageContent"] = $contentHe
	$pageFields.Update()
	
	$ctx.Load($pageFields)
	$ctx.ExecuteQuery();
	
	$page.CheckIn("",1)
	
	$ctx.ExecuteQuery()	
	write-host "$pageName Was Updated" -foregroundcolor Green
   	
		
}

function edt-cancelCandidacy2Lang($newSiteName, $groupName){
	$CurrPage = "CancelCandidacy"
	$pageName = "Pages/"+$CurrPage + ".aspx"
	
	# Get Content for Saves Files
	$editContentPathEn  = $(Get-CPath $groupName)+"\"+$CurrPage+"\editEn.txt"
	$editContentPathHe  = $(Get-CPath $groupName)+"\"+$CurrPage+"\editHe.txt"
	$contentEn = Get-Content $editContentPathEn -encoding Default -Raw
	$contentHe = Get-Content $editContentPathHe -encoding Default -Raw
	
	# Connect to site
	$siteName = get-UrlNoF5 $newSiteName
	
	$relUrl   = get-RelURL $siteName
	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	$Ctx.Credentials = $Credentials

	################   ENGLISH  PAGE ################

 	$pageURL  = $relUrl + $pageName
	$page = $ctx.Web.GetFileByServerRelativeUrl($pageURL);
	
	$ctx.Load($page);
    $ctx.Load($page.ListItemAllFields);
    $ctx.ExecuteQuery();
	
	$page.CheckOut()
	

	
	$pageFields = $page.ListItemAllFields
   
	$pageTitle = "Cancel Candidacy"
	$pageFields["Title"] = $pageTitle
	$pageFields["PublishingPageContent"] = $contentEn
	$pageFields.Update()
	
	$ctx.Load($pageFields)
	$ctx.ExecuteQuery();
	
	$page.CheckIn("",1)
	
	$ctx.ExecuteQuery()	
	write-host "$pageName Was Updated" -foregroundcolor Green
	
	
	################   HEBREW ################
	
	$pageName = "Pages/"+$CurrPage + "He.aspx"
	$pageURL  = $relUrl + $pageName
	$page = $ctx.Web.GetFileByServerRelativeUrl($pageURL);
	
	$ctx.Load($page);
    $ctx.Load($page.ListItemAllFields);
    $ctx.ExecuteQuery();
	
	$page.CheckOut()
		
	$pageFields = $page.ListItemAllFields
   	$pageFields["PublishingPageContent"] = $contentHe
	$pageFields.Update()
	
	$ctx.Load($pageFields)
	$ctx.ExecuteQuery();
	
	$page.CheckIn("",1)
	
	$ctx.ExecuteQuery()	
	write-host "$pageName Was Updated" -foregroundcolor Green
	
}
function create-Empty2LangForms( $spObj){
	$fileNameEn = $spObj.PathXML + "\" + $spObj.XMLFileEn
	$fileNameHe = $spObj.PathXML + "\" + $spObj.XMLFileHe
	
    if (Test-Path $fileNameEn){
		
	}
	else
	{
		$contentEn = get-EmptyXMLFormContEn $fileNameEn
		$contentEn | Out-File $fileNameEn -encoding Default
		Write-Host "File $fileNameEn was created." -foregroundcolor Green
	}

    if (Test-Path $fileNameHe){
		
	}
	else
	{
		$contentHe = get-EmptyXMLFormContHe $fileNameHe
		$contentHe | Out-File $fileNameHe -encoding Default
		Write-Host "File $fileNameHe was created." -foregroundcolor Green
	}	
	return $null
}

function get-EmptyXMLFormContEn($filePath){
	$crlf = [char][int]13 + [char][int]10

 	$content = '<?xml version="1.0" encoding="utf-8"?>'+$crlf
	$content += '<rows>'+$crlf
	$content += '	<config>'+$crlf
	$content += '		<fileName>applicationForm</fileName>'+$crlf
	$content += '		<docHeader>Application Form</docHeader>'+$crlf
	$content += '		<finalMessage>The information was saved successfully</finalMessage>'+$crlf
	$content += '		<missingDataMessage>All marked fields must be filled properly</missingDataMessage>'+$crlf
	$content += '		<registrationMessage>You are not registered for this scholarship. <![CDATA[<a href="http://scholarships2.ekmd.huji.ac.il/home">Register here</a>]]></registrationMessage>'+$crlf
	$content += '		<docTypeList>docType</docTypeList>'+$crlf
	$content += '		<docTypeColumn>Document Type</docTypeColumn>'+$crlf
	$content += '		<docType>0. Application Form</docType>'+$crlf
	$content += '	</config>'+$crlf+$crlf

	$content += '	<row>'+$crlf
	$content += '		<Header>This is Auto genereted Empty Form:</Header>'+$crlf
	$content += '	</row>'+$crlf
	$content += '	<row>'+$crlf
	$content += '		<Label>'+$crlf
	$content += '		</Label>'+$crlf
	$content += '	</row>'+$crlf+$crlf	
	$content += '	<row>'+$crlf
	$content += '		<Header>File is: ' +$filePath+'</Header>'+$crlf
	$content += '	</row>'+$crlf+$crlf
	$content += '	<row>'+$crlf
	$content += '		<Label></Label>'+$crlf
	$content += '	</row>'+$crlf+$crlf

	$content += '	<row>'+$crlf
	$content += '		<Button>Save</Button>'+$crlf
	$content += '	</row>'+$crlf+$crlf

	$content += '	<row>'+$crlf
	$content += '		<Label></Label>'+$crlf
	$content += '	</row>'+$crlf+$crlf

	$content += '	<row>'+$crlf
	$content += '		<control>'+$crlf
	$content += '			<Type>finalMessage</Type>'+$crlf
	$content += '			<Data>MyCustomLabel</Data>'+$crlf
	$content += '			<width>500</width>'+$crlf
	$content += '			<Text></Text>'+$crlf
	$content += '		</control>'+$crlf
	$content += '	</row>'+$crlf+$crlf
	$content += '</rows>'+$crlf
	
	return $content
}

function get-EmptyXMLFormContHe($filePath){
	$crlf = [char][int]13 + [char][int]10

 	$content = '<?xml version="1.0" encoding="utf-8"?>'+$crlf
 	$content += '<rows>'+$crlf
 	$content += '	<config>'+$crlf
 	$content += '		<fileName>applicationForm</fileName>'+$crlf
 	$content += '		<docHeader>טופס בקשה</docHeader>'+$crlf
 	$content += '		<finalMessage>הפרטים נשמרו בהצלחה</finalMessage>'+$crlf
 	$content += '		<missingDataMessage>יש למלא את כל השדות המסומנים</missingDataMessage>'+$crlf
 	$content += '		<registrationMessage>אינך רשום/ה למלגה זו. <![CDATA[<a href="http://scholarships2.ekmd.huji.ac.il/home">הירשם/י כאן</a>]]></registrationMessage>'+$crlf
 	$content += '		<docTypeList>docType</docTypeList>'+$crlf
 	$content += '		<docTypeColumn>Document Type</docTypeColumn>'+$crlf
 	$content += '		<docType>0. Application Form</docType>'+$crlf
 	$content += '	</config>'+$crlf+$crlf

	$content += '	<row>'+$crlf
	$content += '		<Header>זהו טופס ריק שנוצר אוטומטית</Header>'+$crlf
	$content += '	</row>'+$crlf

	$content += '	<row>'+$crlf
	$content += '		<Label>'+$crlf
	$content += '		</Label>'+$crlf
	$content += '	</row>'+$crlf+$crlf	

	$content += '	<row>'+$crlf
	$content += '		<Header>הקובץ הוא: ' +$filePath+'</Header>'+$crlf
	$content += '	</row>'+$crlf+$crlf

	$content += '	<row>'+$crlf
	$content += '		<Label></Label>'+$crlf
	$content += '	</row>'+$crlf+$crlf

	$content += '	<row>'+$crlf
	$content += '		<Button>שמירה</Button>'+$crlf
	$content += '	</row>'+$crlf+$crlf

	$content += '	<row>'+$crlf
	$content += '		<Label></Label>'+$crlf
	$content += '	</row>'+$crlf+$crlf

	$content += '	<row>'+$crlf
	$content += '		<control>'+$crlf
	$content += '			<Type>finalMessage</Type>'+$crlf
	$content += '			<Data>MyCustomLabel</Data>'+$crlf
	$content += '			<width>500</width>'+$crlf
	$content += '			<Text></Text>'+$crlf
	$content += '		</control>'+$crlf
	$content += '	</row>'+$crlf+$crlf
	
	$content += '</rows>'+$crlf	

	return $content
}