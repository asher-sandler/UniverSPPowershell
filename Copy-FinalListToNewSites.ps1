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
<#
Copy Final List structure from Old Site To New Site
Hello Asher,

On the SSW site in GRS, you need to create columns in the Final Folders, like on last year's sites.

Thanks,
Daniel
27.01.2022

Hello to you,
https://grs2.ekmd.huji.ac.il/home/schoolofsocialwork/SSW39-2022/Final/Forms/AllItems.aspx
https://grs2.ekmd.huji.ac.il/home/schoolofsocialwork/SSW38-2022/Final/Forms/AllItems.aspx
https://grs2.ekmd.huji.ac.il/home/schoolofsocialwork/SSW45-2022/Final/Forms/AllItems.aspx
https://grs2.ekmd.huji.ac.il/home/schoolofsocialwork/SSW44-2022/Final/Forms/AllItems.aspx

#>
$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"

$Credentials = get-SCred

 
 $groupNames = @();
 $groupNames+="SSW39-2022"
 $groupNames+="SSW38-2022"
 $groupNames+="SSW45-2022"
 $groupNames+="SSW44-2022"
 $listName = "Final"
 foreach($grName in $groupNames){
	 $jsonFile = ".\JSON\GRS_"+$grName+".json"
	 $newSiteURL = "https://grs2.ekmd.huji.ac.il/home/schoolofsocialwork/"+$grName
	 $spObj = get-content $jsonFile -encoding default | ConvertFrom-Json
	 if (![string]::isNullOrEmpty($spObj.oldSiteURL)){
		$oldSiteURL = $spObj.oldSiteURL
		write-host
		write-host "New Site: $newSiteURL" -f Cyan
		write-host "Old Site: $oldSiteURL" -f Magenta
		write-host
		
		create-ListfromOld	$newSiteURL $oldSiteURL $listName
		#read-host

	 }
 }

 