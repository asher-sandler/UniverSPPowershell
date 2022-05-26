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

function copyPdf($drive, $FolderName,$source, $hug){
	if(Test-Path $source){
		#write-host "Copy From: $source" -f Green
		$destination = $drive+$FolderName+"\"+"תיק מועמדות"
		if (Test-Path $destination){
			
			
		    $itm = Get-Item $source
			$dtFile = $destination + "\" + $itm.BaseName+"-"+$hug+$itm.Extension
			write-host "Copy To: $dtFile" -f Green
			#write-host $dtFile -f Green
			if (Test-Path $dtFile)
			{
				#remove-item $dtFile
				write-host "$dtFile Already Exists" -f Yellow
				#read-host
			}
			else
			{
				#Copy-Item -Path $source -Destination $dtFile
				Copy-Item -Path $source -Destination $destination
				
				write-host "Ok" -f Green
				#read-host
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
. "..\Utils-Request.ps1"
. "..\Utils-DualLanguage.ps1"

Start-Transcript DocumentFill-FinalDoc.log
# Evgenia

$Credentials = get-SCred
 $rootflr = ""
 $destFiles = import-csv $(".\"+$rootflr +"finalList.csv" )
 $errorsInFinal = @()

 
 foreach($rowf in $destFiles){
	 $siteName = $rowf.site;
	 
	 $libName  = "ResponseLetters"
	 $destFolder = $rowf.destFolder
	 $potok = $rowf.potok
 	 $siteUrl = get-UrlNoF5 $siteName

	 #write-host "URL: $siteURL" -foregroundcolor Green
	 #write-host  $libName -f Cyan
	 #write-host  $destFolder -f Magenta
	$listExists = Check-ListExists $siteUrl  $libName
	if ($listExists){
		$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
		$Ctx.Credentials = $Credentials
	
		$schemaDocLibSrc1 = get-ListSchema	$siteUrl $libName
		$sourceDocObj = get-SchemaObject $schemaDocLibSrc1 
		$sourceDocObj | ConvertTo-Json -Depth 100 | out-file $("JSON\"+$potok+"-"+$libName+"LibEvgDoc.json")

		$listItems = get-allListItemsByID $siteURL  $libName
	
		$studentsL = @()
		foreach($litem in $listItems){

		
	
			$stud = "" | Select-Object FileName,Title,Description 
			$stud.FileName 		= $litem["FileLeafRef"]
			$stud.Title 		= $litem["Title"]
			$stud.Description 	= $litem["description0"]
			if ($stud.FileName -eq "56565656.doc"){
				
			}
			else{
				$studentsL += $stud
			}	
		}
		$outFileName = ".\"+$potok+"-"+$libName+"-Students.csv"
		$studentsL | Export-CSV $outFileName -NoTypeInfo -Encoding UTF8 

		$List = $Ctx.Web.Lists.GetByTitle($libName)
		$Ctx.Load($List)
		$Ctx.ExecuteQuery()
		 

		$Folder = $List.RootFolder
		$FilesColl = $Folder.Files
		$Ctx.Load($FilesColl)
		$Ctx.ExecuteQuery()
		
		$targetDir = $rootflr+$destFolder
		$TZList = @()
		Foreach($File in $FilesColl)
		{
			
			#$TargetFile = $targetDir + "\"+$File.Name
			if (!$(Test-Path $targetDir)){
				
				New-Item -Path $targetDir -ItemType directory
				
			}
			$newDir = $(get-Item $targetDir)
			$TargetFile = $newDir.FullName+"\"+$File.Name
			# 
			#
			#Download the file
			
			foreach($student in $studentsL){
				if ($student.FileName -eq $File.Name){
					#write-host $student.FileName -f Yellow
					if (!$(Test-Path $TargetFile)){
						#write-Host $TargetFile -f Yellow
						$FileInfo = [Microsoft.SharePoint.Client.File]::OpenBinaryDirect($Ctx,$File.ServerRelativeURL)
						$WriteStream = [System.IO.File]::Open($TargetFile,[System.IO.FileMode]::Create)
						$FileInfo.Stream.CopyTo($WriteStream)
						$WriteStream.Close()
					}
					$outfile = get-Item $TargetFile
					
					$TZLine = "" | Select-Object TZ,FullName,UserName
					$TZLine.TZ = $outfile.BaseName
					$TZLine.FullName = $outfile.FullName
					$TZLine.UserName = $student.Description.replace($TZLine.TZ,"")
					
					$TZList += $TZLine

					break
				}
			}
			#
		}
		$outFileName = ".\"+$targetDir +"\userList.csv"
		#if (!$(Test-Path $outFileName)){
			$TZList | Export-CSV $outFileName -NoTypeInfo -Encoding UTF8
		#}
		net use w: /del	/yes
		net use w: https://portals.ekmd.huji.ac.il/home/EDU/stdFolders /yes /user:ekmd\ashersa GrapeFloor789
		#write-Host $siteName -f Green
		foreach($tzx in $TZList){
			$destPath = "W:\"+$tzx.tz # +"\תיק מועמדות"
			#write-host $destPath -f Green
			if (Test-Path $destPath){
				$source = $tzx.FullName
				#write-Host $source -f Cyan
				$hugSite = $siteName.split("/")[-2]
				copyPdf "W:" $tzx.TZ $source $hugSite
				#read-host
			}else
			{
				$ErrorsInFinal += ""
				$ErrorsInFinal += "=================================="

				$ErrorsInFinal += "On Site https://portals.ekmd.huji.ac.il/home/EDU/stdFolders"
				$ErrorsInFinal += "No Folder: $($tzx.TZ)"
				$ErrorsInFinal += "Student:  $($tzx.UserName)"
				$ErrorsInFinal += "Site: $siteUrl"
				
				$ErrorsInFinal += "=================================="
				$ErrorsInFinal += ""
				#write-Host $tzx.FullName -f Magenta
				$badDir = $(Get-Item $tzx.FullName).DirectoryName + "\EDU-Not-Found\"
				if (!$(Test-Path $badDir)){
				
					New-Item -Path $badDir -ItemType directory
					
				
				}				
				Copy-Item $($tzx.FullName) $badDir
				
				#write-host $("$destPath not Exists") -f Yellow
				#read-host
			}
		}
		
		foreach($tzx in $TZList){
			$destPath = "W:\"+$tzx.tz.substring(0,$tzx.tz.length-1) # +"\תיק מועמדות"
			#write-host $destPath -f Green
			if (Test-Path $destPath){
				write-Host "found $destPath" -f Magenta
				#read-host
			}

		}		
	

	}
 	else{
		#write-Host 
		
		#write-Host "$libName not Exists on Site $siteUrl" -f Yellow
		$ErrorsInFinal += ""
		$ErrorsInFinal += "************************************"
		$ErrorsInFinal += "$libName (מכתבי תשובה -קבצים) not Exists" 
		$ErrorsInFinal += "on Site $siteUrl"
		$ErrorsInFinal += "************************************"
		$ErrorsInFinal += ""
		#write-Host 
	}
 }	
 $outFileName = ".\"+$rootflr +"ErrorsInReponses.txt"
 write-Host "Written error log $outFileName"	
 $ErrorsInFinal | OUT-File $outFileName  -Encoding UTF8

 Stop-Transcript

 
 
 
 
 
 
 
 
 
 