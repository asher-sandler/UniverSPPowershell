Add-PsSnapin Microsoft.SharePoint.PowerShell
	$srcSiteUrl    = "https://gss2.ekmd.huji.ac.il/home/OverseasApplicantsUnit/GEN27-2020/"

$spweb = Get-SPWeb $srcSiteUrl
$listSubmitted = $spweb.Lists["submitted"]
$listSubmitted.Items.Count
$listSubmitted.ItemCount
$listSoc=$spweb.Lists["Social Sceinces"]
$listSoc.Items.Count
$listSoc.ItemCount
$listSoc | gm