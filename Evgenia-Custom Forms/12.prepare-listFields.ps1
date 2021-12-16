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

 
 #$siteSrcURL = "https://portals2.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace";
 $siteSrcURL = "https://grs2.ekmd.huji.ac.il/home/OverseasApplicantsUnit/GEN32-2022";
 #$sourceList = "/home/huca/EinKarem/ekcc/QA/AsherSpace/Lists/TeachingStudies"
 $sourceList = "/home/OverseasApplicantsUnit/GEN32-2022/Lists/applicants"
 
 
  
 
 write-host "URL: $siteSrcURL" -foregroundcolor Yellow
 write-host "Source List: $sourceList" -foregroundcolor Cyan
 
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
 write-host "Opened List : $srcdocLibName" -f Magenta

 $schemaListSrc1 =  get-ListSchema $siteSrcURL $srcdocLibName
 
 $sourceListObj = get-SchemaObject $schemaListSrc1
 $outFileName = "..\JSON\"+$srcdocLibName+"-ListSource.json"
 $sourceListObj | ConvertTo-Json -Depth 100 | out-file $outFileName
 Write-Host "Created File : $outFileName" -f Green
 
 $fieldList = @()
 $fieldList += ";* Read Field"
 $fieldList += ";+ Edit Field. Can be used simultaneously *+"
 $fieldList += "; No Sign : Exclude"
 $fieldList += "; Comment"
 $fieldList += "; ^ - freezed file (no rewrite)"
 $fieldList += "; "
 
 forEach($field in $sourceListObj){
	 if ($field.DisplayName -ne "Attachments"){
		$fieldList += "+"+$field.DisplayName
	 }
 }

 $outFileName = $srcdocLibName+"-FieldList.txt"
 
 
 $fileIsFreezed = $false
 if (Test-Path $outFileName){
	 $fileFields =  get-Content $outFileName -Encoding UTF8 -raw
	 if ($fileFields.Contains("^")){
		$fileIsFreezed = $true 
	 }
	 
 }
 if (!$fileIsFreezed){
	$fieldList | Out-File $outFileName -Encoding UTF8
	Write-Host "Created File : $outFileName" -f Green
 }
 else{
	Write-Host "File : $outFileName is Freezed. Not Rewrited" -f Cyan
 	 
 }
 
 
 
 
 

 