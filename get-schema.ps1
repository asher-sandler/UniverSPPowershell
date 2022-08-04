
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

	$Credentials = get-SCred

 
	
	$siteURL = "https://portals2.ekmd.huji.ac.il/home/EDU/stdFolders"
	$siteURL = "https://grs.ekmd.huji.ac.il/home/Education/EDU63-2022/"
	$siteURL = "https://scholarships.ekmd.huji.ac.il/home/NaturalScience/SCI97-2022"
	
	$sitePath = "/home/NaturalScience/SCI97-2022/"
	$siteDomain = "https://scholarships.ekmd.huji.ac.il"
	$siteURL = $siteDomain+$sitePath
	$listName = "לימודי הוראה"
	$listName = "applicants"
	$listName = "Physics"
	
	#$schema = get-ListSchema $siteURL $listName
	$listNameURL = $sitePath + $listName
	$schema = get-ListSchemaByUrl $siteURL $listNameURL
	$listTitle = get-ListTitleByURL $siteURL $listNameURL
	write-host $listTitle
	#$outFile = "JSON\TeachCert.json"
	$outFile = "JSON\SCI97-2022-"+$listName+".json"
	$schema | ConvertTo-Json -Depth 100 | out-file $outFile -Encoding Default
	$schemaTXT = @()
	foreach($field in $schema){
		$schemaTXT += $field
	}
	$outFile = "JSON\SCI97-2022-"+$listName+".txt"
	$schemaTXT | Out-File $outFile -encoding UTF8
	
	$schemaXML = get-Content "SCI\HSS-SCI-Fields.txt" -Encoding UTF8 
	foreach($fieldSchema in $schemaXML){
	add-SchemaFields "https://scholarships.ekmd.huji.ac.il/home/NaturalScience/SCI98-2022" $listTitle $fieldSchema
	
	}
	
 
 
 
