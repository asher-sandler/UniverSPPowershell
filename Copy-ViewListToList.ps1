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
function Check-ForFieldsExistsOnDest ($vFields, $dstListObj){
	$outObj = "" | Select AllFieldExists, FieldNotExistsList
	$outObj.AllFieldExists = $true
	$outObj.FieldNotExistsList = @()
	foreach($fld in $vFields){
		$fldExist = $false
		foreach($dstField in $dstListObj){
			if ($dstField.Name -eq $fld){
				$fldExist = $true
				break
			}
		}
		if (!$fldExist){
			if (($fld -eq "Created") -or $($fld -eq "Modified")){
			}
			else{	
				$outObj.AllFieldExists = $false
				$outObj.FieldNotExistsList += $fld
			}
		}
	}
	return $outObj
}
$Credentials = get-SCred

 
 $siteSrcURL = "https://grs2.ekmd.huji.ac.il/home/OverseasApplicantsUnit/GEN27-2020";
 $sourceList = "/home/OverseasApplicantsUnit/GEN27-2020/Lists/studies/AllItems.aspx"
 
 $destSiteURL = get-UrlNoF5 "https://grs2.ekmd.huji.ac.il/home/OverseasApplicantsUnit/GEN31-2021"
 $destListName = "Applicants"
 
 $viewToCopy = "245"
 
  
 
 write-host "URL: $siteSrcURL" -foregroundcolor Yellow
 write-host "DestURL: $destSiteURL" -foregroundcolor Cyan
 
 $siteUrl = get-UrlNoF5 $siteSrcURL

 $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
 $Ctx.Credentials = $Credentials
 
 $Web = $Ctx.Web
 $ctx.Load($Web)
 $Ctx.ExecuteQuery()
 
 $sList = $Web.GetList($sourceList);
 $ctx.Load($sList)
 $Ctx.ExecuteQuery()
 
 $srcdocLibName = $sList.Title
 write-host "Opened List : $srcdocLibName"

 $schemaListSrc1 =  get-ListSchema $siteSrcURL $srcdocLibName
 
 $sourceListObj = get-SchemaObject $schemaListSrc1
 $outFileName = "JSON\"+$srcdocLibName+"-ListSource.json"
 $sourceListObj | ConvertTo-Json -Depth 100 | out-file $outFileName
 Write-Host "Created File : $outFileName"


 $schemaListDst1 =  get-ListSchema $destSiteURL $destListName
 
 $dstListObj = get-SchemaObject $schemaListDst1
 $outFileName = "JSON\"+$destListName+"-ListDest.json"
 $dstListObj | ConvertTo-Json -Depth 100 | out-file $outFileName
 Write-Host "Created File : $outFileName"
  
 $outFileName = "JSON\"+$srcdocLibName+"-Views.json" 
 if (Test-Path $outFileName){
	 $objViews = get-content $outFileName -encoding default | ConvertFrom-Json
			
 }
 else
 {
	$objViews = Get-AllViews $srcdocLibName $siteUrl
	$objViews | ConvertTo-Json -Depth 100 | out-file $($outFileName) 
 }
  
 Write-Host "Created File : $outFileName"
 
foreach($view in $objViews){
	if ($view.Title -eq $viewToCopy){
		$allFieldsExistsOnDest = Check-ForFieldsExistsOnDest $view.Fields $dstListObj 
		if (!$allFieldsExistsOnDest.AllFieldExists){
			Write-Host "Fields not existing on Destination List $destListName :" -f Yellow
			foreach($f in $allFieldsExistsOnDest.FieldNotExistsList){
				write-host $f -f Yellow
			}			
		}
		
		
	}		
 } 
 
 
 foreach($view in $objViews){
	if ($view.Title -eq $viewToCopy){
		write-host "View : $viewToCopy"
		$viewExists = Check-ViewExists $destListName  $destSiteURL $view 
		write-host "View Exists : $($viewExists.Exists)"
		
        if (!$($viewExists.Exists)){
			$allFieldsExistsOnDest = Check-ForFieldsExistsOnDest $view.Fields $dstListObj 
			if ($allFieldsExistsOnDest.AllFieldExists){
				$viewName = $($view.Title)
				if ([string]::isNullOrEmpty($viewName)){
					$viewName = $($view.ServerRelativeUrl.Split("/")[-1]).Replace(".aspx","")
				}
				write-host "view $viewName does Not exists on $destSiteURL" -foregroundcolor Yellow
				write-host "ViewQuery : $($view.ViewQuery)"
				write-host "Check for View! "
				
				$viewDefault = $false
				Create-NewView $destSiteURL $destListName $viewName  $($view.Fields) $($view.ViewQuery) $($view.Aggregations) $viewDefault
			}
			else
			{
				Write-Host "Fields not existing on Destination List $destListName :" -f Yellow
				foreach($f in $allFieldsExistsOnDest.FieldNotExistsList){
					write-host $f -f Yellow
				}
			}
		}
		else
		{
			write-host "view $($view.Title) exists on Site: $destSiteURL List: $destListName" -foregroundcolor Cyan

		}

	}
 }			
 
 