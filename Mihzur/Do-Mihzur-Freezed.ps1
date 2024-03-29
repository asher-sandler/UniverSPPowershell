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
function Get-Tree($Path,$Include='*') { 
    @(Get-Item $Path -Include $Include -Force) + 
        (Get-ChildItem $Path -Recurse -Include $Include -Force) | 
        sort pspath -Descending -unique
} 

function Remove-Tree($Path,$Include='*') { 
    Get-Tree $Path $Include | Remove-Item -force -recurse
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
			Write-host "New List $listName Creating from Custom List template" -f Green


            # Return UID
			# $listN = $spweb.Lists | Where-Object{$_.ID -eq "316f0d50-b05a-482f-95e3-665970af52b3"}			
			<#
			PS C:\AdminDir\Mihzur> $listNew = $spweb.Lists.Add("Test1","Test1",$Template)
			PS C:\AdminDir\Mihzur> $listNew

			Guid
			----
			316f0d50-b05a-482f-95e3-665970af52b3
			#>
			$listCreated.UID = $($archiveWeb.Lists.Add($listName, $lTitle, $Template)).Guid # | Out-Null
			$listCreated.Done = $true
			$listN = $archiveWeb.Lists | Where-Object{$_.ID -eq $listCreated.UID}
			$listN.Title = $lTitle
			$listN.Update()
			$listCreated.URL = $listN.RootFolder.Url
			#Write-Host "101: $($listCreated.UID)"
			#Write-Host "102: $($listCreated.URL)"
			#read-host
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
			Write-Host "List $($itm.Title) Saved as Template $TemplateFileName $savedDataMsg" -f Green

		}
		catch
		{
			Write-host $_.Exception.Message -f Red
			Write-Host "Template $TemplateFileName already exists"	-f Yellow	
		}
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
function Change-Theme ( $siteURL)
{
	$validThemes = "Sea Monster","Nature","Blossom","Sketch","City","Orbit","Characters","Breeze","Immerse","Wood"
    write-Host 267
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
		write-host "Saved Template: " $FilePath -f Cyan
	
	}	
}
function replace-STP($lookUpSTPFile, $replArr, $srcrDir){
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
	$msgSubj = "Original STP: "+$tmpItem.FullName
    Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersa@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj   -Attachments   $tmpItem -smtpserver ekekcas01  -erroraction SilentlyContinue
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
	$utilExecPath = $srcrDir+"\Utils\MakeCab"
	write-host "$utilExecPath $manFileName $($tmpItem.FullName)"
	& $utilExecPath $manFileName $tmpItem.FullName | Out-Null
	Start-Sleep 2
	#write-host 205
	#read-host	
	$msgSubj = "Changed STP: "+$tmpItem.FullName
    Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersa@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj   -Attachments   $tmpItem -smtpserver ekekcas01  -erroraction SilentlyContinue
	
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
						<#
						$lookUpList = ""
						$lookUpListID = $null
						foreach($lkUpFld in $lkUpfieldArr){
							if ($lkUpFld.FieldTitle -eq $fieldDispName){
								    $lookUpListID =  Get-NewListId $allList $lkUpFld.SourceListID.Replace("{","").Replace("}","")
									
									#$lookUpList = $lkUpFld.SourceListTitle
									break
							}
						}
						#>
						$srcLookUp = new-object Microsoft.SharePoint.SPFieldLookupValue($srcValName) 
						
						#$srcDocTypeID = $srcDocTypeValue.LookupId
						$srcLookUpValue = $srcLookUp.LookupValue
						$dstFile.Item[$fieldDispName] = $srcLookUpValue				
						<#
						if (![string]::IsNullOrEmpty($lookUpListID)){
							$lookUpValue =  $(New-Object Microsoft.SharePoint.SPFieldLookupValue($srcVal)).LookupValue
							
							#$lkUpNewValue  = get-LookupIdByValue $dstSite  $lookUpList $lookUpValue 
							$lkUpNewValue  = get-LookupIdByValue $dstSite  $lookUpListID $lookUpValue 
							write-Host 864  "fieldDispName: $fieldDispName"
							write-Host "lookUpList: $lookUpList"
							write-Host "srcVal: $srcVal"
							write-Host "lookUpValue $lookUpValue"   
							write-Host "lkUpNewValue: $lkUpNewValue"
							$dstFile.Item[$fieldDispName] = $lkUpNewValue
						}
						else
						{
							write-Host 875 "fieldName : $fieldName"
							write-Host "fieldName : $fieldName"
						}
						#>
					}
					else
					{
						if ($fieldType -ne "File"){
							 
							write-host 883 "FieldType: $fieldType"
							write-host "fieldDispName: $fieldDispName"
							write-host "fieldName: $fieldName"
							write-host "srcVal: $srcVal"
							write-host "srcValName: $srcValName"
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
    Write-Host "681: Copy from $srcFolder To $dstFolder"
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
function CopyDocLibwithLookup($srcSite, $dstSite ,$listO, $allList){
	$dstweb = get-SPWeb $dstSite
	$dstList = $dstweb.Lists | Where-Object{$_.ID -eq $listO.UIDNew}
	#$dstList = $dstweb.Lists[$docLibName]
	$dstFolder 	   = $dstweb.GetFolder($dstList.RootFolder.Url)
	
	$srcweb = get-SPWeb $srcSite
	$srcList = $srcweb.Lists | Where-Object{$_.ID -eq $listO.UIDOld}

	$listSchema = get-ListSchemaByUID $dstSite  $listO.UIDNew
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

    Write-Host "833 Copy From " $srcList.Title " TO " $dstList.Title 
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
						$lookUpList = ""
						$lookUpListID = $null
						foreach($lkUpFld in $lkUpfieldArr){
							if ($lkUpFld.FieldTitle -eq $fieldDispName){
								    $lookUpListID =  Get-NewListId $allList $lkUpFld.SourceListID.Replace("{","").Replace("}","")
									
									#$lookUpList = $lkUpFld.SourceListTitle
									break
							}
						}
						if (![string]::IsNullOrEmpty($lookUpListID)){
							$lookUpValue =  $(New-Object Microsoft.SharePoint.SPFieldLookupValue($srcVal)).LookupValue
							
							#$lkUpNewValue  = get-LookupIdByValue $dstSite  $lookUpList $lookUpValue 
							$lkUpNewValue  = get-LookupIdByValue $dstSite  $lookUpListID $lookUpValue 
							write-Host 864  "fieldDispName: $fieldDispName"
							write-Host "lookUpList: $lookUpList"
							write-Host "srcVal: $srcVal"
							write-Host "lookUpValue $lookUpValue"   
							write-Host "lkUpNewValue: $lkUpNewValue"
							$dstFile.Item[$fieldDispName] = $lkUpNewValue
						}
						else
						{
							write-Host 875 "fieldName : $fieldName"
							write-Host "fieldName : $fieldName"
						}
					}
					else
					{
						if ($fieldType -ne "File"){
							 
							write-host 883 "FieldType: $fieldType"
							write-host "fieldDispName: $fieldDispName"
							write-host "fieldName: $fieldName"
							write-host "srcVal: $srcVal"
							write-host "srcValName: $srcValName"
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
	

	$dstList.Update()
	return $null
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
function Collect-qlMenu($spweb){
	
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
			
<#
 SPNavigationNode
tyScopeId  Property   guid TargetSecurityScopeId {get;}
           Property   string Title {get;set;}
e          Property   Microsoft.SharePoint.SPUserResource TitleResource {get;}
           Property   string Url {get;set;}
           Method     void Delete()
           Method     bool Equals(System.Object obj)
           Method     int GetHashCode()
           Method     type GetType()
           Method     void Move(Microsoft.SharePoint.Navigation.SPNavigationNodeCollection collection, M...
           Method     void MoveToFirst(Microsoft.SharePoint.Navigation.SPNavigationNodeCollection collec...
           Method     void MoveToLast(Microsoft.SharePoint.Navigation.SPNavigationNodeCollection collect...
           Method     string ToString()
           Method     void Update()
           Property   Microsoft.SharePoint.Navigation.SPNavigationNodeCollection Children {get;}
           Property   int Id {get;}
           Property   bool IsDocLib {get;}
           Property   bool IsExternal {get;}
           Property   bool IsVisible {get;set;}
           Property   datetime LastModified {get;}
           Property   Microsoft.SharePoint.Navigation.SPNavigation Navigation {get;}
           Property   Microsoft.SharePoint.Navigation.SPNavigationNode Parent {get;}
           Property   int ParentId {get;}
           Property   hashtable Properties {get;}
#>			
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
		if ($childrenExists){
			$qlMenu += $qlMainMenuItem
		}
	}

	return 	$qlMenu
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
			<#
			$oldRootFolder = $childMenu.URL -Replace $localPathSrc, ""
			$newRootFolder = Get-NewRootFolder $childItem.Title $oldRootFolder $oSiteList
			$newRootFolder = $newRootFolder.ToLower()
			$newRootFolder = $newRootFolder -Replace $oldRootFolder.ToLower(),$newRootFolder.ToLower()
			$childItem.URL = $childMenu.URL.Tolower() -Replace $oldRootFolder,  $newRootFolder
			$childItem.URL = $childMenu.URL -Replace $localPathSrc.ToLower(),$localPathArc
			write-Host "1099 " $childItem.URL
			#>
			$childItem.URL = $childMenu.URL -Replace $localPathSrc.ToLower(),$localPathArc
			$childItem.IsVisible = $childMenu.IsVisible
			$xsubMenu += $childItem
			
			
		}
		
		$qlMainMenuItem.Children = $xsubMenu
		$qlMenu += $qlMainMenuItem
		
	}

	return 	$qlMenu	
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
function Get-NewRootFolder ($Title, $oldRootFolder, $oSiteList){
	$retValue = $oldRootFolder
	$pureRootFolder = $oldRootFolder
	if ($pureRootFolder.ToLower().Contains("aspx")){
		$pureRootFolder = $pureRootFolder.Substring(0,$pureRootFolder.LastIndexOf("/"))
		if ($pureRootFolder.Contains("Forms")){
			$pureRootFolder = $pureRootFolder.Substring(0,$pureRootFolder.LastIndexOf("/"))
		}
	}
	
	
	write-Host "1128 $retValue"
	write-Host "1128 $pureRootFolder"
	#read-host
	foreach($oItem in  $oSiteList){
		if ($oItem.RootFolder.ToLower() -eq $pureRootFolder.ToLower()){
			$retValue = $oItem.RootFolderNew
		}
	}
	return $retValue
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
function Inher-MasterPage($srcSiteURL, $archSiteURL){
	$topSPWeb  = get-SPweb $srcSiteURL
	$archSPWeb = get-SPweb $archSiteURL
	
	#$archSPWeb.AllProperties["__InheritsCustomMasterUrl"]
	#$archSPWeb.AllProperties["__InheritsMasterUrl"]
	
	#$topSPWeb.MasterUrl
	#$topSPWeb.CustomMasterUrl;
	$archSPWeb.CustomMasterUrl = $topSPWeb.CustomMasterUrl;
    $archSPWeb.AllProperties["__InheritsCustomMasterUrl"] = "True";
    $archSPWeb.MasterUrl = $topSPWeb.MasterUrl;
    $archSPWeb.AllProperties["__InheritsMasterUrl"] = "True";
    $archSPWeb.AlternateCssUrl = $topSPWeb.AlternateCssUrl;
    $archSPWeb.AllProperties["__InheritsAlternateCssUrl"] = "True";
    $archSPWeb.Update();
	return $null	
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
function get-ScrptFullPath($scriptX ){
	$fileScr = get-Item $scriptX
	return $fileScr.DirectoryName
}
function Replace-Brackets($strInp){
	$braks = " ","(",")","[","]","{","}","/","\"
	$outStr = $strInp
	foreach($brkItm in $braks){
		$outStr = $outStr.Replace($brkItm,"")
	}
	return $outStr
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
				Write-Host "1392: " $oItm.UIDNew
				Write-Host "1392: " $oItm.Title " ≠ " $lst.Title
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
function Copy-DefaultQuery($srcURL, $dstURL, $listName){
	$spWebSrc = Get-SPWeb  $srcURL
	$spWebDst = Get-SPWeb  $dstURL
	
    $listSrc = 	$spWebSrc.Lists[$listName]
	$listDst =  $spWebDst.Lists[$listName]
	
	$aggrSrc = $listSrc.DefaultView.Aggregations
	
	$dstDefView = $listDst.DefaultView
	$dstDefView.ViewFields.DeleteAll();
	foreach($xF in $listSrc.DefaultView.ViewFields){
		write-Host $xF
		$dstDefView.ViewFields.Add($xF)	
	}	
	$dstDefView.Query = $listSrc.DefaultView.Query
	$dstDefView.Aggregations = $aggrSrc
	
	$dstDefView.Update()
	$listDst.Update()

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
<#
function check-FinalList($finalLsts, $siteListArr){
	$fnlLstArrRes =  @()
	if (![string]::IsNullOrEmpty($finalLsts)){
		
		$fnlLstArr = $finalLsts.Trim().Replace(";",",").Split(",")
        
        foreach($oItm in  $siteListArr){
			if (!$oItm.Done){
				foreach($fnlLstItem in $fnlLstArr){
					if ($fnlLstItem.Trim().ToUpper() -eq $oItm.Title.ToUpper()){
						dfsf
						foreach( re$fnlLstArrRes.Title -eq )						
						$fnlLstArrRes += $oItm
						#break
					}
				}
				
			}
		}		
	}
	$fnlLstArrRes = $fnlLstArrRes | Sort -Unique
	return $fnlLstArrRes
}
#>
function Is-ListExits ($siteUrl, $oList){
	$retValue = $False
	if (![string]::IsNullOrEmpty($oList.RootFolderNew)){
		$spWeb = Get-SPWeb $siteUrl
		$list = $spWeb.Lists | where-Object {$_.RootFolder.Url -eq $oList.RootFolderNew} 
		if (![string]::IsNullOrEmpty($list)){
			$retValue = $true
		}
	}
	return $retValue
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
        
 				Write-host "Lookup Column $($lookUpFld.FieldTitle) was deleted from the List $($List.Title) Successfully!" -ForegroundColor Green 
		

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
					 
		 
					Write-host "Text Column $($lookUpFld.FieldTitle) was added to the List $($List.Title) Successfully!" -ForegroundColor Green 
				}



			}
		}
	}
	else
	{
		write-Host "Error : Procedure Create_LookupFieldsAsText : Not Found List $($listO.Title)" -f Yellow
	}
}
# Copy Old List To New List
Function Copy-ListToList( $srcSite, $dstSite, $listO, $siteObj){
	$dstweb = get-SPWeb $dstSite
	$dstList = $dstweb.Lists | Where-Object{$_.ID -eq $listO.UIDNew}
	#$dstList = $dstweb.Lists[$docLibName]
	$dstFolder 	   = $dstweb.GetFolder($dstList.RootFolder.Url)
	
	$srcweb = get-SPWeb $srcSite
	$srcList = $srcweb.Lists | Where-Object{$_.ID -eq $listO.UIDOld}

    <#
	$listSchema = get-ListSchemaByUID $dstSite  $listO.UIDNew
	$xmlFile =   "Schema-"+$(HebrewToLatin $($listO.Title))+".xml"
	$listSchemaArchive | out-file $xmlFile -encoding Default
	write-host "$xmlFile was written" -f Yellow
	 
	$ts = gc $xmlFile -raw 
	if (![string]::IsNullOrEmpty($ts)){
		 $msgSubj = $xmlFile
		 Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersa@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction SilentlyContinue
		 start-sleep 2
	}
	#>
	#$lkUpfieldArr = $($listO.IsLookupField.FieldArr)
	#$srcList = $srcweb.Lists[$docLibName]
	$srcFolder 	   = $srcweb.GetFolder($srcList.RootFolder.Url)

    Write-Host "1820 Copy From " $srcList.Title " TO " $dstList.Title 
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
							#$containsSrcUrl = $srcVal.ToString().ToLower().Contains($srcSite.ToLower())
							 
							#if ($containsSrcUrl){
								
								$urlDescription = $srcVal.Split(",")[1].Trim()
								$urlLink = $srcVal.Split(",")[0].Trim()
								$urlLink = $urlLink.ToLower()  -Replace $localPathSrc,$localPathArc
	
								$tlink = New-Object Microsoft.SharePoint.SPFieldURLValue($sourceItem[$($column.InternalName)])
								$tlink.Description = $urlDescription
								$tlink.Url =  $urlLink 
								#write-Host $tlink.Url
								#write-Host $tlink.Description
								#write-Host $column.InternalName
								
												
								$TargetItem[$column.InternalName] = $tlink.ToString()
							#}
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
write-host "Script For Mihzur version 2022-11-07.1"           
write-host "Asher Sandler	: mailTo:AsherSa@ekmd.huji.ac.il"           


$oMihzur = get-siteToArchive
$webservice = [Microsoft.SharePoint.Administration.SPWebService]::ContentService
Write-Host "Template Max Size: " $webservice.MaxTemplateDocumentSize
$webservice.MaxTemplateDocumentSize = 500Mb 
$webservice.Update()
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


	# for very large sites if doclib count is huge we setting limit of records to process
	# if 0 (zero) no limit. For Debug only.
	$progressRecordsLimit = 0


	write-host "Site to Archive	:  <$srcSiteUrl>"          
	write-host "Language ID		:  <$languageID>"           
	write-host "Site Group 		:  <$group>"           
	write-host "Start time		:  <$dtNowStr>"          
	write-host "User			:  <$whoami>"        
	write-host "Running ON		:  <$ENV:Computername>" 
	write-host "Script file		:  <$script>"        
	write-host "Log file		:  <$logFile>"        


	 
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
	 write-Host 1994	
	 write-host $localPathSrc
	 write-host $localPathArc
     # BODY Region
	 write-host 
	 write-host "Collecting Information About Lists and Document Library on Source Web" -f Yellow
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
	  write-host "Collecting Completed" -f Yellow


	 $siteObj.siteListArr =  $realListArr
	 deleteListTemplate	$homeweb.Site.Url $group #$siteObj.workingDir		


	 write-host
	 write-host "Creating Applicants on destination Web from templates on Site" -f Yellow
	 write-host "==============================================================================" -f Yellow
	 write-host $oMihzurItem.applicantList -f Yellow
	 
	 if (![string]::IsNullOrEmpty($oMihzurItem.applicantList)){
		$aApplicants = $oMihzurItem.applicantList.Replace(";",",").Split(",")
		
		foreach($applItem in $aApplicants){
			foreach($listO in $siteObj.siteListArr){
				if (!$listO.Done) {
					if ($listO.Title.ToLower() -eq $applItem.ToLower()){
						write-host -------------------
						write-host $listO.Title
						write-host -----save List Template------
						write-host $listO.Title
						#$saveLstData = $true
						$saveLstData = $false
						saveListTemplate $homeweb $listO $saveLstData

						write-host -------------------
						write-host $listO.Title
						$listCreated = Create-ListOnArchiveFromTemplate $archSubSite $listO
						$listO.Done = $listCreated.Done 
						$listO.UIDNew =  $listCreated.UID 
						$listO.RootFolderNew =  $listCreated.URL
						
						# Delete LookupFields from List
						Delete_LookupFields $archSubSite.Url $listO
						# Change LookupFields To TextFields 
						Create_LookupFieldsAsText $archSubSite.Url $listO
						# Copy Old List To New List
						Copy-ListToList $srcSiteUrl $archSubSite.Url $listO $siteObj.siteListArr
						write-Host 2052 "Stop..."
						
						
					}
				}	
			}	
		}
	 }
	 if (![string]::IsNullOrEmpty($oMihzurItem.FinalLists)){

		 $aFinalLst =   $oMihzurItem.FinalLists.Replace(";",",").Split(",") 
		 #write-Host  $aFinalLst
		 Write-Host
		 write-host "Processing Lists Founded in Field 'Archive_Lists_Final'" -f Yellow
		 write-host "Creating Lists Entered to Field 'Archive_Lists_Final' with/without Lookup Fields on destination Web from template" -f Yellow
		 write-host "==========================================================================" -f Yellow
		foreach($listFinal in $aFinalLst){
			write-Host $listFinal
			foreach($listO in $siteObj.siteListArr){
				if (!$listO.Done) {
					if ($listO.Title.ToLower() -eq $listFinal.ToLower().Trim()){

						write-host -------------------
						write-host $listO.Title
						
							
						#########################
						$saveLstData = $false
						saveListTemplate $homeweb $listO $saveLstData
						
						$listCreated = Create-ListOnArchiveFromTemplate $archSubSite $listO
						$listO.Done = $listCreated.Done 
						$listO.UIDNew =  $listCreated.UID 
						$listO.RootFolderNew =  $listCreated.URL
						
						# Delete LookupFields from List
						Delete_LookupFields $archSubSite.Url $listO
						# Change LookupFields To TextFields 
						Create_LookupFieldsAsText $archSubSite.Url $listO
						# Copy Old List To New List
						Copy-DocLibToDocLib $srcSiteUrl $archSubSite.Url $listO $siteObj.siteListArr

						##########################			
					}
				}
			}
		}
	 }
	 
	 deleteListTemplate	$homeweb.Site.Url $group #$siteObj.workingDir		


	 write-host
	 write-host "Saving  Lists without Lookup Fields template to Site" -f Yellow
	 write-host "====================================================" -f Yellow

	 foreach($listO in $siteObj.siteListArr){
		 if (!$listO.Done) {
			$finalOrSubmitted = (($listO.Title -eq "Final") -or ($listO.Title -eq "Submitted"))
			if ($finalOrSubmitted){
				continue
			}	 
			$docLib = $(($listO.BaseTemplate -eq 101) -and 
					  ($listO.Title.Contains($heDocLibName) -or $listO.Title.Contains($enDocLibName)))
			$tableWithLookupFields = $($listO.IsLookupField.isLookup)		  
				
			if (!$tableWithLookupFields -and !$docLib){
				$saveLstData = $true
				saveListTemplate $homeweb $listO $saveLstData
			}
				
		}			
	 }
	 [system.gc]::Collect()
    

	 write-host
	 write-host "Creating Lists without Lookup Fields on destination Web from templates on Site" -f Yellow
	 write-host "==============================================================================" -f Yellow

	 foreach($listO in $siteObj.siteListArr){
		if (!$listO.Done) {
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
					$listCreated = Create-ListOnArchiveFromTemplate $archSubSite $listO
					$listO.Done = $listCreated.Done 
					$listO.UIDNew =  $listCreated.UID 
					$listO.RootFolderNew =  $listCreated.URL
					
					
					# $listO.UIDNew =  $listCreated.UID 
					# Get-ListID $archSubSite.Url $listO.Title
					
				}
			}
		}
	  }
	  
	  #write-host 416
	  #read-host
	 write-host
	 write-host "1756: Deleting unnecessary Templates on Site" -f Yellow
	 write-host "======================================" -f Yellow
	  
	 deleteListTemplate	$homeweb.Site.Url $group #$siteObj.workingDir		
	 $wDir = Create-TemplateDir $templSavedPath

	 write-host
	 write-host "Saving and Download Lists with Lookup Fields template to Site" -f Yellow
	 write-host "Saving List without Data" -f Yellow
	 write-host "=============================================================" -f Yellow

	 foreach($listO in $siteObj.siteListArr){
		if (!$listO.Done) {
			$tableWithLookupFields = $($listO.IsLookupField.isLookup)
			$ordinalList = $($listO.BaseTemplate -eq 100)
			$finalOrSubmitted = (($listO.Title -eq "Final") -or ($listO.Title -eq "Submitted"))
			if ($finalOrSubmitted){
				continue
			}
			# create Lists with Lookup Fields
			if ($ordinalList){
						
				write-host -----save List Template------
				write-host $listO.Title
				#$saveLstData = $true
				$saveLstData = $false
				saveListTemplate $homeweb $listO $saveLstData
				# download Templare from Site Level
				#downloadListTemplate $archSubSite.Site.Url $listO.templateFileName  $wDir.FullName
				
			}
		}
	 } 
	 #deleteListTemplate	$homeweb.Site.Url $group #$siteObj.workingDir		
	 
	 write-host
	 write-host "Creating Empty Lists with Lookup Fields on destination Web from templates on Site" -f Yellow
	 write-host "==============================================================================" -f Yellow

	 foreach($listO in $siteObj.siteListArr){
		if (!$listO.Done) {
		 
			$finalOrSubmitted = (($listO.Title -eq "Final") -or ($listO.Title -eq "Submitted"))
			if ($finalOrSubmitted){
				continue
			}	 
			#$tableWithLookupFields = $($listO.IsLookupField.isLookup)
			$ordinalList = $($listO.BaseTemplate -eq 100)
			
			#$docLib = $(($listO.BaseTemplate -eq 101) -and 
			#			  ($listO.Title.Contains($heDocLibName) -or $listO.Title.Contains($enDocLibName)))

			# first create Empty Lists with Lookup Fields
			#if (!$tableWithLookupFields){
				if ($ordinalList){
					write-host -------------------
					write-host $listO.Title
					
					#$saveLstData = $false
					#saveListTemplate $homeweb $listO $saveLstData
					
					$listCreated = Create-ListOnArchiveFromTemplate $archSubSite $listO
					$listO.Done = $listCreated.Done 
					$listO.UIDNew =  $listCreated.UID 
					$listO.RootFolderNew =  $listCreated.URL
					
					# Delete LookupFields from List
					Delete_LookupFields $archSubSite.Url $listO
					# Change LookupFields To TextFields 
					Create_LookupFieldsAsText $archSubSite.Url $listO
					# Copy Old List To New List
					Copy-ListToList $srcSiteUrl $archSubSite.Url $listO $siteObj.siteListArr
					#write-Host 2231 "Stop..."
					#read-host
					
					# $listO.UIDNew =  $listCreated.UID 
					# Get-ListID $archSubSite.Url $listO.Title
					
				}
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
		 if (!$listO.Done) {
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
							write-Host "ID-Detection List With Lookup"
							$replArrItm.oldListID = $oldListID
							$replArrItm.newListID = $newListID 
							write-Host $oldListID
							write-Host $newListID
							if ($oldListID.Contains("{")){
								$replArrItm.newListID = "{"+$newListID+"}"
							}
							
							$replArr += $replArrItm
						}
					}
				}
				#write-host 439
				#read-host	
				#if ($replArr.Count -gt 0){			
				$newSTPFile = replace-STP $lookUpSTPFile $replArr $scriptDirectory
				
				#}
				#write-host 442
				#write-host $newSTPFile
				#read-host
				deleteListTemplateSingle	$homeweb.Site.Url $listO.templateFileName
				#write-host 449
				#write-host $($listO.templateFileName)
				#read-host
				
				$uplTempl = addListTemplate $archSubSite.Site.Url $newSTPFile
				#write-host 446
				#read-host			
				
				
				$listCreated = Create-ListOnArchiveFromTemplate $archSubSite $listO
				$listO.Done = $listCreated.Done 
				$listO.UIDNew =  $listCreated.UID 
				$listO.RootFolderNew =  $listCreated.URL

			}
		 }
	  }
	  
	  write-host
	  write-host "Creating Documents Library for Users with metadata and Copying files From Source To Destination" -f Yellow
	  write-host "===============================================================================================" -f Yellow
	  $countRecords = 0
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

				#$dstweb = Get-SPWeb $archSubSite.Url
				#$docLib = $dstweb.Lists[$innerListName]
				#$docLib = $dstweb.Lists | Where-Object {$_.RootFolder.Url -eq $innerListName}
				
				$docLib.Title = $externalListName
				$docLib.Update()
				$docLib.TitleResource.SetValueForUICulture($cultureHE, $externalListName)
				$docLib.TitleResource.SetValueForUICulture($cultureEN, $externalListName)
				$docLib.TitleResource.Update()	

				
				#$docTypeSchema = Get-DocTypeSchema	$dstweb $languageID		
				$docTypeSchema = Get-DocTypeSchema	$archSubSite $languageID		
				$newField = $docLib.Fields.AddFieldAsXml($docTypeSchema, $True,[Microsoft.SharePoint.SPAddFieldOptions]::AddFieldToDefaultView)
				$sentResponseSchema = '<Field Type="Boolean" DisplayName="sentResponse" EnforceUniqueValues="FALSE" Indexed="FALSE"  StaticName="sentResponse" Name="sentResponse" ><Default>0</Default></Field>'
				$newField = $docLib.Fields.AddFieldAsXml($sentResponseSchema, $True,[Microsoft.SharePoint.SPAddFieldOptions]::AddFieldToDefaultView)

				# $srcSite, $dstSite , $langID, $docLibName
				#CopyDocLib $srcSiteUrl $archSubSite.Url $languageID  $innerListName 
				$arcRootFolder = $docLib.RootFolder.Url
				CopyDocLib $srcSiteUrl $archSubSite.Url $languageID  $externalListName $arcRootFolder
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
	  }
	  write-host
	  write-host "Creating Documents Library Final and Submitted" -f Yellow
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

			#$dstweb = Get-SPWeb $archSubSite.Url
			#$docLib = $dstweb.Lists[$listO.Title]
			
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
			<#
			if ($listO.Title -eq "Submitted"){
				$docTypeSchema = Get-DocTypeSchema	$dstweb $languageID		
				$newField = $docLib.Fields.AddFieldAsXml($docTypeSchema, $True,[Microsoft.SharePoint.SPAddFieldOptions]::AddFieldToDefaultView)
				$descrSchema = '<Field DisplayName="description" Type="Text" Required="FALSE" StaticName="description0" Name="description0" />'
				$newField = $docLib.Fields.AddFieldAsXml($descrSchema, $True,[Microsoft.SharePoint.SPAddFieldOptions]::AddFieldToDefaultView)
				
				Copy-SubmittedX $srcSiteUrl $archSubSite.Url $languageID
			}
			#>
			$listO.Done = $true
		}	
	  }
	  write-host
	  write-host "1936: Deleting unnecessary Templates on Site" -f Yellow
	  write-host "======================================" -f Yellow
	  deleteListTemplate	$homeweb.Site.Url $group #$siteObj.workingDir		
	  $wDir = Create-TemplateDir $templSavedPath
	  
	  write-host "Saving Templates (no data) for Documents Library with Lookup Fields" -f Yellow
	  write-host "==============================================" -f Yellow
	  foreach($listO in $siteObj.siteListArr){
		if (!$listO.Done) {
			# skip final or submitted  
			$finalOrSubmitted = (($listO.Title -eq "Final") -or ($listO.Title -eq "Submitted"))
			if ($finalOrSubmitted){
				continue
			}
			# skip students Doclibs
			if (($listO.Title.Contains($heDocLibName) -or $listO.Title.Contains($enDocLibName))){
				continue
			}		
			$docLib = $($listO.BaseTemplate -eq 101) 
			$tableWithLookupFields = $($listO.IsLookupField.isLookup)		  
				
			if ($tableWithLookupFields -and $docLib){
				Write-Host "1953 Saving Template for: " $listO.Title
				$saveLstData = $false
				saveListTemplate $homeweb $listO $saveLstData
				downloadListTemplate $archSubSite.Site.Url $listO.templateFileName  $wDir.FullName

			}
					
		}		
	 }
	 [system.gc]::Collect()
	 
	 #read-host
	 write-host
	 write-host "Creating Empty Document Libraries WITH Lookup Fields on destination Web from template" -f Yellow
	 write-host "==========================================================================" -f Yellow
	 write-host
	 write-host "Saving STP file, Extract Manifest.xml, Replace in Manifest.XML" -f Yellow
	 write-host "for Lookup fields List ID for New List Previously Created on Destination Web" -f Yellow
	 write-host "Pack to CAB file, rename CAB, Saving on Site as Template and" -f Yellow
	 write-host "Creating List on web from Template on Site" -f Yellow
	 foreach($listO in $siteObj.siteListArr){
		if (!$listO.Done) {
	
		 #if ($listO.Title -eq"applicants"){
			$tableWithLookupFields = $($listO.IsLookupField.isLookup)
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
			if ($tableWithLookupFields -and $docLib){
				write-host -------------------
				write-host $listO.Title
				$listCreated = Create-ListOnArchiveFromTemplate $archSubSite $listO
				$listO.Done = $listCreated.Done 
				$listO.UIDNew =  $listCreated.UID 
				$listO.RootFolderNew =  $listCreated.URL
				
				# Delete LookupFields from List
				Delete_LookupFields $archSubSite.Url $listO
				# Change LookupFields To TextFields 
				Create_LookupFieldsAsText $archSubSite.Url $listO
				# Copy Old List To New List
				Copy-DocLibToDocLib $srcSiteUrl $archSubSite.Url $listO $siteObj.siteListArr
				#debug	
				
				#write-Host 2231 "Stop..."
				#read-host
				
				#debug
				
				#saveListTemplate $homeweb $listO
				#$listName = $listO.Title
				#downloadListTemplate $archSubSite.Site.Url $listO.templateFileName  $wDir.FullName
				<#
				$stpFileName = Join-Path $wDir.FullName  $($listO.templateFileName + ".stp")
				
				if (Test-Path $stpFileName){
					$lookUpSTPFile  = Get-Item $stpFileName
					write-host $lookUpSTPFile
					$replArr = @()
					foreach($field in $listO.IsLookupField.FieldArr){
						$lookupListName = $field.SourceListTitle
						if (![string]::IsNullOrEmpty($lookupListName)){
							$oldListID = $field.SourceListID
							$newListID = Get-ListID $archSubSite.Url $lookupListName
							if (![string]::IsNullOrEmpty($newListID)){
								$replArrItm = "" | Select oldListID,newListID
								write-Host "2206 ID-Detection"
								$replArrItm.oldListID = $oldListID
								$replArrItm.newListID = $newListID
								if ($oldListID.Contains("{")){
									$replArrItm.newListID = "{"+$newListID+"}"
								}
								$replArr += $replArrItm
							}
						}
					}
					#write-host 439
					#read-host	
					#if ($replArr.Count -gt 0){			
					$newSTPFile = replace-STP $lookUpSTPFile $replArr $scriptDirectory
					#}
					#write-host 442
					#write-host $newSTPFile
					#read-host
					deleteListTemplateSingle	$homeweb.Site.Url $listO.templateFileName
					#write-host 449
					#write-host $($listO.templateFileName)
					#read-host
					
					$uplTempl = addListTemplate $archSubSite.Site.Url $newSTPFile
					#write-host 446
					#read-host	
					CopyDocLibwithLookup  $srcSiteUrl $archSubSite.Url $listO $siteObj.siteListArr
					
					#>
					
					<#
					$listSchemaArchive = get-ListSchema $archSubSite.Url  $listO.Title
				    $xmlFile =   "Schema-"+$(HebrewToLatin $($listO.Title))+".xml"
					$listSchemaArchive | out-file $xmlFile -encoding Default
					write-host "$xmlFile was written" -f Yellow
					 
					$ts = gc $xmlFile -raw 
					if (![string]::IsNullOrEmpty($ts)){
						 $msgSubj = $xmlFile
						 Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersa@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction SilentlyContinue
						 start-sleep 2
					}
					#>
					#$lookupFieldArr = $($listO.IsLookupField.FieldArr)

				#}
				#else
				#{
				#	write-Host "Template File $stpFileName does not exists." -f Yellow
				#}
			}
		 }
	  }
	 
	  $jsonFile =  $group+"Archive-Finals.json"
	  $finalLstArr | ConvertTo-Json -Depth 100 | out-file $jsonFile
	  write-host "$jsonFile was written" -f Yellow
	 
      $ts = gc $jsonFile -raw 
	  if (![string]::IsNullOrEmpty($ts)){
		  $msgSubj = $jsonFile
		  Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersa@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction SilentlyContinue
	  }	  

	 deleteListTemplate	$homeweb.Site.Url $group #$siteObj.workingDir	

	 write-host
	 write-host "Processing with Status Not Copied" -f Yellow
	 write-host "==========================================================================" -f Yellow
	 write-host
	 foreach($listO in $siteObj.siteListArr){
		 #if ($listO.Title -eq"applicants"){
		if  (!$listO.Done) {
					
			$tableWithLookupFields = $($listO.IsLookupField.isLookup)
			$finalOrSubmitted = (($listO.Title -eq "Final") -or ($listO.Title -eq "Submitted"))
			if ($finalOrSubmitted){
				continue
			}
			# skip students Doclibs
			if (($listO.Title.Contains($heDocLibName) -or $listO.Title.Contains($enDocLibName))){
				continue
			}
            if($tableWithLookupFields){
				# skip this 
				continue
			}		
			$listExistOnArc = Is-ListExits $archSubSite.Url  $listO
			# create Lists with Lookup Fields
			if (!$listExistOnArc){
				Write-Host "2165 Saving Template (No Data) for: " $listO.Title
				$saveLstData = $false
				saveListTemplate $homeweb $listO $saveLstData
				downloadListTemplate $archSubSite.Site.Url $listO.templateFileName  $wDir.FullName
				
				$stpFileName = Join-Path $wDir.FullName  $($listO.templateFileName + ".stp")
				if (Test-Path $stpFileName){				
					$lookUpSTPFile  = Get-Item $stpFileName
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
								$replArrItm.newListID = $newListID
								write-Host "2422 ID-Detection"
								write-Host $oldListID
								write-Host $newListID

								if ($oldListID.Contains("{")){
									$replArrItm.newListID = "{"+$newListID+"}"
								}
								$replArr += $replArrItm
							}
						}
					}
					#write-host 439
					#read-host	
					#if ($replArr.Count -gt 0){			
					$newSTPFile = replace-STP $lookUpSTPFile $replArr $scriptDirectory
					#}
					#write-host 442
					#write-host $newSTPFile
					#read-host
					deleteListTemplateSingle	$homeweb.Site.Url $listO.templateFileName
					#write-host 449
					#write-host $($listO.templateFileName)
					#read-host
					
					$uplTempl = addListTemplate $archSubSite.Site.Url $newSTPFile
					#write-host 446
					#read-host			
					
					
					$listCreated = Create-ListOnArchiveFromTemplate $archSubSite $listO
					$listO.Done =  $listCreated.Done 
					$listO.UIDNew =  $listCreated.UID
					$listO.RootFolderNew =  $listCreated.URL					
				}
				else
				{
					write-Host "Template File $stpFileName does not exists." -f Yellow
				}			

			}
			else
			{
				$lst = $archSubSite.Lists | Where-Object {$_.Title -eq $listO.Title}
				$listO.UIDNew =  get-ListID $archSubSite.Url $listO.Title
				$listO.RootFolderNew =  $lst.RootFolder.URL
			}
			<#
			$listSchemaArchive = get-ListSchema $archSubSite.Url  $listO.Title
			$xmlFile =   "Schema-"+$(HebrewToLatin $($listO.Title))+".xml"
			$listSchemaArchive | out-file $xmlFile -encoding Default
			write-host "$xmlFile was written" -f Yellow
			 
			$ts = gc $xmlFile -raw 
			if (![string]::IsNullOrEmpty($ts)){
				 $msgSubj = $xmlFile
				 Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersa@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction SilentlyContinue
				 start-sleep 2
			}
			#>
			#$lookupFieldArr = $($listO.IsLookupField.FieldArr)
			CopyDocLibwithLookup  $srcSiteUrl $archSubSite.Url $listO  $siteObj.siteListArr #$lookupFieldArr
			$listO.Done = $listO.Done -or $true

		 }
	  }
	 
	 write-host
	 write-host "2290: Deleting unnecessary Templates on Site" -f Yellow
	 write-host "======================================" -f Yellow
	
	 deleteListTemplate	$homeweb.Site.Url $group #$siteObj.workingDir	
	 $listSiteCollectFile = Join-Path $siteObj.workingDir "AllList.json"
	 $siteObj.siteListArr | ConvertTo-Json -Depth 100 | out-file $listSiteCollectFile
	write-host "$listSiteCollectFile Created"

	#Change-Theme $($archSubSite.URL)

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

	Inher-MasterPage $srcSiteUrl $archSubSite.URL
	#Read more: https://www.sharepointdiary.com/2014/02/delete-list-template-in-sharepoint-with-powershell.html#ixzz7XJPyfq5c 
	[system.gc]::Collect()

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

     <#
	 $qlnavJsonFile =   $group+"-qlnavMenuArc.json"
	 $qlMenuArc | ConvertTo-Json -Depth 100 | out-file $qlnavJsonFile
	 write-host "$qlnavJsonFile was written" -f Yellow
	 
     $ts = gc $qlnavJsonFile -raw 
	 $msgSubj = $qlnavJsonFile
	 Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersa@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction Stop
	 start-sleep 2 
	 #>


	Delete-QuickLaunchMenu $archSubSite $qlMenuArc 
	Add-QuickLaunchMenu $archSubSite $qlMenuY $siteObj.siteListArr
	write-host "Change Archive Site Permissions."
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

	write-host "Check not Done Lists" -f Yellow
    write-host "==============================================" -f Yellow
	$listsNotDone = get-ListsNotDone $($archSubSite.URL) $siteObj.siteListArr

	$outFileName = "Lists-Not-Done.txt"
	$listsNotDone | ConvertTo-Json -Depth 100 | Out-File $outFileName
	if (![string]::IsNullOrEmpty($listsNotDone)){
		$msgSubj = "Lists Not Done"
		$ts = gc $outFileName -raw 
		Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersa@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction SilentlyContinue
	}
	write-host "Check Mihzur Integrity" -f Yellow
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

	 $JsonFile =   "mihzur.json"
	 $oMihzur | ConvertTo-Json -Depth 100 | out-file $JsonFile
	 write-host "$JsonFile was written" -f Yellow
	 
     $ts = gc $JsonFile -raw 
	 if (![string]::IsNullOrEmpty($ts)){
		 $msgSubj = $JsonFile
		 Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersa@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction SilentlyContinue
		 start-sleep 2
	 }	 

$ts = gc $logFile -raw 
$msgSubj = "Do Mihzur Log"
Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersa@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction SilentlyContinue
start-sleep 2 

$gzipexec = $scriptDirectory + "\Utils\gzip"	

write-host "$gzipexec $logFile -f"
& $gzipexec $logFile -f #| Out-Null
$gzLogFile = $logFile.Replace("log","log.gz")

$gzFile = get-Item $gzLogFile
$outGzPath = "\\ekekfls00\data$\scriptFolders\LOGS\Mihzur"
copy-item $gzFile $outGzPath

$msgSubj = "Do Mihzur gz"
Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersa@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $outGzPath  -Attachments  $gzFile -smtpserver ekekcas01  -erroraction SilentlyContinue
Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "evgeniat@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $outGzPath  -Attachments  $gzFile -smtpserver ekekcas01  -erroraction SilentlyContinue
Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "danielkl@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $outGzPath  -Attachments  $gzFile -smtpserver ekekcas01  -erroraction SilentlyContinue
start-sleep 2 
remove-Item $gzFile

