param([string] $groupName = "")

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
function Save-FileAttachements($spObj){
	#write-host $spObj.ID -f Green	
	#write-host $spObj.GroupName -f Green
	$saveDirPrefix = ".\Attachements"
    
	If (!(Test-Path -path $saveDirPrefix))
	{   
		$wDir = New-Item $saveDirPrefix -type directory
	}
	else
	{
		$wDir = Get-Item $saveDirPrefix 
	
	}	
	$saveFullPath = Join-Path $saveDirPrefix $spObj.GroupName
	If (!(Test-Path -path $saveFullPath))
	{   
		$wDir = New-Item $saveFullPath -type directory
	}
	else
	{
		$wDir = Get-Item $saveFullPath 
	
	}
	$attachementsPath = $wDir.FullName
 	
	$siteURL = $spObj.spRequestsSiteURL
	$listName = $spObj.spRequestsListName
	
	write-host $siteURL -f Green
	write-host $listName -f Green
	write-host $attachementsPath -f Green
	$siteUrlC = get-UrlNoF5 $siteURL
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrlC)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials
	$Web = $Ctx.Web
	$ctx.Load($Web)
	$Ctx.ExecuteQuery()
    $listName = "spRequestsFiles"
	#$List = $Web.GetList($spObj.FolderLink)
	$List = $Ctx.Web.lists.GetByTitle($ListName)
	$Ctx.Load($List)
	$Ctx.Load($list.RootFolder)
	$Ctx.Load($list.RootFolder.Files)
	$Ctx.Load($list.RootFolder.Folders)
	$Ctx.ExecuteQuery()
	
	$listUrl = $list.RootFolder.ServerRelativeUrl  
	Write-Host $listUrl  
	#$FilesColl = $List.RootFolder.Files
	
	#$Ctx.Load($FilesColl)
	#$Ctx.ExecuteQuery()
	$flds = $list.RootFolder.Folders
	#$list.RootFolder.Folders	| gm
	$fldLink = $spObj.FolderLink.substring($spObj.FolderLink.LastIndexOf("/")+1).ToUpper().Trim()
	
	foreach($fld in $flds){
		if ($fldLink -eq $fld.Name.ToUpper()){
			write-host $fld.name -f cyan
			$Ctx.Load($fld.Files)
			$Ctx.ExecuteQuery()
			foreach($Attachment in $fld.Files){
				$FileContent = [Microsoft.SharePoint.Client.File]::OpenBinaryDirect($Ctx, $Attachment.ServerRelativeUrl)
				$DownloadPath = Join-Path $attachementsPath $Attachment.Name
				write-host $DownloadPath
				$FileStream = [System.IO.File]::Create($DownloadPath)
				$FileContent.Stream.CopyTo($FileStream)
				$FileStream.Close()
 
			} 
			break
		}
	}
<#
	$Folder = $List.RootFolder
	$FilesColl = $Folder.Files
	$Ctx.Load($Folder)
	$Ctx.Load($FilesColl)
	$Ctx.ExecuteQuery()
  	$Folder
	$list.Title
	$FilesColl.count
 	$list | gm
    #$List = $Ctx.Web.Lists.GetByTitle($listName)
    #$List = $Ctx.Web.Lists.GetList($spObj.FolderLink)
	write-host 65
	read-host
	
    $ListItem= $List.GetItemByID($spObj.ID)
     
    #Get All attachments from the List Item
    $AttachmentsColl = $ListItem.AttachmentFiles
    $Ctx.Load($AttachmentsColl)
    $Ctx.ExecuteQuery()
    write-host 	$attachementsPath -f Yellow
  
    #Get each attachment
    ForEach($Attachment in $AttachmentsColl)
    {
        #Download attachment
        $FileContent = [Microsoft.SharePoint.Client.File]::OpenBinaryDirect($Ctx, $Attachment.ServerRelativeUrl)
		$DownloadPath = Join-Path $attachementsPath $Attachment.FileName
		write-host $DownloadPath
        $FileStream = [System.IO.File]::Create($DownloadPath)
        $FileContent.Stream.CopyTo($FileStream)
        $FileStream.Close()
    }
#>
	
}
$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"
if ([string]::isNullOrEmpty($groupName))
{
	write-host groupName Must be specified 
	write-host in format hss_HUM164-2021 
	
}
else
{
	if (Test-CurrentSystem $groupName){
	    $Credentials = get-SCred		
	    $currentSystem = Get-CurrentSystem $groupName
		
		$wrkSite = $currentSystem.appHomeUrl
		$wrkList = $currentSystem.listName
		 
		
		
		$spRequestsListObj = get-RequestListObject
		
		
		
		if ($spRequestsListObj.GroupName.ToUpper() -eq $groupName.Trim().ToUpper()){
			$spRequestID = $spRequestsListObj.ID
			
			Save-FileAttachements $spRequestsListObj
		}
	}	
}
