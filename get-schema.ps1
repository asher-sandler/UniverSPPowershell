function get-ListSchemaX($siteURL,$listName){
	
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
			if ($field.SchemaXml.Contains('Group="_Hidden"')){
			}
			else{
		
				If (!($field.Hidden -or $field.ReadOnly )){
					$fieldsSchema += $field.SchemaXml
				}
		
			}
		#}	
	}	
	#write-Host 1214
	return $fieldsSchema

}
function add-SchemaFieldsX($siteUrl, $listName, $fieldsSchema){
        #Setup the context
        $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
        $Ctx.Credentials = $Credentials
         
        #Get the List
        $List = $Ctx.Web.Lists.GetByTitle($listName)
        $Ctx.Load($List)
        $Ctx.ExecuteQuery()
 
        #Check if the column exists in list already
        $Fields = $List.Fields
        $Ctx.Load($Fields)
        $Ctx.executeQuery()
		$DisplayName = Select-Xml -Content $fieldsSchema  -XPath "/Field" | ForEach-Object {
			 $_.Node.DisplayName
		}
		$NewField = $Fields | where {($_.Title -eq $DisplayName)}
        if($NewField -ne $NULL) 
        {
            Write-host "Column $DisplayName already exists in the List!" -f Yellow
        }
        else
        {
			$NewField = $List.Fields.AddFieldAsXml($fieldsSchema,$True,[Microsoft.SharePoint.Client.AddFieldOptions]::AddFieldInternalNameHint)
			$Ctx.ExecuteQuery()   
			Write-host "Column $DisplayName was Add to the $listName Successfully!" -ForegroundColor Green
		}	
		
}
function get-availLists(){
$mihzurObj = @()
$aListObj = @()
$xmlConfigFile = "\\ekeksql00\SP_Resources$\WP_Config\availableXYZListPath\availableXYZListPath.xml"
$xmlFile = Get-Content $xmlConfigFile -raw
$isXML = [bool](($xmlFile) -as [xml])
		if ($isXML){
			#$xmlNodeData = Select-Xml -Path $wrkFileName -XPath "/Config/application/control" | ForEach-Object 
			              #{$_.Node.Data}
						  
			$xmlDoc = [xml]$xmlFile
			$configXYZList = $xmlDoc.SelectNodes("//application")
			foreach($elXYZ in $configXYZList){
				$aListItem = "" | Select appHomeUrl,ListName
				$aListItem.appHomeUrl = $elXYZ.appHomeUrl
				$aListItem.listName = $elXYZ.listName
				$aListObj += $aListItem
				
				
			}
			
		}
		else
		{
			write-host "$xmlConfigFile File type is not XML file!" 
		}
		return $aListObj
	
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

 
	
	$siteURL = "https://portals2.ekmd.huji.ac.il/home/EDU/stdFolders"
	$siteURL = "https://grs.ekmd.huji.ac.il/home/Education/EDU63-2022/"
	$siteURL = "https://scholarships.ekmd.huji.ac.il/home/NaturalScience/SCI97-2022"
	$siteURL = "https://scholarships.ekmd.huji.ac.il/home"
	<#
	$sitePath = "/home/NaturalScience/SCI97-2022/"
	$sitePath = "/home/"
	$siteDomain = "https://scholarships.ekmd.huji.ac.il"
	$siteURL = $siteDomain+$sitePath
	$listName = "לימודי הוראה"
	$listName = "applicants"
	$listName = "Physics"
	#>
	$listName = "availableScholarshipsList"
	
	#$schema = get-ListSchema $siteURL $listName
	$listNameURL = $sitePath + $listName
	$schema = get-ListSchemaX $siteURL $listName
	#$listTitle = get-ListTitleByURL $siteURL $listNameURL
	#write-host $listTitle
	#$outFile = "JSON\TeachCert.json"
	$outFile = "JSON\SCI97-2022-"+$listName+".json"
	$outFile = "JSON\"+$listName+".json"
	#$schema | ConvertTo-Json -Depth 100 | out-file $outFile -Encoding Default
	
	#$schema = get-content $outFile -encoding default | ConvertFrom-Json
	$outFile = "JSON\"+$listName+".txt"
	
	$schemaTXT = Get-Content $outFile -encoding default
	$listObj = get-availLists
	foreach($siteObj in $listObj){
		#if ($siteObj.appHomeUrl -eq "https://crs2.ekmd.huji.ac.il/home/" ){
			$siteU = get-UrlNoF5  $siteObj.appHomeUrl
			$listU = $siteObj.ListName
			#$listU = "availableSEPArchive"
			write-Host $siteU
			write-Host $listU
			foreach($xField in $schemaTXT){
				$nl =  add-SchemaFieldsX $siteU $listU $xField
				
				#write-Host $xField
				#read-host
			}
			#read-host	
		#}
		
	}
	#foreach($field in $schema){
	#	$schemaTXT += $field
	#}
	#$schemaTXT | Out-File $outFile -encoding UTF8
<#	
	$schemaXML = get-Content "SCI\HSS-SCI-Fields.txt" -Encoding UTF8 
	foreach($fieldSchema in $schemaXML){
	add-SchemaFields "https://scholarships.ekmd.huji.ac.il/home/NaturalScience/SCI98-2022" $listTitle $fieldSchema
	
	}
	
 #>
 
 
