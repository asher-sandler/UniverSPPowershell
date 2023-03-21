
							
function Get-DestFile($ctx, $libName, $dstFld, $sFileName){
	$oFile = $null

    #Write-Host 4 $libName, $dstFld, $sFileName
	$List = $Ctx.Web.GetList($libName)
	
    $ctx.Load($List)
	$Ctx.ExecuteQuery()

    $SubFolders = $List.RootFolder.Folders
    $Ctx.Load($SubFolders)
    $Ctx.ExecuteQuery()

	Foreach($SubFolder in $SubFolders)	
	{
		if ($SubFolder.Name -eq $dstFld)
		{
			#Write-Host 18 "Found"
			$FilesCollSrc = $SubFolder.Files
			$Ctx.Load($FilesCollSrc)
			$Ctx.ExecuteQuery()
			$oFileFound = $false
			ForEach($sFile in $FilesCollSrc){
				#Write-Host 24 $sFile.Name 
				if ($sFile.Name -eq $sFileName)
				{
					$oFile = $sFile
					$oFileFound = $true
					break			
				}
			}
			if ($oFileFound){
				break
			}
			
		}
	}	


	$dFileEmpty = [string]::IsNullOrEmpty($oFile)
	#Write-Host 23 $dFileEmpty
	return $oFile
	
}
function Create-Folders($SiteURL, $listName ,$foldersNew){

	#$foldersNew = "התכתבויות","וועדות הוראה","יתרת חובות"
	$siteName = get-UrlNoF5 $SiteURL
	#$TargetFolderURL =  ([system.uri]$siteName).LocalPath
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	
	$Ctx.Credentials = $Credentials
	$TargetLibrary = $Ctx.Web.lists.GetByTitle($listName)
    $Ctx.Load($TargetLibrary)
    $Ctx.Load($TargetLibrary.RootFolder)
    $Ctx.ExecuteQuery()	
	
    $SubFolders = $TargetLibrary.RootFolder.Folders
    $Ctx.Load($SubFolders)
    $Ctx.ExecuteQuery()
	
	$targetFolderUrlPrefix = ""
	
	Foreach($SubFolder in $SubFolders)	
	{
		if ($SubFolder.Name -eq "Forms")
		{
			$targetFolderUrlPrefix =  $SubFolder.ServerRelativeUrl -Replace "Forms" , ""
			break
		}
		
	}	
    #Write-Host 29 $targetFolderUrlPrefix
	foreach($fldN in $foldersNew){
		$TargetFolderURL = $targetFolderUrlPrefix + $fldN
		
		Try{
			$Folder=$Ctx.web.GetFolderByServerRelativeUrl($TargetFolderURL)
			$Ctx.load($Folder)
			$Ctx.ExecuteQuery()
			#Write-host "Folder Already Exists: "$TargetFolderURL -f Yellow
		}
		catch{
			#Create Folder
			if(!$Folder.Exists){
				
				$Folder=$Ctx.Web.Folders.Add($TargetFolderURL)
				$Ctx.Load($Folder)
				$Ctx.ExecuteQuery()
				#Write-host "Folder Created:"$TargetFolderURL -f Green
			}
		}
	}
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


	
	$qryView = '<OrderBy><FieldRef Name="DocType" /></OrderBy>'
	
	
	$View.ViewQuery = $qryView
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


	$vFieldsList =     "Edit",
                       "DocIcon",
                       "LinkFilename",
                       "Created",
                       "DocType"

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
Function Add-FieldsToDocLibX($siteUrl, $listName){
	$schemaFields = @()
	$schemaFields += '<Field DisplayName="תוכן קובץ" Type="Text" Name="DocType" />'
	ForEach($fSchema in $schemaFields){
		add-SchemaFields $siteUrl $listName $fSchema
	}
	return $null
}

function Is-DocLibExists($SiteURL,$id ){
	$siteName = get-UrlNoF5 $SiteURL
	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	
	$Ctx.Credentials = $Credentials
	$Lists = $Ctx.Web.Lists
	$Ctx.Load($Lists)
    $Ctx.ExecuteQuery()
	
	$libExists ="" | Select Title,Exists 
	$libExists.Exists = $false
	ForEach($list in $Lists)
	{	
	    $rtFolder = $list.RootFolder
		$Ctx.Load($rtFolder)
		$Ctx.ExecuteQuery()
		
		if ($rtFolder.Name -eq $id){
			$libExists.Exists  = $true
			$libExists.Title = $list.Title
			#write-host $list.Title -f Cyan
			break
		}	
			
	}
	return $libExists
	
}
function Get-DestinationItemID($SiteURL,$ListName,$FieldName, $idValue){
	$siteName = get-UrlNoF5 $SiteURL
	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	
	$Ctx.Credentials = $Credentials

	#Get the List
		
	$List = $Ctx.Web.lists.GetByTitle($ListName)
	

	#Define the CAML Query
	$Query = New-Object Microsoft.SharePoint.Client.CamlQuery
	
	$qry = "<View><Query><Where><Eq><FieldRef Name='$FieldName' /><Value Type='Text'>"+$idValue+"</Value></Eq></Where></Query></View>"
	#$qry = "<View><Query></Query></View>"
	$Query.ViewXml = $qry

	#Get All List Items matching the query
	$ListItems = $List.GetItems($Query)
	$Ctx.Load($ListItems)
	$Ctx.ExecuteQuery()
	$outItemID = 0
	foreach($listItem in $listItems){
		$outItemID = $listItem.ID
		break
	}
	
	return $outItemID
			
}
function Copy-LettersFiles(	$siteSRC,$ResponseLetterListName, $studID, 
							$siteDest, $dstLib, 
							$dstFld,$docTypeItemName )
{

	$siteName = get-UrlNoF5 $siteSRC
	#$TargetFolderURL =  ([system.uri]$siteName).LocalPath
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	
	$Ctx.Credentials = $Credentials
	$LettersLib = $Ctx.Web.lists.GetByTitle($ResponseLetterListName)
    $Ctx.ExecuteQuery()

	$FolderSrc = $LettersLib.RootFolder
    $FilesCollSrc = $FolderSrc.Files
    $Ctx.Load($FolderSrc)
    $Ctx.Load($FilesCollSrc)
    $Ctx.ExecuteQuery()

    ###################################
	$siteNameDst = get-UrlNoF5 $siteDest
	$CtxDst = New-Object Microsoft.SharePoint.Client.ClientContext($siteNameDst)
	$CtxDst.Credentials = $Credentials
 
	$listDst = 	$CtxDst.Web.Lists.GetByTitle($dstLib)
    $CtxDst.Load($listDst)
    $CtxDst.ExecuteQuery()
	$listDstRootFolder = $listDst.RootFolder
    $CtxDst.Load($listDstRootFolder)
    $CtxDst.ExecuteQuery()

	$dstListUrl = $([system.uri]$siteNameDst).LocalPath + $listDstRootFolder.Name
	$StudentIDFound = $false
	ForEach($srcFile in $FilesCollSrc){
		$srcBaseFileName = $srcFile.Name.Split(".")[0]
	    if ($studID -eq $srcBaseFileName){
			#Write-Host $srcFile.Name
			#Write-Host $srcFile.ServerRelativeURL
			$dstLibURL  = $dstListUrl+"/"+$dstFld

			$dstFileURL = $dstLibURL+"/"+$srcFile.Name
			# Write-Host 268 $dstFileURL
			$FileInfo = [Microsoft.SharePoint.Client.File]::OpenBinaryDirect($Ctx, $srcFile.ServerRelativeURL)
			[Microsoft.SharePoint.Client.File]::SaveBinaryDirect($CtxDst, $dstFileURL, $FileInfo.Stream,$True)
			$sItems   = $srcFile.ListItemAllFields
			$Ctx.Load($sItems)
			$Ctx.ExecuteQuery()
			$dstFile = Get-DestFile $CtxDst $dstListUrl $dstFld $dstFileURL.split("/")[-1]
			$dstItems = $dstFile.ListItemAllFields
			$dstItems["DocType" ] = $docTypeItemName 
			$dstItems["Created" ] = $sItems["Created" ] #$srcDateCreat
			$dstItems["Modified"] = $sItems["Modified"] # $srcDateEdit
			$dstItems["Author"  ] = $sItems["Author"  ] #$srcWhoCreat
			$dstItems["Editor"  ] = $sItems["Editor"  ] #$srcWhoEdit
			$dstItems.Update()
			$listDst.Update()
			$CtxDst.Load($dstItems)
			$CtxDst.Load($listDst)
			$CtxDst.ExecuteQuery()
			$StudentIDFound = $true
			break

		}
	}
	if (!$StudentIDFound){
		Write-Host "289  Warning: On Site $siteSRC in $ResponseLetterListName Not Found $studID" -f Yellow
	}
							
}
function Copy-StudentFiles( $siteSRC, $listSRC, $siteDst, $dstLib,$dstLibInnName, $dstFld){
	$srcListUrl = $([system.uri]$listSRC.URL).LocalPath
	$dstListUrl = $([system.uri]$siteDst).LocalPath + $dstLibInnName
	#write-Host 296 $dstListUrl

	#Write-Host 180 $siteSRC, $srcListUrl, $siteDst, $dstLib, $dstFld
	
	$siteName = get-UrlNoF5 $siteSRC
	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	
	$Ctx.Credentials = $Credentials
	$srcList = $ctx.Web.GetList($srcListUrl)
    $Ctx.Load($srcList)
    $Ctx.ExecuteQuery()

    $FolderSrc = $srcList.RootFolder
    $FilesCollSrc = $FolderSrc.Files
    $Ctx.Load($FolderSrc)
    $Ctx.Load($FilesCollSrc)
    $Ctx.ExecuteQuery()
	
	$siteNameDst = get-UrlNoF5 $siteDst
	$CtxDst = New-Object Microsoft.SharePoint.Client.ClientContext($siteNameDst)
	$CtxDst.Credentials = $Credentials
 
	$listDst = 	$CtxDst.Web.GetList($dstListUrl)
    $CtxDst.Load($listDst)
    $CtxDst.ExecuteQuery()
	$listDstRootFolder = $listDst.RootFolder
    $CtxDst.Load($listDstRootFolder)
    $CtxDst.ExecuteQuery()

	$dstListUrl = $([system.uri]$siteDst).LocalPath + $listDstRootFolder.Name

    #Write-Host 233 $srcList.Title
	$listSrcSchema = get-ListSchema $siteSRC $srcList.Title

	$listOfSrcFields = @()
	foreach($schemaField in $listSrcSchema){

		$xmlF = $schemaField
		$isXMLsrc = [bool]$($xmlF -as [xml])
		if ($isXMLsrc){
			$fieldItem = "" | Select fieldDispName, fieldName, fieldType
			$fieldItem.fieldDispName = Select-Xml -Content $xmlF  -XPath "/Field" | ForEach-Object { $_.Node.DisplayName.Trim()}
			$fieldItem.fieldName = Select-Xml -Content $xmlF  -XPath "/Field" | ForEach-Object { $_.Node.Name.Trim()}
			$fieldItem.fieldType = Select-Xml -Content $xmlF  -XPath "/Field" | ForEach-Object { $_.Node.Type.Trim()}
			
			$listOfSrcFields += $fieldItem
				
		}
	}
	#$listOfSrcFields |  out-file $("JSON\ma-Src"+$FolderSrc.Name+".txt")
	$listDstSchema = get-ListSchema $siteDst $dstLib

	
	$listOfDstFields = @()
	foreach($schemaField in $listDstSchema){

		$xmlF = $schemaField
		$isXMLsrc = [bool]$($xmlF -as [xml])
		if ($isXMLsrc){
			$fieldItem = "" | Select fieldDispName, fieldName, fieldType
			$fieldItem.fieldDispName = Select-Xml -Content $xmlF  -XPath "/Field" | ForEach-Object { $_.Node.DisplayName.Trim()}
			$fieldItem.fieldName = Select-Xml -Content $xmlF  -XPath "/Field" | ForEach-Object { $_.Node.Name.Trim()}
			$fieldItem.fieldType = Select-Xml -Content $xmlF  -XPath "/Field" | ForEach-Object { $_.Node.Type.Trim()}
			
			$listOfDstFields += $fieldItem
				
		}
	}
	#$listOfDstFields |  out-file $("JSON\ma-Dst"+$listDstRootFolder.Name+".txt")
	
		
	$dstLibURL  = $dstListUrl+"/"+$dstFld

	ForEach($srcFile in $FilesCollSrc){
		#Write-Host $srcFile.Name
		#Write-Host $srcFile.ServerRelativeURL
		$dstFileURL = $dstLibURL+"/"+$srcFile.Name
		
		#Write-Host $dstFileURL
		#Get the Source File
		$FileInfo = [Microsoft.SharePoint.Client.File]::OpenBinaryDirect($Ctx, $srcFile.ServerRelativeURL)
		[Microsoft.SharePoint.Client.File]::SaveBinaryDirect($CtxDst, $dstFileURL, $FileInfo.Stream,$True)

		$sItems   = $srcFile.ListItemAllFields
		$Ctx.Load($sItems)
		$Ctx.ExecuteQuery()
		$dstFile = Get-DestFile $CtxDst $dstListUrl $dstFld $dstFileURL.split("/")[-1]
		$dstItems = $dstFile.ListItemAllFields
		foreach($fieldItem  in $listOfDstFields){
			if ($fieldItem.fieldType -ne "File"){
				$isLookupField = $false
				$foundField = $false
				$fldSrcIntName = "" # internal name
				
				forEach($fItemSrc in $listOfSrcFields){
					if ($fItemSrc.fieldDispName -eq $fieldItem.fieldDispName){
						$foundField = $true
						$isLookupField = $fItemSrc.fieldType -eq "Lookup"
						$fldSrcIntName = $fItemSrc.fieldName
						break
					}
				}
				if ($foundField){
					if (!$isLookupField){
						$dstItems[$fieldItem.fieldName] = $sItems[$fldSrcIntName] 
					}
					else
					{
						$dstItems[$fieldItem.fieldName] = ([Microsoft.SharePoint.Client.FieldLookupValue]$sItems[$fldSrcIntName]).LookupValue
					}
				}
			}	
		}
		$dstItems["Created" ] = $sItems["Created" ] #$srcDateCreat
		$dstItems["Modified"] = $sItems["Modified"] # $srcDateEdit
		$dstItems["Author"  ] = $sItems["Author"  ] #$srcWhoCreat
		$dstItems["Editor"  ] = $sItems["Editor"  ] #$srcWhoEdit
		$dstItems.Update()
		$listDst.Update()
		$CtxDst.Load($dstItems)
		$CtxDst.Load($listDst)
		$CtxDst.ExecuteQuery()
		
		
	
	}
	
}
function Get-XmlObj($xmlFileName){
	$obj = "" | Select SPSource,SPDestination,DestinationFolders,FieldMaps,FieldStatics
	
	$SPSource  		= "" | Select SiteURL,ListName,ListFilterField,ListFilterValues,CopyStudentsItems,CopyResponseLetter,ResponseLetterListName,ApplicantFolderLinkField
	$SPDestination  = "" | Select SiteURL,ListName,FolderField,FolderName,KeyField,StudentsItemsDestFolder,ResponseLetterDocTypeName
	$DestinationFolders  = "" | Select FolderInnerName,FolderName,FolderStructure
	$FieldMaps  = "" | Select Items
	$FieldStatics  = "" | Select Items
	
	$xmlFile = Get-Content $xmlFileName -raw
	$isXML = [bool](($xmlFile) -as [xml])
	if ($isXML){
			#$xmlNodeData = Select-Xml -Path $wrkFileName -XPath "/Config/application/control" | ForEach-Object 
			              #{$_.Node.Data}
						  
		$xmlDoc = [xml]$xmlFile
		$xmlOSPSource = $xmlDoc.SelectNodes("//SPSource")
		foreach($spSrc in $xmlOSPSource){
			$SPSource.SiteURL = $spSrc.SiteURL
			if (!$($SPSource.SiteURL -match "/$")){
				$SPSource.SiteURL += "/"
			}
			
			$SPSource.ListName = $spSrc.ListName
			$SPSource.ListFilterField = $spSrc.ListFilterField
			$SPSource.ListFilterValues = $spSrc.ListFilterValues.ToString().Split(",") | %{$_.Trim()}
			$SPSource.CopyStudentsItems = $false
			if ( $spSrc.CopyStudentsItems -eq "Yes"){
				$SPSource.CopyStudentsItems = $true
				$SPSource.ApplicantFolderLinkField = $spSrc.ApplicantFolderLinkField 
			}
			$SPSource.CopyResponseLetter = $false
			if ( $spSrc.CopyResponseLetter -eq "Yes"){
				$SPSource.CopyResponseLetter = $true
				$SPSource.ResponseLetterListName = $spSrc.ResponseLetterListName
			}
			
			
			break
		}
		$xmlSPDestination = $xmlDoc.SelectNodes("//SPDestination")
		foreach($spDest in $xmlSPDestination){
			$SPDestination.SiteURL  = $spDest.SiteURL
			if (!$($SPDestination.SiteURL -match "/$")){
				$SPDestination.SiteURL += "/"
			}
			$SPDestination.ListName = $spDest.ListName
			$SPDestination.FolderField = $spDest.FolderField
			$SPDestination.FolderName = $spDest.FolderName
			$SPDestination.KeyField = $spDest.KeyField
			$SPDestination.StudentsItemsDestFolder = $spDest.StudentsItemsDestFolder
			$SPDestination.ResponseLetterDocTypeName = $spDest.ResponseLetterDocTypeName
			
			break
		}
		$xmlDestinationFolders = $xmlDoc.SelectNodes("//DestinationFolders")
		foreach($dFld in $xmlDestinationFolders){
			$DestinationFolders.FolderInnerName  = $dFld.FolderInnerName 
			$DestinationFolders.FolderName  = $dFld.FolderName 
			$DestinationFolders.FolderStructure  = $dFld.FolderStructure.ToString().Split(",") | %{$_.Trim()}
			break
		}
		$xmlConsolidation = $xmlDoc.SelectNodes("//Consolidation")
		foreach($FieldMap in $xmlConsolidation){
			$FieldMaps.Items  = $FieldMap.FieldMaps.ToString().Split(",") | %{$_.Trim()}
			$FieldStatics.Items  = $FieldMap.FieldMapsStatics.ToString().Split(",") | %{$_.Trim()}
			break
		}
		

		
		$obj.SPSource = $SPSource
		$obj.SPDestination = $SPDestination
		$obj.DestinationFolders = $DestinationFolders
		$obj.FieldMaps = $FieldMaps
		$obj.FieldStatics = $FieldStatics
		
	}	
	return $obj
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

$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"
Start-Transcript Consolidate-Files.log

$Credentials = get-SCred

$xmlFileName = ".\ConsolidateFolders\Consolidate-Brosh.xml"
#$xmlFileName = "\\ekeksql00\SP_Resources$\WP_Config\SendToRakefet\rakefet.xml"
$xmlObj = get-XmlObj $xmlFileName

$siteURL = get-UrlNoF5 $xmlObj.SPSource.SiteURL
$listSRC = $xmlObj.SPSource.ListName

$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteURL)
#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
$Ctx.Credentials = $Credentials
		  

$LstSrc = $Ctx.Web.lists.GetByTitle($listSRC)

$Query = New-Object Microsoft.SharePoint.Client.CamlQuery
$qry = "<View><Query></Query></View>"
$Query.ViewXml = $qry

#Get All List Items matching the query
$ListItems = $LstSrc.GetItems($Query)
$Ctx.Load($ListItems)
$Ctx.ExecuteQuery()

$filteredListID = @()
$filterFieldName = $xmlObj.SPSource.ListFilterField
$filtrValues = $xmlObj.SPSource.ListFilterValues

#FilterSource
foreach($listItem in $listItems){
	 $filtrValid = $false
	 $fltrFieldVal = $listItem[$filterFieldName]
	 forEach($filtrVal in $filtrValues){
		 if ($fltrFieldVal -eq $filtrVal){
			$filtrValid = $true
			break
		 }
	 }
	 if ($filtrValid){
		#write-Host  $fltrFieldVal
		$filteredListID += $listItem.ID
	 }
    
}
# Open Destination
$siteURLDest = get-UrlNoF5 $xmlObj.SPDestination.SiteURL
$listNameOut = $xmlObj.SPDestination.ListName
$ctxDest = New-Object Microsoft.SharePoint.Client.ClientContext($siteURLDest)
$ctxDest.Credentials = $Credentials
		  

$ListDst = $ctxDest.Web.lists.GetByTitle($listNameOut)
$mappedFields = $xmlObj.FieldMaps.Items
$staticFields = $xmlObj.FieldStatics.Items
$keyFieldName = $xmlObj.SPDestination.KeyField
$studentFolderName = $xmlObj.SPDestination.FolderName
$FolderField = $xmlObj.SPDestination.FolderField
$FolderStructure = $xmlObj.DestinationFolders.FolderStructure
$destFolderInnerName   = $xmlObj.DestinationFolders.FolderInnerName

$adestFolderExternNameTmp = $xmlObj.DestinationFolders.FolderName.Split("%")
$adestFolderExternName = @()

forEach($dstFldExtName in $adestFolderExternNameTmp){
	if (![string]::IsNullOrEmpty($dstFldExtName)){
		$adestFolderExternName += $dstFldExtName
	}
}

#$adestFolderExternName

$cnt =1
$allCount = $filteredListID.Count
forEach($srcID in $filteredListID){
	Write-Host "$cnt OF $allCount ..." -f Green
	#Write-Host "$srcID" -f Green
	#if ($cnt -gt 92){	
	#write-host $srcID
	$srcItem = $LstSrc.GetItemById($srcID)
	$Ctx.Load($srcItem)
	$Ctx.ExecuteQuery()
	#
	Write-Host "StudentID: "$srcItem[$keyFieldName] -f Cyan
	$destinationID = Get-DestinationItemID $siteURLDest $listNameOut $keyFieldName $srcItem[$keyFieldName]
	if ($destinationID -eq 0){
		$listItemInfo = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation
		$listItemDst = $ListDst.AddItem($listItemInfo) 
	}
	else
	{
		$listItemDst = $ListDst.GetItemById($destinationID)
		$ctxDest.Load($listItemDst)
		$ctxDest.ExecuteQuery()

	}
	#>
	forEach($mapFld in $mappedFields){
		$fldNameSrc = $mapFld.Split("=")[1]
		$fldNameDst = $mapFld.Split("=")[0]
		$listItemDst[$fldNameDst] = $srcItem[$fldNameSrc]
		#$fldNameSrc
		#Write-Host $srcItem[$fldNameSrc]
		
	}
	forEach($mapFld in $staticFields){
		$fldNameSrc = $mapFld.Split("=")[1]
		$fldNameDst = $mapFld.Split("=")[0]
		$listItemDst[$fldNameDst] = $fldNameSrc
		
	}
	#
	$HyperLinkField= New-Object Microsoft.SharePoint.Client.FieldUrlValue
    $HyperLinkField.Url = $xmlObj.SPDestination.SiteURL + $listItemDst[$keyFieldName]
	
    $HyperLinkField.Description = $studentFolderName
	$listItemDst[$FolderField] =[Microsoft.SharePoint.Client.FieldUrlValue]$HyperLinkField
	
	$listItemDst.Update()      
	$ctxDest.load($ListDst)      
	$ctxDest.executeQuery()  
	#Write-Host "Item Added with ID - " $listItemDst.ID 		
	#>
	
	
	$dstFldExtNmeVal = ""
	
	forEach($aDestItm in $adestFolderExternName){
		if([string]::IsNullOrEmpty($aDestItm.Trim())){
			$dstFldExtNmeVal += $aDestItm
		}
		else
		{
			$dstFldExtNmeVal += $srcItem[$aDestItm]
		}
	}
	#write-Host 275 $dstFldExtNmeVal
	$dstFldInnNmeVal = $srcItem[$destFolderInnerName]
	$isDocLibExists  = Is-DocLibExists $siteURLDest $dstFldInnNmeVal
	
	if (!$isDocLibExists.Exists){
		write-host "Document Library Creating"
		write-host $dstFldInnNmeVal -f Magenta
		write-host $dstFldExtNmeVal -f Cyan
		create-DocLib $siteURLDest $dstFldInnNmeVal $dstFldExtNmeVal
		
	}
	else
	{
		$dstFldExtNmeVal = $isDocLibExists.Title
	}
	Add-FieldsToDocLibX $siteURLDest $dstFldExtNmeVal
	Change-DefaultViewX $siteURLDest $dstFldExtNmeVal
	Create-Folders $siteURLDest $dstFldExtNmeVal $FolderStructure
	if ($xmlObj.SPSource.CopyStudentsItems){ # flag to Copy is On
		Copy-StudentFiles $siteURL $srcItem[$xmlObj.SPSource.ApplicantFolderLinkField] $siteURLDest $dstFldExtNmeVal $dstFldInnNmeVal $xmlObj.SPDestination.StudentsItemsDestFolder
	}
	if ($xmlObj.SPSource.CopyResponseLetter){ # flag to Copy is On
		Copy-LettersFiles 	$siteURL $xmlObj.SPSource.ResponseLetterListName $srcItem[$keyFieldName] $siteURLDest $dstFldExtNmeVal $xmlObj.SPDestination.StudentsItemsDestFolder 	$xmlObj.SPDestination.ResponseLetterDocTypeName
	}
	
	#}
	$cnt++
	#if ($cnt -gt 2){
	#	break	
	#}
	
	$RecentsTitle = "לאחרונה"
	$NOmoreSubItems = $false
	while (!$NOmoreSubItems){
		$NOmoreSubItems =  Delete-RecentsSubMenu $siteURLDest $RecentsTitle 

	}
	
}

$RecentsTitle = "לאחרונה"

Delete-RecentMainMenu $siteURLDest $RecentsTitle 	


	$JsonFile =   ".\ConsolidateFolders\xmlObj.json"
	$xmlObj | ConvertTo-Json -Depth 100 | out-file $JsonFile

Stop-Transcript
