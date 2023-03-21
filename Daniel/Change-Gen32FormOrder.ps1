function Is-ItemExistInArray($item, $arr){
	$itemExists = $false
	forEach($aItem in $arr){
		if ($aItem -eq $item){
			$itemExists = $true
			break
		}
	}
	return $itemExists
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
. "..\Utils-Request.ps1"
. "..\Utils-DualLanguage.ps1"

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
 $afile = 	$("JSON\AddedFields.txt") 

 $addedFields = get-content $afile
 $newOrder = @()
ForEach($f32 in $FormOrd32){



		 #Write-Host $afld $f32
		 #$newOrder
	     $itmEx = Is-ItemExistInArray $f32 $addedFields
		 if ($itmEx ){
			Write-Host $f32
			#Read-Host
			
		 }
		 else{
			 $idx = $newOrder.IndexOf($f32)
			 if ($idx -eq -1){
				$newOrder += $f32
			 }
			 
			 #break
		 }

 }
 
 forEach($addItm in $addedFields){
	 $newOrder += $addItm.ToString()
 }
  $outfile = 	$("JSON\"+$srcdocLibName+"-32-KrakoverNewOrder.json") 
  $newOrder | ConvertTo-Json -Depth 100 | out-file $outfile
  write-host "Created File : $outfile" -f Yellow

  reorder-FormFields $srcdocLibName	$siteURL $newOrder
 