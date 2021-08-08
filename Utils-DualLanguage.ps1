function check-DLangTemplInfrastruct($siteUrlC, $spRequestsListObj,$oldSiteExists, $oldSiteName){

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
	write-Recommendations  $cpath $siteUrlC $relUrl
	write-Form			   $cpath $siteUrlC $relUrl 
	write-Default		   $cpath $siteUrlC $relUrl $($spRequestsListObj.deadLineText) $oldSiteExists $oldSiteName

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
		if ($i -eq 3){
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
		if ($i -eq 3){
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
		if ($i -eq 3){
			$editContent += $crlf+ $crlf + $contentRecommendationsHe2 + $crlf+ $crlf
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
	$swHe = SwitchToHeb $CurrPage $sName
	$editContentPathHe  = $cpath+"\"+$CurrPage+"\switchHe.txt"
	$swHe | Out-File $editContentPathHe -encoding Default
	
	$swEn  =  DefaultHeStyle
	$swEn += SwitchToEng $CurrPage $sName
	$editContentPathEn  = $cpath+"\"+$CurrPage+"\switchEn.txt"
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
	
	
	$editContentPathHe  = $cpath+"\"+$CurrPage+"\switchHe.txt"
	$swHe | Out-File $editContentPathHe -encoding Default
	
	$swEn = SwitchToEng $CurrPage $sName
	$editContentPathEn  = $cpath+"\"+$CurrPage+"\switchEn.txt"
	$swEn | Out-File $editContentPathEn -encoding Default
	
	

	#$pagePath = $cpath+"\"+$CurrPage+"\ContentHe.txt"
	#$contentCancelCandHe | Out-File $pagePath -encoding Default
	
	
		
	return $null
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
		$outStr = '<h1>סטטוס מסמכים</h1>
	
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
</div>'	
	return $outStr
}
function SubmissionStatusDLangContentHe2($relURL){
		$outStr = '<div>
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
	$outStr = '<div style="text-align: center; text-decoration: underline;">' 
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
function edt-SubmissionStatus2Lang($newSiteName){
	$pageName = "Pages/SubmissionStatus.aspx"
	
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
	$pageTitle = "Submission Status"
	$pageFields["Title"] = $pageTitle
	$pageFields.Update()
	
	$ctx.Load($pageFields)
	$ctx.ExecuteQuery();
	
	$page.CheckIn("",1)
	
	$ctx.ExecuteQuery()	
	write-host "$pageName Was Updated" -foregroundcolor Green
		
}

function edt-cancelCandidacy2Lang($newSiteName){
	$pageName = "Pages/CancelCandidacy.aspx"
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

	$pageTitle = "Cancel Candidacy"
	$pageFields["Title"] = $pageTitle
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