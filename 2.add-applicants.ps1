param([string] $groupName = "")

#$userName = "ekmd\ashersa"
#$userPWD = ""


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
	    $Credentials = get-SCred		
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
				change-siteSetting				$siteUrlC # navigation Settings
				change-HeadingURL 				$siteUrlC $(Get-RelURL $siteUrlC)
				change-siteTitle $siteUrlC $($spRequestsListObj.siteName)
				
				#write-host "Old Site Name1 : $($spRequestsListObj.oldSiteURL)"
				#read-host
				if ($oldSiteExists){
					$contactUsContent =  get-OldContactUs $($spRequestsListObj.oldSiteURL)
					edt-ContactUs $siteUrlC $contactUsContent $($spRequestsListObj.language)
					copy-DocTypeList $siteUrlC $($spRequestsListObj.oldSiteURL)
					Change-AdmGroupsFromOld $groupName $($spRequestsListObj.oldSiteURL)
					copy-ImgLib $siteUrlC $($spRequestsListObj.oldSiteURL)
				}
				else
				{
					$contactUsContent = get-PureContactUs $($spRequestsListObj.language) $($spRequestsListObj.contactFirstNameEn) $($spRequestsListObj.contactLastNameEn) $($spRequestsListObj.contactEmail)
					edt-ContactUs $siteUrlC $contactUsContent $($spRequestsListObj.language)
				}
				
				
				edt-contactUsTitle   	$siteUrlC  $($spRequestsListObj.language)
				edt-DeleteEmptyFolders  $siteUrlC  $($spRequestsListObj.language)
				$isDocumentsUploadExists = check-DocumentsUploadExists $siteUrlC  $($spRequestsListObj.language)
				
				if ($isDocumentsUploadExists){
					edt-DocumentsUpload  $siteUrlC  $($spRequestsListObj.language)
					edt-DocUploadWP $siteUrlC  $spRequestsListObj 
					#copyUpload $spRequestsListObj
				}
				
				if (!$isDoubleLangugeSite){
					edt-cancelCandidacy  	$siteUrlC  $($spRequestsListObj.language)
					edt-SubmissionStatus 	$siteUrlC  $($spRequestsListObj.language)
					edt-Recommendations  	$siteUrlC  $($spRequestsListObj.language)
					edt-Form			    $siteUrlC  $($spRequestsListObj.language)
					edt-FormWP              $siteUrlC  $spRequestsListObj 
					edt-SubmissionWP 		$siteUrlC  $spRequestsListObj 
					
					$contentNewDefault = ""
					
					if ($oldSiteExists){
						$contentOldDefault = get-OldDefault $($spRequestsListObj.oldSiteURL)
					
						$contentNewDefault = repl-DefContent $($spRequestsListObj.oldSiteURL) $siteUrlC $contentOldDefault
					
						 
					}
					else
					{
						$contentNewDefault = get-NewDefault $siteUrlC $($spRequestsListObj.language) $($spRequestsListObj.deadLineText)
					}
					
					edt-HomePage $siteUrlC $contentNewDefault
				}
				else
				{
					if ($oldSiteExists){
						check-DLangTemplInfrastruct  $siteUrlC $spRequestsListObj $oldSiteExists $($spRequestsListObj.oldSiteURL)
					}
					else
					{
						
						check-DLangTemplInfrastruct  $siteUrlC $spRequestsListObj $oldSiteExists ""
						#if no form, create form with message, that form is Empty.
						create-Empty2LangForms $spRequestsListObj
					}
					create-DocLib $siteUrlC	"SwitchModule"
					edt-cancelCandidacy2Lang $siteUrlC $groupName
					edt-cancelCandidacyHeWP $siteUrlC 
					
					edt-SubmissionStatus2Lang $siteUrlC $groupName
					edt-SubmissionWP2Lang $siteUrlC $spRequestsListObj
					
					edt-Recommendations2Lang $siteUrlC $groupName
					# edt-RecommendationsWP2Lang $siteUrlC $spRequestsListObj
					
					#edt-Recommendations2Lang $siteUrlC
					edt-Form2Lang $siteUrlC 
					edt-Form2LangWP $siteUrlC $spRequestsListObj
					
					edt-Default2Lang $siteUrlC $groupName
					
					Upload-SwitchFiles $siteUrlC $groupName
					edt-SwitchPage2Lang $siteUrlC
					
					#delete Recent Menu from Navigation
					$RecentsTitle = "Recent"
					$NOmoreSubItems = $false
					while (!$NOmoreSubItems){
						$NOmoreSubItems =  Delete-RecentsSubMenu $siteUrlC $RecentsTitle 
				
					}

					Delete-RecentMainMenu $siteUrlC $RecentsTitle 	
					
					
					
				}
				
				copyXML  $($spRequestsListObj.PathXML)  $($spRequestsListObj.XMLFile)  $($spRequestsListObj.PreviousXML)  $($spRequestsListObj.language)
				copyMail $spRequestsListObj
				
				Log-Generate $spRequestsListObj $siteUrlC
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