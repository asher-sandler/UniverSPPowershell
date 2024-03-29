<#
	1. Download STP
	2. Extract STP
		Utilities Extrac32.exe, MakeCab
	3. Delete STP On Server
	4. Replace UID in STP
	5. Upload STP
	6. Create List from STP
	


#>
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
    return $wDir	
}
function downloadListTemplate($SiteURL,$templSuffix,$listName, $wDirName){
	$spSite = Get-SPSite $SiteURL
	$ListTemplateFolder = $spSite.RootWeb.GetFolder("_catalogs/lt")
	$ListTemplates =  $ListTemplateFolder.Files
	$templFileName = $templSuffix+$listName+".stp"	
	$templatesCollection = $ListTemplateFolder.Files | Where-Object { $_.Name -eq $templFileName }
	foreach($listTemplate in $templatesCollection){
		write-host "Found template $listTemplate" -f Cyan
		$FilePath= Join-Path $wDirName $listTemplate.Name 
		$Data = $listTemplate.OpenBinary()
		[System.IO.File]::WriteAllBytes($FilePath, $Data) | out-null
		write-host $FilePath -f Cyan
	
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
function saveListTemplate($spWeb,$templSuffix,$listName){
	$TemplateName=$templSuffix + $listName
	$TemplateFileName=$TemplateName
	$TemplateDescription=$TemplateName
	$SaveData = $true
 
	$List = $spWeb.Lists[$listName]
	try{
		# https://gss2.ekmd.huji.ac.il/home/_catalogs/lt/Forms/AllItems.aspx
		$List.SaveAsTemplate($TemplateFileName, $TemplateName, $TemplateDescription, $SaveData)
		Write-Host "List $listName Saved as Template $TemplateFileName" -f Green

	}
	catch
	{
		Write-Host "Template $TemplateFileName already exists"	-f Yellow	
	}
}
Function Delete-SPList
{
    param
    (
        [string]$WebURL  = $(throw "Please Enter the Web URL!"),
        [string]$ListName = $(throw "Please Enter the List Name to Delete!")
    )
     
    #Get the Objects
    $Web = Get-SPWeb $WebURL
    $List = $Web.lists[$ListName]
  
    if($List)
    {
        #Set Allow Delete Flag
        $list.AllowDeletion = $true
        $list.Update()
 
        #delete list from sharepoint using powershell - Send List to Recycle bin
        #$list.Recycle()
         
        #TO permanently delete a list, Use:
        $List.Delete()
 
        Write-Host "List: $($ListName) deleted successfully from: $($WebURL)"
    }
    else
    {
        Write-Host "List: $($ListName) doesn't exist at $($WebURL)"
    }
    

}
Function Create-ListOnArchiveFromTemplate($archivesite,$newListName, $ListTemplateName){
	$TemplateName=$ListTemplateName+".stp"
	$listName = $newListName
	$archiveWeb = get-SPWeb $archivesite
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

			#write-host 51
			#write-host ...
			#read-host
		}
	}
	else
	{
	   write-host "List $listName already exists" -f Yellow
	}	
}
function get-ListID($siteURL,$listName){
   $spWeb = get-SPWeb $siteURL
   $List = $spWeb.lists[$listName]
   $id = ""
   if($List){
	   $id = $List.ID
   }
   return $id
	
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
	Start-Sleep 2
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
	.\Utils\MakeCab $manFileName $tmpItem.FullName | Out-Null
	#write-host 205
	#read-host		
	return $tmpItem
}
$srcSiteUrl   = "https://gss.ekmd.huji.ac.il/home/Humanities/HUM16-2020/"
$homeweb = Get-SPWeb  $srcSiteUrl

$listArray = "ארצות עולם", "ערים עולם", "נשיא"

$templateSuffix = "GSS-HUM16-2020-"
$templSavedPath = "SavedTemplates"
$wDir = Create-TemplateDir $templSavedPath
$newListName = "ערים עולם חדש"
$newListNameCountries = "ארצות עולם חדש"
$newListNamePresident = "נשיא חדש"
$countriesLookupTemplate = $templateSuffix + $listArray[0]
$citiesTemplate          = $templateSuffix + $listArray[1]
$PresidentTemplate       = $templateSuffix + $listArray[2]
# Delete List New , Because we will Create it Later
write-host 211
write-host "Delete List New , Because we will Create it Later..."
Delete-SPList $srcSiteUrl $newListName
Delete-SPList $srcSiteUrl $newListNameCountries
Delete-SPList $srcSiteUrl $newListNamePresident
#read-host
foreach($list in $listArray){
	
	deleteListTemplate $homeweb.Site.Url $templateSuffix 
	
}
[system.gc]::Collect()
foreach($list in $listArray){
	
	saveListTemplate $homeweb $templateSuffix $list
	
}
[system.gc]::Collect()
foreach($list in $listArray){
	
	downloadListTemplate $homeweb.Site.Url $templateSuffix $list $wDir.FullName
	
}
[system.gc]::Collect()
Create-ListOnArchiveFromTemplate $srcSiteUrl $newListName $citiesTemplate
Create-ListOnArchiveFromTemplate $srcSiteUrl $newListNamePresident $PresidentTemplate

foreach($list in $listArray){
	
	deleteListTemplate $homeweb.Site.Url $templateSuffix 
	
}
[system.gc]::Collect()
$stpFiles = get-childItem $wDir.FullName
#$stpFiles | Select FullName




$oldListID = 	get-ListID $srcSiteUrl $listArray[1]
$newListID = 	get-ListID $srcSiteUrl $newListName
write-host "Old City ID : $oldListID" -f Magenta
write-host "new City ID : $newListID" -f Magenta

$oldListPresID = get-ListID $srcSiteUrl $listArray[2]
$newListPresID = get-ListID $srcSiteUrl $newListNamePresident
write-host "Old Presid ID : $oldListPresID" -f Magenta
write-host "new Presid ID : $newListPresID" -f Magenta


$lookUpSTPFile  = Get-Item $(Join-Path $wDir.FullName  $($countriesLookupTemplate + ".stp"))

$replArr = @()

$replArrItm = "" | Select oldListID,newListID
$replArrItm.oldListID = $oldListID
$replArrItm.newListID = $newListID
$replArr += $replArrItm

$replArrItm = "" | Select oldListID,newListID
$replArrItm.oldListID = $oldListPresID
$replArrItm.newListID = $newListPresID
$replArr += $replArrItm

$newSTPFile = replace-STP $lookUpSTPFile $replArr
write-host $newSTPFile
write-host 271
#read-host
#$uploadFullName = get-item -path $newSTPFile
$uplTempl = addListTemplate $homeweb.Site.Url $newSTPFile	
	write-host $newSTPFile
$templCountries = $newSTPFile.BaseName
Create-ListOnArchiveFromTemplate $srcSiteUrl $newListNameCountries $templCountries
[system.gc]::Collect()





#Delete-SPList $srcSiteUrl $newListName

#$uploadName = "GSS-HUM16-2020-upload.stp"
#$uploadFileName = Join-Path $wDir.FullName $uploadName
#$uploadFullName = get-item $uploadFileName
#Write-Host $uploadFullName -f Cyan





