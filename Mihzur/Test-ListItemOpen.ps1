Add-PsSnapin Microsoft.SharePoint.PowerShell
	$srcSiteUrl    = "https://gss2.ekmd.huji.ac.il/home/Humanities/HUM13-2020"

$spweb = Get-SPWeb $srcSiteUrl
$listSubmitted = $spweb.Lists["CountryList"]
<#
$cnt = $listSubmitted.Items.Count
foreach($itm in $listSubmitted.Items){
	write-host $itm.ID
}
#>
$ListItem = $listSubmitted.GetItembyID(230)
write-host $ListItem.ID
write-host $ListItem.Title
if ($ListItem.Title -eq "תוניסיה"){
	write-host "Tunisia"
	$ListItem["Title"] ="Tunisia"
	
}
else
{
	write-host "תוניסיה"
	$ListItem["Title"] ="תוניסיה"
	
}
	$ListItem.Update()
	
	$spweb.Title
	$spweb.Description 

