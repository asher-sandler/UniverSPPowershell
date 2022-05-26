$username = "mirim"

$groups = @()

$groups += "frm_sci10_adminug"
$groups += "frm_sci11_adminug"
$groups += "frm_sci12_adminug"
$groups += "frm_sci13_adminug"
$groups += "frm_sci14_adminug"
$groups += "frm_sci15_admindl"
$groups += "frm_sci16_admindl"
$groups += "frm_sci17_admindl"
$groups += "frm_sci18_admindl"
$groups += "frm_sci19_admindl"
$groups += "frm_sci20_admindl"
$groups += "frm_sci21_admindl"
$groups += "frm_sci22_admindl"
$groups += "frm_sci23_admindl"
$groups += "frm_sci24_admindl"
$groups += "frm_sci25_admindl"
$groups += "frm_sci26_admindl"

$usrObj =  Get-ADuser -Filter 'CN -like $username' -Properties * -Server hustaff.huji.local
foreach ($grp in $groups){
	
	Add-ADGroupMember -Identity $grp -Members $usrObj
	write-host $grp
	read-host
}
