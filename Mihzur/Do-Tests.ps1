class lookUpField{
	[boolean]$isLookup
	[string[]]$FieldArr
	
	lookUpField($islook, $fArr){
		$this.isLookup = $islook
		$this.FieldArr = $fArr
	}
	
}
class Applicant{
	    [string]$RealTitle # ":  "applicants",
	    [string]$Title # ":  "applicants",
        [string]$RootFolder #":  "Lists/applicants",
        [string]$BaseTemplate #":  100,
        [string]$templateFileName #":  "GSS_GEN27-2020-2022-07-27-11-40-50-applicants",
        [string]$UIDOld #":  "61b7d406-3f39-416c-a717-217427420b6b",
        [string]$UIDNew #":  null,
        [object]$IsLookupField = [lookUpField]::New($false,$null)
        [boolean]$Done
		
		Applicant($rTitl,$name,$rFold,$bTempl,$templFN,$uiOld,$uiNew,$dne){
			$this.RealTitle = $rTitl
			$this.Title = $name
			$this.RootFolder = $rFold
			$this.BaseTemplate = $bTempl
			$this.templateFileName = $templFN
			$this.UIDOld = $uiOld
			$this.UIDNew = $uiNew
			$this.Done = $dne
		}

}
function gen-ListClass($className , $arr){
	$outFile = ''
	$header = "class $className{"	
$crlf = [char][int]13+[char][int]10

$body = ''+$crlf
#$body += '$Itm = "" | Select '
	foreach($item in $arr)	{
	
		$body += "	["+$item.FieldType+']$'+$item.Name+$crlf
	
	}
	$body += $crlf+$crlf
	$body += "	$className" +'($sourceItem){'+$crlf
	foreach($item in $arr)	{
	

		$body += '		$this.'+$item.Name+" = ["+$item.FieldType+"]"+'$sourceItem["'+$item.DisplayName+'"]'+$crlf
	}
	$body += "	}"+$crlf

	$body += "function	addItem_$className" +'($siteUrl, $listName){'+$crlf
	$body += '		$dstweb = Get-SPWeb $siteUrl'+$crlf
	$body += '		$dstList = $dstweb.Lists[$listName]'+$crlf+$crlf
	$body += '		$listItm = $dstList.AddItem()'+$crlf+$crlf

	foreach($item in $arr)	{
	
		$body += '		$listItm["'+$item.DisplayName+'"] = $this.'+$item.Name+$crlf
	}
	$body += $crlf+'		$listItm.Update()'+$crlf		
	
	$body += "	}"+$crlf
	
	$footer = "}"

$outFile = $header + $body + $footer
return $outFile
}
function gen-PowerShellSaveObjDef($arr){
	$outFile = ''
$crlf = [char][int]13+[char][int]10

$body = ''+$crlf

	$body += $crlf+$crlf
	foreach($item in $arr)	{
	

		$body += '	$listItm["'+$item.DisplayName+'"] ='+$crlf
	}	
	$footer = ""
	$header = ""
$outFile = $header + $body + $footer
return $outFile
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
function saveListTemplate($spWeb,$itm,$SaveData){
	$TemplateName=$itm.templateFileName
	$TemplateFileName=$itm.templateFileName
	$TemplateDescription=$itm.templateFileName
	#$SaveData = $true
 
	$List = $spWeb.Lists[$itm.RealTitle]
	
	try{
		# https://gss2.ekmd.huji.ac.il/home/_catalogs/lt/Forms/AllItems.aspx
		$List.SaveAsTemplate($TemplateFileName, $TemplateName, $TemplateDescription, $SaveData)
		#start-sleep 5
		Write-Host "List $($itm.RealTitle) Saved as Template $TemplateFileName" -f Green

	}
	catch
	{
		Write-Host "Template $TemplateFileName already exists"	-f Yellow	
	}
}
function get-SiteGroup($siteUrl){
	$strArr = $siteUrl.Split("/")
	$retStr = $($strArr[2].ToLower().replace("2.ekmd.huji.ac.il","").replace(".ekmd.huji.ac.il","")+"_"+$strArr[5]).ToUpper()
	return $retStr
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
function get-TypeOfField($fieldType){
	$retValue = "string"
	switch ($fieldType)
	{
		"Text" {
			$retValue = "string"
			Break
			}
		
		"Choice" {
			$retValue = "string"
			Break
			}
			
		"Note" {
			$retValue = "string"
			Break
			}
			
		"Boolean" {
			$retValue = "Boolean"
			Break
			}
			
		"DateTime" {
			$retValue = "DateTime"
			Break
			}
			
		Default {
			$retValue = "string"
				}

			
	}
	return $retValue				
}
function gen-ClassItem($className, $siteUrl,$listTitle) {
	$spWeb = get-SPWeb $siteUrl
	$list = $spWeb.Lists[$listTitle]
	$listFields = $list.Fields
	$crlf = [char][int]13+[char][int]10	
	$FieldXML = '<Fields>'
	foreach($field in $listFields){
		# write-host "$($field.Title) : Hidden : $($field.Hidden)"
		if ($field.SchemaXml.Contains('ReadOnly="TRUE"')){
		}
		else{
			if ($field.SchemaXml.Contains('Group="_Hidden"')){
			}
			else{
		
				If (!($field.Hidden -or $field.ReadOnly )){
					$FieldXML += $field.SchemaXml+$crlf
				}
		
			}
		}	
	}
	$FieldXML += '</Fields>'
	$FieldXML | out-file "F.xml" -Encoding Default
	#write-host 168
	$arr = @()
	Select-Xml -Content $FieldXML -XPath "/Fields/Field" | ForEach-Object {
				$nodeName = "" | Select Name,DisplayName,FieldType;
				$nodeName.Name = $_.Node.Name
				$nodeName.DisplayName = $_.Node.DisplayName
				$tp = $_.Node.Type
				$nodeName.FieldType = get-TypeOfField $tp
				$doAddToArray = $true
				if (($_.Node.Name -eq "ID")){
					
					$doAddToArray = $false
				}
				if (($_.Node.Name -eq "Attachments")){
					
					$doAddToArray = $false
				}
				if($doAddToArray){
					$arr += $nodeName	
				}				
				
			}
			#write-host 185
			$clName = $className+"-"+$listTitle
			#gen-ListClass $clName $arr | out-file "Template-$($className).ps1" -Encoding Default
			#gen-PowerShellSaveObjDef $arr | out-file "TemplateOut-$($className).txt" -Encoding Default
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
		#$srcWhoEdit   = $sFile.Item["Editor"  ]
		#$srcResponse  = $sFile.Item["sentResponse"]
		
		
		#$dstfolder =  $dstweb.getfolder($dstList.RootFolder.Url)
		#$dstfolderURL =  $dstList.RootFolder.Url
		#$dstfileName = $dstfolder  + "/"+ $fileName
		#$dstfileName = $fileName
		#write-Host $dstfileName
		#write-host $srcDocTypeID
		#write-host $srcDocTypeValue
		$newDocTypeID = 1 # Map-DocType $dstSite $srcDocTypeValue 
		$dstFile = $dstFolder.Files.Add($sFile.Name,$srcData,$true)

		#write-host "srcDateCreat : $srcDateCreat"
		#write-host "srcDateEdit  : $srcDateEdit"
		#write-host "srcWhoCreat  : $srcWhoCreat"
		#write-host "srcWhoEdit   : $srcWhoEdit"
		
		$dstFile.Item["Created" ] = $srcDateCreat
		$dstFile.Item["Modified"] = $srcDateEdit
		$dstFile.Item["Author"  ] = $srcWhoCreat
		$dstFile.Item["Editor"  ] = $srcWhoEdit
		#$dstFile.Item["sentResponse"] = $srcResponse
		#$dstFile.Item[$srcDocTypeFieldName] = $newDocTypeID

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
start-Transcript do-test.log
$moduleFileName = "Template-GSS_GEN27-2020.ps1"
. "$moduleFileName"
# Set-PSDebug -Trace 1
$srcSiteUrl =     "https://gss2.ekmd.huji.ac.il/home/OverseasApplicantsUnit/GEN27-2020/"
$archSubSite = $srcSiteUrl +"Archive-2022-07-27"
$group = get-SiteGroup $srcSiteUrl
$homeweb = Get-SPWeb  $srcSiteUrl
$archSubSite = Get-SPWeb $archSubSite

$group
$listO = [Applicant]::New( "applicants", "applicantsWithData","Lists/applicantsWithData", 100,
						"GSS_GEN27-2020-2022-07-27-11-40-50-applicants",
                        "61b7d406-3f39-416c-a717-217427420b6b",
						$null,$false)
        
$listO

$listO1 = [Applicant]::New( "applicants", "applicantsNoData","Lists/applicantsNoData", 100,
						"GSS_GEN27-2020-2022-07-27-11-40-51-applicants",
                        "61b7d406-3f39-416c-a717-217427420b6b",
						$null,$false)
        
$listO1

<#
   {
        "Title":  "Documents Upload Aaron Levyvalensi 19ef13223",
        "RootFolder":  "EKMDaaronle",
        "BaseTemplate":  101,
        "templateFileName":  "GSS_GEN27-2020-2022-07-27-11-40-50-Documents Upload Aaron Levyvalensi 19ef13223",
        "UIDOld":  "6458967b-7da6-4079-b955-a9cb90c77715",
        "UIDNew":  null,
        "IsLookupField":  null,
        "Done":  false
    },
#>
$doclibAL = [Applicant]::New( "Documents Upload Aaron Levyvalensi 19ef13223", "AL-DOCLIB","AL-DOCLIB", 101,
						"GSS_GEN27-2020-2022-07-27-11-40-50-Documents Upload Aaron Levyvalensi 19ef13223",
                        "6458967b-7da6-4079-b955-a9cb90c77715",
						$null,$false)
     
gen-ClassItem $group $srcSiteUrl $listO.RealTitle 





#write-host 213
#read-host

write-host "Save Applicants List Template with data"
Measure-Command {saveListTemplate $homeweb $listO $true}
write-host "Save Applicants List Template without data"
Measure-Command {saveListTemplate $homeweb $listO1 $false}
write-host "Save DocLib  Template with data"
Measure-Command {saveListTemplate $homeweb $doclibAL $true}
[system.gc]::Collect()

write-host "Create Applicants from Template with Data"
Measure-Command { Create-ListOnArchiveFromTemplate $archSubSite $listO}
[system.gc]::Collect()
write-host "Create Applicants from Template No Data"
Measure-Command { Create-ListOnArchiveFromTemplate $archSubSite $listO1}
$srcList = $homeweb.Lists[$listO.RealTitle]
$sitems = $srcList.Items
write-host "Transfer rows from Old Applicants (count: $($sitems.Count)) to Applicants No Data"
[system.gc]::Collect()
Measure-Command {
foreach($srcItem in $sitems){
	$objItem = [Xapplicants]::New($srcItem)
	#$objItem
	$objItem.addItem_Xapplicants($archSubSite.URL,$listO1.Title)
	#break
	#read-host
	#[system.gc]::Collect()
}
}
[system.gc]::Collect()

write-host "Create and Delete 100 Times DocLib From Template with Data"
Measure-Command {
for($i=1;$i -le 100;$i++){
	
	Create-ListOnArchiveFromTemplate $archSubSite $doclibAL

	$list = $archSubSite.Lists[$doclibAL.Title];
	$list.AllowDeletion = $true;
	$list.Update();
	$list.Delete();


}
}
write-host "Create and Copy 100 Times DocLib Files from Source to Archive"
Measure-Command {
	$archSubSite.Lists.Add($doclibAL.RealTitle, $doclibAL.RealTitle, "DocumentLibrary")
	$list = $archSubSite.Lists[$doclibAL.RealTitle];
	$list.AllowDeletion = $true;
	$list.Update();
	$list.Delete();


for($i=1;$i -le 100;$i++){
	$archSubSite.Lists.Add($doclibAL.RealTitle, $doclibAL.RealTitle, "DocumentLibrary")

    CopyDocLib $srcSiteUrl $archSubSite.Url 1033  $doclibAL.RealTitle
	$list = $archSubSite.Lists[$doclibAL.RealTitle];
	$list.AllowDeletion = $true;
	$list.Update();
	$list.Delete();
}}
write-host "Delete Applicants List Templates"
Measure-Command {deleteListTemplate	$homeweb.Site.Url $group}

write-host "Delete Applicants Lists"
Measure-Command {
	write-host $listO.Title;
	$list = $archSubSite.Lists[$listO.Title];
	$list.AllowDeletion = $true;
	$list.Update();
	$list.Delete();
}

Measure-Command {
	write-host $listO1.Title;
	$list = $archSubSite.Lists[$listO1.Title]
	$list.AllowDeletion = $true
	$list.Update()
	$list.Delete()
}
stop-transcript
 


