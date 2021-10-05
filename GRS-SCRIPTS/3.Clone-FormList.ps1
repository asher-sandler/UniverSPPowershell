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
		$jsonFile = "..\JSON\"+$groupName+".json"
		if (Test-Path $jsonFile){
			write-host "Group: $groupName" -foregroundcolor Green
			$Credentials = get-SCred	
			
			$spObj = get-content $jsonFile -encoding default | ConvertFrom-Json
			
			
			$siteUrl    = get-CreatedSiteName $spObj
			$oldSiteURL = $spObj.oldSiteURL
			
			
			write-host "Old Site: $oldSiteURL" -foregroundcolor Cyan
			write-host "New Site: $siteUrl" -foregroundcolor Green
			
			# TEST ONLY VARS
			#$siteUrl = "https://portals.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace"
			#$oldSiteURL =  "https://grs2.ekmd.huji.ac.il/home/Education/EDU57-2021/"
			
			#$siteUrl
			#$oldSiteURL
			
			$applSchmSrc = get-ApplicantsSchema $oldSiteURL
			$applSchmDst = get-ApplicantsSchema $siteUrl
			
			#write-host OldSchema
			#$applSchmSrc
			#write-host NewSchema
			#$applSchmDst
			
			$xmlFiles = @()
			#if ($spObj.isDoubleLangugeSite){
$xmlFiles += "GEN31-2021-academic-arabic.xml"
$xmlFiles += "GEN31-2021-academic-french.xml"
$xmlFiles += "GEN31-2021-academic-russian.xml"
$xmlFiles += "GEN31-2021-academic-spanish.xml"
$xmlFiles += "GEN31-2021-academic.xml"
$xmlFiles += "GEN31-2021-declaration-arabic.xml"
$xmlFiles += "GEN31-2021-declaration-french.xml"
$xmlFiles += "GEN31-2021-declaration-russian.xml"
$xmlFiles += "GEN31-2021-declaration-spanish.xml"
$xmlFiles += "GEN31-2021-declaration.xml"



$xmlFiles += "GEN31-2021-personalDetails-arabic.xml"
$xmlFiles += "GEN31-2021-personalDetails-french.xml"
$xmlFiles += "GEN31-2021-personalDetails-russian.xml"
$xmlFiles += "GEN31-2021-personalDetails-spanish.xml"
$xmlFiles += "GEN31-2021-personalDetails.xml"



$xmlFiles += "GEN31-2021-studies-arabic.xml"
$xmlFiles += "GEN31-2021-studies-french.xml"
$xmlFiles += "GEN31-2021-studies-russian.xml"
$xmlFiles += "GEN31-2021-studies-spanish.xml"
$xmlFiles += "GEN31-2021-studies-test.xml"
$xmlFiles += "GEN31-2021-studies.xml"				
			$idx=1
			foreach($xmlFile in $xmlFiles){
				$xmlFormPath = $spObj.PathXML + "\" +  $xmlFile
				write-host $xmlFormPath
				if ($(Test-Path $xmlFormPath)){
					# difference между source и destination. Чего не хватает в destination
					$schemaDifference = get-SchemaDifference $applSchmSrc $applSchmDst 
					
					#write-host $schemaDifference
					$listObj = Map-LookupFields $schemaDifference $oldSiteURL $xmlFormPath
					$listObj | ConvertTo-Json -Depth 100 | out-file $("..\JSON\"+$groupName+"-ApplFields-"+$idx.ToString()+".json")
					
					foreach($listName in $($listObj.LookupForm)){
						write-host "========= Clone Form Lists ===========" -foregroundcolor Green
						Clone-List   $siteUrl $oldSiteURL $listName
					}
					
					foreach($listName in $($listObj.LookupLists)){
						write-host "========= Clone applicants Lists =========" -foregroundcolor Green
						Clone-List   $siteUrl $oldSiteURL $listName
					}
					$idx ++
				}
				
			}
		}
		else
		{
			Write-Host "File $jsonFile does not exists." -foregroundcolor Yellow
			Write-Host "Run 1.Get-SPRequest.ps1 first. " -foregroundcolor Yellow
		}
	}
	else
	{
		Write-Host "Group Name $groupName is not valid!" -foregroundcolor Yellow
	}
}