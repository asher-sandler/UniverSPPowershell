function Get-LookupId ($siteSrc,$libName,$LookupValue){
	$retValue = 0 
	$siteNameSrc = get-UrlNoF5 $siteSrc
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteNameSrc)
	$ctx.Credentials = $Credentials
	
	$list = 	$ctx.Web.Lists.GetByTitle($libName)
    $Ctx.Load($list)
    $Ctx.ExecuteQuery()
	
	$Query = New-Object Microsoft.SharePoint.Client.CamlQuery
	
	$qry = "<View><Query><Where><Eq><FieldRef Name='Title' /><Value Type='Text'>$LookupValue</Value></Eq></Where></Query></View>"
	#$qry = "<View><Query></Query></View>"
	$Query.ViewXml = $qry

	#Get All List Items matching the query
	$ListItems = $List.GetItems($Query)
	$Ctx.Load($ListItems)
	$Ctx.ExecuteQuery()
	ForEach($itm in $ListItems){
		$retValue = $itm.Id
		break
	}
	
	return $retValue
	
} 
function Get-DestFile($ctx, $libName, $sFileName){
	$oFile = $null

	$List = $Ctx.Web.lists.GetByTitle($libName)
    $ctx.Load($List)
	$Ctx.ExecuteQuery()

    $FolderSrc = $List.RootFolder
    $FilesCollSrc = $FolderSrc.Files
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
function Copy-ContentY( $siteSrc, $siteDst, $libName)
{
	$siteNameSrc = get-UrlNoF5 $siteSrc
	$CtxSrc = New-Object Microsoft.SharePoint.Client.ClientContext($siteNameSrc)
	$CtxSrc.Credentials = $Credentials
	
	$listSrc = 	$CtxSrc.Web.Lists.GetByTitle($libName)
    $CtxSrc.Load($listSrc)
    $CtxSrc.ExecuteQuery()

    $FolderSrc = $listSrc.RootFolder
    $FilesCollSrc = $FolderSrc.Files
    $CtxSrc.Load($FilesCollSrc)
    $CtxSrc.ExecuteQuery()

	$siteNameDst = get-UrlNoF5 $siteDst
	$CtxDst = New-Object Microsoft.SharePoint.Client.ClientContext($siteNameDst)
	$CtxDst.Credentials = $Credentials
 
	$listDst = 	$CtxDst.Web.Lists.GetByTitle($libName)
    $CtxDst.Load($listDst)
    $CtxDst.ExecuteQuery()

	$listSchema = get-ListSchema	$siteDst $libName

	$listOfFields = @()
	foreach($schemaField in $listSchema){

		$xmlF = $schemaField
		$isXMLsrc = [bool]$($xmlF -as [xml])
		if ($isXMLsrc){
			$fieldItem = "" | Select fieldDispName, fieldName, fieldType
			$fieldItem.fieldDispName = Select-Xml -Content $xmlF  -XPath "/Field" | ForEach-Object { $_.Node.DisplayName.Trim()}
			$fieldItem.fieldName = Select-Xml -Content $xmlF  -XPath "/Field" | ForEach-Object { $_.Node.Name.Trim()}
			$fieldItem.fieldType = Select-Xml -Content $xmlF  -XPath "/Field" | ForEach-Object { $_.Node.Type.Trim()}
			
			$listOfFields += $fieldItem
				
		}
	}
	
	
	ForEach($srcFile in $FilesCollSrc){
		$dstFile = Get-DestFile $CtxDst $libName $srcFile.Name
		$dstExists = $dstFile.Exists
		if (!$dstExists){
			Write-Host $srcFile.Name
			#Get the Source File
			$FileInfo = [Microsoft.SharePoint.Client.File]::OpenBinaryDirect($CtxSrc, $srcFile.ServerRelativeURL)
			$dstRelativeUrl = $srcFile.ServerRelativeURL.Replace("/"+$archiveSuffix,"") 
			Write-Host $dstRelativeUrl
			#Copy File to the Target location
			[Microsoft.SharePoint.Client.File]::SaveBinaryDirect($CtxDst, $dstRelativeUrl, $FileInfo.Stream,$True)
			

			$sItems   = $srcFile.ListItemAllFields
			$CtxSrc.Load($sItems)
			$CtxSrc.ExecuteQuery()
			
			$dstFile = Get-DestFile $CtxDst $libName $srcFile.Name
			$dstItems = $dstFile.ListItemAllFields
			<#
			$docTypeFieldName = "_x05ea__x05d5__x05db__x05df__x0020__x05e7__x05d5__x05d1__x05e5_"
			$dstItems[$docTypeFieldName] = $sItems[$docTypeFieldName]
			$dstItems["sentResponse"] = $sItems["sentResponse"]
			#>
			foreach($fieldItem  in $listOfFields){

				if ($fieldItem.fieldType -eq "Lookup"){
										
					$srcLookUpID = Get-LookupId $siteDst "DocType" ([Microsoft.SharePoint.Client.FieldLookupValue]$sItems[$fieldItem.fieldName]).LookupValue 
					$dstItems[$fieldItem.fieldName] = $srcLookUpID
				}
				else
				{
					if ($fieldItem.fieldType -ne "File"){
				
						$dstItems[$fieldItem.fieldName] = $sItems[$fieldItem.fieldName] 
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
		else
		{
			Write-Host $srcFile.Name " already exists" -f Cyan

		}
	}
 	Return $null
	
}
function Copy-ContentX( $siteSrc, $siteDst, $libName)
{
	$siteNameSrc = get-UrlNoF5 $siteSrc
	$CtxSrc = New-Object Microsoft.SharePoint.Client.ClientContext($siteNameSrc)
	$CtxSrc.Credentials = $Credentials
	
	$listSrc = 	$CtxSrc.Web.Lists.GetByTitle($libName)
    $CtxSrc.Load($listSrc)
    $CtxSrc.ExecuteQuery()

    $FolderSrc = $listSrc.RootFolder
    $FilesCollSrc = $FolderSrc.Files
    $CtxSrc.Load($FilesCollSrc)
    $CtxSrc.ExecuteQuery()

	$siteNameDst = get-UrlNoF5 $siteDst
	$CtxDst = New-Object Microsoft.SharePoint.Client.ClientContext($siteNameDst)
	$CtxDst.Credentials = $Credentials
 
	$listDst = 	$CtxDst.Web.Lists.GetByTitle($libName)
    $CtxDst.Load($listDst)
    $CtxDst.ExecuteQuery()

	$listSchema = get-ListSchema	$siteDst $libName

	$listOfFields = @()
	foreach($schemaField in $listSchema){

		$xmlF = $schemaField
		$isXMLsrc = [bool]$($xmlF -as [xml])
		if ($isXMLsrc){
			$fieldItem = "" | Select fieldDispName, fieldName, fieldType
			$fieldItem.fieldDispName = Select-Xml -Content $xmlF  -XPath "/Field" | ForEach-Object { $_.Node.DisplayName.Trim()}
			$fieldItem.fieldName = Select-Xml -Content $xmlF  -XPath "/Field" | ForEach-Object { $_.Node.Name.Trim()}
			$fieldItem.fieldType = Select-Xml -Content $xmlF  -XPath "/Field" | ForEach-Object { $_.Node.Type.Trim()}
			
			$listOfFields += $fieldItem
				
		}
	}
	
	
	ForEach($srcFile in $FilesCollSrc){
		Write-Host $srcFile.Name
		#Get the Source File
		$FileInfo = [Microsoft.SharePoint.Client.File]::OpenBinaryDirect($CtxSrc, $srcFile.ServerRelativeURL)
		$dstRelativeUrl = $srcFile.ServerRelativeURL.Replace("/"+$archiveSuffix,"") 
		Write-Host $dstRelativeUrl
		#Copy File to the Target location
		[Microsoft.SharePoint.Client.File]::SaveBinaryDirect($CtxDst, $dstRelativeUrl, $FileInfo.Stream,$True)
		

		$sItems   = $srcFile.ListItemAllFields
		$CtxSrc.Load($sItems)
		$CtxSrc.ExecuteQuery()
		
		$dstFile = Get-DestFile $CtxDst $libName $srcFile.Name
		$dstItems = $dstFile.ListItemAllFields
		<#
		$docTypeFieldName = "_x05ea__x05d5__x05db__x05df__x0020__x05e7__x05d5__x05d1__x05e5_"
		$dstItems[$docTypeFieldName] = $sItems[$docTypeFieldName]
		$dstItems["sentResponse"] = $sItems["sentResponse"]
		#>
		foreach($fieldItem  in $listOfFields){

			if ($fieldItem.fieldType -eq "Lookup"){
									
				$srcLookUpID = Get-LookupId $siteDst "DocType" ([Microsoft.SharePoint.Client.FieldLookupValue]$sItems[$fieldItem.fieldName]).LookupValue 
				$dstItems[$fieldItem.fieldName] = $srcLookUpID
			}
			else
			{
				if ($fieldItem.fieldType -ne "File"){
			
					$dstItems[$fieldItem.fieldName] = $sItems[$fieldItem.fieldName] 
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

 	Return $null
	
}
function Change-Permissions ($siteUrl, $studLibObj){

	$siteName = get-UrlNoF5 $siteUrl	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	$Ctx.Credentials = $Credentials

	$Web = $Ctx.Web
	$ctx.Load($Web)
	$Ctx.ExecuteQuery()
	
	
	$List = $Ctx.Web.lists.GetByTitle($studLibObj.Title)
    $ctx.Load($List)
	$Ctx.ExecuteQuery()

	$List.BreakRoleInheritance($False,$False) #keep existing list permissions & Item level permissions
	$Ctx.ExecuteQuery()
	Write-host -f Green "Permission inheritance broken successfully!"


    # Add Group Permissions To List
	$GroupPermissionLevel="Full Control"
	$EdtGroupName = "ekmd\GRS_SOC46-2022_adminUG"
	write-Host $GroupPermissionLevel

	$Group =$Web.EnsureUser($EdtGroupName)
	$Ctx.load($Group)
	$Ctx.ExecuteQuery()
	
	$Role = $web.RoleDefinitions.GetByName($GroupPermissionLevel)
	$RoleDB = New-Object Microsoft.SharePoint.Client.RoleDefinitionBindingCollection($Ctx)
	$RoleDB.Add($Role)

	$Permissions = $List.RoleAssignments.Add($Group,$RoleDB)
	$List.Update()
	$Ctx.ExecuteQuery()
	
    # Add  User Permissions To List
	write-host $studLibObj.UserName

	$spUser = $web.EnsureUser($studLibObj.UserName)
	$Ctx.load($spUser)
	$Ctx.ExecuteQuery()
	
	$UserPermissionLevel="Contribute"
	write-Host $UserPermissionLevel

	# enSure Users and Group
	
	$Role = $web.RoleDefinitions.GetByName($UserPermissionLevel)
	$RoleDB = New-Object Microsoft.SharePoint.Client.RoleDefinitionBindingCollection($Ctx)
	$RoleDB.Add($Role)
	
	$Permissions = $List.RoleAssignments.Add($spUser,$RoleDB)
    $List.Update()
    $Ctx.ExecuteQuery()	
	
    # Remove Current User Permissions
	$currentUserName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
	$spCurrentUser = $web.EnsureUser($currentUserName)
	
	$List.RoleAssignments.GetByPrincipal($spCurrentUser).DeleteObject()
	$List.Update()
	$Ctx.ExecuteQuery()
	
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


	
	$qryView = '<OrderBy><FieldRef Name="_x05ea__x05d5__x05db__x05df__x0020__x05e7__x05d5__x05d1__x05e5_" /></OrderBy>'
	
	
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


	$vFieldsList =      "Edit",
                       "DocIcon",
                       "LinkFilename",
                       "Created",
                       "_x05ea__x05d5__x05db__x05df__x0020__x05e7__x05d5__x05d1__x05e5_"

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
	$schemaFields += '<Field Type="Boolean" DisplayName="sentResponse" EnforceUniqueValues="FALSE" Indexed="FALSE"  StaticName="sentResponse" Name="sentResponse" ><Default>0</Default></Field>'
	$schemaFields += '<Field DisplayName="תוכן קובץ" Type="Lookup" Required="FALSE" List="{FA3D3976-A0BA-445F-BB27-83AF6991440C}"  SourceID="{dcb45d11-47d6-49f6-9d1d-1585ec777339}" StaticName="_x05ea__x05d5__x05db__x05df__x0020__x05e7__x05d5__x05d1__x05e5_" Name="_x05ea__x05d5__x05db__x05df__x0020__x05e7__x05d5__x05d1__x05e5_" ColName="int1" RowOrdinal="0" Version="2" ShowField="Title" />
'
	ForEach($fSchema in $schemaFields){
		add-SchemaFields $siteUrl $listName $fSchema
	}
	return $null
}
Function Invoke-LoadMethod() {
param( [Microsoft.SharePoint.Client.ClientObject]$Object, [string]$PropertyName )
   $ctx = $Object.Context
   $load = [Microsoft.SharePoint.Client.ClientContext].GetMethod("Load")
   $type = $Object.GetType()
   $clientLoad = $load.MakeGenericMethod($type)

   $Parameter = [System.Linq.Expressions.Expression]::Parameter(($type), $type.Name)
   $Expression = [System.Linq.Expressions.Expression]::Lambda(
			[System.Linq.Expressions.Expression]::Convert([System.Linq.Expressions.Expression]::PropertyOrField($Parameter,$PropertyName),
			[System.Object] ), $($Parameter))

   $ExpressionArray = [System.Array]::CreateInstance($Expression.GetType(), 1)
   $ExpressionArray.SetValue($Expression, 0)
   $clientLoad.Invoke($ctx,@($Object,$ExpressionArray))
}

function Get-StudentID ($siteURL,$listName,$UserName){
 $stuID = $null
 $siteName = get-UrlNoF5 $siteURL
 $ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
 $ctx.Credentials = $Credentials
 $List = $Ctx.Web.lists.GetByTitle($listName)
	

    #write-host $List.SchemaXML
	#Define the CAML Query
	$Query = New-Object Microsoft.SharePoint.Client.CamlQuery
	
	$qry = "<View><Query><Where><Eq><FieldRef Name='userName' /><Value Type='Text'>$UserName</Value></Eq></Where></Query></View>"
	#$qry = "<View><Query></Query></View>"
	$Query.ViewXml = $qry

	#Get All List Items matching the query
	$ListItems = $List.GetItems($Query)
	$Ctx.Load($ListItems)
	$Ctx.ExecuteQuery()
	
	ForEach($itm in $ListItems){
		$stuID = $itm["studentId"]
		break
	}
	return $stuID

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

$validUserListFileName = ".\Daniel\UserList.csv"
$validUserList = Import-Csv -Path $validUserListFileName
$cred = get-SCred
$heDocLibName = "העלאת מסמכים"
$enDocLibName = "Documents Upload"
 
 $MihzurSite = "https://grs2.ekmd.huji.ac.il/home/socialSciences/SOC46-2022/Archive-2023-01-30-1";
 $archiveSuffix = $MihzurSite.Split("/")[-1]
 $origSite = $MihzurSite.Substring(0,$MihzurSite.LastIndexOf("/"))
 $OrigTempl = $origSite.Substring($origSite.LastIndexOf("/")+1)

 
 
 $siteSrc = get-UrlNoF5 $MihzurSite
 $siteDst = get-UrlNoF5 $origSite

 #$schemaDocLibTempl = get-ListSchema	$siteDst "העלאת מסמכים - akiva friedman 204653638"
 #$schemaDocLibTempl | out-file $("JSON\templ.txt")
 #$sourceDocObjTempl = get-SchemaObject $schemaDocLibTempl
 #$sourceDocObjTempl | ConvertTo-Json -Depth 100 | out-file $("JSON\templ.json")

 write-host "Source URL: $siteSrc" -foregroundcolor Yellow
 write-host "Dest   URL: $siteDst" -foregroundcolor Yellow
 #write-Host "Press Any Key..."
 #read-host
 $ctxSrc = New-Object Microsoft.SharePoint.Client.ClientContext($siteSrc) 

 $ctxSrc.Credentials = $Credentials
 $webSrc = $ctxSrc.Web
	
 $ctxSrc.Load($webSrc)
 $ctxSrc.ExecuteQuery()

 Write-Host $webSrc.Title " Opened"	
 Write-Host "Get Doc Lib" -ForegroundColor Yellow
		
 $ListsSrc = $ctxSrc.Web.Lists
 $ctxSrc.Load($ListsSrc)
 $ctxSrc.ExecuteQuery()
  
 $srcUserDocLibs = @()
 $badUsers = @()
 
 ForEach($listSrc in $ListsSrc){
	if ($listSrc.Title.contains($enDocLibName) -or 
		$listSrc.Title.contains($heDocLibName)){
			$srcListItem = "" | Select Title, RootFolder,StudentID,UserName
			$srcListItem.Title = $listSrc.Title
			$srcRf = $listSrc.RootFolder
			$ctxSrc.Load($srcRf)
			$ctxSrc.ExecuteQuery()
			$userFound = $false
            forEach($usr in $validUserList){
				$xUser = $usr.UserName.Replace("\","")
				#Write-Host 61 $xUser
				#read-host
				if ($xUser.toUpper() -eq $srcRf.Name.ToUpper()){
					$userFound = $true
					$srcListItem.UserName  = $usr.UserName
					$srcListItem.StudentID = Get-StudentID $siteDst "applicants" $srcListItem.UserName
					break
				}
				
			}
			$srcListItem.RootFolder = $srcRf.Name

			if ($userFound){
				$srcUserDocLibs  += $srcListItem
			}
			if (!$userFound ){
				$badUsers += $srcListItem
			
			}

		}
	 
 }
 Write-Host $srcUserDocLibs.Count

 $userLibsJsonFile = "JSON\" + $OrigTempl+".json"
 $srcUserDocLibs | ConvertTo-Json -Depth 100 | out-file $userLibsJsonFile
 Write-Host $userLibsJsonFile " Saved"		

 $userLibsJsonFile = "JSON\BadUsers-" + $OrigTempl+".json"
 $badUsers | ConvertTo-Json -Depth 100 | out-file $userLibsJsonFile
 Write-Host $userLibsJsonFile " Saved"		

 ForEach($studLib in $srcUserDocLibs){

	$ctxDst = New-Object Microsoft.SharePoint.Client.ClientContext($siteDst) 

	$ctxDst.Credentials = $Credentials

	$ListsDst = $ctxDst.Web.Lists
	$ctxDst.Load($ListsDst)
	$ctxDst.ExecuteQuery()
			
	$isDocLibExists = $false
	$docLibTitle = $null
	ForEach($dlist in $ListsDst)
	{	
			if ($dlist.Title.contains($studLib.Title)){
				$isDocLibExists = $true
				$docLibTitle = $dlist.Title
				#write-host $list.Title -f Cyan
				break
			}	
			
	}
	
	#$isDocLibExists = Is-DocLibExists $siteDst $studLib.Title
	
	if ($isDocLibExists){
		#write-Host $docLibTitle " Exists" -f Cyan
		$DstdocLib = $ctxDst.Web.lists.GetByTitle($docLibTitle)
		$ctxDst.Load($DstdocLib)
		#$Ctx.ExecuteQuery()
		Invoke-LoadMethod -Object $DstdocLib -PropertyName "HasUniqueRoleAssignments"
		$ctxDst.ExecuteQuery()
		
		if($DstdocLib.HasUniqueRoleAssignments ){
			Write-Host -f Yellow "List $docLibTitle is already using Unique permissions!"
				
		}
		else
		{
			Write-Host -f Magenta "List $docLibTitle is using Permission inheritance!"
			
		}
		
		Copy-ContentY $siteSrc $siteDst $docLibTitle
		#write-host "Press any key..."
		#Read-Host
	}
	else
	{
		#if ($false){
		Write-Host $siteDst $studLib.Title  $studLib.StudentID -f Cyan

		create-DocLib $siteDst   $studLib.RootFolder $studLib.Title
		Add-FieldsToDocLibX $siteDst $studLib.Title
		Change-DefaultViewX  $siteDst $studLib.Title
		Change-Permissions $siteDst $studLib 
		Copy-ContentX $siteSrc $siteDst $studLib.Title
		<#
		$schemaDocLibSrc3 = get-ListSchema	$siteSrc $studLib.Title
		$sourceDocObj3 = get-SchemaObject $schemaDocLibSrc3 
		$sourceDocObj3 | ConvertTo-Json -Depth 100 | out-file $("JSON\"+$studLib.StudentID+".json")

		$objViews = Get-AllViews $studLib.Title $siteSrc
		$outFileName = "JSON\"+$studLib.StudentID+"-Views.json" 
		$objViews | ConvertTo-Json -Depth 100 | out-file $($outFileName) 
		#>
		#break
		#}
	}

	#break
	
	
 } 
