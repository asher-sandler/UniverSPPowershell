$UsersObj=Import-Csv C:\AdminDir\Work\Users.csv
foreach($usrO in $UsersObj){
	$groupName = $usrO.Group
	$dstGrp = Get-ADGroup -Filter 'Name -eq $groupName'
	$adUserName = $usrO.userName
    $userNoDomain = $adUserName.Split("\")[1]

	if ($adUserName.ToLower().Contains("cc")){
		$usrObj =  Get-ADuser -Filter 'CN -like $userNoDomain'  -Server hustaff.huji.local #-Properties *
	}
	else
	{
		# EKMD ?
		$usrObj =  Get-ADuser -Filter 'CN -like $userNoDomain' #-Properties * 
	}
	write-host $groupName
	write-host $adUserName
	Write-Host "Press any key..."
	Read-Host
	Add-ADGroupMember -Identity $dstGrp -Members $usrObj
	Read-Host

}