
$srcGrps =  Get-ADGroup -Filter {Name -like "HSS_SCI92-2022_judges-*" -or Name -like "HSS_SCI92-2022_ad*"}

foreach($sGroup in $srcGrps){
	$srcMembers =  Get-ADGroupMember -Identity $sGroup
	$oldGroupName = $sGroup.Name
	#if ($oldGroupName.contains())
	$newGrpName = $oldGroupName.Replace("SCI92","SCI96")
	#if ($newGrpName.contains('judges')){
	#	$newGrpName = $newGrpName.Replace('judges','judeges')
	#}
	$dstGrp = Get-ADGroup -Filter 'Name -eq $newGrpName'
	if ([string]::IsNullOrEmpty($dstGrp)){
		
		write-host "Source Group:  $($sGroup.Name)" -f Green
		write-host "$newGrpName Not Found" -f Yellow
	}
	else
	{
		if (![string]::IsNullOrEmpty($srcMembers)){
			write-host "Copy AD Members from $oldGroupName To $newGrpName" -f Green
			Add-ADGroupMember -Identity $newGrpName -Members $srcMembers
		}
	}
}