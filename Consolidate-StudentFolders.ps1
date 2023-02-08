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
			$Folder=$CtxFld.web.GetFolderByServerRelativeUrl($TargetFolderURL)
			$Ctx.load($Folder)
			$Ctx.ExecuteQuery()
			Write-host "Folder Already Exists:"$TargetFolderURL -f Yellow
		}
		catch{
			#Create Folder
			if(!$Folder.Exists){
				
				$Folder=$Ctx.Web.Folders.Add($TargetFolderURL)
				$Ctx.Load($Folder)
				$Ctx.ExecuteQuery()
				Write-host "Folder Created:"$TargetFolderURL -f Green
			}
		}
	}
#Write-Host 223...
#Read-Host
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
		    write-host $fieldN
			$view.ViewFields.Add($fieldN)
			$view.Update()
			$Ctx.ExecuteQuery()		
	}

	write-host "Updated $listName Default View." -foregroundcolor Green
	
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
	
	$libExists = $false
	ForEach($list in $Lists)
	{	
	    $rtFolder = $list.RootFolder
		$Ctx.Load($rtFolder)
		$Ctx.ExecuteQuery()
		
		if ($rtFolder.Name -eq $id){
			$libExists = $true
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
function Get-XmlObj($xmlFileName){
	$obj = "" | Select SPSource,SPDestination,DestinationFolders,FieldMaps,FieldStatics
	
	$SPSource  		= "" | Select SiteURL,ListName,ListFilterField,ListFilterValues
	$SPDestination  = "" | Select SiteURL,ListName,FolderField,FolderName,KeyField
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
forEach($srcID in $filteredListID){
	write-host $srcID
	$srcItem = $LstSrc.GetItemById($srcID)
	$Ctx.Load($srcItem)
	$Ctx.ExecuteQuery()
	#
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
	Write-Host "Item Added with ID - " $listItemDst.ID 		
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
	
	if (!$isDocLibExists){
		write-host "Document Library Creating"
		write-host $dstFldInnNmeVal -f Magenta
		write-host $dstFldExtNmeVal -f Cyan
		create-DocLib $siteURLDest $dstFldInnNmeVal $dstFldExtNmeVal
		
	}
	Add-FieldsToDocLibX $siteURLDest $dstFldExtNmeVal
	Change-DefaultViewX $siteURLDest $dstFldExtNmeVal
	Create-Folders $siteURLDest $dstFldExtNmeVal $FolderStructure
	$cnt++
	if ($cnt -gt 2){
		break	
	}
	
	
}

$RecentsTitle = "לאחרונה"
$NOmoreSubItems = $false
while (!$NOmoreSubItems){
	$NOmoreSubItems =  Delete-RecentsSubMenu $siteURLDest $RecentsTitle 

}

Delete-RecentMainMenu $siteURLDest $RecentsTitle 	


	$JsonFile =   ".\ConsolidateFolders\xmlObj.json"
	$xmlObj | ConvertTo-Json -Depth 100 | out-file $JsonFile

Stop-Transcript
