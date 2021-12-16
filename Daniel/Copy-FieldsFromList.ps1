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
. "..\Utils-Request.ps1"
. "..\Utils-DualLanguage.ps1"

$Credentials = get-SCred


$grsSite = "https://grs.ekmd.huji.ac.il/home"
$grsList = "availableGRSList"

 
 $siteName = "https://grs2.ekmd.huji.ac.il/home/Education/EDU52-2021/";
 #$newSite  = "https://grs2.ekmd.huji.ac.il/home/Education/EDU65-2022"
 $docLibName = "Final"
 $oldSite = get-UrlNoF5 $siteName
 
 $CtxGrs = New-Object Microsoft.SharePoint.Client.ClientContext($grsSite)
 $CtxGrs.Credentials = $Credentials
 
 $ListGrs = $CtxGrs.Web.lists.GetByTitle($grsList) 
 
 $Query = New-Object Microsoft.SharePoint.Client.CamlQuery
 $qry = "<View><Query>
   <Where>
<And>
     <Gt>
         <FieldRef Name='Created' />
         <Value IncludeTimeValue='TRUE' Type='DateTime'>2021-08-01T00:00:01Z</Value>
      </Gt>
         <Contains>
         <FieldRef Name='relativeURL' />
         <Value Type='Text'>EDU</Value>
      </Contains>

</And>
   </Where>
</Query></View>"
 $Query.ViewXml = $qry 
 $ListItems = $ListGrs.GetItems($Query)
 $CtxGrs.Load($ListItems)
 $CtxGrs.ExecuteQuery()
 $grsUrls = @()
 foreach($listItem in $listItems)
 {
	$grsUrls += $listItem["url"] 
 }
 $grsUrls
 write-host "Press Any Key..."
 Read-Host

 write-host "URL: $oldSite" -foregroundcolor Yellow
 write-host "Opened List : $docLibName"
 $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($oldSite)
 $Ctx.Credentials = $Credentials
	
 $schemaListSrc1 =  get-ListSchema $oldSite $docLibName
	
 $sourceListObj = get-SchemaObject $schemaListSrc1
 $outFileName = "..\JSON\"+$docLibName+"-ListSource.json"
 $sourceListObj | ConvertTo-Json -Depth 100 | out-file $outFileName
 Write-Host "Created File : $outFileName"
 Read-Host  
 foreach($siteGrsURL in $grsUrls){
	$newSite =  get-UrlNoF5 $siteGrsURL
 

	write-host "Copy structure $docLibName" -f Cyan
	write-host "From : $oldSite" -f Magenta
	write-host "To : $newSite" -f Green
	create-ListfromOld	$newSite  $oldSite $docLibName
	#read-host
 }
 
 