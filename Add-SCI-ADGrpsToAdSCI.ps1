start-transcript ADD-SCI-ADGrpToADSCI.log

$Grps = 'SCI63-2021','SCI105-2022','SCI106-2022','SCI107-2022','SCI108-2022'
#		HSS_SCI-appphys_judegesUG
$judGRPS = 'appphys','chem','earth','life','math','phys'

#	HSS_SCI-appphys_adminUG	
$admGrps = 'appphys','chem','earth','fac','life','math','phys'

forEach ($grp in $Grps){
	$adAdminGroupName  = "HSS_"+$grp+"_adminUG"
	$adJudgesGroupName = "HSS_"+$grp+"_judgesUG"

	write-Host "AD Admin  Group: $adAdminGroupName"  -f Yellow
	
	$srcADMGrp =  Get-ADGroup -Filter {Name -eq $adAdminGroupName}
	#$srcADMGrp

	forEach($admGrp in $admGrps){
		$destADMGrpName = 'HSS_SCI-'+$admGrp+'_adminUG'
		$dstADMGrp =  Get-ADGroup -Filter {Name -eq $destADMGrpName}
		#$dstADMGrp
		Add-ADGroupMember  $srcADMGrp -Members $dstADMGrp		
	}	
	#write-host "Press key to continue..."
	#Read-Host
	
	
	write-Host "AD Judges Group: $adJudgesGroupName" -f Yellow

	$srcJUDGrp =  Get-ADGroup -Filter {Name -eq $adJudgesGroupName}	
	#$srcJUDGrp

	forEach($judGrp in $judGRPS){
		$destJUDGrpName = 'HSS_SCI-'+$judGrp+'_judegesUG'
		$dstJUDGrp =  Get-ADGroup -Filter {Name -eq $destJUDGrpName}
		#$dstJUDGrp
		Add-ADGroupMember  $srcJUDGrp -Members $dstJUDGrp		
		
	}	
	
	write-host "-----------------" -f Cyan
	#Read-Host
	
	
}
stop-transcript
