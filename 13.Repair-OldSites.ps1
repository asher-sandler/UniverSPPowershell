function FixDocType($oldSiteURL){
	
	$docTypeSchema = New-DocTypeFieldsSchema
	foreach($fieldsSchema in $docTypeSchema){
		$DisplayName = Select-Xml -Content $fieldsSchema  -XPath "/Field" | ForEach-Object {
			$_.Node.DisplayName
		}
		
		if($DisplayName -eq "Name" -or $DisplayName -eq "Title"){
			continue
		}
		add-SchemaFields $oldSiteURL "DocType" $fieldsSchema
		
		
	}
	$pathField = '<Field Type="Text" DisplayName="path"  />'
	add-SchemaFieldsX $oldSiteURL "DocType" $pathField
	
}
function add-SchemaFieldsX($siteUrl, $listName, $fieldsSchema){
        #Setup the context
        $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
        $Ctx.Credentials = $Credentials
         
        #Get the List
        $List = $Ctx.Web.Lists.GetByTitle($listName)
        $Ctx.Load($List)
        $Ctx.ExecuteQuery()
 
        #Check if the column exists in list already
        $Fields = $List.Fields
        $Ctx.Load($Fields)
        $Ctx.executeQuery()
		$DisplayName = Select-Xml -Content $fieldsSchema  -XPath "/Field" | ForEach-Object {
			 $_.Node.DisplayName
			 
		}
		$NewField = $Fields | where {($_.Title -eq $DisplayName -and $_.InternalName -ne "FileDirRef")}
		
        if($NewField -ne $NULL) 
        {
            Write-host "Column $DisplayName already exists in the List!" -f Yellow
        }
        else
        {
			$NewField = $List.Fields.AddFieldAsXml($fieldsSchema,$True,[Microsoft.SharePoint.Client.AddFieldOptions]::AddFieldInternalNameHint)
			$Ctx.ExecuteQuery()   
			Write-host "Column $DisplayName was Add to the $listName Successfully!" -ForegroundColor Green
		}	
		
}

function FixDocUpload($oldSiteURL, $lang, $relURLX){
	$siteDumpObj = "" | Select-Object Source
	$sourceObj   = "" | Select-Object URL, RelPath, Lists, Pages      
	
	$sourceObj.Url = $oldSiteURL
	$sourceObj.RelPath = $relURLX # get-RelURL $oldSiteURL
	#$sourceObj.Lists = Collect-libs $oldSiteURL

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


	$siteDumpFileName = ".\JSON\13."+$sourceObj.RelPath+"-PagesDump.json"			

	$siteDumpObj | ConvertTo-Json -Depth 100 | out-file $siteDumpFileName -Encoding Default			
	write-Host "$siteDumpFileName Created..." -f Yellow

	$docUploadExists = $false
	foreach($page in $siteDumpObj.Source.Pages){
		
		if ($page.Name -eq "Pages/DocumentsUpload.aspx"){
			$docUploadExists = $true
			break

		}
	}

	if ($docUploadExists){
		$docUploadExists = $true

		write-Host "DocumentsUpload.aspx exists" -foregroundcolor Cyan
		$loaderWPExists = edt-DocUploadWPX $oldSiteURL  $lang
		if (!$loaderWPExists){
			edt-DocumentsUploadLoaderX  $oldSiteURL  $lang
		}
	}
	else
	{
		write-Host "DocumentsUpload.aspx does'nt exist" -foregroundcolor Yellow
		$pageTitle = "העלאת מסמכים"
		$RecentsTitle = "לאחרונה"

		if($lang -eq "En"){
			$pageTitle = "Documents Upload"
			$RecentsTitle = "Recent"
		}
		Create-WPPage $oldSiteURL "DocumentsUpload" $pageTitle
		edt-DocumentsUploadX  $oldSiteURL  $lang
		
		# may be error
		$NOmoreSubItems = $false
		while (!$NOmoreSubItems){
			$NOmoreSubItems =  Delete-RecentsSubMenu $oldSiteURL $RecentsTitle 
					
		}

		Delete-RecentMainMenu $oldSiteURL $RecentsTitle 	

	}
}
function edt-DocUploadWPX($siteUrlC , $lang){
	$pageName = "Pages/DocumentsUpload.aspx"
	
	$siteName = get-UrlNoF5 $siteUrlC
	write-host "Change WP On $pageName on Site: $siteName" -foregroundcolor Yellow
	
	$relUrl   = get-RelURL $siteName
	
	$pageURL  = $relUrl + $pageName
	#$language = $spObj.language
	$loaderWPExists = $false
    $languageWP =  1
	$configFileName = "UploadFilesHe.xml"
	$isDebug = $false
	if ($lang.toLower().contains("en"))
	{
		$configFileName = "UploadFilesEn.xml"
		$languageWP =  2
		
	}
	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials


	$page = $ctx.Web.GetFileByServerRelativeUrl($pageURL);
	
	$webpartManager = $page.GetLimitedWebPartManager([Microsoft.Sharepoint.Client.WebParts.PersonalizationScope]::Shared);	
	
	Write-Host 'Updating webpart "UploadFilesWP"  from the page DocumentsUpload.aspx' -ForegroundColor Green
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
			if ($wp.WebPart.Title.contains("UploadFilesWP")){
				$wp.WebPart.Properties["Config_Name"] = $configFileName
				$wp.WebPart.Properties["Config_Path"] = "\\ekeksql00\SP_Resources$\HSS\UploadFiles\"
				$wp.WebPart.Properties["Language"] = $languageWP;
				$wp.WebPart.Properties["Debug"] = $isDebug;
			}
			if ($wp.WebPart.Title.contains("LoaderWP")){
				$loaderWPExists = $true	
			}
			$wp.WebPart.Properties["ChromeType"] = 2
			$wp.SaveWebPartChanges();				
			
	}
	$page.CheckIn("Change 'UploadFilesWP'", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
	$page.Publish("Change 'UploadFilesWP'")
	$ctx.ExecuteQuery()
	
	return $loaderWPExists
	
}
function Edit-DocTypeList( $oldSite){
	write-host "Copying Document Type List." -foregroundcolor Green
	$siteUrlOld = get-UrlNoF5 $oldSite


	  
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrlOld)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials
	
	#Get the List
	$ListName="DocType"
	$List = $Ctx.Web.lists.GetByTitle($ListName)
	 
	#Define the CAML Query
	$Query = New-Object Microsoft.SharePoint.Client.CamlQuery
	$qry = "<View><Query></Query></View>"
	$Query.ViewXml = $qry

	#Get All List Items matching the query
	$ListItems = $List.GetItems($Query)
	$Ctx.Load($ListItems)
	$Ctx.ExecuteQuery()
	
	$aDocTypeListOld = @()


	ForEach($Item in $ListItems){
		$docTypeItem = "" | Select ID,Title, Required, FilesNumber , fromMail, sourceField,ApplicantPermissions,limitUpload
		
		$docTypeItem.ID = $Item.ID
		$docTypeItem.Title = $Item["Title"]
		$docTypeItem.Title = $docTypeItem.Title.Trim()
		$docTypeItem.Required = $Item["Required"]
		$docTypeItem.FilesNumber = $Item["FilesNumber"]
		$docTypeItem.fromMail = $Item["fromMail"]
		if ([string]::IsNullOrEmpty($Item["ApplicantPermissions"])){
			$docTypeItem.ApplicantPermissions = "contribute"
		}
		else{
			$docTypeItem.ApplicantPermissions = $Item["ApplicantPermissions"]
		}
		if ([string]::IsNullOrEmpty($Item["limit_upload"])){
			$docTypeItem.limitUpload = $false
		}
		else
		{
			$docTypeItem.limitUpload = $Item["limit_upload"]
		}
		
		
		$titlOpX = $Item["Title"].toLower()
		if ($titlOpX.contains("טופס")  -or $titlOpX.contains("form") -or
			$titlOpX.contains("המלצ") -or $titlOpX.contains("recomm")){
			$isVATAT = ($titlOpX.contains("ותת") -or $titlOpX.contains('ות"ת'))	
			#Write-Host "VATAT Found: $isVATAT" -f Yellow
			if 	(!$isVATAT){
				$docTypeItem.ApplicantPermissions = "none"	
			}
	
		} 
		#$docTypeItem.sourceField = $Item["source_field"]
		
		$aDocTypeListOld += $docTypeItem

	}	
	
	foreach($adocItem in $aDocTypeListOld){
		 
		$listItem = $List.GetItemById($adocItem.ID)
		$listItem["ApplicantPermissions"] = $adocItem.ApplicantPermissions
		$listItem["Title"] = $adocItem.Title
		$listItem["limit_upload"] = $adocItem.limitUpload
		$listItem.Update()
		$ctx.executeQuery() 
					
	
	}

	
	return $null

}
function get-SiteLanguage($siteURL){
	$cLang = "En"
	$siteUrlC = get-UrlNoF5 $siteUrl
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrlC)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials
	
	$Web = $Ctx.Web
	$ctx.Load($Web)
	$Ctx.ExecuteQuery()
	
	if ($Web.Language -eq 1037){ #1033 English
		$cLang = "He"
	}
	return $cLang
	
}
function edt-DocumentsUploadLoaderX($newSiteName, $language){
	$pageName = "Pages/DocumentsUpload.aspx"
	
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
	
	$pageTitle  = "העלאת מסמכים"
	if ($language.ToLower().contains("en")){
		$pageTitle = "Documents Upload"
	}
	
	$pageFields = $page.ListItemAllFields
	$PageContent = $pageFields["PublishingPageContent"]
	$oWP = Get-WPfromContent $PageContent
	$editContent = "<br/><br/>Add Following WebParts:<br/><b>1. Custom/UploadFilesWP - VisualWebPart1</b><br/><b>2. Custom/LoaderWP - VisualWebPart1</b><br/>3. Edit Navigation<br/><br/>4. Delete this text<br/><p style='color:red;'>5. And Run script 13 again...</p><br/><p></p><p></p><p></p>"
	
	foreach ($wp in $oWP){
		if ($wp.isWP){
			$editContent += $wp.Content 
		}
			
		$i++
	}
    
	$pageFields["PublishingPageContent"] = "<h1>" + $pageTitle + "</h1>" +	$editContent	
	$pageFields["Title"] = $pageTitle
	
	$pageFields.Update()
	
	$ctx.Load($pageFields)
	$ctx.ExecuteQuery();
	
	$page.CheckIn("",1)
	
	$ctx.ExecuteQuery()
	write-host "$pageName Was Updated" -foregroundcolor Green	
	
}
function edt-DocumentsUploadX($newSiteName, $language){
	$pageName = "Pages/DocumentsUpload.aspx"
	
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
	
	$pageTitle  = "העלאת מסמכים"
	if ($language.ToLower().contains("en")){
		$pageTitle = "Documents Upload"
	}
	
	$pageFields = $page.ListItemAllFields
	$PageContent = $pageFields["PublishingPageContent"]
	$oWP = Get-WPfromContent $PageContent
	$editContent = "<br/><br/>Add Following WebParts:<br/><b>1. Custom/UploadFilesWP - VisualWebPart1</b><br/><b>2. Custom/LoaderWP - VisualWebPart1</b><br/>3. Edit Navigation<br/><br/>4. Delete this text<br/><p style='color:red;'>5. And Run script 13 again...</p><br/><p></p><p></p><p></p>"
	
	foreach ($wp in $oWP){
		if ($wp.isWP){
			$editContent += $wp.Content 
		}
			
		$i++
	}
    
	$pageFields["PublishingPageContent"] = "<h1>" + $pageTitle + "</h1>" +	$editContent	
	$pageFields["Title"] = $pageTitle
	
	$pageFields.Update()
	
	$ctx.Load($pageFields)
	$ctx.ExecuteQuery();
	
	$page.CheckIn("",1)
	
	$ctx.ExecuteQuery()
	write-host "$pageName Was Updated" -foregroundcolor Green	
}
function New-DocTypeFieldsSchema(){
	$fieldsList = @()
	$fieldsList += '<Field Type="Text" DisplayName="source_field"  />'
	$fieldsList += '<Field Type="Choice" DisplayName="ApplicantPermissions"  Format="Dropdown" FillInChoice="FALSE" ><Default>contribute</Default><CHOICES><CHOICE>contribute</CHOICE><CHOICE>read</CHOICE><CHOICE>view</CHOICE><CHOICE>none</CHOICE></CHOICES></Field>'
	
	$fieldsList += '<Field Type="Boolean" DisplayName="limit_upload" ><Default>0</Default></Field>'
	
	return $fieldsList
	
}
function Reverse-HebrewString($str){
    if ([string]::IsNullOrEmpty($str)){
		return ""
	}
	$retStr = $str
	<#
	$abcHeb = "אבגדהוזחטיךכלםמןנסעףפץצקרשת"
	
	#write-Host 
	$cnt = $str.Length
    $isHebrew = $false
	for($k=0;$k -lt $cnt;$k++){
		$symbl = $str[$k]
		$idx = $abcHeb.IndexOf($symbl)
		if ($idx -ge 0){
			$isHebrew = $true
			break
		}
	}
	#>
	if($str -match '[\u0590-\u05FE\uFB1D-\uFB4F]'){
	#if($isHebrew){
		$sH2 = $str.ToCharArray()
		
		[array]::Reverse($sH2)
		$retStr = -join($sH2)
		
	}
	
	return $retStr
}
function get-AvailListObj($connectionUID){
	$urlArchiveLog = "https://portals.ekmd.huji.ac.il/home/huca/spSupport" 
	$listArchive = "availableArchives"
	$obj  = "" | Select URL,List,ID
	# 1670406916929


	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($urlArchiveLog)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials
		  
	#Get the List
		
	$List = $Ctx.Web.lists.GetByTitle($listArchive)
		 
		#Define the CAML Query
	$Query = New-Object Microsoft.SharePoint.Client.CamlQuery
	$qry = "<View><Query><Where><Eq><FieldRef Name='ReqListConnection_UID' /><Value Type='Number'>$connectionUID</Value></Eq></Where></Query></View>"
	#write-Host $qry
	$Query.ViewXml = $qry

	#Get All List Items matching the query
	$ListItems = $List.GetItems($Query)
	$Ctx.Load($ListItems)
	$Ctx.ExecuteQuery()
	#write-Host 265 $ListItems.Count
	foreach($listItem in $listItems)
	{
		$avList = $listItem["availableListURL"]
		if ($avList){
			$HyperLinkField = [Microsoft.SharePoint.Client.FieldUrlValue]$listItem["availableListURL"]
			$avListURL  = $HyperLinkField.URL
			$avlUri = [System.Uri]$avListURL
			$obj.URL = $avlUri.AbsoluteUri.toLower().Substring(0,$avlURI.AbsoluteUri.ToLower().IndexOf("/lists"))
			$obj.List = $avlUri.AbsoluteUri.toLower().Substring($avlURI.AbsoluteUri.ToLower().IndexOf("/lists")+7).split("/")[0]
			$obj.ID = $avlUri.Query.Split("=")[1]
			
		}
	}	
	return $obj
}

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
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Publishing.dll"

$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"

$Credentials = get-SCred	

$siteSPSupport = "https://portals.ekmd.huji.ac.il/home/huca/spSupport"
$urlSPSupport = get-UrlNoF5 $siteSPSupport
$listSPRequest = "spRequestsList"


$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteSPSupport)
#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
$Ctx.Credentials = $Credentials
		  
		#Get the List
		
$List = $Ctx.Web.lists.GetByTitle($listSPRequest)
		 
		#Define the CAML Query
$Query = New-Object Microsoft.SharePoint.Client.CamlQuery
$qry = "<View><Query><Where><Or><Eq><FieldRef Name='status' /><Value Type='Choice'>0 - חדש</Value></Eq><Eq><FieldRef Name='status' /><Value Type='Choice'>1 - בביצוע</Value></Eq></Or></Where></Query></View>"
$qry = "<View><Query><Where><Or><Eq><FieldRef Name='status' /><Value Type='Choice'>0 - חדש</Value></Eq><Eq><FieldRef Name='status' /><Value Type='Choice'>2 - ארכיון בוצע</Value></Eq></Or></Where></Query></View>"
$qry = "<View><Query><Where><Eq><FieldRef Name='status' /><Value Type='Choice'>4 - ניקוי לאחר ארכוב בוצע</Value></Eq></Where></Query></View>"
$Query.ViewXml = $qry

#Get All List Items matching the query
$ListItems = $List.GetItems($Query)
$Ctx.Load($ListItems)
$Ctx.ExecuteQuery()

$i=0
$oldSitesObj = [System.Collections.ArrayList]::new()
$idx = 1		

foreach($listItem in $listItems)
{
	if (![string]::IsNullOrEmpty($listItem["currentSiteUrl"])){

		$sItem = "" | Select Index, Title,TitleEn,ReqListID, OldUrl,availURL,availList, availID,RelURL
		$sItem.Index = $idx
		$sItem.Title = $listItem["siteName"]
		$sItem.TitleEn = $listItem["siteNameEn"]
		$sItem.ReqListID = $listItem.ID
		$sItem.OldUrl = get-SiteNameFromNote $listItem["currentSiteUrl"]
		$availList = get-AvailListObj $listItem["MihzurConnection_UID"]
		$sItem.availURL = $availList.URL
		$sItem.availList = $availList.List
		$sItem.availID = $availList.ID
		$sItem.RelURL = $sItem.OldUrl.Split("/")[-2]

		if (![string]::IsNullOrEmpty($availList.URL)){
			$oldSitesObj.Add($sItem) | out-null
			$idx++	
		}
	}
}
if ($oldSitesObj.Count -gt 0){
	write-host "OldSites found." -f Green
	write-host "Please choose old site you want to Repair by Index (1,2,...)" -f Green
	write-host "Index OldSiteURL"
	write-host "----- -----"
	foreach($st in $oldSitesObj){
		
		write-host " " $st.Index " " $st.OldUrl 
	}
	write-host "Choose Index :" -f Yellow -noNewLine
	$continue = read-host 
	$choice = $null	
	$siteURLRepair = ""
	$reqListID = 0
	$siteTitleEn = ""
	$siteTitle = ""

	$availbList = ""
	$availbUrl = ""
	$relURLCurrent = ""
	$availbID = 0
	$groupName = ""
	$spRequestsListObj = $null
	
	if ($continue.length -le 2) {
		[Int32]$OutNumber = $null
		if ([Int32]::TryParse($continue,[ref]$OutNumber)){
			
			foreach($st in $oldSitesObj){
				if ($st.Index -eq $OutNumber){
					$choice = $continue
					$siteTitleEn = $st.TitleEn
					$reqListID = $st.ReqListID
					$siteTitle = Reverse-HebString $st.Title
					$availbList = $st.availList
					$availbUrl = $st.availURL
					$availbID = $st.availID
					$choice = $continue
					$siteURLRepair =  $st.OldUrl
					$groupName = get-GroupName $siteURLRepair
					$spRequestsListObj = get-RequestListObject $reqListID
					$relURLCurrent = $st.RelURL
						
					break
				}
			}
		}
	}
	if($choice){
		
		#cls
		write-host
		
		write-host "ATTENTION. ATTENTION. ATTENTION."  -f Green
		
		$attnH1 = "שימו לב. שימו לב. שימו לב."
		$attnEn =  Reverse-HebString "ATTENTION. ATTENTION. ATTENTION."
		$attnHeb = Reverse-HebString $attnH1
				
		
		write-host $groupName  -f Yellow
		write-host $attnEn  -f Yellow
		write-host $attnHeb  -f Green
		write-host $attnHeb  -f Yellow
		write-host $attnHeb  -f Yellow
		write-host 
		write-host "==============================="  -f Yellow
		write-host 
		
		write-host "This procedure must run ONLY after site is Cleared (Status 4)."  -f Cyan
		write-host "If you not AWARE. Press CTRL^C to exit."  -f Yellow

		write-host 
		write-host "Attention. What this script will do?"  -f Yellow
		write-host 
		
		write-host "On Site: $siteURLRepair"  -f Yellow
		write-host "Site Title: $siteTitle"  -f Cyan
		write-host "Site Description: $siteTitleEn"  -f Cyan
		write-host 

		write-host "01. Add page DocumentsUpload.aspx (if not exists)"  -f Cyan
		write-host "02. Fix DocType"  -f Cyan
		write-host "03. Change DeadLine on applicants"  -f Cyan
		write-host "04. Add user to applicants"  -f Cyan
		write-host "05. Fix Default.aspx"  -f Cyan
		write-host "06. Fix DefaultHe.aspx (if exists)"  -f Cyan
		write-host "07. Replace site Title"  -f Cyan
		write-host "08. Replace site Description"  -f Cyan
		write-host "09. Replace Letter Template"  -f Cyan
		write-host 
		write-host "On Site: $availbUrl"  -f Yellow
		write-host "10. Replace Title on " -noNewLine -f Cyan 
		write-host $availbList  -f Yellow
		write-host "11. Replace Description on " -noNewLine -f Cyan
		write-host $availbList  -f Yellow
		write-host "12. Replace deadLine (-1 Year) on "  -noNewLine -f Cyan
		write-host $availbList  -f Yellow
		write-host "13. Replace recommendationsDeadline on "  -noNewLine -f Cyan
		write-host $availbList  -f Yellow
		write-host 
		write-host "Are you sure to continue  [Y/n]?" -noNewLine -f Yellow
		$continue = read-host 
		$ctx=$null	
		if (($continue.length -eq 1) -and ([int][char]$continue -eq 89)){
		
			#Write-TextConfig $spRequestsListObj $groupName
			$oldSiteURL = get-UrlNoF5 $siteURLRepair
			$lang = get-SiteLanguage $oldSiteURL
			write-host "Old Site: $oldSiteURL" -foregroundcolor Cyan
			write-host "Old Site Language: $lang" -foregroundcolor Cyan
		
			write-Host 623 "Press Any key.."		
			read-host

			
			Save-spRequestsFileAttachements $spRequestsListObj[0]
			$spRequestsListObj | ConvertTo-Json -Depth 100 | out-file $("JSON\"+$groupName+".json")
			

			FixDocUpload $oldSiteURL $lang $relURLCurrent
			FixDocType $oldSiteURL
			Edit-DocTypeList $oldSiteURL
			$oldSiteExists = $true
			$isDoubleLangugeSite = $($spRequestsListObj.language).toLower().contains("en") -and $($spRequestsListObj.language).toLower().contains("he")

			change-HeadingURL $oldSiteURL $(Get-RelURL $oldSiteURL)
			change-siteTitle  $oldSiteURL $($spRequestsListObj.siteName)
			change-siteDescription  $oldSiteURL $($spRequestsListObj.siteNameEn)
			
			$contentNewDefault = ""
			$contentOldDefault = get-OldDefault $oldSiteURL	
			$contentNewDefault = repl-DefContent $oldSiteURL $oldSiteURL $contentOldDefault
			edt-HomePage $oldSiteURL $contentNewDefault			

			change-ListApplicantsDeadLine 	$oldSiteURL $spRequestsListObj
			add-ListApplicants $oldSiteURL $spRequestsListObj
			change-applTemplate $oldSiteURL  $($spRequestsListObj.language)
			Change-GroupDescription $groupName $spRequestsListObj[0].siteNameEn
			Add-GroupMember $groupName $spRequestsListObj[0].contactEmail $spRequestsListObj[0].userName

			$prepare = $false
			#  flag prepare:  indicate that check field 
			# "Archive_Waiting_for_Archivation"  or not
			$availListId = Get-AvailListRecord $spRequestsListObj[0].systemURL  $spRequestsListObj[0].systemListName $spRequestsListObj[0].RelURL $prepare
			
			$availListLink = $(get-UrlWithF5 $($spRequestsListObj[0].systemListUrl))+"/EditForm.aspx?ID="+$availListId.ToString().Trim()
			Edit-SiteList $spRequestsListObj $availListId			
			$isMihzur = $true
			Write-TextConfig $spRequestsListObj $groupName $isMihzur
			# copyMail $spRequestsListObj $true
			Log-Generate $spRequestsListObj $oldSiteURL	
		}
		
	}
	else
	{
		write-Host "Index Not valid." -f Yellow
	}

}
else
{
	Write-Host "No New sites found. " -f Yellow
}

