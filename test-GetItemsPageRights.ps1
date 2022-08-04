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

 
 $siteName = "https://scholarships2.ekmd.huji.ac.il/home/General/GEN171-2022";
 $listUrl = "/home/General/GEN171-2022/Pages"
 $siteUrl = get-UrlNoF5 $siteName
 $ListName = "Pages"

 write-host "URL: $siteURL" -foregroundcolor Yellow
 
 
 $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
 $Ctx.Credentials = $Credentials
 
    #$List=$Ctx.Web.Lists.GetByTitle($ListName)
    #$Ctx.Load($List)
    #$Ctx.ExecuteQuery()
	
	$Web = $Ctx.Web
	$ctx.Load($Web)
	$Ctx.ExecuteQuery() 

    #Get All List Items

    $List = $Web.GetList($listUrl)	
	
    $Query = New-Object Microsoft.SharePoint.Client.CamlQuery
    $Query.ViewXml ="<View Scope='RecursiveAll' />"
    $ListItems = $List.GetItems($Query)
    $Ctx.Load($ListItems)
    $Ctx.ExecuteQuery()
    $pagePrmissions = @()
	For($i=0;$i -lt $ListItems.Count;$i++)
    {
       #$Ctx.Load($ListItems[$i])
       #$Ctx.ExecuteQuery()
	   
		
		$oFile = $ListItems[$i].File
		$Ctx.Load($oFile)
		$Ctx.ExecuteQuery()
		
		$itemPerm = "" | Select Title,LoginObj
		$itemPerm.Title = $oFile.Title
		write-host "51: $($itemPerm.Title)"
		$rolAssgn = $ListItems[$i].RoleAssignments
		
        $Ctx.Load($rolAssgn)
		$Ctx.ExecuteQuery()
		
		$roles = @()
		foreach($membr in $rolAssgn){
			
			$Ctx.Load($membr)
			$Ctx.Load($membr.Member)
			$Ctx.Load($membr.RoleDefinitionBindings)
			#$Ctx.Load($membr.RoleDefinitionBindings.BasePermissions)
			$Ctx.ExecuteQuery()
			
			foreach($roldef in  $membr.RoleDefinitionBindings)
			{
				#write-host "Hidden: " $($roldef.Hidden)
				$isHiddenInUI  = $roldef.Hidden
				if (!$isHiddenInUI){
					$Ctx.Load($roldef)	
					$Ctx.ExecuteQuery()

					$roleItem = "" | Select LoginName,Role
					$roleItem.LoginName = $membr.Member.LoginName
					$roleItem.Role = $roldef.Name
					$roles += $roleItem
					write-host $membr.Member.LoginName
					write-host $roldef.Name
					write-host "Hidden : $isHiddenInUI"
					write-host -----------
					write-host 
				}
				
				
			}
			
			
		}
		$itemPerm.LoginObj = $roles		
		$pagePrmissions += $itemPerm
	}
$outfile = ".\JSON\GEN171-2022-PagesPermission.json"
$pagePrmissions  | ConvertTo-Json -Depth 100 | out-file $outfile -Encoding Default
write-host $outfile
	
	 #$pages | gm
	#read-host
	<#
	For($i=0;$i -lt $ListItems.Count;$i++)
    {       
        #Break Inheritance copying permissions from parent
		$itemPerm = "" | Select Title,LoginObj
		$rolAssgn = $ListItems[$i].RoleAssignments
		$ListItems[$i] | gm
        $Ctx.Load($rolAssgn)
		$Ctx.ExecuteQuery()
		$itemPerm.Title = $ListItems[$i].Title
		$ListItems[$i]
		foreach($membr in $rolAssgn){
			$Ctx.Load($membr)
			$Ctx.Load($membr.Member)
			$Ctx.Load($membr.RoleDefinitionBindings)
			#$Ctx.Load($membr.RoleDefinitionBindings.BasePermissions)
			$Ctx.ExecuteQuery()
			
			foreach($roldef in  $membr.RoleDefinitionBindings)
			{
				$Ctx.Load($roldef)	
				$Ctx.ExecuteQuery()
				$isHiddenInUI  = $roldef.Hidden
				if (!$isHiddenInUI){
					write-host $membr.Member.LoginName
					write-host $roldef.Name
					write-host "Hidden : $isHiddenInUI"
					write-host -----------
					write-host 
				}
				
				
			}
			
			
		}
		$pagePrmissions += $itemPerm
		#read-host

    }
$outfile = ".\JSON\GEN171-2022-PagesPermission.json"
$pagePrmissions  | ConvertTo-Json -Depth 100 | out-file $outfile -Encoding Default
write-host $outfile
#>
