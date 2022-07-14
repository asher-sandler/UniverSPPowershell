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

 
 $siteName = "https://grs2.ekmd.huji.ac.il/home/Agriculture/AGR13-2021";
 $ListName = "Applicants"
 $fieldToReplace = "deadlineStage1"
 $dt=Get-Date
 $dt1=$dt.AddYears(1).AddDays(10)

 $siteUrl = get-UrlNoF5 $siteName

 write-host "URL: $siteURL" -foregroundcolor Yellow
 $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
 $Ctx.Credentials = $Credentials
	
 #Get the List
 $List = $Ctx.Web.lists.GetByTitle($ListName)
 
 $Query = New-Object Microsoft.SharePoint.Client.CamlQuery
 $qry = "<View><Query></Query></View>"
 $Query.ViewXml = $qry

 #Get All List Items matching the query
 $ListItems = $List.GetItems($Query)
 $Ctx.Load($ListItems)
 $Ctx.ExecuteQuery()
 
 $recordsCount = $ListItems.Count
 $i=1
 foreach($listItem in $listItems){
 
    $id = $listItem.ID
	write-host "$i /    $recordsCount" 
	$lItem = $List.GetItemByID($id)
	$Ctx.Load($lItem)
	$Ctx.ExecuteQuery()
	write-host $lItem[$fieldToReplace] -f Yellow

	write-host $dt1 -f Yellow
	$lItem[$fieldToReplace] = $dt1
	$lItem.Update()
	$Ctx.ExecuteQuery()
	$i=$i+1
	#read-host
 
 }