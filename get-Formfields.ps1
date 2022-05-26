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

 
 $siteName = "https://grs2.ekmd.huji.ac.il/home/OverseasApplicantsUnit/GEN32-2022/";
 $srcdocLibName = "applicants"
 
 write-host "URL: $siteURL" -foregroundcolor Yellow
 
 $siteUrl = get-UrlNoF5 $siteName

 $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
 $Ctx.Credentials = $Credentials
 
 #$krkFormOrd    = get-FormFieldsOrder $srcdocLibName $siteURL  
 $outfile = 	$("JSON\"+$srcdocLibName+"-32-KrakoverFormOrder.json") 
  #$krkFormOrd | ConvertTo-Json -Depth 100 | out-file $outfile
  #write-host "Created File : $outfile" -f Yellow
  
 $FormOrd32 = get-content $outfile -encoding default | ConvertFrom-Json
  reorder-FormFields $srcdocLibName	$siteURL $FormOrd32
  
 $siteName = "https://grs2.ekmd.huji.ac.il/home/OverseasApplicantsUnit/GEN31-2021/";

  $siteUrl = get-UrlNoF5 $siteName
  #$krkFormOrd    = get-FormFieldsOrder $srcdocLibName $siteURL  

  $outfile = 	$("JSON\"+$srcdocLibName+"-31-KrakoverFormOrder.json") 
  #$krkFormOrd | ConvertTo-Json -Depth 100 | out-file $outfile
  #write-host "Created File : $outfile" -f Yellow
  $FormOrd31 = get-content $outfile -encoding default | ConvertFrom-Json


   reorder-FormFields $srcdocLibName	$siteURL $FormOrd31
 
 