
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
	  
 
$siteURL = "https://portals.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace"  
$userId = "ekmd\ashersa"  
#$pwd = Read-Host -Prompt "Enter password" -AsSecureString  
#$creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($userId, $pwd)  
$creds= Get-Credential
$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteURL)  
$ctx.credentials = $creds  
try{  
    $lists = $ctx.web.Lists  
    $list = $lists.GetByTitle("Drinks")  
    $listItemInfo = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation  
    $listItem = $list.AddItem($listItemInfo)  
    $listItem["Title"] = "Peach Juice"  
    $listItem.Update()      
    $ctx.load($list)      
    $ctx.executeQuery()  
    Write-Host "Item Added with ID - " $listItem.Id      
}  
catch{  
    write-host "$($_.Exception.Message)" -foregroundcolor red  
}  