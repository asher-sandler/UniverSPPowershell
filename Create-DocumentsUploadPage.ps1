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
function Create-WPPageX($siteURL,$pageName,$PageTitle, $PageContent){
	$siteName = get-UrlNoF5 $SiteURL
	if (!$pageName.toLower().Contains('.aspx')){
		$pageName += '.aspx'
	} 
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
	$ctx.Credentials = $Credentials
	


 	$Web = $Ctx.Web
	$ctx.Load($Web)
	$Ctx.ExecuteQuery()
	
	$rlURL =  $(get-RelURL $siteName)
	$pageListUrl = $rlURL +"Pages"
	# write-host $pageListUrl
	$PageList = $Web.GetList($pageListUrl)
	$Ctx.Load($PageList)
	$Ctx.ExecuteQuery()
	#$pageName = "default.aspx"
	$query = New-Object Microsoft.SharePoint.Client.CamlQuery  
	$query.ViewXml = "<View><Query><Where><Contains><FieldRef Name='FileLeafRef' /><Value Type='Text'>"+$pageName+"</Value></Contains></Where></Query></View>"  
	$listItems = $PageList.GetItems($query)  
	$ctx.load($listItems) 
	$ctx.executeQuery()  	
	
	if ($listItems.Count -eq 0){
		write-host "Create-WPPage: $pageName on $siteURL" -foregroundcolor Cyan
		
		#Write-host -f Yellow "Getting Page Layout..." -NoNewline
		#Get the publishing Web 
		$PublishingWeb = [Microsoft.SharePoint.Client.Publishing.PublishingWeb]::GetPublishingWeb($Ctx, $Ctx.Web) 
		$ctx.Load($PublishingWeb)
		$Ctx.ExecuteQuery()
 		
		#Get the Page Layout
		$RootWeb = $Ctx.Site.RootWeb
		$PageLayoutName = "BlankWebPartPage.aspx"
		$MasterPageList = $RootWeb.Lists.GetByTitle('Master Page Gallery')
		$CAMLQuery = New-Object Microsoft.SharePoint.Client.CamlQuery
		$CAMLQuery.ViewXml = "<View><Query><Where><Eq><FieldRef Name='FileLeafRef' /><Value Type='Text'>$PageLayoutName</Value></Eq></Where></Query></View>"
		$PageLayouts = $MasterPageList.GetItems($CAMLQuery)
		$Ctx.Load($PageLayouts)
		$Ctx.ExecuteQuery()
		$PageLayoutItem = $PageLayouts[0]
		write-Host "PageLayouts Count: $($PageLayouts.count)"
		$Ctx.Load($PageLayoutItem)
		$Ctx.ExecuteQuery()
		#Write-host -f Green "Done!"
		 
		#Create Publishing page
		Write-host -f Yellow "Creating New Page..." -NoNewline
		$PageInfo = New-Object Microsoft.SharePoint.Client.Publishing.PublishingPageInformation 
		$PageInfo.Name = $PageName
		$PageInfo.PageLayoutListItem = $PageLayoutItem
		$Page = $PublishingWeb.AddPublishingPage($PageInfo) 
		$Ctx.ExecuteQuery()
		#Write-host -f Green "Done!"
		 
		#Get the List item of the page
		Write-host -f Yellow "Updating Page Content..." -NoNewline
		$ListItem = $Page.ListItem
		$Ctx.Load($ListItem)
		$Ctx.ExecuteQuery()
		 
		#Update Page Contents
		$ListItem["Title"] = $PageTitle
		$ListItem["PublishingPageContent"] = $PageContent
		$ListItem.Update()
		$Ctx.ExecuteQuery()
		#Write-host -f Green "Done!"
		 
		#Publish the page
		Write-host -f Yellow "Checking-In and Publishing the Page..." -NoNewline
		$ListItem.File.CheckIn([string]::Empty, [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
		$ListItem.File.Publish([string]::Empty)
		$Ctx.ExecuteQuery()
		Write-host -f Green "Done!"


	}
	else
	{
		Write-host -f Yellow "$pageName on $siteURL already exists" 
	}
	
	return $null
}
function UploadTitl($lang){
	$titl = "העלאת מסמכים"
	if (![string]::isNullOrEmpty($lang )){
		if ($lang.toLower().contains("en")){
			$titl = "Documents Upload"
		}
	}
	return $titl
}
function UploadContent($lang)
{
	$titl = UploadTitl $lang
	$content = "<h1>"+$titl+"</h1><p>Insert Web <b>UploadFilesWP</b> Part Here</p>"
	return $content
}
function edt-DocUploadWPX($siteUrlC , $spObj){
	$pageName = "Pages/DocumentsUpload.aspx"
	
	$siteName = get-UrlNoF5 $siteUrlC
	write-host "Change WP On $pageName on Site: $siteName" -foregroundcolor Yellow
	
	$relUrl   = get-RelURL $siteName
	
	$pageURL  = $relUrl + $pageName
	#$language = $spObj.language
    $languageWP =  1
	$configFileName = "UploadFilesHe.xml"
	$isDebug = $false
	if (![string]::isNullOrEmpty($spObj.language )){
		if ($spObj.language.toLower().contains("en"))
		{
			$configFileName = "UploadFilesEn.xml"
			$languageWP =  2
		
		}
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
				$wp.WebPart.Properties["Config_Path"] = "\\ekeksql00\sp_resources$\HSS\UploadFiles" #$spObj.XMLUploadPath
				
				$wp.WebPart.Properties["Language"] = $languageWP;
				$wp.WebPart.Properties["Debug"] = $isDebug;
				$wp.WebPart.Properties["ChromeType"] = 2;
				
				$wp.SaveWebPartChanges();				
			}		
	}
	$page.CheckIn("Change 'UploadFilesWP'", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
	$page.Publish("Change 'UploadFilesWP'")
	$ctx.ExecuteQuery()
	
}
$cred = get-SCred


 $siteName = "https://hss2.ekmd.huji.ac.il/home/";
 $ListName="availableScholarshipsList"

	 

 
 write-host "URL: $siteName" -foregroundcolor Yellow
 
 
 $siteUrl = get-UrlNoF5 $siteName

 $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
 $Ctx.Credentials = $Credentials
 $List = $Ctx.Web.lists.GetByTitle($listName)
 $dt = Get-Date
 $dt.AddDays(-2)
 $dtS = $dt.Year.ToString()+"-"+$dt.Month.ToString().PadLeft(2,"0")+"-"+$dt.Day.ToString().PadLeft(2,"0") + "T03:00:00Z"

	#Define the CAML Query
  $Query = New-Object Microsoft.SharePoint.Client.CamlQuery
  $qry = "<View><Query>
   <Where>
      <Geq>
         <FieldRef Name='deadline' />
         <Value IncludeTimeValue='TRUE' Type='DateTime'>$dtS</Value>
      </Geq>
   </Where>
</Query>
</View>"
  $qry = "<View><Query></Query></View>"
    $Query.ViewXml = $qry
  
	$ListItems = $List.GetItems($Query)
	$Ctx.Load($ListItems)
	$Ctx.ExecuteQuery()
	
	#$i= $ListItems.Count
	
	$opendeSites = @()
	forEach($reqstItem in $ListItems){
		$urlSite = get-UrlNoF5 $reqstItem["url"]
		
		$deadline = $reqstItem["deadline"]
		if ($deadline -ge $((get-Date).AddDays(-1))){
			$i++
			$siteProps =  "" | Select-Object URL, Deadline, Lang
			$siteProps.URL = $urlSite
			$siteProps.Deadline = $deadline
			$jsonFile = "JSON\HSS_" + $urlSite.split("/")[-1]+".json"
			if (Test-Path $jsonFile){
				#write-Host 
				$spObj = get-content $jsonFile -encoding default | ConvertFrom-Json
				$siteProps.Lang = $spObj.language
			}
			$opendeSites += $siteProps
			#write-host "$urlSite ; $deadline" -f Yellow
			
		}
		
	}
	Write-Host "Open Sites Found: $($opendeSites.Count) " -f Yellow
	
	$i=0;
	forEach($sProp in $opendeSites){
		$i++;
		#if ($i -gt 15){
		#	break;
		#}
		$pageName = "DocumentsUpload"
		$pageTitle = UploadTitl $sProp.lang
		$pageCont  = UploadContent $sProp.lang
		write-Host $sProp.lang 
		write-Host $sProp.URL -f Cyan
		write-Host $pageName -f Green
		write-Host $pageTitle -f Yellow
		write-Host $pageCont -f Magenta
		write-Host ------------------
		write-Host 
		# $siteURL,$pageName,$PageTitle, $PageContent
		Create-WPPageX $sProp.URL $pageName $pageTitle $pageCont
		$jsonFile = "JSON\HSS_" + $sProp.URL.split("/")[-1]+".json"
		if (Test-Path $jsonFile){
			$spObj = get-content $jsonFile -encoding default | ConvertFrom-Json
			edt-DocUploadWPX $sProp.URL $spObj
		}	

	}
	$outCSV = "JSON\HSS_Sites.csv"
	
	$opendeSites | Export-CSV -Path $outCSV -Encoding Default -NoTypeInfo
	