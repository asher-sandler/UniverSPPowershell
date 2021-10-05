param([string] $groupName = "")


$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "..\Utils-Request.ps1"
. "..\Utils-DualLanguage.ps1"
#if ([string]::isNullOrEmpty($groupName))
#{
#	write-host groupName Must be specified  -foregroundcolor Yellow
#	write-host in format hss_HUM164-2021  -foregroundcolor Yellow
	
#}
#else
#{
#	if (Test-CurrentSystem $groupName){
#		$jsonFile = "..\JSON\"+$groupName+".json"
#		if (Test-Path $jsonFile){
#			write-host "Group: $groupName" -foregroundcolor Green
			$Credentials = get-SCred	
			
			#$spObj = get-content $jsonFile -encoding default | ConvertFrom-Json
			
			
			#$siteUrl    = get-CreatedSiteName $spObj
			#$oldSiteURL = $spObj.oldSiteURL
			#$siteUrl = "https://portals.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace"
			$oldSiteURL =  "https://grs2.ekmd.huji.ac.il/home/Education/EDU57-2021/"
			$oldSiteURL =  "https://grs.ekmd.huji.ac.il/home/natureScience/SCI23-2020"
			
			#$siteUrl
			#$oldSiteURL
			
			
			
			write-host "Old Site: $oldSiteURL" -foregroundcolor Cyan
			#write-host "New Site: $siteUrl" -foregroundcolor Green
			write-host "Pause..."
			read-host
			# TEST ONLY VARS
			
			$applSchmSrc = get-ApplicantsSchema $oldSiteURL
			$applSchmSrc | ConvertTo-Json -Depth 100 | out-file $("..\JSON\SCI23-2020-ApplFields.json")				
			#$schemaDifference | out-file "diff.xml" -Encoding Default
			
#		}
#		else
#		{
#			Write-Host "File $jsonFile does not exists." -foregroundcolor Yellow
#			Write-Host "Run 1.Get-SPRequest.ps1 first. " -foregroundcolor Yellow
#		}
#	}
#	else
#	{
#		Write-Host "Group Name $groupName is not valid!" -foregroundcolor Yellow
#	}
#}