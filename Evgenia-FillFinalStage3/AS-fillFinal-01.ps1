#Fill Final PowerShell Script
function get-FrendlyDate($dtNow){
	$dtNowS = $dtNow.Year.ToString() + "-" +$dtNow.Month.ToString().PadLeft(2,"0") + "-"+$dtNow.Day.ToString().PadLeft(2,"0") + " " + $dtNow.Hour.ToString().PadLeft(2,"0")+":"+$dtNow.Minute.ToString().PadLeft(2,"0")+":"+$dtNow.Second.ToString().PadLeft(2,"0")
	return 	$dtNowS
}
function Test-ListExists($LsFolders, $innerListName){
	$lsName = $null
	foreach($xFolder in $LsFolders){
		#write-host $xFolder.RootFolder
		#write-host $innerListName
		
		if ($xFolder.RootFolder.ToString().Trim() -eq $innerListName){
			$lsName = $xFolder.Title
			#write-host 11
			#write-host $lsName
			#write-host Press key ...
			#read-host
			return $lsName
			#break
		}
	}
	return $null
}
function dst-AddItem($siteUrl, $listName, $dstItm){

	$dstLookUpListMikzoa = get-LookUpList $siteUrl $dstLookUpNameMikzoa
	$dstLookUpListSugMaslul = get-LookUpList $siteUrl $dstLookUpNameSugMaslul
 	$dstLookUpListMaslul = get-LookUpList $siteUrl $dstLookUpNameMaslul

	$dstweb = Get-SPWeb $siteUrl
	$dstList = $dstweb.Lists[$listName]
	
	#Create a new item
	$listItm = $dstList.AddItem()
	
	$x = dst-UpdFields
	$listItm.Update()		
	return $null
	
}
function dst-UpdFields(){
	$listItm["שם פרטי"] 	= $dstItm.firstName
	$listItm["שם משפחה"] = $dstItm.surname
	$listItm["תעודת זהות"] = $dstItm.studentId
	$listItm['דוא"ל'] 	= $dstItm.email
	$phone = $dstItm.mobile.Trim()
	if ([string]::IsNullOrEmpty($phone)){
		$phone = $dstItm.homePhone.Trim()
	}
	if ([string]::IsNullOrEmpty($phone)){
		$phone = $dstItm.workPhone.Trim()
	}
	if ([string]::IsNullOrEmpty($phone)){
		$phone = $dstItm.cellPhone.Trim()
	}	
	$listItm["טלפון"] 	= $phone
	$listItm["סטטוס טיפול"]= $dstItm.StatusTipul  #$dstItm.
	
	$tlink = $null; 
	$tlink = new-object Microsoft.SharePoint.SPFieldUrlValue($listItm["folderLink"])
	$tlink.Description = "תיק אישי"
	$tlink.Url = $dstweb.RootFolder.ServerRelativeUrl+$dstItm.studentId.ToString()
	$listItm["folderLink"] = $tlink.ToString(); 	
	
	$listItm["סטטוס לימודים"]= 'פעיל' # $dstItm.
	$listItm["שנת לימודים"] = 'תשפ"ג-2023' # $dstItm.
	
	
    $mikozoa1 = get-LookupIdByValue  $dstLookUpListMikzoa $dstItm.MikzoaKabala
    $mikozoa2 = get-LookupIdByValue  $dstLookUpListMikzoa $dstItm.MikzoaKabala2
    $mikozoa3 = get-LookupIdByValue  $dstLookUpListMikzoa $dstItm.MikzoaKabala3
	$sugMaslul = get-LookupIdByValue  $dstLookUpListSugMaslul $dstItm.SugMaslul
	$Maslul = get-LookupIdByValue  $dstLookUpListMaslul $dstItm.MaslulKabala
	$listItm["מקצוע קבלה 1"] = $mikozoa1 # $dstItm.
	$listItm["מקצוע קבלה 2"] = $mikozoa2 #$dstItm.
	$listItm["מקצוע קבלה 3"] = $mikozoa3 #$dstItm.
	$listItm["סוג מסלול"] = $sugMaslul #$dstItm.
	$listItm["מסלול"] = $Maslul  # $dstItm.
	
	return $null

	
}
function dst-EditItem($siteUrl, $listName, $dstItm, $ItemID){
	$dstLookUpListMikzoa = get-LookUpList $siteUrl $dstLookUpNameMikzoa
	$dstLookUpListSugMaslul = get-LookUpList $siteUrl $dstLookUpNameSugMaslul
 	$dstLookUpListMaslul = get-LookUpList $siteUrl $dstLookUpNameMaslul
	
	$dstweb = Get-SPWeb $siteUrl
	$dstList = $dstweb.Lists[$listName]
	
    #write-host "Record ID: $ItemID"
	$listItm = $dstList.GetItembyID($ItemID)
	
	$x = dst-UpdFields
	
	$listItm.Update()		
	return $null
	
}
function get-LookUpList($siteUrl,$dstLookUpName){
	$outList = @()
	$dstweb = Get-SPWeb $siteUrl
	$dstList = $dstweb.Lists[$dstLookUpName]
	foreach($itm in $dstList.Items){
		$outListItem = "" | Select ID,Title
		$outListItem.ID = $itm.ID
		$outListItem.Title = $itm["Title"]
		$outList += $outListItem
	}
	return 	$outList
	
}
function get-LookupIdByValue($LookupList,$lookUpValue){
    $retVal = 1
	#write-host $lookUpValue
	foreach($itm in $LookupList){
		#write-host $itm.Title
		if ($itm.Title -eq $lookUpValue){
			$retVal = $itm.ID
			break
		}
		
	}

	return $retVal	
}
function clear-SrcExportFileFlag($candyID){
	$hmeweb = Get-SPWeb  $srcSiteUrl
	$wrkLst = $hmeweb.Lists[$srcList]	
	$listItm = $wrkLst.GetItembyID($candyID)
	$listItm["Export_Files"] = $false
	$listItm.Update()
	$wrkLst.Update()
}
function copy-PersFiles($cList){
	foreach($cItem in $cList){
		
		#creating personal folder		
        $persFolder = Get-Item $PersFilesDownloadPath
		$sIDDir  = $persFolder.FullName + "\"+  $cItem.StudentID
		If (!(Test-Path -path $sIDDir))
		{   
			$LocalFolder = New-Item $sIDDir -type directory
		}
		
		$foldLinkURL = $cItem.folderLink
		#write-host "139 : $foldLinkURL" -f Yellow
		#write-host "141 : $sIDDir" -f Yellow
		$CPPersFolder = $homeweb.GetFolder($foldLinkURL)
		ForEach ($cpFile in $CPPersFolder.Files){
			#Download the file
			$Data = $cpFile.OpenBinary()
			$FilePath= Join-Path $sIDDir $cpFile.Name
					
			[System.IO.File]::WriteAllBytes($FilePath, $Data)
			#write-host "Saved File : '$FilePath'" -f Cyan
			
			#$cpFile.Name
		}
		#write-host "144 " -f Yellow
		
		
		#$cItem.folderLink | gm
		#read-host
	}
}

$logFile = "AS-fillFinal-01.log"
Start-Transcript $logFile

Add-PsSnapin Microsoft.SharePoint.PowerShell

$cultureHE = [System.Globalization.CultureInfo]::CreateSpecificCulture("he-IL")
$cultureEN = [System.Globalization.CultureInfo]::CreateSpecificCulture("en-US") 

$dtNow = Get-Date
$dtNowStr = get-FrendlyDate $dtNow

$srcSiteUrl   = "https://grs.ekmd.huji.ac.il/home/Education/EDU63-2022/"
$dstSiteUrl   = "https://portals.ekmd.huji.ac.il/home/EDU/stdFolders/"

$asherTest = $true
if ($asherTest){
	
	$srcSiteUrl   = "https://gss.ekmd.huji.ac.il/home/Humanities/HUM16-2020/"
	$dstSiteUrl   = "https://gss.ekmd.huji.ac.il/home/Humanities/HUM15-2020"
	
}


$srcList  = "applicants"
$srcResponses = "ResponseLetters"
$dstListName  = "לימודי הוראה"
$rspDownloadPath = "C:\temp\SPF-Downloads"
$PersFilesDownloadPath = "C:\temp\SPFPersFiles-Downloads"

$srcFieldName = "סטאטוס טיפול בתיק"

$dstLookUpNameMaslul    = "teachCertTracks"
$dstLookUpNameSugMaslul = "teachCertTrackType"
$dstLookUpNameMikzoa    = "techCertSubjects"

$script=$MyInvocation.InvocationName

write-host "Script For Fill Final version 2022-05-18.1"           #$logFileName
write-host "Asher Sandler	: mailTo:AsherSa@ekmd.huji.ac.il"           #$logFileName
write-host "Start time		:  <$dtNowStr>"           #$logFileName
write-host "User			:  <$whoami>"        #$logFileName
write-host "Running ON		:  <$ENV:Computername>" #$logFileName
write-host "Script file		:  <$script>"        #$logFileName
write-host "Log file		:  <$logFile>"        #$logFileName

$homeweb = Get-SPWeb  $srcSiteUrl
$wrkList = $homeweb.Lists[$srcList]
$rspList = $homeweb.Lists[$srcResponses]




if (!([string]::IsNullOrEmpty($wrkList) -or 
		[string]::IsNullOrEmpty($rspList))){
	
	Write-Host "Opened Web  : $srcSiteUrl" -f Green
	Write-Host "Opened List : $srcList" -f Green
	try{	
		$rspItems = $rspList.Items
		
		if ($rspItems.Count -gt 0){
			$rspRootFolder = $rspList.RootFolder.Url
			$SPFolder = $homeweb.GetFolder($rspRootFolder)
			write-host "rspRootFolder: $rspRootFolder" -f Yellow
			$rsItemsArr = @()			
			foreach($rspItem in $rspItems){
				$rspItm = "" | Select FileLeafRef,Title,Description,oFile
				
				
				$rspItm.FileLeafRef = $rspItem["FileLeafRef"] #שם
				$rspItm.Title = $rspItem.DisplayName # ["Title"] #כותרת
				$rspItm.Description = $rspItem["description0"] #description
				ForEach ($xFile in $SPFolder.Files){
					if ($xFile.Name.ToUpper() -eq $rspItm.FileLeafRef.ToUpper()){
						[Microsoft.SharePoint.SPFile]$rspItm.oFile = $xFile
						$rsItemsArr += $rspItm
						break;
					}
					
				}
				

			}
			
			$spQuery = New-Object Microsoft.SharePoint.SPQuery
			$spQuery.Query = "<Where><Eq><FieldRef Name='Export_Files' /><Value Type='Boolean'>1</Value></Eq></Where>"
			$spQuery.ViewAttributes = 'Scope="Recursive"'
			$wrkItems = $wrkList.GetItems($spQuery)
			
			$candidatesList = @()
			if (![string]::IsNullOrEmpty($wrkItems)){
				write-host "found $($wrkItems.count) Records"
				foreach ($fitm in $wrkItems){
					if ($fitm[$srcFieldName].contains("קבלה")){
						
						$Itm = "" | Select ID,Title,Attachments,firstName,surname,gender,citizenship,email,homePhone,workPhone,cellPhone,address,country,zip,academTitle,city,state,academTitleHe,firstNameHe,surnameHe,IdHe,addressHe,countryHe,cityHe,zipHe,citizenshipHe,userName,folderMail,genderHe,folderLink,birthYear,folderName,studentId,deadline,mobile,submit,documentsCopyFolder,A,birthDate,subject1,subject2,subject3,classAcademy,workshopOutstanding,extendedTrackRegistration,firstDegreeInstitute,firstDegreeCurrentYear,firstDegreeDepartment1,firstDegreeDepartmentGrade1,firstDegreeDepartment2,firstDegreeDepartmentGrade2,secondDegreeInstitute,secondDegreeDepartment,secondDegreeCurrentYear,secondDegreeGrade,PhDInstitute,PhDField,PhDYear,immigration,hebrewKnowledge,teachingExp,learningDisability,challengeOrDifficulty,declaration,SugMaslul,MaslulKabala,MikzoaKabala,MikzoaKabala2,MikzoaKabala3,HugAshlama,HugAshlama2,StatusTipul,lastSubmit,Notes,AgreementUseInformation,Completion,finishInOneYear,Export_Files,FileLeafRef,FileDescription,oFile

						$Itm.ID = $fitm.ID 
						$Itm.Title = $fitm["Title"] #כותרת
						$Itm.Attachments = $fitm["Attachments"] #קבצים מצורפים
						$Itm.firstName = $fitm["firstName"] #firstName
						$Itm.surname = $fitm["surname"] #surname
						$Itm.gender = $fitm["gender"] #gender
						$Itm.citizenship = $fitm["citizenship"] #citizenship
						$Itm.email = $fitm["email"] #email
						$Itm.homePhone = $fitm["homePhone"] #homePhone
						$Itm.workPhone = $fitm["workPhone"] #workPhone
						$Itm.cellPhone = $fitm["cellPhone"] #cellPhone
						$Itm.address = $fitm["address"] #address
						$Itm.country = $fitm["country"] #country
						$Itm.zip = $fitm["zip"] #zip
						$Itm.academTitle = $fitm["academTitle"] #academTitle
						$Itm.city = $fitm["city"] #city
						$Itm.state = $fitm["state"] #state
						$Itm.academTitleHe = $fitm["academTitleHe"] #academTitleHe
						$Itm.firstNameHe = $fitm["firstNameHe"] #firstNameHe
						$Itm.surnameHe = $fitm["surnameHe"] #surnameHe
						$Itm.IdHe = $fitm["IdHe"] #IdHe
						$Itm.addressHe = $fitm["addressHe"] #addressHe
						$Itm.countryHe = $fitm["countryHe"] #countryHe
						$Itm.cityHe = $fitm["cityHe"] #cityHe
						$Itm.zipHe = $fitm["zipHe"] #zipHe
						$Itm.citizenshipHe = $fitm["citizenshipHe"] #citizenshipHe
						$Itm.userName = $fitm["userName"] #userName
						$Itm.folderMail = $fitm["folderMail"] #folderMail
						$Itm.genderHe = $fitm["genderHe"] #genderHe
						#write-host ($fitm["folderLink"]).split(",")[0]  -f Magenta
						$Itm.folderLink = ($fitm["folderLink"]).split(",")[0] #folderLink
						$Itm.birthYear = $fitm["birthYear"] #birthYear
						$Itm.folderName = $fitm["folderName"] #folderName
						$Itm.studentId = $fitm["studentId"] #studentId
						$Itm.deadline = $fitm["deadline"] #deadline
						$Itm.mobile = $fitm["mobile"] #mobile
						$Itm.submit = $fitm["submit"] #submit
						$Itm.documentsCopyFolder = $fitm["documentsCopyFolder"] #documentsCopyFolder
						$Itm.A = $fitm["A"] #A
						$Itm.birthDate = $fitm["birthDate"] #birthDate
						$Itm.subject1 = $fitm["subject1"] #subject1
						$Itm.subject2 = $fitm["subject2"] #subject2
						$Itm.subject3 = $fitm["subject3"] #subject3
						$Itm.classAcademy = $fitm["classAcademy"] #classAcademy
						$Itm.workshopOutstanding = $fitm["workshopOutstanding"] #workshopOutstanding
						$Itm.extendedTrackRegistration = $fitm["extendedTrackRegistration"] #extendedTrackRegistration
						$Itm.firstDegreeInstitute = $fitm["firstDegreeInstitute"] #firstDegreeInstitute
						$Itm.firstDegreeCurrentYear = $fitm["firstDegreeCurrentYear"] #firstDegreeCurrentYear
						$Itm.firstDegreeDepartment1 = $fitm["firstDegreeDepartment1"] #firstDegreeDepartment1
						$Itm.firstDegreeDepartmentGrade1 = $fitm["firstDegreeDepartmentGrade1"] #firstDegreeDepartmentGrade1
						$Itm.firstDegreeDepartment2 = $fitm["firstDegreeDepartment2"] #firstDegreeDepartment2
						$Itm.firstDegreeDepartmentGrade2 = $fitm["firstDegreeDepartmentGrade2"] #firstDegreeDepartmentGrade2
						$Itm.secondDegreeInstitute = $fitm["secondDegreeInstitute"] #secondDegreeInstitute
						$Itm.secondDegreeDepartment = $fitm["secondDegreeDepartment"] #secondDegreeDepartment
						$Itm.secondDegreeCurrentYear = $fitm["secondDegreeCurrentYear"] #secondDegreeCurrentYear
						$Itm.secondDegreeGrade = $fitm["secondDegreeGrade"] #secondDegreeGrade
						$Itm.PhDInstitute = $fitm["PhDInstitute"] #PhDInstitute
						$Itm.PhDField = $fitm["PhDField"] #PhDField
						$Itm.PhDYear = $fitm["PhDYear"] #PhDYear
						$Itm.immigration = $fitm["immigration"] #immigration
						$Itm.hebrewKnowledge = $fitm["hebrewKnowledge"] #hebrewKnowledge
						$Itm.teachingExp = $fitm["teachingExp"] #teachingExp
						$Itm.learningDisability = $fitm["learningDisability"] #learningDisability
						$Itm.challengeOrDifficulty = $fitm["challengeOrDifficulty"] #challengeOrDifficulty
						$Itm.declaration = $fitm["declaration"] #declaration
						$Itm.SugMaslul = $(New-Object Microsoft.SharePoint.SPFieldLookupValue($fitm["סוג מסלול"])).LookupValue #סוג מסלול
						$Itm.MaslulKabala = $(New-Object Microsoft.SharePoint.SPFieldLookupValue($fitm["מסלול קבלה"])).LookupValue #מסלול קבלה
						$Itm.MikzoaKabala = $(New-Object Microsoft.SharePoint.SPFieldLookupValue($fitm["מקצוע קבלה"])).LookupValue #מקצוע קבלה
						$Itm.MikzoaKabala2 = $(New-Object Microsoft.SharePoint.SPFieldLookupValue($fitm["מקצוע קבלה 2"])).LookupValue #מקצוע קבלה 2
						$Itm.MikzoaKabala3 = $(New-Object Microsoft.SharePoint.SPFieldLookupValue($fitm["מקצוע קבלה 3"])).LookupValue #מקצוע קבלה 3
						$Itm.HugAshlama = $(New-Object Microsoft.SharePoint.SPFieldLookupValue($fitm["חוג השלמה"])).LookupValue #חוג השלמה
						$Itm.HugAshlama2 = $(New-Object Microsoft.SharePoint.SPFieldLookupValue($fitm["חוג השלמה 2"])).LookupValue #חוג השלמה 2
						$Itm.StatusTipul = $fitm["סטאטוס טיפול בתיק"] #סטאטוס טיפול בתיק
						$Itm.lastSubmit = $fitm["lastSubmit"] #lastSubmit
						$Itm.Notes = $fitm["הערות"] #הערות
						$Itm.AgreementUseInformation = $fitm["AgreementUseInformation"] 
						$Itm.Completion = $fitm["השלמות"] #השלמות
						$Itm.finishInOneYear = $fitm["finishInOneYear"] #finishInOneYear
						$Itm.Export_Files = $fitm["Export_Files"] #Export_Files
						
						#check for this Student ID exists in Response Letters
						foreach($rsLtrItem in $rsItemsArr){
							$rsLtrStudId = $rsLtrItem.Title.ToString().Trim()
							$itmStudId = $Itm.studentId.ToString().Trim()
							if ($rsLtrStudId -eq $itmStudId){
								$Itm.FileLeafRef = $rsLtrItem.FileLeafRef
								$Itm.FileDescription= $rsLtrItem.Description
								[Microsoft.SharePoint.SPFile]$Itm.oFile= [Microsoft.SharePoint.SPFile]$rsLtrItem.oFile
								# add to Object only if File Exists in Reponse Letters
								$candidatesList	+= $Itm	
								#$Itm.userName
								#$Itm.StatusTipul
								break;
							}
						}
					}
				}
				
				# Create Download folder
				If (!(Test-Path -path $rspDownloadPath))
				{   
					$LocalFolder = New-Item $rspDownloadPath -type directory
				}
				
				Remove-Item -path $PersFilesDownloadPath -recurse -force				
				If (!(Test-Path -path $PersFilesDownloadPath))
				{   
					$LocalFolder = New-Item $PersFilesDownloadPath -type directory
				}
				# Clean DownLoad Folder
				Get-ChildItem $rspDownloadPath -Include *.* -Recurse |  ForEach  { $_.Delete()}
				Get-ChildItem $PersFilesDownloadPath -Include *.* -Recurse |  ForEach  { $_.Delete()}
				copy-PersFiles $candidatesList
				
				# Save Files To Download Directory
				foreach ($candidate in $candidatesList){
					#Download the file
					$Data = $candidate.oFile.OpenBinary()
					$FilePath= Join-Path $rspDownloadPath $candidate.oFile.Name
					
					[System.IO.File]::WriteAllBytes($FilePath, $Data)
					write-host "Saved File : '$FilePath'" -f Green
				}
				
				# Create User Document Library on Destination Site
				write-host "Open Destination site: $dstSiteUrl" -f Green
				$dstweb = Get-SPWeb $dstSiteUrl
				$LsFolders = $dstweb.Lists | Select Title, RootFolder
				foreach($xCandy in $candidatesList){
					$innerListName = $xCandy.studentId.ToString().Trim()
					$externalListName = $xCandy.folderName
					$listName = Test-ListExists $LsFolders $innerListName
					if ($listName -eq $null){
						write-host "Folder $innerListName Does not exists" -f Yellow
						write-host "Folder externalName : $externalListName" -f Yellow
						
						$t=$dstweb.Lists.Add($innerListName, $externalListName, "DocumentLibrary")
						$dstweb = Get-SPWeb $dstSiteUrl

						$SpList = $dstweb.Lists[$innerListName]
						$SpList.Title = $externalListName
						$SpList.Update()
						$SpList.TitleResource.SetValueForUICulture($cultureHE, $externalListName)
						$SpList.TitleResource.SetValueForUICulture($cultureEN, $externalListName)
						$SpList.TitleResource.Update()	
						Write-Host "Document Library Created: '$externalListName'" -f Green							
						Write-Host "Internal Name: $innerListName" -f Green							
					}
					$dstweb = Get-SPWeb $dstSiteUrl
					$LsFolders = $dstweb.Lists | Select Title, RootFolder
					$listName = Test-ListExists $LsFolders $innerListName
					Write-Host "Document Library With Internal Name '$innerListName' `nExists: '$listName'" -f Green

					$foldersNew = @()
					<#
					$userTikFldName = "מסמכים אישיים (תיק אישי)"
					$foldersNew += $userTikFldName
					$foldersNew += "מכתב קבלה + החלטת רכז"
					$foldersNew += "תכנית לימודים"
					$foldersNew += "אישורים אקדמיים"
					$foldersNew += "הערכה של הכשרה מעשית"
					$foldersNew += "מלגות"
					$foldersNew += "אישורי ביניים לפתיחת תיק במשרד החינוך ו  או אישור זכאות לתעודת הוראה"
					#>
					$persFilesFold= "1. מסמכים אישיים (תיק אישי)"
					$userTikFldName = "2. מכתב קבלה + החלטת רכז"
					
					$foldersNew += $persFilesFold
					$foldersNew += $userTikFldName
					
					$foldersNew += "3. תכנית לימודים"
					$foldersNew += "4. אישורים אקדמיים"
					$foldersNew += "5. הערכה של הכשרה מעשית"
					$foldersNew += "6. מלגות"
					$foldersNew += "7. אישורי ביניים לפתיחת תיק במשרד החינוך ו(או) אישור זכאות לתעודת הוראה"
					
					# Create User Folders on Destination DocLib
					write-host "Check for User Folders DocLib" -f Green
					$destDocLib = $dstweb.Lists[$listName]
					
					foreach($fldNew in $foldersNew){
						#Check Folder Doesn't exists in the Library!
						$folder = $destDocLib.ParentWeb.GetFolder($destDocLib.RootFolder.Url + "/" +$fldNew);
						#sharepoint powershell check if folder exists
						If(!$folder.Exists)
						{
						   #Create a Folder
						   $folder = $destDocLib.AddItem([string]::Empty, [Microsoft.SharePoint.SPFileSystemObjectType]::Folder, $fldNew)
						   $folder.Update();
						   write-host "Created Folder '$fldNew'" -f Green
						}
					}

					#change Default View of DocLib
					write-host "change Default View of DocLib"
					$defaultView = $destDocLib.DefaultView
					$defaultView.ViewFields.DeleteAll();
					#$defaultView.ViewFields.Add("Author");
					#$defaultView.ViewFields.Add("Created");
					$defaultView.ViewFields.Add("LinkFilename");
					$defaultView.ViewFields.Add("DocIcon");
					$defaultView.Update()
					$destDocLib.Update()
					
					$FilePath= Join-Path $rspDownloadPath $xCandy.oFile.Name
					#Get File Name from Path
					$dstFileName = $FilePath.Substring($FilePath.LastIndexOf("\")+1)

					#Get the Files collection 
					$dstweb = Get-SPWeb $dstSiteUrl
					$xdstList = $dstweb.Lists[$listName]
					$xRootFolderName = $xdstList.RootFolder.Url + "/" +$userTikFldName
				    $xdstFolder = $dstweb.GetFolder($xRootFolderName) 
					$xdstFiles = $xdstFolder.Files
					
                    $xFullPath = $xRootFolderName+"/"+$dstFileName
	
					
					$xUplFile = Get-Item $FilePath
					#Add File to the Document Library
					
					write-host "Upload file to DocLib: '$xFullPath'" -f Yellow
					
					$nl = $xdstFiles.Add($xFullPath,$xUplFile.Open('Open', 'Read', 'Read') ,$true)
					
					# copy files from Personal Folder
					$persFolder = Get-Item $PersFilesDownloadPath
					$studDir  = $persFolder.FullName + "\"+  $xCandy.StudentID
					write-host 494
					write-host $studDir
					$userFldFiles = Get-ChildItem $studDir
					write-host 495
					$uRootFolderName = $xdstList.RootFolder.Url + "/" +$persFilesFold
					$udstFolder = $dstweb.GetFolder($uRootFolderName) 
					$udstFiles = $udstFolder.Files
					
					foreach($xuserFile in $userFldFiles){
						#$uUplFile = Get-Item $xuserFile
						$uFullPath = $uRootFolderName+"/"+$xuserFile.Name
						$nl = $udstFiles.Add($uFullPath,$xuserFile.Open('Open', 'Read', 'Read') ,$true)
						write-host $xuserFile.FullNameName -f Yellow
						write-host $uFullPath -f Green
						
					}
					write-host 501
					$dstweb.Dispose()

				}
				
	
				foreach($cndX in $candidatesList){
					
					#$cndX # Delete !!!
					
					[system.gc]::Collect()
					$candStdID = $cndX.studentId.ToString().Trim()
					$dstweb = Get-SPWeb $dstSiteUrl
					$dstList = $dstweb.Lists[$dstListName]
					$dstSpQuery = New-Object Microsoft.SharePoint.SPQuery
					write-host $candStdID
					$dstSpQuery.Query = "<Where><Eq><FieldRef Name='StudentID' />
					<Value Type='Text'>$candStdID</Value></Eq></Where>"
					$dstSpQuery.ViewAttributes = 'Scope="Recursive"'
					$dstItems = $dstList.GetItems($dstSpQuery)
					#$dstItems.Count
					if ($dstItems.Count -eq 1){
						write-host "Edit Record"
						dst-EditItem $dstSiteUrl $dstListName $cndX $dstItems.ID
					}
					else
					{
						if ($dstItems.Count -eq 0){	
							write-host "Add Record"
							dst-AddItem $dstSiteUrl $dstListName $cndX
						}
						else
						{
							write-host "461: Error: For StudentID '$candStdID' too many records count: $($dstItems.Count) in list '$dstListName' on site '$dstSiteUrl'"	
						}
					}	
					
				}
				foreach($candyP in $candidatesList){
					if (!$asherTest){
						clear-SrcExportFileFlag $candyP.ID
					}
				}
				[system.gc]::Collect()
				
			}
			else
			{
				Write-Host "Collection of items Applicants Empty : $srcList" -f Yellow	
			}				
		}
		else
		{
			Write-Host "Collection of items Response Empty : $srcResponses" -f Yellow	
			
		}

	}catch 
	{ 
		write-host $_.exception 
	} 	
}
else
{
	Write-Host "Lists : $srcList does not exists" -f Yellow
	Write-Host "Or    : $srcResponses does not exists" -f Yellow
	
}
[system.gc]::Collect()
Stop-Transcript

$ts = gc $logFile -raw

$supportEmail  = "supportsp@savion.huji.ac.il"

if (!$asherTest){
	$sendMail = $false
	if ($ts.contains("Error")){
		$sendMail = $true
	}
	else{
		if (!$ts.contains("Collection of items Applicants Empty")){
			$sendMail = $true
		}
	}

	if ($sendMail){
		Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersa@ekmd.huji.ac.il"  -Bcc $supportEmail -From $doNotReply  -Subject "AS-FillFinal-01 Errors" -body $ts  -smtpserver ekekcas01  -erroraction Stop
		start-sleep 2 
		
	}
}
