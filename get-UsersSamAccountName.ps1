function getSamAccount($itm){
	$targetObj = $itm.Email
	$sAcc = Get-ADuser -Filter 'mail -like $targetObj' -Properties * | Select SamAccountName
	if ([string]::IsNullOrEmpty($sAcc)){
		$targetObj = $itm.TE_FNameEng+"."+$itm.TE_LNameEng+"@mail.huji.ac.il"
		write-host $targetObj
		$sAcc = Get-ADuser -Filter 'mail -like $targetObj' -Properties * | Select SamAccountName
	}

	if ([string]::IsNullOrEmpty($sAcc)){
		$targetObj = $itm.ID	
		$sAcc = Get-ADuser -Filter 'employeeID -like $targetObj' -Properties * | Select SamAccountName
	}
	write-host $sAcc
	if ([string]::IsNullOrEmpty($sAcc)){
		return ""
	}
	return $sAcc.SamAccountName
}
$spisok = import-csv ..\work\Evgenia-Users.csv

$resultSpisok = @()
foreach($itm in $spisok){
	$rSpisok = "" | Select ID,Email,FName,Lname,SamAccount
	$rSpisok.ID = $itm.ID
	$rSpisok.Email = $itm.Email
	$rSpisok.FName = $itm.TE_FNameEng
	$rSpisok.Lname = $itm.TE_LNameEng
	$rSpisok.SamAccount = getSamAccount $itm
	$resultSpisok += $rSpisok
	
}

$resultSpisok | export-CSV ..\work\Evgenia-Users-R.csv -NotYPEiNFO