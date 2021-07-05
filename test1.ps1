

function OnPremises-Test {
    $siteUrl = "https://scholarships.ekmd.huji.ac.il/home/General/GEN132-2021"
    $siteUrl = "https://portals.ekmd.huji.ac.il/home/huca/committees/SPProjects2017/"

    $clientContext = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
    $clientContext.Credentials = New-Object System.Net.NetworkCredential("ekmd\ashersa", "GrapeFloor789")

    $site = $clientContext.Web 
    $clientContext.Load($site) 
    $clientContext.ExecuteQuery()

Write-Host " Current web title is '$($site.Title)', $($site.Url), $($site.GeoLocation)"

#$site | gm
# $site.Lists
#spRequestsList



	$lists = $clientContext.web.Lists
	$list = $lists.GetByTitle("spRequestsList")
	#$listItems = $list.GetItems([Microsoft.SharePoint.Client.CamlQuery]::CreateAllItemsQuery())

	$query  = "<View><rowlimit>10<Query><OrderBy>"
	$query += 		"<FieldRef Name='id' Ascending='False' />"
	$query += "</OrderBy></Query></View>"	

	$CamlQ = [Microsoft.SharePoint.Client.CamlQuery::ViewXml($query)  ]
	#$CamlQ.ViewXml = $query

	$listItems = $list.GetItems($CamlQ)
	
	$clientContext.load($listItems)

	$clientContext.executeQuery()
	$i = 0;
	foreach($listItem in $listItems)
	{
		Write-Host "ID - " $listItem["ID"] "Title - " $listItem["Title"] 
		$i++
		if ($i -gt 9){
			break
		}
	}
$psReqList

}
$spPath = 'C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\'
cls
$spTypes = @()
write-host Init


$spTypes += "Microsoft.SharePoint.Client.Publishing.dll"
$spTypes += "Microsoft.SharePoint.Client.Runtime.dll"
$spTypes += "Microsoft.SharePoint.Client.Search.dll"
$spTypes += "Microsoft.SharePoint.Client.Taxonomy.dll"
$spTypes += "Microsoft.SharePoint.Client.UserProfiles.dll"
$spTypes += "Microsoft.SharePoint.Client.dll"
foreach ($dll in $spTypes)
{
	Add-Type -Path ($spPath+$dll)
}
 OnPremises-Test
 