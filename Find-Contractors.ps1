function find-pdf($siteUrl, $pdfIdVal ){
	
	$pdfFileName=""
	$Ctx1 = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
	$Ctx1.Credentials = $Credentials

	$List = $Ctx1.Web.lists.GetByTitle("Final")	
	$Query = New-Object Microsoft.SharePoint.Client.CamlQuery
	
	$query.ViewXml = "<View><Query><Where><Contains><FieldRef Name='FileLeafRef' /><Value Type='File'>$pdfIdVal</Value></Contains></Where></Query></View>"
	$files = $List.GetItems($query)
	$Ctx1.Load($files)
	$Ctx1.ExecuteQuery()
	
	if ($files.Count -gt 0){
		$filePdf  = $files[0].File
		$Ctx1.Load($filePdf)
		$Ctx1.ExecuteQuery()

		$pdfFileName=$filePdf.Name
	}
	return $pdfFileName
}

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
 $contractors =@()
 <#
 $contractors += "305468134"
 $contractors += "305481707"
 $contractors += "205678188"
 $contractors += "205678188"
 $contractors += "303866834"
 $contractors += "303866834"
 $contractors += "206120453"
 $contractors += "036437614"
 #>
 $contractors += "516748548"
 
 $contractor = $contractors |Select-Object -Unique 
	
 $sites = @()
 $sites += "https://crs.ekmd.huji.ac.il/home/services/2019";
 $sites += "https://crs2.ekmd.huji.ac.il/home/exempt/2019";
 $sites += "https://crs2.ekmd.huji.ac.il/home/murshe/2019";
 $ListName = "contractors" 

 #$siteName = "https://portals2.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace";
 
 forEach ($contractor in $contractors){
	 $IsFound = $false
	 $studentIDFromSP = ""
	 forEach($siteName in $sites){
		 $siteUrl = get-UrlNoF5 $siteName


		 #write-host "URL: $siteURL" -foregroundcolor Yellow
		 
		 
		 $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
		 $Ctx.Credentials = $Credentials
		 
		#$List=$Ctx.Web.Lists.GetByTitle($ListName)
		#$Ctx.Load($List)
		#$Ctx.ExecuteQuery()
		
		$Web = $Ctx.Web
		$ctx.Load($Web)
		$Ctx.ExecuteQuery() 

		#Get All List Items

		$List = $Ctx.Web.lists.GetByTitle($listName)	
		
		$Query = New-Object Microsoft.SharePoint.Client.CamlQuery
		$Query.ViewXml ="<View><Query><Where><Eq><FieldRef Name='studentId' /><Value Type='Text'>$contractor</Value></Eq></Where></Query></View>"
		
		$ListItems = $List.GetItems($Query)
		#$ListItems = $List.RenderListData($Query)
		$Ctx.Load($ListItems)
		$Ctx.ExecuteQuery()
		#$ListItems
		forEach($itm in $ListItems ){
			#Write-Host  $itm["Month"]
			$IsFound = $true			
			#Write-Host  $itm.ID
			$studentIDFromSP = $([string]($itm["studentId"])).Trim()
			Write-Host $($siteName+"/Lists/"+$ListName+"/EditForm.aspx?ID="+$itm.ID) -f Cyan
			Write-Host "Contractor from Param             : " $contractor -f Cyan
			Write-Host "studentId  in SP List $ListName : " $studentIDFromSP -f Green
			#https://crs2.ekmd.huji.ac.il/home/murshe/2019/Lists/contractors/EditForm.aspx?ID=3161&Source=https%3A%2F%2Fcrs2%2Eekmd%2Ehuji%2Eac%2Eil%2Fhome%2Fmurshe%2F2019%2FLists%2Fcontractors%2FAllItems%2Easpx
		}
		if ($IsFound) {
			$filPDFName= find-pdf $siteUrl $studentIDFromSP
			if ([string]::IsNullOrEmpty($filPDFName)){
				
				Write-Host "PDF File                          :  Missing" -f Yellow
				write-Host "-----------------------"
				write-Host
				
			}
            else{			
				Write-Host "PDF File                          :  $filPDFName" -f Green
				write-Host "-----------------------"
				write-Host
			}
			
			break
		}
	 }
	 if (!$IsFound){
		 Write-Host "Contractor $contractor not Found" -f Yellow
	 }
 }
 