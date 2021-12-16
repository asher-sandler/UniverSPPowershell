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

 
 $siteName = "https://portals2.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace";
  $sourceListName = "Fruits"
 
 write-host "URL: $siteURL" -foregroundcolor Yellow
 
 $siteUrl = get-UrlNoF5 $siteName

 $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
 $Ctx.Credentials = $Credentials
 
 $web = $ctx.web
 $ctx.load($web) 
 $ctx.executeQuery() 
 
 
 $lists = $ctx.web.Lists 
 $list = $lists.GetByTitle($sourceListName) 
 $ctx.load($list)      
 $ctx.executeQuery() 
 $RootFolder = $list.RootFolder
 $ctx.load($RootFolder)      
 $ctx.executeQuery()
 
 #$RootFolder | gm
 #$web| gm
 #$web.ServerRelativeUrl
 #$RootFolder.ServerRelativeUrl
 
 $newformURL = $RootFolder.ServerRelativeUrl + "/NewFormAlt.aspx"
 #$formURL
 #Microsoft.SharePoint.SPTemplateFileType
 $FileCreationInfo = New-Object Microsoft.SharePoint.Client.FileCreationInformation
 $FileCreationInfo.Overwrite = $true
 $FileCreationInfo.URL = $newformURL
 $FileUploaded = $RootFolder.Files.Add($newformURL) #,"FormPage")
$Ctx.Load($FileUploaded)
	$Ctx.ExecuteQuery()
 
 #$newForm = $rootFolder.Files.Add($newFormUrl, SPTemplateFileType.FormPage); 
 
 #$rootFolderUrl = $RootFolder.Url 
 # $ctx.load($rootFolderUrl)      
 #$ctx.executeQuery()
 #$rootFolderUrl
 
 
 