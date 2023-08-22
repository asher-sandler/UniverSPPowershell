param([string] $mailNameSource = "")

function findMail ($mailFile){
	$pathResources = "\\ekeksql00\sp_resources$"
	$pathMailFolder = "\HSS\mailTemplates"
	
	$fullPath = $pathResources + $pathMailFolder
	$fileName = $fullPath + "\" + $mailFile
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

if ([string]::isNullOrEmpty($mailNameSource)){
	write-Host Source Name must be specfied. -foregroundColor Yellow
	
}
else
{
	
	if (!$mailNameSource.Contains("-mail.txt")){
		$mailNameSource +="-mail.txt" 
	}
	$mailSource = findMail $mailNameSource 

	if (![string]::isNullOrEmpty($mailSource))
	{
		write-host "Source file $mailSource exists." -foregroundColor Yellow
	}
	else
	{
		write-host "Source $mailNameSource doesn't exists" -foregroundColor Yellow
	}
}


