
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
	
	$curSystem = "" | Select-Object appHomeUrl,appTitle,listName,runRemovePermissions,runConfirmRecommendations,GroupPrefix,isImplemented
	
	foreach($systm in $availSystems){
		if ($systm.GroupPrefix.ToUpper() -eq $groupSuffix){
			return $systm
		}
	}
	
	return $curSystem
}

function Test-AllSystems()
{

	#$userName  = "ekmd\ashersa"
	#$userPWD   = ""
	
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
		#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
		$Ctx.Credentials = $Credentials
		  
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
	
	$system = "" | select appHomeUrl,appTitle,listName,runRemovePermissions,runConfirmRecommendations,workLink,GroupPrefix,App,isImplemented,NameEn,NameHe
	
	$system.appHomeUrl = "https://gss.ekmd.huji.ac.il/home/"
	$system.workLink   = "https://gss2.ekmd.huji.ac.il"
	$system.appTitle   = "HUJI Grant Submission System"
	$system.listName   = "availableGssList"
	$system.runRemovePermissions = $true
	$system.runConfirmRecommendations = $false
	$system.GroupPrefix = "GSS"
	$system.App = "מענקים"
	$system.isImplemented = $false
	$system.NameEn = ""
	$system.NameHe = ""
	
	
	$availableSystems += $system

    # ===============--------- HSS  ------------==========
	
	$system = "" | select appHomeUrl,appTitle,listName,runRemovePermissions,runConfirmRecommendations,workLink,GroupPrefix,App,isImplemented,NameEn,NameHe
	
	$system.appHomeUrl = "https://hss.ekmd.huji.ac.il/home/"
	$system.workLink   = "https://scholarships2.ekmd.huji.ac.il"
	$system.appTitle   = "HUJI Scholarships System"
	$system.listName   = "availableScholarshipsList"
	$system.runRemovePermissions = $false
	$system.runConfirmRecommendations = $false
	$system.GroupPrefix = "HSS"
	$system.App = "מלגות"
	$system.isImplemented = $true
	$system.NameEn = ""
	$system.NameHe = ""
	
	
	
	$availableSystems += $system

    # ===============--------- SEP  ------------==========

	
	$system = "" | select appHomeUrl,appTitle,listName,runRemovePermissions,runConfirmRecommendations,workLink,GroupPrefix,App,isImplemented,NameEn,NameHe
	
	$system.appHomeUrl = "https://sep.ekmd.huji.ac.il/home/"
	$system.workLink   = "https://sep2.ekmd.huji.ac.il"
	$system.appTitle   = "HUJI Student Exchange Program"
	$system.listName   = "availableSEPList"
	$system.runRemovePermissions = $true
	$system.runConfirmRecommendations = $true
	$system.GroupPrefix = "SEP"
	$system.App = "חילופי סטודנטים וסגל"
	$system.isImplemented = $false
	$system.NameEn = ""
	$system.NameHe = ""
	

	$availableSystems += $system	

    # ===============--------- GRS  ------------==========

	$system = "" | select appHomeUrl,appTitle,listName,runRemovePermissions,runConfirmRecommendations,workLink,GroupPrefix,App,isImplemented,NameEn,NameHe
	
	$system.appHomeUrl = "https://grs.ekmd.huji.ac.il/home/"		
	$system.workLink   = "https://grs2.ekmd.huji.ac.il"		
	$system.appTitle   = "HUJI Studies Registration System"
	$system.listName   = "availableGRSList"
	$system.runRemovePermissions = $true
	$system.runConfirmRecommendations = $true
	$system.GroupPrefix = "GRS"
	$system.App = "הרשמה ללימודים"
	$system.isImplemented = $false
	$system.NameEn = ""
	$system.NameHe = ""
	
	
	$availableSystems += $system	

    # ===============--------- PORTALS  ------------==========
	

	$system = "" | select appHomeUrl,appTitle,listName,runRemovePermissions,runConfirmRecommendations,workLink,GroupPrefix,App,isImplemented,NameEn,NameHe

	$system.appHomeUrl = "https://portals.ekmd.huji.ac.il/home/tap/"
	$system.workLink   = "https://portals2.ekmd.huji.ac.il"
	$system.appTitle   = "HUJI Teaching Assistant Positions"
	$system.listName   = "availableSitesList"
	$system.runRemovePermissions = $false
	$system.runConfirmRecommendations = $false
	$system.GroupPrefix = "PRT_TAP"
	$system.App = "משרות תרגול"
	$system.isImplemented = $false	
	$system.NameEn = ""
	$system.NameHe = ""
	

	$availableSystems += $system	

    # ===============--------- TTP  ------------==========


	$system = "" | select appHomeUrl,appTitle,listName,runRemovePermissions,runConfirmRecommendations,workLink,GroupPrefix,App,isImplemented,NameEn,NameHe

	$system.appHomeUrl = "https://ttp.ekmd.huji.ac.il/home/"
	$system.workLink   = "https://ttp2.ekmd.huji.ac.il"
	$system.appTitle   = "HUJI Tenure Track Positions System"
	$system.listName   = "availablePositionsList"
	$system.runRemovePermissions = $true
	$system.runConfirmRecommendations = $true
	$system.GroupPrefix = "TTP"
	$system.App = "משרות אקדמיות"
	$system.isImplemented = $false
	$system.NameEn = ""
	$system.NameHe = ""
	

	$availableSystems += $system	

    # ===============--------- TSS  ------------==========

	$system = "" | select appHomeUrl,appTitle,listName,runRemovePermissions,runConfirmRecommendations,workLink,GroupPrefix,App,isImplemented,NameEn,NameHe

	$system.appHomeUrl = "https://tss.ekmd.huji.ac.il/home/"
	$system.workLink   = "https://tss2.ekmd.huji.ac.il"
	$system.appTitle   = "HUJI Thesis Submission System"
	$system.listName   = "availableTSSList"
	$system.runRemovePermissions = $true
	$system.runConfirmRecommendations = $false
	$system.GroupPrefix = "TSS"
	$system.App = "עבודות גמר"
	$system.isImplemented = $false	
	$system.NameEn = ""
	$system.NameHe = ""

	$availableSystems += $system	
    # ===============---------AAP------------==========


	$system = "" | select appHomeUrl,appTitle,listName,runRemovePermissions,runConfirmRecommendations,workLink,GroupPrefix,App,isImplemented,NameEn,NameHe

	$system.appHomeUrl = "https://aap.ekmd.huji.ac.il/home/"
	$system.workLink   = "https://aap2.ekmd.huji.ac.il"
	$system.appTitle   = "HUJI Appointments and Promotions System"
	$system.listName   = "availableAAPList"
	$system.runRemovePermissions = $false
	$system.runConfirmRecommendations = $false
	$system.GroupPrefix = "AAP"
	$system.App = "עבודות גמר"
	$system.isImplemented = $false	
	$system.NameEn = ""
	$system.NameHe = ""

	$availableSystems += $system	
    # ===============---------   ------------==========
		
	
	return $availableSystems

}

function get-GrpByUrl($Url){
	$siteName = get-UrlWithF5 $Url
	$aSite    = $siteName.Split("/")
	$mainName = $($aSite[0] +"/" + $aSite[1] +"/"+ $aSite[2]).toLower()
	#write-host  $mainName
	$grpSfx   = $aSite[5]
	
	$aSystems = Get-AvailableSystems
	$grp = ""
	foreach($system in $aSystems){
		
		$xSiteName = $system.workLink.toLower()
		#write-host $xSiteName
		if ($xSiteName -eq $mainName){
			$grp = $system.GroupPrefix + "_" + $grpSfx
			#write-Host $grp
			break
		}
	}
	
	return $grp
	
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
function Change-AdmGroupsFromOld($groupName,$oldSiteName){
	# Copy members from group
	If (![string]::isNullOrEmpty($oldSiteName)){
		$newAdmGroup = $groupName + "_AdminUG"
		$oldAdmGroup = get-GrpByUrl $oldSiteName
		$oldAdmGroup = $oldAdmGroup + "_AdminUG"
		write-Host "Copy AD members from $oldAdmGroup to $newAdmGroup" -foregroundcolor Yellow
		$members = Get-ADGroupMember -Identity $oldAdmGroup
		Add-ADGroupMember -Identity $newAdmGroup -Members $members
	}	
}
<#

#$members = Get-ADGroupMember -Identity hss_MED229-2020_adminUG
#Add-ADGroupMember -Identity HSS_MED249-2021_AdminUG -Members $members

#>
function Add-GroupMember($groupName, $email, $userName){
	
	$admGroupName = $groupName+"_AdminUG"
	if ($email.contains("savion.huji.ac.il")){
		$user = $userName.Substring(3)
		$usrObj =  Get-ADuser -Filter 'CN -like $user' -Properties * -Server hustaff.huji.local
		Add-ADGroupMember -Identity $admGroupName -Members $usrObj
		write-host "User $userName was added to AD Group $admGroupName" -foregroundcolor Green
	}
	else
	{
		# EKMD ?
		$result=Get-ADuser -Filter 'mail -like $email' -Properties SamAccountName
		if (![string]::IsNullOrEmpty($result.SamAccountName)){
			$usrObj =  Get-ADuser $result.SamAccountName
			Add-ADGroupMember -Identity $admGroupName -Members $usrObj
			write-host "User $($usrObj.SamAccountName) was added to AD Group $admGroupName" -foregroundcolor Green
			
		}
		else
		{
		
			write-host "User $userName was NOT added to AD Group $admGroupName" -foregroundcolor Yellow
		}
		
	}
}

function Test-ScholarShipItemExist ($ListObj){

	
	$templateName = $ListObj.RelURL
	write-host $templateName

	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($ListObj.systemURL)  
	#$ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$ctx.Credentials = $Credentials
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
		#if ($facultyList[$i].SiteDescription.toUpper() -eq $faculty.ToUpper()){
		if ($facultyList[$i].displayTitle.toUpper() -eq $faculty.ToUpper()){
			# write-Host $faculty, $facultyList[$i].Id
			
			$retValue = $facultyList[$i].Id
			break
		}
	}
	return $retValue
}

function get-FacultyTitle($groupName, $faculty){

	$currentSystem = Get-CurrentSystem $groupName
	$facultyList = Get-FacultyList $($currentSystem.appHomeUrl)
	
	$facultyNames = "" | Select-Object TitleEn, TitleHe
	$facultyNames.TitleEn = ""
	$facultyNames.TitleHe = ""
	
	#write-host $faculty
	
	#foreach($item in $facultyList){
	#	write-Host $item
	#}
	
	
	
	foreach($item in $facultyList)
	{
		
		#if (![string]::isNullOrEmpty($item.SiteDescription)){
		if (![string]::isNullOrEmpty($item.displayTitle)){
			
			#if ($item.SiteDescription.toUpper() -eq $faculty.ToUpper()){
			if ($item.displayTitle.toUpper() -eq $faculty.ToUpper()){
				$facultyNames.TitleEn =  $item.displayTitle
				$facultyNames.TitleHe =  $item.displayTitleHe
				break
			}
		}
	}
	
	if ([string]::isNullOrEmpty($facultyNames.TitleEn) -or 
		[string]::isNullOrEmpty($facultyNames.TitleHe)){
		Write-Host "Faculty '$faculty' not found in Faculty List" -f Yellow
		Write-Host "item.SiteDescription = '$($item.SiteDescription)'" -f Yellow
		Write-Host "facultyNames.TitleEn = '$($facultyNames.TitleEn)'" -f Yellow
		Write-Host "facultyNames.TitleHe = '$($facultyNames.TitleHe)'" -f Yellow
	}
	#write-host $facultyNames
	#read-host
	return $facultyNames
}

function Get-FacultyList($wrkSite){
	#write-host Before
	#write-Host $wrkSite
	#read-host
	#write-host After
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($wrkSite)  
	#$ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$ctx.Credentials = $Credentials
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
		if (![string]::isNullOrEmpty($Item["SiteURL"].Url)){

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
	}

	return $facultyList	
	
}

function Add-SiteList($ListObj, $facultyList)
{
	$SiteURLXX  = $ListObj.systemURL
	$ListNameXX = $ListObj.systemListName
	
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURLXX)  
	#$ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$ctx.Credentials = $Credentials
	
	write-host "Adding Item to site $(get-UrlWithF5 $SiteURLXX) to List $ListNameXX" -foregroundcolor Green
	write-host $(get-UrlWithF5 $ListObj.systemListUrl) -foregroundcolor Green
	

	try{  
		$lists = $ctx.web.Lists  
		$list = $lists.GetByTitle($ListNameXX)  
		$listItemInfo = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation  
		$listItem = $list.AddItem($listItemInfo)  
		$listItem["Title"] = $ListObj.siteName 
		
		
		
		$listItem["sort1"] = Get-FacultyId $ListObj.faculty $facultyList
		
		
		$listItem["adminGroup"] = $ListObj.adminGroup
		$listItem["applicantsGroupSP"] = $ListObj.applicantsGroupSP		
		$listItem["relativeURL"] = $ListObj.relURL
		$listItem["template"] = $ListObj.relURL
		#$listItem["language"] = $ListObj.language
		$listItem["adminGroupSP"] = $ListObj.adminGroupSP
		$listItem["adminGroupSP"] = $ListObj.adminGroupSP
		
		#if ($ListObj.language -eq "He"){
			$listItem["folderName"] = [char][int]1492 + [char][int]1506 + [char][int]1500 + [char][int]1488 + [char][int]1514 + [char][int]32 + [char][int]1502 + [char][int]1505 + [char][int]1502 + [char][int]1499 + [char][int]1497 + [char][int]1501 + ' -'
			$listItem["docType"] = [char][int]1514 + [char][int]1493 + [char][int]1499 + [char][int]1503 + [char][int]32 + [char][int]1511 + [char][int]1493 + [char][int]1489 + [char][int]1509
			$listItem["language"] = "He"
		#}
		
		if ($ListObj.language.ToLower().contains("en")){
		
			$listItem["docType"] = "Document Type"
			$listItem["folderName"] = "Documents Upload"
			$listItem["language"] = "En"
		}
		
		$listItem["mailSuffix"] = $ListObj.mailSuffix
		$listItem["applicantsGroup"] = $ListObj.applicantsGroup
		$deadLineDate = $ListObj.deadline.AddYears(-1)
		$today  = Get-Date
		if ($today -lt $deadLineDate){
			$deadLineDate = $deadLineDate.AddYears(-1)
		}
		$listItem["deadline"] = $deadLineDate
		$listItem["recommendationsDeadline"] = $ListObj.deadline
		$listItem["SiteTitle"] = $ListObj.siteName
		$listItem["ScholarshipName"] = $ListObj.siteName
		$listItem["SiteDescription"] = $ListObj.siteNameEn
		$listItem["isCreated"] = "Waiting"
		$listItem["Target_x0020_Audiences"] = $ListObj.targetAudiency  + ";" + $ListObj.targetAudiencysharepointGroup + ";"+ $ListObj.targetAudiencyDistributionSecurityGroup + ";"+ $ListObj.adminGroup
		
		$listItem.Update()      
		$ctx.load($list)      
		$ctx.executeQuery()  
		Write-Host "Item Added with ID - " $listItem.Id      
	}  
	catch{  
		write-host "$($_.Exception.Message)" -foregroundcolor red  
	}  
}
function get-SCred(){
	
	$iniFile =  "$dp0\UserIni.json"	
	$location = Get-Location
	$content = Get-Content -raw $iniFile
	$userObj= $content | ConvertFrom-Json
	
	$regPath = "HKCU:\SOFTWARE\Microsoft\CrSiteAutomate"
	$passw = (Get-ItemProperty -Path $regPath -Name Param).Param | ConvertTo-SecureString
	$UserName = (Get-ItemProperty -Path $regPath -Name Param1).Param1
	write-host "User: $UserName"
	$Crd = New-Object System.Management.Automation.PSCredential ($UserName, $passw)
	set-location $location
	
	return $Crd
	
		
}
function Write-IniFile($InitUser){
	$iniFile =  "$dp0\UserIni.json"
	$ret = $true
	$iniFileExists = Test-Path $iniFile
	#write-Host "Init file  Exists: $iniFileExists"
	#write-host "Init user: $InitUser"
	$cond = $false
	if (!$iniFileExists){
		$cond = $true
	}
	#write-host "1 Cond: $cond"
	if (!$cond){
		#write-host "2 Cond: $cond"
		#write-host "Init user2: $InitUser"
		#write-host $($InitUser.getType())
		if ($InitUser.toLower() -eq "yes")
		{
			#write-host "We are here????"
			$cond = $true	
		}
		#write-host "3 Cond: $cond"
	}
	#write-host "4 Cond: $cond"
	#write "Ini Exists -or Init : $cond"
	$hiveNotExists = checkHiveNotExists
	if ($cond -or $hiveNotExists)
	{
		$location = Get-Location
		write-host "First need to create ini file": -foregroundcolor Yellow
		Write-Host "Enter UserName in domain ekmd:" -NoNewline  -foregroundcolor Yellow
		$UserName = Read-Host
		Write-Host "Enter Password:" -NoNewline -foregroundcolor Yellow
		$passw = Read-Host  -AsSecureString
		
		
		$userObj = "" | Select-Object UserName,Password
		$userObj.UserName = $UserName
		$userObj.Password = $passw | ConvertFrom-SecureString
		
		$regPath = "HKCU:\SOFTWARE\Microsoft\CrSiteAutomate"
		$testReg = Test-Path $regPath
		
		if (!$testReg){
			cd  HKCU:\SOFTWARE\Microsoft\ | out-null
			New-Item  -Name "CrSiteAutomate" | out-null
			New-ItemProperty -Path $regPath -Name "Param" -Value $($userObj.Password)  -PropertyType "String" | out-null
			New-ItemProperty -Path $regPath -Name "Param1" -Value $($userObj.UserName)  -PropertyType "String" | out-null
			
		}
		else{
			Set-Itemproperty -path $regPath -Name 'Param' -value $($userObj.Password) 
			Set-Itemproperty -path $regPath -Name 'Param1' -value $($userObj.UserName) 
		}
		$userObj.UserName = "[UserName]"
		$userObj.Password = "[User Password]"
		
		$userObj | ConvertTo-Json -Depth 100 | out-file $($iniFile)
		
		set-location $location
		Write-Host "INI file was created. Run Script again."
		$ret = $false
			
	}
	return $ret
}
function checkHiveNotExists(){
		$location = Get-Location	
		$regPath = "HKCU:\SOFTWARE\Microsoft\CrSiteAutomate"
		$testReg = Test-Path $regPath		
		set-location $location	

        return 	!$testReg	
		
}
function Write-TextConfig ($ListObj, $groupName)
{
	$crlf = [char][int]13+[char][int]10
	#write-host Before1
    #$ListObj
	#read-host
	#write-host After1
	# $itemCount = $ListObj.count
	if ($ListObj.GroupName.ToUpper() -eq $groupName.ToUpper()){
		#generate file
		$groupSuffix =  Get-GroupSuffix $groupName
		
		$fName = $($groupName+".txt")
		$relURL = $groupName.ToUpper().Split("_")[1]
		
		$fileS =  $crlf + $crlf + "GROUP TEMPLATE:"+ $relURL + $crlf + $crlf 
		$fileS += "System List: "+ $(get-UrlWithF5 $($ListObj[0].systemListUrl)) + $crlf + $crlf
		$fileS += "spRequestsListItem: "+ $(get-UrlWithF5 $($ListObj[0].spRequestsListLink)) + $crlf 
		$fileS += "spRequestsListDocs: "+ $(get-UrlWithF5 $($ListObj[0].spRequestsListDocs)) + $crlf+$crlf+$crlf
		$fileS += "Assigned Group: "+ $ListObj[0].assignedGroup + $crlf
		$fileS += "Site Name: "+$ListObj[0].siteName + $crlf
		$fileS += "Site Title: "+$ListObj[0].siteName + $crlf
		$fileS += "Site Description: "+$ListObj[0].siteNameEn + $crlf
		$fileS += "Group Description: "+$ListObj[0].siteNameEn + $crlf
		$fileS += "Previous Site: "+$ListObj[0].Notes + $crlf
		$fileS += "Url: " + $crlf+ $crlf

		$fileS += "ContactFirstName: " +  $ListObj[0].contactFirstNameEn+ $crlf
		$fileS += "ContactLastName: "+  $ListObj[0].contactLastNameEn+ $crlf
		$fileS += "ContactTitle: " + $ListObj[0].contactFirstNameEn+ " " +$ListObj[0].contactLastNameEn+ $crlf+ $crlf
		
		$fileS += "ContactEmail: " + $ListObj[0].contactEmail + $crlf
		$fileS += "UserName: " + "CC\"+$ListObj[0].contactEmail.split('@')[0] + $crlf
		
		$fileS += "recommendationsDeadline: " + $ListObj[0].deadLineText+ $crlf+ $crlf
		$fileS += "Language: " + $ListObj[0].language.ToUpper() + $crlf+ $crlf
        
		$fileS += "Faculty: "  + $ListObj[0].faculty + $crlf
		
		$fileS += "relative URL: " + $relURL + $crlf+ $crlf
		$fileS += "template: " + $relURL + $crlf+ $crlf
		$fileS += "mail suffix: " + $ListObj[0].mailSuffix + $crlf
		$fileS += "admin group: " + $ListObj[0].adminGroup + $crlf
		$fileS += "adminGroupSP: " + $ListObj[0].adminGroupSP + $crlf
		$fileS += "applicantsGroup: " + $ListObj[0].applicantsGroup + $crlf
		$fileS += "Target audience: " + $ListObj[0].targetAudiency+ $crlf+ $crlf
		$fileS += "Distribution Security Group: " + $ListObj[0].targetAudiencyDistributionSecurityGroup + $crlf+ $crlf
		
		$fileS += "Sharepoint Group: " + $ListObj[0].targetAudiencysharepointGroup + $crlf+ $crlf

        
 		$fileS += "Rights for Admin: " + $ListObj[0].RightsforAdmin + $crlf+ $crlf

		$isDoubleLangugeSite = $($ListObj[0].language).toLower().contains("en") -and $($ListObj[0].language).toLower().contains("he")
		$fileS += "Path: "+$ListObj[0].PathXML+ $crlf
		if ($isDoubleLangugeSite){
			$fileS += "XML En:" +  $ListObj[0].XMLFileEn+ $crlf 
			$fileS += "GoTo XML En: cd " +  $ListObj[0].PathXML + "\" + $ListObj[0].XMLFileEn+ $crlf
			$fileS += "XML He: " +  $ListObj[0].XMLFileHe+ $crlf 
			$fileS += "GoTo XML He: cd " +  $ListObj[0].PathXML + "\" + $ListObj[0].XMLFileHe+ $crlf
			
		}
		else{		
			$fileS += "XML: " +  $ListObj[0].XMLFile+ $crlf 
			$fileS += "GoTo XML: cd " +  $ListObj[0].PathXML + "\" + $ListObj[0].XMLFile+ $crlf
		}

		$fileS += $crlf + $crlf
		#$fileS += "XML Upload Path: " + $ListObj[0].XMLUploadPath + $crlf
		#$fileS += "XML Upload File:" + $ListObj[0].XMLUploadFileName + $crlf
		#$fileS += "Goto XML Upload File: cd " + $ListObj[0].XMLUploadPath + $ListObj[0].XMLUploadFileName + $crlf + $crlf
	
		$fileS += "Email Path: " +  $ListObj[0].MailPath+ $crlf
		$fileS += "Email Template: " +  $ListObj[0].MailFile+ $crlf
		$fileS += "GoTo Email: cd " +  $ListObj[0].MailPath+ "\" + $ListObj[0].MailFile+ $crlf
		if ($isDoubleLangugeSite){
			$fileS += "GoTo Email He: cd " +  $ListObj[0].MailPath+ "\" + $($ListObj[0].MailFile).replace(".xml","-He.xml")+ $crlf		
		}		
		$fileS += $crlf
				
		
		
		$fileS += "Path: "+$ListObj[0].PathXML+ $crlf
		$fileS += "Prev XML Form: " +   $ListObj[0].PreviousXML +  $crlf + $crlf
		$fileS += "Email Path: " +  $ListObj[0].MailPath + $crlf
		$fileS += "Prev Email Template: " +   $ListObj[0].PreviousMail +  $crlf + $crlf
		if ($isDoubleLangugeSite){
			$fileS += "GoTo Template Infrastructure: cd TemplInf\" +   $ListObj[0].assignedGroup +  $crlf+ $crlf
		}
		if (![string]::IsNullOrEmpty($ListObj[0].GRSReponseLetterConfigPath)){
			$fileS += "================  GRS ================"+  $crlf
			$fileS += "GoTo ReponseLetterConfig: cd "+$ListObj[0].GRSReponseLetterConfigPath +  $crlf
			$fileS += "GoTo Old: cd "+$ListObj[0].OldGRSReponseLetterConfigPath +  $crlf
		}
		$fileS += $crlf
		$fileS += 'spRequestsList Attch Files: cd "' +  $ListObj[0].spAttachementsPath +'"'+ $crlf
		$fileS += 'Open: file://' +  $ListObj[0].spAttachementsPath + $crlf+$crlf
		$fileS += "Site Report: file://C:\AdminDir\SP Powershell\Log\"+$ListObj[0].GroupName +  ".html"+$crlf
		$fileS += "Compare Report: file://C:\AdminDir\SP Powershell\Log\"+$ListObj[0].GroupName +  "-CompareSites.html"+$crlf
		
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
function Get-OldSiteSuffix($Notes){
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
				return $($urlArr[5]).toUpper()
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
function Check-ContactEmpty($contactFirstNameEn, $contactLastNameEn, $contactEmail ){
	$ret = $true
	return ([string]::IsNullOrEmpty($contactFirstNameEn) -or
		[string]::IsNullOrEmpty($contactLastNameEn)  -or
		[string]::IsNullOrEmpty($contactEmail))
	
}
function delete-ListItemIfEmpty($newSite, $listName){
	
	$siteUrl = get-UrlNoF5 $newSite

	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
	$Ctx.Credentials = $Credentials
	$List = $Ctx.Web.lists.GetByTitle($listName)	

	#Define the CAML Query
	$Query = New-Object Microsoft.SharePoint.Client.CamlQuery
	$qry = "<View><Query></Query></View>"
	$Query.ViewXml = $qry

	#Get All List Items matching the query
	$ListItems = $List.GetItems($Query)
	$Ctx.Load($ListItems)
	$Ctx.ExecuteQuery()
	
	$listIsEmpty = $true
	$aList = @()
	ForEach($Item in $ListItems){
		$el = "" | Select-Object Id,Title	
		$el.Id = $Item.Id
		$el.Title = $Item["Title"]
        if (!$($el.Title -eq "-")){
			$listIsEmpty = $false
		}
		$aList += $el
		
	}
	#write-Host $($ListItems.count)
    if ($ListItems.count -gt 0)	{
		if ($listIsEmpty){
			foreach($el in $alist){
				write-host "Site: $siteUrl" -foregroundcolor Yellow
				write-host "Delete Items on  $listName." -foregroundcolor Yellow
					
				$listItem = $List.getItemById($el.Id)
				$listItem.DeleteObject()
				$Ctx.ExecuteQuery()
			}
		}
	}
	
}
function Clone-List($newSite, $oldSite, $listName){
	$fieldNamesAdditional = create-ListfromOld	$newSite  $oldSite $listName
	#write-Host $fieldNamesAdditional -f Cyan
	#write-Host 912
	#read-host
	copy-ListOldToNew $newSite $oldSite $listName $fieldNamesAdditional
}
function create-ListfromOld($newSite, $oldSite, $listName)
{
	
	$listExists = Check-ListExists $newSite $listName
	if ($listExists){
		
		delete-ListItemIfEmpty $newSite $listName
	}
	else
	{
		Write-Host "Create List $listName On $newSite" -foregroundcolor Yellow
		Create-List $newSite $listName $listName 
	}
	
	$newListSchema = get-ListSchema $newSite $listName
	$oldListSchema = get-ListSchema $oldSite $listName
	
	
	$schemaDifference = get-SchemaDifference $oldListSchema $newListSchema
	#write-Host 935
	$listObj = Map-LookupFields $schemaDifference $oldSite ""
	$listObj | ConvertTo-Json -Depth 100 | out-file $("JSON\"+$ListName+"-ApplFields.json")
	
	$fieldNamesAdditional = @()
	foreach($fieldObj in  $($listObj.FieldMap)){
		write-Host "fieldObjType: $($fieldObj.Type)" -f Magenta
		if ($fieldObj.Type -eq "Text"){
			write-Host "add-Text" -f Cyan
			#write-host $fieldObj.FieldObj.DisplayName
			add-TextFields $newSite $listName $($fieldObj.FieldObj)
			$fieldNamesAdditional += $fieldObj.FieldObj.DisplayName	
		}
		if ($fieldObj.Type -eq "Choice"){
			write-Host "add-Choice" -f Cyan
			add-ChoiceFields $newSite $listName $($fieldObj.FieldObj);
			$fieldNamesAdditional += $fieldObj.FieldObj.DisplayName
		}
		if ($fieldObj.Type -eq "Lookup"){
			write-Host "add-LookupFields" -f Cyan
			add-LookupFields $newSite $listName $($fieldObj.FieldObj) $($fieldObj.LookupTitle)$fieldNamesAdditional += $fieldObj.FieldObj.DisplayName							
		}
		if ($fieldObj.Type -eq "Boolean"){
			write-Host "add-Boolean" -f Cyan
			add-BooleanFields $newSite $listName $($fieldObj.FieldObj)
			$fieldNamesAdditional += $fieldObj.FieldObj.DisplayName							
		}
		if ($fieldObj.Type -eq "DateTime"){
			write-Host "add-DateTime" -f Cyan
			add-DateTimeFields $newSite $listName $($fieldObj.FieldObj)
			$fieldNamesAdditional += $fieldObj.FieldObj.DisplayName							
		}
		if ($fieldObj.Type -eq "Note"){
			write-Host "add-Note" -f Cyan
			add-NoteFields $newSite $listName $($fieldObj.FieldObj)
			$fieldNamesAdditional += $fieldObj.FieldObj.DisplayName							
		}
		if ($fieldObj.Type -eq "Currency"){
			write-Host "add-Currency" -f Cyan
			add-CurrencyFields $newSite $listName $($fieldObj.FieldObj)
			$fieldNamesAdditional += $fieldObj.FieldObj.DisplayName							
		}
	}	
	return $fieldNamesAdditional
}
function check-DocumentsUploadExists($siteURL, $language){
	$DocumentsUploadExists = $false
	$listName   = "דפים"
	if ($language.ToLower().contains("en")){
		$listName = "Pages"
	}

	$siteUrlNew = get-UrlNoF5 $siteURL
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrlNew)
	$Lists = $Ctx.Web.Lists
	$Ctx.Load($Lists)
	$Ctx.ExecuteQuery()
	$list = $lists.GetByTitle($listName)  

	$Query = New-Object	 Microsoft.SharePoint.Client.CamlQuery
	$qry = "<View><Query></Query></View>"
	$Query.ViewXml = $qry

	#Get All List Items matching the query
	$ListItems = $List.GetItems($Query)
	$Ctx.Load($ListItems)
	$Ctx.ExecuteQuery()		

	ForEach($Item in $ListItems){
		#write-host $Item["Title"]
		if ($($Item["Title"].toLower() -eq "documentsupload") -or
		    $($Item["Title"].toLower() -eq "העלאת מסמכים")){
			$DocumentsUploadExists = $true;break;
		}
	}	
	return $DocumentsUploadExists
}
function copy-ListOldToNew($newSite, $oldSite, $listName, $fieldNamesAdditional){

	$siteUrlNew = get-UrlNoF5 $newSite
	$siteUrlOld = get-UrlNoF5 $oldSite

	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
	
	#$siteUrlOld
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrlOld)
	
	$Ctx.Credentials = $Credentials
	$List = $Ctx.Web.lists.GetByTitle($listName)	

	#Define the CAML Query
	$Query = New-Object Microsoft.SharePoint.Client.CamlQuery
	$qry = "<View><Query></Query></View>"
	$Query.ViewXml = $qry

	#Get All List Items matching the query
	$ListItems = $List.GetItems($Query)
	$Ctx.Load($ListItems)
	$Ctx.ExecuteQuery()
	
	$aListOld = @()

	ForEach($Item in $ListItems){
		$docTypeItem = "" | Select Title
		if (!$([string]::IsNullOrEmpty($fieldNamesAdditional))){
			foreach($addFieldName in $fieldNamesAdditional){
				#Add-Member -InputObject $docTypeItem -TypeName $addFieldName
				#write-Host $addFieldName -f Cyan
				$docTypeItem | Add-Member -MemberType NoteProperty -Name $addFieldName -Value "" -Force
			}
			#$docTypeItem 
			#write-host 1018 
			#read-host
			foreach($addFieldName1 in $fieldNamesAdditional){
				$docTypeItem.$addFieldName1 = $Item[$addFieldName1]
			}
		}
		
		$docTypeItem.Title = $Item["Title"]

		$aListOld += $docTypeItem

	}
	
	<#
	if (!$([string]::IsNullOrEmpty($fieldNamesAdditional))){
		write-Host 963
		foreach($item in $aListOld){
			write-Host $item
		}		
	
		write-Host Pause...
		read-host
	}
	#>
	
	# Write-Host "Adding To Site: $newSite" -foregroundcolor Green 
	$ctx1 = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrlNew)  
	
	$ctx1.Credentials = $Credentials


	$lists = $ctx1.web.Lists  
	$list = $lists.GetByTitle($ListName)

    $ListItems = $List.GetItems($Query)
	$ctx1.Load($ListItems)
	$ctx1.ExecuteQuery()
	$i=0
	if ($ListItems.Count -eq 0){
		write-host "Copying $listName." -foregroundcolor Green
		write-host "Old Site: $oldSite" -foregroundcolor Green
		write-host "New Site: $newSite" -foregroundcolor Green
			
		foreach ($item in $aListOld)	{
			$listItemInfo = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation  
			
			$listItem = $list.AddItem($listItemInfo)  
			$listItem["Title"] = $item.Title
			if (!$([string]::IsNullOrEmpty($fieldNamesAdditional))){
				foreach($addFieldName in $fieldNamesAdditional){
					$listItem[$addFieldName] = $item.$addFieldName
				}
			}
			<#
			
			ERROR
			Exception calling "ExecuteQuery" with "0" argument(s): "Column 'כותרת' does
not exist. It may have been deleted by another user.
			#>
			$listItem.Update()      
			$ctx1.load($list)      
			$ctx1.executeQuery()  
			$i = $i+1	
		}
		Write-Host "Copied $i items."
	}
	else
	{
		Write-Host 
		Write-Host "During Copying: List $listName on site $newSite is not Empty." -foregroundcolor Yellow
		Write-Host "List Was Not Copied."  -foregroundcolor Yellow
		
	}
	
	return $null

	
}
function get-DefaultViewByURL($siteURL,$listUrl){
	$siteUrlC = get-UrlNoF5 $siteUrl
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrlC)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials
	
	$Web = $Ctx.Web
	$ctx.Load($Web)
	$Ctx.ExecuteQuery()
	
	$List = $Web.GetList($listUrl)
	$Ctx.Load($List)
	$Ctx.ExecuteQuery()
   
	$DefaultView = $list.DefaultView
    $Ctx.load($DefaultView) 
    $Ctx.ExecuteQuery()

    $ViewFields = $DefaultView.ViewFields
	$Ctx.load($ViewFields) 
    $Ctx.ExecuteQuery()
	
	return $ViewFields
	
}
function get-ListSchemaByUrl($siteURL,$listUrl){
	$fieldsSchema = @()
	#Write-Host "$siteURL , $listUrl" -f Cyan
	$siteUrlC = get-UrlNoF5 $siteUrl
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrlC)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials
	
	$Web = $Ctx.Web
	$ctx.Load($Web)
	$Ctx.ExecuteQuery()
	
	$List = $Web.GetList($listUrl)
	$Ctx.Load($List)
	$Ctx.ExecuteQuery()
	
    $Ctx.load($List.Fields) 
    $Ctx.ExecuteQuery()	


	foreach($field in $List.Fields){
		# write-host "$($field.Title) : Hidden : $($field.Hidden)"
		if ($field.SchemaXml.Contains('ReadOnly="TRUE"')){
		}
		else{
			if ($field.SchemaXml.Contains('Group="_Hidden"')){
			}
			else{
		
				If (!($field.Hidden -or $field.ReadOnly )){
					$fieldsSchema += $field.SchemaXml
				}
		
			}
		}	
	}	
	
	return $fieldsSchema	
}
function get-ListSchema($siteURL,$listName){
	
	$fieldsSchema = @()
	#write-Host "$siteURL , $listName" -f Cyan
	$siteUrlC = get-UrlNoF5 $siteUrl
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrlC)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials
	
	$List = $Ctx.Web.lists.GetByTitle($ListName)
	
    $Ctx.load($List.Fields) 
    $Ctx.ExecuteQuery()	


	foreach($field in $List.Fields){
		# write-host "$($field.Title) : Hidden : $($field.Hidden)"
		if ($field.SchemaXml.Contains('ReadOnly="TRUE"')){
		}
		else{
			if ($field.SchemaXml.Contains('Group="_Hidden"')){
			}
			else{
		
				If (!($field.Hidden -or $field.ReadOnly )){
					$fieldsSchema += $field.SchemaXml
				}
		
			}
		}	
	}	
	#write-Host 1214
	return $fieldsSchema

}
function get-ApplicantsSchema($siteUrl){
	$fieldsSchema = @()
	
	$siteUrlC = get-UrlNoF5 $siteUrl
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrlC)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials
	$ListName="Applicants"
	$List = $Ctx.Web.lists.GetByTitle($ListName)
	
    $Ctx.load($List.Fields) 
    $Ctx.ExecuteQuery()	


	foreach($field in $List.Fields){
		# write-host "$($field.Title) : Hidden : $($field.Hidden)"
		if ($field.SchemaXml.Contains('ReadOnly="TRUE"')){
		}
		else{
			if ($field.SchemaXml.Contains('Group="_Hidden"')){
			}
			else{
		
				If (!($field.Hidden -or $field.ReadOnly )){
					$fieldsSchema += $field.SchemaXml
				}
		
			}
		}	
	}	
	
	return $fieldsSchema
}
function get-SchemaDifference($scSrc, $scDst){
	# difference между schema source и schema destination. Чего не хватает в destination
	$fieldsSchema = @()	
	$crlf = [char][int]13+[char][int]10
	
	
	$FieldXMLSrc = '<Fields>'+$crlf
	foreach($elSrc in $scSrc){
		$FieldXMLSrc += $elSrc+$crlf
	}
	$FieldXMLSrc += '</Fields>'

	$FieldXMLDst = '<Fields>'+$crlf
	foreach($elDst in $scDst){
		$FieldXMLDst += $elDst+$crlf
	}
	$FieldXMLDst += '</Fields>'

    <#
    $isXMLsrc = [bool]$($FieldXMLSrc -as [xml])
    $isXMLdst = [bool]$($FieldXMLDst -as [xml])
	write-host "Is Source      XML:$isXMLsrc"
	write-host "Is Destination XML:$isXMLdst"
	$FieldXMLDst | out-file "dst.xml" -Encoding Default
	$FieldXMLSrc | out-file "src.xml" -Encoding Default	
	#$sXml = $($FieldXMLSrc -as [xml])
	#>
	
	$sourceFields = Select-Xml -Content $FieldXMLSrc  -XPath "/Fields/Field" | ForEach-Object {
		 $_.Node.DisplayName.Trim().ToLower()
	}
	$destFields = Select-Xml -Content $FieldXMLDst  -XPath "/Fields/Field" | ForEach-Object {
		$_.Node.DisplayName.Trim().ToLower()
	}
	<#
	write-host ================ sourceFields
	write-host $sourceFields
	write-host 
	write-host ================ destFields
	write-host $destFields
	#>
	
	$idx =0
    foreach($srcEl in $sourceFields){
		$fieldExistsInDest = $false
		foreach($dstEl in $destFields){
			if ($srcEl -eq $dstEl){
				$fieldExistsInDest = $true
				break
			}
		}
	    if (!$fieldExistsInDest){
			 #write-Host $srcEl
			 #write-Host "Exists: $fieldExistsInDest"
			 #write-host $scSrc[$idx]
			 
			 #read-host
			 $fieldsSchema += $scSrc[$idx]
		}		
		$idx++
		
	}
	
	return $fieldsSchema	
}
function get-xFieldObjXML($FieldXML,$cType){
	$FieldXMLSrc = '<Fields>'+$FieldXML+'</Fields>'
	$fieldObj = "" | Select-Object DisplayName,Required,Format, Default ,FillInChoice, Choice,EnforceUniqueValues,ShowField, RichText, RichTextMode, IsolateStyles
	
	$isXMLsrc = [bool]$($FieldXMLSrc -as [xml])
	if ($isXMLsrc){
		$DisplayName = Select-Xml -Content $FieldXMLSrc  -XPath "/Fields/Field" | ForEach-Object {
			 $_.Node.DisplayName
		}
		#write-host $DisplayName
		$fieldObj.DisplayName = $DisplayName

		$Required = Select-Xml -Content $FieldXMLSrc  -XPath "/Fields/Field" | ForEach-Object {
			 $_.Node.Required
		}
		#write-host $Required
		$fieldObj.Required = $Required
		
		$EnforceUniqueValues = Select-Xml -Content $FieldXMLSrc  -XPath "/Fields/Field" | ForEach-Object {
			 $_.Node.EnforceUniqueValues
		}
		#write-host $EnforceUniqueValues
		$fieldObj.EnforceUniqueValues = $EnforceUniqueValues
		
					
		if ($cType -eq "Choice"){
			#Write-Host $FieldXMLSrc
			
			$FillInChoice = Select-Xml -Content $FieldXMLSrc  -XPath "/Fields/Field" | ForEach-Object {
			 $_.Node.FillInChoice
			}
			#write-host $Required
			$fieldObj.FillInChoice = $FillInChoice
			
			$Format = Select-Xml -Content $FieldXMLSrc  -XPath "/Fields/Field" | ForEach-Object {
			 $_.Node.Format
			}
			#write-host $Required
			$fieldObj.Format = $Format
			
			$pos1 = $FieldXMLSrc.IndexOf("<Default>")
			if ($pos1 -eq -1){
				$pos1 = $FieldXMLSrc.IndexOf("<CHOICES>")
			}
			$subs1 = $FieldXMLSrc.Substring($pos1)
			#Write-host $subs1
			$pos2 = $subs1.IndexOf("</CHOICES>")
			$subs2 = $subs1.substring(0,$pos2+10)
			#Write-host $subs2
			#$Default = Select-Xml -Content $FieldXMLSrc  -XPath "/Fields/Default" | ForEach-Object {
			# $_.Node.Default
			#}
			$fieldObj.Choice = $subs2		
				
		}
		if ($cType -eq "Note"){
			
			$RichText = Select-Xml -Content $FieldXMLSrc  -XPath "/Fields/Field" | ForEach-Object {
			 $_.Node.RichText
			}
			
			$fieldObj.RichText = $RichText
			

			$RichTextMode = Select-Xml -Content $FieldXMLSrc  -XPath "/Fields/Field" | ForEach-Object {
			 $_.Node.RichTextMode
			}
			
			$fieldObj.RichTextMode = $RichTextMode
			
			
			$IsolateStyles = Select-Xml -Content $FieldXMLSrc  -XPath "/Fields/Field" | ForEach-Object {
			 $_.Node.IsolateStyles
			}
			
			$fieldObj.IsolateStyles = $IsolateStyles
					
			
			
		}
	}
	return $fieldObj
}
function get-ChoiceOption($str){
	$subs2 = ""
	$pos1 = $str.IndexOf("<Default>")
	if ($pos1 -gt 0){
		$subs1 = $str.Substring($pos1)
		#Write-host $subs1
		$pos2 = $subs1.IndexOf("</CHOICES>")
		$subs2 = $subs1.substring(0,$pos2+10)
	}		
	return $subs2		
}
function get-FieldObjXML($FieldXML){
		$FieldXMLSrc = '<Fields>'+$FieldXML+'</Fields>'

        $fieldObj = "" | Select-Object DisplayName,Required,EnforceUniqueValues,ShowField
		
		$DisplayName = Select-Xml -Content $FieldXMLSrc  -XPath "/Fields/Field" | ForEach-Object {
		 $_.Node.DisplayName
		}
		#write-host $DisplayName
		$fieldObj.DisplayName = $DisplayName
		
		$Required = Select-Xml -Content $FieldXMLSrc  -XPath "/Fields/Field" | ForEach-Object {
		 $_.Node.Required
		}
		#write-host $Required
		$fieldObj.Required = $Required
		
		$ShowField = Select-Xml -Content $FieldXMLSrc  -XPath "/Fields/Field" | ForEach-Object {
		 $_.Node.ShowField
		}
		#write-host $ShowField
		$fieldObj.ShowField = $ShowField
		
		$EnforceUniqueValues = Select-Xml -Content $FieldXMLSrc  -XPath "/Fields/Field" | ForEach-Object {
		 $_.Node.EnforceUniqueValues
		}
		#write-host $EnforceUniqueValues
		$fieldObj.EnforceUniqueValues = $EnforceUniqueValues

        return $fieldObj		
}

function Get-FieldXmlType($FieldXML){
		$FieldXMLSrc = '<Fields>'+$FieldXML+'</Fields>'
		$cType = ""
		$isXMLsrc = [bool]$($FieldXMLSrc -as [xml])
		if ($isXMLsrc){
			$cType = Select-Xml -Content $FieldXMLSrc  -XPath "/Fields/Field" | ForEach-Object {
			$_.Node.Type
			}
		}	
        return $cType		
}
function add-TextFields($siteUrl, $listName, $fieldObj){
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
        $NewField = $Fields | where { ($_.Title -eq $($fieldObj.DisplayName))  }
        if($NewField -ne $NULL) 
        {
            Write-host "Column $($fieldObj.DisplayName) already exists in the List!" -f Yellow
        }
        else
        {
			$DisplayName = $fieldObj.DisplayName
			$FldName = $fieldObj.Name
			$IsRequired = $fieldObj.Required
			
			#Define XML for Field Schema
            $FieldSchema = "<Field Type='Text' DisplayName='$DisplayName' Name='$FldName' Required='$IsRequired'  />"
			if([string]::isNullOrEmpty($FldName)){
	            $FieldSchema = "<Field Type='Text' DisplayName='$DisplayName' Required='$IsRequired'  />"

			}
			write-host $FieldSchema
            $NewField = $List.Fields.AddFieldAsXml($FieldSchema,$True,[Microsoft.SharePoint.Client.AddFieldOptions]::AddFieldInternalNameHint)
            $Ctx.ExecuteQuery()   
 
            Write-host "New Column $DisplayName Added to the $listName Successfully!" -ForegroundColor Green 


		
		}
}

function add-BooleanFields($siteUrl, $listName, $fieldObj){
	#write-Host "$siteUrl, $listName, $fieldObj"
	#$read-host
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
        $NewField = $Fields | where { ($_.Title -eq $($fieldObj.DisplayName))  }
        if(($NewField -ne $NULL) -and ($NewField.InternalName -eq $($fieldObj.Name))) 
        {
            Write-host "Column $Name already exists in the List!" -f Yellow
        }
        else
        {
			$DisplayName = $fieldObj.DisplayName
			
			$FldName = $fieldObj.Name
			$IsRequired = $fieldObj.Required
			$DefaultValue="0"
			
            $FieldSchema = "<Field Type='Boolean' DisplayName='$DisplayName' Name='$FldName' Required='$IsRequired'><Default>$DefaultValue</Default></Field>"
			if([string]::isNullOrEmpty($FldName)){
				$FieldSchema = "<Field Type='Boolean' DisplayName='$DisplayName'  Required='$IsRequired'><Default>$DefaultValue</Default></Field>"
				 
			}	
			
			write-host $FieldSchema
            $NewField = $List.Fields.AddFieldAsXml($FieldSchema,$True,[Microsoft.SharePoint.Client.AddFieldOptions]::AddFieldInternalNameHint)
            $Ctx.ExecuteQuery()   
 
            Write-host "New Column $DisplayName Added to the $listName Successfully!" -ForegroundColor Green 


		
		}
}
function add-NoteFields($siteUrl, $listName, $fieldObj){
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
        $NewField = $Fields | where { ($_.Title -eq $($fieldObj.DisplayName))  }
        if($NewField -ne $NULL) 
        {
            Write-host "Column $Name already exists in the List!" -f Yellow
        }
        else
        {
			$DisplayName = $fieldObj.DisplayName
			$FldName     = $fieldObj.Name
			$IsRequired = $fieldObj.Required
			$EnforceUniqueValues = $fieldObj.EnforceUniqueValues
			$RichText = $fieldObj.RichText
			$RichTextMode  =   ""
			$IsolateStyles =   ""
			if (![string]::isNullOrEmpty($RichText)){
				if ($RichText.ToLower() -eq "true"){
					$RichText='RichText="TRUE"'
				}
				else{
					$RichText='RichText="FALSE"'	
				}		
				if (![string]::IsNullOrEmpty($fieldObj.RichTextMode)){
					$RichTextMode  =   " RichTextMode='" +$fieldObj.RichTextMode+"'" 
				}
				if (![string]::IsNullOrEmpty($fieldObj.IsolateStyles)){
					$IsolateStyles =   " IsolateStyles='"+$fieldObj.IsolateStyles+"'"
				}
					
				
			}
			else
			{
				$RichText=''	
			}
			
			$FieldSchema = "<Field Type='Note'  DisplayName='$DisplayName'  Name='$FldName' Required='$IsRequired' $RichText $RichTextMode  $IsolateStyles />"
			if([string]::isNullOrEmpty($FldName)){
				$FieldSchema = "<Field Type='Note'  DisplayName='$DisplayName'  Required='$IsRequired' $RichText $RichTextMode  $IsolateStyles />"
				
			}				
			write-host $FieldSchema
            $NewField = $List.Fields.AddFieldAsXml($FieldSchema,$True,[Microsoft.SharePoint.Client.AddFieldOptions]::DefaultValue)
            $Ctx.ExecuteQuery()   
 
            Write-host "New Column $DisplayName Added to the $listName Successfully!" -ForegroundColor Green 
			
			
		}
	
}
function add-CurrencyFields($siteUrl, $listName, $fieldObj){
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
        $NewField = $Fields | where { ($_.Title -eq $($fieldObj.DisplayName))  }
        if($NewField -ne $NULL) 
        {
            Write-host "Column $Name already exists in the List!" -f Yellow
        }
        else
        {
			$DisplayName = $fieldObj.DisplayName
			$FldName     = $fieldObj.Name
			$IsRequired = $fieldObj.Required
			$EnforceUniqueValues = $fieldObj.EnforceUniqueValues
            
            
            $FieldSchema = "<Field Type='Currency'  DisplayName='$DisplayName' Name='$FldName'  Required='$IsRequired' EnforceUniqueValues='$EnforceUniqueValues'/>"
			if([string]::isNullOrEmpty($FldName)){
				$FieldSchema = "<Field Type='Currency'  DisplayName='$DisplayName' Required='$IsRequired' EnforceUniqueValues='$EnforceUniqueValues'/>"
				
			}					
			write-host $FieldSchema
            $NewField = $List.Fields.AddFieldAsXml($FieldSchema,$True,[Microsoft.SharePoint.Client.AddFieldOptions]::DefaultValue)
            $Ctx.ExecuteQuery()   
 
            Write-host "New Column $DisplayName Added to the $listName Successfully!" -ForegroundColor Green 
			
			
		}
	
}

function add-DateTimeFields($siteUrl, $listName, $fieldObj){
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
        $NewField = $Fields | where { ($_.Title -eq $($fieldObj.DisplayName))  }
        if($NewField -ne $NULL) 
        {
            Write-host "Column $Name already exists in the List!" -f Yellow
        }
        else
        {
			$DisplayName = $fieldObj.DisplayName
			$FldName     = $fieldObj.Name
			$IsRequired = $fieldObj.Required
			$EnforceUniqueValues = $fieldObj.EnforceUniqueValues
            
			#$FieldSchema = "<Field Type='DateTime'  DisplayName='$DisplayName'  Required='$IsRequired' Format='DateOnly' />"
			$FieldSchema = "<Field Type='DateTime'  DisplayName='$DisplayName'  Name='$FldName' Required='$IsRequired' />"
			if([string]::isNullOrEmpty($FldName)){
				$FieldSchema = "<Field Type='DateTime'  DisplayName='$DisplayName' Required='$IsRequired' />"
				
			}			
			write-host $FieldSchema
            $NewField = $List.Fields.AddFieldAsXml($FieldSchema,$True,[Microsoft.SharePoint.Client.AddFieldOptions]::DefaultValue)
            $Ctx.ExecuteQuery()   
 
            Write-host "New Column $DisplayName Added to the $listName Successfully!" -ForegroundColor Green 


		}
	
}
function add-ChoiceFields($siteUrl, $listName, $fieldObj){
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
        $NewField = $Fields | where { ($_.Title -eq $($fieldObj.DisplayName))  }
        if($NewField -ne $NULL) 
        {
            Write-host "Column $Name already exists in the List!" -f Yellow
        }
        else
        {
            $DisplayName = $fieldObj.DisplayName
			$FldName = $fieldObj.Name
			$IsRequired = $fieldObj.Required
			$EnforceUniqueValues = $fieldObj.EnforceUniqueValues
			$Format = $fieldObj.Format
			$Choice = $fieldObj.Choice
 
			#Define XML for Field Schema
            $FieldSchema = "<Field Type='Choice'  DisplayName='$DisplayName' Name='$FldName' Required='$IsRequired' Format='$Format'>$Choice</Field>"
			if([string]::isNullOrEmpty($FldName)){
				$FieldSchema = "<Field Type='Choice'  DisplayName='$DisplayName' Required='$IsRequired' Format='$Format'>$Choice</Field>"
				
			}
			write-host $FieldSchema
            $NewField = $List.Fields.AddFieldAsXml($FieldSchema,$True,[Microsoft.SharePoint.Client.AddFieldOptions]::DefaultValue)
            $Ctx.ExecuteQuery()   
 
            Write-host "New Column $DisplayName Added to the $listName Successfully!" -ForegroundColor Green 


		}



}
function add-LookupFields($siteUrl, $listName, $fieldObj, $lookupListName){
	
	    #write-Host "1638: $siteUrl, $listName, $fieldObj, $lookupListName" -f Yellow
		<#
1638: https://scholarships.ekmd.huji.ac.il/home/General/GEN158-2021, Oded Lowenheim, @{DisplayName=Name; Required=FALSE; EnforceUniqueValues=FALSE; ShowField=firstName}, applicants
Column Name already exists in the Oded Lowenheim!		
		
		#>
        #Setup the context
        $ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
        $ctx.Credentials = $Credentials
         
        #Get the web, List and Lookup list
        $web = $Ctx.web
        $List = $Web.Lists.GetByTitle($listName)
        $lookupList = $Web.Lists.GetByTitle($lookupListName)
        $Ctx.Load($web)
        $Ctx.Load($list)
        $Ctx.Load($lookupList)
        $Ctx.ExecuteQuery()
		
        #Check if the column exists in list already
        $Fields = $List.Fields
        $Ctx.Load($Fields)
        $Ctx.executeQuery()
		$NewField = $Null
		if ($fieldObj.DisplayName -eq "Name"){
			$NewField = $Fields | where { ($_.InternalName -eq $($fieldObj.DisplayName))   }
		}
		else
		{
			$NewField = $Fields | where { ($_.Title -eq $($fieldObj.DisplayName))   }
		}	
        
        if($NewField -ne $NULL) 
        {
            Write-host "Column $($fieldObj.DisplayName) already exists in the $listName!" -f Yellow
        }
        else
        {
			$LookupListID= $LookupList.id
            $LookupWebID=$web.Id
			$DisplayName = $fieldObj.DisplayName
			$FldName = $fieldObj.Name
			$IsRequired = $fieldObj.Required
			$EnforceUniqueValues = $fieldObj.EnforceUniqueValues
			$LookupField = $fieldObj.ShowField
			
			#sharepoint online powershell create lookup field
            $FieldSchema = "<Field Type='Lookup'  DisplayName='$DisplayName' Name='$FldName' Required='$IsRequired' EnforceUniqueValues='$EnforceUniqueValues' List='$LookupListID' WebId='$LookupWebID' ShowField='$LookupField' />"
			if([string]::isNullOrEmpty($FldName)){
				$FieldSchema = "<Field Type='Lookup'  DisplayName='$DisplayName' Required='$IsRequired' EnforceUniqueValues='$EnforceUniqueValues' List='$LookupListID' WebId='$LookupWebID' ShowField='$LookupField' />"
				
			}
			#write-host $FieldSchema
            $NewField = $List.Fields.AddFieldAsXml($FieldSchema,$True,[Microsoft.SharePoint.Client.AddFieldOptions]::DefaultValue)
            $Ctx.ExecuteQuery()   
 
            Write-host "New Column $($fieldObj.DisplayName) Added to the $listName Successfully!" -ForegroundColor Green 
 		
		}
  
}
function get-SchemaObject($schema)
{
	$schemaObj = @()
	foreach($line in $schema){
				$fieldObj = "" | Select-Object Name,Type,DisplayName,Schema,Choice,Required,Format
				$fieldObj.Schema = $line
				$fieldObj.Required = "FALSE"
				
				$FieldXMLSrc = '<Fields>'+  $line	 + '</Fields>'
				
				$fieldObj.Name = Select-Xml -Content $FieldXMLSrc  -XPath "/Fields/Field" | ForEach-Object {
					$_.Node.Name
				}
				$fieldObj.Type =  Select-Xml -Content $FieldXMLSrc  -XPath "/Fields/Field" | ForEach-Object {
					$_.Node.Type
				}
				$fieldObj.DisplayName =  Select-Xml -Content $FieldXMLSrc  -XPath "/Fields/Field" | ForEach-Object {
					$_.Node.DisplayName
				}
				$fieldRequiered =  Select-Xml -Content $FieldXMLSrc  -XPath "/Fields/Field" | ForEach-Object {
					$_.Node.DRequired
				} 	
				
				if (![string]::IsNullOrEmpty($fieldRequiered)){
					If ($fieldRequiered -eq "TRUE"){
						$fieldObj.Required = "TRUE"
					}
				}
				
				if ($fieldObj.Type -eq "Choice"){
					$fieldObj.Choice = get-ChoiceOption $line
					$fieldObj.Format =  Select-Xml -Content $FieldXMLSrc  -XPath "/Fields/Field" | ForEach-Object {
					$_.Node.Format
					} 
					
				}
				$schemaObj += $fieldObj

			}
    return $schemaObj
}
function Map-LookupFields($schemaDifference,$SiteURL,$xmlForm){
	
	$FieldXMLSrc = '<Fields>'
	foreach($elSrc in $schemaDifference){
		$FieldXMLSrc += $elSrc
	}	
	$FieldXMLSrc += '</Fields>'
	
	$sourceFields = Select-Xml -Content $FieldXMLSrc  -XPath "/Fields/Field" | ForEach-Object {
		 $_.Node.Type
	}
	$idx =0
	$fieldsLookupSchema = @()	
	$fieldsNoLookupSchema = @()	
	$sfCount = $sourceFields.Count
	#write-Host "SFCount : $sfCount"
	foreach($el in $sourceFields){
		if($el -eq "Lookup"){
			#$isString =  $schemaDifference.GetType() 
			if ($sfCount -eq 1){
				$fieldsLookupSchema += $schemaDifference
			}
			else
			{
				$fieldsLookupSchema += $schemaDifference[$idx]
			}
		}
		else
		{
			#write-Host $schemaDifference.GetType() | Select FullName
			#write-Host $schemaDifference[$idx]
			#$isString =  $schemaDifference.GetType() 
			#write-Host $isString
			if ($sfCount -eq 1){
				$fieldsNoLookupSchema += $schemaDifference
			}
			else
			{
				$fieldsNoLookupSchema += $schemaDifference[$idx]
			}
			#write-Host "We are Here"
			#read-host			
				
		}
		$idx++
	}
	
	$FieldXMLSrc = '<Fields>'	
	foreach($elSrc in $fieldsLookupSchema){
		$FieldXMLSrc += $elSrc
	}	
	$FieldXMLSrc += '</Fields>'	

	$LookupFields = Select-Xml -Content $FieldXMLSrc  -XPath "/Fields/Field" | ForEach-Object {
		 $_.Node.List
	}


	
	$siteUrlNew = get-UrlNoF5 $SiteURL
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrlNew)
	$Ctx.Credentials = $Credentials
	$Lists = $Ctx.Web.lists
	$Ctx.Load($Lists)
	$Ctx.ExecuteQuery()	

    $LookUpMap = @()
	$LookUpLists = @()
	$idx =0
	foreach($el in $LookupFields){
		ForEach($list in $Lists)
		{
			if($el.contains($($list.ID))){
				$LookUpLists +=  $($list.Title)
				$MapObject = "" | Select-Object Type,LookupTitle, FieldXML,FieldObj
				$MapObject.Type = "Lookup"
				$MapObject.LookupTitle = $($list.Title)
				$MapObject.FieldXML = $fieldsLookupSchema[$idx]
				$MapObject.FieldObj = get-FieldObjXML $MapObject.FieldXML
				$LookUpMap += $MapObject
			} 
		
		}
		$idx++
	}	
    $LookUpLists = $LookUpLists | select -Unique

	foreach($el in $fieldsNoLookupSchema)
    {
		$MapObject = "" | Select-Object Type,LookupTitle, FieldXML,FieldObj
		
		$MapObject.LookupTitle = ""
		$MapObject.FieldXML = $el
		#write-host $el
		
		$MapObject.Type = Get-FieldXmlType $el
		$MapObject.FieldObj = get-xFieldObjXML $MapObject.FieldXML $MapObject.Type
		$LookUpMap += $MapObject		
    }


    # Form LookUp Lists
    $LookUpFormLists = @()
	if (!$([string]::IsNullOrEmpty($xmlForm))){
		$xmlControlData = Select-Xml -Path $xmlForm -XPath "/rows/row/control"	| ForEach-Object {$_.Node.List}
		foreach($el in $xmlControlData){
			
			if (!$([string]::isNullOrEmpty($el))){
				$elExists = $false
				foreach($luEl in $LookUpLists){
					if ($luEl.ToLower() -eq $el.ToLower()){
						$elExists = $true
						break
					}
				}
				if (!$elExists){
					$LookUpFormLists += $el
				}
			}
		}
		
		$LookUpFormLists = $LookUpFormLists  | select -Unique
	}
	$outMap = "" | Select-Object LookupLists,LookupForm, FieldMap 
	$outMap.LookupLists = $LookUpLists
	$outMap.LookupForm = $LookUpFormLists
	$outMap.FieldMap = $LookUpMap
	return $outMap
	
}
function copy-DocTypeList($newSite, $oldSite){
	write-host "Copying Document Type List." -foregroundcolor Green
	$siteUrlNew = get-UrlNoF5 $newSite
	$siteUrlOld = get-UrlNoF5 $oldSite


	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
	  
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
		$docTypeItem = "" | Select Title, Required, FilesNumber , fromMail, sourceField,ApplicantPermissions
		
		$docTypeItem.Title = $Item["Title"]
		$docTypeItem.Required = $Item["Required"]
		$docTypeItem.FilesNumber = $Item["FilesNumber"]
		$docTypeItem.fromMail = $Item["fromMail"]
		$docTypeItem.ApplicantPermissions = "contribute"
		
		$titlOpX = $Item["Title"].toLower()
		if ($titlOpX.contains("טופס")  -or $titlOpX.contains("form") -or
			$titlOpX.contains("המלצ") -or $titlOpX.contains("recomm")){
			$docTypeItem.ApplicantPermissions = "none"	
		} 
		#$docTypeItem.sourceField = $Item["source_field"]
		
		$aDocTypeListOld += $docTypeItem

	}	
	
	#$aDocTypeListOld
	Write-Host "Adding To Site: $newSite" -foregroundcolor Green 
	$ctx1 = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrlNew)  
	#$ctx1.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$ctx1.Credentials = $Credentials


	$lists = $ctx1.web.Lists  
	$list = $lists.GetByTitle($ListName)

    $ListItems = $List.GetItems($Query)
	$ctx1.Load($ListItems)
	$ctx1.ExecuteQuery()
	$i=0
	if ($ListItems.Count -eq 0){
		foreach ($item in $aDocTypeListOld)	{
			$listItemInfo = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation  
			
			$listItem = $list.AddItem($listItemInfo)  
			$listItem["Title"] = $item.Title
			$listItem["Required"] = $item.Required
			$listItem["FilesNumber"] = $item.FilesNumber
			$listItem["fromMail"] = $item.fromMail
			$listItem["ApplicantPermissions"] = $item.ApplicantPermissions
			#$listItem["source_field"] = $item.sourceField
		
			$listItem.Update()      
			$ctx1.load($list)      
			$ctx1.executeQuery()  
			$i = $i+1	
		}
		Write-Host "$ListName : Copied $i items."
	}
	else
	{
		Write-Host "Document Type List on site $newSite is not Empty." -foregroundcolor Yellow
		Write-Host "List Not Copied."  -foregroundcolor Yellow
		
	}
	
	return $null

}
function get-RequestListObject(){
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
	  
	#Set parameter values
	
	$SiteURL="https://portals.ekmd.huji.ac.il/home/huca/spSupport"
	  
	#Get Credentials to connect
	#$Cred= Get-Credential
	   
	#Setup the context
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
	#$Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)
	$Ctx.Credentials = $Credentials
	$spRequestsListObj = @()	
	

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
	$spRequestsListItem = "" | Select ID,spRequestsSiteURL,spRequestsListName,spRequestsListLink,spRequestsListDocs, spAttachementsPath, GroupName, RelURL, Status,adminGroup, adminGroupSP, assignedGroup, applicantsGroup,targetAudiency, targetAudiencysharepointGroup, targetAudiencyDistributionSecurityGroup, OldSiteSuffix, currentSiteUrl,Notes, Title, contactFirstNameEn, contactLastNameEn , contactEmail, userName,mailSuffix, contactPhone, system, systemCode, siteName, siteNameEn, faculty, publishingDate, deadline, language,isDoubleLangugeSite, folderLink, PathXML, XMLFile,XMLFileEn,XMLFileHe, MailPath, MailFile,MailFileEn,MailFileHe, XMLUploadPath, XMLUploadFileName,PreviousXML, PreviousMail, GRSReponseLetterConfigPath, OldGRSReponseLetterConfigPath, RightsforAdmin, systemURL, systemListUrl, systemListName, oldSiteURL, deadLineText, isUserContactEmpty, facultyTitleEn, facultyTitleHe

	ForEach($Item in $ListItems)
	{ 
		$aGroup = $Item["assignedGroup"]
		if (![string]::isNullOrEmpty($aGroup)){
			if ($aGroup.ToUpper() -eq $groupName.ToUpper()){
				$userContactEmpty = Check-ContactEmpty $Item["contactFirstNameEn"] $Item["contactLastNameEn"] $Item["contactEmail"]
				if (!$userContactEmpty){
				
					#Write-host $Item.id, $Item["status"],$Item["contactLastNameEn"],$Item["assignedGroup"]
					#Write-host $Item.count 
					$relURL = Get-GroupTemplate $groupName
					$groupSuffix =  Get-GroupSuffix $groupName
					
					$spRequestsListItem.ID = $Item.id
					$spRequestsListItem.spRequestsSiteURL = get-UrlWithF5 $SiteURL
					$spRequestsListItem.spRequestsListName = $ListName
					$spRequestsListItem.spRequestsListLink = "https://portals2.ekmd.huji.ac.il/home/huca/spSupport/_layouts/15/listform.aspx?PageType=6&ListId=%7B05A3DC03%2D3755%2D40D2%2D8AB8%2DEDEA25CF3375%7D&ID="+$Item.id.ToString()
					$spRequestsListItem.spRequestsListDocs = "https://portals2.ekmd.huji.ac.il/home/huca/spSupport/spRequestsFiles/NEW-REQ"+$Item.id.ToString()
					$spRequestsListItem.GroupName = $Item["assignedGroup"]
					$spRequestsListItem.spAttachementsPath = Get-spReqFileAttachPath ".\Attachements" $spRequestsListItem.GroupName
					
					$spRequestsListItem.relURL = $relURL
					$spRequestsListItem.language = $Item["language"]
					if ($spRequestsListItem.language.contains("דו לשוני")){
						$spRequestsListItem.language = "EN (HE)"
					}
					
					$spRequestsListItem.Status = $Item["status"]
					$spRequestsListItem.adminGroup = $groupSuffix +"_"+ $relURL + "_AdminUG"
					$spRequestsListItem.adminGroupSP =$groupSuffix +"_"+ $relURL + "_AdminSP"
					$spRequestsListItem.assignedGroup = $groupName
					$spRequestsListItem.Notes = $Item["currentSiteUrl"]  # field "Notes" was changed to "currentSiteUrl"
					$spRequestsListItem.PreviousXML = GetPrevXML $spRequestsListItem.Notes
					$spRequestsListItem.PreviousMail = GetPrevMAIL $spRequestsListItem.Notes

					$spRequestsListItem.XMLFile =  $relURL + ".xml"
					$spRequestsListItem.XMLFileEn =  $relURL + "-En.xml"
					$spRequestsListItem.XMLFileHe =  $relURL + "-He.xml"
					$spRequestsListItem.PathXML = "\\ekeksql00\SP_Resources$\"+$groupSuffix.toUpper()+"\default" 
					$spRequestsListItem.XMLUploadPath = "\\ekeksql00\SP_Resources$\"+$groupSuffix.toUpper()+"\UploadFiles\"
					
					
					$spRequestsListItem.XMLUploadFileName = "UploadFilesHe.xml"
					if ($spRequestsListItem.language.toLower().contains("en")){
						$spRequestsListItem.XMLUploadFileName = "UploadFilesEn.xml"	
					}
					

					$spRequestsListItem.MailPath = "\\ekeksql00\SP_Resources$\"+$groupSuffix.toUpper()+"\mailTemplates"
	
					$spRequestsListItem.MailFile   = $relURL + "-mail.txt"
					$spRequestsListItem.MailFileEn = $relURL + "-mail-En.txt"
					$spRequestsListItem.MailFileHe = $relURL + "-mail-He.txt"
					
					$spRequestsListItem.mailSuffix = $groupSuffix.toUpper() +"-"+ $relURL
					$spRequestsListItem.applicantsGroup = $groupSuffix +"_"+ $relURL + "_applicantsUG"
					$spRequestsListItem.targetAudiency = "EkccUG" 
					$spRequestsListItem.targetAudiencysharepointGroup = $groupSuffix +"_"+ $relURL + "_AdminSP; "+ $groupSuffix +"_" +  $relURL + "_JudgesSP"
					$spRequestsListItem.targetAudiencyDistributionSecurityGroup = $groupSuffix +"_"+ $relURL + "_JudgesUG"
					
					
					$isDoubleLangugeSite = $($spRequestsListItem.language).toLower().contains("en") -and $($spRequestsListItem.language).toLower().contains("he")
					$spRequestsListItem.isDoubleLangugeSite = $isDoubleLangugeSite
					if ($spRequestsListItem.language.toUpper().contains("EN")){
						
						if ([string]::IsNullOrEmpty($Item["siteNameEn"])){
							$spRequestsListItem.Title = $Item["Title"]
							$spRequestsListItem.siteName = $Item["siteName"]
						}
						else
						{	
							$spRequestsListItem.Title =  $Item["siteNameEn"]
							$spRequestsListItem.siteName = $Item["siteNameEn"]
						}
						$spRequestsListItem.MailFile = $spRequestsListItem.MailFileEn
						
					}
					else
					{
						$spRequestsListItem.Title = $Item["Title"]
						$spRequestsListItem.siteName = $Item["siteName"]
						$spRequestsListItem.MailFile = $spRequestsListItem.MailFileHe
					}	
					
					if ([string]::IsNullOrEmpty($Item["siteNameEn"])){
						$spRequestsListItem.siteNameEn = $Item["siteName"]
					}else
					{
						$spRequestsListItem.siteNameEn = $Item["siteNameEn"]
					}
					
					$TextInfo = (Get-Culture).TextInfo
					$spRequestsListItem.contactFirstNameEn =  $TextInfo.ToTitleCase($Item["contactFirstNameEn"])
					$spRequestsListItem.contactLastNameEn  =  $TextInfo.ToTitleCase($Item["contactLastNameEn"])
					
					$spRequestsListItem.contactEmail = $Item["contactEmail"]
					$spRequestsListItem.userName = "CC\"+$spRequestsListItem.contactEmail.split('@')[0]
					$spRequestsListItem.userName = Get-UsrNameAD $Item["contactEmail"]
					
					$spRequestsListItem.contactPhone = $Item["contactPhone"]
					$spRequestsListItem.system = $Item["system"]
					$spRequestsListItem.systemCode = $Item["systemCode"]
					
					
					
					$spRequestsListItem.faculty = $Item["faculty"]
					$spRequestsListItem.publishingDate = $Item["publishingDate"]
					$spRequestsListItem.deadline = $Item["deadline"]
					
					$dedln = $spRequestsListItem.deadline.AddDays(1)
					$spRequestsListItem.deadLineText =  $dedln.day.tostring().PadLeft(2,"0")+"."+$dedln.month.tostring().PadLeft(2,"0")+"."+$dedln.year
					
					$spRequestsListItem.folderLink =  ($Item["folderLink"]).Url
					$spRequestsListItem.RightsforAdmin = "ekccUG; "+$groupSuffix +"_"+ $relURL + "_adminSP;"+$groupSuffix +"_" +$relURL + "_judgesSP"
					$spRequestsListItem.systemListUrl = $currentList
					$spRequestsListItem.systemURL = $currentSystem.appHomeUrl
					$spRequestsListItem.systemListName = $currentSystem.listName
					$spRequestsListItem.oldSiteURL  = get-SiteNameFromNote $spRequestsListItem.Notes
					$spRequestsListItem.OldSiteSuffix = Get-OldSiteSuffix $spRequestsListItem.oldSiteURL
					$spRequestsListItem.isUserContactEmpty = $false
					$facTitle = get-FacultyTitle $groupName $spRequestsListItem.faculty
					$spRequestsListItem.facultyTitleEn = $facTitle.TitleEn
					$spRequestsListItem.facultyTitleHe = $facTitle.TitleHe
					
					if ($($groupSuffix.toUpper()) -eq "GRS"){
						$spRequestsListItem.GRSReponseLetterConfigPath = "\\ekeksql00\SP_Resources$\"+$groupSuffix.toUpper()+"\ResponseLetterConfig\"+$relURL
						$spRequestsListItem.OldGRSReponseLetterConfigPath = "\\ekeksql00\SP_Resources$\"+$groupSuffix.toUpper()+"\ResponseLetterConfig\" + $spRequestsListItem.OldSiteSuffix
					}					
					
					write-Host "Old Site Name : $($spRequestsListItem.oldSiteURL)" -foregroundcolor Green

					# $spRequestsListObj += $spRequestsListItem
					break
				}
				else
				{
					$spRequestsListItem.isUserContactEmpty = $true
					break
				}
				
			}
		}
		
	}

		
	return $spRequestsListItem;
}
function Get-UsrNameAD($email){
	$retStr = ""
	if ($email.contains("savion.huji.ac.il")){
		
		$eml1 = $email.split('@')[0] + "@savion.huji.ac.il"
		 
		$usrObj =  Get-ADuser -Filter 'mail -like $eml1' -Properties SamAccountName -Server hustaff.huji.local
		
		$retStr = "CC\"+ $usrObj.SamAccountName
	}
	else
	{
		# EKMD ?
		$usrObj=Get-ADuser -Filter 'mail -like $email' -Properties SamAccountName
		if (![string]::IsNullOrEmpty($usrObj.SamAccountName)){
			$retStr = "EKMD\"+ $usrObj.SamAccountName 
		}
		else
		{
			write-host "User with mail $email NOT found in AD!!!" -foregroundcolor Yellow
		}
	}
	return $retStr	
}
function get-CreatedSiteName($spObj){

	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($spObj.systemURL)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials
	
	$List = $Ctx.Web.lists.GetByTitle($spObj.systemListName)
	$Query = New-Object Microsoft.SharePoint.Client.CamlQuery
	$qry = "<View><Query></Query></View>"
	$Query.ViewXml = $qry

	#Get All List Items matching the query
	$ListItems = $List.GetItems($Query)
	$Ctx.Load($ListItems)
	$Ctx.ExecuteQuery()
	# $ListItems.count

 
	$applicantsSiteURL = ""
	$siteUrl = ""

	ForEach($Item in $ListItems){
		if ($Item["template"].ToUpper().Trim() -eq $spObj.RelURL){
			$applicantsSiteURL = $Item["url"]
			break
		}
	}
	if (![string]::IsNullOrEmpty($applicantsSiteURL)){
		$siteUrl = get-UrlNoF5 $applicantsSiteURL
	}
	
	return $siteUrl
	
	
}

function add-ListApplicants( $siteUrlX1, $spObj){
	
	#$spObj
	#$siteUrlX1
	
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
	
	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrlX1)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials
	$List = $Ctx.Web.lists.GetByTitle("applicants")
	
	$Query = New-Object Microsoft.SharePoint.Client.CamlQuery
	$qry = "<View><Query></Query></View>"
	$Query.ViewXml = $qry

	#Get All List Items matching the query
	$ListItems = $List.GetItems($Query)
	$Ctx.Load($ListItems)
	$Ctx.ExecuteQuery()
	write-host "Applicants list items:$($ListItems.count)"
	
	$asherExists = $false
	#$danteExists = $false
	$userExists  = $false		
	
	foreach($item in $ListItems){
		if ($Item["userName"].ToUpper().Trim() -eq 'EKMD\ASHERSA'){	
			$asherExists = $true
		}
		#if ($Item["userName"].ToUpper().Trim() -eq 'EKMD\DANTE'){	
		#	$danteExists = $true
		#}	
		if ($spObj.contactEmail.ToLower().Contains('savion.huji.ac.il')){
			if ($Item["userName"].ToUpper().Trim() -eq $spObj.userName.ToUpper()){	
				$userExists = $true
			}						
		}	
	}
	$userObj = "" | Select Title, FirstName, SurName, UserName 
	if (!$userExists){
		$userObj.Title 		= $spObj.contactFirstNameEn + " "+ $spObj.contactLastNameEn
		$userObj.FirstName 	= $spObj.contactFirstNameEn
		$userObj.SurName 	= $spObj.contactLastNameEn
		$userObj.UserName 	= $spObj.userName
		Add-ApplicantsItem $siteUrlX1 $userObj

	}	
	
	if (!$asherExists){
		$userObj.Title = "Asher Sandler"
		$userObj.FirstName = "Asher"
		$userObj.SurName = "Sandler"
		$userObj.UserName = "ekmd\ashersa"
		Add-ApplicantsItem $siteUrlX1 $userObj

	}
	<#
	if (!$danteExists){
		$userObj.Title = "דן טסטמן"
		$userObj.FirstName = "דן"
		$userObj.SurName = "טסטמן"
		$userObj.UserName = "ekmd\dante"
		Add-ApplicantsItem $siteUrlX1 $userObj

	}
	#>
	
	
	write-host "Asher Exists: $asherExists" -foregroundcolor Yellow
	#write-host "Dante Exists: $danteExists" -foregroundcolor Yellow
	write-host "User  Exists: $userExists" -foregroundcolor Yellow
			
	
	

}

function Add-ApplicantsItem($siteUrl, $spObj)
{
	#$siteUrl | gm
	#write-host 1111
	#read-host
	#$spObj
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)  
	#$ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$ctx.Credentials = $Credentials
	try{  
		 
		$lists = $ctx.web.Lists 
		$list = $lists.GetByTitle("applicants")  
		$listItemInfo = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation  
		$listItem = $list.AddItem($listItemInfo)  
		$listItem["Title"] = $spObj.Title
		$listItem["firstName"] = $spObj.FirstName
		$listItem["surname"] = $spObj.SurName
		$listItem["userName"] = $spObj.UserName
		
		
		$listItem.Update()      
		$ctx.load($list)      
		$ctx.executeQuery()  
		Write-Host "applicants Added with ID - " $listItem.Id      
	}  
	catch{  
		write-host "$($_.Exception.Message)" -foregroundcolor red  
	} 
}

function change-ListApplicantsDeadLine( $siteUrl, $spObj){
	write-Host $spObj.deadline
	write-host $siteUrl

	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)  
	#$ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$ctx.Credentials = $Credentials
	
	$lists = $ctx.web.Lists 
	$list = $lists.GetByTitle("applicants") 
	$field = $list.Fields.GetByTitle("deadline")
	$defValueT = $($spObj.deadline.AddDays(1).GetDateTimeFormats()[6]+"T00:00:00Z")
	write-host "Default value: $defValueT"
	$field.DefaultValue = $defValueT # $spObj.deadline;
	$field.Update();
	$ctx.Load($field);
	$ctx.ExecuteQuery();	
	
	
}
function change-siteSetting($SiteURL) {
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
	
	Try {
		#Setup the context
		$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
		#$ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
		$ctx.Credentials = $Credentials
		
		#Get the Web
		$Web = $Ctx.Web
		$ctx.Load($Web)
		$Ctx.ExecuteQuery()
	 
		$TaxonomySession = [Microsoft.SharePoint.Client.Taxonomy.TaxonomySession]::GetTaxonomySession($Ctx)
		$NavigationSettings = New-Object Microsoft.SharePoint.Client.Publishing.Navigation.WebNavigationSettings($Ctx, $Web)
	 
		#Set Both current and global navigation settings to structural - Other values: PortalProvider,InheritFromParentWeb ,TaxonomyProvider
		#$NavigationSettings.GlobalNavigation.Source = "PortalProvider"
		#$NavigationSettings.GlobalNavigation | gm
		$NavigationSettings.CurrentNavigation.Source = "PortalProvider"
	 
		#Show subsites in Global navigation
		#$Web.AllProperties["__IncludeSubSitesInNavigation"] = $False
	 
		#Show pages in global navigation
		#$Web.AllProperties["__IncludePagesInNavigation"] = $true
		
		# GlobalNavigation Not Show Pages and Not Show Subsites
		$Web.AllProperties["__GlobalNavigationIncludeTypes"]  = 0;
		# CurrentNavigation show pages Only
		$Web.AllProperties["__CurrentNavigationIncludeTypes"] = 2;
		
	 
		#Maximum number of dynamic items to in global navigation
		$web.AllProperties["__GlobalDynamicChildLimit"] = 25
	 
		#Update Settings
		$Web.Update()
		$NavigationSettings.Update($TaxonomySession)
		$Ctx.ExecuteQuery()
	 
		Write-host -f Green "Navigation Settings Updated!"
	}
	Catch {
		write-host -f Red "Error Updating Navigation Settings!" $_.Exception.Message
	}
}

function change-siteTitle($SiteURL, $siteTitle){
		$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
		#$ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
		$ctx.Credentials = $Credentials
	
		#Get the Web
		$Web = $Ctx.Web
		$ctx.Load($Web)
		$Ctx.ExecuteQuery()
		
		$Web.Title = $siteTitle
		$Web.Update()
		$Ctx.ExecuteQuery()
	 	
}

function get-UrlWithF5($url){
	if ($url.contains("2.ekmd.")){
		return $url
	}
	else
	{
		return $url.replace(".ekmd.","2.ekmd.")
	}
	
	
}
function get-UrlNoF5($url){
	if (!$url.contains("2.ekmd.")){
		return $url
	}
	else
	{
		return $url.replace("2.ekmd",".ekmd")	
	}
}

function get-allListItemsByID($site, $listName){
	$siteName = get-UrlNoF5 $site
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)  
	#$ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$ctx.Credentials = $Credentials
	
	$list = $Ctx.Web.lists.GetByTitle($listName)
	
	#Define the CAML Query
	$query = New-Object Microsoft.SharePoint.Client.CamlQuery
	
	$qry = "<View><Query></Query></View>"
	$query.ViewXml = $qry

	
	

	$itemColl = $list.GetItems($query);
	$ctx.Load($itemColl)
	$ctx.ExecuteQuery()
	
	<#
	foreach ($item in $itemColl){
		
		
		Write-Host $item.ID
		
	}
	#>
	return $itemColl
	
}

function delete-ListItemsByID($site, $listName, $id){
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext(get-UrlNoF5 $site)  
	#$ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$ctx.Credentials = $Credentials
	
	$list = $Ctx.Web.lists.GetByTitle($listName)
	
	$item = $list.GetItemById($id)
	
	$item.DeleteObject()
	
	$ctx.ExecuteQuery()
	
}

function get-SiteNameFromNote($note){
	$sName = ""
	if (![string]::IsNullOrEmpty($note)){
		[regex]$regex = '(http|ftp|https)://([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?'
		$siteName = $regex.Matches($note).Value
		
		if (![string]::IsNullOrEmpty($siteName)){
			$sName = "https://"
			$aName = $siteName.split("/")
			for ($i = 2; $i -le 5; $i++ ){
				$sName += $aName[$i] + "/"
			}
		}
		
		
	}
	
	return $sName
}

function get-RelURL($url){
# get-RelURL "https://grs2.ekmd.huji.ac.il/home/Medicine/MED86-2022"
# /home/Medicine/MED86-2022/	
	$relUrl = ""
	
	if (![string]::IsNullOrEmpty($url)){
		
		$aUrl = $url.split("/")
		
		if ($aUrl.length -ge 6){
			for ($i = 3; $i -le 5; $i++ ){
				$relUrl += $aUrl[$i] + "/"
			}
			$relUrl = "/" + $relUrl
		}	
	}
	
	
	return $relUrl
}

function get-OldContactUs($oldSiteName){
	$pageName = "Pages/ContactUs.aspx"
	$siteName = get-UrlNoF5 $oldSiteName
	
	$relUrl   = get-RelURL $siteName
	
	$pageURL  = $relUrl + $pageName
	
	#write-host $pageURL 
	#read-host


	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
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
	
	return $PageContent
	
}

function edt-ContactUs($newSiteName, $pageContent, $language){
	$pageName = "Pages/ContactUs.aspx"
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
	
	$pageTitle  = "צור קשר"
	if ($language.ToLower().contains("en")){
		$pageTitle = "Contact Us"
	}
	
	$pageFields = $page.ListItemAllFields
	$pageFields["PublishingPageContent"] = $pageContent
	$pageFields["Title"] = $pageTitle
	$pageFields.Update()
	
	$ctx.Load($pageFields)
	$ctx.ExecuteQuery();
	
	$page.CheckIn("",1)
	
	$ctx.ExecuteQuery()	
	write-host "$pageName Was Updated" -foregroundcolor Green
}

function get-PureContactUs($language, $fName, $lName, $email){
	$result = ""
	if ($language.ToLower().contains("en")){	
		$result = '<h1>Contact Us</h1>'
		$result += '<div><div><div><span class="ms-rteFontSize-2">For administrative questions please contact:</span></div><div><span class="ms-rteFontSize-2">'
		$result += $fName + " " + $lName
		$result += '</span></div>'
		
		#$result += '<div><span class="ms-rteFontSize-2">Phone: <span>[phone]</span></span></div><div>'
        
		$result += '<span class="ms-rteFontSize-2">Email: <a href="mailto:'
		$result += $email
		$result +='"><span style="text-decoration: underline;"><font color="#0066cc">'
		$result += $email
		$result += '</font></span></a></span>&#160;</div></div></div><p>​</p>'
	}
	else
	{
		$result  = '<h1>​צור ​קשר</h1>'
		$result += '<p>'
		$result += '   <br/>'
		$result += '   <span class="ms-rteFontSize-2">ליצירת קשר ניתן לפנות אל:</span></p>'
		$result += '<p><div class="ms-rteFontSize-2">'
		$result += '   <a href="mailto:' + $email +'">'+ $email + '</a></div></p>'
				
	}
	return $result
}
function edt-DocumentsUpload($newSiteName, $language){
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
	$editContent = ""
	
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

function edt-contactUsTitle($newSiteName, $language){
	$pageName = "Pages/ContactUs.aspx"
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
	
	$pageTitle  = "צור קשר"
	if ($language.ToLower().contains("en")){
		$pageTitle = "Contact Us"
	}
	
	$pageFields = $page.ListItemAllFields
	
	$pageFields["Title"] = $pageTitle
	$pageFields.Update()
	
	$ctx.Load($pageFields)
	$ctx.ExecuteQuery();
	
	$page.CheckIn("",1)
	
	$ctx.ExecuteQuery()
	write-host "$pageName Was Updated" -foregroundcolor Green	
}


function edt-cancelCandidacy($newSiteName, $language){
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
	
	$pageTitle  = "הסרת מועמדות"
	if ($language.ToLower().contains("en")){
		$pageTitle = "Cancel Candidacy"
	}

	$pageFields = $page.ListItemAllFields
	$pContent = get-cancelCandidacyContent $pageFields["PublishingPageContent"] $language
	
	#write-Host "2498: Check for  pContent" 
	#write-Host	$pContent.GetType()
	#write-Host $pContent
	
    #read-host
	$pageFields["PublishingPageContent"] = $pContent
	$pageFields["Title"] = $pageTitle
	$pageFields.Update()
	
	$ctx.Load($pageFields)
	$ctx.ExecuteQuery();
	
	$page.CheckIn("",1)
	
	$ctx.ExecuteQuery()	
	write-host "$pageName Was Updated" -foregroundcolor Green	
}

function get-cancelCandidacyContent($content, $language)
{
	$oWP = Get-WPfromContent $content
	$editContent = ""
	
	$i = 1
	$wpCount = 0 
	foreach($wp in $oWP){
		if ($wp.isWP){
			$wpCount++
		}
	} 
	#write-host "cancelCandidacywpCount : $wpCount"
	#read-host
	if ($wpCount -eq 1){
		foreach ($wp in $oWP){
			if ($wp.isWP){
				$editContent += $wp.Content 
			}
			
			$i++
		}
	}
	else
	{
		foreach ($wp in $oWP){
			if ($i -gt 1){
				if ($wp.isWP){
					$editContent += $wp.Content 
				}	
			}
			$i++
		}		
    }	
    
	$langContent = CancelCandidacyContentHe
	if ($language.ToLower().contains("en")){
		$langContent = CancelCandidacyContentEn
	}
	
	$editContent = $langContent + $editContent	
	#write-Host "Content of cancelCandidacy:"
	#write-host $editContent.GetType()
	#write-host $editContent
	#read-host	
	return $editContent
}

function CancelCandidacyContentHe(){
	
	$retStr = @"
<h1 dir="rtl" style="text-align: right;">​הסרת מועמדות</h1>
<div dir="rtl" style="text-align: right;">
   <span class="ms-rteFontSize-2" lang="HE">ניתן לבטל מועמדות על ידי לחיצה על כפתור &quot;הסרת מועמדות&quot;.
   <br>שימו לב, פעולה זו תסיר מהאתר את כל החומרים שהועלו, ללא אפשרות לשחזור.<br>לרישום מחדש יש לחזור על תהליך הרישום מההתחלה (מילוי טופס/ העלאת קבצים וכו').</span>
</div>	
"@
	 return '<div dir="rtl" style="text-align: right;"><h1><span aria-hidden="true"></span>הסרת מועמדות</h1><span class="ms-rteFontSize-2"><span lang="HE">ניתן לבטל מועמדות על ידי לחיצה על כפתור &quot;הסרת מועמדות&quot;.<br/>שימו לב, פעולה זו תסיר מהאתר את כל החומרים שהועלו, ללא אפשרות לשחזור.<br/>לרישום מחדש יש לחזור על תהליך הרישום מההתחלה (מילוי טופס/ העלאת קבצים וכו&#39;).</span></span></div>'
	#return $retStr
}

function CancelCandidacyContentEn(){
	return '<h1>Cancel Candidacy </h1>
<p style="text-align: justify;">
   <span class="ms-rteFontSize-2"> You can cancel your candidacy by clicking on the “Cancel Candidacy” button.<br/>Please note, clicking on the button will remove all your material from this site, without the possibility of recovery.<br/>To re-apply, you will need to repeat the application process from the beginning (application form / uploading documents etc.).</span></p>'
}

# ------------------------------------
function edt-SubmissionStatus($newSiteName, $language){
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
	
	$pageTitle  = "סטטוס הגשה"
	if ($language.ToLower().contains("en")){
		$pageTitle = "Submission Status"
	}
	
	$pageFields = $page.ListItemAllFields
	$pageContent = get-SubmissionStatusContent $pageFields["PublishingPageContent"] $language $relUrl
	$pageFields["PublishingPageContent"] = $pageContent
	$pageFields["Title"] = $pageTitle
	$pageFields.Update()
	
	$ctx.Load($pageFields)
	$ctx.ExecuteQuery();
	
	$page.CheckIn("",1)
	
	$ctx.ExecuteQuery()	
	write-host "$pageName Was Updated" -foregroundcolor Green	
}

function get-SubmissionStatusContent($content, $language, $relURL){
		
	$retContent = ""
	$wToSearch = 'id="div_'
	if ($content.contains($wToSearch)){
		$idPos = $content.IndexOf($wToSearch)+$wToSearch.length
		$idSubst = $content.substring($idPos)
		$kvPos = $idSubst.IndexOf('"')
		
		$sId1 = $idSubst.Substring(0,$kvPos)
		#write-host $sId1
		
		$ostatok = $idSubst.substring($kvPos)
		$wToSearch = 'ms-rte-wpbox'
		$idPos = $ostatok.IndexOf($wToSearch)+$wToSearch.length
		
		$content = $ostatok.substring($idPos)
		#write-Host "CNT1 : $content"
		$wToSearch = 'id="div_'
		
		$idPos = $content.IndexOf($wToSearch)+$wToSearch.length
		$idSubst = $content.substring($idPos)
		$kvPos = $idSubst.IndexOf('"')
		
		$sId2 = $idSubst.Substring(0,$kvPos)
		#write-host "Submission status RelUrl: $relURL"
		#write-host $sId2
		

	if ($language.ToLower().contains("en")){		
		$LangContent1 = '<h1>​Document Status</h1><p><span class="ms-rteFontSize-2">Recommendation letters will be updated&#160;up to </span><strong class="ms-rteFontSize-2">two hours </strong><span class="ms-rteFontSize-2">after confirmation of arrival on the&#160;</span><a href="'+$relURL+'Pages/Recommendations.aspx"><span class="ms-rteFontSize-2" style="text-decoration-line: underline;"><font color="#0066cc">Recomme​​ndations</font></span></a><span class="ms-rteFontSize-2"> page.​</span></p>'
		$LangContent2 = '<div>
   <div>
      <h1>Submission</h1>
      <font class="ms-rteThemeFontFace-1 ms-rteFontSize-2"><span class="ms-rteThemeFontFace-1 ms-rteFontSize-2">You can press &#39;Submit&#39;, </span>
         <span class="ms-rteThemeFontFace-1 ms-rteFontSize-2">once you have carried out all the obligations according to the administrative guidelines.</span></font><span class="ms-rteThemeFontFace-1 ms-rteFontSize-2"> </span></div>
   <div>
      <span class="ms-rteThemeFontFace-1 ms-rteFontSize-2">
         
         <span class="ms-rteThemeFontFace-1 ms-rteFontSize-2">After&#160;the deadline,&#160;all the material in your &quot;Documents Upload&quot; folder will be read only.</span></span></div>
</div> 
'
	}
	else
	{
		$LangContent1 = '<h1>סטטוס מסמכים</h1>
	
<div style="color: #000000; font-size: medium;"> 
   <font class="ms-rteFontSize-2">
      <font size="3">&#160;<span class="ms-rteFontSize-2"><font size="3">מכתבי המלצה יתעדכנו </font></span><font size="3"> 
            <strong class="ms-rteFontSize-2">כשעתיים</strong>
			<span class="ms-rteFontSize-2"> לאחר אישור קבלה בדף </span>
	  </font>
    </font> 
    <a href="'+$relURL+'Pages/Recommendations.aspx"> 
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


		$LangContent2 = '<div>
   <h1>
      <span aria-hidden="true"></span><span aria-hidden="true"></span><span aria-hidden="true"></span>הגשה</h1>
   <div class="ms-rteFontSize-2">בתום ביצוע כל חובות הבקשה בהתאם להנחיות המנהליות, תוכל/י ללחוץ &#39;הגשה&#39;. </div>
   <div class="ms-rteFontSize-2">
      <span lang="HE" dir="rtl">המידע שימצא בתיק המועמד/ת במועד הסגירה יהיה זמין לקריאה בלבד.<span aria-hidden="true"></span><span aria-hidden="true"></span></span></div>
</div>'


	}		
		$retContent  =  $LangContent1 + '<div class="ms-rtestate-read ms-rte-wpbox" contenteditable="false">'		
		$retContent +=  '<div class="ms-rtestate-notify  ms-rtestate-read '+$sId1+'" id="div_'+$sId1+'">'
		$retContent +=  '</div>'
		$retContent +=  '<div id="vid_'+$sId1+'" style="display: none;">'
		$retContent +=  '</div></div><div>'+$LangContent2+'</div>'
		$retContent +=  '<div class="ms-rtestate-read ms-rte-wpbox" contenteditable="false">'
		$retContent +=  '<div class="ms-rtestate-notify  ms-rtestate-read '+$sId2+'" id="div_'+$sId2+'">'
		$retContent +=  '</div>'
		$retContent +=  '<div id="vid_'+$sId2+'" style="display: none;">'
		$retContent +=  '</div></div><div></div>'
		
		
		#write-host $retContent
		
		
		
		
		
	}

	return $retContent	
}

function edt-Recommendations($newSiteName, $language){
	$pageName = "Pages/Recommendations.aspx"
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
	
	$pageTitle  = "המלצות"
	if ($language.ToLower().contains("en")){
		$pageTitle = "Recommendations"
	}
	
	$pageFields = $page.ListItemAllFields
	$pageContent = get-RecommendationsContent $pageFields["PublishingPageContent"] $language $relUrl
	$pageFields["PublishingPageContent"] = $pageContent
	$pageFields["Title"] = $pageTitle
	$pageFields.Update()
	
	$ctx.Load($pageFields)
	$ctx.ExecuteQuery();
	
	$page.CheckIn("",1)
	
	$ctx.ExecuteQuery()
	write-host "$pageName Was Updated" -foregroundcolor Green	
}



function get-RecommendationsContent($content, $language, $relURL){
		
	$retContent = ""
	$wToSearch = 'id="div_'
	if ($content.contains($wToSearch)){
		$idPos = $content.IndexOf($wToSearch)+$wToSearch.length
		$idSubst = $content.substring($idPos)
		$kvPos = $idSubst.IndexOf('"')
		
		$sId1 = $idSubst.Substring(0,$kvPos)
		#write-host $sId1
		
		$ostatok = $idSubst.substring($kvPos)
		$wToSearch = 'ms-rte-wpbox'
		$idPos = $ostatok.IndexOf($wToSearch)+$wToSearch.length
		
		$content = $ostatok.substring($idPos)
		#write-Host "CNT1 : $content"
		$wToSearch = 'id="div_'
		
		$idPos = $content.IndexOf($wToSearch)+$wToSearch.length
		$idSubst = $content.substring($idPos)
		$kvPos = $idSubst.IndexOf('"')
		
		$sId2 = $idSubst.Substring(0,$kvPos)
		#write-host $sId2
		

	if ($language.ToLower().contains("en")){		
		$LangContent1 = RecomendationContentEN1 $relURL


		$LangContent2 = RecomendationContentEN2
	}
	else
	{
		$LangContent1 = RecomendationContentHE1


		$LangContent2 = RecomendationContentHE2


	}		
		$retContent  =  $LangContent1 + '<div class="ms-rtestate-read ms-rte-wpbox" contenteditable="false">'		
		$retContent +=  '<div class="ms-rtestate-notify  ms-rtestate-read '+$sId1+'" id="div_'+$sId1+'">'
		$retContent +=  '</div>'
		$retContent +=  '<div id="vid_'+$sId1+'" style="display: none;">'
		$retContent +=  '</div></div><div>'+$LangContent2+'</div>'
		$retContent +=  '<div class="ms-rtestate-read ms-rte-wpbox" contenteditable="false">'
		$retContent +=  '<div class="ms-rtestate-notify  ms-rtestate-read '+$sId2+'" id="div_'+$sId2+'" unselectable="on">'
		$retContent +=  '</div>'
		$retContent +=  '<div id="vid_'+$sId2+'" style="display: none;">'
		$retContent +=  '</div></div><div></div>'
		
		
		#write-host $retContent
		
	
	}

	return $retContent	
}
function RecomendationContentHE2(){
	return '<h2>המלצות שהתקבלו:</h2>'
}
function RecomendationContentHE1($relURL){
	$outstr = '<div>
   <h1>המלצות</h1>
   <div>
      <span class="ms-rteFontSize-2 ms-rteThemeFontFace-1"><span lang="HE">אנא בקשו מהממליצים שלכם לשלוח את מכתביהם לכתובת הדוא&quot;ל המופיעה מטה.</span><span dir="ltr"></span>                               
         <br/>מכתבי המלצה מתקבלים אוטומטית במערכת ישירות לתיק המועמד/ת מספר דקות לאחר השליחה.</span></div>
   <div>
      <span class="ms-rteFontSize-2 ms-rteThemeFontFace-1">&#160;</span></div>
   <div style="background: white; margin: 0cm 0cm 0pt; vertical-align: top; unicode-bidi: embed; direction: rtl;">
      <span class="ms-rteFontSize-2 ms-rteThemeFontFace-1"><span lang="HE">אנא וודאו שהממליצים עוקבים אחר ההוראות הבאות:</span><span dir="ltr"></span></span></div>
   <ul>
      <li>
         <p>
            <span class="ms-rteFontSize-2"><span lang="HE">שליחת מכתב ההמלצה כצרופה – </span>                                                             
               <span dir="ltr">attachment</span><span dir="rtl"></span><span dir="rtl"></span><span dir="rtl"></span><span dir="rtl"></span>                                                             
               <span lang="HE">(כל טקסט בגוף המייל לא ייקלט במערכת).</span><span dir="ltr"></span></span></p>
      </li>
      <li>
         <p>
            <span class="ms-rteFontSize-2"><span lang="HE">גודל הקובץ לא יעלה על </span>                                                             
               <span dir="ltr"></span>                                                             
               <span dir="ltr"></span>                                                             
               <span dir="ltr">
                  <span dir="ltr"></span>                                                                            
                  <span dir="ltr"></span>5MB</span><span dir="rtl"></span><span dir="rtl"></span><span lang="HE"><span dir="rtl"></span><span dir="rtl"></span>.</span></span></p>
      </li>
      <li>
         <p>
            <span class="ms-rteFontSize-2" lang="HE">על שם הקובץ לא להכיל תווים מיוחדים כגון&#160; (&quot; ;)</span></p>
      </li>
   </ul>
   <div style="background: white; margin: 0cm 0cm 0pt; vertical-align: top; unicode-bidi: embed; direction: rtl;">
      <span class="ms-rteFontSize-2 ms-rteThemeFontFace-1" lang="HE">הממליץ יקבל אישור על שליחת המכתב תוך 24 שעות.</span></div>
   <div style="background: white; margin: 0cm 0cm 0pt; vertical-align: top; unicode-bidi: embed; direction: rtl;">
      <span class="ms-rteFontSize-2 ms-rteThemeFontFace-1" lang="HE"></span>                
      <div style="margin: 0cm 0cm 0pt; vertical-align: top; unicode-bidi: embed; direction: rtl;">
         <span class="ms-rteFontSize-2 ms-rteThemeFontFace-1">
            <span lang="HE">אנא הדגישו בפני הממליץ                                                                  
               <strong>שאין לכם גישה</strong> למכתב ההמלצה.</span></span></div>
   </div>
   <div style="background: white; margin: 0cm 0cm 0pt; vertical-align: top; unicode-bidi: embed; direction: rtl;">
      <strong class="ms-rteFontSize-2"><span lang="HE"><br/>באחריותכם לוודא שמכתבי ההמלצה הגיעו לפני מועד סגירת הרישום.</span></strong></div>
   <div style="background: white; margin: 0cm 0cm 0pt; vertical-align: top; unicode-bidi: embed; direction: rtl;">
      <strong><span lang="HE" style="font-family: arial, sans-serif; font-size: 10pt;"></span></strong>&#160;</div>
   <h2>
      <span lang="HE">​​כתובת דוא&quot;ל למשלוח המלצות:<span aria-hidden="true"></span><span aria-hidden="true"></span></span></h2>
</div>
'
	return $outStr
}
function RecomendationContentEN1($relURL){
	$outStr = '<h1>Recommendations </h1>
<div style="background: white; margin: 0cm 0cm 0pt; vertical-align: top;"> 
   <span class="ms-rteThemeFontFace-1 ms-rteFontSize-2">Please ask your referees to send their recommendation letters to the e-mail address appearing below.<span lang="HE" dir="rtl"></span></span></div>
<div> 
   <span class="ms-rteThemeFontFace-1 ms-rteFontSize-2">Letters arrive directly to the applicant'+"’"+'s folder automatically, a few moments after being sent.</span></div>
<div style="background: white; margin: 0cm 0cm 0pt; vertical-align: top;"> 
   <span class="ms-rteThemeFontFace-1 ms-rteFontSize-2">
      <span lang="HE" dir="rtl"></span>&#160;</span></div>
<div style="background: white; margin: 0cm 0cm 0pt; vertical-align: top;"> 
   <span class="ms-rteThemeFontFace-1 ms-rteFontSize-2">Please make sure your referees follow these guidelines:<span lang="HE" dir="rtl"></span></span></div>
<ul>
   <li>
      <p> 
         <span class="ms-rteFontSize-2">Sending the letter as an attachment (all text in the email body will not be received by the system)</span></p>
   </li>
</ul>
<ul>
   <li>
      <p> 
         <span class="ms-rteFontSize-2">The file size should not be larger than 5MB.</span></p>
   </li>
</ul>
<ul>
   <li>
      <p> 
         <span class="ms-rteFontSize-2">The file name should not contain any special characters such as (“ ;).</span></p>
   </li>
</ul>
<div style="background: white; margin: 0cm 0cm 0pt; vertical-align: top;"> 
   <span class="ms-rteThemeFontFace-1 ms-rteFontSize-2">Your referee will receive confirmation within 24 hours.</span></div>
<div style="background: white; margin: 0cm 0cm 0pt; vertical-align: top;"> 
   <span class="ms-rteThemeFontFace-1 ms-rteFontSize-2">Please&#160;inform the referees that 
      <strong>you will not</strong> have access to these letters. </span></div>
<div style="background: white; margin: 0cm 0cm 0pt; vertical-align: top;"> 
   <strong>​<br/>Please ensure that the letters arrive before the deadline.</strong></div>
<div>&#160;</div>
<h2>E-mail address for referees:​</h2>'

return $outStr
}

function RecomendationContentEN2(){
	return '<h2>Received recommendations:​</h2>'	
}

function edt-DeleteEmptyFolders($newSiteName, $language){
	$pageName = "Pages/DeleteEmptyFolders.aspx"
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
	
	$pageTitle  = "מחיקת תיקים ריקים"
	if ($language.ToLower().contains("en")){
		$pageTitle = "Delete Empty Folders"
	}
	
	$pageFields = $page.ListItemAllFields
	$pageContent = get-DeleteEmptyFolders $pageFields["PublishingPageContent"] $language $relUrl
	#write-host "2962: Check for pageContent"
	#write-host $pageContent
	#read-host
	$pageFields["PublishingPageContent"] = $pageContent
	$pageFields["Title"] = $pageTitle
	$pageFields.Update()
	
	$ctx.Load($pageFields)
	$ctx.ExecuteQuery();
	
	$page.CheckIn("",1)
	
	$ctx.ExecuteQuery()	
	write-host "$pageName Was Updated" -foregroundcolor Green	
}

function get-DeleteEmptyFolders($content, $language)
{
	$oWP = Get-WPfromContent $content
	$editContent = ""
	$i = 1
	$wpCount = 0 
	foreach($wp in $oWP){
		if ($wp.isWP){
			$wpCount++
		}
	} 
	#write-host "DeleteEmpty wpCount : $wpCount"
	#read-host
	if ($wpCount -eq 1){
		foreach ($wp in $oWP){
			if ($wp.isWP){
				$editContent += $wp.Content 
			}
			
			$i++
		}
	}
	else
	{
		foreach ($wp in $oWP){
			if ($i -gt 1){
				if ($wp.isWP){
					$editContent += $wp.Content 
				}	
			}
			$i++
		}		
    }	

	$langContent = DeleteEmptyFoldersContentHE

	if ($language.ToLower().contains("en")){
		$langContent = DeleteEmptyFoldersContentEN
	}
		
   	$editContent = $langContent + $editContent	
  	#write-Host "Content of DeleteEmpty:"
	#write-host $editContent
	#read-host	

	return $editContent
}
function DeleteEmptyFoldersContentHE(){
	$strOut = @'
<p>
   <span class="ms-rteFontSize-2">
   <span aria-hidden="true"></span>
   <span aria-hidden="true"></span>
   <span aria-hidden="true"></span>
   לחיצה על הכפתור תסיר את כל המועמדים בעלי תיקים ריקים (0 מסמכים בתיק)&#160;מהאתר.</span>
</p>
<p>
   <span class="ms-rteFontSize-2">ניתן לבצע פעולה זו לאחר מועד הסגירה.
	<span aria-hidden="true"></span>
	<span aria-hidden="true"></span>
	<span aria-hidden="true"></span>
   </span>
</p>
'@

	return $strOut
}

function DeleteEmptyFoldersContentEN(){
	$strOut = @'
<p>
   <span class="ms-rteFontSize-2">
	<span aria-hidden="true"></span>
   Clicking on the button will remove all candidates with empty document upload&#160;folders (0 documents in the folder) from the site.</span>
</p>
<p>
   <span class="ms-rteFontSize-2">This can be done after the deadline
	<span aria-hidden="true"></span>
   </span>
</p>
'@

	return $strOut
}

function edt-Form($newSiteName, $language){
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
	
	$pageTitle  = "טופס בקשה"
	if ($newSiteName.ToLower().contains("grs")){
		$pageTitle  = "טופס הרשמה"
	}
	
	
	if ($language.ToLower().contains("en")){
		$pageTitle = "Application Form"
	}
	
	$pageFields = $page.ListItemAllFields
	#$pageContent = get-FormContent $pageFields["PublishingPageContent"] $language $relUrl
	#$pageFields["PublishingPageContent"] = $pageContent
	$PageContent = $pageFields["PublishingPageContent"]
	$oWP = Get-WPfromContent $PageContent
	$editContent = ""
	
	foreach ($wp in $oWP){
		if ($wp.isWP){
			$editContent += $wp.Content 
		}
			
		$i++
	}
    
	$pageFields["PublishingPageContent"] = 	$editContent
	$pageFields["Title"] = $pageTitle
	$pageFields.Update()
	
	$ctx.Load($pageFields)
	$ctx.ExecuteQuery();
	
	$page.CheckIn("",1)
	
	$ctx.ExecuteQuery()
	write-host "$pageName Was Updated" -foregroundcolor Green
}
function edt-WPPage($siteUrlC ,$pageURL, $wpName ,$wpKey, $wpValue){
	$siteName = get-UrlNoF5 $siteUrlC
	write-host "Change WP $wpName " -foregroundcolor Yellow 
	write-host "On $pageURL " -foregroundcolor Yellow
	write-host "on Site: $siteName" -foregroundcolor Yellow
	
	write-Host "$wpKey, $wpValue" -f Cyan

	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials

	$page = $ctx.Web.GetFileByServerRelativeUrl($pageURL);
	$webpartManager = $page.GetLimitedWebPartManager([Microsoft.Sharepoint.Client.WebParts.PersonalizationScope]::Shared);	
	
	# Write-Host 'Updating webpart "'+$wpName+'" on the page ' + $pageName -ForegroundColor Green
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
			Write-Host "WP IS : $($wp.WebPart.Title)" -f Magenta		
			if ($wp.WebPart.Title -eq $wpName){
				Write-Host "Found Web Part : $wpName" -f Green
				[Int32]$OutNumber = $null
				$valueChanged = $false

				if ([Int32]::TryParse($wpValue, [ref]$OutNumber)){
					#Write-Host "Valid Number"
					$wpValue = $OutNumber
				} else {
						
					if ($wpValue -eq "True"){
						$wp.WebPart.Properties[$wpKey] = $true
						$valueChanged = $true
					}
					if ($wpValue -eq "False"){
						$wp.WebPart.Properties[$wpKey] = $false
						$valueChanged = $true
					}
				}
				if (!$valueChanged){
					$wp.WebPart.Properties[$wpKey] = $wpValue
				}	
				if ($wp.WebPart.Title -eq "Dynamic Form - v 2.0"){
					
					#$wp.WebPart.Properties["addColumns"] = $true;
					#$wp.WebPart.Properties["addLists"] = $true;
					#$wp.WebPart.Properties["submit"] = $true;
					
				}
				
				$wp.SaveWebPartChanges();				
			}		
	}
	$page.CheckIn("Change '"+$wpName+"'", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
	$page.Publish("Change '"+$wpName+"'")
	$ctx.ExecuteQuery()
	
	
}
function edt-SubmissionWP($siteUrlC , $spObj){
	$pageName = "Pages/SubmissionStatus.aspx"
	
	$siteName = get-UrlNoF5 $siteUrlC
	write-host "Change WP On $pageName on Site: $siteName" -foregroundcolor Yellow
	
	$relUrl   = get-RelURL $siteName
	
	$pageURL  = $relUrl + $pageName
	#$language = $spObj.language
	$lang = 0
	$wpName = "SubmissionButton WP"
	
	
	if ($spObj.language.toLower().contains("en"))
	{
		$lang = 1
		
	}
	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials



	$page = $ctx.Web.GetFileByServerRelativeUrl($pageURL);
	
	$webpartManager = $page.GetLimitedWebPartManager([Microsoft.Sharepoint.Client.WebParts.PersonalizationScope]::Shared);	
	
	Write-Host 'Updating webpart "'+$wpName+'" on the page ' + $pageName -ForegroundColor Green
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
			if ($wp.WebPart.Title -eq $wpName){
				$wp.WebPart.Properties["WP_Language"] = $lang
				$wp.WebPart.Properties["EmailTemplatePath"] = $spObj.MailPath
				
				$wp.WebPart.Properties["EmailTemplateName"] = $spObj.MailFile;
				
				$wp.SaveWebPartChanges();				
			}		
	}
	$page.CheckIn("Change '"+$wpName+"'", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
	$page.Publish("Change '"+$wpName+"'")
	$ctx.ExecuteQuery()
		
}
function edt-DocUploadWP($siteUrlC , $spObj){
	$pageName = "Pages/DocumentsUpload.aspx"
	
	$siteName = get-UrlNoF5 $siteUrlC
	write-host "Change WP On $pageName on Site: $siteName" -foregroundcolor Yellow
	
	$relUrl   = get-RelURL $siteName
	
	$pageURL  = $relUrl + $pageName
	#$language = $spObj.language
    $languageWP =  1
	$configFileName = "UploadFilesHe.xml"
	$isDebug = $false
	if ($spObj.language.toLower().contains("en"))
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
				$wp.WebPart.Properties["Config_Path"] = $spObj.XMLUploadPath
				
				$wp.WebPart.Properties["Language"] = $languageWP;
				$wp.WebPart.Properties["Debug"] = $isDebug;
				
				$wp.SaveWebPartChanges();				
			}		
	}
	$page.CheckIn("Change 'UploadFilesWP'", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
	$page.Publish("Change 'UploadFilesWP'")
	$ctx.ExecuteQuery()
	
}
function edt-FormWP($siteUrlC , $spObj){
	$pageName = "Pages/Form.aspx"
	
	$siteName = get-UrlNoF5 $siteUrlC
	write-host "Change WP On $pageName on Site: $siteName" -foregroundcolor Yellow
	
	$relUrl   = get-RelURL $siteName
	
	$pageURL  = $relUrl + $pageName
	#$language = $spObj.language
	$textAlign = 0
	$textDirection = 0
	
	if ($spObj.language.toLower().contains("en"))
	{
		$textAlign = 1
		$textDirection = 1
	}
	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
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
				$wp.WebPart.Properties["fileName"] = $spObj.XMLFile
				
				$wp.WebPart.Properties["addColumns"] = $true;
				$wp.WebPart.Properties["addLists"] = $true;
				
				$wp.WebPart.Properties["textAlign"] = $textAlign;
				$wp.WebPart.Properties["textDirection"] = $textDirection;
				$wp.SaveWebPartChanges();				
			}		
	}
	$page.CheckIn("Change 'Dynamic Form - v 2.0'", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
	$page.Publish("Change 'Dynamic Form - v 2.0'")
	$ctx.ExecuteQuery()
	
}

function edt-cancelCandidacyHeWP($siteUrlC){
	$pageName = "Pages/CancelCandidacyHe.aspx"
	
	$siteName = get-UrlNoF5 $siteUrlC
	write-host "Change WP On $pageName on Site: $siteName" -foregroundcolor Yellow
	
	$relUrl   = get-RelURL $siteName
	
	$pageURL  = $relUrl + $pageName
	#$language = $spObj.language
	$textAlign = 0
	$textDirection = 0
	
	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials



	$page = $ctx.Web.GetFileByServerRelativeUrl($pageURL);
	
	$webpartManager = $page.GetLimitedWebPartManager([Microsoft.Sharepoint.Client.WebParts.PersonalizationScope]::Shared);	
	
	Write-Host 'Updating webpart "CancelApplicationButton"  from the page CancelCandidacyHe.aspx' -ForegroundColor Green
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
			if ($wp.WebPart.Title -eq "CancelApplicationButton"){
				
				$wp.WebPart.Properties["BtnTextEn"] = $wp.WebPart.Properties["BtnTextHe"]
				$wp.WebPart.Properties["YesBtnTextEn"] = $wp.WebPart.Properties["YesBtnTextHe"]
				$wp.WebPart.Properties["NoBtnTextEn"] = $wp.WebPart.Properties["NoBtnTextHe"]
				$wp.WebPart.Properties["ConfirmMsgEn"] = $wp.WebPart.Properties["ConfirmMsgHe"]
				$wp.WebPart.Properties["SuccessMsgEn"] = $wp.WebPart.Properties["SuccessMsgHe"]
				$wp.WebPart.Properties["NoBtnTextEn"] = $wp.WebPart.Properties["NoBtnTextHe"]
				$wp.WebPart.Properties["ModalWinConfirmHeaderEn"] = $wp.WebPart.Properties["ModalWinConfirmHeaderHe"]
				$wp.WebPart.Properties["ModalWinSuccessHeaderEn"] = $wp.WebPart.Properties["ModalWinSuccessHeaderHe"]
				
				$wp.SaveWebPartChanges();				
			}		
	}
	$page.CheckIn("Change 'CancelApplicationButton'", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
	$page.Publish("Change 'CancelApplicationButton'")
	$ctx.ExecuteQuery()
	
}

function get-OldDefault($oldSiteName){
	$pageName = "Pages/Default.aspx"
	$siteName = get-UrlNoF5 $oldSiteName
	
	$relUrl   = get-RelURL $siteName
	
	$pageURL  = $relUrl + $pageName
	
	#write-host $pageURL 
	#read-host


	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials



	$page = $ctx.Web.GetFileByServerRelativeUrl($pageURL);
	
	$ctx.Load($page);
    $ctx.Load($page.ListItemAllFields);
    $ctx.ExecuteQuery();


	$page.CheckOut()
	$pageFields = $page.ListItemAllFields

	$PageContent = $pageFields["PublishingPageContent"]
	
	#$page.CheckIn("",1)
	$page.UndoCheckOut()
	
	$ctx.ExecuteQuery()	
	
	return $PageContent
	
}

function get-OldDefault2Lang ($oldSiteName, $langPage){
	
	$pageName = "Pages/Default"+$langPage+".aspx"
	$siteName = get-UrlNoF5 $oldSiteName
	
	$relUrl   = get-RelURL $siteName
	
	$pageURL  = $relUrl + $pageName
	
	#write-host $pageURL 
	#read-host


	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials



	$page = $ctx.Web.GetFileByServerRelativeUrl($pageURL);
	
	$ctx.Load($page);
    $ctx.Load($page.ListItemAllFields);
    $ctx.ExecuteQuery();


	$page.CheckOut()
	$pageFields = $page.ListItemAllFields

	$PageContent = $pageFields["PublishingPageContent"]
	
	#$page.CheckIn("",1)
	$page.UndoCheckOut()
	
	$ctx.ExecuteQuery()	
	
	return $PageContent
		
}
function edt-HomePage($newSiteName, $content){
	$pageName = "Pages/Default.aspx"
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
	
	$pageFields["PublishingPageContent"] = $content
	
	$pageFields.Update()
	
	$ctx.Load($pageFields)
	$ctx.ExecuteQuery();
	
	$page.CheckIn("",1)
	
	$ctx.ExecuteQuery()
	write-host "$pageName Was Updated" -foregroundcolor Green
}
function get-HtmlInstructTag($siteURL, $htmlContent){
	$aHtmlTags = @()
	$instrHe =  'href="/home/Pages/InstructionsHe.aspx"'
	$instrEn =  'href="/home/Pages/InstructionsEn.aspx"'
	
	$instrHe =  'InstructionsHe.aspx'
	$instrEn =  'InstructionsEn.aspx'
	
    $HTML = New-Object -Com "HTMLFile"
	$HTML.IHTMLDocument2_write($htmlContent)

		$HTML.All.Tags('a') | ForEach-Object{
		 $aTag = "" | Select-Object URL,lang,innerHTML,outerHTML,innerText,outerText,href,parent
		 if ($_.outerHTML.Contains($instrHe)){
			 
			 
			$aTag.URL = $siteURL
			$aTag.innerHTML = $_.innerHTML
			$aTag.outerHTML = $_.outerHTML
			$aTag.outerText = $_.outerText
			 
			$xt = $_.innerText
			write-host "innerText: $xt" -f Cyan
			write-host "outerText: $($aTag.outerText)" -f Cyan
			 
			$aTag.innerText = $_.parentNode.innerText -replace $aTag.outerText,""
			$aTag.innerText = $aTag.innerText.Trim()
			$aTag.innerHTML = $aTag.innerHTML
			$aTag.parent = $_.parentNode.outerHTML

			$xto = $_.parentNode.innerText
			#write-host "XTO: $xto" -f Green
			 
			$xtx = $xto -replace $xt, ""
			#write-host $xtx -f Yellow
			 
			$aTag.innerText = $xtx.trim()
			$aTag.href = $_.pathname
			#$aTag.foundInFile = $fileCont.ToLower().contains($_.parentNode.outerHTML.ToLower())
			$aTag.lang = "He"
			$aHtmlTags += $aTag
			#Write-Host "He" -f Green
		}
		if ($_.outerHTML.Contains($instrEn)){
			$aTag.URL = $oldSiteURL
			$aTag.innerHTML = $_.innerHTML
			$aTag.outerHTML = $_.outerHTML
			$aTag.outerText = $_.outerText

			$xt = $_.innerText
			#write-host "XT: $xt" -f Cyan
			 
			$aTag.innerText = $_.parentNode.innerText -replace $aTag.outerText,""
			$aTag.innerText = $aTag.innerText.Trim()
			$aTag.innerHTML = $aTag.innerHTML
			$aTag.parent = $_.parentNode.outerHTML

			$xto = $_.parentNode.innerText
			#write-host "XTO: $xto" -f Green
			$xtx = $xto -replace $xt, ""
			#write-host $xtx -f Yellow
			$aTag.innerText = $xtx.trim()
			$aTag.href = $_.pathname
			 
			$aTag.lang = "En"
			$aHtmlTags += $aTag
			#Write-Host "En" -f Yellow
		}
		 
	}	
	return $aHtmlTags	
}
function repl-DefContent ($oldSiteName, $newSiteName, $pageContent){
	$siteNameOld = get-UrlWithF5 $oldSiteName
	$siteNameNew = get-UrlWithF5 $newSiteName
	
	$relUrlOld = get-RelURL $siteNameOld
	$relUrlNew = get-RelURL $siteNameNew
	$crlf = [char][int]13+[char][int]10

	$backupPageContent = $pageContent+$crlf+$crlf+"======================="+$crlf+$crlf
	#write-host "Replace content in Default Page:" -foregroundcolor Yellow
	#write-host "Find what: $relUrlOld" -foregroundcolor Yellow
	#write-host "Replace To: $relUrlNew" -foregroundcolor Yellow

	$newPageCont = $pageContent -Replace $relUrlOld, $relUrlNew	
	
	$aHtmlTags = get-HtmlInstructTag $oldSiteName $pageContent
 
    $RelURLX = Get-RelURL  $oldSiteName
    $grRelURL = $RelURLX.split("/")[-2]

	$outfile = ".\JSON\"+$grRelURL+"-HtmlTags.json"
	$aHtmlTags | ConvertTo-Json -Depth 100 | out-file $outfile -Encoding Default
	write-host "$outfile written" -f Yellow
	

    write-Host "newSiteName : $newSiteName" -f Cyan
	if (![string]::isNullOrEmpty($aHtmlTags)){
		
		$stringA = 'a href="/home/Pages/InstructionsEn.aspx" target="_blank"'
		if (!$newPageCont.contains($stringA)){
			$stringA = 'a href="/home/Pages/InstructionsEn.aspx"'
		}	
		$stringARX = 'a href="' + $newSiteName + "/Pages/DocumentsUpload.aspx"+'"'
		
		$stringATR = 'Documents Upload page'
		$stringSR  = 'B. The following documents should be uploaded via the '
		
		if ($aHtmlTags.Lang -eq "He"){
			$stringATR = "דף העלאת המסמכים"
			$stringSR  = 'ב. להעלות את המסמכים הבאים באמצעות '
			$stringA = 'a href="/home/Pages/InstructionsHe.aspx" target="_blank"'
			if (!$newPageCont.contains($stringA)){
				$stringA = 'a href="/home/Pages/InstructionsHe.aspx"'
			}				
		}
		
		# "innerText":  "ב. להעלות את המסמכים הבאים לתיקיית העלאת מסמכים אישית לפי",
		if (![string]::isNullOrEmpty($aHtmlTags.innerText)){
			$newPageCont = $newPageCont -Replace $aHtmlTags.innerText, $stringSR
		}

		# "outerText":  "ההוראות המופיעות כאן"
		$newPageCont = $newPageCont -Replace $aHtmlTags.outerText, $stringATR

		$newPageCont = $newPageCont -Replace $stringA, $stringARX
			
	}
	
				
	
	$backupPageContent += "Replace content in Default Page:" + $crlf
	$backupPageContent += "Find what: $relUrlOld" + $crlf
	$backupPageContent += "Replace To: $relUrlNew" + $crlf + $crlf+$crlf+"======================="+$crlf+$crlf
	
	$backupPageContent += $newPageCont
	$fname = $relUrlNew.split("/")[-2]
	$backupPageContent | out-file $("DefPages-Repl\"+ $fname+".html") -encoding default
	Write-Host "Replace Default Page Content" -foregroundcolor Green
	return $newPageCont
	
}
function SwitchToHeb($pageName, $newSiteName){
	$relUrl   = get-RelURL $newSiteName
	$content = '​​<div id="switch-to-lang"><div style="width: 40%; height: 5%; margin-bottom: 1%; margin-left: 66%; float: right;"> &#160;&#160;' 
    $content += '<button class="greenButton" aria-label="English Page" onclick="window.open(&#39;'
	$content += $relUrl +"Pages/" + $pageName + ".aspx"
	$content += '&#39;, &#39;_self&#39;)" type="button" style="padding: 1%; border: 3px solid #03515b; width: 20%; height: 5%; text-align: center; color: #ffffff; margin-right: 1%; float: right; display: block; background-color: #03515b;">'
	$content += '<b>English</b></button>'
	$content += '<button class="greenButton" aria-label="דף העברית" onclick="window.open(&#39;'
	$content += $relUrl +"Pages/" + $pageName + 'He.aspx'
	$content += '&#39;, &#39;_self&#39;)" type="button" formtarget="_self" style="padding: 1%; border: 3px solid #157987; width: 20%; height: 5%; text-align: center; color: #ffffff; float: right; display: block; background-color: #157987;">'
	$content += '<b>עברית</b></button></div></div>'
	
	return $content
}

function SwitchToEng($pageName, $newSiteName){
	$relUrl   = get-RelURL $newSiteName	
	$content =  '<div id="switch-to-lang">​​<div style="width: 40%; height: 5%; margin-right: 66%; margin-bottom: 1%; float: left;">&#160;&#160; &#160;&#160;'
	$content += '<button class="greenButton" aria-label="English Page" onclick="window.open(&#39;'
	$content += $relUrl +"Pages/" + $pageName + ".aspx"
	$content += '&#39;, &#39;_self&#39;)" type="button" style="padding: 1%; border: 3px solid #157987; width: 19%; height: 5%; text-align: center; color: #ffffff; margin-left: 1%; float: left; display: block; background-color: #157987;">'
	$content += '<b>English</b></button>'
	$content += '<button class="greenButton" aria-label="דף העברית" onclick="window.open(&#39;'
	$content += $relUrl +"Pages/" + $pageName + 'He.aspx'
	$content += '&#39;, &#39;_self&#39;)" type="button" style="padding: 1%; border: 3px solid #03515b; width: 19%; height: 5%; text-align: center; color: #ffffff; float: left; display: block; background-color: #03515b;">'
	$content += '<b>עברית​</b></button>​​</div></div>'
	
	return $content	
}

function change-applTemplate($newSiteName, $language){
	
	$siteName = get-UrlNoF5 $newSiteName	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials
	$List = $Ctx.Web.lists.GetByTitle("ApplicantTemplate")

    $ViewFields = $List.DefaultView.ViewFields
	$View = $list.DefaultView
    $Ctx.load($ViewFields) 
    $Ctx.load($View) 
    $Ctx.ExecuteQuery()


	$ModerationStatusExists = $($List.DefaultView.ViewFields).contains("_ModerationStatus");

	if ($ModerationStatusExists){
	   $List.DefaultView.ViewFields.Remove("_ModerationStatus")
       $List.DefaultView.Update()
       $Ctx.ExecuteQuery()
	}
	
	$qryView = '<OrderBy><FieldRef Name="_x05ea__x05d5__x05db__x05df__x0020__x05e7__x05d5__x05d1__x05e5_" /></OrderBy>'
	if ($language.ToLower().contains("en")){
		$qryView   = '<OrderBy><FieldRef Name="Document_x0020_Type" /></OrderBy>'
	}
	
	
	$View.ViewQuery = $qryView
	$view.Update();
	$ctx.ExecuteQuery();
	write-host "Updated ApplicantTemplate Default View." -foregroundcolor Green
	
	return $null
	
}
function copyXML($PathXML, $XMLFile, $PreviousXML, $language){
	$isDoubleLangugeSite = $language.toLower().contains("en") -and $language.toLower().contains("he")
	
	if (![string]::isNullOrEmpty($PreviousXML)){
		# check for exists
		$fullPrevPath = $PathXML + "\*" + $PreviousXML
		
		
		$fileNewXML   = $PathXML + "\" + $XMLFile
		
		If (Test-Path $fullPrevPath){
			if (!(Test-Path $fileNewXML)){
				$itemOld = get-item $fullPrevPath
				Copy-Item -Path $($itemOld.FullName) -Destination $fileNewXML
				if (Test-Path $fileNewXML){
					write-Host "XML File $fileNewXML succesfully created." -foregroundcolor Green
				}
				else
				{
					write-Host "Problem was with copy XML File $fileNewXML." -foregroundcolor Yellow
				}
			}
			else
			{
				Write-Host "XML File $fileNewXML already exists. Not Copied." -foregroundcolor Yellow
			}
		}
		else
		{
			Write-Host "Previous XML $filePrevXML does not found.Check for it." -foregroundcolor Yellow
		}
		
		
	}
}
function copyMail($spObj){
	
	$PathMail = $spObj.MailPath
	$MailFile = $spObj.MailFile
	$isDoubleLangugeSite = $spObj.isDoubleLangugeSite
	$language = $spObj.language
	$siteName = $spObj.siteName
	$siteNameEn = $spObj.siteNameEn
	$facultyEn = $spObj.facultyTitleEn
	$facultyHe = $spObj.facultyTitleHe
	
	#$($spRequestsListObj.MailPath) $($spRequestsListObj.MailFile) 
	#$($spRequestsListObj.PreviousMail) $($spRequestsListObj.language) 
	#$($spRequestsListObj.siteName) $($spRequestsListObj.siteNameEn)
	
	# $isDoubleLangugeSite = $language.toLower().contains("en") -and $language.toLower().contains("he")
   
	$fileNewMailEn = $PathMail + "\" + $spObj.MailFileEn
	$fileNewMailHe = $PathMail + "\" + $spObj.MailFileHe
	#write-Host $fileNewMailEn
	#write-Host $fileNewMailHe
	$contentFileEn = Get-MailContentEn $siteNameEn $facultyEn
	$contentFileHe = Get-MailContentHe $siteName $facultyHe

	if ($language.toLower().contains("en")){

		if (!(Test-Path $fileNewMailEn)){
			$contentFileEn | Out-File $fileNewMailEn -encoding Default
			write-Host "Mail File $fileNewMailEn succesfully created." -foregroundcolor Green
			
		}
		else
		{
			Write-Host "Mail File $fileNewMailEn already exists. Not Copied." -foregroundcolor Yellow

		}			
	}
	
	if ($language.toLower().contains("he")){

		if (!(Test-Path $fileNewMailHe)){
			#$TemplItem = Get-Item ".\mailTemplates\mailHe.txt"
			#
			$contentFileHe | Out-File "file-utf8.txt" -encoding "utf8"
			cmd.exe /c "cnv.cmd"
			Copy-Item "file-utf8-win.txt" $fileNewMailHe
			write-Host "Mail File $fileNewMailHe succesfully created." -foregroundcolor Yellow
			write-Host "This is Template file! Need to Edit this!." -foregroundcolor Yellow
			
		}
		else
		{
			Write-Host "Mail File $fileNewMailHe already exists. Not Copied." -foregroundcolor Yellow
		}
	}		
}
function copyUpload($spObj){
	$uploadPath = $spObj.XMLUploadPath + $spObj.XMLUploadFileName
	if (!$(Test-Path $uploadPath)){
		Write-Host  "Copying Upload File $uploadPath" -foregroundcolor Green
		if (!$(Test-Path $spObj.XMLUploadPath -PathType Container)){
		    New-Item -ItemType Directory -Force -Path $spObj.XMLUploadPath
		}
		$sourceFile = ".\UploadFiles\Template.xml"
		Copy-Item $sourceFile $uploadPath
	}
	else
	{
		Write-Host  "Upload File $uploadPath already exists. Not copyied." -foregroundcolor Yellow
	}
}
function psiconv ( $f, $t, $string ) {
	$enc = [system.text.encoding]

    $cp1          = $enc::getencoding( $f )
    $cp2          = $enc::getencoding( $t )
    $inputbytes   = $enc::convert( $cp1, $cp2, $cp2.getbytes( $string ))
    $outputstring = $cp2.getstring( $inputbytes )
    
    return  $outputstring

}
function Get-MailContentEn($siteName,$faculty){
	$crlf = [char][int]13 + [char][int]10

	$retStr  = "<br>" + $crlf
	$retStr += "Hello [SPF:firstName] [SPF:surname],<br>" + $crlf
	$retStr += "<br>" + $crlf
	$retStr += "Thank you for applying for the<br>" + $crlf
	$retStr += $siteName 
	$retStr += "<br>" + $crlf
	$retStr += "The following documents that you have uploaded were received by the system:" + $crlf
	$retStr += "[documentsListContent]" + $crlf
	$retStr += "" + $crlf
	$retStr += "<br>" +$faculty  +   $crlf + "<br>" +   $crlf
	$retStr += "The Hebrew University in Jerusalem" + $crlf

	return $retStr
}

function Get-MailContentHe($siteName,$faculty){
	$crlf = [char][int]13 + [char][int]10

	$retStr  = "<br>"+ $crlf
	$retStr += "שלום [SPF:firstNameHe] [SPF:surnameHe],<br>"+ $crlf
	$retStr += "<br>"+ $crlf
	#$retStr += "תודה על הגשה למלגה:<br>"+ $crlf
	$retStr += "תודה על הגשת מועמדותך<br>"+ $crlf
	$retStr += "<b>ל" # + $crlf
	$retStr += $siteName #+ $crlf
	$retStr += "</b>" + $crlf
	$retStr += "<br>" + $crlf
	$retStr += "<br>" + $crlf
	$retStr += "המסמכים הבאים שהעלית נקלטו במערכת:" + $crlf
	$retStr += "[documentsListContent]" + $crlf
	$retStr += "" + $crlf
	$retStr += "<br>" + $crlf
	$retStr += "בברכה,<br>" + $crlf
	$retStr += $faculty  +   "<br>" +   $crlf	
	$retStr += "האוניברסיטה העברית בירושלים" + $crlf
	
	return $retStr
}
function get-WPIdArray($sContent){
	$resArray = @()
	$aID = $sContent | Select-String -Pattern "ms-rtestate-notify  ms-rtestate-read"

	for ($i=0; $i -lt $aID.count; $i++){
		$findStr = 'id="div_'
		$nIdPos = $aID[$i].ToString().IndexOf($findStr)
		$sSubtr = $aID[$i].ToString().SubString($nIdPos+$findStr.Length)
		$nHyph  = $sSubtr.IndexOf('"')
		$resId = $sSubtr.Substring(0,$nHyph)
		
		$resArray += $resId
	}
	return $resArray
}

function Get-WPfromContent($content){
	#bebeb
	
	#$f.replace('<div class="ms-rtestate-read ms-rte-wpbox">',"\").split("\")
	#write-host $content 
	#read-host
	$findStr = '<div class="ms-rtestate-read ms-rte-wpbox"'
	$outArr = [System.Collections.ArrayList]@()
	$elObj = "" | Select-Object el1,el2,el3,el4,el5,el6
	$outstr = ""
	$webpart = $true
	$level = 0
	$j=0
	$divObjArr = @()
	#$idx  = $content.IndexOf($findStr)
	#$isCont = $content.contains($findStr) 
	#write-host "Contains: $isCont"
	#write-host "Idx: $idx"
	
	#read-host
	while ($webpart){
		if ($content.contains($findStr)){
			  
			
		      $idx  = $content.IndexOf($findStr)
			  $ostatok = $($content.substring(0,$idx))
			  
			  #write-host "Index idx: $idx"
			  #write-Host "ostatok-do : $ostatok"
			  if ($idx -gt 0 -and $ostatok -ne "</div>"){
				  if ($ostatok.length -gt 6 -and $ostatok.substring(0,6) -eq "</div>"){
					
					
					
					$ostatok = $($ostatok.substring(6,$idx-6))
					If (![string]::isNullOrEmpty($ostatok.trim())){
						#write-Host "ostatok-posle : $ostatok"
					
						$wpObj1 = "" | Select-Object Content, isWP, ID, WPType, PSEdit
						$wpObj1.Content = $ostatok
						#write-Host 3708
						#write-host $ostatok  -f Cyan
						#read-host
						$wpObj1.isWP = $false
						$asherClass = Get-ASHERClass
						$wpObj1.PSEdit = $ostatok.contains($asherClass)
						$divObjArr += $wpObj1
					}
				  }else {
						if ($ostatok.length -gt 0){
							#write-Host "ostatok-posle : $ostatok"
							
							$wpObj1 = "" | Select-Object Content, isWP, ID, WPType, PSEdit
							$wpObj1.Content = $ostatok
						#write-Host 3721
						#write-host $ostatok  -f Cyan
						#read-host
								
							$wpObj1.isWP = $false
							$asherClass = Get-ASHERClass
							$wpObj1.PSEdit = $ostatok.contains($asherClass)
							$divObjArr += $wpObj1				
						}
				  }
				  
			  }
			  
			  #read-host
			  
			  for ($i = $idx; $i -lt $content.length;$i++){
					if ($content[$i] -eq $null){
                        break					
					}
					else
					{
						$outStr += $content[$i]
						<#
						write-host "OutStr : $outStr"
						write-host "Level : $level"
						
						read-host
						#>
						if ($content[$i] -eq "<"){
							
							if (($content[$i+1] -ne $null) -and # /
							    ($content[$i+2] -ne $null) -and # d
								($content[$i+3] -ne $null) -and # i
								($content[$i+4] -ne $null)      # v

								){
									$strC = $content[$i+1]+
											$content[$i+2]+
											$content[$i+3]+
											$content[$i+4]
											
									$strC1 = $content[$i+1]+
											 $content[$i+2]+
											 $content[$i+3]
											
									if ($strC -eq "/div"){
										#write-host "/div"
										#write-host "Index :$i"
										$level--
									}
									if ($strC1 -eq "div"){
										#write-host "div"
										#write-host "Index :$i"
										$level++
									}
									
								}	# i
						}
						if ($level -eq 1){
							
							if ($j -eq 1){
								if (![string]::isNullOrEmpty($outStr)){
									$outStr += "/div>"
									$elObj.el1 = $outStr
								}
								
								
							}
							
							if ($j -eq 2){
								if (![string]::isNullOrEmpty($outStr)){
									$outStr += "/div>"
									$elObj.el2 = $outStr
								}	
							}
							if ($j -eq 3){
								if (![string]::isNullOrEmpty($outStr)){
									$outStr += "/div>"
									$elObj.el3 = $outStr
								}
							}
							if ($j -eq 4){
								if (![string]::isNullOrEmpty($outStr)){
									$outStr += "/div>"
									$elObj.el4 = $outStr
								}	
							}
							if ($j -eq 5){
								if (![string]::isNullOrEmpty($outStr)){
									$outStr += "/div>"
									$elObj.el5 = $outStr
								}	
							}
							if ($j -eq 6){
								if (![string]::isNullOrEmpty($outStr)){
									$outStr += "/div>"
									$elObj.el6 = $outStr
								}	
							}
							
							if (![string]::isNullOrEmpty($outStr)){
								$j++
							}
							if (!($outStr -eq "<")){
								$wpObj = "" | Select-Object Content, isWP, ID, WPType, PSEdit
								$wpObj.Content = $outStr
								$wpObj.isWP = $true
								$wpObj.PSEdit = $false
								$divObjArr += $wpObj
							}
							#$outArr.Add($outStr)  
							
							$content = $content.substring($i)
							
							<#
							write-host "outStr:$outStr"
							write-Host
							write-host "outArr:"
							$outArr
							write-Host
							write-host "Content: $content"
							read-host
							#>
							$outStr = ""
							break
						}
					}	
			  }
		}
		else
		{
			if ($content.trim().length -gt 0){
			    if ($content.trim().toLower().substring(0,6) -eq "</div>")
				{
					$content = $content.trim().substring(6)
					if ($content.trim().length -gt 0){
					
						$wpObj1 = "" | Select-Object Content, isWP, ID, WPType, PSEdit
						$wpObj1.Content = $content.trim()
								#write-Host 3856
								#write-host $($wpObj1.Content)  -f Cyan
								#read-host
							
						$wpObj1.isWP = $false
						$asherClass = Get-ASHERClass
						$wpObj1.PSEdit = $ostatok.contains($asherClass)
						$divObjArr += $wpObj1
					}					
				}
			}
			
			break
		}	
	}	
	
	#write-host "We are here"
	#write-host $elObj
	#read-host

	return $divObjArr
}

function Get_EndWpPosition($content){
	$findStr = '<div class="ms-rtestate-read ms-rte-wpbox">'
	$outVal = 0
	if ($content.contains($findStr)){
		$posBeg  = $content.IndexOf($findStr)
		
		$posFind = $posBeg+$findStr.length
		$posEnd  = $posFind
		
		#find closing div 
		$divLevel = 1
		$workStr = $content.Substring($posFind)
		#write-Host "123"
		#Write-Host $workStr 
		#read-host
		$pos = $posFind
		while ($divLevel -gt 0){
			$findStr = "</div>"
			$posFind = $workStr.IndexOf($findStr)+$findStr.length
			$posEnd += $posFind
			$workBuff = $workStr.substring(0,$posFind)
			
			#write-Host "333"
			#write-Host $workBuff
			#write-Host $divLevel
			#read-host
			
			$workStr = $workStr.substring($posFind)
			if ($workStr.substring(0,$posFind).contains("<div")){
				$divLevel++
				
			}
			else{
				$divLevel--
			}
			#$posFind = $workStr.IndexOf($findStr)+$findStr.length
			#$workStr = $workStr.Substring($posFind)
			#write-host $workStr
			#write-host $divLevel
			#read-host
			
		}
		$outArr += $content.Substring($posBeg,$posEnd)
		$content = $content.Substring($posEnd)
		#write-host $content 
		#read-host
		
	}
	return $posEnd	
}
function Extract-ContentFromWPPage ($content){
	
	$posWPEnd = Get_EndWpPosition $content
	return $content.Substring($posWPEnd)
}

function IS-SwitcherExists($content){
	return $content.contains("switch-to-lang");
}
function Get-ASHERClass(){
	return 'class="pse-2610"'
}
function Check-PageWasEdit($oWP)
{
	$wasEdit = $false
	foreach($wp in $oWP){
		if ($wp.PSEdit){
			$wasEdit = $true
			break
		}
	}
	return $wasEdit
}
function Gen-Cancel2LangCandidateHe ($oWP, $newSiteName){
	$content = ""
	$i = 0
	foreach($wp in $oWP){
		write-host "is Web Part : $($wp.isWP)"
		if ($wp.isWP){
			$content += $wp.Content
			
			#write-host "i =  : $i"
			if ($i -eq 1){
				$asherCont = Get-ASHERClass 
				$swToEng = SwitchToEng "CancelCandidacy" $newSiteName 
				$content += "<div "+ $asherCont+" >" + $swToEng +"</div>"
			}
			if ($i -eq 2){
				$content += CancelCandidacyContentHe
			}
			
		}
		$i++
		
	}
	return $content
}
function Check-ListExists($siteUrl,$ListTitle){
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl) 
	$ctx.Credentials = $Credentials
 
 
	$Lists = $Ctx.Web.Lists
	$Ctx.Load($Lists)
	$Ctx.ExecuteQuery()
<#
			   TypeName: Microsoft.SharePoint.Client.List

			Name                                         MemberType Definition
			----                                         ---------- ----------
			AddItem                                      Method     Microsoft.S...
			AddItemUsingPath                             Method     Microsoft.S...
			BreakRoleInheritance                         Method     void BreakR...
			CreateDocument                               Method     Microsoft.S...
			CreateDocumentAndGetEditLink                 Method     Microsoft.S...
			CreateDocumentFromTemplate                   Method     Microsoft.S...
			CreateDocumentFromTemplateBytes              Method     Microsoft.S...
			CreateDocumentFromTemplateStream             Method     Microsoft.S...
			CreateDocumentFromTemplateUsingPath          Method     Microsoft.S...
			CreateDocumentWithDefaultName                Method     Microsoft.S...
			CreateMappedView                             Method     Microsoft.S...
			CustomFromJson                               Method     bool Custom...
			DeleteObject                                 Method     void Delete...
			Equals                                       Method     bool Equals...
			FromJson                                     Method     void FromJs...
			GetBloomFilter                               Method     Microsoft.S...
			GetBloomFilterWithCustomFields               Method     Microsoft.S...
			GetChanges                                   Method     Microsoft.S...
			GetHashCode                                  Method     int GetHash...
			GetItemById                                  Method     Microsoft.S...
			GetItemByUniqueId                            Method     Microsoft.S...
			GetItems                                     Method     Microsoft.S...
			GetMappedApp                                 Method     Microsoft.S...
			GetMappedApps                                Method     Microsoft.S...
			GetRelatedFields                             Method     Microsoft.S...
			GetSpecialFolderUrl                          Method     Microsoft.S...
			GetType                                      Method     type GetType()
			GetUserEffectivePermissions                  Method     Microsoft.S...
			GetView                                      Method     Microsoft.S...
			GetWebDavUrl                                 Method     Microsoft.S...
			IsObjectPropertyInstantiated                 Method     bool IsObje...
			IsPropertyAvailable                          Method     bool IsProp...
			PublishMappedView                            Method     Microsoft.S...
			Recycle                                      Method     Microsoft.S...
			RefreshLoad                                  Method     void Refres...
			RenderExtendedListFormData                   Method     Microsoft.S...
			RenderListContextMenuData                    Method     Microsoft.S...
			RenderListData                               Method     Microsoft.S...
			RenderListDataAsStream                       Method     Microsoft.S...
			RenderListFilterData                         Method     Microsoft.S...
			RenderListFormData                           Method     Microsoft.S...
			ReserveListItemId                            Method     Microsoft.S...
			ResetRoleInheritance                         Method     void ResetR...
			Retrieve                                     Method     void Retrie...
			SaveAsNewView                                Method     Microsoft.S...
			SaveAsTemplate                               Method     void SaveAs...
			SetExemptFromBlockDownloadOfNonViewableFiles Method     void SetExe...
			SyncFlowCallbackUrl                          Method     Microsoft.S...
			SyncFlowInstances                            Method     Microsoft.S...
			SyncFlowTemplates                            Method     Microsoft.S...
			ToString                                     Method     string ToSt...
			UnpublishMappedView                          Method     Microsoft.S...
			Update                                       Method     void Update()
			ValidateAppName                              Method     Microsoft.S...
			AllowContentTypes                            Property   bool AllowC...
			AllowDeletion                                Property   bool AllowD...
			BaseTemplate                                 Property   int BaseTem...
			BaseType                                     Property   Microsoft.S...
			BrowserFileHandling                          Property   Microsoft.S...
			ContentTypes                                 Property   Microsoft.S...
			ContentTypesEnabled                          Property   bool Conten...
			Context                                      Property   Microsoft.S...
			CrawlNonDefaultViews                         Property   bool CrawlN...
			CreatablesInfo                               Property   Microsoft.S...
			Created                                      Property   datetime Cr...
			CurrentChangeToken                           Property   Microsoft.S...
			CustomActionElements                         Property   Microsoft.S...
			DataSource                                   Property   Microsoft.S...
			DefaultContentApprovalWorkflowId             Property   guid Defaul...
			DefaultDisplayFormUrl                        Property   string Defa...
			DefaultEditFormUrl                           Property   string Defa...
			DefaultItemOpenUseListSetting                Property   bool Defaul...
			DefaultNewFormUrl                            Property   string Defa...
			DefaultView                                  Property   Microsoft.S...
			DefaultViewPath                              Property   Microsoft.S...
			DefaultViewUrl                               Property   string Defa...
			Description                                  Property   string Desc...
			DescriptionResource                          Property   Microsoft.S...
			Direction                                    Property   string Dire...
			DocumentTemplateUrl                          Property   string Docu...
			DraftVersionVisibility                       Property   Microsoft.S...
			EffectiveBasePermissions                     Property   Microsoft.S...
			EffectiveBasePermissionsForUI                Property   Microsoft.S...
			EnableAssignToEmail                          Property   bool Enable...
			EnableAttachments                            Property   bool Enable...
			EnableFolderCreation                         Property   bool Enable...
			EnableMinorVersions                          Property   bool Enable...
			EnableModeration                             Property   bool Enable...
			EnableVersioning                             Property   bool Enable...
			EntityTypeName                               Property   string Enti...
			EventReceivers                               Property   Microsoft.S...
			ExcludeFromOfflineClient                     Property   bool Exclud...
			ExemptFromBlockDownloadOfNonViewableFiles    Property   bool Exempt...
			Fields                                       Property   Microsoft.S...
			FileSavePostProcessingEnabled                Property   bool FileSa...
			FirstUniqueAncestorSecurableObject           Property   Microsoft.S...
			ForceCheckout                                Property   bool ForceC...
			Forms                                        Property   Microsoft.S...
			HasExternalDataSource                        Property   bool HasExt...
			HasUniqueRoleAssignments                     Property   bool HasUni...
			Hidden                                       Property   bool Hidden...
			Id                                           Property   guid Id {get;}
			ImagePath                                    Property   Microsoft.S...
			ImageUrl                                     Property   string Imag...
			InformationRightsManagementSettings          Property   Microsoft.S...
			IrmEnabled                                   Property   bool IrmEna...
			IrmExpire                                    Property   bool IrmExp...
			IrmReject                                    Property   bool IrmRej...
			IsApplicationList                            Property   bool IsAppl...
			IsCatalog                                    Property   bool IsCata...
			IsPrivate                                    Property   bool IsPriv...
			IsSiteAssetsLibrary                          Property   bool IsSite...
			IsSystemList                                 Property   bool IsSyst...
			ItemCount                                    Property   int ItemCou...
			LastItemDeletedDate                          Property   datetime La...
			LastItemModifiedDate                         Property   datetime La...
			LastItemUserModifiedDate                     Property   datetime La...
			ListExperienceOptions                        Property   Microsoft.S...
			ListItemEntityTypeFullName                   Property   string List...
			MajorVersionLimit                            Property   int MajorVe...
			MajorWithMinorVersionsLimit                  Property   int MajorWi...
			MultipleDataList                             Property   bool Multip...
			NoCrawl                                      Property   bool NoCraw...
			ObjectVersion                                Property   string Obje...
			OnQuickLaunch                                Property   bool OnQuic...
			PageRenderType                               Property   Microsoft.S...
			ParentWeb                                    Property   Microsoft.S...
			ParentWebPath                                Property   Microsoft.S...
			ParentWebUrl                                 Property   string Pare...
			ParserDisabled                               Property   bool Parser...
			Path                                         Property   Microsoft.S...
			ReadSecurity                                 Property   int ReadSec...
			RoleAssignments                              Property   Microsoft.S...
			RootFolder                                   Property   Microsoft.S...
			SchemaXml                                    Property   string Sche...
			ServerObjectIsNull                           Property   System.Null...
			ServerTemplateCanCreateFolders               Property   bool Server...
			Tag                                          Property   System.Obje...
			TemplateFeatureId                            Property   guid Templa...
			Title                                        Property   string Titl...
			TitleResource                                Property   Microsoft.S...
			TypedObject                                  Property   Microsoft.S...
			UserCustomActions                            Property   Microsoft.S...
			ValidationFormula                            Property   string Vali...
			ValidationMessage                            Property   string Vali...
			Views                                        Property   Microsoft.S...
			WorkflowAssociations                         Property   Microsoft.S...
			WriteSecurity                                Property   int WriteSe...


#>	

    $listExists = $false
	foreach($list in $Lists){
		if ($list.Title.ToLower() -eq $ListTitle.Trim().ToLower()){
			$listExists = $true
			break
		}
	}
	
	return $listExists

}
function Create-List($siteUrl,$ListTitle,$ListDisplayTitle){
	
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl) 
	$ctx.Credentials = $Credentials
 
 
	$Lists = $Ctx.Web.Lists
	$Ctx.Load($Lists)
	$Ctx.ExecuteQuery()

<#
	$site = $Ctx.Web
	$Ctx.Load($site)
	$Ctx.ExecuteQuery()
	
	
	$Lists = $Ctx.Web.Lists
	$Ctx.Load($Lists)
	$Ctx.ExecuteQuery()
#>	
	#Create List
	$listinfo = New-Object Microsoft.SharePoint.Client.ListCreationInformation
	$listinfo.Title = $ListTitle
	$listinfo.TemplateType = [Microsoft.SharePoint.Client.ListTemplateType]'GenericList'

	$list = $Lists.Add($listinfo)
	$Ctx.ExecuteQuery()

	$list.Title = $ListDisplayTitle 
	$list.Update()
	$Ctx.Load($list)
	$Ctx.ExecuteQuery()
	
	return $null
}
function Create-ListFromTemplate($siteUrl,$ListName,$listTemplateName){
	$siteName = get-UrlNoF5 $siteURL
	
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
	$ctx.Credentials = $Credentials
 
 
	$Lists = $Ctx.Web.Lists
	$Ctx.Load($Lists)
	#Get the Custom list template
	
	$ListTemplates=$Ctx.site.GetCustomListTemplates($Ctx.site.RootWeb)
	$Ctx.Load($ListTemplates)
	$Ctx.ExecuteQuery()
	
	$ListTemplate = $ListTemplates | where { $_.Name -eq $listTemplateName } 
	If($ListTemplate -ne $Null)
	{
		#Check if the given List exists
		$List = $Lists | where {$_.Title -eq $ListName}
		If($List -eq $Null)
		{
			#Create new list from custom list template
			$ListCreation = New-Object Microsoft.SharePoint.Client.ListCreationInformation
			$ListCreation.Title = $ListName
			$ListCreation.ListTemplate = $ListTemplate
			$List = $Lists.Add($ListCreation)
			$Ctx.ExecuteQuery()
			Write-host -f Green "List Created from Custom List Template Successfully!"
		}
		else
		{
			Write-host -f Yellow "List '$($ListName)' Already Exists!"
		}
	}
	else
	{
		Write-host -f Yellow "List Template '$($ListTemplateName)' Not Found!"
	}
    return $null
}
function Delete-List($siteUrl,$ListName){
		
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl) 
	$ctx.Credentials = $Credentials
 
 
	$Lists = $Ctx.Web.Lists
	$Ctx.Load($Lists)
	
	$Ctx.ExecuteQuery()
    #$lists | gm
	$list = $Lists.GetByTitle($ListName);
	
	$list.DeleteObject()
	$Ctx.ExecuteQuery()
	return $null
}
function Rename-ListColumn($siteUrl,$ListName,$OldColumnName,$NewColumnName){
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl) 
	$ctx.Credentials = $Credentials
 
 
	$Lists = $Ctx.Web.Lists
	$Ctx.Load($Lists)
	$Ctx.ExecuteQuery()

	$list = $Lists.GetByTitle($ListName);

    #Get the column to rename
    $Field = $List.Fields.GetByInternalNameOrTitle($OldColumnName)
    $Field.Title = $NewColumnName
    $Field.Update()
    $Ctx.ExecuteQuery()
             
	return $null
	
}

function Add-FieldsToList ($siteUrl, $ListName, $SchemaXML){
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl) 
	$ctx.Credentials = $Credentials
 
 
	$Lists = $Ctx.Web.Lists
	$Ctx.Load($Lists)
	$Ctx.ExecuteQuery()

	$list = $Lists.GetByTitle($ListName);
	foreach ($xmlEl in $SchemaXML){
		<#
		AddFieldOptions Enum
		
		AddFieldCheckDisplayName	32	
AddFieldInternalNameHint	8	
AddFieldToDefaultView	16	
AddToAllContentTypes	4	
AddToDefaultContentType	1	
AddToNoContentType	2	
DefaultValue	0
		#>
		$($xmlEl.XML)
		$list.Fields.AddFieldAsXml($xmlEl.XML,$false,[Microsoft.SharePoint.Client.AddFieldOptions]::AddFieldToDefaultView) | out-null
	}
	$Ctx.ExecuteQuery()
	
    foreach($el in $SchemaXML){
		$idxEl = $el.XML.ToUpper().IndexOf("NAME=")+6
		$subst1 = $el.XML.Substring($idxEl);
		$delim = "'"
		if ($subst1.contains('"')){
			$delim = '"'
		}
		$nameOld = $subst1.Split($delim)[0]
		
		Rename-ListColumn $siteUrl $ListName $nameOld $el.DisplayName
	}	
	
	return $null	
	
}
function Log-Generate($spObj,$newSite){
	$htmlTemplate = get-content "HtmlLog\index.html" -encoding UTF8
	$outLog = "Log\" + $spObj.GroupName+ ".html"
	
	$htmlTemplate = $htmlTemplate.Replace("%GroupName%",$spObj.GroupName)
	$htmlTemplate = $htmlTemplate.Replace("%Site Name%",$spObj.siteName)
	$htmlTemplate = $htmlTemplate.Replace("%MailSuffix%",$spObj.mailSuffix)
	$htmlTemplate = $htmlTemplate.Replace("%siteName%",$spObj.siteName)
	$htmlTemplate = $htmlTemplate.Replace("%siteNameEn%",$spObj.siteNameEn)
	$contactTitle = $spObj.contactFirstNameEn + " " + $spObj.contactLastNameEn
	$htmlTemplate = $htmlTemplate.Replace("%contactTitle%",$contactTitle)
	$htmlTemplate = $htmlTemplate.Replace("%contactEmail%",$spObj.contactEmail)
	$htmlTemplate = $htmlTemplate.Replace("%Language%",$spObj.language)
	$htmlTemplate = $htmlTemplate.Replace("%isDoubleLangugeSite%",$spObj.isDoubleLangugeSite)
	$htmlTemplate = $htmlTemplate.Replace("%Faculty%",$spObj.facultyTitleEn)
	$oldSiteURL  = get-SiteNameFromNote $spObj.Notes
	$htmlTemplate = $htmlTemplate.Replace("%PreviousSite%",$oldSiteURL)
	if ($spObj.isDoubleLangugeSite){
		$pathXmlEn = $spObj.PathXML + "\" + $spObj.XMLFileEn
		$pathXmlHe = $spObj.PathXML + "\" + $spObj.XMLFileHe
		
		$pathMailEn = $spObj.MailPath + "\" + $spObj.MailFileEn
		$pathMailHe = $spObj.MailPath + "\" + $spObj.MailFileHe
		
		
		$htmlTemplate = $htmlTemplate.Replace("%XMLEn%",$spObj.XMLFileEn)
		$htmlTemplate = $htmlTemplate.Replace("%XMLHe%",$spObj.XMLFileHe)
		$htmlTemplate = $htmlTemplate.Replace("%MailEn%",$spObj.MailFileEn)
		$htmlTemplate = $htmlTemplate.Replace("%MailHe%",$spObj.MailFileHe)
		$htmlTemplate = $htmlTemplate.Replace("%PathXMLEn%",$pathXmlEn)
		$htmlTemplate = $htmlTemplate.Replace("%PathXMLHe%",$pathXmlHe)
		$htmlTemplate = $htmlTemplate.Replace("%pathMailHe%",$pathMailHe)
		$htmlTemplate = $htmlTemplate.Replace("%pathMailEn%",$pathMailEn)
		
		
		
	}
	else
	{
		$pathXmlEn = $spObj.PathXML + "\" + $spObj.XMLFile
		$pathXmlHe = $spObj.PathXML + "\" + $spObj.XMLFile
		
        if ($spObj.language.ToLower().contains("en")){
			$pathMailEn = $spObj.MailPath + "\" + $spObj.MailFileEn
			$pathMailHe = $pathMailEn
			$htmlTemplate = $htmlTemplate.Replace("%MailEn%",$spObj.MailFileEn)
			$htmlTemplate = $htmlTemplate.Replace("%MailHe%",$spObj.MailFileEn)
			
		}
		else
		{
			$pathMailHe = $spObj.MailPath + "\" + $spObj.MailFileHe
			$pathMailEn = $pathMailHe
			$htmlTemplate = $htmlTemplate.Replace("%MailEn%",$spObj.MailFileHe)
			$htmlTemplate = $htmlTemplate.Replace("%MailHe%",$spObj.MailFileHe)
			
		}
		
		
		$htmlTemplate = $htmlTemplate.Replace("%XMLEn%",$spObj.XMLFile)
		$htmlTemplate = $htmlTemplate.Replace("%XMLHe%",$spObj.XMLFile)
		$htmlTemplate = $htmlTemplate.Replace("%PathXMLEn%",$pathXmlEn)
		$htmlTemplate = $htmlTemplate.Replace("%PathXMLHe%",$pathXmlHe)
		$htmlTemplate = $htmlTemplate.Replace("%pathMailHe%",$pathMailHe)
		$htmlTemplate = $htmlTemplate.Replace("%pathMailEn%",$pathMailEn)
	

		
	}
	
	$htmlTemplate = $htmlTemplate.Replace("%SystemList%",$spObj.systemListName)
	$htmlTemplate = $htmlTemplate.Replace("%SystemListUrl%",$(get-UrlWithF5 $spObj.systemListUrl))
	$htmlTemplate = $htmlTemplate.Replace("%userAcc%",$spObj.userName)
	$htmlTemplate = $htmlTemplate.Replace("%deadLineText%",$spObj.deadLineText)
	$oldAdmGroup = get-GrpByUrl $spObj.oldSiteURL
	$htmlTemplate = $htmlTemplate.Replace("%SourceGroup%",$oldAdmGroup)
	$newSite = get-UrlWithF5 $newSite
	$htmlTemplate = $htmlTemplate.Replace("%URL%",$newSite)
	$htmlTemplate = $htmlTemplate.Replace("%targetAudiency%",$spObj.targetAudiency)
	$htmlTemplate = $htmlTemplate.Replace("%targetAudiencysharepointGroup%",$spObj.targetAudiencysharepointGroup)
	#Write-Host "%RelURL%: $($spObj.RelURL)"
	$htmlTemplate = $htmlTemplate.Replace("%RelURL%",$spObj.RelURL)
	
	$htmlTemplate | Out-File $outLog -encoding UTF8 | out-null
	Invoke-Expression $outLog
	return $null
}
function get-FormFieldsOrder($listName,	$siteURL){
	$fieldOrder = @()
	$siteName = get-UrlNoF5 $siteURL
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
	
	$ctx.Credentials = $Credentials
 
 
	$Lists = $Ctx.Web.Lists
	$Ctx.Load($Lists)
	$Ctx.ExecuteQuery()
	
	$List = $Ctx.Web.lists.GetByTitle($listName)
	
	$contentTypes = $list.ContentTypes
    $ctx.Load($contentTypes)
	$ctx.ExecuteQuery()
	
	$itemContenType = $contentTypes[0]
	$ctx.Load($itemContenType)
	$ctx.ExecuteQuery()
	
	$FieldLinks = $itemContenType.FieldLinks
	$ctx.Load($FieldLinks)
	$ctx.ExecuteQuery()
	
    foreach($el in $FieldLinks){
		if (!$($el.Name -eq "ContentType")){
			$fieldOrder += $el.Name
		}
	}		
	
	return $fieldOrder
}
function reorder-FormFields($listName,	$siteURL,$fieldOrder){
	Write-Host "Reorder Fields on $listName" -foregroundcolor Green	
	$siteName = get-UrlNoF5 $siteURL
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
	$ctx.Credentials = $Credentials
 
 
	$Lists = $Ctx.Web.Lists
	$Ctx.Load($Lists)
	$Ctx.ExecuteQuery()
	
	$List = $Ctx.Web.lists.GetByTitle($listName)
	
	$contentTypes = $list.ContentTypes
    $ctx.Load($contentTypes)
	$ctx.ExecuteQuery()
	
	$itemContenType = $contentTypes[0]
	$ctx.Load($itemContenType)
	$ctx.ExecuteQuery()
	
	$FieldLinks = $itemContenType.FieldLinks
	$ctx.Load($FieldLinks)
	$ctx.ExecuteQuery()
	

	$FieldLinks.Reorder($fieldOrder);
	$itemContenType.Update($false);
	$ctx.ExecuteQuery()
	Write-Host "Done"  -foregroundcolor Green	
	return $null
}
function checkForArrElExists($srcArr,$destArr){
	$resultArr = @()
	foreach($srcEl in $srcArr){
		$found = $false
		foreach($dstEl in $destArr){
			if ($srcEl -eq $dstEl){
				$resultArr += $srcEl
				$found = $true
				break;
			}
		}
		if (!$found){
			write-Host "checkForArrElExists : $srcEl not exists in Destination" -foregroundcolor Yellow
		}
	}
	return $resultArr
}
function Get-AllViews($listName,	$siteURL){
	$arrViews = @()
	$siteName = get-UrlNoF5 $siteURL
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
	
	$ctx.Credentials = $Credentials
 
 
	$Lists = $Ctx.Web.Lists
	$Ctx.Load($Lists)
	$Ctx.ExecuteQuery()
	
	$List = $Ctx.Web.lists.GetByTitle($listName)
	
	
	$viewCollection = $List.Views
	$Ctx.Load($viewCollection)
	$Ctx.ExecuteQuery()
		
	foreach($view in $viewCollection){
		$viewFieldsColl = $view.ViewFields
		$Ctx.Load($viewFieldsColl)
		$Ctx.ExecuteQuery()
	
		$objView = "" | Select-Object DefaultView,Aggregations,Title, ServerRelativeUrl,ViewQuery,Fields
		$objView.DefaultView = $view.DefaultView
		$objView.Aggregations =  $view.Aggregations
		$objView.Title =  $view.Title
		$objView.ServerRelativeUrl =  $view.ServerRelativeUrl
		$objView.ViewQuery =  $view.ViewQuery
		
		$arrFields = @()
		foreach($fld in $viewFieldsColl)
		{
			$arrFields += $fld
		}
		$objView.Fields = $arrFields
		
		#$view | gm
		#$view | fl
		#write-Host $view.Title
		$arrViews += $objView
	}
	return $arrViews	
}
function Check-ViewExists($listName,	$siteURL, $viewObj){
	$viewExists = "" | Select-Object Exists, Title, TitleOld
	$viewExists.Exists = $false
	$viewExists.Title = $null
	
	$siteName = get-UrlNoF5 $siteURL
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
	
	$ctx.Credentials = $Credentials
 
 
	$Lists = $Ctx.Web.Lists
	$Ctx.Load($Lists)
	$Ctx.ExecuteQuery()
	
	$List = $Ctx.Web.lists.GetByTitle($listName)
	
	
	$viewCollection = $List.Views
	$Ctx.Load($viewCollection)
	$Ctx.ExecuteQuery()
		
	foreach($view in $viewCollection){
		$relUrls = $view.ServerRelativeUrl.split("/")[-1]
		# write-Host $relUrls -> AllItems.aspx
		$relUrlo = $viewObj.ServerRelativeUrl.split("/")[-1]
		
		if (($relUrls -eq $relUrlo) -or ($view.Title -eq $viewObj.Title)){
			#Write-Host "Site View : $relUrls"
			#Write-Host "Obj View : $relUrlo"
			$viewExists.Exists = $true
			$viewExists.Title = $view.Title
			$viewExists.TitleOld = $viewObj.Title
			break
		}
		
	}
	
	return $viewExists
}
function check-FieldInView($listName, $viewTitle, $siteURL, $firstField){
	$fieldInView = $false
	$siteName = get-UrlNoF5 $siteURL
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
	
	$ctx.Credentials = $Credentials
 
 
	$Lists = $Ctx.Web.Lists
	$Ctx.Load($Lists)
	$Ctx.ExecuteQuery()
	
	$List = $Ctx.Web.lists.GetByTitle($listName)
	
	
	$view = $List.Views.getByTitle($viewTitle)	
	$viewFieldsColl = $view.ViewFields
	$Ctx.Load($viewFieldsColl)
	$Ctx.ExecuteQuery()
		

	foreach($fld in $viewFieldsColl){
		if ($fld -eq $firstField){
			$fieldInView = $true
			break
		}
	}

	
	return $fieldInView
}
function Add-FieldInView($listName, $viewTitle, $siteURL, $firstField){
	$fieldInView = $false
	$siteName = get-UrlNoF5 $siteURL
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
	
	$ctx.Credentials = $Credentials
 
 
	$Lists = $Ctx.Web.Lists
	$Ctx.Load($Lists)
	$Ctx.ExecuteQuery()
	
	$List = $Ctx.Web.lists.GetByTitle($listName)
	$view = $List.Views.getByTitle($viewTitle)
    $view.ViewFields.Add($firstField)
	$view.Update()
	$Ctx.ExecuteQuery()
	return $null
	
}
function remove-AllFieldsFromViewButOne($listName, $viewTitle, $siteURL, $firstField){
	
	$siteName = get-UrlNoF5 $siteURL
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
	
	$ctx.Credentials = $Credentials
 
 
	$Lists = $Ctx.Web.Lists
	$Ctx.Load($Lists)
	$Ctx.ExecuteQuery()
	
	$List = $Ctx.Web.lists.GetByTitle($listName)
	$view = $List.Views.getByTitle($viewTitle)


	$viewFieldsColl = $view.ViewFields
	$Ctx.Load($viewFieldsColl)
	$Ctx.ExecuteQuery()
		
    For($i = $viewFieldsColl.Count -1 ; $i -ge 0; $i--){
	    $fieldN = $viewFieldsColl[$i]
		
		if (!$($fieldN -eq $firstField)){
			#write-host $fieldN 
			#write-host $firstField 
			#write-host "Equ: $($fieldN -eq $firstField)"
			
			$view.ViewFields.Remove($fieldN)
			$view.Update()
			$Ctx.ExecuteQuery()
		}
	}	
	return $null
}
function Add-FieldsToView($listName, $viewTitle, $siteURL, $Fields){
	
	$siteName = get-UrlNoF5 $siteURL
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
	
	$ctx.Credentials = $Credentials
 
 
	$Lists = $Ctx.Web.Lists
	$Ctx.Load($Lists)
	$Ctx.ExecuteQuery()
	
	$List = $Ctx.Web.lists.GetByTitle($listName)
	$view = $List.Views.getByTitle($viewTitle)
	
	
    For($i = 1 ; $i -lt $Fields.Count; $i++){ 	
            $fieldN = $Fields[$i]	
		    write-host $fieldN
			$view.ViewFields.Add($fieldN)
			$view.Update()
			$Ctx.ExecuteQuery()		
	}
	return $null	
}
function Rename-View($listName, $viewTitle, $siteURL,$newTitle,$viewQuery){
	
	$siteName = get-UrlNoF5 $siteURL
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
	$ctx.Credentials = $Credentials
 
	$Lists = $Ctx.Web.Lists
	$Ctx.Load($Lists)
	$Ctx.ExecuteQuery()
	
	$List = $Ctx.Web.lists.GetByTitle($listName)
	$view = $List.Views.getByTitle($viewTitle)
	
	$view.Title = $newTitle	
	$view.Update()
	$Ctx.ExecuteQuery()
	return $null	
}
function Create-NewView($siteURL,$listName,$viewTitle,$viewFields,$viewQuery, $viewAggregations, $viewDefault)
{
	$siteName = get-UrlNoF5 $siteURL
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
	$ctx.Credentials = $Credentials
 
	$Lists = $Ctx.Web.Lists
	$Ctx.Load($Lists)
	$Ctx.ExecuteQuery()
	$List = $Ctx.Web.lists.GetByTitle($listName)
	
	$ViewCreationInfo = New-Object Microsoft.SharePoint.Client.ViewCreationInformation
	
    $ViewCreationInfo.Title = $viewTitle
    $ViewCreationInfo.Query = $viewQuery
    $ViewCreationInfo.ViewFields = $viewFields
    $ViewCreationInfo.SetAsDefaultView = $viewDefault
   
    $NewView =$List.Views.Add($ViewCreationInfo)
    $Ctx.ExecuteQuery() 

    if (![string]::isNullOrEmpty($viewAggregations)){
		$NewView.Aggregations = $viewAggregations
	}
	$NewView.Update()
	$Ctx.ExecuteQuery()	
 	
	return $null	
}
function ConvHexFieldToName($str){
	$result = ""
	$aStr = $str.split("_x")
    for($i=0;$i -lt $aStr.count;$i++){
		if (![string]::isNullOrEmpty($aStr[$i])){
			$result += [char][int]$([Convert]::ToString("0x"+$aStr[$i],10))
		}
	}
	return $result
}
function Get-NavigationMenu($siteURL){
	$menu = @()
	$siteName = get-UrlNoF5 $siteURL
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
	$ctx.Credentials = $Credentials
 
	$QuickLaunch = $Ctx.Web.Navigation.QuickLaunch
	
	$Ctx.load($QuickLaunch)
	$Ctx.ExecuteQuery()
 	
    foreach($QuickLaunchLink in $QuickLaunch){	
		$Ctx.Load($QuickLaunchLink)
		$Ctx.Load($QuickLaunchLink.Children)
		$Ctx.ExecuteQuery()
		
		$menuItem = "" | Select-Object Title,Url, Children, IsDocLib, IsExternal, IsVisible
		$menuItem.Url = $QuickLaunchLink.Url
		$menuItem.Title = $QuickLaunchLink.Title
		$menuItem.Children = $false
		$menuItem.IsDocLib = $false
		$menuItem.IsExternal = $false
		$menuItem.IsVisible = $false
		$menu += $menuItem
		
		$child = $QuickLaunchLink.Children
		 
		foreach($childItem in $child) {
			$Ctx.Load($childItem)
			
			$Ctx.ExecuteQuery()
			$menuItem = "" | Select-Object Title,Url, Children, IsDocLib, IsExternal, IsVisible
			$menuItem.Url = $childItem.Url
			$menuItem.Title = $childItem.Title
			$menuItem.Children = $true
			$menuItem.IsDocLib = $childItem.IsDocLib
			$menuItem.IsExternal = $childItem.IsExternal
			$menuItem.IsVisible = $childItem.IsVisible
			$menu += $menuItem
				
			#$childItem | gm
			
			#$childItem 
		}		
	}
 
	
	return $menu
}
function Add-MemberToSpGroup($siteURL, $spGroupName, $UserAccount)
{
	$siteName = get-UrlNoF5 $siteURL
	$retValue = ""

	Try {
		#Setup the context
		$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
		$ctx.Credentials = $Credentials
		 
		#Get the Web and Group
		$Web = $Ctx.Web
		$Group= $Web.SiteGroups.GetByName($spGroupName)
	    
		#ensure user sharepoint online powershell - Resolve the User
		$User=$web.EnsureUser($UserAccount)
	 
		#Add user to the group
		$Result = $Group.Users.AddUser($User)
		$Ctx.Load($Result)
		$Ctx.ExecuteQuery()
	 
		write-host  -f Green "User '$UserAccount' has been added to '$spGroupName'"
	}
	Catch {
		
		write-host -f Yellow "Error Adding user '$UserAccount' to '$spGroupName' !" $_.Exception.Message
		$retValue = $UserAccount
	}
	
	return $retValue

	
}
function get-PermDifference($newSuffix, $OldSuffix,  $ListPermSrc, $ListPermDst, $ListName){
	$perm ="" #| Select List, Permdiff
	#$perm.List = $ListName
	#$perm.Permdiff = @()
	foreach ($permSrc in $ListPermSrc){
		$permSrcName =  $permSrc.Name 
		$permSrcNameNew = $permSrc.Name
		$permSrcLevelNew = $permSrc.PermissionLevels
		
		#Write-host "5035 $permSrcName $OldSuffix $($permSrcName.ToUpper().Contains($OldSuffix.toUpper()))"
		if ($permSrcName.ToUpper().Contains($OldSuffix.toUpper())){
			$permSrcNameNew = $permSrcName.toUpper() -Replace $OldSuffix.ToUpper(),$newSuffix.toUpper()
			#write-Host $permSrcNameNew -f Cyan
		}
		#Write-Host $permSrcName -f Cyan

		$permExistInDestination = $false
		forEach($permDst in $ListPermDst){
			#$permDst.PermissionLevels = $permDst.PermissionLevels -Replace "Limited Access", ""
			#$permDst.PermissionLevels = $permDst.PermissionLevels -Replace ",", ""
			
			#Write-Host "List: $ListName" -f Green
			#write-Host $permDst.PermissionLevels
			$permSrcLevelNew = $permSrcLevelNew -Replace ",Limited Access",""
			#write-Host $permSrcLevelNew -f Magenta
			if ($permDst.Name -eq $permSrcNameNew){
				if ( $permDst.PermissionLevels.Contains($permSrcLevelNew)){
					$permExistInDestination = $true
					break
				}
			}
		}
		if (!$permExistInDestination){
			
			Write-Host "List: $ListName" -f Yellow
			Write-Host "$permSrcNameNew $permSrcLevelNew not Found In Destination" -f Cyan
			
			$perm += $permSrcNameNew + ";"
		}
		
	}
	return $perm 
}
	

function get-DestListObjPerm($newSuffix, $OldSuffix, $spSrc, $ListName, $ListPerm){
	$resultPerm = ""
	#$objPermArr = @()
	foreach($itemMenu in $spSrc){
		forEach($itemSubm in $itemMenu.Items){
			if ($itemSubm.Type -eq "Lists" -or $itemSubm.Type -eq "DocLib" ){		
				if ($itemSubm.Name -eq $ListName){
					#write-Host "Find $ListName" -f Green
					$resultPerm = get-PermDifference $newSuffix $OldSuffix $itemSubm.ListPermissons $ListPerm $ListName
					break
				}
			}
		}
	}
	return $resultPerm
}
function Delete-RecentMainMenu($siteURL,$MenuTitle){
	$siteName = get-UrlNoF5 $SiteURL
	write-host "Delete-RecentMainMenu: $siteURL" -foregroundcolor Green
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
	    
		if (($QuickLaunchLink.Title -eq $MenuTitle) ){
			$QuickLaunchLink.DeleteObject()
			$Ctx.ExecuteQuery()
			break			
		}
	}	
}
function Delete-RecentsSubMenu($siteURL,$MenuTitle){
	$siteName = get-UrlNoF5 $SiteURL
	write-host "Delete Recent Submenus: $siteURL" -foregroundcolor Green
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
	$ctx.Credentials = $Credentials
 	
	$Web = $Ctx.Web
	$ctx.Load($Web)
	$Ctx.ExecuteQuery()
	
	$menuDump = @()
	
	$QuickLaunch = $Ctx.Web.Navigation.QuickLaunch
	
	$Ctx.load($QuickLaunch)
	$Ctx.ExecuteQuery()
	$isItemWasDeleted = $false
 	#write-host 18
	$noMoreSubItems = $false
	$recentMenuFound = $false
    foreach($QuickLaunchLink in $QuickLaunch){	
	    
		if (($QuickLaunchLink.Title -eq $MenuTitle) ){
			write-host $QuickLaunchLink.Title -f Yellow	
			$recentMenuFound = $true
					
			#write-host $QuickLaunchLink.Url
			#write-host $QuickLaunchLink.Title

			$child = $QuickLaunchLink.Children
			$Ctx.load($child)
			$Ctx.ExecuteQuery()
			if ($child.Count -gt 0){
				For($i = $child.Count -1 ; $i -ge 0; $i--){
				
					$subItem = $child[$i]
					$Ctx.Load($subItem)
					
					$Ctx.ExecuteQuery()
					
					
					write-host $subItem.Title -f Yellow
					$subItem.DeleteObject()
					$Ctx.ExecuteQuery()
					$isItemWasDeleted = $true
					
				}

				
			}
			else
			{
				$noMoreSubItems	= $true
			}
		}
		if ($isItemWasDeleted){
			break
		}
		
		#read-host
	}
	if (!$recentMenuFound){
		 $noMoreSubItems	= $true
	}
	
	
	return $noMoreSubItems
	
	
}
function Get-FiveRandomLetters()
{
	return $(-join ((65..90) + (97..122) | Get-Random -Count 5 | % {[char]$_}))
}
function Create-WPPage($siteURL,$pageName,$PageTitle, $lang){
	$siteName = get-UrlNoF5 $SiteURL
	$sucess = $false
	#write-Host "5590: Create-WPPage"
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
		#$ListItem["PublishingPageContent"] = $PageContent
		$ListItem.Update()
		$Ctx.ExecuteQuery()
		#Write-host -f Green "Done!"
		 
		#Publish the page
		Write-host -f Yellow "Checking-In and Publishing the Page..." -NoNewline
		$ListItem.File.CheckIn([string]::Empty, [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
		$ListItem.File.Publish([string]::Empty)
		$Ctx.ExecuteQuery()
		Write-host -f Green "Done!"
		$sucess = $true

	}
	
	return $sucess
}
function Create-PublishingPages($siteURL, $oldSiteURL, $menuItems){
	
	forEach ($menuItm in $menuItems){
		
		forEach($itm in $menuItm.Items){
			
			if ($itm.Type -eq "Pages" ){
				
				if (!$itm.IsOldMenu){
					#write-Host 5286
					if ($itm.Url.Contains("/Pages/")){
						$pageCreated = Create-WPPage $siteURL $itm.InnerName $itm.Title #"כתב ויתור על סודיות רפואית"
						if ($pageCreated){
							write-Host "5686: Oldsite Url: $oldSiteURL" -f Magenta
							write-Host "5687: site Url: $siteURL" -f Magenta
							write-Host "5688: old Page: $($itm.OldUrl)" -f Magenta
							write-Host "5689: new Page: $($itm.Url)" -f Magenta
						}
					}
				}
			}
		}
	}
}
function change-HeadingURL($siteURL,$URIaddress){
	$menuApplEn = "Application"
	$menuApplHe = "הגשת מועמדות"
 	
	$siteUrlC = get-UrlNoF5 $siteURL
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrlC)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials


	$QuickLaunch = $Ctx.Web.Navigation.QuickLaunch
	
	$Ctx.load($QuickLaunch)
	$Ctx.ExecuteQuery()
 	
    foreach($QuickLaunchLink in $QuickLaunch){	

		$Ctx.Load($QuickLaunchLink)
		#$Ctx.Load($QuickLaunchLink.Children)
		$Ctx.ExecuteQuery()
		
		if (($QuickLaunchLink.Title -eq $menuApplEn ) -or
			($QuickLaunchLink.Title -eq $menuApplHe )){
			
			$QuickLaunchLink.Url = $URIaddress
			$QuickLaunchLink.Update()
			$Ctx.ExecuteQuery()			
			write-host "Updated Heading $($QuickLaunchLink.Title)" -f Green
			write-host "Updated URL to $URIaddress" -f Green

		}

	}
	
	return $null

}
function copy-ImgFiles($imgObjSrc,$imgObjDst){

	$mountPointSrc = get-UrlNoF5 $("https://"+$imgObjSrc.DNSHost+$imgObjSrc.DocLib)
	$mountPointDst = get-UrlNoF5 $("https://"+$imgObjDst.DNSHost+$imgObjDst.DocLib)
	
#write-Host 	"5650: $mountPointSrc"
#write-Host 	"5651 $mountPointDst"
#write-Host Press a key ...

#read-host
	net use w: /del | out-null #source
	net use y: /del | out-null # dest
	
	net use w: $mountPointSrc /user:ekmd\ashersa GrapeFloor789 | out-null
	net use y: $mountPointDst /user:ekmd\ashersa GrapeFloor789 | out-null
	
	$source = "w:" + $imgObjSrc.relDir+$imgObjSrc.docName
	$destPath = "y:"+$imgObjDst.relDir
	$destination = $destPath+$imgObjDst.docName
	
	if(Test-Path $source){
		

		if (!$(Test-Path $destPath)){
			New-Item -Path $destPath -ItemType directory
		}
		
		if (!$(Test-Path $destination)){
				write-host "Copy From: $source" -f Green
				write-host "Copy To: $destination" -f Green
				Copy-Item -Path $source -Destination $destination
				write-host "Ok" -f Green
		}
	}
	else
	{
		write-host "$source Does not Exists" -f Yellow
	}
	net use w: /del | out-null #source
	net use y: /del | out-null # dest
	
}
function get-PageAndTitleContent($oldSiteName,$pageName){
	
	$siteName = get-UrlNoF5 $oldSiteName
	
	$relUrl   = get-RelURL $siteName
	
	$pageURL  = $relUrl + $pageName
	
	if (!$pageURL.contains(".aspx")){
		$pageURL += ".aspx"
	}
	
    $pageTitlAndCont = "" | Select Title, Content
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	$Ctx.Credentials = $Credentials



	$page = $ctx.Web.GetFileByServerRelativeUrl($pageURL);
	
	$ctx.Load($page);
    $ctx.Load($page.ListItemAllFields);
    $ctx.ExecuteQuery();


	$page.CheckOut()
	$pageFields = $page.ListItemAllFields

	$pageTitlAndCont.Content = $pageFields["PublishingPageContent"]
	$pageTitlAndCont.Title   = $pageFields["Title"]
	#$page.CheckIn("",1)
	$page.UndoCheckOut()
	
	$ctx.ExecuteQuery()	
	
	return $pageTitlAndCont
	
}

function get-ImgDocLib($htmlContent, $siteURL){
	$siteDomain = $([System.Uri]$siteURL).Host
	$aHtmlTags = @()

	$HTML = New-Object -Com "HTMLFile"
	$HTML.IHTMLDocument2_write($htmlContent)

		$HTML.All.Tags('img') | ForEach-Object{
		 $aTag = "" | Select-Object href,docLib,docLibName,relDir, docName,DNSHost
		     
			$aTag.href = [uri]::UnescapeDataString($_.href)
			$aTag.docName = [uri]::UnescapeDataString($_.nameProp)
			$aTag.docLib = [uri]::UnescapeDataString($_.href).replace($aTag.docName,"").replace("about:","")
			$aTag.href = [uri]::UnescapeDataString($_.href).replace("about:","")
			
			$aTag.DNSHost =  $([System.Uri]$aTag.docLib).Host
			
			
			if ([string]::isNullOrEmpty($aTag.docLib)){
				$aTag.docLib = $aTag.href.replace($aTag.docName,"")
			}
			if ([string]::isNullOrEmpty($aTag.DNSHost)){
				$aTag.DNSHost = $siteDomain
			}
			
			$libRealName = getListOrDocName $siteURL $aTag.docLib "DocLib"
			$aTag.docLibName = $libRealName

			#$aTag.foundInFile = $fileCont.ToLower().contains($_.parentNode.outerHTML.ToLower())
			if ($aTag.DocLib.toLower() -ne "/home/logo/"){
				if ([string]::isNullOrEmpty($aTag.docLibName)){
					$aDoclib = $aTag.docLib.split("/")
					$xCount  = $aTag.docLib.split("/").Count
					
					$docLibNameFound = $false
					while(!$docLibNameFound){
						$xDoclib = "/"
						for($i=0;$i -lt $xCount; $i++){
							if (![string]::isNullOrEmpty($aDoclib[$i])){
								$xDoclib += $aDoclib[$i] + "/"
							}
						}
						if ($xDoclib -eq "/"){
							break
						}
						$libRealName = getListOrDocName $siteURL $xDoclib "DocLib"
						if (![string]::isNullOrEmpty($libRealName)){
							$docLibNameFound = $true
							$aTag.docLibName = $libRealName
							
							
						}
						$xCount--
						
					}
					$chkDocLib = $aTag.docLib
				}
				
				write-Host "5868: siteURL : $siteURL ;libRealName: $libRealName " -f Yellow
				if (![string]::isNullOrEmpty($libRealName)){
					$aTag.docLib = get-ListURL $siteURL $libRealName
					$aTag.relDir = $aTag.href.toLower().replace($aTag.docLib.toLower(),"").replace($aTag.docName.toLower(),"")
				}
				
				
				
				$aHtmlTags += $aTag
			}
				
		}
	$OutFileName = ".\JSON\RPL-"+$siteDomain+"-aHtmlTags.json"			
	$aHtmlTags | ConvertTo-Json -Depth 100 | out-file $OutFileName -Encoding Default	
	write-Host "$OutFileName Created..."

	return $aHtmlTags		
	
}
function get-ListURL($siteURL, $listName){
	$siteName = get-UrlNoF5 $siteURL	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	$Ctx.Credentials = $Credentials
	$lists = $ctx.web.Lists 
	$list = $lists.GetByTitle($listName) 
    $Ctx.load($List) 
	$Ctx.Load($list.RootFolder);
    $Ctx.ExecuteQuery()	
	
	return  $list.RootFolder.ServerRelativeUrl
	
}
function copy-ImgLib($siteURL,$oldSiteURL){
	
	
   $oldSiteURL = 	 get-UrlNoF5 $oldSiteURL
   $siteUrl    =   get-UrlNoF5 $siteUrl
   $siteName   =  $siteUrl
	
   
	
	$siteDumpObj = "" | Select-Object Source, Destination
	$sourceObj   = "" | Select-Object URL, RelPath, Lists, Pages      
	$DestObj     = "" | Select-Object URL, RelPath, Lists, Pages
	$RelURLSrc =  get-RelURL $siteUrl
	
	$sourceObj.Url = $oldSiteURL
	$sourceObj.RelPath = get-RelURL $oldSiteURL
		
	$DestObj.URL   = $siteUrl
	$DestObj.RelPath = $RelURLSrc

    $RelURL = get-RelURL $oldSiteURL
    $PagesName = getListOrDocName $oldSiteURL $($RelURL+"Pages") "DocLib"
    $SitePagesName = getListOrDocName $oldSiteURL $($RelURL+"SitePages") "DocLib"

	$pageItems = get-allListItemsByID $oldSiteURL $PagesName
	$SPages = @()

	foreach ($itm in $pageItems){
		$pgObj = "" | Select-Object URL, Name, InnerName
		$pgObj.URL = $itm["FileRef"]
		$pgObj.Name = $pgObj.URL.split("/")[-2]+"/"+$pgObj.URL.split("/")[-1]
		$pgObj.InnerName = $pgObj.URL.split("/")[-1].Replace(".aspx","")
		#$pgObj.WebParts = get-PageWebPartAll $oldSiteURL $pgObj.URL
		$SPages += $pgObj
	}			

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
	
	foreach($itm in $PagesToCreate){
		if ($itm.InnerName.contains("Default")){
			$objPageCont = get-PageAndTitleContent $oldSiteURL $itm.Name
			$contNew = $objPageCont.Content -Replace $RelURL,$RelURLSrc
			$titl =  $objPageCont.Title 
			
			$aImgsNew = get-ImgDocLib	$contNew 				 $siteName		
			$aImgsOld = get-ImgDocLib	$objPageCont.Content	 $oldSiteURL
			
			
	#<#		
	$OutFileName = ".\JSON\RPL-OLD-aImgTags.json"			
	$aImgsOld | ConvertTo-Json -Depth 100 | out-file $OutFileName -Encoding Default	
	write-Host "$OutFileName Created..."
	
	$OutFileName = ".\JSON\RPL-NEW-aImgTags.json"			
	$aImgsNew | ConvertTo-Json -Depth 100 | out-file $OutFileName -Encoding Default	
	write-Host "$OutFileName Created..."
	#>		
			copy-ImgFiles $aImgsOld $aImgsNew 

		}
	}
}
function Save-spRequestsFileAttachements($spObj){
	#write-host $spObj.ID -f Green	
	#write-host $spObj.GroupName -f Green

	#$attachementsPath = $spObj.spAttachementsPath
 	
	$siteURL = $spObj.spRequestsSiteURL
	$listName = $spObj.spRequestsListName
	
	$siteUrlC = get-UrlNoF5 $siteURL
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrlC)
	$Ctx.Credentials = $Credentials
	$Web = $Ctx.Web
	$ctx.Load($Web)
	$Ctx.ExecuteQuery()
    $listName = "spRequestsFiles"
	$List = $Ctx.Web.lists.GetByTitle($ListName)

	$Ctx.Load($List)
	$Ctx.Load($list.RootFolder)
	$Ctx.Load($list.RootFolder.Files)
	$Ctx.Load($list.RootFolder.Folders)
	$Ctx.ExecuteQuery()
	
	$flds = $list.RootFolder.Folders
	$fldLink = $spObj.FolderLink.substring($spObj.FolderLink.LastIndexOf("/")+1).ToUpper().Trim()
	
	foreach($fld in $flds){
		if ($fldLink -eq $fld.Name.ToUpper()){
			$Ctx.Load($fld.Files)
			$Ctx.ExecuteQuery()
			if ($fld.Files.Count -gt 0){
				write-host "Saving SP $listName Attachements..." -f Green
				foreach($attachment in $fld.Files){
					$fileContent = [Microsoft.SharePoint.Client.File]::OpenBinaryDirect($Ctx, $attachment.ServerRelativeUrl)
					$downloadPath = Join-Path $spObj.spAttachementsPath $attachment.Name
					write-host $downloadPath -f Cyan
					$fileStream = [System.IO.File]::Create($downloadPath)
					$fileContent.Stream.CopyTo($fileStream)
					$fileStream.Close()
				}
			}			
			break
		}
	}
}
function Get-spReqFileAttachPath($saveDirPrefix,$groupName){
	If (!(Test-Path -path $saveDirPrefix))
	{   
		$wDir = New-Item $saveDirPrefix -type directory
	}
	else
	{
		$wDir = Get-Item $saveDirPrefix 
	
	}	
	$saveFullPath = Join-Path $saveDirPrefix $groupName
	If (!(Test-Path -path $saveFullPath))
	{   
		$wDir = New-Item $saveFullPath -type directory
	}
	else
	{
		$wDir = Get-Item $saveFullPath 
	
	}
	$attachementsPath = $wDir.FullName
 	return $attachementsPath
}