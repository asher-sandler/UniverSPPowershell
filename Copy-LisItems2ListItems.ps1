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

$cred = get-SCred

 
 $siteNew = "https://portals2.ekmd.huji.ac.il/home/tap/CSE/CSE13-2023";
 $siteOld = "https://portals2.ekmd.huji.ac.il/home/tap/CSE/CSE12-2022";
 $srcListName = "coursesList"
 $dstListName = "coursesList"

  
 $siteName = get-UrlNoF5 $siteOld
 write-host "URL: $siteName" -foregroundcolor Yellow

 write-host "Get-ListFields $srcListName : $siteSrcURL" -foregroundcolor Green
 $ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
 $ctx.Credentials = $Credentials
 	
 $Web = $Ctx.Web
 $ctx.Load($Web)
 $Ctx.ExecuteQuery()
 
 $sList = $Web.lists.GetByTitle($srcListName);
 $ctx.Load($sList)
 $Ctx.ExecuteQuery()
 
 $docLibName = $sList.Title
 write-host "Opened List : $docLibName"
 
 
 $schemaListSrc1 =  get-ListSchema $siteOld $srcListName
 
 $sourceListObj = get-SchemaObject $schemaListSrc1
 $outFileName = "JSON\"+$srcListName+"-ListSource.json"
 $sourceListObj | ConvertTo-Json -Depth 100 | out-file $outFileName
 Write-Host "Created File : $outFileName"
 
 $AllFields = @()
 forEach($fEl in $sourceListObj){
	 $AllFields += $fel.DisplayName
 }
 
 $outFileName = "JSON\"+$srcListName+"-ListSource.txt"
 $AllFields | out-file $outFileName
 Write-Host "Created File : $outFileName"
 
 
 $siteUrlDst =  get-UrlNoF5 $siteNew
 $schemaDocLibDst1 =  get-ListSchema $siteUrlDst $dstListName
 $dstDocObj = get-SchemaObject $schemaDocLibDst1 
 $outFileName = "JSON\"+$dstListName+"-ListDest.json"
 $dstDocObj | ConvertTo-Json -Depth 100 | out-file $outFileName
 Write-Host "Created File : $outFileName"

	#Define the CAML Query
 $Query = New-Object Microsoft.SharePoint.Client.CamlQuery
 $qry = "<View><Query></Query></View>"
 $Query.ViewXml = $qry

	#Get All List Items matching the query
 $SrcListItems = $sList.GetItems($Query)
 $Ctx.Load($SrcListItems)
 $Ctx.ExecuteQuery()

 $aListOld = @()
 ForEach($SrcListItem in $SrcListItems){
	 $listOldItem = "" | Select ID,  Course,Title
	 $listOldItem.ID = $SrcListItem.ID
	 $listOldItem.Title = $SrcListItem["Title"]
	 $listOldItem.Course = $SrcListItem["_x05de__x05e1__x05e4__x05e8__x00"]
	 $aListOld += $listOldItem
	 
 }	 
 
 $outFileName = "JSON\"+$srcListName+"-ListSrcItems.json"
 $aListOld | ConvertTo-Json -Depth 100 | out-file $outFileName
 Write-Host "Created File : $outFileName"

 $siteDstName = get-UrlNoF5 $siteNew

 Write-Host "Copy to Site: $siteDstName List: $dstListName" -f Cyan
 $ctxDst = New-Object Microsoft.SharePoint.Client.ClientContext($siteDstName) 
 $ctx.Credentials = $Credentials
 	
 $WebDst = $CtxDst.Web
 $ctxDst.Load($WebDst)
 $CtxDst.ExecuteQuery()
 
 $dList = $WebDst.lists.GetByTitle($srcListName);
 $ctxDst.Load($dList)
 $CtxDst.ExecuteQuery()
 
 Write-Host $dList.Title
 #$maxRows = 0
 	
 
 
 forEach($listOldItem in $aListOld){
	$itemSrc = $sList.getItemById($listOldItem.Id)
	#$itemSrc = $sList.getItemById(189)
	$ctx.Load($itemSrc)
	$Ctx.ExecuteQuery()

	$listItemInfo = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation  
			
	$listItemNew = $dList.AddItem($listItemInfo)  
   
	foreach($dstFldObj in $dstDocObj){
		if ($dstFldObj.Type -eq "Attachments"){
			continue
		}
		if ($dstFldObj.Type.Contains("Lookup")){
			
			#$lookupFID = ([Microsoft.SharePoint.Client.FieldLookupValue]$itemSrc[$dstFldObj.Name]).LookupId
			#$lookupFVal = ([Microsoft.SharePoint.Client.FieldLookupValue]$itemSrc[$dstFldObj.Name]).LookupValue
			
			if ($dstFldObj.Type -eq "LookupMulti"){
				$LookupCollection = @()
				forEach ($sItem in $itemSrc[$dstFldObj.Name]){
					$lookupValue = New-Object Microsoft.SharePoint.Client.FieldLookupValue
					$lookupValue.LookupId = $sItem.LookupId
					$LookupCollection += $lookupValue
					#Write-Host 133 $dstFldObj.DisplayName $sItem.LookupId 	 $sItem.LookupId
					#$sItem | gm
				}
				$listItemNew[$dstFldObj.Name] = [Microsoft.SharePoint.Client.FieldLookupValue[]]$LookupCollection
				
			}
			else
			{
				$LookupIDs = $itemSrc[$dstFldObj.Name] | ForEach-Object { $_.LookupID.ToString()}	
				$listItemNew[$dstFldObj.Name] = $LookupIDs
			}
		}
		else{
			$listItemNew[$dstFldObj.Name] = $itemSrc[$dstFldObj.Name]
		}
	
	}
	#$listItemNew["Title"] = $itemSrc["Title"]
	$listItemNew["Created" ] = $itemSrc["Created" ] #$srcDateCreat
	$listItemNew["Modified"] = $itemSrc["Modified"] # $srcDateEdit
	$listItemNew["Author"  ] = $itemSrc["Author"  ] #$srcWhoCreat
	$listItemNew["Editor"  ] = $itemSrc["Editor"  ] #$srcWhoEdit

	$listItemNew.Update()      
	$ctxDst.load($dList)      
	$ctxDst.executeQuery() 
	#$maxRows--
    #write-host 143	$maxRows
	#if ($maxRows -le 0){

	#	break	 
	#}
	#read-host
 }
 
 Write-Host "Done ...."
 

 
 
 
 