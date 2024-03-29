function Change-PermissionsX ($siteUrl, $listName){

	$siteName = get-UrlNoF5 $siteUrl	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	$Ctx.Credentials = $Credentials

	$Web = $Ctx.Web
	$ctx.Load($Web)
	$Ctx.ExecuteQuery()
	
	
	$List = $Ctx.Web.lists.GetByTitle($listName)
    $ctx.Load($List)
	$Ctx.ExecuteQuery()

	$List.BreakRoleInheritance($False,$False) #keep existing list permissions & Item level permissions
	$Ctx.ExecuteQuery()
	#Write-host -f Green "Permission inheritance broken successfully!"


    # Add Group Permissions To List
	$GroupPermissionLevel="עיצוב"
	$EdtGroupName = "EKMD\med_hr_writedl"
	#write-Host $GroupPermissionLevel

	$Group =$Web.EnsureUser($EdtGroupName)
	$Ctx.load($Group)
	$Ctx.ExecuteQuery()
	
	$Role = $web.RoleDefinitions.GetByName($GroupPermissionLevel)
	$RoleDB = New-Object Microsoft.SharePoint.Client.RoleDefinitionBindingCollection($Ctx)
	$RoleDB.Add($Role)

	$Permissions = $List.RoleAssignments.Add($Group,$RoleDB)
	$List.Update()
	$Ctx.ExecuteQuery()
	
    # Add Group Permissions To List
	$GroupPermissionLevel="קריאה"
	$EdtGroupName = "EKMD\med_hr_filesviewerug"
	#write-Host $GroupPermissionLevel

	$Group =$Web.EnsureUser($EdtGroupName)
	$Ctx.load($Group)
	$Ctx.ExecuteQuery()
	
	$Role = $web.RoleDefinitions.GetByName($GroupPermissionLevel)
	$RoleDB = New-Object Microsoft.SharePoint.Client.RoleDefinitionBindingCollection($Ctx)
	$RoleDB.Add($Role)

	$Permissions = $List.RoleAssignments.Add($Group,$RoleDB)
	$List.Update()
	$Ctx.ExecuteQuery()
	<#
    # Add  User Permissions To List
	$usrBins = "ekmd\biniamins"
	#write-host $usrBins

	$spUser = $web.EnsureUser($usrBins)
	$Ctx.load($spUser)
	$Ctx.ExecuteQuery()
	
	$UserPermissionLevel="שליטה מלאה"
	#write-Host $UserPermissionLevel
	# enSure Users and Group
	
	$Role = $web.RoleDefinitions.GetByName($UserPermissionLevel)
	$RoleDB = New-Object Microsoft.SharePoint.Client.RoleDefinitionBindingCollection($Ctx)
	$RoleDB.Add($Role)
	
	$Permissions = $List.RoleAssignments.Add($spUser,$RoleDB)
    $List.Update()
    $Ctx.ExecuteQuery()	

	# enSure Users and Group
    # Add  User Permissions To List
	$usrBins = "cc\biniamins"
	#write-host $usrBins

	$spUser = $web.EnsureUser($usrBins)
	$Ctx.load($spUser)
	$Ctx.ExecuteQuery()

	$UserPermissionLevel="שליטה מלאה"
	#write-Host $UserPermissionLevel
 
	# enSure Users and Group
	
	$Role = $web.RoleDefinitions.GetByName($UserPermissionLevel)
	$RoleDB = New-Object Microsoft.SharePoint.Client.RoleDefinitionBindingCollection($Ctx)
	$RoleDB.Add($Role)
	
	$Permissions = $List.RoleAssignments.Add($spUser,$RoleDB)
    $List.Update()
    $Ctx.ExecuteQuery()	
    #>		
    # Remove Current User Permissions
	try{
		$currentUserName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
		$spCurrentUser = $web.EnsureUser($currentUserName)
		
		$List.RoleAssignments.GetByPrincipal($spCurrentUser).DeleteObject()
		$List.Update()
		$Ctx.ExecuteQuery()
	}
	catch{
		#write-host -f Yellow "Local User does not exists in Library" 
		
	}
	
    return $null	
}
Function Add-FieldsToDocLibX($siteUrl, $listName){
	$schemaFields = @()
	$schemaFields += '<Field Type="Boolean" DisplayName="sentResponse" EnforceUniqueValues="FALSE" Indexed="FALSE"  StaticName="sentResponse" Name="sentResponse" ><Default>0</Default></Field>'

	ForEach($fSchema in $schemaFields){
		add-SchemaFields $siteUrl $listName $fSchema
	}
	return $null
}
function Change-DefaultViewX($siteUrl, $listName){
	
	$siteName = get-UrlNoF5 $siteUrl	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	
	$Ctx.Credentials = $Credentials
	$List = $Ctx.Web.lists.GetByTitle($listName)

    $ViewFields = $List.DefaultView.ViewFields
	$View = $list.DefaultView
    $Ctx.load($ViewFields) 
    $Ctx.load($View) 
    $Ctx.ExecuteQuery()


	
#	$qryView = '<OrderBy><FieldRef Name="_x05ea__x05d5__x05db__x05df__x0020__x05e7__x05d5__x05d1__x05e5_" /></OrderBy>'
	
	
#	$View.ViewQuery = $qryView
	$view.Update();
	$ctx.ExecuteQuery();
	
	# remove Fields From View
	For($i = $ViewFields.Count -1 ; $i -ge 0; $i--){
	    $fieldN = $ViewFields[$i]
		
	
		#write-host $fieldN 
		#write-host $firstField 
		#write-host "Equ: $($fieldN -eq $firstField)"
		
		$view.ViewFields.Remove($fieldN)
		$view.Update()
		$Ctx.ExecuteQuery()
	
	}	


	$vFieldsList =      "Edit",
                       "DocIcon",
                       "LinkFilename",
					   "Modified",
					   "Editor"
					   
	# add Fields To View
   For($i = 0 ; $i -lt $vFieldsList.Count; $i++){ 	
            $fieldN =  $vFieldsList[$i]	
		    #write-host $fieldN
			$view.ViewFields.Add($fieldN)
			$view.Update()
			$Ctx.ExecuteQuery()		
	}

	#write-host "Updated $listName Default View." -foregroundcolor Green
	
	return $null
	
}
function Get-FilesX($folderUrlName){
	$filesObj = @()
    try{
	$usrDocFolder = $Ctx.Web.GetFolderByServerRelativeUrl($folderUrlName)
    $FilesCollSrc = $usrDocFolder.Files
 
	$Ctx.load($usrDocFolder) 
    $Ctx.Load($FilesCollSrc)
    $Ctx.ExecuteQuery()
	

	forEach($srcFile in $FilesCollSrc){
		$sItems   = $srcFile.ListItemAllFields
		$Ctx.Load($sItems)
		$Ctx.ExecuteQuery()

		$fileObj = "" | Select Name, Created, Modified, Author, Editor
		
		
		$fileObj.Name     = $srcFile.ServerRelativeURL
		$fileObj.Created  = $sItems["Created" ] 
		$fileObj.Modified = $sItems["Modified"]
		$fileObj.Author   = $sItems["Author"  ]
		$fileObj.Editor   = $sItems["Editor"  ]


		
		$filesObj += $fileObj
	}
	}
	Catch {
		write-host -f Yellow "Source User Library $folderUrlName not found" $_.Exception.Message
		Write-Host $($siteName + "/Lists/" + $ListTitle + "/EditForm.aspx?ID="+$idObj.ID)

	}	
	return $filesObj

}
function Copy-ContentX( $siteDst, $libName,$folderLink,$filesObj){
	$siteNameDst = get-UrlNoF5 $siteDst
	$CtxDst = New-Object Microsoft.SharePoint.Client.ClientContext($siteNameDst)
	$CtxDst.Credentials = $Credentials
 
    $Web = $CtxDst.Web
	#$listDst = 	$CtxDst.Web.Lists.GetByTitle($libName)
	$listDst = 	$web.GetFolderByServerRelativeUrl($folderLink)
    $CtxDst.Load($listDst)
    $CtxDst.ExecuteQuery()


	forEach($fileItem in $filesObj){
		$FileInfo = [Microsoft.SharePoint.Client.File]::OpenBinaryDirect($CtxDst, $fileItem.Name)
		$dstFileName = $fileItem.Name.Split("/")[-1]
		$dstRelativeUrl = $folderLink +"/"+ $dstFileName
        write-Host "Copy from " $fileItem.Name " To $dstRelativeUrl" -f Green		
		[Microsoft.SharePoint.Client.File]::SaveBinaryDirect($CtxDst, $dstRelativeUrl, $FileInfo.Stream,$True)
		$dstFile = Get-DestFile $CtxDst $folderLink $dstFileName
		$dstItems = $dstFile.ListItemAllFields

		$dstItems["Created" ] = $fileItem.Created #$srcDateCreat
		$dstItems["Modified"] = $fileItem.Modified # $srcDateEdit
		$dstItems["Author"  ] = $fileItem.Author #$srcWhoCreat
		$dstItems["Editor"  ] = $fileItem.Editor #$srcWhoEdit
		$dstItems.Update()
		$listDst.Update()
		$CtxDst.Load($dstItems)
		$CtxDst.Load($listDst)
		$CtxDst.ExecuteQuery()

	}
}
function Get-DestFile($ctx, $folderLink, $sFileName){
	$oFile = $null
	$Web  = $ctx.Web
	$List = $web.GetFolderByServerRelativeUrl($folderLink)
    $ctx.Load($List)
	$Ctx.ExecuteQuery()
 	
	<#
	write-host 257 $folderLink
	write-host 258 $FolderSrc.Name
	write-host 259 $sFileName
	write-host "..."
	read-host
	#>
 
    $FilesCollSrc = $List.Files
    $Ctx.Load($FilesCollSrc)
    $Ctx.ExecuteQuery()
	
	ForEach($sFile in $FilesCollSrc){
		if ($sFile.Name -eq $sFileName)
		{
			$oFile = $sFile
			break			
		}
	}
	return $oFile
	
}
function Change-FolderLink($siteUrl, $listName,$itemID, $folderLink,$studentId){
       $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
        $Ctx.Credentials = $Credentials
         
        #Get the List
        $List = $Ctx.Web.Lists.GetByTitle($listName)
        $Ctx.Load($List)
        $Ctx.ExecuteQuery()
		$listItem = $List.getItemById($itemID)
        $Ctx.Load($listItem)
        $Ctx.ExecuteQuery()


		$iCreated  = $listItem["Created" ] 
		$iModified = $listItem["Modified"]

		$iAuthor   = $listItem["Author"  ] 
		$iEditor   = $listItem["Editor"  ]

        #write-host 286 $iCreated
        #write-host 287 $iModified
        #write-host 288 $iAuthor
        #write-host 289 $iEditor
        
		#Set Hyperlink field properties    
		$Link = New-Object Microsoft.SharePoint.Client.FieldUrlValue
		$Link.Url = $folderLink
		$Link.Description = "תיק אישי"
 
		#Update Hyperlink Field
		$listItem["folderLink"] = [Microsoft.SharePoint.Client.FieldUrlValue]$Link
		$listItem["studentId"] = $studentId

		$listItem["Created" ] = $iCreated
		$listItem["Modified"] = $iModified
		$listItem["Author"  ] = $iAuthor
		$listItem["Editor"  ] = $iEditor


		$listItem.Update()
		$List.Update()
		$Ctx.Load($listItem)
		$Ctx.Load($List)
		$Ctx.ExecuteQuery()
		
		$outStr = $siteUrl + "/Lists/" +  $listName + "/EditForm.aspx?ID=" + $itemID
		write-host $outStr -f Cyan
		
		
	
}
function Check-LibExists($siteUrl , $folderlink){
	$isLibExists = $true
	Try{
      $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
      $Ctx.Credentials = $Credentials

	  $Web  = $ctx.Web
      $List = $web.GetFolderByServerRelativeUrl($folderLink)
	  
      $ctx.Load($List)
	  $Ctx.ExecuteQuery()
	  
 		
	}
	Catch{
		$isLibExists = $false
	}
	return $isLibExists
}
function Delete-FieldX($siteUrl, $listName, $FieldName){
Try{
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
	    $Column = $List.Fields.GetByTitle($ColumnName)
		 
		#sharepoint online delete list column powershell
		$Column.DeleteObject()
		$Ctx.ExecuteQuery()
 
    Write-host "Column '$ColumnName' deleted Successfully!" -ForegroundColor Green
}
Catch {
    write-host -f Red "Error Deleting Column from List!" $_.Exception.Message
}	
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

Start-Transcript "Preclinical Staff.log"
$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\..\Utils-Request.ps1"
. "$dp0\..\Utils-DualLanguage.ps1"

$Credentials = get-SCred
$heDocLibName = "העלאת מסמכים"
$enDocLibName = "Documents Upload"
$folderLinkSchema = '<Field Format="Hyperlink"  DisplayName="folderLnk" Type="URL"  Name="folderLnk"     />'

 
 $siteName = "https://portals2.ekmd.huji.ac.il/home/Medicine/hr";
 $ListTitle = "Clinical_Staff"
 $ListTitle = "Preclinical Staff"
 #$ListTitle = "researchers"


  
 $siteUrl = get-UrlNoF5 $siteName
 $docFolderName = ""
 write-host "URL: $siteURL" -foregroundcolor Yellow
 #add-SchemaFields $siteUrl $ListTitle $folderLinkSchema
 
 
    $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
    $Ctx.Credentials = $Credentials
	$Web = $Ctx.Web
	$ctx.Load($Web)
	$Ctx.ExecuteQuery()
	$List = $Ctx.Web.lists.GetByTitle($ListTitle)
	$Ctx.load($List) 
    $Ctx.ExecuteQuery()
	$lItemsCount = $List.ItemCount
	
	
    write-Host "Opened List: " 	$List.Title " Count: " $lItemsCount



	$JsonFile = ".\idList.json"
	$idList = @()
	$Query = [Microsoft.SharePoint.Client.CamlQuery]::CreateAllItemsQuery()  
	$ListItems = $List.GetItems($Query)  
	$Ctx.Load($ListItems)  
	$Ctx.ExecuteQuery()
	$itmCount = 0

	forEach($lItem in $ListItems){
        #if ($lItem.ID -eq 1033){ # Lerner


		$idObj = "" | Select ID, StudentID,FirstName,SurName,Uri, samEKMD,Email,UserDocLibName, List,folderLink, UserFolder,Files

		$idObj.ID = $lItem.ID
		$idObj.StudentID = $lItem["employeeID"].Trim()
		
		$calculatedLink   =  $lItem["calculatedLink"]
		$calcLinkTrimmed  =  $calculatedLink.Replace("<a href='","").Replace("'>תיק אישי</a>","")

		$idObj.Uri        =  get-SiteNameFromNote $calculatedLink
		$idObj.List       =  $([system.uri]$calcLinkTrimmed).LocalPath
		$idObj.UserFolder =  $calcLinkTrimmed.Split("/")[-1]
		$idObj.FirstName  =  $lItem["givenName"]
		$idObj.SurName    =  $lItem["sn"]
		$idObj.samEKMD    =  $lItem["EKMD"]
		$idObj.Email      =  $lItem["mail"]
		$idObj.folderLink =  $siteName+"/"+$idObj.StudentID
		$idObj.Files      =  Get-FilesX $idObj.List
		$idObj.UserDocLibName=   $idObj.StudentID + " - " + $idObj.SurName + " " + $idObj.FirstName

		$idList += $idObj 
		$docFolderName = $idObj.List
		$itmCount++
		#write-host "Item " $itmCount "of " $lItemsCount
		<#
		if ($itmCount -gt 4){
			break
		}
		#>
		#}
	}
	
	
	$idList | ConvertTo-Json -Depth 100 | out-file $JsonFile
	Write-Host $JsonFile " Saved"


    Write-Host 	$idList.Count
	write-host "..."
	#read-host
	
#	
   forEach($itmC in $idList){
	   $outFolder = $([system.uri]$itmC.folderLink).LocalPath 

	   $libExists = Check-LibExists $siteUrl  $outFolder
	   if (!$libExists){
		write-host "Creating DocLib : " $itmC.UserDocLibName  
		create-DocLib 	   $siteUrl $itmC.StudentID $itmC.UserDocLibName
		Change-DefaultViewX $siteUrl $itmC.UserDocLibName
	    Change-PermissionsX  $siteUrl $itmC.UserDocLibName
		
	   }
	   else
	   {
		write-host "DocLib : " $itmC.UserDocLibName  " already exists"
		   
	   }
	   #Add-FieldsToDocLibX $siteUrl $itmC.UserDocLibName
	   Copy-ContentX 	   $siteUrl $itmC.UserDocLibName $outFolder $itmC.Files
	   
	   
	   Change-FolderLink $siteUrl $ListTitle $itmC.ID $itmC.folderLink $itmC.StudentID
   }
   
#>
	$RecentsTitle = "לאחרונה"
	#if ($spObj.language.ToLower().Contains("en")){
		#$RecentsTitle = "Recent"
	#}
	
	
	#
	$NOmoreSubItems = $false
	while (!$NOmoreSubItems){
		$NOmoreSubItems =  Delete-RecentsSubMenu $siteURL $RecentsTitle 
					
	}
	Delete-RecentMainMenu $siteURL $RecentsTitle
    #>
	
stop-transcript	
	
	
	

