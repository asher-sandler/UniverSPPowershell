param([string] $xmlNameSource = "")

function findXml ($xmlFile){
	$pathResources = "\\ekeksql00\sp_resources$"
	$pathXmlFolder = "\HSS\default"
	
	$fullPath = $pathResources + $pathXmlFolder
	$fileName = $fullPath + "\" + $xmlFile
	if (Test-Path $fileName){
		
		# write-host $fileName
		$xmlItem = get-item $fileName
		return $xmlItem
	}
	else
	{
		return $null
	}
}

if ([string]::isNullOrEmpty($xmlNameSource)){
	write-Host Source Name must be specfied. -foregroundColor Yellow
}
else
{
	
	if (!$xmlNameSource.Contains(".xml")){
		$xmlNameSource +=".xml" 
	}
	$xmlSource = findXml $xmlNameSource 

	if (![string]::isNullOrEmpty($xmlSource))
	{
		write-host "Source file $xmlSource exists." -foregroundColor Yellow
	}
	else
	{
		write-host "Source doesn't exists"
	}
}


