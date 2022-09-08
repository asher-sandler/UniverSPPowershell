function Remove-SitePermissions($siteUrl){
	$spWeb = Get-SPweb $siteURL
	$spWeb.BreakRoleInheritance($true)
	$maxGrp = 100
	for($k = 1; $k -le  $maxGrp ; $k++){
		$spWeb = Get-SPweb $siteURL
		$ra = $spWeb.RoleAssignments
		$raObj  = @()
		foreach($raItm in $ra){
			$raIem = "" | Select Name, LoginName
			$raIem.Name      =  $raItm.Member.Name 
			$raIem.LoginName =  $raItm.Member.LoginName
			
			#write-Host 	$raIem.Name -f Yellow
			#write-Host 	$raIem.LoginName -f Yellow
			#write-Host ---------------------- -f Magenta
			
			$raObj  += $raIem
		
		}


		for($i=0;$i -lt $raObj.Count; $i++){
			if (-not $raObj[$i].LoginName.ToUpper().Contains("_ADMIN")){
				write-Host "Removed : " $raObj[$i].LoginName -f Cyan
				$spWeb.RoleAssignments.Remove($i)
				break;
			}
			
			
		}
	}
return $null	
}
$siteURL  = "https://gss2.ekmd.huji.ac.il/home/Humanities/HUM13-2020/Archive-2022-08-18"
Remove-SitePermissions $siteURL
write-Host "Done"
# оставить ADMIN_SP ADMIN_UG
<#

    $groupsToRemove = $spWeb.Groups
	$grpCount = $groupsToRemove.Count
	$i = $grpCount - 1
	while($grpCount -ge 1){
		write 10
		
		$grName = $groupsToRemove[$i].Name
		#write-host $grName
		if (-not $grName.ToUpper().Contains("ADMINSP")){
			write-host $grName
			$spWeb.Groups.Remove($grName)

			
			#read-host
		}
		$spWeb = Get-SPweb $siteURL
		$groupsToRemove	= $spWeb.Groups	
		$grpCount = $groupsToRemove.Count
		
		$i = $grpCount - 1
		if ($i -eq 0){
			break
		}

		
	}
	
	write 19
	read-host
<#
EKMD\all_apps_grpsug
EKMD\all_apps_grpsug
----------------------
ekccUG
EKMD\ekccug
----------------------
EKMD\sharepoint_temp_editorsug
EKMD\sharepoint_temp_editorsug
----------------------
GSS_HUM13-2020_adminUG
EKMD\gss_hum13-2020_adminug
----------------------
System Account
SHAREPOINT\system
----------------------
#>	
#$groupNames = "ekccug","dante","sharepoint_temp_editorsug","sharepoint_temp_editorsug","all_apps_grpsug"
#$adGroup=$spWeb.SiteGroups.GetByName($GroupName)
# $spWeb.RoleAssignments.Remove(1)

<#
$spWeb = Get-SPweb $siteURL
$ra = $spWeb.RoleAssignments
$raObj  = @()
foreach($raItm in $ra){
	$raIem = "" | Select Name, LoginName
	$raIem.Name      =  $raItm.Member.Name 
	$raIem.LoginName =  $raItm.Member.LoginName 

    write-Host 	$raIem.Name
    write-Host 	$raIem.LoginName
	write-Host ----------------------
	
	$raObj  += $raIem
	
	 #$raItm.Member.Name | gm
}
#>

    #$groupsToRemove = $spWeb.Groups| WHERE-OBJECT{$_.Name -ne $groupADM} # v | $spWeb.Groups.Remove($_)
    #$groupsToRemove | FOREACH-OBJECT{$spWeb.Groups.Remove($_)}

    #$usersToRemove = $spWeb.Users| WHERE-OBJECT{$_.Name -ne "XXXXXXXXXX Portal Owners"} 
    #$usersToRemove  | FOREACH-OBJECT{$spWeb.Users.Remove($_)}
   
<#
    $spWeb.SiteGroups.Add("$spWeb Read", $spWeb.Site.Owner, $spWeb.Site.Owner, "The read group for $spWeb")
	$newGroup = $spWeb.SiteGroups["$spWeb Read"]


	$newGroupAssign = New-Object Microsoft.SharePoint.SPRoleAssignment($newGroup)

	$newGroupAssign.RoleDefinitionBindings.Add($spWeb.RoleDefinitions.GetByType("Reader"))
	$spWeb.RoleAssignments.Add($newGroupAssign)
	$spWeb.update()

	$spWeb.SiteGroups.Add("$spWeb Contributor", $spWeb.Site.Owner, $spWeb.Site.Owner, "The Contributor group for $spWeb")
	$newGroup = $spWeb.SiteGroups["$spWeb Contributor"]


	$newGroupAssign = New-Object Microsoft.SharePoint.SPRoleAssignment($newGroup)

	$newGroupAssign.RoleDefinitionBindings.Add($spWeb.RoleDefinitions.GetByType("Contributor"))
	$spWeb.RoleAssignments.Add($newGroupAssign)
	$spWeb.update()
	Write-Host "Creating $businessAreaURL..... " 
	$spWeb.ApplyWebTemplate(Template stuuf")
#>