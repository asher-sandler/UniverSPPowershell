function saveListTemplateNoData($spWeb,$itm){
	$TemplateName=$itm.templateFileName
	$TemplateFileName=$itm.templateFileName
	$TemplateDescription=$itm.templateFileName
	$SaveData = $true
 
	$List = $spWeb.Lists[$itm.Title]
	try{
		# https://gss2.ekmd.huji.ac.il/home/_catalogs/lt/Forms/AllItems.aspx
		$List.SaveAsTemplate($TemplateFileName, $TemplateName, $TemplateDescription, $SaveData)
		#start-sleep 5
		<#
	Agriculture
Template GSS_GEN27-2020-2022-07-25-17-56-15-Agriculture already exists
PS C:\AdminDir\Mihzur> .\Copy-DocLibLeft.ps1
Agriculture
Template GSS_GEN27-2020-2022-07-25-17-56-15-Agriculture already exists
PS C:\AdminDir\Mihzur> .\Copy-DocLibLeft.ps1
Agriculture
Exception calling "SaveAsTemplate" with "4" argument(s): 
"The list is too large to save as a template. The size of a template cannot exceed 52428800 bytes."
At C:\AdminDir\Mihzur\Copy-DocLibLeft.ps1:10 char:3
+         $List.SaveAsTemplate($TemplateFileName, $TemplateName, $Templ ...
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (:) [], MethodInvocationException
    + FullyQualifiedErrorId : SPException

List Agriculture Saved as Template GSS_GEN27-2020-2022-07-25-17-56-15-Agriculture
PS C:\AdminDir\Mihzur>	

$webservice = [Microsoft.SharePoint.Administration.SPWebService]::ContentService
Write-Host "Size: " $webservice.MaxTemplateDocumentSize
$webservice.MaxTemplateDocumentSize = 500Mb #250 MB
$webservice.Update()
		#>
		Write-Host "List $($itm.Title) Saved as Template $TemplateFileName" -f Green

	}
	catch
	{
		Write-Host "$($_.Exception.Message)" 	-f Yellow	
	}
}
function get-SiteGroup($siteUrl){
	$strArr = $siteUrl.Split("/")
	$retStr = $($strArr[2].ToLower().replace("2.ekmd.huji.ac.il","").replace(".ekmd.huji.ac.il","")+"_"+$strArr[5]).ToUpper()
	return $retStr
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
Add-PsSnapin Microsoft.SharePoint.PowerShell
$srcSite =     "https://gss2.ekmd.huji.ac.il/home/FacultyofMedicine/MED15-2017/"
$srcSite =     "https://gss2.ekmd.huji.ac.il/home/FacultyofMedicine/MED15-2017"
$srcSite =     "https://gss2.ekmd.huji.ac.il/home/OverseasApplicantsUnit/GEN27-2020/"
$archSubSiteUrl = $srcSite +"Archive-2022-07-25"
$languageID = 1033
$langID = $languageID
$dstSite = $archSubSite
$heDocLibName = "העלאת מסמכים"
$enDocLibName = "Documents Upload"

$webservice = [Microsoft.SharePoint.Administration.SPWebService]::ContentService
Write-Host "Size: " $webservice.MaxTemplateDocumentSize
$webservice.MaxTemplateDocumentSize = 500Mb 
$webservice.Update()

$group = get-SiteGroup $srcSite
$homeweb = Get-SPWeb  $srcSite 
$archSubSite = Get-SPWeb $archSubSiteUrl
$jsonFile = ".\_Mihzur\GSS_GEN27-2020\AllList-copyLeft.json"
$siteListArr = get-content $jsonFile -encoding default | ConvertFrom-Json

foreach($listO in $siteListArr){
	if (-not $listO.Done){
		if (-not ($listO.Title.Contains($heDocLibName) -or $listO.Title.Contains($enDocLibName))){
			$listO.Title
			saveListTemplateNoData $homeweb $listO
			Create-ListOnArchiveFromTemplate $archSubSite $listO
			deleteListTemplateSingle	$homeweb.Site.Url $listO.templateFileName
			#read-host
		}
	}
}