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

function isApproved($approved){
	$retValue = $false
	
	if($approved -eq "קבלה"){
		$retValue = $true
	}
	if($approved -eq "Master's"){
		$retValue = $true
	}
	if($approved -eq "אישור"){
		$retValue = $true
	}	
	return $retValue
}
function Get-Magema($magema){
	$retValue = ""
	$siteUrl = get-UrlNoF5 "https://portals2.ekmd.huji.ac.il/home/EDU/stdFolders"
	
	$listName = "megamaList"
	$listItems = get-allListItemsByID $siteURL  $listName
	foreach($itm in $listItems){
		if ($itm["Title"] -eq $magema){
			$retValue = $itm.Id
			break
			
		}
	}
	return $retValue	
}
function Kill-Word()
{

            Start-Sleep 5

            #read-Host Press a key... 1

            $wordCount = @(Get-Process winword -ea 0).Count
            
            #"Word process 2: {0}" -f $wordCount
            if ($wordCount -gt 0)
            {
                     $noOutput = Stop-Process -Name WinWord
            }
 
}


function Is-DocLibExists($SiteURL,$id ){
	$siteName = get-UrlNoF5 $SiteURL
	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	
	$Ctx.Credentials = $Credentials
	$Lists = $Ctx.Web.Lists
	$Ctx.Load($Lists)
    $Ctx.ExecuteQuery()
	
	$libExists = $false
	ForEach($list in $Lists)
	{	
			if ($list.Title.contains($id)){
				$libExists = $true
				#write-host $list.Title -f Cyan
				break
			}	
			
	}
	return $libExists
	
}
function get-StudentByIDExists($SiteURL,$ListName,$id){
	$siteName = get-UrlNoF5 $SiteURL
	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	
	$Ctx.Credentials = $Credentials

	#Get the List
		
	$List = $Ctx.Web.lists.GetByTitle($ListName)
	

    write-host $List.SchemaXML
	#Define the CAML Query
	$Query = New-Object Microsoft.SharePoint.Client.CamlQuery
	
	$qry = "<View><Query><Where><Eq><FieldRef Name='StudentID' /><Value Type='Text'>"+$id+"</Value></Eq></Where></Query></View>"
	#$qry = "<View><Query></Query></View>"
	$Query.ViewXml = $qry

	#Get All List Items matching the query
	$ListItems = $List.GetItems($Query)
	$Ctx.Load($ListItems)
	$Ctx.ExecuteQuery()
	
	
	return ($listItems.count -gt 0)
			
}
function Add-allstudentsItem($siteURL,$listName, $studentItem){
	$siteName = get-UrlNoF5 $SiteURL
	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	
	$Ctx.Credentials = $Credentials

	try{  
		$lists = $ctx.web.Lists  
		$list  = $lists.GetByTitle($listName)  
		$listItemInfo = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation  
		$listItem = $list.AddItem($listItemInfo)  
		
		$listItem["Title"] 			= $studentItem.SurnameFinal
		$listItem["FamilyName"] 	= $studentItem.FamilyNameFinal
		$listItem["StudentID"] 		= $studentItem.StudentID
		$listItem["EmailPersonal"]	= $studentItem.Email
		$listItem["PhoneNumber"] 	= $studentItem.PhoneNumber
		$listItem["_x05de__x05d2__x05de__x05d4_"] 	= $studentItem.Magema
		
		
		
		$HyperLinkField= New-Object Microsoft.SharePoint.Client.FieldUrlValue
        $HyperLinkField.Url = $studentItem.URL
        $HyperLinkField.Description = $studentItem.URLDescription
		$listItem["LinkToPersonalFolder"] =[Microsoft.SharePoint.Client.FieldUrlValue]$HyperLinkField
		
		$listItem.Update()      
		$ctx.load($list)      
		$ctx.executeQuery()  
		Write-Host "Item Added with ID - " $listItem.Id  		
	}  
	catch{  
		write-host "$($_.Exception.Message)" -foregroundcolor red  
	}
	return $null
	
}
function Create-Folders($SiteURL, $libName){
	$foldersNew = @()
	$foldersNew += "התכתבויות"
	$foldersNew += "אישורים אקדמיים"
	$foldersNew += "וועדת הוראה"
	$foldersNew += "יתרת חובות"
	$foldersNew += "תיק מועמדות"

	#$foldersNew = "התכתבויות","וועדות הוראה","יתרת חובות"
	$siteName = get-UrlNoF5 $SiteURL
	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	
	$Ctx.Credentials = $Credentials
	$Lists = $Ctx.Web.Lists
	$Ctx.Load($Lists)
    $Ctx.ExecuteQuery()

    #write-host $libName -f Yellow
	$TargetLibrary = $Ctx.Web.Lists.GetByTitle($libName)
    $Ctx.Load($TargetLibrary)
    $Ctx.Load($TargetLibrary.RootFolder)
    $Ctx.ExecuteQuery()	
	
    $CtxFld = $TargetLibrary.RootFolder.Context
    #Get all Folders from the Source
    $SubFolders = $TargetLibrary.RootFolder.Folders
    $CtxFld.Load($SubFolders)
    $CtxFld.ExecuteQuery()
	
	$targetFolderUrlPrefix = ""
	Foreach($SubFolder in $SubFolders)	
	{
		if ($SubFolder.Name -eq "Forms")
		{
			$targetFolderUrlPrefix =  $SubFolder.ServerRelativeUrl -Replace "Forms" , ""
			break
		}
		
	}	
    
	foreach($fldN in $foldersNew){
		$TargetFolderURL = $targetFolderUrlPrefix + $fldN
		Try{
			$Folder=$CtxFld.web.GetFolderByServerRelativeUrl($TargetFolderURL)
			$CtxFld.load($Folder)
			$CtxFld.ExecuteQuery()
			Write-host "Folder Already Exists:"$TargetFolderURL -f Yellow
		}
		catch{
			#Create Folder
			if(!$Folder.Exists){
				
				$Folder=$CtxFld.Web.Folders.Add($TargetFolderURL)
				$CtxFld.Load($Folder)
				$CtxFld.ExecuteQuery()
				Write-host "Folder Created:"$TargetFolderURL -f Green
			}
		}
	}
	
}

function copyPdf($drive, $FolderName,$source){
	if(Test-Path $source){
		write-host "Copy From: $source" -f Green
		$destination = $drive+$FolderName+"\"+"תיק מועמדות"
		if (Test-Path $destination){
			write-host "Copy To: $destination" -f Green
			
		    $itm = Get-Item $source
			$dtFile = $destination + "\" + $itm.Name
			#write-host $dtFile -f Green
			if (Test-Path $dtFile)
			{
				write-host "$dtFile Already Exists" -f Yellow
			}
			else
			{
				Copy-Item -Path $source -Destination $destination
				write-host "Ok" -f Green
			}
			
			
		}
		else
		{
			write-host "$destination Does Not exists" -f Yellow
		}
	}
	else
	{
		write-host "$source File Does not Exists" - f Yellow
	}
	return $null
	
}
function get-ListSchemaX2($siteURL,$listName){
	
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
		#if ($field.SchemaXml.Contains('ReadOnly="TRUE"')){
		#}
		#else{
		#	if ($field.SchemaXml.Contains('Group="_Hidden"')){
		#	}
		#	else{
		
		#		If (!($field.Hidden -or $field.ReadOnly )){
					$fieldsSchema += $field.SchemaXml
		#		}
		
		#	}
		#}	
	}	
	#write-Host 1214
	return $fieldsSchema

}


$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"

Start-Transcript DocumentFill-Final.log
# Evgenia

$Credentials = get-SCred
 $rootflr = "Evgenia-FillFinal\"
 $destFiles = import-csv $(".\"+$rootflr +"finalList.csv" )
 $errorsInFinal = @()
  
 foreach($rowf in $destFiles){
	 $siteName = $rowf.site;
	 $libName  = $rowf.lib
	 $destFolder = $rowf.destFolder
	 $potok = $rowf.potok
 	 $siteUrl = get-UrlNoF5 $siteName

	 write-host "URL: $siteURL" -foregroundcolor Yellow
	 write-host  $libName -f Cyan
	 write-host  $destFolder -f Magenta

	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
	$Ctx.Credentials = $Credentials
	
	$schemaDocLibSrc1 = get-ListSchema	$siteUrl $libName
	$sourceDocObj = get-SchemaObject $schemaDocLibSrc1 
	$sourceDocObj | ConvertTo-Json -Depth 100 | out-file $("JSON\"+$potok+"-"+$libName+"LibEvg.json")

#write-host ....
#read-host	
	$listItems = get-allListItemsByID $siteURL  $libName
	
	$studentsL = @()
	foreach($litem in $listItems){
		if ($potok -eq "238"){ 
			$approved = $litem["_x05d4__x05d7__x05dc__x05d8__x05ea__x0020__x05e8__x05db__x05d6_"]
			$isAppr = isApproved $approved
		}
		if ($potok -eq "239"){ 
			$approved = $litem["_x05d4__x05d7__x05dc__x05d8__x05ea__x0020__x05e8__x05db__x05d6_"]
			$isAppr = isApproved $approved
		}
		if ($potok -eq "240"){ 
			$approved = $litem["_x05d4__x05d7__x05dc__x05d8__x05ea__x0020__x05e8__x05db__x05d6_"]
			$isAppr = isApproved $approved
		}		
		
		if ($potok -eq "243"){ 
			$approved = $litem["_x05d4__x05d7__x05dc__x05d8__x05ea__x0020__x05e8__x05db__x05d6_"]
			$isAppr = isApproved $approved
		}		
		if ($potok -eq "245"){
			$approved = $litem["Faculty_x0027_s_x0020_Decision"]
			$isAppr = isApproved $approved
		}
		if ($potok.contains("237")){
			$approved = $litem["_x05d4__x05d7__x05dc__x05d8__x05ea__x0020__x05e8__x05db__x05d6_"]
			$isAppr = isApproved $approved
		}
		if ($potok -eq "230"){ 
			$approved = $litem["_x05d4__x05d7__x05dc__x05d8__x05ea__x0020__x05e8__x05db__x05d6_"]
			$isAppr = isApproved $approved
		}		
		if ($potok -eq "241"){ 
			$approved = $litem["_x05d4__x05d7__x05dc__x05d8__x05ea__x0020__x05e8__x05db__x05d6_"]
			$isAppr = isApproved $approved
		}		
		if ($potok -eq "242"){ 
			$approved = $litem["_x05d4__x05d7__x05dc__x05d8__x05ea__x0020__x05e8__x05db__x05d6_"]
			$isAppr = isApproved $approved
		}		
		
		
		if ($isAppr){
			$stud = "" | Select-Object FileName 
			$stud.FileName = $litem["FileLeafRef"]
			$studentsL += $stud
		}
	}
	$List = $Ctx.Web.Lists.GetByTitle($libName)
    $Ctx.Load($List)
    $Ctx.ExecuteQuery()
     

    $Folder = $List.RootFolder
    $FilesColl = $Folder.Files
    $Ctx.Load($FilesColl)
    $Ctx.ExecuteQuery()
	
	$targetDir = $rootflr+$destFolder
    Foreach($File in $FilesColl)
    {
		
        $TargetFile = $targetDir + "\"+$File.Name
		if (!$(Test-Path $targetDir)){
			
			New-Item -Path $targetDir -ItemType directory
			
		}
		#
        #Download the file
		foreach($student in $studentsL){
			if ($student.FileName -eq $File.Name){
				#write-host $student.FileName -f Yellow
				if (!$(Test-Path $TargetFile)){
					$FileInfo = [Microsoft.SharePoint.Client.File]::OpenBinaryDirect($Ctx,$File.ServerRelativeURL)
					$WriteStream = [System.IO.File]::Open($TargetFile,[System.IO.FileMode]::Create)
					$FileInfo.Stream.CopyTo($WriteStream)
					$WriteStream.Close()
				}
				break
			}
		}
		#
    }
	
	
	$pdfDocs = $targetDir+"\*.pdf"
	$pdfItems = get-ChildItem $pdfDocs
	$textFileDir = $targetDir + "\TXTFiles"
	if (!$(Test-Path $textFileDir)){
			
			New-Item -Path $textFileDir -ItemType directory
			
		}	
	foreach($pdfFile in $pdfItems){
		$wrkFile = $pdfFile.FullName
		write-host $wrkFile -f Yellow
		$outputName = $dp0+"\"+$textFileDir+"\$($pdfFile.BaseName).txt"
		if (!$(Test-Path $outputName)){

			Kill-Word

			$Word=NEW-Object –comobject Word.Application
			Start-Sleep 5

			$Document=$Word.documents.open($wrkFile)
			Start-Sleep 5

			write-host $outputName -f Cyan
			# write-host Saving file $outputName. 
			# write-host Please wait...
			$def = [Type]::Missing
			$Document.SaveAs(
				#ref Object FileName,
				[ref] $outputName, 
				#ref Object FileFormat,
				[ref] 2, 
				#ref Object LockComments,
				$def,
				#ref Object Password,
				$def,
				#ref Object AddToRecentFiles,
				$def,
				#ref Object WritePassword,
				$def,
				#ref Object ReadOnlyRecommended,
				$def,
				#ref Object EmbedTrueTypeFonts,
				$def,
				#ref Object SaveNativePictureFormat,
				$def,
				#ref Object SaveFormsData,
				$def,
				#ref Object SaveAsAOCELetter,
				$def,
				#ref Object Encoding,
				65001
				#ref Object InsertLineBreaks,
				#ref Object AllowSubstitutions,
				#ref Object LineEnding,
				#ref Object AddBiDiMarks
				)


			$document.close()
			$Word.quit()
        }
		
	}
	
	
	$txtDir = $textFileDir + "\*.txt"
	$txtItems = get-ChildItem $txtDir
	$TZList = @()
	foreach($txtFile in $txtItems){	
	    $contentTxt = Get-Content $txtFile -encoding  UTF8
		$foundTZ = $false
		$tz = ""
		$i=0
		foreach($line in $contentTxt){
			if ($line.contains('מספר זהות:') -or $line.contains('Passport Number:'))
			{
				#write-host 410
				#write-host $line
				$foundTZ = $true
				$tz=$contentTxt[$i-1]
				break
			}
			$i++
		}
		if (!$foundTZ){
			write-host $txtFile -f Yellow
		}
		else
		{
			$TZLine = "" | Select-Object UserName, TZ
			$TZLine.UserName = $txtFile.BaseName
			$TZLine.TZ = $tz
			$TZList += $TZLine
			#write-host $tz -f Green
		}
	}
	$outFileName = ".\"+$targetDir +"\userList.csv"
	if (!$(Test-Path $outFileName)){
		$TZList | Export-CSV $outFileName -NoTypeInfo -Encoding UTF8
	}
	$schemaAppl = get-ListSchema	$siteUrl "Applicants"
	$applDocObj = get-SchemaObject $schemaAppl
	$applDocObj | ConvertTo-Json -Depth 100 | out-file $("JSON\"+$potok+"-appli-DocLibEvg.json")
	
	$ListName="Applicants"
	$List = $Ctx.Web.lists.GetByTitle($ListName)
	 
	#Define the CAML Query
	$Query = New-Object Microsoft.SharePoint.Client.CamlQuery
	$qry = "<View><Query></Query></View>"
	$Query.ViewXml = $qry

	#Get All List Items matching the query
	$applicants = $List.GetItems($Query)
	$Ctx.Load($applicants)
	$Ctx.ExecuteQuery()
		
	#$applicants = get-allListItemsByID $siteURL  "Applicants"
	$TZListNew = Import-CSV $outFileName  -Encoding UTF8
	
	$candidateList =@()
	foreach($TZItem in $TZListNew){	
	    $foundInList = $false
		
		#if ($potok -eq "245"){
		#	write-host $TZItem.TZ
		#	read-host
		#}
		
		foreach($applicant in $applicants){
			$studentID = [string]$applicant["studentId"]
			#if($studentID -eq "029671013"){
			#	write-host -------------------
			#	write-host 462
			#	write-host $studentID -f Magenta
			#	write-host -------------------
			#}
			if ($studentID -eq $TZItem.TZ){
			#	if ($TZItem.TZ -eq  "029671013"){
			#	write-host -------------------
			#	write-host 470
			#	write-host $studentID -f Cyan
			#	write-host -------------------
					
			#	}
				$candidateItm = "" | Select-Object Surname,FamilyName,SurnameFinal, FamilyNameFinal,StudentID,Email,Phone,URL,URLDescription,PhoneNumber,EmailUniv,EmailPersonal,Track,SchoolLeaderShip,Magema,Status,PDFFile
				
				$candidateItm.Surname    = $applicant["firstNameHe"]
				$candidateItm.FamilyName = $applicant["surnameHe"]
				
				$snFinal = $TZItem.UserName.split(" ")[0].trim()
				$fnFinal = $TZItem.UserName.replace($snFinal,"").Trim()
				$candidateItm.SurnameFinal    = $snFinal
				$candidateItm.FamilyNameFinal = $fnFinal
				
				$candidateItm.StudentID  = $studentID
				$candidateItm.Email  = $applicant["email"]
				$candidateItm.Phone  = $applicant["cellPhone"]
				$candidateItm.PhoneNumber  = $applicant["homePhone"]
				# maslul
				$candidateItm.Track  = "מחקרי"
				$candidateItm.SchoolLeaderShip  = "-"
				$candidateItm.Magema  = Get-Magema $potok
				$candidateItm.Status  = "מוסמך בחינוך"
				$candidateItm.URL  = "https://portals2.ekmd.huji.ac.il/home/EDU/stdFolders/"+$studentID+"/Forms/AllItems.aspx"
				$candidateItm.URLDescription 	= "תיק אישי"
				$candidateItm.PDFFile 	= $targetDir + "\"+$TZItem.UserName+".pdf"
				$candidateList += $candidateItm
				
				
				
				
				
				
				#write-host $studentID -f Yellow
				#write-host $TZItem.UserName -f Green
				#write-host $applicant["firstNameHe"] -f Cyan
				#write-host $applicant["surnameHe"] -f Cyan
				$foundInList = $true
				break
				
			}
		}
		if (!$foundInList){
			$errInF = "" | Select-Object URL,StudentID, UserName, PDFFile
			$errInF.URL = $siteName
			$errInF.UserName = $($TZItem.UserName)
			$errInF.StudentID = $($TZItem.TZ)
			$errInF.PDFFile = $dp0 + "\" + $targetDir + "\$($TZItem.UserName)" + ".pdf"
			
			$errorsInFinal +=$errInF
			
			write-host "515: $($TZItem.TZ)" -f Red
			write-host "515: $($TZItem.UserName)" -f Red
			
		}
	}
	
	$outFileName = ".\"+$rootflr +$destFolder+"-candidateList.csv"
	if (!$(Test-Path $outFileName)){
		$candidateList | Export-CSV $outFileName -NoTypeInfo -Encoding UTF8
	}
	
	$candList1 = Import-CSV $outFileName -Encoding UTF8
	
	net use w: /del	
	net use w: https://portals.ekmd.huji.ac.il/home/EDU/stdFolders /yes /user:ekmd\ashersa GrapeFloor789
	$siteUrl = get-UrlNoF5 "https://portals2.ekmd.huji.ac.il/home/EDU/stdFolders"
	
	$outlist = "מוסמך"
	$i = 0
	foreach($itemS in $candList1){
	      
		  $itemExists = get-StudentByIDExists $siteURL $outlist $itemS.StudentID
		  if (!$itemExists){
			#write-host "Item Not Exists: " -F Green
			Add-allstudentsItem $siteURL $outlist $itemS 
			#write-host $itemS.StudentID  -f CyAN	
		  }
		  else
		  {
			write-host "Item  Exists: " -F Yellow 
			write-host $itemS.StudentID  -f Magenta			
		  }
		  
		  $doclibInternalName = $itemS.StudentID
		  write-host "Creating DocLib: $doclibInternalName"
		  $doclibExternalName = $itemS.FamilyNameFinal.trim()+" "+$itemS.SurnameFinal.trim()+" "+$doclibInternalName
		  
		  $isDocLibExists = Is-DocLibExists $siteURL $doclibInternalName
		  
		  if (!$isDocLibExists){
			  write-host "Document Library Creating"
			  write-host $doclibInternalName -f Magenta
			  write-host $doclibExternalName -f Cyan
			  create-DocLib $siteURL $doclibInternalName $doclibExternalName
			  
		  }
		  
		  			
 
		  $docLibFields = "DocIcon","LinkFilename"
          $objViews = Get-AllViews $doclibExternalName $siteURL
		  remove-AllFieldsFromViewButOne $doclibExternalName "כל המסמכים" $siteURL "DocIcon"
		  Add-FieldsToView  $doclibExternalName "כל המסמכים" $siteURL $docLibFields

<#
		  if ($doclibInternalName -eq "312504442"){
			  write-host "DOCLIB 609: $doclibInternalName" -f Cyan
			  $schemaDocLib4 =  get-ListSchemaX2 $siteUrl $doclibExternalName
			  $dstDocObj4 = get-SchemaObject $schemaDocLib4 
			  $dstDocObj4 | ConvertTo-Json -Depth 100 | out-file $("JSON\"+$doclibInternalName+"-"+$destFolder+"EvgDocLib.json")
			  
              $objViews = Get-AllViews $doclibExternalName $siteURL
		 
			  $objViews | ConvertTo-Json -Depth 100 | out-file $("JSON\"+$doclibInternalName+"-Views.json")
			  
			  remove-AllFieldsFromViewButOne $doclibExternalName "כל המסמכים" $siteURL "DocIcon"
			  Add-FieldsToView  $doclibExternalName "כל המסמכים" $siteURL $docLibFields
		  }
#>		  
		  
		  
		  Create-Folders $siteURL $doclibExternalName
		  
		  copyPdf "W:" $itemS.StudentID $itemS.PDFFile
			  
		  #write-host "I : $i"

		  
		  #$i++
		  #if ($i -ge 1){
		#	  break
		  #}
		
	}		
	
	
	$RecentsTitle = "לאחרונה"
	$NOmoreSubItems = $false
	while (!$NOmoreSubItems){
		$NOmoreSubItems =  Delete-RecentsSubMenu $siteURL $RecentsTitle 
				
	}

	Delete-RecentMainMenu $siteURL $RecentsTitle 	

	
	
	#$schemaDocLibSrc3 = get-ListSchema	$siteUrl $outlist
	#$sourceDocObj3 = get-SchemaObject $schemaDocLibSrc3 
	#$sourceDocObj3 | ConvertTo-Json -Depth 100 | out-file $("JSON\ma-DocLibEvg.json")

	
	
	#$Ctx1 = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
	#$Ctx1.Credentials = $Credentials
	
	


<#
	$List = $Ctx.Web.lists.GetByTitle($libName)
	$Query = New-Object Microsoft.SharePoint.Client.CamlQuery
	$qry = "<View><Query></Query></View>"
	$Query.ViewXml = $qry

	#Get All List Items matching the query
	$ListItems = $List.GetItems($Query)
	$Ctx.Load($ListItems)
	$Ctx.ExecuteQuery()
#>	
	

	 
 } 
 
 $outFileName = ".\"+$rootflr +"-ErrorsInFinal.csv"
	
	$ErrorsInFinal | Export-CSV $outFileName -NoTypeInfo -Encoding UTF8
	
	write-host "Writed File $outFileName"

 STOP-Transcript

 
 
 
 
 
 
 
 
 
 