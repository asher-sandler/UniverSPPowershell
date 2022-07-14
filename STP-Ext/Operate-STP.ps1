<#
	1. Download STP
	2. Extract STP
		Utilities Extrac32.exe, MakeCab
	3. Delete STP On Server
	4. Replace UID in STP
	5. Upload STP
	6. Create List from STP
	


#>


$srcSiteUrl   = "https://gss.ekmd.huji.ac.il/home/Humanities/HUM16-2020/"
$homeweb = Get-SPWeb  $srcSiteUrl

$listArray = "ארצות עולם", "ערים עולם"

$templateSuffix = "GSS-HUM16-2020"

foreach($list in $listArray){
	$templateName = $templateSuffix + $list
	write-host $templateName
}
