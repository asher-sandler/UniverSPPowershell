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

 
 $siteSrcURL ="https://portals2.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace";
 
 $sourceListName = "TestBigList"
 $sourceListName = "Fruits"
 
 
 write-host "URL: $siteSrcURL" -foregroundcolor Yellow
 write-host "SourceList: $sourceListName" -foregroundcolor Cyan
 
 $siteUrl = get-UrlNoF5 $siteSrcURL
 $rowsToAdd = 20
 $fieldsCount = 15	
 $listExists = Check-ListExists $siteUrl $sourceListName
	 
	if ($listExists){
		
	}
	else
	{
		Write-Host "Create List $sourceListName On $siteUrl" -foregroundcolor Yellow
		Create-List $siteUrl $sourceListName $sourceListName 
	} 

	for($i = 1; $i -le $fieldsCount; $i++){
		$fieldObj = "" | Select-Object DisplayName,Required
		$fieldObj.DisplayName = "Field"+$i.ToString().PadLeft(3,"0")
		$fieldObj.Required =  $false
		#$fieldObj
		add-TextFields $siteUrl $sourceListName $fieldObj
	}
	
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)  
	#$ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$ctx.Credentials = $Credentials

		 
	$lists = $ctx.web.Lists 
	$list = $lists.GetByTitle($sourceListName)  
	$listItemInfo = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation

    for($k = 1; $k -le $rowsToAdd; $k++){	
		$listItem = $list.AddItem($listItemInfo)  
        

		$listItem["Title"] = "Title"+$k.ToString().PadLeft(4,"0")
		for($j=1;$j -le $fieldsCount; $j++){
			$fieldName = "Field"+$j.ToString().PadLeft(3,"0")
			$listItem[$fieldName] = "Value Of "+ $fieldName +" : " + $k.ToString().PadLeft(4,"0")
		}
		$listItem.Update()      
		$ctx.load($list)      
		$ctx.executeQuery()  
		Write-Host "$sourceListName Added with ID - " $listItem.Id 
	}	
	