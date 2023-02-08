$username = "mirim"
$username = "tamarbe"

$groups = @()
<#
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
#>
$groups += "GRS_SOC52-2022_adminUG"
$groups += "GRS_SOC49-2022_adminUG"
$groups += "GRS_SOC49-2022_adminUG"
$groups += "GRS_SOC48-2022_adminUG"
$groups += "GRS_SOC46-2022_adminUG"
$groups += "GRS_SOC44-2021_adminUG"
$groups += "GRS_SOC42-2021_adminUG"
$groups += "GRS_SOC37-2020_adminUG"
$groups += "GRS_SOC36-2020_adminUG"
$groups += "GRS_SOC35-2020_adminUG"
$usrObj =  Get-ADuser -Filter 'CN -like $username' -Properties * -Server hustaff.huji.local
foreach ($grp in $groups){
	
	Add-ADGroupMember -Identity $grp -Members $usrObj
	write-host $grp
	read-host
}
