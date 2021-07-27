function AddWebPartToPage ($ctx, $sitesURL) {

	$pageRelativeUrl = "/Pages/Submissions.aspx"
	$wpZoneID = "Left"
	$wpZoneOrder= 0


	try{

		#Using the params, build the page url
		$pageUrl = $sitesURL + $pageRelativeUrl
		Write-Host "Getting the page with the webpart we are going to modify: " $pageUrl -ForegroundColor Green

		#Getting the page using the GetFileByServerRelativeURL and do the Checkout
		#After that, we need to call the executeQuery to do the actions in the site
		$page = $ctx.Web.GetFileByServerRelativeUrl($pageUrl);
		$page.CheckOut()
		$ctx.ExecuteQuery()
		try{

			#Get the webpart manager from the page, to handle the webparts
			Write-Host "The page $pageUrl is checkout" -ForegroundColor Green
			#read-host
			$webpartManager = $page.GetLimitedWebPartManager([Microsoft.Sharepoint.Client.WebParts.PersonalizationScope]::Shared);
			
	<#
	SubmissionButton WP
	
Key                        Value
---                        -----
Title                      SubmissionButton WP
ImportErrorMessage         Cannot import this Web Part.
TitleIconImageUrl
TitleUrl
AuthorizationFilter
AllowZoneChange            True
CatalogIconImageUrl
ChromeType                 0
ChromeState                0
AllowConnect               True
AllowClose                 True
AllowEdit                  True
AllowMinimize              True
AllowHide                  True
HelpMode                   2
Hidden                     False
HelpUrl
Direction                  0
Description                SubmissionButton WP
ExportMode                 0
SuccessMsgHe               התיק הוגש בהצלחה
SuccessMsgEn               Your Application has been submitted succ...
Deadline                   deadline
LastSubmitColumn           lastSubmit
FailedMsgHe                לא ניתן לבצע הגשה. חסרים המסמכים הבאים:
NoSubmitMsgEn              Not yet submitted
BtnTextHe                  הגשה
FailedMsgEn                Could not submit. The following document...
NoSubmitMsgHe              טרם הוגש
DocumentUploadColumnEn     Document Type
SubmitColumnName           submit
CopyFolderName             Submitted
ApplicantsListName         applicants
ListsNames                 applicants;
CopyFolderDescColumn       description
DocumentTypeListName       DocType
DocumentUploadColumnHe     תוכן קובץ
ApplicantCopyFolderNameHe  [SPF:studentId] - [SPF:firstNameHe] [SPF...
ApplicantCopyFolderNameEn  [SPF:studentId] - [SPF:firstName] [SPF:s...
EmailSubjectHe             הגשת מועמדות
EmailSubjectEn             Application Submission
MailServer                 ekekcas01.ekmd.huji.uni
EmailSender                do-not-reply@ekmd.huji.ac.il
EmailTemplatePath          \\ekeksql00\SP_Resources$\HSS\mailTemplates
DebugMode                  False
SendErrorMail              False
EmailTemplateName          AsherSpace-mail.txt
CssPath                    /Style%20Library/SubmissionButton.css
WP_Language                0
CheckFiles                 True
CopyDocuments              True
BtnTextEn                  Submit
CopyFolderLinkText         Submit Folder
SetReadingPermission       False
SkipRequiredRecommendation False
ReplaceSubmittedDocs       False
UpdateApplyStatus          True
SetDisableAttribute        False
	
	#>		
			
			#Write-Host $WebPartXml.OuterXml
			

			#Load and execute the query to get the data in the webparts
			Write-Host "Getting the webparts from the page" -ForegroundColor Green
			$WebParts = $webpartManager.WebParts
			$ctx.Load($webpartManager);
			$ctx.Load($WebParts);
			$ctx.ExecuteQuery();
			foreach($wp in $webparts){
				#$wp | fl
				#$wp.WebPart | fl # | gm
				
				
				$ctx.Load($wp.WebPart.Properties)
				$ctx.Load($wp.WebPart)
				$ctx.Load($wp)
				$ctx.ExecuteQuery() 
				if ($wp.WebPart.Title -eq "SubmissionButton WP")
				{
					#$wp.WebPart | gm
					#$wp.id
					$wp.WebPart.Properties.FieldValues
					
					# Email Text Alignment
					$wp.WebPart.Properties["WP_Language"] = 1
					#$wp.WebPart.Properties["Content"] = "<![CDATA[<div><h1>Hello</h1></div>]]>"
					
					#Set content and Save
					#$xmlContent = get-content SimchaContent.dwp -encoding Default
					#$wp.Content = $xmlContent   
					$wp.SaveWebPartChanges();				
				}
				
			}
			
			
		}
		catch{
			Write-Host "Errors found:`n$_" -ForegroundColor Red

		}
		finally{
			#CheckIn and Publish the Page
			Write-Host "Checkin and Publish the Page" -ForegroundColor Green
			
			
			#$page.UndoCheckOut()
			$page.CheckIn("Add the User Profile WebPart", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
			$page.Publish("Add the User Profile WebPart")
			$ctx.ExecuteQuery()

			#Write-Host "The webpart has been added" -ForegroundColor Yellow 
			
		}	

	}
	catch{
		Write-Host "Errors found:`n$_" -ForegroundColor Red
	}

}
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

 $tenantAdmin = "ekmd\ashersa"
 $tenantAdminPassword = "GrapeFloor789"
 $secureAdminPassword = $(convertto-securestring $tenantAdminPassword -asplaintext -force)
 $siteURL = "https://portals.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace";
 $ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl) 
 # $credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($tenantAdmin, $secureAdminPassword)  
 $ctx.Credentials = New-Object System.Net.NetworkCredential($tenantAdmin, $tenantAdminPassword)
    
######################################
# Set Add WebPart to Page Parameters #
######################################
$relUrl = "/home/huca/EinKarem/ekcc/QA/AsherSpace"
# LogSection "Add Manual Correction WebPart to Page"
AddWebPartToPage $ctx $relUrl