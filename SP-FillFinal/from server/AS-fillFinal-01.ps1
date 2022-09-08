#Fill Final PowerShell Script
function get-FrendlyDate($dtNow){
	$dtNowS = $dtNow.Year.ToString() + "-" +$dtNow.Month.ToString().PadLeft(2,"0") + "-"+$dtNow.Day.ToString().PadLeft(2,"0") + " " + $dtNow.Hour.ToString().PadLeft(2,"0")+":"+$dtNow.Minute.ToString().PadLeft(2,"0")+":"+$dtNow.Second.ToString().PadLeft(2,"0")
	return 	$dtNowS
}
function get-ReportDate($dtNow){
	$dtNowS = $dtNow.Day.ToString().PadLeft(2,"0") + "."+ $dtNow.Month.ToString().PadLeft(2,"0") + "." + $dtNow.Year.ToString() + " "  + $dtNow.Hour.ToString().PadLeft(2,"0")+":"+$dtNow.Minute.ToString().PadLeft(2,"0")
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
	if ($isDebug){
		write-host 41 
		write-host "We are here"
	}
	$x = dst-UpdFields
	$listItm.Update()		
	return $null
	
}
function dst-UpdFields(){
	
	$listItm["שם פרטי"] 	= $dstItm.firstName
	$listItm["שם משפחה"] = $dstItm.surname
	$listItm["שם פרטי בעברית"] = $dstItm.firstNameHe
	$listItm["שם משפחה בעברית"] = $dstItm.surnameHe
	$listItm["תעודת זהות"] = $dstItm.studentId
	$listItm['דוא"ל'] 	= $dstItm.email
	if ([string]::IsNullOrEmpty($dstItm.mobile)){
		$phone = ""
	}
	else
	{
		$phone = $dstItm.mobile.Trim()	
	}
	if ([string]::IsNullOrEmpty($dstItm.homePhone)){
		$phone = ""	
	}
	else{
		$phone = $dstItm.homePhone.Trim()	
	}
	if ([string]::IsNullOrEmpty($dstItm.workPhone)){
		$phone = ""	
	}
	else{
		$phone = $dstItm.workPhone.Trim()	
	}
	if ([string]::IsNullOrEmpty($dstItm.cellPhone)){
		$phone = ""	
	}
	else{
		$phone = $dstItm.cellPhone.Trim()	
	}
	
	if ($isDebug){
		write-host "Line: 82"
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
	if ($isDebug){
		write-host "Line:103"	
		write-host $mikozoa1	
		write-host $mikozoa2	
		write-host $mikozoa3	
		write-host $sugMaslul	
		write-host $sugMaslul	
		write-host $Maslul	
		write-host "Line:110"
	}
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
	$valueFound=$false
	if ($isDebug){
		write-host "Line:155 "
		write-host $lookUpValue
	}
	foreach($itm in $LookupList){
		if ($isDebug){
			write-host "Line:160"
			write-host $itm.Title
		}
		if ($itm.Title -eq $lookUpValue){
			$retVal = $itm.ID
			$valueFound = $true
			break
		}
		
	}
	if (!$valueFound){
		write-host "Error: Lookup Value: '$lookUpValue' not found."
		write-host "Add it to https://portals.ekmd.huji.ac.il/home/EDU/stdFolders/Lists/techCertSubjects"
	}

	return $retVal	
}
function clear-SrcExportFileFlag($candyID){
	$hmeweb = Get-SPWeb  $srcSiteUrl
	$wrkLst = $hmeweb.Lists[$srcList]	
	$listItm = $wrkLst.GetItembyID($candyID)
	$listItm["Export_Files"] = $false
	$listItm["ApplicantExported"] = $true
	$nowDate = Get-Date
	$listItm["exportDate"] = $nowDate
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
		if ($isDebug){
			write-host "198  foldLinkURL: $foldLinkURL" -f Yellow
		}
		if (![string]::IsNullOrEmpty($foldLinkURL)){
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

#$asherTest = $true
$asherTest = $false
$isDebug = $false
if ($asherTest){
	
	$srcSiteUrl   = "https://gss.ekmd.huji.ac.il/home/Humanities/HUM16-2020/"
	$dstSiteUrl   = "https://gss.ekmd.huji.ac.il/home/Humanities/HUM15-2020"
	
}


$srcList  = "applicants"
$srcResponses = "ResponseLetters"
$dstListName  = "לימודי הוראה"
$coordDecisionsName  = "החלטות רכזים - קבצים"
$rspDownloadPath = "C:\temp\SPF-Downloads"
$PersFilesDownloadPath = "C:\temp\SPFPersFiles-Downloads"
$coordFilesDownloadPath = "C:\temp\SPFCoordFiles-Downloads"

$srcFieldName = "סטאטוס טיפול בתיק"


$foldersNew = @()

$persFilesFold= "1. מסמכים אישיים (תיק אישי)"
$userTikFldName = "2. מכתב קבלה + החלטת רכז"

$foldersNew += $persFilesFold
$foldersNew += $userTikFldName

$foldersNew += "3. תכנית לימודים"
$foldersNew += "4. אישורים אקדמיים"
$foldersNew += "5. הערכה של הכשרה מעשית"
$foldersNew += "6. מלגות"
$foldersNew += "7. אישורי ביניים לפתיחת תיק במשרד החינוך ו(או) אישור זכאות לתעודת הוראה"



$dstLookUpNameMaslul    = "teachCertTracks"
$dstLookUpNameSugMaslul = "teachCertTrackType"
$dstLookUpNameMikzoa    = "techCertSubjects"

$script=$MyInvocation.InvocationName

write-host
write-host "Script For Fill Final version 2022-08-03.1"           #$logFileName
write-host "Asher Sandler	: mailTo:AsherSa@ekmd.huji.ac.il"           #$logFileName
write-host "Start time		:  <$dtNowStr>"           #$logFileName
write-host "User			:  <$whoami>"        #$logFileName
write-host "Running ON		:  <$ENV:Computername>" #$logFileName
write-host "Script file		:  <$script>"        #$logFileName
write-host "Log file		:  <$logFile>"        #$logFileName

$homeweb = Get-SPWeb  $srcSiteUrl
$wrkList = $homeweb.Lists[$srcList]
$rspList = $homeweb.Lists[$srcResponses]
$sendMailToUser = $false

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
						$Itm.Title = [string]$fitm["Title"] #כותרת
						$Itm.Attachments = $fitm["Attachments"] #קבצים מצורפים
						$Itm.firstName = [string]$fitm["firstName"] #firstName
						$Itm.surname = [string]$fitm["surname"] #surname
						$Itm.gender = [string]$fitm["gender"] #gender
						$Itm.citizenship = [string]$fitm["citizenship"] #citizenship
						$Itm.email 		= [string]$fitm["email"] #email
						$Itm.homePhone 	= [string]$fitm["homePhone"] #homePhone
						$Itm.workPhone 	= [string]$fitm["workPhone"] #workPhone
						$Itm.cellPhone 	= [string]$fitm["cellPhone"] #cellPhone
						$Itm.address 	= [string]$fitm["address"] #address
						$Itm.country 	= [string]$fitm["country"] #country
						$Itm.zip 		= [string]$fitm["zip"] #zip
						$Itm.academTitle = [string]$fitm["academTitle"] #academTitle
						$Itm.city 		= [string]$fitm["city"] #city
						$Itm.state 		= [string]$fitm["state"] #state
						$Itm.academTitleHe = [string]$fitm["academTitleHe"] #academTitleHe
						$Itm.firstNameHe = [string]$fitm["firstNameHe"] #firstNameHe
						$Itm.surnameHe = [string]$fitm["surnameHe"] #surnameHe
						$Itm.IdHe = [string]$fitm["IdHe"] #IdHe
						$Itm.addressHe = [string]$fitm["addressHe"] #addressHe
						$Itm.countryHe = [string]$fitm["countryHe"] #countryHe
						$Itm.cityHe = [string]$fitm["cityHe"] #cityHe
						$Itm.zipHe = [string]$fitm["zipHe"] #zipHe
						$Itm.citizenshipHe = [string]$fitm["citizenshipHe"] #citizenshipHe
						$Itm.userName = $fitm["userName"] #userName
						$Itm.folderMail = $fitm["folderMail"] #folderMail
						$Itm.genderHe = [string]$fitm["genderHe"] #genderHe
						#write-host ($fitm["folderLink"]).split(",")[0]  -f Magenta
						$Itm.folderLink = ($fitm["folderLink"]).split(",")[0] #folderLink
						$Itm.birthYear = [string]$fitm["birthYear"] #birthYear
						$Itm.folderName = $fitm["folderName"] #folderName
						$Itm.studentId = $fitm["studentId"] #studentId
						$Itm.deadline = $fitm["deadline"] #deadline
						$Itm.mobile = [string]$fitm["mobile"] #mobile
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
				Remove-Item -path $coordFilesDownloadPath -recurse -force
				If (!(Test-Path -path $coordFilesDownloadPath))
				{   
					$LocalFolder = New-Item $coordFilesDownloadPath -type directory
				}
				
				# Clean DownLoad Folder
				Get-ChildItem $rspDownloadPath -Include *.* -Recurse |  ForEach  { $_.Delete()}
				Get-ChildItem $PersFilesDownloadPath -Include *.* -Recurse |  ForEach  { $_.Delete()}
				Get-ChildItem $coordFilesDownloadPath -Include *.* -Recurse |  ForEach  { $_.Delete()}
				copy-PersFiles $candidatesList
				
				# Save Files To Download Directory
				foreach ($candidate in $candidatesList){
					#Download the file
					$Data = $candidate.oFile.OpenBinary()
					$FilePath= Join-Path $rspDownloadPath $candidate.oFile.Name
					
					[System.IO.File]::WriteAllBytes($FilePath, $Data) | out-null
					if ($isDebug){
						write-host "468 Saved File : '$FilePath'" -f Green
					}
					# write-host "Saved File : '$FilePath'" -f Green
				}
				# save Coordinator Files
				Write-Host "save Coordinator Files" -f Green
				$coordDocLib = $homeweb.Lists[$coordDecisionsName]

				$rcFolder = $coordDocLib.RootFolder

				foreach($cndY in $candidatesList){
					foreach($SourceFile in $rcFolder.Files){
					  
						#$SourceFile.ServerRelativeUrl
						$si =  $SourceFile.Item['studentId']
						if ($si -eq $cndY.StudentID){
							#write-host "Student ID: $si"
							$dirPath= Join-Path $coordFilesDownloadPath $si # $SourceFile.Name
							$FilePath = Join-Path $dirPath $SourceFile.Name
							If (!(Test-Path -path $dirPath))
							{   
								$LocalFolder = New-Item $dirPath -type directory
							}
							$Data = $SourceFile.OpenBinary()
							[System.IO.File]::WriteAllBytes($FilePath, $Data) | out-null
							#write-host "Saved File : '$FilePath'" -f Green
							if ($isDebug){
								write-host "495: Saved File : '$FilePath'" -f Green
							}
							#write-host "FilePath: $FilePath"
						}
					}
				}
				# Create User Document Library on Destination Site
				write-host 
				write-host "==================================" -f Green
				write-host "Open Destination site: $dstSiteUrl" -f Green
				$dstweb = Get-SPWeb $dstSiteUrl
				$LsFolders = $dstweb.Lists | Select Title, RootFolder
				foreach($xCandy in $candidatesList){
					write-host 
					write-host "----------------------------------" -f Green
					write-host 
					$innerListName = $xCandy.studentId.ToString().Trim()
					$externalListName = $xCandy.folderName
					$listName = Test-ListExists $LsFolders $innerListName
					if ($listName -eq $null){
						#write-host "Folder $innerListName Does not exists" -f Yellow
						#write-host "Folder externalName : $externalListName" -f Yellow
						
						$t=$dstweb.Lists.Add($innerListName, $externalListName, "DocumentLibrary")
						$dstweb = Get-SPWeb $dstSiteUrl

						$SpList = $dstweb.Lists[$innerListName]
						$SpList.Title = $externalListName
						$SpList.Update()
						$SpList.TitleResource.SetValueForUICulture($cultureHE, $externalListName)
						$SpList.TitleResource.SetValueForUICulture($cultureEN, $externalListName)
						$SpList.TitleResource.Update()	
						#Write-Host "Document Library Created: '$externalListName'" -f Green							
						#Write-Host "Internal Name: $innerListName" -f Green							
					}
					$dstweb = Get-SPWeb $dstSiteUrl
					$LsFolders = $dstweb.Lists | Select Title, RootFolder
					$listName = Test-ListExists $LsFolders $innerListName
					Write-Host "Document Library With Internal Name '$innerListName' `nExists: '$listName'" -f Green
					
					# Create User Folders on Destination DocLib
					# write-host "Check for User Folders DocLib" -f Green
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
						   # write-host "Created Folder '$fldNew'" -f Green
						}
					}

					# --------  change Default View of DocLib
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
					
					# =============== Add File to the Document Library
					
					# delete Old files in Document library
					Write-Host 
					Write-Host -f Yellow "Deleting Files from:  '$($xdstFolder.ServerRelativeURL)'"
					foreach($oldFile in @($xdstFolder.Files)){
						$oldFile.Recycle() | Out-Null
						#Write-host -f Yellow $($oldFile.ServerRelativeURL)
						if ($isDebug){
							Write-host -f Yellow "583: $($oldFile.ServerRelativeURL)"
						}
					}
					
					#Get the Files collection again 
					$dstweb = Get-SPWeb $dstSiteUrl
					$xdstList = $dstweb.Lists[$listName]
					$xRootFolderName = $xdstList.RootFolder.Url + "/" +$userTikFldName
				    $xdstFolder = $dstweb.GetFolder($xRootFolderName) 
					$xdstFiles = $xdstFolder.Files
					
                    $xFullPath = $xRootFolderName+"/"+$dstFileName
					
					# get files from File System to upload them to SP
					$xUplFile = Get-Item $FilePath
					$xCoordPath = Join-Path $coordFilesDownloadPath $xCandy.studentId.ToString().Trim()
					$xCoordItems = $null
					if (Test-Path $xCoordPath){
						$xCoordItems = get-ChildItem $xCoordPath
					}
					
					Write-Host 
					write-host "Upload file to DocLib: '$($xdstFolder.ServerRelativeURL)'" -f Green
					
					$newFile = $xdstFiles.Add($xFullPath,$xUplFile.Open('Open', 'Read', 'Read') ,$true)
					# write-host $newFile.ServerRelativeURL -f Green
						
					$rakz = "החלטת רכז"
					foreach($coordItem in $xCoordItems){
						$newName = $coordItem.BaseName + '-'+$rakz+$coordItem.Extension
						$coordFullPath = $xRootFolderName+"/" + $newName 
						$newFile = $xdstFiles.Add($coordFullPath,$coordItem.Open('Open', 'Read', 'Read') ,$true)
						#write-host $newFile.ServerRelativeURL -f Green
						if ($isDebug){
							write-host "617: coordFullPath : $coordFullPath"
						}
					}
					
					# copy files from Personal Folder
					$persFolder = Get-Item $PersFilesDownloadPath
					$studDir  = $persFolder.FullName + "\"+  $xCandy.StudentID
					$userFldFiles = Get-ChildItem $studDir
					$rFolder = $xdstList.RootFolder
					$uRootFolderName = $rFolder.Url + "/" +$persFilesFold
					$udstFolder = $dstweb.GetFolder($uRootFolderName) 

					
					# delete files in Subfolder 
					Write-Host 
					Write-Host -f Yellow "Deleting Files from:  '$($udstFolder.ServerRelativeURL)'"
					foreach($oldFile in @($udstFolder.Files)){
						$oldFile.Recycle() | Out-Null
						#Write-host -f Yellow $($oldFile.ServerRelativeURL)

					}
					$udstFolder = $dstweb.GetFolder($uRootFolderName) 
					$udstFiles = $udstFolder.Files
					Write-Host 
					Write-Host -f Green "Adding Files to: '$($udstFolder.ServerRelativeURL)'"
					foreach($xuserFile in $userFldFiles){
						#$uUplFile = Get-Item $xuserFile
						$uFullPath = $uRootFolderName+"/"+$xuserFile.Name
						$newFile = $udstFiles.Add($uFullPath,$xuserFile.Open('Open', 'Read', 'Read') ,$true)
						#write-host $newFile.ServerRelativeURL -f Green
						if ($isDebug){
							write-host "648: uFullPath : $uFullPath" -f Green
						}
					}
					
					$dstweb.Dispose()
					[system.gc]::Collect()
					write-host "Ok" -f Green
					write-host 
				}
				
				Write-Host
				Write-Host "Final : "
				Write-Host "Updating Sharepoint Site: $dstSiteUrl" -f Green
				Write-Host "List:   $dstListName"  -f Green
				[system.gc]::Collect()
				
				foreach($cndX in $candidatesList){
					if ($isDebug){
						$cndX # Delete !!!
					}
					#
					$candStdID = $cndX.studentId.ToString().Trim()
					$dstweb = Get-SPWeb $dstSiteUrl
					$dstList = $dstweb.Lists[$dstListName]
					$dstSpQuery = New-Object Microsoft.SharePoint.SPQuery
					if ($isDebug){
						write-host $candStdID
					}
					$dstSpQuery.Query = "<Where><Eq><FieldRef Name='StudentID' />
					<Value Type='Text'>$candStdID</Value></Eq></Where>"
					$dstSpQuery.ViewAttributes = 'Scope="Recursive"'
					$dstItems = $dstList.GetItems($dstSpQuery)
					$dstItems.Count
					if ($dstItems.Count -eq 1){
						if ($isDebug){
							write-host "Edit Record"
						}
						$sendMailToUser = $true
						dst-EditItem $dstSiteUrl $dstListName $cndX $dstItems.ID
					}
					else
					{
						if ($dstItems.Count -eq 0){	
							if ($isDebug){
								write-host "Add Record"
							}
							$sendMailToUser = $true
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
				Write-Host 
				Write-Host "Hope to enjoy us!"
				Write-Host "     THE END"
				
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
	$sendToMiriam = $false
	$msgSubj = "AS-FillFinal-01 Errors"
	if ($ts.contains("Error")){
		$sendMail = $true
	}
	else{
		#if (!$ts.contains("Collection of items Applicants Empty")){
		if ($sendMailToUser){
			$sendMail = $true
			$sendToMiriam = $true
			$msgSubj = "AS-FillFinal-01 Report"
		}
	}

	if ($sendMail){
		#Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersa@ekmd.huji.ac.il"  -Bcc $supportEmail -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction Stop
		Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersa@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction Stop
		start-sleep 2 
		
	}
	if ($sendToMiriam){
		$dt = get-ReportDate $dtNow
		
		$subjMiriam = "הנתונים הועתקו" + " " + $dt
		$siteSource = "https://grs2.ekmd.huji.ac.il/home/Education/EDU63-2022/Lists/applicants/AllItems.aspx"
		$siteDest   = "https://portals2.ekmd.huji.ac.il/home/EDU/stdFolders/Lists/TeachCert/AllItems.aspx"
	
		$msgBody = @"
<!DOCTYPE html>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta charset="utf-8" />
<title></title>
</head> 
<body>		
<div style="direction:rtl;font-family:Arial;color:#000099;">
<br></br>
<div>שלום רב,</div>
<br>
<div>הנתונים הועתקו מאתר: </div>
<div><a href=$siteSource>$siteSource</a></div>
<br>
<img style="height:50px;" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASIAAADjCAIAAACuH45EAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAAEnQAABJ0Ad5mH3gAABVNSURBVHhe7Z33XxTX3sefPyOgiCX6vOL1Jo80xRqJUW4sUReWXkQUCCpqQCGIohKKoIboFSsmRkE0ii1GY8HeESkasaBUaRKQpS1bnlGP95pZypY5szPD5/36/JBXZM/O9+y8d2bPnDnzP1oAAGWgGQDUgWYAUAeaAUAdaAYAdaAZANSBZgBQB5oBQB1oBgB1pK1Zm7ZToVYqNKo28j8AMAcS1UxVV5ufcz5z+5akhOjohJTUHUdO5TwuryP/CgC/SEwzdWv+sR0rvvlysnyonWyQneyjkSTMfw8aJXecGRqZdvxxk5r8OQC8ICHNNA1lJ5LdJ/xXre4y0jfl7JMG8ioA6CMZzSpvbwz9VMeo7mI5fuGWq1XkpQBQRhqatVZkrZ78wSmiPhk8c83REgyNAD6QhGYvfpk7mm2RPhkelFFDmgCAIhLQrDpv/TxrHYX0iu38TbcgGqCO+DWrzI7zlFuy/NE3bvK4Y69IQ9JDo20try/Je3j3WuEdU1N09/rTF2XtSg1pGxiC6DVrO7/GkS2PAbGYsvZGM2lKKqg0TU8enNwZu2x54NxQV4+gr53lA3UKNzSDx/t+5RosD4hJST96/2mFCroZgtg1U1dtm2ehs08YksA9pRK6jKYuy8tIjfDzG8ouk9PYePomHCiqVpA3Bb0hds06HqyUs3cCwyKPva8kjYmdttz9IW46BdLK8OlL0+83krcGPSJ2zdoLY0zcsdzW5nWQxkSNpvhwCAcnhwblH+6Jp5+2kA0A3SN2zdoKV7uzPnsD474ur500JmIaHu9d4cAujY/8MzBTumNInAHNJKHZox1zHFl18Raf7280kc0A3QDNJKBZa+mesE/YdfGXf8X8WqUimwK6BJqJXzNFblaYd392XTxmfNjBcnjWE9BM9JqpCtPDZ7uadlXDxLh+e/k12RrQFdBM7JppFOcSJrKL4jtuvzwlmwO6ApqJXbPO+qMxI9hF8Z2vttwnmwO6ApqJXTNlXXaM/jfaUcq0f+eTzQFdAc1Ef9LYkpM0y2yj+SQz91WQzQFdAc1EPwSiLT2a4O1m7D0KnMRt5a1WsjGgK6CZ+DXTVN2KN/aOOy5i77f+NgYaewSaiV8zrbbjcsIEG1ZdvEXuk3YDiz30DDSTgmba9lvbA70Hs0vjIxZfxF7EKmG9Ac0koZlW21mww4v/gZDRAcsyHpMtAN0DzSSimVarajgWzeupo41H8J67mGSlD9BMMpoxtL66uDVoltcIA9fSMyJWU8Lis669xvLN+gHNpKTZWxrunfvxO4+Z7sP+vry56RlqLxtoK7O2ldl4Jx4vqCRvB/QAmklOM0LT66fXLh/YtjkxIToyNtLERMUn/7B9X8bBP87eqKzFbZwGA82kqtk7OrSqFk1Hs9rUKDSdLVoNzhGNBJpJWzMgCKAZNAPUgWbQDFAHmkEzQB1oBs0AdaAZNAPUgWbQDFAHmkEzQB1oBs0AdaAZNAPUgWbQDFAHmkEzQB1oBs0AdaAZNAPUgWbQDFAHmkEzQB1oBs0AdaAZNAPUgWbQDFAHmkEzQB1oBs0AdaAZNAPUgWbQDFAHmkEzQB1oBs0AdaAZNAPUgWbQDFAHmkEzQB1oBs0AdaAZNAPUgWbQDFAHmkEzQB1oBs0AdaAZNAPUgWbQDFAHmkEzQB1oJl3NNC2dTeUNpQ+eP7j3jEmRIMNs2MOiutqazk4l2WwpAs2kqJmytCRn34ZvQ53Gyfqz6xViLG1dHFxXJO/7vbiinpQgLaCZtDTTVBRmJPk7uwyxlfVjVyqCDBnl6hiSdqdGal980ExCmrU+vLhxqaMNq0DxZfDs+AuVkjqHhGaS0az0XJT3EHZ1Yo2Vc8zJ8k5SmfiBZtLQ7PWTvSsn27NKE3eGBWZK5ocaNJOEZpWZAWNYdYk/jt9sulRBChQ50EwCmrU+3xpkza5LCrH13VtLahQ30Ez8minuHVziLYqBe4NjszD7FalS1EAz0WumKkz3GcUqSjLx3VDQRuoUM9BM7JqpG0/EjGAXJZl4rfjtBSlUzEAzsWumrMuWrma23gs2n37Zpia1ihZoJnbNOuuPSlczG9/wrHwJXKiGZmLXTKM4nzCOXZRk4hd/vYEUKmagmeiHQLQlh1bOdtGpSxrxS33YQcoUM9BM/Jqpy6+u8bdi1yWFWH214U9JzLiCZuLXjPl9dmmtPbsu8cfOLyw9X0NKFDfQTAqaadX307zdpXaFenLczWYVKVDkQDNJaKbVdBTsCXFilSbquC/KlsIVs3dAM2loxtD4ePcy54kyC3aBYozXwj23pfGpvAOaSUYzBkVdTto3M1zFeN/0f2M3N+ZoMSlIKkAzKWn2FlVZUWbisvlBkxxZlQo9tp4r1mzOuPniL1KIhIBmktPsDUp147OSK4d2rYlaGr4qMjJWuFmxKiJ8TfyGbVmnrpRVS+FKdJdAM0lqBoQFNINmgDrQDJoB6kAzaAaoA82gGaAONINmgDrQDJoB6kAzaAaoA82gGaAONINmgDrQDJoB6kAzaAaoA82gGaAONINmgDrQDJoB6kAzaAaoA82gGaAONINmgDrQDJoB6kAzaAaoA82gGaAONINmgDrQDJoB6kAzaAaoA82gGaAONINmgDrQDJoB6kAzaAaoA82gGaAONINmgDrQDJoB6kAzaAaoA82gGaAONINmgDrQDJoB6kAzaAaoA82gGaAONJOwZhpta3l9Sd7Du9cK7/TFFBUW1tbUakhvmBNoJj3NVJqmJw9O7oxdtjxwbqirR9DXzvKB7Kqln/6jPKfJg128F/oFRSxOzswtqTajb9BMWpqpy/IyUiP8/Iayy+zrGTB5YcQPB+6+bCUdxS/QTEKateXuD3HTKRD5IKNCd+U3kO7iEWgmFc00xYdD+uLJoaEZNH5xxjMl6TS+gGbS0Kzh8d4VDuzSkK4zJuq3JjXpOH6AZpLQ7NGOOY6supBuYz0p9PsbjaTreAGaSUCz1tI9YZ+w60J6yvBFx1pI7/EBNBO/ZorcrDDv/uy6kB7z5bqrTaT/eACaiV4zVWF6+GxXC3ZdSE+xmLh0x80K0oP0gWZi10yjOJcwkV0U0kssxy2I+ul6G+lD6tDQrFPbUa+oftFYU9by+i+1iurgqcA1U2lVzZ3NNYq60ua/ajvaW99MgOKYzvqjMSPYRSG9xtUl6fcGviaGcKqZuu7lzew9a5d//YVLv7fFWDnIx8kWLVqVerqA0gFasJp1NBf9cfiH2Lkyr0/sZQNsZFa2so/H+8pCEzNzClu5HE1W1mXHfMouCuk9o+JO/yU2zToU9/avXxw0xlE20IZdD5OhY9zHenx/JK+S/DlnCFAzlfL5uf2rFo4d6zLElvVeb2Jt7/KpW/zJR1zNRdC05CTNwmi+wfFcnJnXSfqQOpxo1lx9btsSfX6FO4ZsulROXsQNQtOsser8tqV6dIWl0/KDjzkaUi49muDtZqnzFkgPsfh8eVbxX6QD6WO6ZsrX59dPs2eX0W1s3D23FZGXcoCgNGurPhwzpqsjWJexdAr/uaiZvNQUNFW34udZ67SP9BCLmZtLeJyxb6Jmmpbz8bOdZIaNJtvPT7pQRhowFeFopunI3bVkpotO+z2l/9cb7nMxZbzjcsKErs7VkW4i9/zlCek7XjBNs9YbaZ6G7VgkDgs2Xq0hjZiEQDTTqMt/S/GS6zTea+SeyWcaTf9abb+1PdB7MLtxpOsM99p4rU5Fuo4XTNGsMT8p9DOdGvSNw/y156pIS8YjDM0qj0bPdDHuArGF3dyUuxycOnYW7PDCQIh+8fjpEek1vjBBs6YjAXbsAgyLY+iW6yaaJgDNGs6kBnpasZs1IHNSb3Ax5KVqOBaNU8fe4u636byC9Bh/GK+Z5k6iI7sGwzM6dHeRKVWbXbPyC1Fe7y4SGh2beVtu1nJyEb/11cWtQbO8Rpj49SfNuNhPDwneedUst08brVlz1YEVtuxKjIn11wmXKjtIqwZjXs0qL68O/JjdoMGx+jw0LucladJ0Gu6d+/E7j5nuw+xkg/q2b0McZANt38wNsB4/LyTpQOFLLsZ1jcJYzZSPr6Qs+j+dwoyL5RcrT1Ua93VuPs00z68kBv8vuzXj4v5tNucDX02vn167fGDb5sSE6MjYyD6XNXHrt6Tv/ulAxq+3CooVHbwOeOhirGYt+afiQowf/9DJiFmxZ18a0Rfm0qy5eHOQ6cex93FZfKiYNMwxHVpVi6ajWd33olG2aFRGnyVxjLGadRRfSl7I1dHsXYYHZ9YZfEgzi2btdafjnfW+DK1H3CKOl5C2gRQx+rdZe8OxlRwvPmHr5rzmpIGTpvnXTFmfHW3PbsSk9HNauvV2PWkeSBGjNdNqX+7z4PIb/W0cfINTf68zYHibZ81UDcdXfTmW1YKpsQ3ceqeet1mswAyYoJn2wbbp7D2Gi8h9t1xu0feYxqtm6rLMBWNYL+cgLv++w+86S4BvTNGso/pQNAeXznRiYec+LfWOfqLxqFnV8diZ8gHsl5uafmOXnOJvpjgwD6Zoxoh2b98CIyby6ZHxS3bc1ufmNJ4005T99mOIL3dDi/+Je8DWa3yvzQl4xzTNtJrWa6l+U1m7Djexclr20/1e733kRbPmm3sWULmhy3JacgFv61EA82GiZgyttcfXfcH5WMjbfPyvZamXez6m8aBZ6aV1ofYUChw4c92ZUn1/FgJRY7pmDHVPsr53mcDejTjJ4BmrjxT1cEyjrJm6PH931CQaU5Ycgrfnm23uD+AZTjRjaPhz+5IxDjo7ExcZMj0xt9v5nlQ1ayje9a0djTnvjiEbckrJm4A+AFeaMV/8z3OivCgtyunwze5HXZtGT7PO6r3RU0ex/piLOMxfe567icJADHCnGUPL9R0B3kNYexVHGRW2r7SLITlKmmnURTt9qNwl6b3yDOfLewGhw6lmDK03tnrIKK2yZBv0cwX7Oi4VzTR/ps+dyPozLmLjGbDprFnudwLmhWvNGFpyaV1MGylzWnm8/m+mca9ZZ+7OBU6sv+EkrlNjjvO2zC0QFBQ0Y6g9Fj6ZtZNxlinrzn6wvqGyeJ2JmnkkPvhgPmH9yUgqWy73SPn9lRKS9VHoaKbVqh7tX0bnsvVHNl4L0q6+v6irKU0wVbMNT9/v/Y2Xtwd5UniCkevs2EO4QtaXoaXZGx7tDv6CtcNxljmbb70bEKlNNvEE1e3Hd6v+NN/4t5z1T9zEesYPxWa+eReYGZqaMZQcWEzJNFu5fFehVvvqjwCdfzIwPkdrtJ13t7nLaSzc+5ln4m/Fr0lvgL4KZc20quYrm73GsXc+bjI2/MjjvYEmN/6PgO1/7ljE0aoef8tIWWRmAVePpAAihrZmDI1/pi0aTWeJpaGfc3PxwJbC/BXrydHHX2BeMHgDD5oxvHqyL3oinenFwozF5+F7czHVAxD40Uyr1ZTn7Yxy0v/BMaKOjYvPzw9J4QDwp9kbam+t8x8h/dWnXXzSCzCyCD6ET8202ubcXyP8BrL3SwnFzidk+w2hLA4IBAO/mjFUnU4J9KUxrCeEOK+/hBUHgC68a8bQdHGj3IXCZAszZ2J4RiVWqAJdYQ7NGGovbnRh76aizuiwrGrMWATdYCbNtNrO64kT6dxtzX8mRGRV4GQRdI/ZNGNEaz4bN15nlxVdxi7aU4Ilg0GPmFEzho76U0kulKZi8RLrr5KLMLAIesO8mjEoaw5F2ujsvqLIsFkxGfdekToA6B6za8bQVPJzuOhM+9h5adodPMYF6IUQNGNoyE8JGqazKws21lO+O/iwiWw7AL0hEM0Yau6nLvxEZ4cWYCwnLFx/8hFG74H+CEczhoqrSSECN83CTj47+QJWpwIGISjNGMpOLfbop7NzCyU2XiG7ritwIAMGIjTNtNq6nO1BngI0zWK0f8imMw0imk6laelsKm8offD8wb1nTIoQzvLi6aO6mpfKdn1Pa4SnGcOLw9Ee7lY6O7o5Y+P6VfwfCrJ9gkdZWpKzb8O3oU7jZNKbOyqQWNq6TvCMSth5JLes90eOCFIzhtozKW6ulFbkNyKfBe4oahLDyaKmojAjyd/ZZYitTLjn3hJKPxvZoLH+/qt23y7vaWEloWqmVbcXZqyYwa7KLPnnjLVnK8UwZ7H14cWNSx2lf+OsEDPKJy6j++fLClYzBmXdkZXjKTxS3aBYTl17sU4UN0OXnoui9ZwQRJ9YfRmd/aTrY5qQNWNorj2VMN18E/mHuSScLRfFcsGvn+xdObmPLLUi4Iz2Sflwqfj/IHDNGBqeHUzwmMSuh484hv1SLJIrZJWZAeY+7CNvI19yuoZ8KB8gfM0Ymp/vjRhD44l+PWTswtRLFeT9hU7r861BNJZMRozIiHk7HzWzL/uIQrM368/djg8YoFMSrYwOTrkunmnBinsHl3hj4F4gGeK8bNOVavLRvEckmjG05/4U4D1UpyruY79g07Va8qZiQFWY7sPzoR7pKXK/nx+Qz+Y94tGMoSN3j7+LTlWcxs4//Jc8Uc2mUjeeiBnBqgIxa8bFXWGdNYpKM4a2vENhnpQeuvvRSNcZiWdFM9WDoKzLhmbCirX/AdbEELFpxtB4JtaZXRgXcfdLPdsgvpVzOuuPQjNhZdSqC6xRfRFqxpwnPcmKnMauzaTYeHjGZVeJcuUcjeJ8wjhWOYg54xqcVUw+nPeIUrM3lOxfNIVVnvEZE5Et4jU9Sg6tnE35Jyuid/pPWrxBxCONupQdXs7F2aNj8Nbb1WJenkpdfnWNv7BuaOjD+XRB+lOFSK+bdY2m7c72eZ+z6zQoI2dHHxb/Q2s7L6211ykNMUu89j0ln8oHiFozBsWLveFjjX0U6MAZcecqJfFATfX9NG93XKE2e4bPibvT1fw8sWvG8OrFwTVTDZ81azX1u6z8OtKG6NF0FOwJcWLXiPAax+D1Z56QD+TvSEAzhpcFu1fPNGT14gH2HhEnSsmrJULj493LnCfKhHMvbJ/KgLG+nklnGruZ2SANzRja6s9u8pvMLr6ruIxZsOVGpSQXp1LU5aR9M8MV903znKFTFiWfKOjhmqtkNHtL470zP8YFu/t0+ZjCQRN85wSv23niem2LpB8toSorykxcNj9okiO7BxCOY+cz3T9y9a7zte29rMQkLc3e0K6sunv31P6dKclxMbGRkUxWL4+Iifsh/diFO3VNfWSFRaW68VnJlUO71kQtDV/1thMQLrM8PDosevPh87erXzWSLu8R6WkGgOCAZgBQB5oBQB1oBgB1oBkA1IFmAFAHmgFAGa32/wHkGgkAGZu4MgAAAABJRU5ErkJggg==" />
<div>&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp &nbsp&nbsp&nbsp&nbsp&nbsp&nbspלאתר: </div>
<div><a href=$siteDest>$siteDest</a></div>

<br>

<div>בברכה,</div>
<br>
<div style="display: flex;">
<img src="data:image/png;base64,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" />
<div style="display: block;">
<div>צוות SP,</div>
<div>האגף למחשוב, תקשורת ומידע</div>

<div >האוניברסיטה העברית בירושלים.</div>
<div><a href='mailTo:supportsp@savion.huji.ac.il'>supportsp@savion.huji.ac.il</a></div>

</div>
</div>
<br>


</div>
</body>
</html>
"@		
		#Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersa@ekmd.huji.ac.il"      -From $doNotReply  -Subject $subjMiriam -body $msgBody -BodyAsHtml  -smtpserver ekekcas01  -erroraction Stop	
		#Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "miriamsha@savion.huji.ac.il"  -From $doNotReply  -Subject $subjMiriam -body $msgBody -BodyAsHtml  -smtpserver ekekcas01  -erroraction Stop	
	}
}
