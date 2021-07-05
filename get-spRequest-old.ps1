param([string] $groupName = "")

$wrkSite 		=  "https://portals.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace"
$productionSite =  "https://hss.ekmd.huji.ac.il/home"

$userName = "ekmd\ashersa"
$userPWD = "GrapeFloor789"


function Get-GroupTemplate($groupName){
	$retValue = ""
	if ([string]::isNullOrEmpty($groupName))
	{
		return $retValue
	}
	if ($groupName.contains("_")){
	
		# last element
		$retValue = $groupName.split("_")[-1]
	}
	return $retValue
}

function Get-GroupSuffix($groupName){
	$groupSuffix = ""
	$groupTemplate = get-GroupTemplate($groupName)
	# write-host $groupTemplate
	# suffix 
	if ($groupTemplate.Length -gt 0){
		$rSuffix       = $groupName.Replace($groupTemplate,"")
	}
	else
	{
		$rSuffix = $groupName
	}
	
	if ($rSuffix.contains("_")){
		if (![string]::isNullOrEmpty($rSuffix)){
			$groupSuffix   = $rSuffix.Substring(0,$rSuffix.Length -1)
		}
	}
	else
	{
		$groupSuffix = $rSuffix
	}
	return $groupSuffix
	
}

function Test-CurrentSystem($groupName){
	$groupSuffix = Get-GroupSuffix $groupName

	$availSystems =  Get-AvailableSystems
	
	$curSystemExists = $false
	
	foreach($systm in $availSystems){
		if ($systm.GroupPrefix.ToUpper() -eq $groupSuffix){
			$curSystemExists = $true
			break
		}
	}
	
	return $curSystemExists	
}

function Get-CurrentSystem($groupName){
	
	$groupSuffix = Get-GroupSuffix $groupName

	$availSystems =  Get-AvailableSystems
	
	$curSystem = "" | select appHomeUrl,appTitle,listName,runRemovePermissions,runConfirmRecommendations,GroupPrefix,isImplemented
	
	foreach($systm in $availSystems){
		if ($systm.GroupPrefix.ToUpper() -eq $groupSuffix){
			return $systm
		}
	}
	
	return $curSystem
}

function Test-AllSystems()
{

	$userName  = "ekmd\ashersa"
	$userPWD   = "GrapeFloor789"
	
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"


    $allSystems = Get-AvailableSystems
	
	foreach($system in $allSystems)
	{
		write-host
		write-host $($system.appTitle)
		write-host $($system.appHomeUrl+"lists/"+$system.listName)
		
		$SiteURL  = $system.appHomeUrl
		$ListName = $system.listName
		#Setup the context
		$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
		$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
		  
		#Get the List
		
		$List = $Ctx.Web.lists.GetByTitle($ListName)
		 
		#Define the CAML Query
		$Query = New-Object Microsoft.SharePoint.Client.CamlQuery
		$qry = "<View><RowLimit>1</RowLimit><Query><OrderBy><FieldRef Name='ID' Ascending='False' /></OrderBy></Query> </View>"
		$Query.ViewXml = $qry

		#Get All List Items matching the query
		$ListItems = $List.GetItems($Query)
		$Ctx.Load($ListItems)
		$Ctx.ExecuteQuery()
		
		$i=0
		foreach($listItem in $listItems)
		{
			Write-Host "ID - " $listItem["ID"] "Title - " $listItem["Title"] 
			$i++
			if ($i -gt 9){
				break
			}
		}
		
		
	}
	


	
}

function Get-AvailableSystems(){
	
	$availableSystems = @()

    # ===============--------- GSS  ------------==========
	
	$system = "" | select appHomeUrl,appTitle,listName,runRemovePermissions,runConfirmRecommendations,GroupPrefix,isImplemented
	
	$system.appHomeUrl = "https://gss.ekmd.huji.ac.il/home/"
	$system.appTitle   = "HUJI Grant Submission System"
	$system.listName   = "availableGssList"
	$system.runRemovePermissions = $true
	$system.runConfirmRecommendations = $false
	$system.GroupPrefix = "GSS"
	$system.isImplemented = $false
	
	$availableSystems += $system

    # ===============--------- HSS  ------------==========
	
	$system = "" | select appHomeUrl,appTitle,listName,runRemovePermissions,runConfirmRecommendations,GroupPrefix,isImplemented
	
	$system.appHomeUrl = "https://hss.ekmd.huji.ac.il/home/"
	$system.appTitle   = "HUJI Scholarships System"
	$system.listName   = "availableScholarshipsList"
	$system.runRemovePermissions = $false
	$system.runConfirmRecommendations = $false
	$system.GroupPrefix = "HSS"
	$system.isImplemented = $true
	
	
	$availableSystems += $system

    # ===============--------- SEP  ------------==========

	
	$system = "" | select appHomeUrl,appTitle,listName,runRemovePermissions,runConfirmRecommendations,GroupPrefix,isImplemented
	
	$system.appHomeUrl = "https://sep.ekmd.huji.ac.il/home/"
	$system.appTitle   = "HUJI Student Exchange Program"
	$system.listName   = "availableSEPList"
	$system.runRemovePermissions = $true
	$system.runConfirmRecommendations = $true
	$system.GroupPrefix = "SEP"
	$system.isImplemented = $false	

	$availableSystems += $system	

    # ===============--------- GRS  ------------==========

	$system = "" | select appHomeUrl,appTitle,listName,runRemovePermissions,runConfirmRecommendations,GroupPrefix,isImplemented
	
	$system.appHomeUrl = "https://grs.ekmd.huji.ac.il/home/"		
	$system.appTitle   = "HUJI Studies Registration System"
	$system.listName   = "availableGRSList"
	$system.runRemovePermissions = $true
	$system.runConfirmRecommendations = $true
	$system.GroupPrefix = "GRS"
	$system.isImplemented = $false
	
	$availableSystems += $system	

    # ===============--------- PORTALS  ------------==========
	

	$system = "" | select appHomeUrl,appTitle,listName,runRemovePermissions,runConfirmRecommendations,GroupPrefix,isImplemented

	$system.appHomeUrl = "https://portals.ekmd.huji.ac.il/home/tap/"
	$system.appTitle   = "HUJI Teaching Assistant Positions"
	$system.listName   = "availableSitesList"
	$system.runRemovePermissions = $false
	$system.runConfirmRecommendations = $false
	$system.GroupPrefix = "PRT_TAP"
	$system.isImplemented = $false	

	$availableSystems += $system	

    # ===============--------- TTP  ------------==========


	$system = "" | select appHomeUrl,appTitle,listName,runRemovePermissions,runConfirmRecommendations,GroupPrefix,isImplemented

	$system.appHomeUrl = "https://ttp.ekmd.huji.ac.il/home/"
	$system.appTitle   = "HUJI Tenure Track Positions System"
	$system.listName   = "availablePositionsList"
	$system.runRemovePermissions = $true
	$system.runConfirmRecommendations = $true
	$system.GroupPrefix = "TTP"
	$system.isImplemented = $false	

	$availableSystems += $system	

    # ===============--------- TSS  ------------==========

	$system = "" | select appHomeUrl,appTitle,listName,runRemovePermissions,runConfirmRecommendations,GroupPrefix,isImplemented

	$system.appHomeUrl = "https://tss.ekmd.huji.ac.il/home/"
	$system.appTitle   = "HUJI Thesis Submission System"
	$system.listName   = "availableTSSList"
	$system.runRemovePermissions = $true
	$system.runConfirmRecommendations = $false
	$system.GroupPrefix = "TSS"
	$system.isImplemented = $false	

	$availableSystems += $system	
    # ===============---------   ------------==========
	
	
	return $availableSystems

}



function CheckPreviousSiteDestinationList()
{
	# if in Prev. site declaration in field 
	# destinationList have two values i.e. "applicants;relatives"
	# in Destination site have to change this value as in previuos
	
	
	return $true
}

function Change-GroupDescription ($groupName, $description){
	
	$wildcardGroupName = $groupName+"*"
	$filterStr = 'name -like "'+$wildcardGroupName+'"'
	
	$groups = Get-ADGroup -Filter $filterStr | Set-ADGroup -Description $description
	
}

function Test-ScholarShipItemExist ($ListObj){

	
	$templateName = $ListObj.RelURL
	write-host $templateName

	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($ListObj.systemURL)  
	$ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$listName=$ListObj.systemListName
	$List = $Ctx.Web.lists.GetByTitle($listName)
	Write-Host "Looking for $templateName in site:$($ListObj.systemURL), List:$($listName)"
	
	#Define the CAML Query
	$scholarShipQuery = New-Object Microsoft.SharePoint.Client.CamlQuery
	
	$qry = "<View><Query><Where><Eq><FieldRef Name='template' /><Value Type='Text'>"+$templateName+"</Value></Eq></Where></Query></View>"
	#$qry = "<View><Query></Query></View>"
	#write-host $qry
	$scholarShipQuery.ViewXml = $qry
	
	$ListItems = $List.GetItems($scholarShipQuery)
	$Ctx.Load($ListItems)
	$Ctx.ExecuteQuery()
	
	write-Host "Counts: $($ListItems.Count)"
		
	$scholarShipList = @()	
	
	#return $true
	
	return $($ListItems.Count -eq 0)
}

function Get-FacultyId($faculty, $facultyList){
	
	$retValue = ""
	
	for($i=0; $i -lt $facultyList.count; $i++){
		if ($facultyList[$i].SiteDescription.toUpper() -eq $faculty.ToUpper()){
			# write-Host $faculty, $facultyList[$i].Id
			
			$retValue = $facultyList[$i].Id
			break
		}
	}
	return $retValue
}

function Get-FacultyList($wrkSite){
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($wrkSite)  
	$ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$ListName="Faculty"
	$List = $Ctx.Web.lists.GetByTitle($ListName)
	
	#Define the CAML Query
	$facultyQuery = New-Object Microsoft.SharePoint.Client.CamlQuery
	
	$qry = "<View><Query></Query></View>"

	$facultyQuery.ViewXml = $qry

	#Get All List Items matching the query
	$ListItems = $List.GetItems($facultyQuery)
	$Ctx.Load($ListItems)
	$Ctx.ExecuteQuery()
	
	$facultyList = @()

	ForEach($Item in $ListItems)
	{ 

		$facultyListItem = "" | Select Id, Title, Code, SiteURL, SiteDescription,  displayTitle, displayOrder, displayTitleHe, displayOrderHe  
		
		$facultyListItem.Id				= $Item.id
		$facultyListItem.Title 			= $Item["Title"]
		$facultyListItem.Code 			= $Item["Code"]
		$facultyListItem.SiteURL 		= $Item["SiteURL"].Url
		$facultyListItem.SiteDescription= $Item["SiteURL"].Description
		$facultyListItem.displayTitle 	= $Item["displayTitle"]
		$facultyListItem.displayOrder 	= $Item["displayOrder"]
		$facultyListItem.displayTitleHe = $Item["displayTitleHe"]
		$facultyListItem.displayOrderHe = $Item["displayOrderHe"]
		
		$facultyList += $facultyListItem
	}

	return $facultyList	
	
}

function Add-SiteList($ListObj, $facultyList)
{
	$SiteURLXX  = $ListObj.systemURL
	$ListNameXX = $ListObj.systemListName
	
	
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURLXX)  
	$ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	
	
	
	write-host "Adding Item to site $SiteURLXX to List $ListNameXX" -foregroundcolor Green
	write-host $($ListObj.systemListUrl) -foregroundcolor Green
	
	
	

	try{  
		$lists = $ctx.web.Lists  
		$list = $lists.GetByTitle($ListNameXX)  
		$listItemInfo = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation  
		$listItem = $list.AddItem($listItemInfo)  
		$listItem["Title"] = $ListObj.siteName 
		
		# get Title from facultyList
		#$t = Get-FacultyTitle $ListObj.faculty $facultyList
		# write-host $t
		
		$listItem["sort1"] = Get-FacultyId $ListObj.faculty $facultyList
		
		
		$listItem["adminGroup"] = $ListObj.adminGroup
		$listItem["applicantsGroupSP"] = $ListObj.applicantsGroupSP		
		$listItem["relativeURL"] = $ListObj.relURL
		$listItem["template"] = $ListObj.relURL
		$listItem["language"] = $ListObj.language
		$listItem["adminGroupSP"] = $ListObj.adminGroupSP
		$listItem["adminGroupSP"] = $ListObj.adminGroupSP
		
		if ($ListObj.language -eq "He"){
			$listItem["folderName"] = [char][int]1492 + [char][int]1506 + [char][int]1500 + [char][int]1488 + [char][int]1514 + [char][int]32 + [char][int]1502 + [char][int]1505 + [char][int]1502 + [char][int]1499 + [char][int]1497 + [char][int]1501 + ' -'
			$listItem["docType"] = [char][int]1514 + [char][int]1493 + [char][int]1499 + [char][int]1503 + [char][int]32 + [char][int]1511 + [char][int]1493 + [char][int]1489 + [char][int]1509
		}
		
		if ($ListObj.language -eq "En"){
		
			$listItem["docType"] = "Document Type"
			$listItem["folderName"] = "Documents Upload"
		}
		
		$listItem["mailSuffix"] = $ListObj.mailSuffix
		$listItem["applicantsGroup"] = $ListObj.applicantsGroup
		$listItem["deadline"] = $ListObj.deadline.AddYears(-1)
		$listItem["recommendationsDeadline"] = $ListObj.deadline
		$listItem["SiteTitle"] = $ListObj.siteName
		$listItem["ScholarshipName"] = $ListObj.siteName
		$listItem["SiteDescription"] = $ListObj.siteNameEn
		$listItem["isCreated"] = "Waiting"
		$listItem["Target_x0020_Audiences"] = $ListObj.targetAudiency  # ";" + $ListObj.targetAudiencysharepointGroup
		
		$listItem.Update()      
		$ctx.load($list)      
		$ctx.executeQuery()  
		Write-Host "Item Added with ID - " $listItem.Id      
	}  
	catch{  
		write-host "$($_.Exception.Message)" -foregroundcolor red  
	}  
}

function Write-TextConfig ($ListObj, $groupName)
{
	$crlf = [char][int]13+[char][int]10

	$itemCount = $ListObj.count
	if ($itemCount -eq 1){
		#generate file
		
		$fName = $($groupName+".txt")
		$relURL = $groupName.ToUpper().Split("_")[1]
		
		$fileS =  $crlf + $crlf + "GROUP TEMPLATE:"+ $relURL + $crlf + $crlf 
		$fileS += "Assigned Group: "+ $ListObj[0].assignedGroup + $crlf
		$fileS += "Site Name:"+$ListObj[0].siteName + $crlf
		$fileS += "Site Title:"+$ListObj[0].siteName + $crlf
		$fileS += "Site Description:"+$ListObj[0].siteNameEn + $crlf
		$fileS += "Group Description:"+$ListObj[0].siteNameEn + $crlf
		$fileS += "Previous Site:"+$ListObj[0].Notes + $crlf
		$fileS += "Url:" + $crlf
		$fileS += "ContactFirstName:" +  $ListObj[0].contactFirstNameEn+ $crlf
		$fileS += "ContactLastName:"+  $ListObj[0].contactLastNameEn+ $crlf
		$fileS += "ContactTitle:" + $ListObj[0].contactFirstNameEn+ " " +$ListObj[0].contactLastNameEn+ $crlf
		$fileS += "ContactTitle:" + $ListObj[0].contactFirstNameEn+ " " +$ListObj[0].contactLastNameEn+ $crlf
		$fileS += "ContactEmail:" + $ListObj[0].contactEmail + $crlf
		$fileS += "UserName:" + "CC\"+$ListObj[0].contactEmail.split('@')[0] + $crlf
		$fileS += "recommendationsDeadline:" + $ListObj[0].deadline.month+"/"+$ListObj[0].deadline.day+"/"+$ListObj[0].deadline.year + $crlf
		$fileS += "Language:" + $ListObj[0].language + $crlf
		$fileS += "relative URL:" + $relURL + $crlf
		$fileS += "template:" + $relURL + $crlf
		$fileS += "mail suffix:" + $ListObj[0].mailSuffix + $crlf
		$fileS += "admin group:" + $ListObj[0].adminGroup + $crlf
		$fileS += "adminGroupSP:" + $ListObj[0].adminGroupSP + $crlf
		$fileS += "applicantsGroup:" + $ListObj[0].applicantsGroup + $crlf
		$fileS += "Target audience:" + $ListObj[0].targetAudiency+ $crlf
		
		$fileS += "Sharepoint Group:" + $ListObj[0].targetAudiencysharepointGroup + $crlf
		$fileS += "Distribution Security Group:" + $ListObj[0].targetAudiencyDistributionSecurityGroup + $crlf+ $crlf

        
        $fileS += "Faculty:"  + $ListObj[0].faculty + $crlf
		$fileS += "Rights for Admin:" + $ListObj[0].RightsforAdmin + $crlf
		$fileS += "XML:" +  $ListObj[0].XMLFile+ $crlf
		$fileS += "Email Template:" +  $ListObj[0].MailFile+ $crlf+ $crlf
		$fileS += "Prev XML Form:" +   $ListObj[0].PreviousXML +  $crlf
		$fileS += "Prev Email Template:" +   $ListObj[0].PreviousMail +  $crlf
		
		$fileS | Out-File $fName -Encoding UTF8
		
		write-Host "File $fName sucessfully saved. " -foregroundcolor yellow
	}
	else
	{
		Write-host "No Group $groupName found or too many groups." -foregroundcolor yellow
		Write-host "Group count : $itemCount" -foregroundcolor yellow
	}	
}

function GetPrevXML ($Notes){
	if ([string]::isNullOrEmpty($Notes)){
		return ""
	}
	else
	{
		If ($Notes.toLower().contains("https://")){
			
			$urlArr = $Notes.split("/")
			# write-Host $urlArr
			if ($urlArr.Count -ge 6)
			{
				return $($urlArr[5]+".xml").toUpper()
			}
			else
			{
				return ""
			}
		}
		else
		{
			return ""
		}	
	}
}

function GetPrevMAIL ($Notes)
{
	if ([string]::isNullOrEmpty($Notes)){
		return ""
	}
	else
	{
		If ($Notes.toLower().contains("https://")){
			
			$urlArr = $Notes.split("/")
			# write-Host $urlArr
			if ($urlArr.Count -ge 6)
			{
				return $($urlArr[5]+"-mail.txt").toUpper()
			}
			else
			{
				return ""
			}
		}
		else
		{
			return ""
		}	
	}
}

if ([string]::isNullOrEmpty($groupName))
{
	write-host groupName Must be specified 
	write-host in format hss_HUM164-2021 
	
}
else
{

	#Load SharePoint CSOM Assemblies

	$crlf = [char][int]13+[char][int]10
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
	  
	#Set parameter values
	$SiteURL="https://portals.ekmd.huji.ac.il/home/huca/committees/SPProjects2017/"
	  
	#Get Credentials to connect
	#$Cred= Get-Credential
	   
	#Setup the context
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
	#$Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)
	$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	
	if (Test-CurrentSystem $groupName){  
		#Get the List
		$ListName="spRequestsList"
		$List = $Ctx.Web.lists.GetByTitle($ListName)
		 
		#Define the CAML Query
		$Query = New-Object Microsoft.SharePoint.Client.CamlQuery
		$qry = "<View><Query></Query></View>"
		$Query.ViewXml = $qry

		#Get All List Items matching the query
		$ListItems = $List.GetItems($Query)
		$Ctx.Load($ListItems)
		$Ctx.ExecuteQuery()

		$currentSystem = Get-CurrentSystem $groupName
		$currentList = $currentSystem.appHomeUrl + "lists/"+$currentSystem.listName
		$isImplemented = $currentSystem.isImplemented


		 
		#Loop through each List Item
		$spRequestsListObj = @()

		ForEach($Item in $ListItems)
		{ 
			$aGroup = $Item["assignedGroup"]
			if (![string]::isNullOrEmpty($aGroup)){
				if ($aGroup.ToUpper() -eq $groupName.ToUpper()){
					$spRequestsListItem = "" | Select ID, RelURL, Status,adminGroup, adminGroupSP, assignedGroup, applicantsGroup,targetAudiency, targetAudiencysharepointGroup, targetAudiencyDistributionSecurityGroup, Notes, Title, contactFirstNameEn, contactLastNameEn , contactEmail, userName,mailSuffix, contactPhone, system, systemCode, siteName, siteNameEn, faculty, publishingDate, deadline, language, folderLink, XMLFile, MailFile, PreviousXML, PreviousMail, RightsforAdmin, systemURL, systemListUrl, systemListName
					#Write-host $Item.id, $Item["status"],$Item["contactLastNameEn"],$Item["assignedGroup"]
					#Write-host $Item.count 
					$relURL = Get-GroupTemplate $groupName
					$groupSuffix =  Get-GroupSuffix $groupName
					
					$spRequestsListItem.ID = $Item.id
					$spRequestsListItem.relURL = $relURL
					
					$spRequestsListItem.Status = $Item["status"]
					$spRequestsListItem.adminGroup = $groupSuffix +"_"+ $relURL + "_AdminUG"
					$spRequestsListItem.adminGroupSP =$groupSuffix +"_"+ $relURL + "_AdminSP"
					$spRequestsListItem.assignedGroup = $groupName
					$spRequestsListItem.Notes = $Item["notes"]
					$spRequestsListItem.PreviousXML = GetPrevXML $spRequestsListItem.Notes
					$spRequestsListItem.PreviousMail = GetPrevMAIL $spRequestsListItem.Notes
					$spRequestsListItem.XMLFile =  $relURL + ".xml"
					$spRequestsListItem.MailFile = $relURL + "-mail.txt"
					$spRequestsListItem.mailSuffix = $groupSuffix.toUpper() +"-"+ $relURL
					$spRequestsListItem.applicantsGroup = $groupSuffix +"_"+ $relURL + "_applicantsUG"
					$spRequestsListItem.targetAudiency = "EkccUG" 
					$spRequestsListItem.targetAudiencysharepointGroup = $groupSuffix +"_"+ $relURL + "_AdminSP; hss_" + $relURL + "_JudgesSP"
					$spRequestsListItem.targetAudiencyDistributionSecurityGroup = $groupSuffix +"_"+ $relURL + "_JudgesUG"
					$spRequestsListItem.language = $Item["language"]
					if ($spRequestsListItem.language.toUpper() -eq "EN"){
						
						$spRequestsListItem.Title =  $Item["siteNameEn"]
						$spRequestsListItem.siteName = $Item["siteNameEn"]
						
					}
					else
					{
						$spRequestsListItem.Title = $Item["Title"]
						$spRequestsListItem.siteName = $Item["siteName"]
						
					}	
					$spRequestsListItem.siteNameEn = $Item["siteNameEn"]	
					
					
					$spRequestsListItem.contactFirstNameEn = $Item["contactFirstNameEn"]
					$spRequestsListItem.contactLastNameEn = $Item["contactLastNameEn"]
					$spRequestsListItem.contactLastNameEn = $Item["contactLastNameEn"]
					$spRequestsListItem.contactEmail = $Item["contactEmail"]
					$spRequestsListItem.userName = "CC\"+$spRequestsListItem.contactEmail.split('@')[0]
					
					$spRequestsListItem.contactPhone = $Item["contactPhone"]
					$spRequestsListItem.system = $Item["system"]
					$spRequestsListItem.systemCode = $Item["systemCode"]
					
					
					
					$spRequestsListItem.faculty = $Item["faculty"]
					$spRequestsListItem.publishingDate = $Item["publishingDate"]
					$spRequestsListItem.deadline = $Item["deadline"]
					
					$spRequestsListItem.folderLink =  ($Item["folderLink"]).Url
					$spRequestsListItem.RightsforAdmin = "ekccUG; "+$groupSuffix +"_"+ $relURL + "_adminSP;"+$groupSuffix +"_" +$relURL + "_judgesSP"
					$spRequestsListItem.systemListUrl = $currentList
					$spRequestsListItem.systemURL = $currentSystem.appHomeUrl
					$spRequestsListItem.systemListName = $currentSystem.listName
					
					$spRequestsListObj += $spRequestsListItem
				}
			}
			
		}
		$itemCount = $spRequestsListObj.count

		if ($itemCount -eq 1){
			
			if (Test-ScholarShipItemExist $spRequestsListObj[0] ){
				

				Write-Host "CurrentSystem: $($currentSystem.appTitle)" -foregroundcolor Yellow
				Write-Host "CurrentList: $currentList" -foregroundcolor Yellow
				Write-Host "Implemented: $isImplemented" -foregroundcolor Yellow
				
				
				$facultyList = Get-FacultyList $($currentSystem.appHomeUrl)
				
				#write-Host $facultyList
				
				Write-TextConfig $spRequestsListObj $groupName
				$spRequestsListObj | ConvertTo-Json -Depth 100 | out-file $($groupName+".json")
				Add-SiteList $spRequestsListObj[0] $facultyList
				Change-GroupDescription $groupName $spRequestsListObj[0].siteNameEn
			}
			else
			{
				write-Host "$groupName already exists in $($($spRequestsListObj[0]).systemListUrl)." -foregroundcolor Yellow
				write-Host "No items were added." -foregroundcolor Yellow
			}
		}
		else
		{
			Write-Host "Group $groupName not found in spRequestsList." -foregroundcolor Yellow
		}
	}
	else
	{
		Write-Host "Group Name $groupname is not valid!"
	}
	
}
