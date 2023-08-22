
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.Portable.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Publishing.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Search.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.UserProfiles.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"

$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"



$outlook = New-Object -Com Outlook.Application
$MAPI = $Outlook.GetNamespace("MAPI")
$Mailbox = $MAPI.Folders("ashersan@savion.huji.ac.il")
$Inbox = $mailbox.Folders("Inbox")
#$inbox.Items.Count
$validSubj = "Grs Register Errors"
$doubleStudents = @()

foreach($mailItem in $inbox.Items){
	$subj = $mailItem.Subject
	if ($subj.Contains($validSubj) ){
		if ($subj.Substring(0,19) -eq "Grs Register Errors"){
			#for($i=0; $i -lt $mailItem.Body.Count
			$bd = $mailItem.Body.split("`n")
			for($i=0; $i -lt $bd.count; $i++)
			{
				if ($bd[$i].Contains("Error")){
					if ( $bd[$i-3].Contains("Line 265: myId :")){
						$studItm = "" | Select StudenID, SiteURL, listName 
						$studItm.StudenID =  $bd[$i-3].split(":")[2].Trim()
						$studItm.SiteURL  =  "https:"+$bd[$i-2].split(":")[3].Trim()
						$studItm.listName =  $bd[$i-1].split(":")[2].Trim()
						$doubleStudents += $studItm
						#read-host
					}
					
					
				}
				
			}
			
		}
	}
}



$Credentials = get-SCred

$templROW = get-Content "EmailTemplate\dstemplateRow.html" -raw -encoding UTF8
$idxRow = ""
$templIndex = get-Content "EmailTemplate\doubleStudent.html" -raw -encoding UTF8



foreach($itm in $doubleStudents){
	$mailObj = @()
	$htmlRowTemp = ""	
	$needToSend = $false
	$siteURL = get-UrlNoF5 $itm.SiteURL
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteURL)
	$Ctx.Credentials = $Credentials
	$List = $Ctx.Web.lists.GetByTitle($itm.listName)
	$sID = $itm.StudenID
	$Query = New-Object Microsoft.SharePoint.Client.CamlQuery
	$qry = "<View><Query><Where><Eq><FieldRef Name='studentId' /><Value Type='Text'>$sID</Value></Eq></Where></Query></View>"
	$Query.ViewXml = $qry

	$ListItems = $List.GetItems($Query)
	$Ctx.Load($ListItems)
	$Ctx.ExecuteQuery()
	if ($ListItems.Count -gt 1){
		
		#write-host $itm
		foreach($lItem in $ListItems){
			$mailItm = "" | Select ID, StudentID, URL, listName
			$mailItm.ID = $lItem.ID
			$mailItm.StudentID = $sID
			$mailItm.URL = $itm.SiteURL
			$mailItm.listName = $itm.listName
			$ApplURL = $itm.SiteURL + "/Lists/"+$itm.listName+"/EditForm.aspx?ID="+$lItem.ID
			$htmlRowTemp += "$ApplURL `n"
			$htmlRow += $templROW -Replace "{APPLICANTURL}",$ApplURL

			$needToSend = $true
			$mailObj += $mailItm
			
			
		}
	}
	
	$idxHTML = $templIndex -Replace "{StudentID}",$sID
	$idxHTML = $idxHTML -Replace "{TEMPLATEROW}",$htmlRow
	
	$idxHTML | Out-File idx.html -encoding UTF8
	$htmlBody = get-Content idx.html -encoding UTF8 -raw
	$target = "supportsp@savion.huji.ac.il"
	#$target = "AsherSa@ekmd.huji.ac.il"
	$supportEmail = "AsherSa@ekmd.huji.ac.il"
	$doNotReply = "AsherSan@savion.huji.ac.il"
	$subj = "Multiple Student ID Detected"
	
	#$smtpserverName = "ekekcas01"
	
	#Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To $target -From $doNotReply -cc $supportEmail -Subject $subj -body $newtext -BodyAsHtml -smtpserver $smtpServerName  -erroraction Stop
	if ($needToSend ){
		$Outlook = New-Object -ComObject Outlook.Application
		$Mail = $Outlook.CreateItem(0)
		$Mail.To = $target
		$Mail.Sender = $doNotReply
		$Mail.Subject = $subj
		$abc =  "StudentID : $sID`n"+ $htmlRowTemp
		$abc
		#$Mail.HTMLBody  = $abc # "<br><p>StudentID : $sID</p>"+$htmlRowTemp #+ $htmlBody #"<br><p>rrr</p>" #$idxHTML
		$Mail.Body  = $abc # "<br><p>StudentID : $sID</p>"+$htmlRowTemp #+ $htmlBody #"<br><p>rrr</p>" #$idxHTML
		$Mail.Send()
	}

	
	
}




