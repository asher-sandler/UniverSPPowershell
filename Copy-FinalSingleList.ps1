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

<#

Columns need to be built according to an Excel file attachment.

Spreadsheet Teaching Fellows - https://gss2.ekmd.huji.ac.il/home/general/GEN31-2021/Final

Spreadsheet Teaching Staff - https://gss2.ekmd.huji.ac.il/home/general/GEN32-2022/Final

#>

$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"

$Credentials = get-SCred

 
 $siteName = "https://gss2.ekmd.huji.ac.il/home/general/GEN31-2021";
 
 $sourceListName = "Final"


  
 $siteUrl = get-UrlNoF5 $siteName
 write-host "URL: $siteSrcURL" -foregroundcolor Yellow
 write-host "SourceList: $sourceListName" -foregroundcolor Cyan

 $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
 $Ctx.Credentials = $Credentials
 
 
 $schemaListSrc1 =  get-ListSchema $siteUrl $sourceListName
 
 $schemaListObj = get-SchemaObject $schemaListSrc1
 $outFileName = "JSON\"+$srcdocLibName+"-GEN31-2021-ListSource.json"
 $schemaListObj | ConvertTo-Json -Depth 100 | out-file $outFileName
 Write-Host "Created File : $outFileName" -f Yellow
 
 
 $oldSiteURL = get-UrlNoF5 "https://gss2.ekmd.huji.ac.il/home/general/GEN32-2022"
 $newSiteURL = $siteUrl
 $listName = $sourceListName
 write-host
 write-host "New Site: $newSiteURL" -f Cyan
 write-host "Old Site: $oldSiteURL" -f Magenta
 write-host Press a key...
 read-host
		
 create-ListfromOld	$newSiteURL $oldSiteURL $listName
 
 $FormOrd32   = get-FormFieldsOrder $listName $oldSiteURL  
 $outfile = 	$("JSON\"+$listName+"-GEN32-2022.json") 
 $FormOrd32 | ConvertTo-Json -Depth 100 | out-file $outfile
 write-host "Created File : $outfile" -f Yellow
 
 reorder-FormFields $listName	$newSiteURL $FormOrd32
  
 
 