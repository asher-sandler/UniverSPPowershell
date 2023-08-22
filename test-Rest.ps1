<#
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

Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
#> 
#[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client")
#[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Runtime")
#$assembly = [Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")

#Read more: https://www.sharepointdiary.com/2018/04/call-sharepoint-online-rest-api-from-powershell.html#ixzz7SmgFQEJN
$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"

$Credentials = get-SCred
$UserID="AsherSa@ekmd.huji.ac.il"
 
 $siteName = "https://portals.ekmd.huji.ac.il/_api/Web";
 $siteName = "https://scholarships2.ekmd.huji.ac.il/home/EdmondandLilySafraCenterforBrainSciences/ELS32-2020/_api/Web";
 #$siteName = "https://scholarships2.ekmd.huji.ac.il/_api/SP.UserProfiles.PeopleManager/GetPropertiesFor(accountName=@v)?@v='i:0%23.f|membership|$($UserID)'";
 
 $siteUrl = get-UrlNoF5 $siteName

 write-host "URL: $siteURL" -foregroundcolor Yellow
 
 $webclient = New-Object System.Net.WebClient
 $webclient.UseDefaultCredentials = $true
 $webclient.Headers.Add("Accept", "application/json;odata=verbose")
 $webclient.Headers.Add("Content-Type", "application/json; charset=utf-8");
 
 [string]$dataString = $webclient.DownloadString($siteUrl)
 $dataString 
 #write-host 41
 #read-host
 $json=new-object System.Web.Script.Serialization.JavaScriptSerializer
 $data=$json.DeserializeObject($dataString)
 $data
 #$title = $data["d"]
 #$title.Title
 #foreach ($result in $data.d.results){
 #    write-host "$($result.FullName) , $($result.EMailAddress1)"
 # } 
 
 
 
<#

 $webclient.Headers.Add("Accept", "application/json")
    $webclient.Headers.Add("Content-Type", "application/json; charset=utf-8");
    $dataString=$webclient.DownloadString($url)
    $json=new-object System.Web.Script.Serialization.JavaScriptSerializer
    $data=$json.DeserializeObject($dataString)
    foreach ($result in $data.d.results){
        write-host "$($result.FullName) , $($result.EMailAddress1)"
    }
    Write-Host "Press any key to continue ..."
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    if ($data.d.__next){
        $url=$data.d.__next.ToString()
    }
    else {
        $url=$null
    }


#> 
