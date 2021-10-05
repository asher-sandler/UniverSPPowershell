param([string] $groupName = "")


$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "..\Utils-Request.ps1"
. "..\Utils-DualLanguage.ps1"
if ([string]::isNullOrEmpty($groupName))
{
	write-host groupName Must be specified  -foregroundcolor Yellow
	write-host in format hss_HUM164-2021  -foregroundcolor Yellow
	
}
else
{
	if (Test-CurrentSystem $groupName){
		#$jsonFile = "JSON\"+$groupName+".json"
		#if (Test-Path $jsonFile){
			write-host "Group: $groupName" -foregroundcolor Green
			$Credentials = get-SCred	
			
			
			$siteUrl    = "https://grs2.ekmd.huji.ac.il/home/Agriculture/AGR13-2021/"
			$oldSiteURL = "https://grs2.ekmd.huji.ac.il/home/Agriculture/AGR12-2021/"
			
			$siteUrl
			$oldSiteURL
			
			# TEST ONLY VARS
			#$siteUrl = "https://portals.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace"
			#$oldSiteURL =  "https://grs2.ekmd.huji.ac.il/home/Education/EDU57-2021/"
			
			#$siteUrl
			#$oldSiteURL
			
			
			#write-host OldSchema
			#$applSchmSrc
			#write-host NewSchema
			#$applSchmDst
			


			$lists = @()
			<#
			$lists += "מסלולים - סמירה"
			$lists += "מסלולים - בועז"
			$lists += "מסלולים - עדי"
			$lists += "מסלולים - אסמהאן"
			$lists += "מסלולים - פרידה"
			#>
			foreach($listName in $lists){
				write-host "========= Clone Form Lists ===========" -foregroundcolor Green
				Clone-List   $siteUrl $oldSiteURL $listName
			}
			
	
		#}
		#else
		#{
		#	Write-Host "File $jsonFile does not exists." -foregroundcolor Yellow
		#	Write-Host "Run 1.Get-SPRequest.ps1 first. " -foregroundcolor Yellow
		#}
	}
	else
	{
		Write-Host "Group Name $groupName is not valid!" -foregroundcolor Yellow
	}
}