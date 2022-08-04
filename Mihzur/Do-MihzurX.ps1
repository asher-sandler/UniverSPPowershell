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
		$pageFile = $spWeb.GetFile($pageFullName)
		$pubWeb =[Microsoft.SharePoint.Publishing.PublishingWeb]::GetPublishingWeb($spWeb)
		$pubWeb.DefaultPage = $pageFile
		$pubWeb.Update();
		$spweb.Update()
	}

 
}
function get-FrendlyDate($dtNow){
	$dtNowS = $dtNow.Year.ToString() + "-" +$dtNow.Month.ToString().PadLeft(2,"0") + "-"+$dtNow.Day.ToString().PadLeft(2,"0") + " " + $dtNow.Hour.ToString().PadLeft(2,"0")+":"+$dtNow.Minute.ToString().PadLeft(2,"0")+":"+$dtNow.Second.ToString().PadLeft(2,"0")
	return 	$dtNowS
}
function get-FrendlyDateLog($dtNow){
	$dtNowS = $dtNow.Year.ToString() + "-" +$dtNow.Month.ToString().PadLeft(2,"0") + "-"+$dtNow.Day.ToString().PadLeft(2,"0") + "-" + $dtNow.Hour.ToString().PadLeft(2,"0")+"-"+$dtNow.Minute.ToString().PadLeft(2,"0")+"-"+$dtNow.Second.ToString().PadLeft(2,"0")
	return 	$dtNowS
}
function get-ArchiveDate($dtNow){
	$dtNowS = $dtNow.Year.ToString() + "-" +$dtNow.Month.ToString().PadLeft(2,"0") + "-"+$dtNow.Day.ToString().PadLeft(2,"0") 
	return 	$dtNowS
}
function get-ReportDate($dtNow){
	$dtNowS = $dtNow.Day.ToString().PadLeft(2,"0") + "."+ $dtNow.Month.ToString().PadLeft(2,"0") + "." + $dtNow.Year.ToString() + " "  + $dtNow.Hour.ToString().PadLeft(2,"0")+":"+$dtNow.Minute.ToString().PadLeft(2,"0")
	return 	$dtNowS
}
function get-SiteGroup($siteUrl){
	$strArr = $siteUrl.Split("/")
	$retStr = $($strArr[2].ToLower().replace("2.ekmd.huji.ac.il","").replace(".ekmd.huji.ac.il","")+"_"+$strArr[5]).ToUpper()
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
function Create-ListOnArchiveFromTemplate($archivesite,$listItm){
	$listCreated = $false
	$TemplateName=$listItm.templateFileName+".stp"
	$listName = $listItm.Title
	$archiveWeb = get-SPWeb $archivesite.URL
	if ([string]::IsNullOrEmpty($archiveWeb.Lists[$listName])){ # List does not exists
		$Template = $archiveWeb.site.GetCustomListTemplates($archiveWeb) | where {$_.InternalName -match $TemplateName }

		#Check if given template name exists!
		if($Template -eq $null){
			Write-host "Specified list template '$TemplateName' not found!" -f Red
		}
		else{
			#Create list using template in sharepoint 2013
			Write-host "New List $listName Creating from Custom List template" -f Green

			$archiveWeb.Lists.Add($listName, $listName, $Template) | Out-Null
			$listCreated = $true
			#write-host 51
			#write-host ...
			#read-host
		}
	}
	else
	{
	   write-host "List $listName already exists" -f Yellow
	}
    return $listCreated	
}
function saveListTemplate($spWeb,$itm){
	$TemplateName=$itm.templateFileName
	$TemplateFileName=$itm.templateFileName
	$TemplateDescription=$itm.templateFileName
	$SaveData = $true
 
	$List = $spWeb.Lists[$itm.Title]
	try{
		# https://gss2.ekmd.huji.ac.il/home/_catalogs/lt/Forms/AllItems.aspx
		$List.SaveAsTemplate($TemplateFileName, $TemplateName, $TemplateDescription, $SaveData)
		#start-sleep 5
		Write-Host "List $($itm.Title) Saved as Template $TemplateFileName" -f Green

	}
	catch
	{
		Write-Host "Template $TemplateFileName already exists"	-f Yellow	
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
function deleteListTemplateSingle($SiteURL,$ListTemplateName){
	$spSite = Get-SPSite $SiteURL
	$ListTemplateFolder = $spSite.RootWeb.GetFolder("_catalogs/lt")
	$ListTemplates =  $ListTemplateFolder.Files
	#$listSiteCollectFile = Join-Path $wDir "Templates.json"
	#$ListTemplates | ConvertTo-Json -Depth 1 | out-file $listSiteCollectFile
	
	$templatesCollection = $ListTemplateFolder.Files | Where-Object { $_.Name -eq $ListTemplateName+'.stp' }
	
	foreach($ListTemplate in $templatesCollection){
		$ListTemplate.delete()
		#To permanently delete, call: $ListTemplate.delete();
		write-host "Deleted List template $ListTemplate" -f Yellow
	
	}

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
function Create-NewArchiveSubSite($spWeb,$newSubSiteObj){
	$siteTitle = $newSubSiteObj.Title
	$langID = $spWeb.Language
	$siteDescription  = "Archive site for date " + $newSubSiteObj.ArchiveDate+"."
	$siteURL  = $spWeb.URL+"/"+$newSubSiteObj.Title+"/"
	$webTemplate = "STS#0" #Team Site template	
	$subSite = New-SPWeb -Name $siteTitle -Description $siteDescription -Url $siteURL -Template $webTemplate -Language $langID # -AddToTopNav $false -UniquePermissions $false -UseParentTopNav $false

 
	return $subSite
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
function Change-Theme ( $siteURL)
{
	$validThemes = "Sea Monster","Nature","Blossom","Sketch","City","Orbit","Characters","Breeze","Immerse","Wood"

	$spWeb = Get-SPWeb $siteURL
	$designCatalog = $spWeb.Site.GetCatalog("Design")
	$random = get-random -Minimum 0 -Maximum $($validThemes.Count-1)
	$ApplyiedTheme = $validThemes[$random]
	write-Host "Apply Theme: $ApplyiedTheme"
	$theme = $designCatalog.Items | Where{$_.Name -eq $ApplyiedTheme}
	$spweb.ApplyTheme($theme["ThemeUrl"].Split(",")[1].Trim(), $null, $theme["ImageUrl"].Split(",")[1].Trim(), $true) 

	#$theme = $designCatalog.Items | Where{$_.Name -eq "Immerse"}
	#$theme = $designCatalog.Items | Where{$_.Name -eq "Sea Monster"}
	#$theme = $designCatalog.Items | Where{$_.Name -eq "Nature"}
	#$theme = $designCatalog.Items | Where{$_.Name -eq "Blossom"}
	#$theme = $designCatalog.Items | Where{$_.Name -eq "Sketch"}
	#$theme = $designCatalog.Items | Where{$_.Name -eq "City"}
	#$theme = $designCatalog.Items | Where{$_.Name -eq "Orbit"}
	#$theme = $designCatalog.Items | Where{$_.Name -eq "Characters"}
	#$theme = $designCatalog.Items | Where{$_.Name -eq "Immerse"}
	#$theme = $designCatalog.Items | Where{$_.Name -eq "Wood"}
	
<#
Sea Monster+
Nature /green/
Blossom /rose/
Sketch+  
City	/black/
Orbit  /black/
Characters
Breeze+
Immerse
Wood
#>

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
function downloadListTemplate($SiteURL,$templfName, $wDirName){
	$spSite = Get-SPSite $SiteURL
	$ListTemplateFolder = $spSite.RootWeb.GetFolder("_catalogs/lt")
	$ListTemplates =  $ListTemplateFolder.Files
	$templFileName = $templfName+".stp"
	$templatesCollection = $ListTemplateFolder.Files | Where-Object { $_.Name -eq $templFileName }
	foreach($listTemplate in $templatesCollection){
		write-host "Found template $listTemplate" -f Cyan
		$FilePath= Join-Path $wDirName $listTemplate.Name 
		$Data = $listTemplate.OpenBinary()
		[System.IO.File]::WriteAllBytes($FilePath, $Data) | out-null
		write-host $FilePath -f Cyan
	
	}	
}
function replace-STP($lookUpSTPFile, $replArr){
	$tmpDir = Join-Path $lookUpSTPFile.Directory "ExtractCab"
	If (!(Test-Path -path $tmpDir))
	{   
		$wDir = New-Item $tmpDir -type directory
	}
	else
	{
		$wDir = Get-Item $tmpDir 
		
	}
	Start-Sleep 5
	[system.gc]::Collect()
	Get-ChildItem $wDir -Include *.* -Recurse |  ForEach  { $_.Delete()}
	copy-Item $lookUpSTPFile $wDir 
	$tmpItem = Get-Item $(Join-Path $wDir $lookUpSTPFile.Name)
	<#
	write-host 165 -f Cyan
	write-host $wdir
	write-host $tmpItem
	write-host $lookUpSTPFile -f Cyan
	#>
	$curDir = Get-Location
	Set-Location $wDir
	write-host "Extrac32.exe $($tmpItem.FullName) "
	# expand GSS_HUM16-2020-2022-07-08-17-58-35-Submitted.cab -F:manifest.xml .\
	Extrac32.exe $tmpItem.FullName 
	Start-Sleep 2
	Set-Location $curDir
	
	$manFileName =  $(Join-Path $wDir "manifest.xml")
	
	
	$manifestFile = Get-Content $manFileName  -raw -Encoding UTF8
	foreach($rItm in $replArr){
		write-host "Replace $($rItm.oldListID)"
		write-host "To $($rItm.newListID)"
		$manifestNew = $manifestFile -Replace $rItm.oldListID, $rItm.newListID
		$manifestFile = $manifestNew
		#write-host $rItm -f Cyan
	}
	$manifestNew = $manifestFile
	$manifestNew | Out-File $manFileName -Encoding UTF8
	write-host "Delete File: $($tmpItem.FullName)"
	Remove-Item $($tmpItem.FullName)
	Start-Sleep 2
	write-host ".\Utils\MakeCab $manFileName $($tmpItem.FullName)"
	.\Utils\MakeCab $manFileName $tmpItem.FullName | Out-Null
	Start-Sleep 2
	#write-host 205
	#read-host		
	return $tmpItem
}
function addListTemplate($SiteURL,$templateName){
	
	$spSite = Get-SPSite $SiteURL
	$ListTemplateFolder = $spSite.RootWeb.GetFolder("_catalogs/lt")
	$ListTemplates =  $ListTemplateFolder.Files
	$listTemplateName = $templateName.Name
	write-host "64: $listTemplateName" -f Cyan
	#$listSiteCollectFile = Join-Path $wDir "Templates.json"
	#$ListTemplates | ConvertTo-Json -Depth 1 | out-file $listSiteCollectFile
	
	$templatesCollection = $ListTemplateFolder.Files | Where-Object { $_.Name -eq $ListTemplateName }
	if (!$templatesCollection){
		write-host "Template $ListTemplateName not Found" -f Cyan
		$ListTemplateFolder.Files.Add($ListTemplateName,$templateName.Open('Open', 'Read', 'Read') ,$true)
	}
	
	return $null
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
function Copy-SubmittedX($srcSite, $dstSite,$langID){
	$srcweb = get-SPWeb $srcSite
	$applList = $srcweb.Lists['Applicants']
	$applItems = $applList.Items
	$applItemscount = $applItems.Count 
	write-Host "Applicants items count : $applItemscount"
	$maxCount = 10000
	$cnt =0
	foreach($applItem in $applItems){
		
		
		$docfolder = [string]$applItem['documentsCopyFolder']
		if (![string]::isNullOrEmpty($docfolder)){
			#write-Host $cnt
			$firstPart = $docfolder.Split(",")[0].Trim()
			$secondPart = $firstPart.Split("/")
			$submitfolder = $secondPart[-2]+"/"+$secondPart[-1]
			do-Submitted $srcSite $dstSite $langID $submitfolder
			write-Host $submitfolder
		}
		$cnt++
		if ($cnt -ge $maxCount){
			write-Host "$cnt Rows was readed"
			break
			
		}
	}
	
	
	change-DefView $srcSite $dstSite "Submitted"
	
}
function change-DefView($srcSite, $dstSite,$docLibName){
	
	write-host $srcSite
	write-host $dstSite
	write-host $docLibName
	
	$dstweb = get-SPWeb $dstSite
	$dstList = $dstweb.Lists[$docLibName]
	#$dstFolder 	   = $dstweb.GetFolder($dstList.RootFolder.Url)
	
	$srcweb = get-SPWeb $srcSite
	$srcList = $srcweb.Lists[$docLibName]
	write-host "change Default View of $docLibName"
	<#
	$dstList.DefaultView.Query = $srcList.DefaultView.Query
	$dstList.DefaultView.Update()
	$dstList.Update()
	#>
	
	$dstDefView = $dstList.DefaultView
	$vwFields =  @()
	$vwFields += "Edit"
	foreach($fld in $dstDefView.ViewFields)
	{
		$vf = $fld 
		if ($vf -eq "Modified"){
			Continue
		}
		if ($vf -eq "Edit"){
			Continue
		}
		
		
		$vwFields += $vf
	}

	$dstDefView.ViewFields.DeleteAll();
	foreach($xF in $vwFields){
		$dstDefView.ViewFields.Add($xF)	
	}
	#write-Host $srcList.DefaultView.Query
	$dstDefView.Query = $srcList.DefaultView.Query
	$dstDefView.Update()
	
	$dstList.Update()
	
	
	

	
}
function do-Submitted($srcSite, $dstSite,$langID,$sFolder){
	$docLibName = "Submitted"
	$dstweb = get-SPWeb $dstSite
	$dstList = $dstweb.Lists[$docLibName]
	$dstFolder 	   = $dstweb.GetFolder($dstList.RootFolder.Url)
	
	$srcweb = get-SPWeb $srcSite
	$srcList = $srcweb.Lists[$docLibName]
	$srcFolder 	   = $srcweb.GetFolder($srcList.RootFolder.Url)

	$srcDocTypeFieldName = "Document Type"
	if ($langID -eq 1037){
		$srcDocTypeFieldName = "תוכן קובץ"
	}
	
    #$subFolders = $srcList.Folders
	$srcFolder 	   = $srcweb.GetFolder($sFolder)
	
	$fldDateCreat = $srcFolder.Item["Created" ]
	$fldDateEdit  = $srcFolder.Item["Modified"]
	$fldWhoCreat  = $srcFolder.Item["Author"  ]
	$fldWhoEdit   = $srcFolder.Item["Editor"  ]
	$fldDescr     = $srcFolder.Item["description"]
	
	write-Host $srcFolder.Name
	write-Host $fldDateCreat
	write-Host $fldDateEdit
	write-Host $fldWhoCreat
	write-Host $fldWhoEdit
	write-Host $fldDescr
	write-host --------------
	$folder = $dstList.ParentWeb.GetFolder($dstList.RootFolder.Url + "/" +$srcFolder.Name);
	
	If(!$folder.Exists)
	{
	   #Create a Folder
	   $folder = $dstList.AddItem([string]::Empty, [Microsoft.SharePoint.SPFileSystemObjectType]::Folder, $srcFolder.Name)
	   $folder.Update();
	   # write-host "Created Folder '$fldNew'" -f Green
	}

	$folder = $dstList.ParentWeb.GetFolder($dstList.RootFolder.Url + "/" +$srcFolder.Name);

	$folder.Item["Created" ] = $fldDateCreat
	$folder.Item["Modified"] = $fldDateEdit		
	$folder.Item["Author"  ] = $fldWhoCreat		
	$folder.Item["Editor"  ] = $fldWhoEdit	
	$folder.Item["description"] = $fldDescr	
	$folder.Item.Update()
	
	foreach($sFile in $srcFolder.Files)
	{
		$srcDocTypeValue = new-object Microsoft.SharePoint.SPFieldLookupValue($sFile.Item[$srcDocTypeFieldName] )
		$srcDocTypeValue = $srcDocTypeValue.LookupValue
		$srcDateCreat = $sFile.Item["Created" ]
		$srcDateEdit  = $sFile.Item["Modified"]
		$srcWhoCreat  = $sFile.Item["Author"  ]
		$srcWhoEdit   = $sFile.Item["Editor"  ]
		$srcDescription  = $sFile.Item["description"]
		
		$srcData = $sFile.OpenBinary()
		$fileName = $dstList.RootFolder.Url + "/"+$srcFolder.Name + "/" + $sFile.Name
		Write-host -f Yellow $fileName

		$dstFile = $dstFolder.Files.Add($fileName,$srcData,$true)
		$newDocTypeID = Map-DocType $dstSite $srcDocTypeValue 
		
		$dstFile.Item["Created" ] = $srcDateCreat
		$dstFile.Item["Modified"] = $srcDateEdit
		$dstFile.Item["Author"  ] = $srcWhoCreat
		$dstFile.Item["Editor"  ] = $srcWhoEdit
		$dstFile.Item["description"]  = $srcDescription
		#               description
		$dstFile.Item[$srcDocTypeFieldName] = $newDocTypeID
		$dstFile.Item.Update()
		
	}
	$dstList.Update()


	return $null
	
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
		Write-host -f Yellow $sFile.Name
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
	
	write-host "change Default View of $docLibNam"
	$dstList.DefaultView.Query = $srcList.DefaultView.Query
	$dstList.DefaultView.Update()

	<#	
	$dstDefView = $dstList.DefaultView
	$vwFields =  @()
	$vwFields += "Edit"
	foreach($fld in $dstDefView.ViewFields)
	{
		$vf = $fld 
		$vwFields += $vf
	}

	$dstDefView.ViewFields.DeleteAll();
	foreach($xF in $vwFields){
		$dstDefView.ViewFields.Add($xF)	
	}
	$dstDefView.Update()
	#>
	$dstList.Update()
	return $null
	
}

function CopyDocLib($srcSite, $dstSite , $langID, $docLibName ){
	#write-host 343
	#write-host $srcSite -f Yellow
	#write-host $dstSite -f Cyan
	#write-host $langID
	#write-host $docLibName -f Green
	# Aaron Levyvalensi
	$srcDocTypeFieldName = "Document Type"
	if ($langID -eq 1037){
		$srcDocTypeFieldName = "תוכן קובץ"
	}
	$dstweb = get-SPWeb $dstSite
	$dstList = $dstweb.Lists[$docLibName]
	$dstFolder 	   = $dstweb.GetFolder($dstList.RootFolder.Url)
	#write-host "Destination Folder: $($dstList.RootFolder.Url)"
	
	$srcweb = get-SPWeb $srcSite
	$srcList = $srcweb.Lists[$docLibName]
	$srcFolder 	   = $srcweb.GetFolder($srcList.RootFolder.Url)
	#write-host "Source Folder: $($srcList.RootFolder.Url)"

	foreach($sFile in @($srcFolder.Files)){
		#$oldFile.Recycle() | Out-Null
		#$fileName = $sFile.ServerRelativeURL.Split("/")[-1]
		Write-host -f Yellow $sFile.Name
		$srcDocTypeValue = new-object Microsoft.SharePoint.SPFieldLookupValue($sFile.Item[$srcDocTypeFieldName] )
		$srcData = $sFile.OpenBinary()
		#$srcDocTypeID = $srcDocTypeValue.LookupId
		$srcDocTypeValue = $srcDocTypeValue.LookupValue

		$srcDateCreat = $sFile.Item["Created" ]
		$srcDateEdit  = $sFile.Item["Modified"]
		$srcWhoCreat  = $sFile.Item["Author"  ]
		$srcWhoEdit   = $sFile.Item["Editor"  ]
		$srcResponse  = $sFile.Item["sentResponse"]
		
		
		#$dstfolder =  $dstweb.getfolder($dstList.RootFolder.Url)
		#$dstfolderURL =  $dstList.RootFolder.Url
		#$dstfileName = $dstfolder  + "/"+ $fileName
		#$dstfileName = $fileName
		#write-Host $dstfileName
		#write-host $srcDocTypeID
		#write-host $srcDocTypeValue
		$newDocTypeID = Map-DocType $dstSite $srcDocTypeValue 
		$dstFile = $dstFolder.Files.Add($sFile.Name,$srcData,$true)

		write-host "srcDateCreat : $srcDateCreat"
		write-host "srcDateEdit  : $srcDateEdit"
		write-host "srcWhoCreat  : $srcWhoCreat"
		write-host "srcWhoEdit   : $srcWhoEdit"
		
		$dstFile.Item["Created" ] = $srcDateCreat
		$dstFile.Item["Modified"] = $srcDateEdit
		$dstFile.Item["Author"  ] = $srcWhoCreat
		$dstFile.Item["Editor"  ] = $srcWhoEdit
		$dstFile.Item["sentResponse"] = $srcResponse
		$dstFile.Item[$srcDocTypeFieldName] = $newDocTypeID

		$dstFile.Item.Update()
	}
	write-host "change Default View of DocLib"
		
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
function Get-DocTypeSchema($dstweb, $languageID){
	$parentList = $dstweb.Lists['DocType']
	$FieldID = New-Guid
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
	$lookUpDocTypeSchema = "<Field Type='Lookup' ID='{$FieldID}' DisplayName='$DisplayName' Name='$Name' Description='$Description' Required='$IsRequired' EnforceUniqueValues='$EnforceUniqueValues' List='$LookupListID' WebId='$LookupWebID' ShowField='$LookupField' />"
    return 	$lookUpDocTypeSchema
}
function get-PageContent($siteURL, $PageName, $pageField){
	$spWeb = Get-SPWeb $siteURL
	write-Host $siteURL
	
    $pageFullName = "Pages/" + $PageName + ".aspx"
	write-Host $pageFullName
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
Add-PsSnapin Microsoft.SharePoint.PowerShell
$dtNow = Get-Date

$dtNowStrLog 	= get-FrendlyDateLog 	$dtNow
$dtNowStr 		= get-FrendlyDate 		$dtNow

$logFile = "AS-Mihzur-01-"+$dtNowStrLog+".log"
$logFile = "AS-Mihzur-01.log"
Start-Transcript $logFile

Add-PsSnapin Microsoft.SharePoint.PowerShell

$cultureHE = [System.Globalization.CultureInfo]::CreateSpecificCulture("he-IL")
$cultureEN = [System.Globalization.CultureInfo]::CreateSpecificCulture("en-US") 


$srcSiteUrl   = "https://grs.ekmd.huji.ac.il/home/Education/EDU63-2022/"

$script=$MyInvocation.InvocationName

$asherTest = $true
#$asherTest = $false
if ($asherTest){
	
	#$srcSiteUrl   = "https://gss.ekmd.huji.ac.il/home/Humanities/HUM16-2020/"
	#$srcSiteUrl   = "https://gss2.ekmd.huji.ac.il/home/FacultyofMedicine/MED18-2019/"
	#$srcSiteUrl   = "https://gss2.ekmd.huji.ac.il/home/FacultyofMedicine/MED15-2017/"
	$srcSiteUrl   = "https://gss2.ekmd.huji.ac.il/home/OverseasApplicantsUnit/GEN27-2020/"
	#$srcSiteUrl   = "https://gss.ekmd.huji.ac.il/home/SocialSciences/SOC24-2019"
	
}

$webservice = [Microsoft.SharePoint.Administration.SPWebService]::ContentService
Write-Host "Template Max Size: " $webservice.MaxTemplateDocumentSize
$webservice.MaxTemplateDocumentSize = 500Mb 
$webservice.Update()


$group = get-SiteGroup $srcSiteUrl
$templateName = $group + "-"+$dtNowStrLog 
$templSavedPath = "SavedTemplates"

$homeweb = Get-SPWeb  $srcSiteUrl
$languageID = $spWeb.Language 

$heDocLibName = "העלאת מסמכים"
$enDocLibName = "Documents Upload"

# for very large sites if doclib count is huge setting limit of records to process
# if 0 (zero) no limit.
$progressRecordsLimit = 100


write-host
write-host "Script For Mihzur version 2022-07-20.1"           #$logFileName
write-host "Asher Sandler	: mailTo:AsherSa@ekmd.huji.ac.il"           #$logFileName
write-host "Site to Archive	:  <$srcSiteUrl>"           #$logFileName
write-host "Language ID		:  <$languageID>"           #$logFileName
write-host "Site Group 		:  <$group>"           #$logFileName
write-host "Start time		:  <$dtNowStr>"           #$logFileName
write-host "User			:  <$whoami>"        #$logFileName
write-host "Running ON		:  <$ENV:Computername>" #$logFileName
write-host "Script file		:  <$script>"        #$logFileName
write-host "Log file		:  <$logFile>"        #$logFileName


 
 $newArchiveObj= Get-NextArchiveSubSiteObj $homeweb
 write-host "Creating new Archive Subsite $($newArchiveObj.Title)" 
 $archSubSite = Create-NewArchiveSubSite $homeweb $newArchiveObj
 $featActivated = Activate_PublishingFeature  $archSubSite.URL
 if ($featActivated){
	write-host "Publishing Feature was Activated" -f Green
 }
 else{
	write-host "Publishing Feature was NOT Activated" -f Yellow
 }
 write-host "Archive site was Created $($archSubSite.URL)" -f Yellow
 
 $siteObj = "" | Select SiteURL, SiteName, SiteSaveDirectory,WorkingDir,siteListArr
 $siteObj.SiteURL  = $srcSiteUrl
 $siteObj.SiteName = $homeweb.Title
 $siteObj.SiteSaveDirectory =  $group
 $siteObj.workingDir = Create-WorkingDir $siteObj.SiteSaveDirectory
 # List is :GenericList =100 OR DocumentLibrary =101

 write-host 
 write-host "Collecting Information About Lists and Document Library on Source Web" -f Yellow
 write-host "=====================================================================" -f Yellow
 $tmpListArr =  $homeweb.Lists | Select Title,RootFolder, BaseTemplate,ID,Fields | Where {$_.BaseTemplate -lt 102} 
 $realListArr = @()
 $listCount = $tmpListArr.Count
 $listCollectingProgress = 0
 foreach($tlArr in $tmpListArr){
	 
	 $tmplFName = $templateName + "-" + $tlArr.Title
	 $newListArrItem ="" | Select Title, RootFolder, BaseTemplate,templateFileName,UIDOld,UIDNew,IsLookupField, Done
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
	 $newListArrItem.Done=$false
	 
	 $realListArr += $newListArrItem 
	 $listCollectingProgress++ 
	 $Completed = [math]::Round(($listCollectingProgress/$listCount*100),0)
	 if ($($Completed % 10) -eq 0){
		 write-Host $Completed "%"
	 }
	 #Write-Progress -Activity "Collecting Lists" -Status "Progress:" -PercentComplete $Completed
	 #write-host "Progress : $listCollectingProgress of $listCount % $Completed" -f Yellow
 }
  write-host "Collecting Complete" -f Yellow

 $siteObj.siteListArr =  $realListArr
 $checkPages = $true
 if (!$checkPages){
 deleteListTemplate	$homeweb.Site.Url $group #$siteObj.workingDir		

 write-host
 write-host "Saving  Lists without Lookup Fields template to Site" -f Yellow
 write-host "====================================================" -f Yellow

 foreach($listO in $siteObj.siteListArr){
	$finalOrSubmitted = (($listO.Title -eq "Final") -or ($listO.Title -eq "Submitted"))
	if ($finalOrSubmitted){
		continue
	}	 
	$docLib = $(($listO.BaseTemplate -eq 101) -and 
			  ($listO.Title.Contains($heDocLibName) -or $listO.Title.Contains($enDocLibName)))
	$tableWithLookupFields = $($listO.IsLookupField.isLookup)		  
		
	if (!$tableWithLookupFields -and !$docLib){
		saveListTemplate $homeweb $listO
	}
			
			
 }
 [system.gc]::Collect()

 write-host
 write-host "Creating Lists without Lookup Fields on destination Web from templates on Site" -f Yellow
 write-host "==============================================================================" -f Yellow

 foreach($listO in $siteObj.siteListArr){
	$finalOrSubmitted = (($listO.Title -eq "Final") -or ($listO.Title -eq "Submitted"))
	if ($finalOrSubmitted){
		continue
	}	 
	$tableWithLookupFields = $($listO.IsLookupField.isLookup)
	$ordinalList = $($listO.BaseTemplate -eq 100)
	$docLib = $(($listO.BaseTemplate -eq 101) -and 
				  ($listO.Title.Contains($heDocLibName) -or $listO.Title.Contains($enDocLibName)))

	# first create Lists without Lookup Fields
	if (!$tableWithLookupFields){
		if ($ordinalList -or -not $docLib){
			
			write-host -------------------
			write-host $listO.Title
		    $listO.Done = Create-ListOnArchiveFromTemplate $archSubSite $listO
			
			$listO.UIDNew =  Get-ListID $archSubSite.Url $listO.Title
			
		}
	}
  }
  
  #write-host 416
  #read-host
 write-host
 write-host "Deleting unnecessary Templates on Site" -f Yellow
 write-host "======================================" -f Yellow
  
 deleteListTemplate	$homeweb.Site.Url $group #$siteObj.workingDir		

 $wDir = Create-TemplateDir $templSavedPath

 write-host
 write-host "Saving and Download Lists with Lookup Fields template to Site" -f Yellow
 write-host "=============================================================" -f Yellow

	foreach($listO in $siteObj.siteListArr){
	 #if ($listO.Title -eq"applicants"){
		$tableWithLookupFields = $($listO.IsLookupField.isLookup)
		$ordinalList = $($listO.BaseTemplate -eq 100)
		$finalOrSubmitted = (($listO.Title -eq "Final") -or ($listO.Title -eq "Submitted"))
		if ($finalOrSubmitted){
			continue
		}
		# create Lists with Lookup Fields
		if ($tableWithLookupFields -and $ordinalList){
					
			write-host -----save List Template------
			write-host $listO.Title
			
			saveListTemplate $homeweb $listO
			downloadListTemplate $archSubSite.Site.Url $listO.templateFileName  $wDir.FullName
			
		}
	} 
#start-sleep 10
 write-host
 write-host "Creating Lists WITH Lookup Fields on destination Web from template in Site" -f Yellow
 write-host "==========================================================================" -f Yellow
 write-host
 write-host "Saving STP file, Extract Manifest.xml, Replace in Manifest.XML" -f Yellow
 write-host "for Lookup fields List ID for New List Previously Created on Destination Web" -f Yellow
 write-host "Pack to CAB file, rename CAB, Saving on Site as Template and" -f Yellow
 write-host "Creating List on web from Template on Site" -f Yellow

 foreach($listO in $siteObj.siteListArr){
	 #if ($listO.Title -eq"applicants"){
		$tableWithLookupFields = $($listO.IsLookupField.isLookup)
		$ordinalList = $($listO.BaseTemplate -eq 100)
		# create Lists with Lookup Fields
		if ($tableWithLookupFields -and $ordinalList){
			write-host -------------------
			write-host $listO.Title
			
			#saveListTemplate $homeweb $listO
			#$listName = $listO.Title
			#downloadListTemplate $archSubSite.Site.Url $listO.templateFileName  $wDir.FullName
			$lookUpSTPFile  = Get-Item $(Join-Path $wDir.FullName  $($listO.templateFileName + ".stp"))
			write-host $lookUpSTPFile
			$replArr = @()
			foreach($field in $listO.IsLookupField.FieldArr){
				$lookupListName = $field.SourceListTitle
				if (![string]::IsNullOrEmpty($lookupListName)){
					$oldListID = $field.SourceListID
					$newListID = Get-ListID $archSubSite.Url $lookupListName
					if (![string]::IsNullOrEmpty($newListID)){
						$replArrItm = "" | Select oldListID,newListID
						$replArrItm.oldListID = $oldListID
						$replArrItm.newListID = "{"+$newListID+"}"
						$replArr += $replArrItm
					}
				}
			}
			write-host 439
			#read-host	
            #if ($replArr.Count -gt 0){			
			$newSTPFile = replace-STP $lookUpSTPFile $replArr
			#}
			write-host 442
			write-host $newSTPFile
			#read-host
			deleteListTemplateSingle	$homeweb.Site.Url $listO.templateFileName
			write-host 449
			write-host $($listO.templateFileName)
			#read-host
			
			$uplTempl = addListTemplate $archSubSite.Site.Url $newSTPFile
			write-host 446
			#read-host			
			
			$listO.Done = Create-ListOnArchiveFromTemplate $archSubSite $listO

		}
	 #}
  }
  
  write-host
  write-host "Creating Documents Library for Users with metadata and Copying files From Source To Destination" -f Yellow
  write-host "===============================================================================================" -f Yellow
  $countRecords = 0
  foreach($listO in $siteObj.siteListArr){
		$docLib = $(($listO.BaseTemplate -eq 101) -and 
				  ($listO.Title.Contains($heDocLibName) -or $listO.Title.Contains($enDocLibName)))
		if ($docLib){
			write-host -------------------
			write-host $listO.Title
			$externalListName = $listO.Title
			$innerListName = $listO.RootFolder
			$archSubSite.Lists.Add($innerListName, $externalListName, "DocumentLibrary")

			$dstweb = Get-SPWeb $archSubSite.Url
			$docLib = $dstweb.Lists[$innerListName]
			$docLib.Title = $externalListName
			$docLib.Update()
			$docLib.TitleResource.SetValueForUICulture($cultureHE, $externalListName)
			$docLib.TitleResource.SetValueForUICulture($cultureEN, $externalListName)
			$docLib.TitleResource.Update()	

			
            $docTypeSchema = Get-DocTypeSchema	$dstweb $languageID		
			$newField = $docLib.Fields.AddFieldAsXml($docTypeSchema, $True,[Microsoft.SharePoint.SPAddFieldOptions]::AddFieldToDefaultView)
			$sentResponseSchema = '<Field Type="Boolean" DisplayName="sentResponse" EnforceUniqueValues="FALSE" Indexed="FALSE"  StaticName="sentResponse" Name="sentResponse" ><Default>0</Default></Field>'
			$newField = $docLib.Fields.AddFieldAsXml($sentResponseSchema, $True,[Microsoft.SharePoint.SPAddFieldOptions]::AddFieldToDefaultView)

			# $srcSite, $dstSite , $langID, $docLibName
			CopyDocLib $srcSiteUrl $archSubSite.Url $languageID  $externalListName 
			$listO.Done = $true
			$countRecords++
			if ($progressRecordsLimit -gt 0){
				write-Host "Progress Records leave: $($progressRecordsLimit - $countRecords)"
				if ($countRecords -gt $progressRecordsLimit){
					break
				}
			}

		}
	  
  }
  write-host
  write-host "Creating Documents Library Final and Submitted" -f Yellow
  write-host "==============================================" -f Yellow
  foreach($listO in $siteObj.siteListArr){
		$finalOrSubmitted = (($listO.Title -eq "Final") -or ($listO.Title -eq "Submitted"))
		if (!$finalOrSubmitted){
			continue
		}
		write-host -------------------
		write-host $listO.Title
		$externalListName = $listO.Title
		$innerListName = $listO.RootFolder
		$archSubSite.Lists.Add($innerListName, $externalListName, "DocumentLibrary")
		$dstweb = Get-SPWeb $archSubSite.Url
		$docLib = $dstweb.Lists[$listO.Title]
		
		if ($listO.Title -eq "Final"){
			Copy-Final $srcSiteUrl $archSubSite.Url 
		}
		if ($listO.Title -eq "Submitted"){
            $docTypeSchema = Get-DocTypeSchema	$dstweb $languageID		
			$newField = $docLib.Fields.AddFieldAsXml($docTypeSchema, $True,[Microsoft.SharePoint.SPAddFieldOptions]::AddFieldToDefaultView)
			$descrSchema = '<Field DisplayName="description" Type="Text" Required="FALSE" StaticName="description0" Name="description0" />'
			$newField = $docLib.Fields.AddFieldAsXml($descrSchema, $True,[Microsoft.SharePoint.SPAddFieldOptions]::AddFieldToDefaultView)
			
			Copy-SubmittedX $srcSiteUrl $archSubSite.Url $languageID
		}
		
		$listO.Done = $true
		
  }
  
  # Documents Upload Abigail Leavitt 539290705
#read-host
 <# 
 foreach($listO in $siteObj.siteListArr){
	 #if ($listO.BaseTemplate -eq 100){ # :GenericList =100
	    if ($listO.Title.ToLower() -ne "applicants" ){
			#write-host 115 -f Cyan
			Create-ListOnArchiveFromTemplate $archSubSite $listO
		}
		#if ($listO.Title.ToLower() -eq "ekmdkatiem"){
			#write-host 115 -f Cyan
		#	Create-ListOnArchiveFromTemplate $archSubSite $listO
		#}
		
		#$templateFileName = $group + "-" 
	 #}
 }
 #>
 <#
 foreach($listO in $siteObj.siteListArr){
	 #if ($listO.BaseTemplate -eq 100){ # :GenericList =100
	    if ($listO.Title.ToLower() -eq "applicants" ){
			#write-host 115 -f Cyan
			Create-ListOnArchiveFromTemplate $archSubSite $listO
		}
		#if ($listO.Title.ToLower() -eq "ekmdkatiem"){
			#write-host 115 -f Cyan
		#	Create-ListOnArchiveFromTemplate $archSubSite $listO
		#}
		
		#$templateFileName = $group + "-" 
	 #}
 } 
 
 #$siteObj
 
#write-host ...
#read-host
#>
deleteListTemplate	$homeweb.Site.Url $group #$siteObj.workingDir
	}
 $listSiteCollectFile = Join-Path $siteObj.workingDir "AllList.json"
 $siteObj.siteListArr | ConvertTo-Json -Depth 100 | out-file $listSiteCollectFile

write-host "$listSiteCollectFile was written" -f Yellow
write-host "Archive site was Created $($archSubSite.URL)" -f Yellow
Change-Theme $($archSubSite.URL)

create-WPPage $archSubSite.URL "Default" $true
create-WPPage $archSubSite.URL "DefaultHe" $false

$Content = get-PageContent $srcSiteUrl "default" "PublishingPageContent"
$Title = get-PageContent $srcSiteUrl "default" "Title"
$ContentHe = get-PageContent $srcSiteUrl "defaultHe" "PublishingPageContent"
$TitleHe = get-PageContent $srcSiteUrl "defaultHe" "Title"

Update-PageContent $archSubSite.URL "default" "PublishingPageContent" $Content
Update-PageContent $archSubSite.URL "default" "Title" $Title
Update-PageContent $archSubSite.URL "defaultHe" "PublishingPageContent" $ContentHe
Update-PageContent $archSubSite.URL "defaultHe" "Title" $TitleHe

#Read more: https://www.sharepointdiary.com/2014/02/delete-list-template-in-sharepoint-with-powershell.html#ixzz7XJPyfq5c 
[system.gc]::Collect()
Stop-Transcript
