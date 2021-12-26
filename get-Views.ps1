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

 
 $siteSrcURL ="https://grs2.ekmd.huji.ac.il/home/OverseasApplicantsUnit/GEN32-2022";
 
 $sourceListName = "Applicants"
 $needViewName = "administration"
 $needViewName = "rakefet"
 
 
  
 
 write-host "URL: $siteSrcURL" -foregroundcolor Yellow
 write-host "SourceList: $sourceListName" -foregroundcolor Cyan
 
 $siteUrl = get-UrlNoF5 $siteSrcURL

 $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
 $Ctx.Credentials = $Credentials
 
 $Web = $Ctx.Web
 $ctx.Load($Web)
 $Ctx.ExecuteQuery()
 
 $sList = $Web.lists.GetByTitle($sourceListName)
 $ctx.Load($sList)
 $Ctx.ExecuteQuery()
 
 $srcdocLibName = $sList.Title
 write-host "Opened List : $srcdocLibName"

 $schemaListSrc1 =  get-ListSchema $siteUrl $srcdocLibName
 
 $sourceListObj = get-SchemaObject $schemaListSrc1
 $outFileName = "JSON\"+$srcdocLibName+"-ListSource.json"
 $sourceListObj | ConvertTo-Json -Depth 100 | out-file $outFileName
 Write-Host "Created File : $outFileName"
 
 $objViews = Get-AllViews $srcdocLibName $siteUrl 
 $outFileName = "JSON\"+$srcdocLibName+"-Views.json" 
 $objViews | ConvertTo-Json -Depth 100 | out-file $($outFileName) 
 Write-Host "Created File : $outFileName"
 
 $outViewFields = @()
 foreach($view in $objViews){
		if ($view.Title -eq $needViewName){
			
			foreach($fld in $view.Fields){
				$outViewFields += $fld
			}
			$outFileList = @()
			
			foreach ($fldn in $outViewFields)
			{
				$outFileList += '"'+$fldn+'",'
			}
			$outFileName = $("Evgenia-Custom Forms\"+$needViewName+".txt")
			$outFileList | Out-File $outFileName -encoding UTF8
			write-host "$needViewName Found" -f Green
			write-host "Created File : $outFileName" -f Green
			
			break
			
			
		}		
 }

$excludeFromFields = @()
foreach($fldobj in $sourceListObj){
	$addListToExclude = $true
	foreach($fldx in $outViewFields){
		if ($fldx -eq $fldobj.DisplayName){
			$addListToExclude = $false
			break;
		}
	}
	if ($addListToExclude){
		
		$excludeFromFields += '"'+$fldobj.DisplayName+'",'	
	}
	
}
$outFileName = $("Evgenia-Custom Forms\"+$needViewName+"-exclude.txt")
$excludeFromFields | Out-File $outFileName -encoding UTF8
write-host "Created File : $outFileName" -f Green

 
 
	 
 
