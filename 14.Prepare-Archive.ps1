function New-ItemFromArchive( $siteUrl,$listName, $recItem){
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
	$listItem["deadline"] = $recItem.deadline   #deadline
	$listItem["recommendationsDeadline"] = $recItem.recommendationsDeadline   #recommendationsDeadline
	$listItem["SiteTitle"] = $recItem.SiteTitle   #SiteTitle
	$listItem["SiteDescription"] = $recItem.SiteDescription   #SiteDescription
	$listItem["isCreated"] = $recItem.isCreated  #isCreated

	#!!!
	$listItem["Target_x0020_Audiences"] = $recItem.TargetAudiences   #Target Audiences


	$listItem["url"] = $recItem.url  #url
	#$listItem["ScholarshipStartDate"] = $recItem.ScholarshipStartDate   #ScholarshipStartDate
	#$listItem["mailContactDeleted"] = $recItem.mailContactDeleted   #mailContactDeleted
	#$listItem["alert_x0020_date"] = $recItem.alertdate   #alert date
	#$listItem["contactEMail"] = $recItem.contactEMail  #contactEMail
	#$listItem["contactPhone"] = $recItem.contactPhone   #contactPhone
	$listItem["destinationList"] = $recItem.destinationList   #destinationList
	$listItem["applicantsGroupSP"] = $recItem.applicantsGroupSP   #applicantsGroupSP
	$listItem["Archive_Waiting_for_Archivation"] = $true

	#>
	$listItem.Update()      
	$ctx.load($list)      
	$ctx.executeQuery()  
	Write-Host "Item Added with ID - " $listItem.Id  		
	
}
function Remove-ItemFromArchive($siteUrl,$listName,$ItemID){
	
	$siteName = get-UrlNoF5 $siteUrl
	#write-host 53 $siteName $listName $ItemID
	#read-host
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials
	$List = $Ctx.Web.lists.GetByTitle($listName)
	$ListItem = $List.GetItemById($ItemID)
    $ListItem.DeleteObject()
    $Ctx.ExecuteQuery()
 
    Write-Host "List Item $ItemID Deleted from $listName successfully!" -ForegroundColor Green

}
function Get-AvailFromArchive($siteUrl,$listName,$recID){
	$recItem = "" | Select Title,url,ScholarshipName,mailSuffix,adminGroup,deadline,alertdate,template,folderName,language,applicantsGroup,sort1,recommendationsDeadline,isCreated,SiteTitle,SiteDescription,AdminPermissions,GlobalAapplicantGroup,TargetAudiences,ScholarshipStartDate,mailContactDeleted,contactEMail,contactPhone,destinationList,relativeURL,docType,adminGroupSP,applicantsGroupSP
	$siteName = get-UrlNoF5 $siteUrl
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials
	$List = $Ctx.Web.lists.GetByTitle($listName)
		 
		#Define the CAML Query
	$Query = New-Object Microsoft.SharePoint.Client.CamlQuery
	

	$qry = "<View><Query><Where><Eq><FieldRef Name='ID' /><Value Type='Counter'>$recID</Value></Eq></Where></Query></View>"
	$Query.ViewXml = $qry


	$ListItems = $List.GetItems($Query)
	$Ctx.Load($ListItems)
	$Ctx.ExecuteQuery()
	
	$itmsCnt = $ListItems.Count
	
	
	if ($itmsCnt -eq 1){
	
		ForEach($fitm in $ListItems){

			$recItem.Title = $fitm["Title"] #Title
			$recItem.ScholarshipName = $fitm["ScholarshipName"] #ScholarshipName
			$recItem.language = $fitm["language"] #language

			# !!!
			$recItem.sort1 = ([Microsoft.SharePoint.Client.FieldLookupValue]$fitm["sort1"]).LookupId #sort1
			
			$recItem.relativeURL = $fitm["relativeURL"] #relativeURL
			$recItem.template = $fitm["template"] #template
			$recItem.folderName = $fitm["folderName"] #folderName
			$recItem.docType = $fitm["docType"] #docType
			$recItem.mailSuffix = $fitm["mailSuffix"] #mailSuffix
			$recItem.adminGroup = $fitm["adminGroup"] #adminGroup
			$recItem.adminGroupSP = $fitm["adminGroupSP"] #adminGroupSP
			$recItem.AdminPermissions = $fitm["AdminPermissions"] #AdminPermissions
			$recItem.applicantsGroup = $fitm["applicantsGroup"] #applicantsGroup
			$recItem.GlobalAapplicantGroup = $fitm["GlobalAapplicantGroup"] #GlobalAapplicantGroup
			$recItem.deadline = $fitm["deadline"] #deadline
			$recItem.recommendationsDeadline = $fitm["recommendationsDeadline"] #recommendationsDeadline
			$recItem.SiteTitle = $fitm["SiteTitle"] #SiteTitle
			$recItem.SiteDescription = $fitm["SiteDescription"] #SiteDescription
			$recItem.isCreated = $fitm["isCreated"] #isCreated

			#!!!
			$recItem.TargetAudiences = $fitm["Target_x0020_Audiences"] #Target Audiences


			$recItem.url = $fitm["url"] #url
			$recItem.ScholarshipStartDate = $fitm["ScholarshipStartDate"] #ScholarshipStartDate
			$recItem.mailContactDeleted = $fitm["mailContactDeleted"] #mailContactDeleted
			$recItem.alertdate = $fitm["alert_x0020_date"] #alert date
			$recItem.contactEMail = $fitm["contactEMail"] #contactEMail
			$recItem.contactPhone = $fitm["contactPhone"] #contactPhone
			$recItem.destinationList = $fitm["destinationList"] #destinationList
			$recItem.applicantsGroupSP = $fitm["applicantsGroupSP"] #applicantsGroupSP
			break;
			
		}
	}
	
	return $recItem
}
function get-AvaibListX($oldSiteURL){
	$sObj = "" | Select Url, List, ArchList, GroupPrefix
	$tSiteName = get-UrlWithF5 $oldSiteURL
	$siteUri =  [System.Uri]$tSiteName
	$availSystems = Get-AvailableSystems	
	
    foreach($system in $availSystems){
		if ($system.workLink.ToLower().Contains($siteUri.Host.ToLower())){
			$sObj.Url = $system.appHomeUrl
			$sObj.List = $system.listName
			$sObj.ArchList = $system.archListName
			$sObj.GroupPrefix = $system.GroupPrefix
			break
		}
	}	
	return $sObj
}
function Change-spRequestsListStatus($spID){
	$siteName = "https://portals.ekmd.huji.ac.il/home/huca/spSupport"
	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials
	$List = $Ctx.Web.lists.GetByTitle("spRequestsList")
	$ListItem = $List.GetItemById($spID)
	#$listItem["status"] = "1 - בביצוע"
	$listItem["status"] = "1.1 - ארכיון תוכנן"

	#>
	$listItem.Update()      
	$ctx.load($list)      
	$ctx.executeQuery()  
	
    return $null
 
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
$qry = "<View><Query><Where><Eq><FieldRef Name='status' /><Value Type='Choice'>0 - חדש</Value></Eq></Where></Query></View>"
$qry = "<View><Query><Where><Or><Eq><FieldRef Name='status' /><Value Type='Choice'>0 - חדש</Value></Eq><Eq><FieldRef Name='status' /><Value Type='Choice'>1 - בביצוע</Value></Eq></Or></Where></Query></View>"
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
        $sUri =  [System.Uri]$listItem["currentSiteUrl"]
		if (![string]::IsNullOrEmpty($sUri.Host)){
			$sItem = "" | Select Index, ID, Title,TitleEn, OldUrl,availURL,availList, availID
			$sItem.Index = $idx
			$sItem.ID = $listItem.ID
			$sItem.Title = $listItem["siteName"]
			$sItem.TitleEn = $listItem["siteNameEn"]
			$sItem.OldUrl = get-SiteNameFromNote $listItem["currentSiteUrl"]
			
			$oldSitesObj.Add($sItem) | out-null
			$idx++
		}	
	}
}
if ($oldSitesObj.Count -gt 0){
	write-host "OldSites found." -f Green
	write-host "Please choose old site you want to Archive by Index (1,2,...)" -f Green
	write-host "Index SiteURL"
	write-host "----- -----"
	foreach($st in $oldSitesObj){
		
		write-host " " $st.Index " " $st.OldUrl 
	}
	write-host "Choose Index :" -f Yellow -noNewLine
	$continue = read-host 
	$choice = $null	
	$siteURLRepair = ""
	$siteTitleEn = ""
	$siteTitle = ""
	$sitePureTitle = ""
	$spItemId = 0 

	$availbList = ""
	$availbUrl = ""
	$availbID = 0
	
	if (($continue.length -eq 1) -and ("123456789".contains($continue))){
		foreach($st in $oldSitesObj){
			if ($st.Index.ToString() -eq $continue){
				$choice = $continue
				$siteTitleEn = $st.TitleEn
				$spItemId = $st.ID
				$siteTitle = Reverse-HebString $st.Title
				$sitePureTitle =  $st.Title
				$availbList = $st.availList
				$availbUrl = $st.availURL
				$availbID = $st.availID
				$choice = $continue
				$siteURLRepair =  $st.OldUrl
				break
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
		
		write-host $attnEn  -f Yellow
		write-host $attnHeb  -f Green
		write-host $attnHeb  -f Yellow
		write-host $attnHeb  -f Yellow
		#write-host $spItemId  -f Yellow
		write-host 
		write-host "==============================="  -f Yellow
		write-host 
		
		write-host "This procedure Prepare site for archive."  -f Cyan
		write-host "If you not AWARE. Press CTRL^C to exit."  -f Yellow

	
		write-host "On Site: $siteURLRepair"  -f Yellow
		write-host "=====================" -foregroundcolor Cyan
		write-host "groupName: $groupName" -foregroundcolor Magenta
		write-host "=====================" -foregroundcolor Cyan

		write-host "Site Title: $siteTitle"  -f Cyan
		write-host "Site Description: $siteTitleEn"  -f Cyan
		write-host 

		write-host 
		write-host "Are you sure to continue  [Y/n]?" -noNewLine -f Yellow
		$continue = read-host 
		$ctx=$null	
		$sucess = $false
		if (($continue.length -eq 1) -and ([int][char]$continue -eq 89)){
		
			
			$oldSiteURL = get-UrlNoF5 $siteURLRepair
			
			write-host "Old Site: $oldSiteURL" -foregroundcolor Cyan
			
			$availSystem = Get-AvaibListX $oldSiteURL
			if ([string]::IsNullOrEmpty($availSystem.Url)){
				write-host "Not Found System for Site $oldSiteURL" -f Yellow
			}
			else
			{
				$relUrl   = get-RelURL $oldSiteURL
				$grRelURL = $relUrl.split("/")[-2]
				$prepare = $true
				$availListId = Get-AvailListRecord $availSystem.Url  $availSystem.List $grRelURL $prepare
				$isMoveNeed = $false
				$availUrl = ""
				$availList = ""
				$moveFromList = ""
				
				if ($availListId -eq 0){
					write-host "Site not found in " $availSystem.List -f Yellow
					if (![string]::IsNullOrEmpty($availSystem.ArchList)){
						write-host "Looking for in " $availSystem.ArchList -f Yellow
						$prepare = $false
						#  flag prepare:  indicate that check field 
						# "Archive_Waiting_for_Archivation"  or not
						$availListId = Get-AvailListRecord $availSystem.Url  $availSystem.ArchList $grRelURL $prepare
						$isMoveNeed = $true
						$availUrl = $availSystem.Url
						$availList = $availSystem.List
						$moveFromList = $availSystem.ArchList
						
					}
					if ($availListId -eq 0)
					{
					
						write-host "Site not found in System " $availSystem.Url " !"-f Yellow
					}
				}
				else
				{
					$availUrl = $availSystem.Url
					$availList = $availSystem.List
					$sucess = $true
				}
				
				#write-host $availUrl
				#write-host $availList
				#write-host $availListId
				if ($isMoveNeed -and ($availListId -ne 0)){
					write-host "Move Needed from : " $moveFromList
					$arcItem = Get-AvailFromArchive $availSystem.Url  $availSystem.ArchList $availListId
					$arcItem.mailSuffix = $availSystem.GroupPrefix + "-" +$arcItem.template.Split("-")[0]
					$arcItem.adminGroup = $availSystem.GroupPrefix + "_" +$arcItem.template+"_AdminUG"
					$arcItem.adminGroupSP = $availSystem.GroupPrefix + "_" +$arcItem.template+"_AdminSP"
					$arcItem.applicantsGroup = $availSystem.GroupPrefix + "_" +$arcItem.template+"_applicantsUG"
					$arcItem.siteTitle    = $sitePureTitle
					$arcItem.Title       = $sitePureTitle
					$arcItem.ScholarshipName    = $sitePureTitle
					$arcItem.SiteDescription = $siteTitleEn
					
					#$arcItem
					
					New-ItemFromArchive $availSystem.Url  $availSystem.List $arcItem
					Remove-ItemFromArchive $availSystem.Url  $availSystem.ArchList $availListId
					$sucess = $true
					#$arcItem
				}
				

				
				
			}
			
			 
				
		}
		if ($sucess){
			$groupName = get-GroupName $siteURLRepair
			$spRequestsListObj = $null
					

			$spRequestsListObj = get-RequestListObject $spItemId
			Save-spRequestsFileAttachements $spRequestsListObj[0]
			$spRequestsListObj | ConvertTo-Json -Depth 100 | out-file $("JSON\"+$groupName+".json")
			Log-Generate $spRequestsListObj $siteURLRepair
			$isMihzur = $true
			$oldSiteTitleMihzur = Get-SiteTitle $siteURLRepair		
			
			Write-TextConfig $spRequestsListObj $groupName $isMihzur
			
			Change-spRequestsListStatus $spItemId
			write-host "Site prepeared to Archive." -f Green
			write-host "All done." -f Green
		}
		
	}	
}
else
{
	Write-Host "No New sites found. " -f Yellow
}

