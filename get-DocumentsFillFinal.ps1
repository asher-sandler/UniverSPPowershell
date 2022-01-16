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

$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"

# Evgenia

$Credentials = get-SCred
 $rootflr = "Evgenia-FillFinal\"
 $destFiles = import-csv $(".\"+$rootflr +"finalList.csv" )
 
  
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
	$sourceDocObj | ConvertTo-Json -Depth 100 | out-file $("JSON\"+$libName+"-DocLibEvg.json")

	
	$listItems = get-allListItemsByID $siteURL  $libName
	
	$studentsL = @()
	foreach($litem in $listItems){
		
		$approved = $litem["_x05d4__x05d7__x05dc__x05d8__x05ea__x0020__x05e8__x05db__x05d6_"]
		$isAppr = isApproved $approved
		
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
			if ($line.contains('מספר זהות:'))
			{
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
	$outFileName = ".\"+$rootflr +"userList.csv"
	if (!$(Test-Path $outFileName)){
		$TZList | Export-CSV $outFileName -NoTypeInfo -Encoding UTF8
	}
	$schemaAppl = get-ListSchema	$siteUrl "Applicants"
	$applDocObj = get-SchemaObject $schemaAppl
	$applDocObj | ConvertTo-Json -Depth 100 | out-file $("JSON\appli-DocLibEvg.json")
	
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
		
		
		foreach($applicant in $applicants){
			$studentID = $applicant["studentId"]
			if ($studentID -eq $TZItem.TZ){
				$candidateItm = "" | Select-Object Surname,FamilyName,StudentID,Email,Phone,URL,URLDescription,PhoneNumber,EmailUniv,EmailPersonal,Track,SchoolLeaderShip,Magema,Status,PDFFile
				
				$candidateItm.Surname    = $applicant["firstNameHe"]
				$candidateItm.FamilyName = $applicant["surnameHe"]
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
				
				
				
				
				
				
				write-host $studentID -f Yellow
				write-host $TZItem.UserName -f Green
				write-host $applicant["firstNameHe"] -f Cyan
				write-host $applicant["surnameHe"] -f Cyan
				$foundInList = $true
				break
				
			}
		}
		if (!$foundInList){
			write-host $studentID
		}
	}
	
	$outFileName = ".\"+$rootflr +$potok+"-candidateList.csv"
	#if (!$(Test-Path $outFileName)){
		$candidateList | Export-CSV $outFileName -NoTypeInfo -Encoding UTF8
	#}
	
	
	$siteUrl = get-UrlNoF5 "https://portals2.ekmd.huji.ac.il/home/EDU/stdFolders"
	
	$outlist = "מוסמך"
	
	
	$schemaDocLibSrc3 = get-ListSchema	$siteUrl $outlist
	$sourceDocObj3 = get-SchemaObject $schemaDocLibSrc3 
	$sourceDocObj3 | ConvertTo-Json -Depth 100 | out-file $("JSON\ma-DocLibEvg.json")
	
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

 
 
 
 
 
 
 
 
 
 