param([string] $groupName = "")


$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"
if ([string]::isNullOrEmpty($groupName))
{
	write-host groupName Must be specified  -foregroundcolor Yellow
	write-host in format hss_HUM164-2021  -foregroundcolor Yellow
	
}
else
{
	if (Test-CurrentSystem $groupName){
		$jsonFile = "JSON\"+$groupName+".json"
		if (Test-Path $jsonFile){
			write-host "Group: $groupName" -foregroundcolor Green
			$Credentials = get-SCred	
			
			$spObj = get-content $jsonFile -encoding default | ConvertFrom-Json
			
			
			$siteUrl    = get-CreatedSiteName $spObj
			$oldSiteURL = $spObj.oldSiteURL
			$oldSiteSuffix = $spObj.OldSiteSuffix
			if ([string]::isNullOrEmpty($oldSiteSuffix)){
				$oldSiteSuffix = $spObj.oldSiteURL.split("/")[-2]
			}
			write-host "oldSiteSuffix : $oldSiteSuffix" -f Cyan
				
			
			write-host "Old Site: $oldSiteURL" -foregroundcolor Cyan
			write-host "New Site: $siteUrl" -foregroundcolor Green
			write-Host "Press any key..."
			read-host
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
			
			$oldXMLMask = $spObj.PathXML + "\"+$oldSiteSuffix+"*.xml"
			
			$oldItems   =  get-Item $oldXMLMask
			foreach($fitem in  $oldItems){
				$newFileName = $spObj.PathXML + "\"+$fitem.Name.Replace($oldSiteSuffix, $spObj.RelURL)
				if (!$(Test-Path $newFileName)){
				    
					write-Host "Copy From: " -noNewLine -f Green
					write-Host $($fitem.FullName) -f Cyan -noNewLine
					write-Host " To: " -noNewLine -f Green
					write-Host  $newFileName -f Cyan
					
					Copy-Item -Path $($fitem.FullName) -Destination $newFileName
				}
				$xmlFiles += $newFileName
				
			
				
			}
			$xmlFiles += $spObj.PathXML + "\" + $spObj.XMLFile
			$xmlFiles += $spObj.PathXML + "\" + $spObj.XMLFileEn
			$xmlFiles += $spObj.PathXML + "\" + $spObj.XMLFileHe
			#write-Host Pause...
			#read-host
			
			
			#if ($spObj.isDoubleLangugeSite){
	
			#}
			#$xmlFiles
			$idx=1
			foreach($xmlFile in $xmlFiles){
				$xmlFormPath =   $xmlFile
				write-Host $xmlFormPath -f Green
				if ($(Test-Path $xmlFormPath)){
					# difference между source и destination. Чего не хватает в destination
					$schemaDifference = get-SchemaDifference $applSchmSrc $applSchmDst 
					
					#write-host $schemaDifference
					$listObj = Map-LookupFields $schemaDifference $oldSiteURL $xmlFormPath
					$listObj | ConvertTo-Json -Depth 100 | out-file $("JSON\"+$groupName+"-ApplFields-"+$idx.ToString()+".json")
					
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