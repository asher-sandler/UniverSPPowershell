
function Activate_PublishingFeature($siteURL){
    $featActivated = $true	
	try{
		$publishingWebFeatureID = "94c94ca6-b32f-4da9-a9e3-1f3d343d7ecb"
		Enable-SPFeature $publishingWebFeatureID  -URL $siteURL -Force -Confirm:$false -ErrorAction stop
	}
	catch
	{
		$featActivated = $false		
	}
	return $featActivated
}
function Add-QuickLaunchMenu($spWeb,$qlMenu,$siteListArr){
	$qlNavigation = $spWeb.Navigation.QuickLaunch
	foreach($el in $qlMenu){
		$node = New-Object Microsoft.SharePoint.Navigation.SPNavigationNode($el.Title, $el.URL, $true)
		$qlNavigation.AddAsLast($node) | out-null
		$node.Update | out-null
        $qLink = $node # $qlNavigation | Where {$_.Title -eq $el.Title}
		foreach($child in $el.Children){
			
			#$tstListDone = isListDone $child.URL $siteListArr
			#if ($tstListDone){
				$linkNode = new-Object Microsoft.Sharepoint.Navigation.SPNavigationNode($child.Title, $child.URL,$true)
				$noresult = $qLink.Children.AddAsLast($linkNode) | out-null
				$linkNode.Update | out-null
			#}
			
		}
		
	}
	
}

function add-SchemaField($siteURL,$listName,$fieldsSchema){
	$spWebX = Get-SPWeb $siteURL
	$listX = $spWebX.Lists[$listName]
    #Check if the column exists in list already
    $FieldsX = $listX.Fields

	$DisplayName = Select-Xml -Content $fieldsSchema  -XPath "/Field" | ForEach-Object {
			 $_.Node.DisplayName
	}
	$NewField = $FieldsX | where {($_.Title -eq $DisplayName)}
    if($NewField -ne $NULL) 
    {
        Write-host "Column $DisplayName already exists in the List!" -f Yellow
    }
    else
    {
		$newField = $listX.Fields.AddFieldAsXml($fieldsSchema, $True,[Microsoft.SharePoint.SPAddFieldOptions]::AddFieldToDefaultView)
		
		Write-host "Column $DisplayName was Add to the $listName Successfully!" -ForegroundColor Green
	}	
	return $null
 	
}
function check-Integrity ($archSiteUrl, $oList ){
	#$crlf = [char][int]13+[char][int]10
	$crlf = "<br/>"
	$outStr = "<b>Check Integrity</b>" + $crlf +$archSiteUrl + $crlf
	$strInvalidateList = ""
	$strNotMihzurList = ""
	
	$aSpweb = Get-SPWeb $archSiteUrl
	$addToLog = $false
	foreach($oItm in $oList){
		if ($oItm.Done){
			if ([string]::IsNullOrEmpty($oItm.UIDNew)){
				$lst = $aSpweb.Lists | Where-Object {$_.RootFolder.Url -eq $oItm.RootFolder}	
			}
			else
			{
				$lst = $aSpweb.Lists | Where-Object{$_.ID -eq $oItm.UIDNew}
			}
			
			#
			#$lst = $aSpweb.Lists | Where-Object {$_.RootFolder.Url -eq $oItm.RootFolder}
			if ($lst.Title -ne $oItm.Title){
				#Write-Host "1392: " $oItm.UIDNew
				#Write-Host "1392: " $oItm.Title " ≠ " $lst.Title
				$lst = $aSpweb.Lists[$oItm.Title]
			}
			#
			$itmCount = $lst.ItemCount
			if ([string]::IsNullOrEmpty($itmCount)){
				$itmCount = 0
			}
	
			if ($itmCount -ne $oItm.ItemCountSrc){
				$strInvalidateList +=  "List: <b>"+$oItm.Title + "</b>"+$crlf
				
				$strInvalidateList +=   "Source Items Count     : " + $oItm.ItemCountSrc + $crlf 
				$strInvalidateList +=   "Destination Items Count: " + $itmCount + $crlf
				$strInvalidateList +=   "-----------"+ $crlf + $crlf
				
				$addToLog = $true
			}
		}
		else{
			$strNotMihzurList += "List, it wasn't archived: <b>" +   $oItm.Title +"</b>"+ $crlf
			$addToLog = $true
		}
		
	}
	if (!$addToLog){
		$outStr += "Ok"+$crlf
	}
	else{
		$outStr += $strInvalidateList + $strNotMihzurList
	}
		
	return $outStr
}
function Collect-qlMenu($spweb){
	
    $pubWeb = [Microsoft.SharePoint.Publishing.PublishingWeb]::GetPublishingWeb($spweb)
    $qlNav = $pubweb.Navigation.CurrentNavigationNodes
	
	$qlMenu = @()
	foreach($qlnavItem in $qlNav){
		$qlMainMenuItem = "" | Select Title, IsVisible, URL, Children
        if ($qlnavItem.URL.ToLower().Contains("/pages/") -or
			$qlnavItem.URL.ToLower().Contains("/sitepages/")){
			continue
		}

		$qlMainMenuItem.Title = $qlnavItem.Title
		$qlMainMenuItem.IsVisible = $qlnavItem.IsVisible
		$qlMainMenuItem.URL = "" #$qlnavItem.URL
		$qlMainMenuItem.Children = @()
		if ($qlMainMenuItem.Title.Contains($heDocLibName) -or
		    $qlMainMenuItem.Title.Contains("Recent") -or
		    $qlMainMenuItem.Title.Contains($enDocLibName) ){
			   continue
		   }
		$xsubMenu = @()
        $childrenExists = $false		
		foreach($childMenu in $qlnavItem.Children){
			#$childMenu.GetType()
			
            if ($childMenu.URL.ToLower().Contains("/pages/") -or
				$childMenu.URL.ToLower().Contains("/sitepages/") -or
				$childMenu.URL.ToLower().Contains("/submitted/forms") ){
				continue
			}
			$childItem = "" | Select Title, IsVisible, URL
			$childItem.Title = $childMenu.Title
			$childItem.URL = $childMenu.URL
			$childItem.IsVisible = $childMenu.IsVisible
			#write-host $childItem.Title
			#write-host $childItem.Url
			$xsubMenu += $childItem
			$childrenExists = $true
			#write-host $xsubMenu
			
		}
		
		$qlMainMenuItem.Children = $xsubMenu
		if ($childrenExists){
			$qlMenu += $qlMainMenuItem
		}
	}

	return 	$qlMenu
}

function Collect-qlMenuAll($spweb){
	
    $pubWeb = [Microsoft.SharePoint.Publishing.PublishingWeb]::GetPublishingWeb($spweb)
    $qlNav = $pubweb.Navigation.CurrentNavigationNodes
	
	$qlMenu = @()
	foreach($qlnavItem in $qlNav){
		$qlMainMenuItem = "" | Select Title, IsVisible, URL, Children
        if ($qlnavItem.URL.ToLower().Contains("/pages/")){
			continue
		}

		$qlMainMenuItem.Title = $qlnavItem.Title
		$qlMainMenuItem.IsVisible = $qlnavItem.IsVisible
		$qlMainMenuItem.URL = "" #$qlnavItem.URL
		$qlMainMenuItem.Children = @()
		if ($qlMainMenuItem.Title.Contains($heDocLibName) -or
		    $qlMainMenuItem.Title.Contains("Recent") -or
		    $qlMainMenuItem.Title.Contains($enDocLibName) ){
			   continue
		   }
		$xsubMenu = @()
        $childrenExists = $false		
		foreach($childMenu in $qlnavItem.Children){
			#$childMenu.GetType()
			
			
            if ($childMenu.URL.ToLower().Contains("/pages/") -or
				$childMenu.URL.ToLower().Contains("/submitted/forms") ){
				continue
			}
			$childItem = "" | Select Title, IsVisible, URL
			$childItem.Title = $childMenu.Title
			$childItem.URL = $childMenu.URL
			$childItem.IsVisible = $childMenu.IsVisible
			#write-host $childItem.Title
			#write-host $childItem.Url
			$xsubMenu += $childItem
			$childrenExists = $true
			#write-host $xsubMenu
			
		}
		
		$qlMainMenuItem.Children = $xsubMenu
		#if ($childrenExists){
			$qlMenu += $qlMainMenuItem
		#}
	}

	return 	$qlMenu
}

function Copy-DefaultQuery($srcURL, $dstURL, $listName){
	$spWebSrc = Get-SPWeb  $srcURL
	$spWebDst = Get-SPWeb  $dstURL
	
    $listSrc = 	$spWebSrc.Lists[$listName]
	$listDst =  $spWebDst.Lists[$listName]
	
	$aggrSrc = $listSrc.DefaultView.Aggregations
	
	$dstDefView = $listDst.DefaultView
	$dstDefView.ViewFields.DeleteAll();
	foreach($xF in $listSrc.DefaultView.ViewFields){
		#write-Host $xF
		$dstDefView.ViewFields.Add($xF)	
	}	
	$dstDefView.Query = $listSrc.DefaultView.Query
	$dstDefView.Aggregations = $aggrSrc
	
	$dstDefView.Update()
	$listDst.Update()

}

function Copy-Final($srcSite, $dstSite){

	$docLibName = "Final"
	$dstweb = get-SPWeb $dstSite
	$dstList = $dstweb.Lists[$docLibName]
	$dstFolder 	   = $dstweb.GetFolder($dstList.RootFolder.Url)
	
	$srcweb = get-SPWeb $srcSite
	$srcList = $srcweb.Lists[$docLibName]
	$srcFolder 	   = $srcweb.GetFolder($srcList.RootFolder.Url)

	foreach($sFile in @($srcFolder.Files)){
		#Write-host -f Yellow $sFile.Name
		$srcData = $sFile.OpenBinary()

		$srcDateCreat = $sFile.Item["Created" ]
		$srcDateEdit  = $sFile.Item["Modified"]
		$srcWhoCreat  = $sFile.Item["Author"  ]
		$srcWhoEdit   = $sFile.Item["Editor"  ]
		
		$dstFile = $dstFolder.Files.Add($sFile.Name,$srcData,$true)
		
		$dstFile.Item["Created" ] = $srcDateCreat
		$dstFile.Item["Modified"] = $srcDateEdit
		$dstFile.Item["Author"  ] = $srcWhoCreat
		$dstFile.Item["Editor"  ] = $srcWhoEdit

		$dstFile.Item.Update()
	}
	
	#write-host "change Default View of $docLibNam"
	$dstList.DefaultView.Query = $srcList.DefaultView.Query
	$dstList.DefaultView.Update()

	$dstList.Update()
	return $null
	
}
Function Copy-DocLibToDocLib ($srcSite, $dstSite ,$listO, $allList){
	# Copy Source Lookup Fields  destination  Text
	$dstweb = get-SPWeb $dstSite
	$dstList = $dstweb.Lists | Where-Object{$_.ID -eq $listO.UIDNew}
	#$dstList = $dstweb.Lists[$docLibName]
	$dstFolder 	   = $dstweb.GetFolder($dstList.RootFolder.Url)

	$srcweb = get-SPWeb $srcSite
	$srcList = $srcweb.Lists | Where-Object{$_.ID -eq $listO.UIDOld}

	$listSchema = get-ListSchemaByUID $srcSite  $listO.UIDOld
	$xmlFile =   "Schema-"+$(HebrewToLatin $($listO.Title))+".xml"
	$listSchemaArchive | out-file $xmlFile -encoding Default
	write-host "$xmlFile was written" -f Yellow
	 
	$ts = gc $xmlFile -raw 
	if (![string]::IsNullOrEmpty($ts)){
		 $msgSubj = $xmlFile
		 Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersa@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction SilentlyContinue
		 start-sleep 2
	}
	$lkUpfieldArr = $($listO.IsLookupField.FieldArr)
	#$srcList = $srcweb.Lists[$docLibName]
	$srcFolder 	   = $srcweb.GetFolder($srcList.RootFolder.Url)

    Write-Host "738 Copy From " $srcList.Title " TO " $dstList.Title 
	# source Lib With Subfolder ?
	#$is_DoclibWithSubFolders = Test-IsDocLibWithFolder $srcList
	$subFldrs = $srcList.Folders
	if ($subFldrs.Count -gt 0){
		write-Host 
		write-Host $srcList.Title " is DocLib With SubFolders"
		$fldListToCreate = @()
		foreach($fld in $subFldrs){
			$fldItem = "" | Select Name, Created, Modified, Author, Editor
			$fldItem.Name     = $fld.Name
			$fldItem.Created  = $fld["Created" ]
			$fldItem.Modified = $fld["Modified"]
			$fldItem.Author   = $fld["Author"  ]
			$fldItem.Editor   = $fld["Editor"  ]
			$fldListToCreate += $fldItem
		}
		foreach($fldToCreate in $fldListToCreate){
			$dstSubDirName = $dstList.RootFolder.Url + "/" +$fldToCreate.Name
			#write-Host 329
			
			#write-Host $dstSubDirName
			$dstSubDir = $dstList.ParentWeb.GetFolder($dstSubDirName);
			If(!$dstSubDir.Exists)
			{
				#Create a Folder
				$fldDstNew = $dstweb.Folders.Add($dstSubDirName)
				$fldDstNew.Update();
				#write-host "Created Folder '$dstSubDirName'" -f Green
				
				
				$srcSubFolderName = $srcList.RootFolder.Url+"/"+$fldToCreate.Name
				$srcFileFolder = $srcweb.GetFolder($srcSubFolderName)
				
				foreach($sFile in @($srcFileFolder.Files)){
					$srcData = $sFile.OpenBinary()

					$srcDateCreat = $sFile.Item["Created" ]
					$srcDateEdit  = $sFile.Item["Modified"]
					$srcWhoCreat  = $sFile.Item["Author"  ]
					$srcWhoEdit   = $sFile.Item["Editor"  ]
					#write-Host $sFile.Name
					$dstFile = $fldDstNew.Files.Add($sFile.Name,$srcData,$true)
					foreach($schemaField in $listSchema){

						$xmlF = $schemaField
						$isXMLsrc = [bool]$($xmlF -as [xml])
						if ($isXMLsrc){
								$fieldDispName = Select-Xml -Content $xmlF  -XPath "/Field" | ForEach-Object { $_.Node.DisplayName.Trim()}
								$fieldName = Select-Xml -Content $xmlF  -XPath "/Field" | ForEach-Object { $_.Node.Name.Trim()}
								$fieldType = Select-Xml -Content $xmlF  -XPath "/Field" | ForEach-Object { $_.Node.Type.Trim()}
								$srcVal = $sFile.Item[$fieldDispName] 
								$srcValName = $sFile.Item[$fieldName] 

								if ($fieldType -eq "Lookup"){
									
									$srcLookUp = new-object Microsoft.SharePoint.SPFieldLookupValue($srcValName) 
									$srcLookUpValue = $srcLookUp.LookupValue
									$dstFile.Item[$fieldDispName] = $srcLookUpValue				
						
								}
								else
								{
									if ($fieldType -ne "File"){
										$dstFile.Item[$fieldDispName] = $srcVal 
										#$dstItem[]
									}
								}
						
						}
					
					}		
					$dstFile.Item["Created" ] = $srcDateCreat
					$dstFile.Item["Modified"] = $srcDateEdit
					$dstFile.Item["Author"  ] = $srcWhoCreat
					$dstFile.Item["Editor"  ] = $srcWhoEdit

					$dstFile.Item.Update()
				}
						
				
			}			
		}

		
		foreach($fldToCreate in $fldListToCreate){
			$dstSubDirName = $dstList.RootFolder.Url + "/" +$fldToCreate.Name
			$dstSubDir = $dstList.ParentWeb.GetFolder($dstSubDirName);
			If($dstSubDir.Exists)
			{
				#Create a Folder
				$dstSubDir.Item["Created" ] = $fldToCreate.Created
				$dstSubDir.Item["Modified"] = $fldToCreate.Modified
				$dstSubDir.Item["Author"  ] = $fldToCreate.Author
				$dstSubDir.Item["Editor"  ] = $fldToCreate.Editor
				$dstSubDir.Item.Update();
				#write-host "Updated Metadata Folder '$dstSubDirName'" -f Green
			}			
		}
		
		#read-host
		
	}
	else{
	
		foreach($sFile in @($srcFolder.Files)){
			$srcData = $sFile.OpenBinary()

			$srcDateCreat = $sFile.Item["Created" ]
			$srcDateEdit  = $sFile.Item["Modified"]
			$srcWhoCreat  = $sFile.Item["Author"  ]
			$srcWhoEdit   = $sFile.Item["Editor"  ]
			
			$dstFile = $dstFolder.Files.Add($sFile.Name,$srcData,$true)
			foreach($schemaField in $listSchema){

				$xmlF = $schemaField
				$isXMLsrc = [bool]$($xmlF -as [xml])
				if ($isXMLsrc){
						$fieldDispName = Select-Xml -Content $xmlF  -XPath "/Field" | ForEach-Object { $_.Node.DisplayName.Trim()}
						$fieldName = Select-Xml -Content $xmlF  -XPath "/Field" | ForEach-Object { $_.Node.Name.Trim()}
						$fieldType = Select-Xml -Content $xmlF  -XPath "/Field" | ForEach-Object { $_.Node.Type.Trim()}
						$srcVal = $sFile.Item[$fieldDispName] 
						$srcValName = $sFile.Item[$fieldName] 

						if ($fieldType -eq "Lookup"){
							
							$srcLookUp = new-object Microsoft.SharePoint.SPFieldLookupValue($srcValName) 
							$srcLookUpValue = $srcLookUp.LookupValue
							$dstFile.Item[$fieldDispName] = $srcLookUpValue				
				
						}
						else
						{
							if ($fieldType -ne "File"){
								$dstFile.Item[$fieldDispName] = $srcVal 
								#$dstItem[]
							}
						}
				
				}
			
			}		
			$dstFile.Item["Created" ] = $srcDateCreat
			$dstFile.Item["Modified"] = $srcDateEdit
			$dstFile.Item["Author"  ] = $srcWhoCreat
			$dstFile.Item["Editor"  ] = $srcWhoEdit

			$dstFile.Item.Update()
		}
	
	}
	$dstList.Update()
	return $null	
}
function CopyDocLib($srcSite, $dstSite , $langID, $docLibName, $docLibRootFolder ){
	$srcDocTypeFieldName = "Document Type"
	if ($langID -eq 1037){
		$srcDocTypeFieldName = "תוכן קובץ"
	}
	$dstweb = get-SPWeb $dstSite
	#Write-Host "670: $($docLibRootFolder)"
	$dstList = $dstweb.Lists | Where-Object {$_.RootFolder.Url -eq $docLibRootFolder}
	#$dstList = $dstweb.Lists[$docLibName]
	$dstFolder 	   = $dstweb.GetFolder($dstList.RootFolder.Url)
	#write-host "Destination Folder: $($dstList.RootFolder.Url)"
	
	$srcweb = get-SPWeb $srcSite
	#$srcList = $srcweb.Lists[$docLibName]
	$srcList = $srcweb.Lists | Where-Object {$_.RootFolder.Url -eq $docLibRootFolder}
	$srcFolder 	   = $srcweb.GetFolder($srcList.RootFolder.Url)
	#write-host "Source Folder: $($srcList.RootFolder.Url)"
    #Write-Host "681: Copy from $srcFolder To $dstFolder"
	foreach($sFile in @($srcFolder.Files)){
		#$oldFile.Recycle() | Out-Null
		#$fileName = $sFile.ServerRelativeURL.Split("/")[-1]
		#Write-host -f Yellow $sFile.Name
		$srcDocTypeValue = new-object Microsoft.SharePoint.SPFieldLookupValue($sFile.Item[$srcDocTypeFieldName] )
		$srcData = $sFile.OpenBinary()
		#$srcDocTypeID = $srcDocTypeValue.LookupId
		$srcDocTypeValue = $srcDocTypeValue.LookupValue

		$srcDateCreat = $sFile.Item["Created" ]
		$srcDateEdit  = $sFile.Item["Modified"]
		$srcWhoCreat  = $sFile.Item["Author"  ]
		$srcWhoEdit   = $sFile.Item["Editor"  ]
		$srcResponse  = $sFile.Item["sentResponse"]
		
		$newDocTypeID = Map-DocType $dstSite $srcDocTypeValue 
		$dstFile = $dstFolder.Files.Add($sFile.Name,$srcData,$true)

		#write-host "srcDateCreat : $srcDateCreat"
		#write-host "srcDateEdit  : $srcDateEdit"
		#write-host "srcWhoCreat  : $srcWhoCreat"
		#write-host "srcWhoEdit   : $srcWhoEdit"
		
		$dstFile.Item["Created" ] = $srcDateCreat
		$dstFile.Item["Modified"] = $srcDateEdit
		$dstFile.Item["Author"  ] = $srcWhoCreat
		$dstFile.Item["Editor"  ] = $srcWhoEdit
		$dstFile.Item["sentResponse"] = $srcResponse
		$dstFile.Item[$srcDocTypeFieldName] = $newDocTypeID

		$dstFile.Item.Update()
	}
	#write-host "change Default View of DocLib"
		
	$dstDefView = $dstList.DefaultView
	$vwFields =  @()
	$vwFields += "Edit"
	foreach($fld in $dstDefView.ViewFields)
	{
		$vf = $fld 
		if ($vf -eq "Editor"){
			continue
		}
		if ($vf -eq "Edit"){
			continue
		}
		if ($vf -eq "sentResponse"){
			continue
			
		}		
		if ($vf -eq "Modified"){
			$vf	= "Created"
		}
		$vwFields += $vf
	}

	$dstDefView.ViewFields.DeleteAll();
	foreach($xF in $vwFields){
		$dstDefView.ViewFields.Add($xF)	
	}
	$dstDefView.Query = $srcList.DefaultView.Query
	
	$dstDefView.Update()
	$dstList.Update()
	return $null
}

# Copy Old List To New List
Function Copy-ListToList( $srcSite, $dstSite, $listO, $siteObj){
	$dstweb = get-SPWeb $dstSite
	$dstList = $dstweb.Lists | Where-Object{$_.ID -eq $listO.UIDNew}
	#$dstList = $dstweb.Lists[$docLibName]
	$dstFolder 	   = $dstweb.GetFolder($dstList.RootFolder.Url)
	
	$srcweb = get-SPWeb $srcSite
	$srcList = $srcweb.Lists | Where-Object{$_.ID -eq $listO.UIDOld}

	$srcFolder 	   = $srcweb.GetFolder($srcList.RootFolder.Url)

    Write-Host "Msg 453: Copy From " $srcList.Title " TO " $dstList.Title 
	#Get all source items
	$SourceColumns = $srcList.Fields
	$SourceItems = $srcList.GetItems();
	 
	#Iterate through each item and add to target list
	Foreach($SourceItem in $SourceItems)
	{
		$fldDateCreat = $sourceItem["Created" ]
		$fldDateEdit  = $sourceItem["Modified"]
		$fldWhoCreat  = $sourceItem["Author"  ]
		$fldWhoEdit   = $sourceItem["Editor"  ]
		
		$TargetItem = $dstList.AddItem()
		Foreach($column in $SourceColumns)
		{
			if($column.Hidden -eq $False -and $column.ReadOnlyField -eq $False -and $column.InternalName -ne "Attachments")
			{
				if($column.Type -eq "Lookup"){
					$srcLookUp = new-object Microsoft.SharePoint.SPFieldLookupValue($sourceItem[$($column.InternalName)] )
					
					#$srcDocTypeID = $srcDocTypeValue.LookupId
					$srcLookUpValue = $srcLookUp.LookupValue
					$TargetItem[$($column.InternalName)] = $srcLookUpValue				
				}
				else
				{
					$srcVal = $sourceItem[$($column.InternalName)];
					if ($Column.Type -eq "URL"){
						if (![string]::IsNullOrEmpty($srcVal)){
								
								$urlDescription = $srcVal.Split(",")[1].Trim()
								$urlLink = $srcVal.Split(",")[0].Trim()
								$urlLink = $urlLink.ToLower()  -Replace $localPathSrc,$localPathArc
	
								$tlink = New-Object Microsoft.SharePoint.SPFieldURLValue($sourceItem[$($column.InternalName)])
								$tlink.Description = $urlDescription
								$tlink.Url =  $urlLink 
								$TargetItem[$column.InternalName] = $tlink.ToString()
						}
					}
					else
					{
						$TargetItem[$($column.InternalName)] = $srcVal
					}
				} 
			}
		}
		$TargetItem["Created" ] = $fldDateCreat
		$TargetItem["Modified"] = $fldDateEdit		
		$TargetItem["Author"  ] = $fldWhoCreat		
		$TargetItem["Editor"  ] = $fldWhoEdit	
			
	    $TargetItem.Update();
	}

	#$dstList.Update()
	return $null
	
}

function Create-ListOnArchiveFromTemplate($archivesite,$listItm){
	$listCreated = "" | Select Done, UID, URL
	$listCreated.Done = $false
	$listCreated.UID = $null
	$TemplateName=$listItm.templateFileName+".stp"
	$lTitle = $listItm.Title
	$listName = $listItm.RootFolder	

	if ($listItm.BaseTemplate -eq 100){
		$listName = $listItm.RootFolder.Split("/")[1]
	}

	
	$archiveWeb = get-SPWeb $archivesite.URL
	if ([string]::IsNullOrEmpty($archiveWeb.Lists[$listName])){ # List does not exists
		$Template = $archiveWeb.site.GetCustomListTemplates($archiveWeb) | where {$_.InternalName -match $TemplateName }

		#Check if given template name exists!
		if($Template -eq $null){
			Write-host "Specified list template '$TemplateName' not found!" -f Red
		}
		else{
			#Create list using template in sharepoint 2013
			#Write-host "New List $listName Creating from Custom List template" -f Green
          
			$listCreated.UID = $($archiveWeb.Lists.Add($listName, $lTitle, $Template)).Guid # | Out-Null
			$listCreated.Done = $true
			$listN = $archiveWeb.Lists | Where-Object{$_.ID -eq $listCreated.UID}
			$listN.Title = $lTitle
			$listN.Update()
			$listCreated.URL = $listN.RootFolder.Url
			
		}
	}
	else
	{
	   write-host "List $listName already exists" -f Yellow
	}
    return $listCreated	
}
function Create-NewArchiveSubSite($spWeb,$newSubSiteObj){
	$siteTitle = $newSubSiteObj.Title
	$langID = $spWeb.Language
	$siteDescription  = "Archive site for date " + $newSubSiteObj.ArchiveDate+"."
	$siteURL  = $spWeb.URL+"/"+$newSubSiteObj.Title+"/"
	$webTemplate = "STS#0" #Team Site template	
	$subSite = New-SPWeb -Name $siteTitle -Description $siteDescription -Url $siteURL -Template $webTemplate -Language $langID # -AddToTopNav $false -UniquePermissions $false -UseParentTopNav $false

 
	return $subSite
}

function Create-WorkingDir($groupName, $mhzurDir){
	#$mhzurDir = '.\_Mihzur\'
	#Remove-Tree $mhzurDir
	$tmpDir = $mhzurDir+$groupName
	If (!(Test-Path -path $tmpDir))
	{   
	
		$wDir = New-Item $tmpDir -type directory
	}
	else
	{
		$wDir = Get-Item $tmpDir 
		
	}
    return $wDir	
}
function Create-TemplateDir($templDirName){
	$tmpDir = '.\'+$templDirName
	If (!(Test-Path -path $tmpDir))
	{   
		$wDir = New-Item $tmpDir -type directory
	}
	else
	{
		$wDir = Get-Item $tmpDir 
		
	}
	Get-ChildItem $wDir -Include *.* -Recurse |  ForEach  { $_.Delete()}
    return $wDir	
}
function create-WPPage($siteURL, $PageName, $setDefault){
	$spWeb = Get-SPWeb $siteURL
	write-Host $siteURL
    $pageFullName = "Pages/" + $PageName + ".aspx"
	$pageFile = $spweb.GetFile($pageFullName)
    if ($pageFile.exists){
		
	}
	else
	{
		$pubWeb =[Microsoft.SharePoint.Publishing.PublishingWeb]::GetPublishingWeb($spWeb)
		# Create blank web part page
		$pl = $pubWeb.GetAvailablePageLayouts() | Where { $_.Name -eq "BlankWebPartPage.aspx" } #you may change "BlankWebPartPage.aspx" to your custom page layout file name
		$newPage = $pubWeb.AddPublishingPage($PageName + ".aspx", $pl) #filename need end with .aspx extension
		$newPage.Update()
		# Check-in and publish page
		$newPage.CheckIn("")
		$newPage.ListItem.File.Publish("")
		
		
		
	}
	if ( $setDefault){
		$spWeb = Get-SPWeb $siteURL
		$pageFile = $spWeb.GetFile($pageFullName)
		$pubWeb =[Microsoft.SharePoint.Publishing.PublishingWeb]::GetPublishingWeb($spWeb)
		$pubWeb.DefaultPage = $pageFile
		$pubWeb.Update();
		$spweb.Update()
	}

 
}
function deleteListTemplate($SiteURL,$ListTemplateName){
	$spSite = Get-SPSite $SiteURL
	$ListTemplateFolder = $spSite.RootWeb.GetFolder("_catalogs/lt")
	$ListTemplates =  $ListTemplateFolder.Files
	#$listSiteCollectFile = Join-Path $wDir "Templates.json"
	#$ListTemplates | ConvertTo-Json -Depth 1 | out-file $listSiteCollectFile
	
	$templatesCollection = $ListTemplateFolder.Files | Where-Object { $_.Name -like $ListTemplateName+'*' }
	
	foreach($ListTemplate in $templatesCollection){
		$ListTemplate.delete()
		#To permanently delete, call: $ListTemplate.delete();
		write-host "Deleted List template $ListTemplate" -f Yellow
	
	}

}
function Delete-QuickLaunchMenu ($spweb)
{
    $pubWeb = [Microsoft.SharePoint.Publishing.PublishingWeb]::GetPublishingWeb($spweb)
    $qlNav = $pubweb.Navigation.CurrentNavigationNodes
    for ($i=$spWeb.Navigation.QuickLaunch.count-1;$i -ge 0;$i--)
    {     
          $IsMenuForDeleting = $true
		  
		  $children = $spWeb.Navigation.QuickLaunch[$i].Children
		  $spWeb.Navigation.QuickLaunch[$i].Delete()

    }
	$spWeb.Update()
	
	
}
Function Delete_LookupFields($siteUrl, $listO){
	$spWeb =  Get-SPWeb $siteUrl
	$list = $spWeb.Lists |  Where-Object{$_.ID -eq $listO.UIDNew}
	if ($list){
		if ($listO.IsLookupField.isLookup){
			foreach($lookUpFld in $listO.IsLookupField.FieldArr){
				#Get the Column to delete
				$column = $list.Fields[$lookUpFld.FieldTitle]
		 
				$column.Sealed = $false
				$column.ReadOnlyField = $false
				$column.AllowDeletion = $true
				$column.Update()
				#Delete the column from list
				$list.Fields.Delete($column.InternalName)
        
 				#Write-host "Lookup Column $($lookUpFld.FieldTitle) was deleted from the List $($List.Title) Successfully!" -ForegroundColor Green 
		

			}
		}
	}
	else
	{
		write-Host "Error : Procedure Delete_LookupFields : Not Found List $($listO.Title)" -f Yellow
	}
}
# Change LookupFields To TextFields 
Function Create_LookupFieldsAsText($siteUrl, $listO){
	$spWeb =  Get-SPWeb $siteUrl
	$list = $spWeb.Lists |  Where-Object{$_.ID -eq $listO.UIDNew}
	if ($list){
		if ($listO.IsLookupField.isLookup){
			foreach($lookUpFld in $listO.IsLookupField.FieldArr){
				#Get the Column to delete
				$Fields = $List.Fields
        
				$NewField = $Fields | where { ($_.Internalname -eq $lookUpFld.FieldInternalName) -or ($_.Title -eq $lookUpFld.FieldTitle) }
				if($NewField -ne $NULL) 
				{
					Write-host "Column $($lookUpFld.FieldTitle) already exists in the List!" -f Yellow
				}
				else
				{
					#Define XML for Field Schema
					$FieldSchema = "<Field Type='Text'   DisplayName='$($lookUpFld.FieldTitle)'  />"
					$NewField = $List.Fields.AddFieldAsXml($FieldSchema,$True,[Microsoft.SharePoint.SPAddFieldOptions]::AddFieldToDefaultView)
					 
		 
					#Write-host "Text Column $($lookUpFld.FieldTitle) was added to the List $($List.Title) Successfully!" -ForegroundColor Green 
				}



			}
		}
	}
	else
	{
		write-Host "Error : Procedure Create_LookupFieldsAsText : Not Found List $($listO.Title)" -f Yellow
	}
}
function get-ArchiveDate($dtNow){
	$dtNowS = $dtNow.Year.ToString() + "-" +$dtNow.Month.ToString().PadLeft(2,"0") + "-"+$dtNow.Day.ToString().PadLeft(2,"0") 
	return 	$dtNowS
}
function get-FrendlyDate($dtNow){
	$dtNowS = $dtNow.Year.ToString() + "-" +$dtNow.Month.ToString().PadLeft(2,"0") + "-"+$dtNow.Day.ToString().PadLeft(2,"0") + " " + $dtNow.Hour.ToString().PadLeft(2,"0")+":"+$dtNow.Minute.ToString().PadLeft(2,"0")+":"+$dtNow.Second.ToString().PadLeft(2,"0")
	return 	$dtNowS
}
function get-FrendlyDateLog($dtNow){
	$dtNowS = $dtNow.Year.ToString() + "-" +$dtNow.Month.ToString().PadLeft(2,"0") + "-"+$dtNow.Day.ToString().PadLeft(2,"0") + "-" + $dtNow.Hour.ToString().PadLeft(2,"0")+"-"+$dtNow.Minute.ToString().PadLeft(2,"0")+"-"+$dtNow.Second.ToString().PadLeft(2,"0")
	return 	$dtNowS
}

function get-ReportDate($dtNow){
	$dtNowS = $dtNow.Day.ToString().PadLeft(2,"0") + "."+ $dtNow.Month.ToString().PadLeft(2,"0") + "." + $dtNow.Year.ToString() + " "  + $dtNow.Hour.ToString().PadLeft(2,"0")+":"+$dtNow.Minute.ToString().PadLeft(2,"0")
	return 	$dtNowS
}
function get-ScrptFullPath($scriptX ){
	$fileScr = get-Item $scriptX
	return $fileScr.DirectoryName
}

function get-ListsNotDone ($archSiteUrl, $oList ){
	$arrListNotDone=@()
	$aSpweb = Get-SPWeb $archSiteUrl
	foreach($oItm in $oList){
		if (!$oItm.Done){
		    $listND  = $aSpweb[$oItm.Title] 
			if ([string]::IsNullOrEmpty($listND)){
				
				$arrListNotDone	+= $oItm
			}
		}
	}	
	return $arrListNotDone
}

function get-ListSchemaByUID($siteURL,$UID){
	
	$fieldsSchema = @()
	$spWeb = get-SPWeb $siteUrl
	
	#$List = $spWeb.lists[$ListName]
	$List = $spWeb.lists | Where-Object{$_.ID -eq $UID}

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
	$spWeb = get-SPWeb $siteUrl
	$List = $spWeb.lists[$ListName]

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
function Get-NewRootFolder ($Title, $oldRootFolder, $oSiteList){
	$retValue = $oldRootFolder
	$pureRootFolder = $oldRootFolder
	if ($pureRootFolder.ToLower().Contains("aspx")){
		$pureRootFolder = $pureRootFolder.Substring(0,$pureRootFolder.LastIndexOf("/"))
		if ($pureRootFolder.Contains("Forms")){
			$pureRootFolder = $pureRootFolder.Substring(0,$pureRootFolder.LastIndexOf("/"))
		}
	}
	#read-host
	foreach($oItem in  $oSiteList){
		if ($oItem.RootFolder.ToLower() -eq $pureRootFolder.ToLower()){
			$retValue = $oItem.RootFolderNew
		}
	}
	return $retValue
} 
function get-SiteGroup($siteUrl){
	$strArr = $siteUrl.Split("/")
	$retStr = $($strArr[2].ToLower().replace("2.ekmd.huji.ac.il","").replace(".ekmd.huji.ac.il","")+"_"+$strArr[5]).ToUpper()
	return $retStr
}
function get-siteToArchive(){
$mihzurObj = @()
$xmlConfigFile = "\\ekeksql00\SP_Resources$\WP_Config\availableXYZListPath\availableXYZListPath.xml"
$xmlFile = Get-Content $xmlConfigFile -raw
$isXML = [bool](($xmlFile) -as [xml])
		if ($isXML){
			#$xmlNodeData = Select-Xml -Path $wrkFileName -XPath "/Config/application/control" | ForEach-Object 
			              #{$_.Node.Data}
						  
			$xmlDoc = [xml]$xmlFile
			$configXYZList = $xmlDoc.SelectNodes("//application")
			foreach($elXYZ in $configXYZList){
				$currentSite = $elXYZ.appHomeUrl
				$currentList = $elXYZ.listName

				$spWeb =  get-SPWeb $currentSite -ErrorAction SilentlyContinue
				if ($spWeb){
					#write-host "1072: $currentSite was Opened" -f Magenta	
					$webTitle = $spWeb.Title
					#write-host $currentSite -f Yellow
					#write-host "1075: " $currentList -f Green

					#write-host $webTitle -f Magenta
					$list = $spWeb.Lists[$currentList]
					$FieldsOfList = $list.Fields
					$arcfieldName = "Archive_Waiting_for_Archivation"
					$creatArchExists =  $FieldsOfList | where{$_.Title -eq $arcfieldName}
					if ($creatArchExists){
						$query=New-Object Microsoft.SharePoint.SPQuery
						$query.Query = "<Where><Eq><FieldRef Name='$arcfieldName' /><Value Type='Boolean'>1</Value></Eq></Where>"

						# 'Status'is the name of the List Column. 'CHOICE'is the information type of the Column.

						$SPListItemCollection = $list.GetItems($query)
						#$SPListItemCollection.Count
						foreach($listItem in $SPListItemCollection){
							$mihzurItem =  "" | Select  XYZSite, XYZList, ID, ArchiveURL,RealArchiveSiteURL,srcSiteName,srcSiteDescr,FinalLists,applicantList
							$mihzurItem.XYZSite = $currentSite
							$mihzurItem.XYZList = $currentList
							$mihzurItem.ID = $listItem.ID
							$mihzurItem.ArchiveURL = $listItem["url"]
							$mihzurItem.RealArchiveSiteURL = ""
							$mihzurItem.FinalLists = $listItem["Archive_Lists_Final"]
							$mihzurItem.applicantList = $listItem["destinationList"]
							$mhzAddToObj = $true
							foreach($mhzItem in $mihzurObj){
								if ($mhzItem.ArchiveURL -eq $mihzurItem.ArchiveURL){
									# url already exists
									$mhzAddToObj = $false
									break
								}
							}
							if ($mhzAddToObj){
								$mihzurObj += $mihzurItem
								write-host "$($mihzurItem.ArchiveURL) : Will Archive"  -f Green	
							}
						}
					}
					else
					{
						Write-Host "Field $arcfieldName Does Not Exists in $currentList "
						Write-Host "On Site  $currentSite"
					}
					$spWeb.Dispose()
				}
				
			}
			
		}
		else
		{
			write-host "$xmlConfigFile File type is not XML file!" 
		}
		return $mihzurObj
	
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
 
	$sourceFields = Select-Xml -Content $FieldXMLSrc  -XPath "/Fields/Field" | ForEach-Object {
		 $_.Node.DisplayName.Trim().ToLower()
	}
	$destFields = Select-Xml -Content $FieldXMLDst  -XPath "/Fields/Field" | ForEach-Object {
		$_.Node.DisplayName.Trim().ToLower()
	}
	
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
			
			 $fieldsSchema += $scSrc[$idx]
		}		
		$idx++
		
	}
	
	return $fieldsSchema	
}


function Get-Tree($Path,$Include='*') { 
    @(Get-Item $Path -Include $Include -Force) + 
        (Get-ChildItem $Path -Recurse -Include $Include -Force) | 
        sort pspath -Descending -unique
} 


function Get-NextArchiveSubSiteObj($spWeb){
	$subsites = $spWeb.Webs
	$currDate = Get-Date
	$archiveDate = get-ArchiveDate $currDate
	$currentArchiveNameTempl = "Archive-"+ $archiveDate
	$currentArchiveName = $currentArchiveNameTempl
	$currSiteIndex = 1

	do{
		$archiveExists = $false
		foreach($subsite in $subsites){
			if ($subsite.Title.ToLower().trim() -eq $currentArchiveName.ToLower().trim() ){
				
				$currentArchiveName = $currentArchiveNameTempl + "-" + $currSiteIndex.ToString()
				$archiveExists = $true
				$currSiteIndex++
				break
			}
		}
		
	}while ($archiveExists)
	
	
	
	$newSiteObj = "" | Select Title, ArchiveDate
	$newSiteObj.Title = $currentArchiveName
	$newSiteObj.ArchiveDate = $archiveDate
	
    return $newSiteObj
}
function Get-DocTypeSchema($dstweb, $languageID){
	$parentList = $dstweb.Lists['DocType']
	$DisplayName = "Document Type"
	if ($languageID -eq 1037){
		$DisplayName = "תוכן קובץ"	
	}
	$Name = "DocType"
	$Description = "Lookup DocType"
	$Required =  "FALSE"
	$EnforceUniqueValues = "FALSE"
	$LookupListID = $parentList.ID
	$LookupWebID = $dstweb.ID
	$LookupField = "Title"
	$lookUpDocTypeSchema = "<Field Type='Lookup' DisplayName='$DisplayName' Name='$Name' Description='$Description' Required='$IsRequired' EnforceUniqueValues='$EnforceUniqueValues' List='$LookupListID' WebId='$LookupWebID' ShowField='$LookupField' />"
    return 	$lookUpDocTypeSchema
}
function get-PageContent($siteURL, $PageName, $pageField){
	$spWeb = Get-SPWeb $siteURL
	#write-Host $siteURL
	
    $pageFullName = "Pages/" + $PageName + ".aspx"
	#write-Host $pageFullName
	$page = $spweb.GetFile($pageFullName)
	$PageContent = ""
    if ($page.exists){
		$page.CheckOut()
		$pageFields = $page.ListItemAllFields
		$PageContent = $pageFields[$pageField]
		$page.UndoCheckOut()
	}
	return $PageContent
}

function get-LookupArray( $fa){
	$FieldArr = @()
	foreach($fld in $fa){
		if (!$fld.Hidden){	
			$isServiceField = $false
			foreach($srvLF in $ServiceLookupFields){
				if ($srvLF -eq $fld.InternalName){
					$isServiceField = $true
					break
				}
			}
			if (!$isServiceField){	
				if ($fld.Type.ToString().Contains("Lookup")){
			
					$xmlF = "<Fields>"+$fld.SchemaXml+"</Fields>"
					$isXMLsrc = [bool]$($xmlF -as [xml])
					if ($isXMLsrc){
						$SourceListID = Select-Xml -Content $xmlF  -XPath "/Fields/Field" | ForEach-Object { $_.Node.List}
						$SourceListName = $homeweb.Lists | Where{$SourceListID.Contains($_.ID) }
						#write-host
						$fieldItm = "" | Select FieldTitle, FieldInternalName	,SourceListID,SourceListTitle
						# write-Host 296 $SourceListID
						$fieldItm.SourceListID = $SourceListID					
						$fieldItm.SourceListTitle = $SourceListName.Title					
						$fieldItm.FieldTitle = $fld.Title					
						$fieldItm.FieldInternalName = $fld.InternalName		
						$FieldArr += $fieldItm
						
					}
				}
			}
		}
	}
	return $FieldArr	
}
function get-ListID($siteURL,$listName){
   $spWeb = get-SPWeb $siteURL
   $id = ""

   if (![string]::IsNullOrEmpty($spWeb.Lists[$listName])){
		$List = $spWeb.lists[$listName]
		if($List){
			$id = $List.ID
		}
   }
   return $id
	
}



function get-LookupIdByValue($SiteName, $ListId,$lookUpValue){
    $retVal = 1
	if (![string]::IsNullOrEmpty($lookUpValue)){
		$valueFound=$false
		$spWeb = get-SPWeb $SiteName
		$lookUpList = $spWeb.Lists  | Where-Object{$_.ID -eq $ListId}
		
		foreach($itm in $lookUpList.Items){
			
			if ($itm.Title.Trim() -eq $lookUpValue.Trim()){
				$retVal = $itm.ID
				$valueFound = $true
				break
			}
			
		}
		if (!$valueFound){
			write-host "Error: Lookup Value: '$lookUpValue' not found."
			write-host "Error: Lookup Site: '$SiteName'"
			write-host "Error: Lookup List: '$ListName'"
			
		}
	}
	return $retVal	
}
function Get-NewListId ($allList, $listID){
	$newListId = $null
	
	foreach($lst in $allList){
		if ($lst.UIDOld -eq $listID){
			$newListId = $lst.UIDNew
			break
		}
	}
	return $newListId
}
function isListDone($Urlx,$siteListArr){
	$done = $false
	$lUrl = $Urlx.ToLower()
	#write-host 178 $lUrl
	$lIndex = $lUrl.IndexOf("/lists/")
	if ($lIndex -eq -1){
		$dIndex = $lUrl.IndexOf($newArchiveObj.Title.ToLower())
		if ($dIndex -gt 0){
			$subsList = $lUrl.Substring($dIndex)
			$doclibName = $subsList.Split("/")[1]
			
			foreach($listEl in $siteListArr){
				if (($listEl.BaseTemplate -eq 101) -and ($listEl.Title.ToLower() -eq $doclibName)){
					$done = $listEl.Done
					
					break
				}
			
			}
		}	
	}
	else
	{
		#write-host 180 $lIndex
		$subsList = $lUrl.Substring($lIndex)
		#write-host 187 $subsList
		$listName = $subsList.Split("/")[2]
	    #write-host 182 $listName
		foreach($listEl in $siteListArr){
			if (($listEl.BaseTemplate -eq 100) -and ($listEl.Title.ToLower() -eq $listName)){
				$done = $listEl.Done
				break
			}
		}
	}
	return $done
}
function Is-ListExists ($siteUrl, $oList){
	$retValue = $False
    	
	if (![string]::IsNullOrEmpty($oList.RootFolder)){
		$spWeb = Get-SPWeb $siteUrl
		$list = $spWeb.Lists | where-Object {$_.RootFolder.Url -eq $oList.RootFolder} 
		if (![string]::IsNullOrEmpty($list)){
			$retValue = $true
		}
	}
	
	if (!$retVal){
		if (![string]::IsNullOrEmpty($oList.Title)){	
			$spWeb = Get-SPWeb $siteUrl
			$list = $spWeb.Lists | where-Object {$_.Title -eq $oList.Title} 
			if (![string]::IsNullOrEmpty($list)){
				$retValue = $true
			}		
		}
	}
	return $retValue
}
function IsFieldLookup($fieldS){
	$containsLookup = "" | Select isLookup, FieldArr
	$containsLookup.isLookup = $false
	$containsLookup.FieldArr = @()
	$ServiceLookupFields = "ItemChildCount","FolderChildCount","AppAuthor","AppEditor",
							"ParentVersionString","ParentLeafName","_CheckinComment","ContentType"
	foreach($fld in $fieldS){
		if (!$fld.Hidden){
			$isServiceField = $false
			foreach($srvLF in $ServiceLookupFields){
				if ($srvLF -eq $fld.InternalName){
					$isServiceField = $true
					break
				}
			}
			if (!$isServiceField){
				if ($fld.Type.ToString().Contains("Lookup")){
					$containsLookup.isLookup = $true
					#break
				}
			}
		}
	}
	$containsLookup.FieldArr = get-LookupArray $fieldS

	return $containsLookup
}

function Inher-MasterPage($srcSiteURL, $archSiteURL){
	$topSPWeb  = get-SPweb $srcSiteURL
	$archSPWeb = get-SPweb $archSiteURL
	
	$archSPWeb.CustomMasterUrl = $topSPWeb.CustomMasterUrl;
    $archSPWeb.AllProperties["__InheritsCustomMasterUrl"] = "True";
    $archSPWeb.MasterUrl = $topSPWeb.MasterUrl;
    $archSPWeb.AllProperties["__InheritsMasterUrl"] = "True";
    $archSPWeb.AlternateCssUrl = $topSPWeb.AlternateCssUrl;
    $archSPWeb.AllProperties["__InheritsAlternateCssUrl"] = "True";
    $archSPWeb.Update();
	return $null	
}
function HebrewToLatin($phraseHeb){
	
	$abcHeb = "אבגדהוזחטיךכלםמןנסעףפץצקרשת"
	$abcLat = "abgdaozhtikklmmnnsappcckrst"
	$cnt = $phraseHeb.Length

	$outPhraseLatin = ""
	for($k=0;$k -lt $cnt;$k++){
		$symbl = $phraseHeb[$k]
		$idx = $abcHeb.IndexOf($symbl)
		if ($idx -ge 0)
		{
			$outPhraseLatin += $abcLat[$idx]
		}
		else
		{
			$outPhraseLatin += $symbl
		}
	}

	return $outPhraseLatin
}

function Map-DocType($siteURL, $DocTypeValue){
	$retValue = $null
	$spWeb = get-SPWeb $siteURL
	$docTypeList = $spWeb.Lists["DocType"]
	$found = $false
	foreach($item in $docTypeList.Items){
		if ($item.Name -eq $DocTypeValue){
			$retValue = $item.ID
			#write-Host "found ID"
			$found=$true
			break
		}
	}
	if (!$found){
			write-Host "not found ID for: $DocTypeValue" -f Yellow
	}
	return $retValue
}
function Replace-QLMenu( $qlMenuOld, $localPathSrc, $localPathArc, $oSiteList){
	$qlMenu = @()
	foreach($qlnavItem in $qlMenuOld){
		$qlMainMenuItem = "" | Select Title, IsVisible, URL, Children
 
		$qlMainMenuItem.Title = $qlnavItem.Title
		$qlMainMenuItem.IsVisible = $qlnavItem.IsVisible
		$qlMainMenuItem.URL = $qlnavItem.URL -Replace $localPathSrc,$localPathArc
		$qlMainMenuItem.Children = @()

		$xsubMenu = @()
       		
		foreach($childMenu in $qlnavItem.Children){
			
  			
			$childItem = "" | Select Title, IsVisible, URL
			$childItem.Title = $childMenu.Title
			$childItem.URL = $childMenu.URL -Replace $localPathSrc.ToLower(),$localPathArc
			$childItem.IsVisible = $childMenu.IsVisible
			$xsubMenu += $childItem
			
			
		}
		
		$qlMainMenuItem.Children = $xsubMenu
		$qlMenu += $qlMainMenuItem
		
	}

	return 	$qlMenu	
}



function Remove-SitePermissions($siteUrl){
	$spWeb = Get-SPweb $siteURL
	$spWeb.BreakRoleInheritance($true)
		
	$maxGrp = $spWeb.RoleAssignments.Count + 2
	for($k = 1; $k -le  $maxGrp ; $k++){
		$spWeb = Get-SPweb $siteURL
		$ra = $spWeb.RoleAssignments
		$raObj  = @()
		foreach($raItm in $ra){
			$raIem = "" | Select Name, LoginName
			$raIem.Name      =  $raItm.Member.Name 
			$raIem.LoginName =  $raItm.Member.LoginName
			
			#write-Host 	$raIem.Name -f Yellow
			#write-Host 	$raIem.LoginName -f Yellow
			#write-Host ---------------------- -f Magenta
			
			$raObj  += $raIem
		}

		for($i=0;$i -lt $raObj.Count; $i++){
			# leave only ADMIN_SP ADMIN_UG Groups in Site Permissions

			if (-not $raObj[$i].LoginName.ToUpper().Contains("_ADMIN")){
				write-Host "Removed : " $raObj[$i].LoginName -f Cyan
				$spWeb.RoleAssignments.Remove($i)
				break;
			}
		}
	}
return $null	
}



function Remove-Tree($Path,$Include='*') { 
    Get-Tree $Path $Include | Remove-Item -force -recurse
} 
function Replace-Brackets($strInp){
	$braks = " ","(",")","[","]","{","}","/","\"
	$outStr = $strInp
	foreach($brkItm in $braks){
		$outStr = $outStr.Replace($brkItm,"")
	}
	return $outStr
}
function saveListTemplate($spWeb,$itm,$SaveData){
	$TemplateName=$itm.templateFileName
	$TemplateFileName=$itm.templateFileName
	$TemplateDescription=$itm.templateFileName
	#$SaveData = $true
 
	$List = $spWeb.Lists[$itm.Title]
	if ([string]::IsNullOrEmpty($List)){
		$List = $spWeb.Lists | Where-Object {$_.RootFolder.Url -eq $itm.RootFolder}
	}
	if ([string]::IsNullOrEmpty($List)){
		Write-Host "149: Error : List $($itm.Title) not Found" -f Red
	}
	else{
		try{
			# https://gss2.ekmd.huji.ac.il/home/_catalogs/lt/Forms/AllItems.aspx
			$List.SaveAsTemplate($TemplateFileName, $TemplateName, $TemplateDescription, $SaveData)
			#start-sleep 5
			$savedDataMsg = " without Data"
			if ($SaveData){
				$savedDataMsg = " with Data"	
			}
			#Write-Host "List $($itm.Title) Saved as Template $TemplateFileName $savedDataMsg" -f Green

		}
		catch
		{
			Write-host $_.Exception.Message -f Red
			Write-Host "Template $TemplateFileName already exists"	-f Yellow	
		}
	}
}
function Update-MihzurLog($mihzurObj){
	$dt =  get-Date
	#$nullDate = get-date -Year 1900 -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0
	$spWeb =  get-SPWeb "https://portals2.ekmd.huji.ac.il/home/huca/spSupport" -ErrorAction SilentlyContinue
	if ($spWeb){
		$list = $spWeb.Lists["availableArchives"]

		foreach($mihzurItem in $mihzurObj){
			$archURL      = $mihzurItem.ArchiveURL
			$currentSite  = $mihzurItem.XYZSite
			$currentList  = $mihzurItem.XYZList
			$currentID    = $mihzurItem.ID
			$srcSiteName  = $mihzurItem.srcSiteName 
			$srcSiteDescr = $mihzurItem.srcSiteDescr
			
			$avialListUrl = $currentSite + "Lists/"+$currentList+"/EditForm.aspx?ID="+$currentID
			
			$QueryStr = "<Where><Contains><FieldRef Name='ArchiveURL' /><Value Type='URL'>$archURL</Value></Contains></Where>"
			$query=New-Object Microsoft.SharePoint.SPQuery
			$query.Query = $QueryStr
			$SPListItemCollection = $list.GetItems($query)
			#write-Host 1045 $SPListItemCollection.Count
			
			$itemID =  0
			foreach($listItem in $SPListItemCollection){
				
				$itemID = $listItem.ID
				break
			}
			if($itemID -gt 0){
				$listItm = $list.GetItembyID($itemID)	
			}
			else
			{
				$listItm = $list.AddItem()
			}
			
			$listItm["SiteURL"]     = $archURL 
			$listItm["ArchiveURL"]  = $archURL + "/_layouts/15/mngsubwebs.aspx"
			$listItm["availableListURL"]  = $avialListUrl
			$listItm["ArchiveDate"] = $dt
			$listItm["SiteCleaned"] = $false
			$listItm["CleanDate"]   = $null # Date
			$listItm["Title"]       = $srcSiteName # Title
			$listItm["siteDescription"]   = $srcSiteDescr # English name
			$listItm.Update()
			
		}
	}	
	
}
function Update-MihzurIsDone($mihzurObj){
	$dt =  get-Date
	foreach($mihzurItem in $mihzurObj){
		$currentSite = $mihzurItem.XYZSite
		$currentList = $mihzurItem.XYZList
		$currentID =  $mihzurItem.ID
		$archURL = $mihzurItem.ArchiveURL
		$relArchSiteURL = $mihzurItem.RealArchiveSiteURL
		
		$spWeb =  get-SPWeb $currentSite -ErrorAction SilentlyContinue
		if ($spWeb){
			write-host "$archURL : Archive Done" -f Green
			$list = $spWeb.Lists[$currentList]
			$ListItem = $List.GetItembyID($currentID)	
			$ListItem["Archive_Waiting_for_Archivation"] = $false
			$ListItem["Archive_Archivation_Date"] = $dt
			$ListItem["Archive_Site_Checked"] = $false
			$ListItem["Archive_Waiting_for_Cleanup"] = $false
			$ListItem["Archive_Cleanup_Date"] = $null
			$ListItem["Archive_URL"] = $relArchSiteURL
			$ListItem.Update()
		}	
		
	}
	return $null
	
}
function Update-PageContent($siteURL, $PageName, $pageField,$Content){
	$spWeb = Get-SPWeb $siteURL
	write-Host $siteURL
	
    $pageFullName = "Pages/" + $PageName + ".aspx"
	write-Host $pageFullName
	$page = $spweb.GetFile($pageFullName)
	$PageContent = ""
    if ($page.exists){
		$page.CheckOut()
		$pageFields = $page.ListItemAllFields
		$pageFields[$pageField] = $Content
		$pageFields.Update()
		$page.CheckIn('')
		
		$page.Publish('')
	}
	return $null
	
}
# Set-PSDebug -Trace 1
Add-PsSnapin Microsoft.SharePoint.PowerShell
$dtNow = Get-Date

$dtNowStrLog 	= get-FrendlyDateLog 	$dtNow
$dtNowStr 		= get-FrendlyDate 		$dtNow

$logFile = "AS-Mihzur-"+$dtNowStrLog+".log"
#$logFile = "AS-Mihzur-01.log"

$cultureHE = [System.Globalization.CultureInfo]::CreateSpecificCulture("he-IL")
$cultureEN = [System.Globalization.CultureInfo]::CreateSpecificCulture("en-US") 

$heDocLibName = "העלאת מסמכים"
$enDocLibName = "Documents Upload"

$script=$MyInvocation.InvocationName
$scriptDirectory = get-ScrptFullPath $script
Write-Host $scriptDirectory

Get-ChildItem $scriptDirectory -Include *.json -Recurse |  ForEach  { $_.Delete()}
Get-ChildItem $scriptDirectory -Include *.xml -Recurse |  ForEach  { $_.Delete()}
Get-ChildItem $scriptDirectory -Include *.txt -Recurse |  ForEach  { $_.Delete()}
#Get-ChildItem $scriptDirectory -Include *.log -Recurse |  ForEach  { $_.Delete()}
$mhzurDir = '.\_Mihzur\'
If (Test-Path -path $mhzurDir)
{   
	Remove-Tree $mhzurDir
}
Start-Transcript $logFile

write-host
write-host "Script For Mihzur version 2022-11-13.1"           
write-host "Asher Sandler	: mailTo:AsherSa@ekmd.huji.ac.il"           

$oMihzur = get-siteToArchive
$webservice = [Microsoft.SharePoint.Administration.SPWebService]::ContentService
Write-Host "Template Max Size: " $webservice.MaxTemplateDocumentSize
$webservice.MaxTemplateDocumentSize = 500Mb 
$webservice.Update()

$mihzurNotEmpty = $false

foreach($oMihzurItem in $oMihzur){
	$mihzurNotEmpty = $true	
}
if ($mihzurNotEmpty){	
	$JsonFile =   "mihzur.json"
	$oMihzur | ConvertTo-Json -Depth 100 | out-file $JsonFile
	write-host "Begin: $JsonFile was written" -f Yellow

	$ts = gc $JsonFile -raw 
	if (![string]::IsNullOrEmpty($ts)){
		 $msgSubj = "Mihzur Started on Sites: " + $JsonFile
		 Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersa@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction SilentlyContinue
		 Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "danielkl@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction SilentlyContinue
		 start-sleep 2
	}
}
foreach($oMihzurItem in $oMihzur){
    $srcSiteUrl = $oMihzurItem.ArchiveURL
	write-host "Site To Archive" $srcSiteUrl
	
	$group = get-SiteGroup $srcSiteUrl
	$templateName = $group + "-"+$dtNowStrLog 
	write-Host $group
	#read-host
	$templSavedPath = "SavedTemplates"

	$homeweb = Get-SPWeb  $srcSiteUrl
	$languageID = $homeweb.Language 

	write-host "Site to Archive	:  <$srcSiteUrl>"          
	write-host "Language ID		:  <$languageID>"           
	write-host "Site Group 		:  <$group>"           
	write-host "Start time		:  <$dtNowStr>"          
	write-host "User			:  <$whoami>"        
	write-host "Running ON		:  <$ENV:Computername>" 
	write-host "Script file		:  <$script>"        
	write-host "Log file		:  <$logFile>"        
	 
	 $newArchiveObj= Get-NextArchiveSubSiteObj $homeweb
	 write-host "Stage 01-1: Creating new Archive Subsite $($newArchiveObj.Title)" 
	 $archSubSite = Create-NewArchiveSubSite $homeweb $newArchiveObj
	 $featActivated = Activate_PublishingFeature  $archSubSite.URL
	 if ($featActivated){
		write-host "Stage 01-2: Publishing Feature was Activated" -f Green
	 }
	 else{
		write-host "Error 1501: Publishing Feature was NOT Activated" -f Yellow
	 }
	 write-host "Stage 01: Archive site was Created $($archSubSite.URL)" -f Yellow
	 
	 $siteObj = "" | Select SiteURL, SiteName,Description, SiteSaveDirectory,WorkingDir,siteListArr
	 $siteObj.SiteURL  = $srcSiteUrl
	 $siteObj.SiteName = $homeweb.Title
	 $siteObj.Description = $homeweb.Description
	 $siteObj.SiteSaveDirectory =  $group
	 $siteObj.workingDir = Create-WorkingDir $siteObj.SiteSaveDirectory $mhzurDir
	 write-Host $siteObj.workingDir
	 #read-host
	 # List is :GenericList =100 OR DocumentLibrary =101

	$localPathSrc = $([System.Uri]$srcSiteUrl).LocalPath 
	$lastSlash = $localPathSrc.Substring($localPathSrc.Length-1,1) -eq "/"
	#write-host "$localPathSrc lastSlash1 : $lastSlash"
	if ($lastSlash){
	}
	else
	{	
		$localPathSrc = $localPathSrc + "/"
	}


	$localPathArc = $([System.Uri]$archSubSite.URL).LocalPath
	$lastSlash = $localPathArc.Substring($localPathArc.Length-1,1) -eq "/"
	#write-host "$localPathArc lastSlash2 : $lastSlash"
	if ($lastSlash){
	}
	else
	{
		$localPathArc = $localPathArc + "/"
	}

	$localPathSrc = $localPathSrc.ToLower()
	$localPathArc = $localPathArc.ToLower()
	 
     # BODY Region
    

	 write-host 
	 write-host "Stage 02: Collecting Information About Lists and Document Library on Source Web" -f Yellow
	 write-host "=====================================================================" -f Yellow
	 $tmpListArr =  $homeweb.Lists | Select Title,RootFolder,RootFolderNew, BaseTemplate,ID,Fields,ItemCount | Where {$_.BaseTemplate -lt 102} 
	 $realListArr = @()
	 $listCount = $tmpListArr.Count
	 $listCollectingProgress = 0
	 foreach($tlArr in $tmpListArr){
		 
		 $tmplFName = $templateName + "-" + $tlArr.Title
		 $tmplFName = Replace-Brackets $tmplFName
		 $tmplFName = HebrewToLatin $tmplFName
		 $newListArrItem ="" | Select Title, RootFolder,RootFolderNew, BaseTemplate,templateFileName,UIDOld,UIDNew,IsLookupField, ItemCountSrc,ItemCountDst, Done
		 $newListArrItem.Title=$tlArr.Title
		 $newListArrItem.RootFolder=$tlArr.RootFolder.ToString()
		 $newListArrItem.BaseTemplate=$tlArr.BaseTemplate
		 $newListArrItem.UIDOld =$tlArr.ID
		 $docLib = $(($newListArrItem.BaseTemplate -eq 101) -and 
					  ($newListArrItem.Title.Contains($heDocLibName) -or $newListArrItem.Title.Contains($enDocLibName)))
		 $newListArrItem.IsLookupField = $null
		 if (!$docLib){
			$newListArrItem.IsLookupField = IsFieldLookup $tlArr.Fields	 
		 }	 
		 
		 $newListArrItem.templateFileName=$tmplFName
		 $newListArrItem.ItemCountSrc=$tlArr.ItemCount
		 $newListArrItem.ItemCountDst=0
		 $newListArrItem.Done=$false
		 
		 $realListArr += $newListArrItem 
		 $listCollectingProgress++ 
		 $Completed = [math]::Round(($listCollectingProgress/$listCount*100),0)
		 if ($($Completed % 25) -eq 0){
			 write-Host $Completed "%"
		 }
		 #Write-Progress -Activity "Collecting Lists" -Status "Progress:" -PercentComplete $Completed
		 #write-host "Progress : $listCollectingProgress of $listCount % $Completed" -f Yellow
	 }
	  write-host "Stage 02: Collecting Completed" -f Yellow

	 $siteObj.siteListArr =  $realListArr
	 deleteListTemplate	$homeweb.Site.Url $group #$siteObj.workingDir		

	 write-host
	 write-host "Stage 03: Copy Documents Library Created on Archive By Default" -f Yellow
	 write-host "==============================================================================" -f Yellow
	 
	foreach($listO in $siteObj.siteListArr){
		if (!$listO.Done) {
			$docLib = $($listO.BaseTemplate -eq 101)
			if ($docLib){
				$listAlreadyExists = Is-ListExists $archSubSite.Url $listO
				
				if ($listAlreadyExists){
					write-host -------------------
					write-host "Already exists"
					write-host $listO.Title

					$listO.Done = $true
					$lst = $archSubSite.Lists | Where-Object {$_.Title -eq $listO.Title}
					$listO.UIDNew =  get-ListID $archSubSite.Url $listO.Title
					$listO.RootFolderNew =  $lst.RootFolder.URL

					# Copy Old List To New List
					Copy-DocLibToDocLib $srcSiteUrl $archSubSite.Url $listO $siteObj.siteListArr
					
				}
			}
		}
	}	
    write-host "Stage 03: Completed" -f Yellow

	write-host
	write-host "Stage 04: Creating Applicants on destination Web from templates on Site" -f Yellow
	write-host "==============================================================================" -f Yellow
	write-host $oMihzurItem.applicantList -f Yellow
	 
	if (![string]::IsNullOrEmpty($oMihzurItem.applicantList)){
		$aApplicants = $oMihzurItem.applicantList.Replace(";",",").Split(",")
		
		foreach($applItem in $aApplicants){
			foreach($listO in $siteObj.siteListArr){
				if (!$listO.Done) {
					if ($listO.Title.ToLower() -eq $applItem.ToLower()){
						
						write-host -----save List Template------
						write-host $listO.Title
						#$saveLstData = $true
						$saveLstData = $false
						saveListTemplate $homeweb $listO $saveLstData
						
						$listCreated = Create-ListOnArchiveFromTemplate $archSubSite $listO
						$listO.Done = $listCreated.Done 
						$listO.UIDNew =  $listCreated.UID 
						$listO.RootFolderNew =  $listCreated.URL
						
						if ($listO.IsLookupField.isLookup){
							# Delete LookupFields from List
							Delete_LookupFields $archSubSite.Url $listO
							# Change LookupFields To TextFields 
							Create_LookupFieldsAsText $archSubSite.Url $listO
						}
						# Copy Old List To New List
						Copy-ListToList $srcSiteUrl $archSubSite.Url $listO $siteObj.siteListArr
					}
				}	
			}	
		}
	 }
	  write-host "Stage 04: Completed" -f Yellow

	 if (![string]::IsNullOrEmpty($oMihzurItem.FinalLists)){

	 $aFinalLst =   $oMihzurItem.FinalLists.Replace(";",",").Split(",") 
	 #write-Host  $aFinalLst
	 Write-Host
	 write-host "Stage 05:  Processing Lists Founded in Field 'Archive_Lists_Final'" -f Yellow
	 write-host "Creating Lists Entered to Field 'Archive_Lists_Final' with/without Lookup Fields on destination Web from template" -f Yellow
	 write-host "==========================================================================" -f Yellow
		foreach($listFinal in $aFinalLst){
			write-Host $listFinal
			foreach($listO in $siteObj.siteListArr){
				if (!$listO.Done) {
					if ($listO.Title.ToLower() -eq $listFinal.ToLower().Trim()){

						write-host -------------------
						write-host $listO.Title
						$saveLstData = $false
						saveListTemplate $homeweb $listO $saveLstData
						
						$listCreated = Create-ListOnArchiveFromTemplate $archSubSite $listO
						$listO.Done = $listCreated.Done 
						$listO.UIDNew =  $listCreated.UID 
						$listO.RootFolderNew =  $listCreated.URL
						
						if ($listO.IsLookupField.isLookup){
							# Delete LookupFields from List
							Delete_LookupFields $archSubSite.Url $listO
							# Change LookupFields To TextFields 
							Create_LookupFieldsAsText $archSubSite.Url $listO
						}
						# Copy Old List To New List
						Copy-DocLibToDocLib $srcSiteUrl $archSubSite.Url $listO $siteObj.siteListArr

						##########################			
					}
				}
			}
		}
	 }
	 
	 deleteListTemplate	$homeweb.Site.Url $group #$siteObj.workingDir		

	  write-host "Stage 05: Completed" -f Yellow

	 write-host
	 write-host "Stage 06 :Creating Ordinary Lists on Site" -f Yellow
	 write-host "==============================================================================" -f Yellow
		
	foreach($listO in $siteObj.siteListArr){
		if (!$listO.Done) {
			$ordinalList = $($listO.BaseTemplate -eq 100)
			if ($ordinalList){
			
				write-host -------------------
				write-host $listO.Title
				
				$saveLstData = $false
				saveListTemplate $homeweb $listO $saveLstData
				
				$listCreated = Create-ListOnArchiveFromTemplate $archSubSite $listO
				$listO.Done = $listCreated.Done 
				$listO.UIDNew =  $listCreated.UID 
				$listO.RootFolderNew =  $listCreated.URL
				
				if ($listO.IsLookupField.isLookup){
					# Delete LookupFields from List
					Delete_LookupFields $archSubSite.Url $listO
					# Change LookupFields To TextFields 
					Create_LookupFieldsAsText $archSubSite.Url $listO
				}
				# Copy Old List To New List
				Copy-ListToList $srcSiteUrl $archSubSite.Url $listO $siteObj.siteListArr
				
				
			}	
			
		}	
	}
    write-host "Stage 06: Completed" -f Yellow
	
	deleteListTemplate	$homeweb.Site.Url $group #$siteObj.workingDir		

	  write-host
	  write-host "Stage 07 :Creating Documents Library for Users with metadata and Copying files From Source To Destination" -f Yellow
	  write-host "===============================================================================================" -f Yellow
	  
	  foreach($listO in $siteObj.siteListArr){
		if (!$listO.Done) {
			$docLib = $(($listO.BaseTemplate -eq 101) -and 
					  ($listO.Title.Contains($heDocLibName) -or $listO.Title.Contains($enDocLibName)))
			if ($docLib){
				write-host -------------------
				write-host $listO.Title
				$externalListName = $listO.Title
				$innerListName = $listO.RootFolder
				$listO.UIDNew = $($archSubSite.Lists.Add($innerListName, $externalListName, "DocumentLibrary")).Guid
				$docLib = $archSubSite.Lists | Where-Object{$_.ID -eq $listO.UIDNew}
				$listO.RootFolderNew = $docLib.RootFolder.Url
				
				$docLib.Title = $externalListName
				$docLib.Update()
				$docLib.TitleResource.SetValueForUICulture($cultureHE, $externalListName)
				$docLib.TitleResource.SetValueForUICulture($cultureEN, $externalListName)
				$docLib.TitleResource.Update()	
					
				$docTypeSchema = Get-DocTypeSchema	$archSubSite $languageID		
				$newField = $docLib.Fields.AddFieldAsXml($docTypeSchema, $True,[Microsoft.SharePoint.SPAddFieldOptions]::AddFieldToDefaultView)
				$sentResponseSchema = '<Field Type="Boolean" DisplayName="sentResponse" EnforceUniqueValues="FALSE" Indexed="FALSE"  StaticName="sentResponse" Name="sentResponse" ><Default>0</Default></Field>'
				$newField = $docLib.Fields.AddFieldAsXml($sentResponseSchema, $True,[Microsoft.SharePoint.SPAddFieldOptions]::AddFieldToDefaultView)

				# $srcSite, $dstSite , $langID, $docLibName
				#CopyDocLib $srcSiteUrl $archSubSite.Url $languageID  $innerListName 
				$arcRootFolder = $docLib.RootFolder.Url
				CopyDocLib $srcSiteUrl $archSubSite.Url $languageID  $externalListName $arcRootFolder
				$listO.Done = $true

			}
		}  
	  }
     write-host "Stage 07: Completed" -f Yellow
	  
	 deleteListTemplate	$homeweb.Site.Url $group #$siteObj.workingDir		
	  
	  write-host
	  write-host "Stage 08 :Creating Documents Library Final and Submitted" -f Yellow
	  write-host "==============================================" -f Yellow
	  foreach($listO in $siteObj.siteListArr){
		if (!$listO.Done) {
			$finalOrSubmitted = (($listO.Title -eq "Final") -or ($listO.Title -eq "Submitted"))
			if (!$finalOrSubmitted){
				continue
			}
			write-host -------------------
			write-host $listO.Title
			$externalListName = $listO.Title
			$innerListName = $listO.RootFolder
			$listO.UIDNew = $($archSubSite.Lists.Add($innerListName, $externalListName, "DocumentLibrary")).Guid

			$docLib = $archSubSite.Lists | Where-Object{$_.ID -eq $listO.UIDNew}
			$listO.RootFolderNew = $docLib.RootFolder.Url

			
			if ($listO.Title -eq "Final"){
				
				$listSchemaOrigin  = get-ListSchema $srcSiteUrl $listO.Title
				$listSchemaArchive = get-ListSchema $archSubSite.Url  $listO.Title

				$schemaDiff = get-SchemaDifference $listSchemaOrigin $listSchemaArchive

				foreach($fieldsSchema in $schemaDiff){
					#write-Host $fieldschema -f Yellow
					add-SchemaField  $archSubSite.Url $listO.Title $fieldsSchema
				}
				
				Copy-Final $srcSiteUrl $archSubSite.Url 
				Copy-DefaultQuery $srcSiteUrl $archSubSite.Url  $listO.Title

			}

			$listO.Done = $true
		}	
	  }
    write-host "Stage 08: Completed" -f Yellow
	  
	deleteListTemplate	$homeweb.Site.Url $group #$siteObj.workingDir
	
	 write-host
	 write-host "Stage 09 :Creating Document Libraries WITH Lookup Fields on destination Web from template" -f Yellow
	 write-host "==========================================================================" -f Yellow
	 foreach($listO in $siteObj.siteListArr){
		if (!$listO.Done) {
			
			$finalOrSubmitted = (($listO.Title -eq "Final") -or ($listO.Title -eq "Submitted"))
			if ($finalOrSubmitted){
				continue
			}
			# skip students Doclibs
			if (($listO.Title.Contains($heDocLibName) -or $listO.Title.Contains($enDocLibName))){
				continue
			}		
			$docLib = $($listO.BaseTemplate -eq 101) 
			# create Lists with Lookup Fields
			if ($docLib){
				write-host -------------------
				write-host $listO.Title
				$saveLstData = $false
				saveListTemplate $homeweb $listO $saveLstData

				$listCreated = Create-ListOnArchiveFromTemplate $archSubSite $listO
				$listO.Done = $listCreated.Done 
				$listO.UIDNew =  $listCreated.UID 
				$listO.RootFolderNew =  $listCreated.URL
				if ($listO.IsLookupField.isLookup){
					# Delete LookupFields from List
					Delete_LookupFields $archSubSite.Url $listO
					# Change LookupFields To TextFields 
					Create_LookupFieldsAsText $archSubSite.Url $listO
				}
				# Copy Old List To New List
				Copy-DocLibToDocLib $srcSiteUrl $archSubSite.Url $listO $siteObj.siteListArr

			}
		 }
	  }
     write-host "Stage 09: Completed" -f Yellow
	  
	 write-host
	 write-host "Stage 10 :Processing with Status Not Copied" -f Yellow
	 write-host "==========================================================================" -f Yellow
	 write-host
	 foreach($listO in $siteObj.siteListArr){
		 #if ($listO.Title -eq"applicants"){
		if  (!$listO.Done) {
			write-host $listO.Title		

	  }
	}
	 
    write-host "Stage 10: Completed" -f Yellow
	
	 deleteListTemplate	$homeweb.Site.Url $group #$siteObj.workingDir	
	  
	# end Body Region
	
	 $listSiteCollectFile = Join-Path $siteObj.workingDir "AllList.json"
	 $siteObj.siteListArr | ConvertTo-Json -Depth 100 | out-file $listSiteCollectFile
	write-host "$listSiteCollectFile Created"
	
	 write-host
	 write-host "Stage 11 :Creating Pages " -f Yellow
	 write-host "==========================================================================" -f Yellow

	$Content = get-PageContent $srcSiteUrl "default" "PublishingPageContent"
	$Title = get-PageContent $srcSiteUrl "default" "Title"
	$ContentHe = get-PageContent $srcSiteUrl "defaultHe" "PublishingPageContent"
	
	$hePageExists = $true	
	if (![string]::IsNullOrEmpty($ContentHe)){

		$TitleHe = get-PageContent $srcSiteUrl "defaultHe" "Title"
		create-WPPage $archSubSite.URL "DefaultHe" $false
		Update-PageContent $archSubSite.URL "defaultHe" "PublishingPageContent" $ContentHe
		Update-PageContent $archSubSite.URL "defaultHe" "Title" $TitleHe
	}
	else{
		$hePageExists = $false
	}
	create-WPPage $archSubSite.URL "Default" $true
	Update-PageContent $archSubSite.URL "default" "PublishingPageContent" $Content
	Update-PageContent $archSubSite.URL "default" "Title" $Title

	Inher-MasterPage $srcSiteUrl $archSubSite.URL
	#Read more: https://www.sharepointdiary.com/2014/02/delete-list-template-in-sharepoint-with-powershell.html#ixzz7XJPyfq5c 
	[system.gc]::Collect()
	 write-host
	 write-host "Stage 12 :Creating Navigation" -f Yellow
	 write-host "==========================================================================" -f Yellow

	 $qlMenuX = Collect-qlMenu $homeweb
	 
	 $qlnavJsonFile =   $group+"-qlnavMenuX.json"
	 $qlMenuX | ConvertTo-Json -Depth 100 | out-file $qlnavJsonFile
	 write-host "$qlnavJsonFile was written" -f Yellow
	 
     $ts = gc $qlnavJsonFile -raw 
	 $msgSubj = $qlnavJsonFile
	 Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersa@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction SilentlyContinue
	 start-sleep 2 

	 $qlMenuY =  Replace-QLMenu $qlMenuX $localPathSrc $localPathArc $siteObj.siteListArr  

     
	 $qlnavJsonFile =  $group+"-qlnavMenuY.json"
	 $qlMenuY | ConvertTo-Json -Depth 100 | out-file $qlnavJsonFile
	 write-host "$qlnavJsonFile was written" -f Yellow
	 
     $ts = gc $qlnavJsonFile -raw 
	 $msgSubj = $qlnavJsonFile
	 Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersa@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction SilentlyContinue
	 start-sleep 2 
	 
	 $qlMenuArc = Collect-qlMenuAll $archSubSite

	Delete-QuickLaunchMenu $archSubSite $qlMenuArc 
	Add-QuickLaunchMenu $archSubSite $qlMenuY $siteObj.siteListArr

	 write-host "Stage 13 :Change Archive Site Permissions." -f Yellow
	Remove-SitePermissions $archSubSite.URL

	write-host "$listSiteCollectFile was written" -f Yellow
	write-host "Archive site was Created $($archSubSite.URL)" -f Yellow
	$oMihzurItem.RealArchiveSiteURL = $($archSubSite.URL)
	$oMihzurItem.srcSiteName = $siteObj.SiteName
	$oMihzurItem.srcSiteDescr = $siteObj.Description


    $ts = gc $listSiteCollectFile -raw 
	$msgSubj = $listSiteCollectFile
	Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersa@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction SilentlyContinue
	start-sleep 2

	write-host "Stage 14: Check not Done Lists" -f Yellow
    write-host "==============================================" -f Yellow
	$listsNotDone = get-ListsNotDone $($archSubSite.URL) $siteObj.siteListArr

	$outFileName = "Lists-Not-Done.txt"
	$listsNotDone | ConvertTo-Json -Depth 100 | Out-File $outFileName
	if (![string]::IsNullOrEmpty($listsNotDone)){
		$msgSubj = "Lists Not Done"
		$ts = gc $outFileName -raw 
		Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersa@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction SilentlyContinue
	}
	write-host "Stage 15: Check Mihzur Integrity" -f Yellow
    write-host "==============================================" -f Yellow
	$intStr  = check-Integrity $($archSubSite.URL) $siteObj.siteListArr
    
	$intStr | Out-File "Integrity Report.txt"
	$msgSubj = "Integrity Report"
	Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersa@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $intStr -BodyAsHtml -smtpserver ekekcas01  -erroraction SilentlyContinue
	Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "evgeniat@ekmd.huji.ac.il"  -From $doNotReply  -Subject $msgSubj -body $intStr -BodyAsHtml -smtpserver ekekcas01  -erroraction SilentlyContinue
	Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "danielkl@ekmd.huji.ac.il"  -From $doNotReply  -Subject $msgSubj -body $intStr -BodyAsHtml -smtpserver ekekcas01  -erroraction SilentlyContinue
	start-sleep 2 
	 
	
		}
Update-MihzurIsDone $oMihzur 
Update-MihzurLog $oMihzur
Stop-Transcript
if ($mihzurNotEmpty){	
	 $JsonFile =   "mihzur.json"
	 $oMihzur | ConvertTo-Json -Depth 100 | out-file $JsonFile
	 write-host "End: $JsonFile was written" -f Yellow
	 
     $ts = gc $JsonFile -raw 
	 if (![string]::IsNullOrEmpty($ts)){
		 $msgSubj = $JsonFile
		 Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersa@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction SilentlyContinue
		 start-sleep 2
	 }	 
	write-host "Stage 16: Do Mihzur Log" -f Yellow
	write-host "==============================================" -f Yellow

	$ts = gc $logFile -raw 
	$msgSubj = "Do Mihzur Log Text"
	Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersa@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction SilentlyContinue
	start-sleep 2 

	$gzipexec = $scriptDirectory + "\Utils\gzip"	

	write-host "$gzipexec $logFile -f"
	& $gzipexec $logFile -f #| Out-Null
	$gzLogFile = $logFile.Replace("log","log.gz")

	$gzFile = get-Item $gzLogFile
	$outGzPath = "\\ekekfls00\data$\scriptFolders\LOGS\Mihzur"
	copy-item $gzFile $outGzPath

	$msgSubj = "Do Mihzur Log gz"
	Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersa@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $outGzPath  -Attachments  $gzFile -smtpserver ekekcas01  -erroraction SilentlyContinue
	Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "evgeniat@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $outGzPath  -Attachments  $gzFile -smtpserver ekekcas01  -erroraction SilentlyContinue
	Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "danielkl@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $outGzPath  -Attachments  $gzFile -smtpserver ekekcas01  -erroraction SilentlyContinue
	start-sleep 2 
	remove-Item $gzFile
}
else
{
	$lgFile = Get-Item $logFile
	remove-Item $lgFile
}
write-host "Mihzur Completed. Bye." -f Yellow
write-host "==============================================" -f Yellow

	