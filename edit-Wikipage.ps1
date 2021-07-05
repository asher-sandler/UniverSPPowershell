$userName = "ekmd\ashersa"
$userPWD = "GrapeFloor789"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"



function edt-page($site, $relUrl, $pageName){
	$pageName = "/Pages/"+$pageName+".aspx"
	$pageURL = $relUrl + $pageName

	#write-host $site
	#write-host $pageUrl

	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($Site)
	$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	
	$page = $ctx.Web.GetFileByServerRelativeUrl($pageUrl);
	
	$ctx.Load($page);
    $ctx.Load($page.ListItemAllFields);
    $ctx.ExecuteQuery();
	#write-host Page Methods -ForegroundColor Green
	
	#write-host Page Properties -ForegroundColor Green
	

	$page.CheckOut()
	
	$pagecont = '<div>123</div><div class="ms-rtestate-read ms-rte-wpbox" contenteditable="false" unselectable="on">      <div class="ms-rtestate-notify  ms-rtestate-read 13377df7-a25c-4e45-80e1-fb7478c161db" id="div_13377df7-a25c-4e45-80e1-fb7478c161db" unselectable="on"></div>      <div id="vid_13377df7-a25c-4e45-80e1-fb7478c161db" unselectable="on" style="display: none;">      </div>   </div>   <br/></div><div></div><br/>'
	$x = '<div lang="HE" style="text-align: right;">'
	$x +=    '<h1>צור קשר</h1>'
	$x +=    '<div>'
	$x +=       '<span class="ms-rteFontSize-2">בשאלות מנהליות&#160;<span lang="HE">ניתן לפנות אל:</span></span></div>'
	$x +=    '<div>'
	$x +=       '<span class="ms-rteFontSize-2" lang="HE">גלית נגה-בנאי</span></div>'
	$x +=    '<div dir="rtl" style="text-align: right;">'
	$x +=       '<span class="ms-rteFontSize-2" lang="HE">דוא&quot;ל:&#160;<a href="mailto:saskiad@savion.huji.ac.il"><span lang="EN-US" dir="ltr"></span></a><a href="mailto:galit.nogabanai@mail.huji.ac.il"><span style="text-decoration-line: underline;"><font color="#0066cc"><span style="text-decoration: underline;">galit.nogabanai@mail.huji.ac.il</span></font></span></a></span></div>'
	$x +=    '<p>​</p>'
	$x += '</div>'
	
	
	$newItem = $page.ListItemAllFields
	<#
		$newItem.FieldValues.keys
		
		
		ContentTypeId
		_ModerationComments
		FileLeafRef
		Modified_x0020_By
		Created_x0020_By
		File_x0020_Type
		HTML_x0020_File_x0020_Type
		_SourceUrl
		_SharedFileIndex
		Title
		TemplateUrl
		xd_ProgID
		xd_Signature
		ParentLeafName
		ParentVersionString
		Comments
		PublishingStartDate
		PublishingExpirationDate
		PublishingContact
		PublishingContactEmail
		PublishingContactName
		PublishingContactPicture
		PublishingPageLayout
		PublishingVariationGroupID
		PublishingVariationRelationshipLinkFieldID
		PublishingRollupImage
		Audience
		PublishingIsFurlPage
		SeoBrowserTitle
		SeoMetaDescription
		SeoKeywords
		RobotsNoIndex
		PublishingPageImage
		PublishingPageContent
		SummaryLinks
		ArticleByLine
		ArticleStartDate
		PublishingImageCaption
		HeaderStyleDefinitions
		SummaryLinks2
		AverageRating
		RatingCount
		e1a5b98cdd71426dacb6e478c7a5882f
		Wiki_x0020_Page_x0020_Categories
		TaxCatchAll
		ID
		Created
		Author
		Modified
		Editor
		_HasCopyDestinations
		_CopySource
		_ModerationStatus
		FileRef
		FileDirRef
		Last_x0020_Modified
		Created_x0020_Date
		File_x0020_Size
		FSObjType
		SortBehavior
		CheckedOutUserId
		IsCheckedoutToLocal
		CheckoutUser
		UniqueId
		SyncClientId
		ProgId
		ScopeId
		VirusStatus
		CheckedOutTitle
		_CheckinComment
		MetaInfo
		_Level
		_IsCurrentVersion
		ItemChildCount
		FolderChildCount
		AppAuthor
		AppEditor
		owshiddenversion
		_UIVersion
		_UIVersionString
		InstanceID
		Order
		GUID
		WorkflowVersion
		WorkflowInstanceID
		DocConcurrencyNumber
	#>
	$newItem["PublishingPageContent"] = $x # "<b>gfdgfgd</b>"
	$newItem["Title"] = "צור קשר" # "<b>gfdgfgd</b>"
	
	$newItem.Update();
	
	
	$ctx.Load($newItem)
	$ctx.ExecuteQuery();
	# $page.getType() | gm
	$page.CheckIn("",1)
	
	$ctx.ExecuteQuery()

	

	
<#
	$page | gm
	

	Write-Host "The page is checkout" -ForegroundColor Green
	read-host	
	$webpartManager = $page.GetLimitedWebPartManager([Microsoft.Sharepoint.Client.WebParts.PersonalizationScope]::Shared);
	$Ctx.Load($webpartManager)
    $Ctx.Load($webpartManager.WebParts)
	$ctx.ExecuteQuery()
	
	
	foreach($webpart in $webpartManager.WebParts )
	{
		$Ctx.Load($webpart.WebPart)
		$ctx.Load($webpart.WebPart.Properties)
        $Ctx.ExecuteQuery()
		
		$webpart.WebPart.Title
		
		$webpart.WebPart.Properties.Item.Name # | gm
		$wpPropValues = $webpart.WebPart.Properties.FieldValues
		$properties =  $webpart.WebPart.Properties.FieldValues
		Write-Host "Webpart ID: " $webpart.ID
		#Write-Host "Webpart Context: " $webpart.Context
		#$webpart.Context | gm
		
		foreach($prop in $properties){
			# $prop.keys
		}
	}
	
	$page = $ctx.Web.GetFileByServerRelativeUrl($pageUrl);
	$allFields.FieldValues.PublishingPageContent = "<b>Ку-Ку</b>"
	# $page.Set_Item("PublishingPageContent", "<b>Ку-Ку</b>")
	# $page.Update()	
	$page.CheckIn("",1)
	$ctx.ExecuteQuery()
	
	#$file = $page.ListItem.File
    #$file.Publish("")
	#$ctx.ExecuteQuery()
	
#>	
}



$site = "https://portals.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace"
$relUrl = "/home/huca/EinKarem/ekcc/QA/AsherSpace"
$page = "contactus"
edt-page $site $relUrl $page