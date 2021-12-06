function Add-allstudentsItem($siteURL,$listName, $studentItem){
	$siteName = get-UrlNoF5 $SiteURL
	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	
	$Ctx.Credentials = $Credentials

	try{  
		$lists = $ctx.web.Lists  
		$list  = $lists.GetByTitle($listName)  
		$listItemInfo = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation  
		$listItem = $list.AddItem($listItemInfo)  
		
		$listItem["Title"] 			= $studentItem.Surname
		$listItem["FamilyName"] 	= $studentItem.FamilyName
		$listItem["StudentID"] 		= $studentItem.StudentID
		$listItem["Email"] 			= $studentItem.Email
		$listItem["PhoneNumber"] 	= $studentItem.Phone
		
		
		
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
	
	
	$foldersNew = "התכתבויות","וועדות הוראה","יתרת חובות"
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

Start-Transcript "UpdateBA.log"
$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "..\Utils-Request.ps1"
. "..\Utils-DualLanguage.ps1"

	$Credentials = get-SCred

$csvFile = ".\SListBA.csv"
 if ($(Test-Path $csvFile)){
	cls
	$csvStudent = Import-CSV $csvFile -Encoding UTF8
	
	#foreach($item in $csvStudent){
	#	write-host $item
	#}
	#$csvStudent
	#read-host
	
	$siteURL = "https://portals2.ekmd.huji.ac.il/home/EDU/stdFolders"
	$listName = "תואר ראשון"
	<#
	$schema = get-ListSchema $siteURL $listName
	$outFile = $listName+".json"
	$schema | ConvertTo-Json -Depth 100 | out-file $outFile -Encoding Default
	
	$students = get-AllStudentsList $siteURL $listName
	$students | Export-CSV studentsSP.csv -Encoding UTF8
	$studentx = Import-CSV studentsSP.csv -Encoding UTF8
	#>
	
	$i=0
	$studentsX = @()
	foreach($item in $csvStudent){
		
		$studentItem = "" | Select-Object Surname, FamilyName, StudentID, Email,Phone,  URL , URLDescription
		
		$studentItem.Surname 	= $item.FullName.trim().Split(" ")[-1]
		$studentItem.FamilyName = $item.FullName -Replace $studentItem.Surname, ""
		
		$studentItem.FamilyName = $studentItem.FamilyName.Trim()
		$studentItem.Surname 	= $studentItem.Surname.Trim()
		$studentItem.StudentID 	= $item.ID.Trim()
		$studentItem.Email 	= $item.Email
		$studentItem.Phone 	= $item.Phone
		$studentItem.URL 	= $siteURL+"/"+$item.ID
		$studentItem.URLDescription 	= "תיק אישי"
		#read-host
		#write-Host $studentItem
		$studentsX += $studentItem
	}
	
	$studentsX | Export-CSV studentsPURE.csv -Encoding UTF8 -NoTypeInformation
    #write-Host "Press Any Key..."
	#READ-HOST
	foreach($itemS in $studentsX){	
		
		
		
	      write-host $itemS.StudentID  -f CyAN	
		  
		  $itemExists = get-StudentByIDExists $siteURL $listName $itemS.StudentID
		  if (!$itemExists){
			write-host "Item Not Exists: $itemExists " -F Green
			Add-allstudentsItem $siteURL $listName $itemS 
			
		  }
		  #write-Host "395: Press Any Key..."
		#READ-HOST
		  
		  $doclibInternalName = $itemS.StudentID
		  $doclibExternalName = $itemS.FamilyName.trim()+" "+$itemS.Surname.trim()+" "+$doclibInternalName
		  
		  $isDocLibExists = Is-DocLibExists $siteURL $doclibInternalName
		  #write-Host "402: Press Any Key..."
		#READ-HOST
		  
		  if (!$isDocLibExists){
			  write-host $doclibInternalName
			  write-host $doclibExternalName
			  create-DocLib $siteURL $doclibInternalName $doclibExternalName
			  
		  }
		  Create-Folders $siteURL $doclibExternalName
		  		  #write-Host "412: Press Any Key..."
		#READ-HOST

		  write-host "I : $i"

		 
		  $i++
		  if ($i -ge 1){
			  #break
		  }
		  #read-host
		  
		  
	}
	
	
	$RecentsTitle = "לאחרונה"
	$NOmoreSubItems = $false
	while (!$NOmoreSubItems){
		$NOmoreSubItems =  Delete-RecentsSubMenu $siteURL $RecentsTitle 
				
	}

	Delete-RecentMainMenu $siteURL $RecentsTitle 	

	
	
 }
 
 Stop-Transcript
 
