function Edt-ItemArchive( $siteUrl,$listName, $recItem){
	$siteName = get-UrlNoF5 $siteUrl
	write-host 3 $siteName $listName
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials
	$List = $Ctx.Web.lists.GetByTitle($listName)
	$listItem = $List.GetItemById($recItem.ArchiveID)
	$listItem["url"] = $(get-UrlWithF5 $recItem.ArchiveURL)  #url
	$listItem.Update()      
	$ctx.load($list)      
	$ctx.executeQuery()  
	
	
}
function New-ItemArchive( $siteUrl,$listName, $recItem){
	$siteName = get-UrlNoF5 $siteUrl
	write-host 3 $siteName $listName
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials
	$List = $Ctx.Web.lists.GetByTitle($listName)
	$listItemInfo = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation  
	$listItem = $list.AddItem($listItemInfo)  

	$listItem["Title"] = $recItem.Title #Title
	$listItem["ScholarshipName"] = $recItem.ScholarshipName #ScholarshipName
	$listItem["language"] = $recItem.language #language
	$listItem["sort1"] = $recItem.sort1
	$listItem["relativeURL"] = $recItem.relativeURL   #relativeURL
	
	$listItem["template"] = $recItem.template   #template
	$listItem["folderName"] = $recItem.folderName   #folderName
	$listItem["docType"] = $recItem.docType  #docType
	$listItem["mailSuffix"] = $recItem.mailSuffix  #mailSuffix
	$listItem["adminGroup"] = $recItem.adminGroup   #adminGroup
	$listItem["adminGroupSP"] = $recItem.adminGroupSP   #adminGroupSP
	$listItem["AdminPermissions"] = $recItem.AdminPermissions   #AdminPermissions
	$listItem["applicantsGroup"] = $recItem.applicantsGroup  #applicantsGroup
	$listItem["GlobalAapplicantGroup"] = $recItem.GlobalAapplicantGroup   #GlobalAapplicantGroup
	$listItem["deadline"] = $recItem.applDeadline   #deadline
	$listItem["recommendationsDeadline"] = $recItem.recommendationsDeadline   #recommendationsDeadline
	$listItem["SiteTitle"] = $recItem.SiteTitle   #SiteTitle
	$listItem["SiteDescription"] = $recItem.SiteDescription   #SiteDescription
	$listItem["isCreated"] = $recItem.isCreated  #isCreated

	#!!!
	$listItem["Target_x0020_Audiences"] = $recItem.TargetAudiences   #Target Audiences


	$listItem["url"] = $(get-UrlWithF5 $recItem.ArchiveURL)  #url
	#$listItem["ScholarshipStartDate"] = $recItem.ScholarshipStartDate   #ScholarshipStartDate
	#$listItem["mailContactDeleted"] = $recItem.mailContactDeleted   #mailContactDeleted
	#$listItem["alert_x0020_date"] = $recItem.alertdate   #alert date
	#$listItem["contactEMail"] = $recItem.contactEMail  #contactEMail
	#$listItem["contactPhone"] = $recItem.contactPhone   #contactPhone
	$listItem["destinationList"] = $recItem.destinationList   #destinationList
	$listItem["applicantsGroupSP"] = $recItem.applicantsGroupSP   #applicantsGroupSP
	

	#>
	$listItem.Update()      
	$ctx.load($list)      
	$ctx.executeQuery()  
	Write-Host "Item Added with ID - " $listItem.Id  		
	
}
function get-deadline($arcUrl,$arcApplList){
	$siteUrl = get-UrlNoF5 $arcUrl
	$Ctxa = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctxa.Credentials = $Credentials
			  
			#Get the List
			
	$ListAppl = $Ctxa.Web.lists.GetByTitle($arcApplList)
	$Ctxa.Load($ListAppl)
	$ctxa.ExecuteQuery()
	$field = $ListAppl.Fields.GetByTitle("deadline")
	$Ctxa.Load($field)
	$ctxa.ExecuteQuery()
	##$ctx.ExecuteQuery();	

	$defValueT = [datetime]$field.DefaultValue
	#write-host "Default value: $defValueT"
	#$field.DefaultValue = $defValueT # $spObj.deadline;
	return $defValueT

	
}
function Get-ArchiveTitleDesc($itemObj){
	$siteUrl = get-UrlNoF5 $itemObj.ArchiveURL
	
	$Ctx1 = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx1.Credentials = $Credentials
	
	$web = $Ctx1.Web
	
	$Ctx1.Load($web)
	$Ctx1.ExecuteQuery()
	
	$aTitDesc = "" | Select Title,Description
	$aTitDesc.Title = $web.Title
	$archString = "⟰ Archive ⟰: "
	if (!$aTitDesc.Title.Contains($archString)){
		$aTitDesc.Title = $archString + $web.Url.Split("/")[-1].Replace("Archive-","")+" : "+$web.Title
	}

	$aTitDesc.Description = $web.Description
	return $aTitDesc
}
function Get-ArchiveSiteID($itemObj){
	$siteUrl = get-UrlNoF5 $itemObj.SiteUrl
	$archList = $itemObj.ArchiveList
	$relUrl  = $itemObj.relativeURL
	
	$retValID = 0

	$Ctx1 = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx1.Credentials = $Credentials
			  
			#Get the List
			
	$ListArc = $Ctx1.Web.lists.GetByTitle($archList)
	
	$Query = New-Object Microsoft.SharePoint.Client.CamlQuery
	$qry =  "<View><Query><Where><Eq><FieldRef Name='relativeURL' /><Value Type='Text'>$relUrl</Value></Eq></Where></Query></View>"
	$Query.ViewXml = $qry


	$SPListItemCollection = $ListArc.GetItems($Query)
	$Ctx1.Load($SPListItemCollection)
	$Ctx1.ExecuteQuery()

			foreach($lstItem in $SPListItemCollection){
				$deadl     = $lstItem["deadline"]
				$dt = $itemObj.applDeadline
				$noTimedl1 = Get-Date -Year $dt.Year -Month $dt.Month -Day $dt.Day -Hour 0 -Second 0 -Minute 0 -Millisecond 0
				$noTimedl2 = Get-Date -Year $deadl.Year -Month $deadl.Month -Day $deadl.Day -Hour 0 -Second 0 -Minute 0 -Millisecond 0
				#$curDeadl  = $deadl.AddMonths(-2)
				#$curDeadlMax = $deadl.AddMonths(2)
				#Write-Host 23 $curDeadlMin
				#Write-Host 24 $curDeadlMax
				#Write-Host $query.Query
				
				if ($noTimedl1 -eq $noTimedl2){
					#write-Host 31 $lstItem["url"]
					#write-Host 32 $lstItem["deadline"]
					$retValID = [int]$lstItem.ID
					#Write-Host 34 $retValID
					
					break
					
				}	
			}


	
	return $retValID
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

$xyzObj = @()
$xmlConfigFile = "\\ekeksql00\SP_Resources$\WP_Config\availableXYZListPath\availableXYZListPath.xml"
$xmlFile = Get-Content $xmlConfigFile -raw
$isXML = [bool](($xmlFile) -as [xml])
if ($isXML){
	$xmlDoc = [xml]$xmlFile
	$configXYZList = $xmlDoc.SelectNodes("//application")
	foreach($elXYZ in $configXYZList){
		$xyzItem = "" | Select listName, archListName
		$xyzItem.listName = $elXYZ.listName
		$xyzItem.archListName = $elXYZ.archListName
		$addToxyz = $true
		ForEach($iXYZ in $xyzObj){
			if ($xyzItem.listName -eq $iXYZ.listName){
				$addToxyz = $false
				break
			}
		}
		if ($addToxyz){
			$xyzObj +=$xyzItem 
		}
	}
	
	

}


$Credentials = get-SCred	

$siteSPSupport = "https://portals.ekmd.huji.ac.il/home/huca/spSupport"
$urlSPSupport = get-UrlNoF5 $siteSPSupport
$listSPRequest = "availableArchives"


$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteSPSupport)
#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
$Ctx.Credentials = $Credentials
		  
		#Get the List
		
$List = $Ctx.Web.lists.GetByTitle($listSPRequest)

$Query = New-Object Microsoft.SharePoint.Client.CamlQuery
$qry = "<View><Query><Where><Eq><FieldRef Name='status' /><Value Type='Choice'>0 - חדש</Value></Eq></Where></Query></View>"
$qry = "<View><Query><Where><Eq><FieldRef Name='SiteCleaned' /><Value Type='Boolean'>1</Value></Eq></Where></Query></View>"
$Query.ViewXml = $qry

#Get All List Items matching the query
$ListItems = $List.GetItems($Query)
$Ctx.Load($ListItems)
$Ctx.ExecuteQuery()


$i=0
$arcObj = @()
$idx = 1
$dateNeeded = Get-Date "2023-03-01Z21:00:00"

foreach($listItem in $listItems)
{
	if ($listItem["CleanDate"] -lt $dateNeeded){
		continue
	}
	if ($listItem.ID -eq 28){
		continue
	}
	if (![string]::IsNullOrEmpty($listItem["availableListURL"])){
		
		#$avlList = [string]$listItem["availableListURL"].Split(",")[0]
		$avlList = $listItem["availableListURL"]
		$sUri =  [System.Uri]$avlList.Url
        
		if (![string]::IsNullOrEmpty($sUri.Host)){
			$sItem = "" | Select logMihzurID, SiteUrl, FullUrl, List,ArchiveList,ArchiveID,ArchiveURL,destinationList,applDeadline, Id ,
			Title,url,ScholarshipName,mailSuffix,adminGroup,alertdate,template,folderName,language,applicantsGroup,sort1,recommendationsDeadline,isCreated,SiteTitle,SiteDescription,AdminPermissions,GlobalAapplicantGroup,TargetAudiences,ScholarshipStartDate,mailContactDeleted,contactEMail,contactPhone,relativeURL,docType,adminGroupSP,applicantsGroupSP
			$sItem.logMihzurID = $listItem.ID
			$sItem.FullUrl = $sUri
			$sItem.List = $sUri.Segments[3].Replace("/","")
			$sItem.SiteUrl = "https://"+$sUri.Host+$sUri.Segments[0]+$sUri.Segments[1]
			if ($sItem.List -eq "Lists"){
				$sItem.List = $sUri.Segments[4].Replace("/","")
				$sItem.SiteUrl = "https://"+$sUri.Host+$sUri.Segments[0]+$sUri.Segments[1]+$sUri.Segments[2]
			}
			$sItem.Id   = [int]$($sUri.Query.Split("=")[1])
			foreach($xyzItem in $xyzObj){
				if ($xyzItem.listName.ToUpper() -eq $sItem.List.ToUpper()){
					$sItem.ArchiveList = $xyzItem.archListName
					break					
				}
			}
			if (![string]::IsNullOrEmpty($sItem.ArchiveList)){
				$arcObj+=$sItem
			}
			
		}
		

		
	}
}


$jsonFileName = "Json\xyz-Archive.json"
$xyzObj | ConvertTo-Json -Depth 100 | out-file $jsonFileName
write-host "Json File $jsonFileName was Created"
Write-Host "Press any key..."
Read-Host


foreach ($arcItem in $arcObj){
	if (![string]::IsNullOrEmpty($arcItem.ArchiveList)){
		$siteXYZ = get-UrlNoF5 $arcItem.SiteUrl
		
		$listXYZ = $arcItem.List
		$idXYZ  = $arcItem.ID
		#Write-Host $siteXYZ
		#Write-Host $listXYZ
		#Write-Host $idXYZ
		
		$CtxArc = New-Object Microsoft.SharePoint.Client.ClientContext($siteXYZ)
		#$CtxArc.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
		$CtxArc.Credentials = $Credentials
			  
		#Get the List
			
		$ListArc = $CtxArc.Web.lists.GetByTitle($listXYZ)
		$CtxArc.Load($ListArc)
		$CtxArc.ExecuteQuery()

		$xyzarcItem = $ListArc.GetItemById($idXYZ)
		$CtxArc.Load($xyzarcItem)
		$CtxArc.ExecuteQuery()

		# -------------------------------------------
		
		#$arcItem.ScholarshipName = $xyzarcItem["ScholarshipName"] #ScholarshipName
		$arcItem.language = $xyzarcItem["language"] #language

		# !!!
		$arcItem.sort1 = ([Microsoft.SharePoint.Client.FieldLookupValue]$xyzarcItem["sort1"]).LookupId #sort1
		
		$arcItem.relativeURL = $xyzarcItem["relativeURL"] #relativeURL
		$arcItem.template = $xyzarcItem["template"] #template
		$arcItem.folderName = $xyzarcItem["folderName"] #folderName
		$arcItem.docType = $xyzarcItem["docType"] #docType
		$arcItem.mailSuffix = $xyzarcItem["mailSuffix"] #mailSuffix
		$arcItem.adminGroup = $xyzarcItem["adminGroup"] #adminGroup
		$arcItem.adminGroupSP = $xyzarcItem["adminGroupSP"] #adminGroupSP
		$arcItem.AdminPermissions = $xyzarcItem["AdminPermissions"] #AdminPermissions
		$arcItem.applicantsGroup = $xyzarcItem["applicantsGroup"] #applicantsGroup
		$arcItem.GlobalAapplicantGroup = $xyzarcItem["GlobalAapplicantGroup"] #GlobalAapplicantGroup
		$arcItem.recommendationsDeadline = $xyzarcItem["recommendationsDeadline"] #recommendationsDeadline
		$arcItem.isCreated = $xyzarcItem["isCreated"] #isCreated

		#!!!
		$arcItem.TargetAudiences = $xyzarcItem["Target_x0020_Audiences"] #Target Audiences


		$arcItem.url = $xyzarcItem["url"] #url
		$arcItem.ScholarshipStartDate = $xyzarcItem["ScholarshipStartDate"] #ScholarshipStartDate
		$arcItem.mailContactDeleted = $xyzarcItem["mailContactDeleted"] #mailContactDeleted
		$arcItem.alertdate = $xyzarcItem["alert_x0020_date"] #alert date
		$arcItem.contactEMail = $xyzarcItem["contactEMail"] #contactEMail
		$arcItem.contactPhone = $xyzarcItem["contactPhone"] #contactPhone
		$arcItem.applicantsGroupSP = $xyzarcItem["applicantsGroupSP"] #applicantsGroupSP

		# -------------------------------------------

		$arcItem.ArchiveURL = $xyzarcItem["Archive_URL"].Url
		$arcItem.destinationList = $xyzarcItem["destinationList"]
		if ($arcItem.ArchiveURL -eq "https://scholarships.ekmd.huji.ac.il/home/Medicine/MED186-2019/Archive-2022-12-13"){
			$arcItem.destinationList = "applicants2020"
		}
		$arcItem.ArchiveURL = $(get-UrlWithF5 $arcItem.ArchiveURL)
		#Write-Host 162 $arcItem.ArchiveURL
		#Write-Host 163 $arcItem.destinationList
		$arcItem.applDeadline = get-deadline $arcItem.ArchiveURL $arcItem.destinationList
		$arcItem.ArchiveID = Get-ArchiveSiteID $arcItem
		$titlDescr = Get-ArchiveTitleDesc $arcItem
		
		$arcItem.SiteTitle = $titlDescr.Title #SiteTitle
		$arcItem.SiteDescription = $titlDescr.Description #SiteDescription
		$arcItem.Title = $titlDescr.Title #Title
		$arcItem.ScholarshipName = $titlDescr.Title #Title
		#Write-Host $arcItem.deadline
		

	}
	
	
}

$jsonFileName = "Json\arcObj-Archive.json"
$arcObj | ConvertTo-Json -Depth 100 | out-file $jsonFileName
write-host "Json File $jsonFileName was Created"


write-host "Press any key"
Read-Host

forEach($itemArc in $arcObj){
	$sUrl  = $itemArc.SiteUrl
	$aList = $itemArc.ArchiveList
	
	if ($itemArc.ArchiveID -eq 0){
		New-ItemArchive $sUrl $aList $itemArc
			
	}
	else
	{
		#Edt-ItemArchive $sUrl $aList $itemArc
		#break	
	}
}

$jsonFileName = "Json\Copy-ArcList.json"
$arcObj | ConvertTo-Json -Depth 100 | out-file $jsonFileName
write-host "Json File $jsonFileName was Created"

$csvFileName = "Json\Copy-ArcList.csv"
$arcObj | Export-Csv -Delimiter "," -Encoding UTF8 -NoTypeInfo $csvFileName
write-host "Json File $csvFileName was Created"






