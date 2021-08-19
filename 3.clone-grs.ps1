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
			
			$siteUrl
			$oldSiteURL
			
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
			
			$xmlFormPath = $spObj.PathXML + "\" +  $spObj.XMLFile
			# difference между source и destination. Чего не хватает в destination
			$schemaDifference = get-SchemaDifference $applSchmSrc $applSchmDst 
			
			#write-host $schemaDifference
			$listObj = Map-LookupFields $schemaDifference $oldSiteURL $xmlFormPath
			$listObj | ConvertTo-Json -Depth 100 | out-file $("JSON\"+$groupName+"-ApplFields.json")
			
			foreach($listName in $($listObj.LookupForm)){
				Clone-List   $siteUrl $oldSiteURL $listName
			}
			
			foreach($listName in $($listObj.LookupLists)){
				Clone-List   $siteUrl $oldSiteURL $listName
			}
			
			foreach($fieldObj in  $($listObj.FieldMap)){
				if ($fieldObj.Type -eq "Lookup"){
					#write-host $fieldObj.FieldObj.DisplayName
					add-LookupFields $siteUrl "Applicants" $($fieldObj.FieldObj) $($fieldObj.LookupTitle)
				}
			}
			
			foreach($fieldObj in  $($listObj.FieldMap)){
				if ($fieldObj.Type -eq "Choice"){
					#write-host $fieldObj.FieldObj.DisplayName
					add-ChoiceFields $siteUrl "Applicants" $($fieldObj.FieldObj) 
				}
			}

			foreach($fieldObj in  $($listObj.FieldMap)){
				if ($fieldObj.Type -eq "DateTime"){
					#write-host $fieldObj.FieldObj.DisplayName
					add-DateTimeFields $siteUrl "Applicants" $($fieldObj.FieldObj) 
				}
			}

			foreach($fieldObj in  $($listObj.FieldMap)){
				if ($fieldObj.Type -eq "Note"){
					#write-host $fieldObj.FieldObj.DisplayName
					add-NoteFields $siteUrl "Applicants" $($fieldObj.FieldObj) 
				}
			}

			foreach($fieldObj in  $($listObj.FieldMap)){
				if ($fieldObj.Type -eq "Text"){
					#write-host $fieldObj.FieldObj.DisplayName
					add-TextFields $siteUrl "Applicants" $($fieldObj.FieldObj) 
				}
			}				
			
			
			
							
			#$schemaDifference | out-file "diff.xml" -Encoding Default
			
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