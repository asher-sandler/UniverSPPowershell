function Add-allstudentsItem($siteURL, $studentItem){
	$siteName = get-UrlNoF5 $SiteURL
	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	
	$Ctx.Credentials = $Credentials

	try{  
		$lists = $ctx.web.Lists  
		$list = $lists.GetByTitle("allstudents")  
		$listItemInfo = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation  
		$listItem = $list.AddItem($listItemInfo)  
		
		$listItem["Title"] 								= $studentItem.Surname
		$listItem["_x05e9__x05dd__x0020__x05de__x05"] 	= $studentItem.FamilyName
		$listItem["_x05de__x05e1__x05e4__x05e8__x00"] 	= $studentItem.StudentID
		$listItem["_x05db__x05ea__x05d5__x05d1__x05"] 	= $studentItem.Email
		$listItem["_x05e9__x05e0__x05d4__x0020__x05"]	 = $studentItem.YearGraduate
		$listItem["_x05d4__x05e2__x05e8__x05d5__x05"] 	= $studentItem.Status
		$listItem["_x05d4__x05e2__x05e8__x05d5__x050"] 	= $studentItem.Notes
		$listItem["Year"] =$studentItem.Year
		
		
		$HyperLinkField= New-Object Microsoft.SharePoint.Client.FieldUrlValue
        $HyperLinkField.Url = $studentItem.URL
        $HyperLinkField.Description = $studentItem.URLDescription
		$listItem["folderLink"] =[Microsoft.SharePoint.Client.FieldUrlValue]$HyperLinkField
		
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
function Delete-RecentsSubMenu($siteURL,$MenuTitle){
	$siteName = get-UrlNoF5 $SiteURL
	write-host "Collect Navigation: $siteURL" -foregroundcolor Green
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
    foreach($QuickLaunchLink in $QuickLaunch){	
	    
		if (($QuickLaunchLink.Title -eq $MenuTitle) ){
			write-host $QuickLaunchLink.Title -f Yellow	
			
					
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
	
	return $noMoreSubItems
	
	
}
 
function Create-Folders($SiteURL, $libName){
	
	$foldersNew = "הצהרות בריאות- מחלה- פטורים","התאמות בבחינות","סגירת תואר","עבודת גמר","ציונים","תכתובות - סיכומי פגישות- מסמכים רשמיים"
	$siteName = get-UrlNoF5 $SiteURL
	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	
	$Ctx.Credentials = $Credentials
	$Lists = $Ctx.Web.Lists
	$Ctx.Load($Lists)
    $Ctx.ExecuteQuery()

    write-host $libName -f Yellow
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
    #write-host $targetFolderUrlPrefix -f Cyan
	#write-host 25
	#read-host
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
				write-host $list.Title
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
	$qry = "<View><Query><Where><Eq><FieldRef Name='_x05de__x05e1__x05e4__x05e8__x00' /><Value Type='Text'>"+$id+"</Value></Eq></Where></Query></View>"
	#$qry = "<View><Query></Query></View>"
	$Query.ViewXml = $qry

	#Get All List Items matching the query
	$ListItems = $List.GetItems($Query)
	$Ctx.Load($ListItems)
	$Ctx.ExecuteQuery()
	
	
	return ($listItems.count -gt 0)
			
}


function get-AllStudentsList($SiteURL,$ListName){
	
	$siteName = get-UrlNoF5 $SiteURL
	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	
	$Ctx.Credentials = $Credentials

	#Get the List
		
	$List = $Ctx.Web.lists.GetByTitle($ListName)
	

    write-host $List.SchemaXML
	#Define the CAML Query
	$Query = New-Object Microsoft.SharePoint.Client.CamlQuery
		
		
		$qry = "<View><RowLimit>12</RowLimit><Query><OrderBy><FieldRef Name='ID' Ascending='False' /></OrderBy></Query> </View>"
		$qry = "<View><Query></Query></View>"
	$Query.ViewXml = $qry

	#Get All List Items matching the query
	$ListItems = $List.GetItems($Query)
	$Ctx.Load($ListItems)
	$Ctx.ExecuteQuery()
	
	$studentList = @()

	$i=0
	write-host $listItems.count
	foreach($listItem in $listItems)
	{
		
	<#
שם פרטי  
 שם משפחה  
 מספר זהות  
 כתובת דוא"ל  
 שנה לימוד לתואר  
 מסמכים  היפר-קישור או תמונה  
 סטטוס  
folderLink  היפר-קישור או תמונה  
Year  
 הערות מילוליות 
	
	#>	
		$studentItem = "" | Select-Object Title, Surname, FamilyName, StudentID, Email, YearGraduate, Status, Notes,Year 
		
		
			Write-Host "ID - " $listItem["ID"] "Title - " $listItem["Title"] 
			$i++
			if ($i -gt 9){
				break
		}
		
		
		$studentItem.Title = $listItem["Title"]
		$studentItem.Surname = $listItem["Title"]
		$studentItem.FamilyName = $listItem["_x05e9__x05dd__x0020__x05de__x05"]
		$studentItem.StudentID = $listItem["_x05de__x05e1__x05e4__x05e8__x00"]
		$studentItem.Email = $listItem["_x05db__x05ea__x05d5__x05d1__x05"]
		$studentItem.YearGraduate = $listItem["_x05e9__x05e0__x05d4__x0020__x05"]
		$studentItem.Status = $listItem["_x05d4__x05e2__x05e8__x05d5__x05"]
		$studentItem.Notes = $listItem["_x05d4__x05e2__x05e8__x05d5__x050"]
		$studentItem.Year = $listItem["Year"]
		$studentList += $studentItem
	}
		
	return $studentList
	
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

Start-Transcript "UpdateListAndLibs.log"
$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "..\Utils-Request.ps1"
. "..\Utils-DualLanguage.ps1"

	$Credentials = get-SCred

 if ($(Test-Path ".\SList.csv")){
	$csvStudent = Import-CSV SList.csv -Encoding UTF8
	
	foreach($item in $csvStudent){
		write-host $item
	}
	#$csvStudent
	read-host
	
	$siteURL = "https://portals2.ekmd.huji.ac.il/home/Dental/StdFolders"
	$listName = "allstudents"
	<#
	$schema = get-ListSchema $siteURL $listName
	$outFile = $listName+".json"
	$schema | ConvertTo-Json -Depth 100 | out-file $outFile -Encoding Default
	
	$students = get-AllStudentsList $siteURL $listName
	$students | Export-CSV studentsSP.csv -Encoding UTF8
	$studentx = Import-CSV studentsSP.csv -Encoding UTF8
	#>
	
	$i=0
	foreach($item in $csvStudent){
		
		$studentItem = "" | Select-Object Surname, FamilyName, StudentID, Email, YearGraduate,Status,Notes,  Year,URL , URLDescription
		
		$studentItem.Surname 	= $item.FamilyName.trim()
		$studentItem.FamilyName = $item.Name.trim()
		$studentItem.StudentID 	= $item.ID.Trim()
		$studentItem.Email 	= ""
		$studentItem.YearGraduate 	= "-"
		$studentItem.Status 	= "-"
		$studentItem.Notes 	= ""
		$studentItem.URL 	= $siteURL+"/"+$item.ID
		$studentItem.URLDescription 	= "תיק אישי"
		$studentItem.Year 	= "שנה א"
		
		
		
	      write-host $studentItem.StudentID  -f CyAN	
		  
		  $itemExists = get-StudentByIDExists $siteURL $listName $studentItem.StudentID
		  if (!$itemExists){
			write-host "Item Not Exists: $itemExists " -F Green
			Add-allstudentsItem $siteURL $studentItem 
			
		  }
		  
		  
		  $doclibInternalName = $studentItem.StudentID
		  $doclibExternalName = $item.Name.trim()+" " +$item.FamilyName.trim()+" "+$doclibInternalName
		  
		  $isDocLibExists = Is-DocLibExists $siteURL $doclibInternalName
		  if (!$isDocLibExists){
			  write-host $doclibInternalName
			  write-host $doclibExternalName
			  create-DocLib $siteURL $doclibInternalName $doclibExternalName
			  
		  }
		  Create-Folders $siteURL $doclibExternalName
		  write-host "DocLib Exists: $isDocLibExists " -f Yellow
		  write-host "I : $i"

		 
		  $i++
		  if ($i -gt 5){
			  #break
		  }
		  #read-host
		  
		  
	}
	
	<#
	write-host "342679156" -f CyAN	
	$itemExists = get-StudentByIDExists $siteURL $listName "342679156"
	write-host "Item Exists: $itemExists " -F Green
	
	
	$isDocLibExists = Is-DocLibExists $siteURL "342679156"
	write-host "DocLib Exists: $isDocLibExists " -f Yellow
	#>
	
	#$menuDumpSrc = Collect-Navigation $siteURL $true 
	#$outfile = ".\MenuDmp.json"
	#$menuDumpSrc = get-content $outfile -encoding default | ConvertFrom-Json	
	#$menuDumpSrc | ConvertTo-Json -Depth 100 | out-file $outfile -Encoding Default
	
	$RecentsTitle = "לאחרונה"
	$NOmoreSubItems = $false
	while (!$NOmoreSubItems){
		$NOmoreSubItems =  Delete-RecentsSubMenu $siteURL $RecentsTitle 
				
	}	

	
	
 }
 
 Stop-Transcript
 
