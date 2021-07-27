param([string] $groupName = "")

$userName = "ekmd\ashersa"
$userPWD = "GrapeFloor789"


$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"
if ([string]::isNullOrEmpty($groupName))
{
	write-host groupName Must be specified 
	write-host in format hss_HUM164-2021 
	
}
else
{
	if (Test-CurrentSystem $groupName){	
	    $currentSystem = Get-CurrentSystem $groupName
		
		$wrkSite = $currentSystem.appHomeUrl
		$wrkList = $currentSystem.listName
		 
		
		
		$spRequestsListObj = get-RequestListObject
		
		
		
		if ($spRequestsListObj.GroupName.ToUpper() -eq $groupName.Trim().ToUpper()){
			$siteUrlC = get-CreatedSiteName $spRequestsListObj
			#write-host "Get Created Site Name: $siteUrlC"
			#read-host
			if (![string]::IsNullOrEmpty($siteUrlC)){
				$isDoubleLangugeSite = $($spRequestsListObj.language).toLower().contains("en") -and $($spRequestsListObj.language).toLower().contains("he")
				$oldSiteExists = $(![string]::isNullOrEmpty($spRequestsListObj.oldSiteURL))
				Write-Host "Is Double Language site : $isDoubleLangugeSite" -foregroundcolor Green
				Write-Host "Is Old Site Exists : $oldSiteExists" -foregroundcolor Green
				
				
				change-ListApplicantsDeadLine 	$siteUrlC $spRequestsListObj
				add-ListApplicants  			$siteUrlC $spRequestsListObj
				change-siteSetting				$siteUrlC
				change-siteTitle $siteUrlC $($spRequestsListObj.siteName)
				#write-host "Old Site Name1 : $($spRequestsListObj.oldSiteURL)"
				#read-host
				if ($oldSiteExists){
					$contactUsContent =  get-OldContactUs $($spRequestsListObj.oldSiteURL)
					edt-ContactUs $siteUrlC $contactUsContent $($spRequestsListObj.language)
				}
				else
				{
					$contactUsContent = get-PureContactUs $($spRequestsListObj.language) $($spRequestsListObj.contactFirstNameEn) $($spRequestsListObj.contactLastNameEn) $($spRequestsListObj.contactEmail)
					edt-ContactUs $siteUrlC $contactUsContent $($spRequestsListObj.language)
				}
				
				
				edt-contactUsTitle   	$siteUrlC  $($spRequestsListObj.language)
				edt-DeleteEmptyFolders  $siteUrlC  $($spRequestsListObj.language)
				
				if (!$isDoubleLangugeSite){
					edt-cancelCandidacy  	$siteUrlC  $($spRequestsListObj.language)
					edt-SubmissionStatus 	$siteUrlC  $($spRequestsListObj.language)
					edt-Recommendations  	$siteUrlC  $($spRequestsListObj.language)
					edt-Form			    $siteUrlC  $($spRequestsListObj.language)
					edt-FormWP              $siteUrlC  $spRequestsListObj 
					edt-SubmissionWP 		$siteUrlC  $spRequestsListObj 
					
					if ($oldSiteExists){
						$contentOldDefault = get-OldDefault $($spRequestsListObj.oldSiteURL)
					
						$contentNewDefault = repl-DefContent $($spRequestsListObj.oldSiteURL) $siteUrlC $contentOldDefault
					
						edt-HomePage $siteUrlC $contentNewDefault $($spRequestsListObj.language)
					}
					else
					{
						
					}
				}
				else
				{
					if ($oldSiteExists){
						check-DLangTemplInfrastruct  $siteUrlC $spRequestsListObj $oldSiteExists $($spRequestsListObj.oldSiteURL)
					}
					else
					{
						check-DLangTemplInfrastruct  $siteUrlC $spRequestsListObj $oldSiteExists ""
					}		
					edt-cancelCandidacy2Lang $siteUrlC
					edt-SubmissionStatus2Lang $siteUrlC
					#edt-Recommendations2Lang $siteUrlC
					edt-Form2Lang $siteUrlC
					
					#edt-HomePage2Lang $siteUrlC
					
					
				}
				
				copyXML  $($spRequestsListObj.PathXML)  $($spRequestsListObj.XMLFile)  $($spRequestsListObj.PreviousXML)  $($spRequestsListObj.language)
				copyMail $spRequestsListObj
				
				change-applTemplate $siteUrlC  $($spRequestsListObj.language)
				write-host "Do not forget save ApplicantTemplate as : $($spRequestsListObj.RelURL)" -foregroundcolor Yellow
				# write-host $contactUsContent
				
				write-host "Done."	
			}
			else{
				write-host "Site is not created, yet."	
			}
		}	
	}
	else
	{
		Write-Host "Group Name $groupname is not valid!"
	}	
}