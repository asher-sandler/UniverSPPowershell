function get-ListSchemaXPure($siteURL,$listName){
	
	$fieldsSchema = @()
	#write-Host "$siteURL , $listName" -f Cyan
	$siteUrlC = get-UrlNoF5 $siteUrl
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrlC)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials
	
	$List = $Ctx.Web.lists.GetByTitle($ListName)
	
    $Ctx.load($List.Fields) 
    $Ctx.ExecuteQuery()	


	foreach($field in $List.Fields){
		# write-host "$($field.Title) : Hidden : $($field.Hidden)"
		#if ($field.SchemaXml.Contains('ReadOnly="TRUE"')){
		#}
		#else{
			if ($field.SchemaXml.Contains('Hidden="TRUE"')){
				continue
			}
			#else{
		
			#	If (!($field.Hidden -or $field.ReadOnly )){
					$fieldsSchema += $field.SchemaXml
			#	}
		
			#}
		#}	
	}	
	#write-Host 1214
	return $fieldsSchema

}function get-ListSchemaXLookupOnly($siteURL,$listName){
	
	$fieldsSchema = @()
	#write-Host "$siteURL , $listName" -f Cyan
	$siteUrlC = get-UrlNoF5 $siteUrl
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrlC)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials
	
	$List = $Ctx.Web.lists.GetByTitle($ListName)
	
    $Ctx.load($List.Fields) 
    $Ctx.ExecuteQuery()	


	foreach($field in $List.Fields){
		# write-host "$($field.Title) : Hidden : $($field.Hidden)"
		if ($field.SchemaXml.Contains('Hidden="TRUE"')){
			continue
		}
		#else{
			if ($field.SchemaXml.Contains('Type="Lookup"')){
			#}
			#else{
		
			#	If (!($field.Hidden -or $field.ReadOnly )){
					$fieldsSchema += $field.SchemaXml
			#	}
		
			}
		#}	
	}	
	#write-Host 1214
	return $fieldsSchema

}
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.Portable.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Publishing.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Search.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.UserProfiles.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"


$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"

	$Credentials = get-SCred

 
	
	$siteURL = "https://scholarships2.ekmd.huji.ac.il/home/Agriculture/AGR175-2022"
	$siteURL = "https://scholarships2.ekmd.huji.ac.il/home/Medicine/MED220-2020"
	$siteURL = "https://portals2.ekmd.huji.ac.il/home/tap/CSE/CSE12-2022/"
	$listName = "DocType"
	$listName = "שבוץ סגל זוטר"
	$listName = "coursesList"
	
	#$schema = get-ListSchema $siteURL $listName
	$schema = get-ListSchemaXPure $siteURL $listName
	#$schema = get-ListSchemaXLookupOnly $siteURL $listName
	$outFile = "coursesList-Schema.txt"
	#$schema | ConvertTo-Json -Depth 100 | out-file $outFile -Encoding Default
 
 $schema | out-file $outFile -Encoding Default
 
