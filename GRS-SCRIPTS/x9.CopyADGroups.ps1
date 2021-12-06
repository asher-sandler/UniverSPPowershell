$groupsOldArr = @()

$groupsOldArr += "grs_soc36-2020_judgesclinicug" 
$groupsOldArr += "grs_soc36-2020_judgespersonug" 
$groupsOldArr += "grs_soc36-2020_judgesharediug" 

$oldPrefix = "grs_soc36-2020"
$newPrefix = "grs_soc46-2022"


foreach($grpOld in $groupsOldArr){
	$grpNew = $grpOld.Replace($oldPrefix,$newPrefix)
	write-Host "Copy AD members from $grpOld to $grpNew" -foregroundcolor Yellow
	$members = Get-ADGroupMember -Identity $grpOld
	Add-ADGroupMember -Identity $grpNew -Members $members	
}
