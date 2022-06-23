$search = New-Object DirectoryServices.DirectorySearcher([ADSI]"")
$search.filter="(servicePrincipalName=*)"
$results=$search.Findall()
foreach($result in $results){
	$userentry = $result.GetDirectoryEntry()
	write-host $("Object Name="+$userentry.name) -backgroundcolor Yellow -f black
	write-host $("DN = " + $userentry.distinguishedname)
	write-host $("Object Category = " + $userentry.objectCategory)
	write-host ServicePrincipialName
	$i=1
	foreach($SPN in $userentry.servicePrincipalName){
		write-host $("SPN("+$i+")=$SPN")
		$i++
	}
	write-host
}