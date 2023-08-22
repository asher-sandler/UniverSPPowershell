start-transcript "Delete-ADGroupMember.log"
$srcGrps =  Get-ADGroup -Filter {Name -like "GSS_GEN35-2022_applicants-*" }

foreach($sGroup in $srcGrps){
	$srcMembers =  Get-ADGroupMember -Identity $sGroup
	write-host
	write-host "Group: " $sGroup.Name
	write-host "======================="
	foreach ($member in $srcMembers) {
        Remove-ADGroupMember -Identity $sGroup.DistinguishedName -Members $member -Confirm:$false
		
		Write-Host "Removed: " $member.Name  
	}

}
stop-transcript
<#
foreach ($group in $srcGrps) {
    $members = Get-ADGroupMember -Identity $group.DistinguishedName
    foreach ($member in $members) {
        Remove-ADGroupMember -Identity $group.DistinguishedName -Members $member -Confirm:$false
    }
}
#>