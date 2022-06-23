#         MIHZUR
function Get-SiteName($siteName){
	
	$siteUrl = get-UrlNoF5 $siteName
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
	$Ctx.Credentials = $Credentials
	
    #Get the Site from URL
    $Web = $Ctx.web
    $Ctx.Load($web)
    $Ctx.ExecuteQuery()

	return $web.title
}
function GetAllLists ($siteName) {

		Write-Host "Get All Site Lists" -ForegroundColor Yellow
		$siteUrl = get-UrlNoF5 $siteName
		$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
		$Ctx.Credentials = $Credentials
		
		$Lists = $Ctx.Web.Lists
		$Ctx.Load($Lists)
        $Ctx.ExecuteQuery()
		$listArr = @()
		
		ForEach($list in $Lists)
		{
			$listArr += $list.Title
		}
		return $listArr

}
function get-SiteGroup($siteUrl){
	$strArr = $siteUrl.Split("/")
	$retStr = $($strArr[2].ToLower().replace("2.ekmd.huji.ac.il","")+"_"+$strArr[5]).ToUpper()
	return $retStr
}
function Create-WorkingDir($groupName){
	$tmpDir = '.\_Mihzur\'+$groupName
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
function SaveSiteLists($siteObj){
	$saveDirPrefix = $siteObj.WorkingDir
	
	$listCollection = @()
		
	foreach($listName in $siteObj.siteListArr){
		$listCollItem = "" | Select Title, Path, BaseTemplate
		$listCollItem.Title = $listName
		$siteUrlC = get-UrlNoF5 $siteObj.siteURL
		$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrlC)
		$Ctx.Credentials = $Credentials
		
		$List = $Ctx.Web.lists.GetByTitle($ListName)
		$Ctx.load($List) 
		$Ctx.ExecuteQuery()
	
		$baseTemplate = $List.BaseTemplate
		if ($baseTemplate -lt 102){ # List is :GenericList =100 OR DocumentLibrary =101
			
			write-Host "$ListName    : $ListName" -f Green
			write-Host "BaseTemplate : $BaseTemplate" -f Green
			write-Host 
		
			$saveFullPath = Join-Path $saveDirPrefix $listName
			If (!(Test-Path -path $saveFullPath))
			{   
				$wDir = New-Item $saveFullPath -type directory
			}
			else
			{
				$wDir = Get-Item $saveFullPath 
			
			}
			$listCollItem.Path = $wDir.FullName
			$listCollItem.BaseTemplate = $baseTemplate
			$listCollection += $listCollItem
		}
		#Write-Host $wDir -f Green
		
	}
	$listSiteCollectFile = Join-Path $saveDirPrefix "AllList.json"
	$listCollection | ConvertTo-Json -Depth 100 | out-file $listSiteCollectFile
	write-Host "List Collection listSiteCollectFile written" -f Black -b Yellow
	foreach ($listItem in $listCollection){
		$listName = $listItem.Title
		$siteUrlC = get-UrlNoF5 $siteObj.siteURL
			
		
		$schema = get-ListSchemaFull $siteUrlC $listName
		$outSchemaFileName = Join-Path $listItem.Path $($listName+".xml")
		$schema | Out-File $outSchemaFileName -Encoding UTF8
		write-Host $outSchemaFileName -f Yellow
		
		$itemsExport = Get-ListObject $siteUrlC $listName
		$outExportCSVFile = Join-Path $listItem.Path $($listName+".csv")
		if ($itemsExport.Count -gt 0){
			$itemsExport | Export-CSV $outExportCSVFile -NoTypeInformation -Encoding UTF8
			write-Host $outExportCSVFile -f Yellow
			
		}
		if ($listItem.BaseTemplate -eq 101){
			write-Host "DocumentLibrary $($listItem.Title) found" -backgroundcolor Yellow -f black
			Save-DocLibAttachements $siteUrlC $listItem
		}		
		#read-host
		#break
		
	} 
	
}
function Save-DocLibAttachements($siteURL, $listItem){
	#write-Host 89
	#write-Host $siteUrl
	write-Host "Save List Attachements..." -f Yellow
	#write-Host 92
	
	$siteUrlC = get-UrlNoF5 $siteUrl
	$Ctx2 = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrlC)
	$Ctx2.Credentials = $Credentials

	$DocLib = $Ctx2.Web.lists.GetByTitle($listName)
	$Ctx2.load($DocLib) 
	$Ctx2.ExecuteQuery()

    $Folder = $DocLib.RootFolder
    $FilesColl = $Folder.Files
    $Ctx2.Load($FilesColl)
    $Ctx2.ExecuteQuery()
	$targetDir = Join-Path $listItem.Path "Attachements"
	#write-Host 152
	#read-host
	if ($FilesColl.Count -gt 0){
		If ((Test-Path -path $targetDir))
		{   
			Remove-Item -path $targetDir -recurse -force 
		}
		
		
		If (!(Test-Path -path $targetDir))
		{   
			$wDir = New-Item $targetDir -type directory
		}
		else
		{
			$wDir = Get-Item $targetDir 
			
		}
		Get-ChildItem $targetDir  -Include *.* -Recurse |  ForEach  { $_.Delete()}	
			
	}	
	Foreach($File in $FilesColl)
    {
		
        $TargetFile = Join-Path $targetDir  $File.Name
		$FileInfo = [Microsoft.SharePoint.Client.File]::OpenBinaryDirect($Ctx2,$File.ServerRelativeURL)
		$WriteStream = [System.IO.File]::Open($TargetFile,[System.IO.FileMode]::Create)
		$FileInfo.Stream.CopyTo($WriteStream)
		$WriteStream.Close()
		write-Host $TargetFile -f Cyan
 	
	}
	#write-Host 165
	#read-host
		
}
function Get-ListObject($siteURL, $listName){
	#write-Host 89
	#write-Host $siteUrl
	write-Host "Export List $listName" -f Yellow
	#write-Host 92
	
	$siteUrlC = get-UrlNoF5 $siteUrl
	$Ctx1 = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrlC)
	$Ctx1.Credentials = $Credentials

	$List = $Ctx1.Web.lists.GetByTitle($listName)
	$Ctx1.load($List) 
	$Ctx1.ExecuteQuery()
	
	#Define the CAML Query
	$Query = New-Object Microsoft.SharePoint.Client.CamlQuery
	$qry = "<View><Query></Query></View>"
	$Query.ViewXml = $qry
	$ListItems = $List.GetItems($Query)
	$listFields = $List.Fields
	$Ctx1.load($listFields) 
	$Ctx1.Load($ListItems)
	$Ctx1.ExecuteQuery()
	#$listFields | gm
	$listOfIds = @()
	#Get All List items
	$ListItems | ForEach {
		
		
		$ItemId = $_["ID"]
		$listOfIds	+= $ItemId
	}
	$ListItemCollection = @()
    foreach($idItm in $listOfIds){	
		write-host "Processing Item ID: $idItm"
		$ListItem = $List.GetItemById($idItm)
		$Ctx1.Load($ListItem)
		$Ctx1.ExecuteQuery()
		
		$ListItemFieldValues = $ListItem.FieldValuesAsText
		$Ctx1.Load($ListItemFieldValues)
		$Ctx1.ExecuteQuery()		
		
		$ExportItem = New-Object PSObject
		#Get Each field
		foreach($Field in $listFields)
		{
			$isHiddenField = $($Field.Hidden)
			if (!$isHiddenField){
				$internalName = $Field.InternalName
				$fieldName = $Field.Title
				$fieldValue   = $ListItemFieldValues[$internalName]
				$readOnly     = $Field.ReadOnlyField
				$typeDisplayName = $Field.TypeDisplayName
				$typeAsString = $Field.TypeAsString
				$fieldType = "N/A"
				if (-not [string]::isNullorempty($fieldValue)){
					
					$fieldType = $ListItemFieldValues[$Field.InternalName].GetType().Name		
				}
				#Write-Host "Name : $fieldName"
				<#
				Write-Host "-------------------------"
				Write-Host "InternalName : $internalName"
				Write-Host "Name : $fieldName"
				#Write-Host "Hidden : $($Field.Hidden)"
				Write-Host "ReadOnly : $readOnly"
				Write-Host "Type: $fieldType"
				Write-Host "typeDisplayName: $typeDisplayName"
				Write-Host "typeAsString: $typeAsString"
				Write-Host "Value : $fieldValue"
				write-Host
				#>
				#write-Host 180
				#write-Host $Field 
				
				
				#$ExportItem | Add-Member -MemberType NoteProperty -name $internalName -value $fieldValue
                if($fieldName -eq 'Title'){
					$fieldName = $internalName
				}
				if($fieldName -eq 'Name'){
					$fieldName = $internalName
				}					
				$ExportItem | Add-Member -MemberType NoteProperty -name $fieldName -value $fieldValue # -Force
			}
			
		}
		
		#Add the object with property to an Array
		$ListItemCollection += $ExportItem
		#break

	}
	
    return $ListItemCollection

}
function get-ListSchemaFull($siteURL,$listName){
	
	$fieldsSchema = @()
	$fieldsSchema += "<Fields>"
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
	$fieldsSchema += "</Fields>"
	return $fieldsSchema

}
