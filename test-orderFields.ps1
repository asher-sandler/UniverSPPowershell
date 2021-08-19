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

$cred = get-SCred

 $siteURL = "https://portals.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace";
 #$siteURL = "https://portals.ekmd.huji.ac.il/home/EDU/stdFolders";
 
 write-host "URL: $siteURL" -foregroundcolor Yellow
 $ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl) 
 $ctx.Credentials = $cred
 
 
	$Lists = $Ctx.Web.Lists
	$Ctx.Load($Lists)
	$Ctx.ExecuteQuery()
	$ListName = "testOrder"
	$List = $Ctx.Web.lists.GetByTitle($ListName)
	
	$list
	
	
	
	$contentTypes = $list.ContentTypes
    $ctx.Load($contentTypes)
	#$ctx.Load($contentTypes.FieldLinks)
    $ctx.ExecuteQuery()
	
	$itemContenType = $contentTypes[0]
	$ctx.Load($itemContenType)
	#$ctx.Load($contentTypes.FieldLinks)
    $ctx.ExecuteQuery()
	
	
	
	$FieldLinks = $itemContenType.FieldLinks
	
	$ctx.Load($FieldLinks)
	#$ctx.Load($contentTypes.FieldLinks)
    $ctx.ExecuteQuery()
	
	$FieldLinks
	
	
	$orderFields = @()
	$orderFields +='Name'
	$orderFields +='Phone_x0020_Number'
	$orderFields +='_x0410__x0434__x0440__x0435__x04'
	$orderFields +='Surname'

	
	$FieldLinks.Reorder($orderFields);
	$itemContenType.Update($false);
	$ctx.ExecuteQuery()
	
	
<#
	  #Making generic list of content type ids in passed order
		#
		$ctList = New-Object System.Collections.Generic.List[Microsoft.SharePoint.Client.ContentTypeId]
		Foreach($ct in $ContentTypeNamesInOrder){
			$ctToInclude = $contentTypes | Where {$_.Name -eq $ct}
			$ctList.Add($ctToInclude.Id)
		}


		#Updating content type order
		#
		$list.RootFolder.UniqueContentTypeOrder = $ctList
		$list.Update()
		$ctx.Load($list)
		$ctx.ExecuteQuery()
		 
		Write-Host "Content Types Reordered successfully" -ForegroundColor Green

#>


