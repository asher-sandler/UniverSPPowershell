$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"


$spRequestsListItem = "" | Select ID, GroupName, RelURL, Status,adminGroup, adminGroupSP, assignedGroup, applicantsGroup,targetAudiency, targetAudiencysharepointGroup, targetAudiencyDistributionSecurityGroup, Notes, Title, contactFirstNameEn, contactLastNameEn , contactEmail, userName,mailSuffix, contactPhone, system, systemCode, siteName, siteNameEn, faculty, publishingDate, deadline, language,isDoubleLangugeSite, folderLink, PathXML, XMLFile, MailPath, MailFile,MailFileEn,MailFileHe, PreviousXML, PreviousMail, RightsforAdmin, systemURL, systemListUrl, systemListName, oldSiteURL, deadLineText

	$spRequestsListItem.MailPath = "mailTemplates"
	$spRequestsListItem.MailFile = "AS-TEST.txt"
	$spRequestsListItem.MailFileEn = "AS-TEST-En.txt"
	$spRequestsListItem.MailFileHe = "AS-TEST-He.txt"
	$spRequestsListItem.isDoubleLangugeSite = $false
	$spRequestsListItem.language = "he"
	$spRequestsListItem.siteNameEn = "Test Test Scholarships"
	$spRequestsListItem.siteName   = "טסט סקולרשיפס"
	
$x= copyMail $spRequestsListItem
