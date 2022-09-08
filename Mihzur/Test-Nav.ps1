function Collect-qlMenuAll($spweb){
	
    $pubWeb = [Microsoft.SharePoint.Publishing.PublishingWeb]::GetPublishingWeb($spweb)
    $qlNav = $pubweb.Navigation.CurrentNavigationNodes
	
	$qlMenu = @()
	foreach($qlnavItem in $qlNav){
		$qlMainMenuItem = "" | Select Title, IsVisible, URL, Children
        if ($qlnavItem.URL.ToLower().Contains("/pages/")){
			continue
		}

		$qlMainMenuItem.Title = $qlnavItem.Title
		$qlMainMenuItem.IsVisible = $qlnavItem.IsVisible
		$qlMainMenuItem.URL = "" #$qlnavItem.URL
		$qlMainMenuItem.Children = @()
		if ($qlMainMenuItem.Title.Contains($heDocLibName) -or
		    $qlMainMenuItem.Title.Contains("Recent") -or
		    $qlMainMenuItem.Title.Contains($enDocLibName) ){
			   continue
		   }
		$xsubMenu = @()
        $childrenExists = $false		
		foreach($childMenu in $qlnavItem.Children){
			#$childMenu.GetType()
			
			
            if ($childMenu.URL.ToLower().Contains("/pages/") -or
				$childMenu.URL.ToLower().Contains("/submitted/forms") ){
				continue
			}
			$childItem = "" | Select Title, IsVisible, URL
			$childItem.Title = $childMenu.Title
			$childItem.URL = $childMenu.URL
			$childItem.IsVisible = $childMenu.IsVisible
			#write-host $childItem.Title
			#write-host $childItem.Url
			$xsubMenu += $childItem
			$childrenExists = $true
			#write-host $xsubMenu
			
		}
		
		$qlMainMenuItem.Children = $xsubMenu
		#if ($childrenExists){
			$qlMenu += $qlMainMenuItem
		#}
	}

	return 	$qlMenu
}
function Collect-qlMenu($spweb){
	
    $pubWeb = [Microsoft.SharePoint.Publishing.PublishingWeb]::GetPublishingWeb($spweb)
    $qlNav = $pubweb.Navigation.CurrentNavigationNodes
	
	$qlMenu = @()
	foreach($qlnavItem in $qlNav){
		$qlMainMenuItem = "" | Select Title, IsVisible, URL, Children
        if ($qlnavItem.URL.ToLower().Contains("/pages/")){
			continue
		}

		$qlMainMenuItem.Title = $qlnavItem.Title
		$qlMainMenuItem.IsVisible = $qlnavItem.IsVisible
		$qlMainMenuItem.URL = "" #$qlnavItem.URL
		$qlMainMenuItem.Children = @()
		if ($qlMainMenuItem.Title.Contains($heDocLibName) -or
		    $qlMainMenuItem.Title.Contains("Recent") -or
		    $qlMainMenuItem.Title.Contains($enDocLibName) ){
			   continue
		   }
		$xsubMenu = @()
        $childrenExists = $false		
		foreach($childMenu in $qlnavItem.Children){
			#$childMenu.GetType()
			
<#
 SPNavigationNode
tyScopeId  Property   guid TargetSecurityScopeId {get;}
           Property   string Title {get;set;}
e          Property   Microsoft.SharePoint.SPUserResource TitleResource {get;}
           Property   string Url {get;set;}
           Method     void Delete()
           Method     bool Equals(System.Object obj)
           Method     int GetHashCode()
           Method     type GetType()
           Method     void Move(Microsoft.SharePoint.Navigation.SPNavigationNodeCollection collection, M...
           Method     void MoveToFirst(Microsoft.SharePoint.Navigation.SPNavigationNodeCollection collec...
           Method     void MoveToLast(Microsoft.SharePoint.Navigation.SPNavigationNodeCollection collect...
           Method     string ToString()
           Method     void Update()
           Property   Microsoft.SharePoint.Navigation.SPNavigationNodeCollection Children {get;}
           Property   int Id {get;}
           Property   bool IsDocLib {get;}
           Property   bool IsExternal {get;}
           Property   bool IsVisible {get;set;}
           Property   datetime LastModified {get;}
           Property   Microsoft.SharePoint.Navigation.SPNavigation Navigation {get;}
           Property   Microsoft.SharePoint.Navigation.SPNavigationNode Parent {get;}
           Property   int ParentId {get;}
           Property   hashtable Properties {get;}
#>			
            if ($childMenu.URL.ToLower().Contains("/pages/") -or
				$childMenu.URL.ToLower().Contains("/submitted/forms") ){
				continue
			}
			$childItem = "" | Select Title, IsVisible, URL
			$childItem.Title = $childMenu.Title
			$childItem.URL = $childMenu.URL
			$childItem.IsVisible = $childMenu.IsVisible
			#write-host $childItem.Title
			#write-host $childItem.Url
			$xsubMenu += $childItem
			$childrenExists = $true
			#write-host $xsubMenu
			
		}
		
		$qlMainMenuItem.Children = $xsubMenu
		if ($childrenExists){
			$qlMenu += $qlMainMenuItem
		}
	}

	return 	$qlMenu
}
function Replace-QLMenu( $qlMenuOld, $localPathSrc, $localPathArc){
	$qlMenu = @()
	foreach($qlnavItem in $qlMenuOld){
		$qlMainMenuItem = "" | Select Title, IsVisible, URL, Children
 
		$qlMainMenuItem.Title = $qlnavItem.Title
		$qlMainMenuItem.IsVisible = $qlnavItem.IsVisible
		$qlMainMenuItem.URL = $qlnavItem.URL.Replace($localPathSrc,$localPathArc)
		$qlMainMenuItem.Children = @()

		$xsubMenu = @()
       		
		foreach($childMenu in $qlnavItem.Children){
			
  			
			$childItem = "" | Select Title, IsVisible, URL
			$childItem.Title = $childMenu.Title
			$childItem.URL = $childMenu.URL.Replace($localPathSrc,$localPathArc)
			$childItem.IsVisible = $childMenu.IsVisible
			$xsubMenu += $childItem
			
			
		}
		
		$qlMainMenuItem.Children = $xsubMenu
		$qlMenu += $qlMainMenuItem
		
	}

	return 	$qlMenu	
}
function Delete-QuickLaunchMenu ($spweb)
{
    $pubWeb = [Microsoft.SharePoint.Publishing.PublishingWeb]::GetPublishingWeb($spweb)
    $qlNav = $pubweb.Navigation.CurrentNavigationNodes
    for ($i=$spWeb.Navigation.QuickLaunch.count-1;$i -ge 0;$i--)
    {     
          $IsMenuForDeleting = $true
		  
		  $children = $spWeb.Navigation.QuickLaunch[$i].Children
		  $spWeb.Navigation.QuickLaunch[$i].Delete()

    }
	$spWeb.Update()
	
	
}
function isListDone($Urlx,$siteListArr){
	$done = $false
	$lUrl = $Urlx.ToLower()
	#write-host 178 $lUrl
	$lIndex = $lUrl.IndexOf("/lists/")
	if ($lIndex -eq -1){
		$dIndex = $lUrl.IndexOf($newArchiveObj.Title.ToLower())
		if ($dIndex -gt 0){
			$subsList = $lUrl.Substring($dIndex)
			$doclibName = $subsList.Split("/")[1]
			
			foreach($listEl in $siteListArr){
				if (($listEl.BaseTemplate -eq 101) -and ($listEl.Title.ToLower() -eq $doclibName)){
					$done = $listEl.Done
					
					break
				}
			
			}
		}	
	}
	else
	{
		#write-host 180 $lIndex
		$subsList = $lUrl.Substring($lIndex)
		#write-host 187 $subsList
		$listName = $subsList.Split("/")[2]
	    #write-host 182 $listName
		foreach($listEl in $siteListArr){
			if (($listEl.BaseTemplate -eq 100) -and ($listEl.Title.ToLower() -eq $listName)){
				$done = $listEl.Done
				break
			}
		}
	}
	return $done
}
function Add-QuickLaunchMenu($spWeb,$qlMenu,$siteListArr){
	$qlNavigation = $spWeb.Navigation.QuickLaunch
	foreach($el in $qlMenu){
		$node = New-Object Microsoft.SharePoint.Navigation.SPNavigationNode($el.Title, $el.URL, $true)
		$qlNavigation.AddAsLast($node) | out-null
		$node.Update | out-null
        $qLink = $node # $qlNavigation | Where {$_.Title -eq $el.Title}
		foreach($child in $el.Children){
			
			$tstListDone = isListDone $child.URL $siteListArr
			if ($tstListDone){
				$linkNode = new-Object Microsoft.Sharepoint.Navigation.SPNavigationNode($child.Title, $child.URL,$true)
				$noresult = $qLink.Children.AddAsLast($linkNode) | out-null
				$linkNode.Update | out-null
			}
			
		}
		
	}
	
}
start-Transcript test-nav.log
# Set-PSDebug -Trace 1
$srcSiteUrl =     "https://gss2.ekmd.huji.ac.il/home/OverseasApplicantsUnit/GEN27-2020/"
$newArchiveObj = "" | Select Title
$newArchiveObj.Title = "Archive-2022-07-26"
 
$archSubSite = $srcSiteUrl + $newArchiveObj.Title


  $jsonFile = Join-Path "_Mihzur\GSS_GEN27-2020" "AllList.json"
  $jsonFile = Join-Path "_Mihzur\GSS_GEN27-2020" "AllList-copyLeft.json"
  $siteObj = "" | Select SiteURL, SiteName, SiteSaveDirectory,WorkingDir,siteListArr

  $siteObj.siteListArr = get-content $jsonFile -encoding default | ConvertFrom-Json
write-host $srcSiteUrl
write-host $archSubSite
$heDocLibName = "העלאת מסמכים"
$enDocLibName = "Documents Upload"

$spweb = get-SPWeb $srcSiteUrl
$arcweb = get-SPWeb $archSubSite

$localPathSrc = $([System.Uri]$srcSiteUrl).LocalPath 
$lastSlash = $localPathSrc.Substring($localPathSrc.Lenght,1) -eq "/"
write-host "$localPathSrc lastSlash1 : $lastSlash"
if ($localPathSrc.Substring($localPathSrc.Lenght,1) -eq "/"){
}
else
{	
	$localPathSrc = $localPathSrc + "/"
}


$localPathArc = $([System.Uri]$archSubSite).LocalPath
$lastSlash = $localPathArc.Substring($localPathArc.Length-1,1) -eq "/"
write-host "$localPathArc lastSlash2 : $lastSlash"
if ($localPathArc.Substring($localPathArc.Length-1,1) -eq "/"){
}
else
{
	$localPathArc = $localPathArc + "/"
}



 write-host $localPathSrc
 write-host $localPathArc

 $qlMenuX = Collect-qlMenu $spweb
 $qlnavJsonFile =  "qlnavMenuX.json"
 $qlMenuX | ConvertTo-Json -Depth 100 | out-file $qlnavJsonFile
 write-host "$qlnavJsonFile was written" -f Yellow

 $qlMenuY =  Replace-QLMenu $qlMenuX $localPathSrc $localPathArc
 $qlnavJsonFile =  "qlnavMenuY.json"
 $qlMenuY | ConvertTo-Json -Depth 100 | out-file $qlnavJsonFile
 write-host "$qlnavJsonFile was written" -f Yellow
 
 $qlMenuArc = Collect-qlMenuAll $arcweb
 $qlnavJsonFile =  "qlnavMenuArc.json"
 $qlMenuArc | ConvertTo-Json -Depth 100 | out-file $qlnavJsonFile
 write-host "$qlnavJsonFile was written" -f Yellow


Delete-QuickLaunchMenu $arcweb $qlMenuArc 
Add-QuickLaunchMenu $arcweb $qlMenuY $siteObj.siteListArr
stop-transcript
 


