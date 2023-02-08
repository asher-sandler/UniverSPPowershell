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

 
 $siteName = "https://grs2.ekmd.huji.ac.il/home/socialSciences/SOC46-2022";
 
 $siteUrl = get-UrlNoF5 $siteName
 $libName = "applicants"
 write-host "URL: $siteURL" -foregroundcolor Yellow
 
 
 $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
 $Ctx.Credentials = $Credentials
	$list = 	$ctx.Web.Lists.GetByTitle($libName)
    $Ctx.Load($list)
    $Ctx.ExecuteQuery()
	
	$Query = New-Object Microsoft.SharePoint.Client.CamlQuery
	
	$qry = "<View><Query></Query></View>"
	#$qry = "<View><Query></Query></View>"
	$Query.ViewXml = $qry

	#Get All List Items matching the query
	$ListItems = $List.GetItems($Query)
	$Ctx.Load($ListItems)
	$Ctx.ExecuteQuery()
	$ListItems.count
    $apLibs = @()
	ForEach($itm in $ListItems){
		$apItem = "" | Select Item
		$apItem.Item = $itm["folderLink"]
		$apLibs += $apItem
		
	}
    
    $apLibs | ConvertTo-Json -Depth 100 | out-file $("JSON\apList.json")
	
	$allLists =  $ctx.Web.Lists
    $ctx.Load($allLists)
    $ctx.ExecuteQuery()
	
	$userLibs = @()
	foreach($lst in $allLists){
		$srcListItem = "" | Select Title, RootFolder
		$srcListItem.Title = $lst.Title
		$rf = $lst.RootFolder
		$ctx.Load($rf)
		$ctx.ExecuteQuery()

		$srcListItem.RootFolder = $rf.Name
		$userLibs += $srcListItem
	}
 
    $userLibs | ConvertTo-Json -Depth 100 | out-file $("JSON\UserLibs.json")
	
	forEach($applItem in $apLibs){
		if (![string]::IsNullOrEmpty($applItem.Item)){
			$applRootFolder = $applItem.Item.Url.Split("/")[-1]
			$xApplRF = $applRootFolder.ToUpper()
			#Write-Host 73 $xApplRF
			#Read-Host
			$found = $false
			forEach($uLib in $userLibs){
				$xUlib = $uLib.RootFolder.ToUpper()
				#Write-Host 78 $xUlib 
				#Read-Host
				
				#if ($uLib.Title.Contains("העלאת מסמכים") ){
					if ($xApplRF -eq $xUlib){
						$found = $true
						break
					}
				#}
		
			}
			if (!$found){
				Write-Host $applItem.Item.Description
				Write-Host $applItem.Item.Url
			}
		}
	}
	
	
 