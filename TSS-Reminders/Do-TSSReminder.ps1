
<#
function get-ListSchema($siteURL,$listName){
	
	$fieldsSchema = @()
	$spWeb = get-SPWeb $siteUrl
	$List = $spWeb.lists[$ListName]

	foreach($field in $List.Fields){
		# write-host "$($field.Title) : Hidden : $($field.Hidden)"
		if ($field.SchemaXml.Contains('ReadOnly="TRUE"')){
		}
		else{
			if ($field.SchemaXml.Contains('Group="_Hidden"')){
			}
			else{
		
				If (!($field.Hidden -or $field.ReadOnly )){
					$fieldsSchema += $field.SchemaXml
				}
			}
		}	
	}	
	return $fieldsSchema
}
#>
function Check-FileChanged($currentSite, $folderUrl){
	$isFileChanged = 0 # File  Not Changed during 2 weeks
	$dt=Get-Date
	$strDate = $dt.AddMinutes($TwoWeeksInMinutes*-1).ToString("yyyy-MM-dd")+"T00:00:00Z"
	if (![string]::IsNullOrEmpty($folderUrl)){
		$listUrl = $folderUrl.Split(",")[0].trim().Split("/")[-1]
		$spWeb = Get-SPWeb $currentSite
		
		$DocLib = $spWeb.Lists | Where{$_.RootFolder.ToString() -eq $listUrl}
        if ($DocLib){
			#write-host 11 $listUrl
			$query=New-Object Microsoft.SharePoint.SPQuery
			$query.ViewAttributes = "Scope='RecursiveAll'"
			$query.Query = "<Where><Lt><FieldRef Name='Modified' /><Value IncludeTimeValue='TRUE' Type='DateTime'>"+$strDate+"</Value></Lt></Where>"

			Write-Host $query.Query
			$items = $DocLib.GetItems($query)
			foreach ($item in $items){
				#Write-Host 18 $DocLib.Title
				$isFileChanged = 2 # File Changed not later than 2 weeks
				break
			}			
		}
		else
		{
			$isFileChanged = 1 # no Student Library Found	
		}
		
	}
	return $isFileChanged
	
	
}
function sendHebMail($textBody, $target, $msgSubj)
{
	$newtext =@"
 <!DOCTYPE html>
 <html lang="en" xmlns="http://www.w3.org/1999/xhtml">
 <head>
 <meta charset="utf-8" />
 <title></title>
 </head> 
 <body>
   $textBody
 </body>
 </html>
"@
<#
	if ($isDebug){
		#
		$RandomString = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 10 | ForEach-Object {[char]$_})

		$outFNmm = $($target+$RandomString + ".html")
		#Write-Host $outFNmm
		$newtext | Out-File   $outFNmm -Force -Encoding Unicode
		#read-host
		

	}
	else
	{
#>		
	
		try
		{
			Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To $target -BCC "ashersan@savion.huji.ac.il" -From $doNotReply -Subject $msgSubj -body $newtext -BodyAsHtml -smtpserver "ekekcas01"  -erroraction SilentlyContinue
			#Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To $target  -From $doNotReply -Subject $msgSubj -body $newtext -BodyAsHtml -smtpserver "ekekcas01"  -erroraction SilentlyContinue
			#g; log "Successfuly sent Hebrew mail to $target" $logFileName ;w
		}
		catch
		{
			#red; log "Failed Hebrew mail Send to $target `n$error[0]" $logFileName ; w
		}
	#}
	
} #end function
function Send-MailToSapak($siteUrl, $listName,$ListOfIDs){
	$spWeb = Get-SPWeb $siteUrl
	if ($spWeb){
		$sapakimList = $spWeb.Lists[$listName]
		if ($sapakimList){
			forEach($lid in $ListOfIDs){
				$sapakListItem = $sapakimList.GetItembyID($lid.ID)
				$emailAddress = $sapakListItem["email"]
				if (![string]::IsNullOrEmpty($emailAddress)){
					
					$msgSubj =  "Notification for submission" 
					
					$contractorName = $([string]$sapakListItem["firstNameHe"] + " " + [string]$sapakListItem["surnameHe"]).Trim() 
					$contractorNameEn = $([string]$sapakListItem["firstName"] + " " + [string]$sapakListItem["surname"]).Trim()
					if ([string]::IsNullOrEmpty($contractorNameEn)){
						$contractorNameEn = $contractorName
					}
					$linkToForm = "<a href="+'"'+$siteUrl + "/Lists/" + $listName + "/EditForm.aspx?ID="+$lid.ID+'">לפתוח טופס</a>'
					write-host 84 $($siteUrl + "/Lists/" + $listName + "/EditForm.aspx?ID="+$lid.ID)
					write-host 85 $contractorName
					$openSubmissionStatusPage = "<a href="+'"'+$siteUrl + '/Pages/SubmissionStatus.aspx">וללחוץ על כפתור ההגשה</a>'
					$openCancelPage  = "<a href="+'"'+$siteUrl + '/Pages/Cancel.aspx">באפשרותך להסיר הרשמה כאן</a>'
					$OpenfilesUpload = "<a href="+'"'+$siteUrl + '/Pages/filesUpload.aspx">לסיים למלא את כל מסמכי</a>'
					$mailt   = $mailTemplate
					if (![string]::IsNullOrEmpty($contractorName.Trim())){
						$mailt2 = $mailt.Replace("[CustNameHe]", "לכבוד "+$contractorName + ",")
					}
					else
					{
						$mailt2 = $mailt.Replace("[CustNameHe]", " ")

						
					}
					if (![string]::IsNullOrEmpty($contractorNameEn.Trim())){
						$mailt3 = $mailt2.Replace("[CustNameEn]", "Dear "+$contractorNameEn + ",")
					}
					else
					{
						
						$mailt3 = $mailt2.Replace("[CustNameEn]", " ")
						
					}
					
					$mailt4 = $mailt3.Replace("[siteurl]", $siteUrl)
					#$mailt4 = $mailt3.Replace("[openCancelPage]", $openCancelPage)
					#$mailt5 = $mailt4.Replace("[OpenfilesUpload]", $OpenfilesUpload)
					#$mailt6 = $mailt5.Replace("[linkToId]", $linkToForm)
					$msgBody = $mailt4 # .Replace("[emailAddress]", $emailAddress)
					
					#Write-Host "Send Email Message:"
					Write-Host "TO: " $emailAddress
					#$emailAddress = "ashersan@savion.huji.ac.il"
					
					#Write-Host $msgSubj		
					#Write-Host 107 $msgBody		
					#Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To $emailAddress  -From $doNotReply  -Subject $msgSubj -body $msgBody -BodyAsHtml -smtpserver ekekcas01  -erroraction SilentlyContinue
					sendHebMail $msgBody $emailAddress $msgSubj

					#Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersan@savion.huji.ac.il"  -From $doNotReply  -Subject $msgSubj -body $msgBody -BodyAsHtml -smtpserver ekekcas01  -erroraction SilentlyContinue
					<#
					$outFNmm = $($emailAddress+".txt")
					Write-Host $outFNmm
					$msgBody | Out-File   $outFNmm -Force -Encoding Unicode
					#>
					#break
				}
			}
			
		}
		
	}		
	return $null
	
}
function Update-Contractor($siteUrl, $listName,$ListOfIDs){
	#Write-Host 2 $siteUrl $listName  $sendSapField  $doneField
	$spWeb = Get-SPWeb $siteUrl
	if ($spWeb){
		$sapakimList = $spWeb.Lists[$listName]
		if ($sapakimList){
			forEach($lid in $ListOfIDs){
				$linkUrl = $siteUrl + "/Lists/" + $listName + "/EditForm.aspx?ID="+$lid.ID
				Write-Host $linkUrl
				
				
				$sapakListItem = $sapakimList.GetItembyID($lid.ID)
				
				$sapakListItem[$reminderField] = $dtNow
				$sapakListItem.Update()
				#break
				
			}
			
		}
		
	}		
	return $null
}
function get-FrendlyDate($dtNow){
	$dtNowS = $dtNow.Year.ToString() + "-" +$dtNow.Month.ToString().PadLeft(2,"0") + "-"+$dtNow.Day.ToString().PadLeft(2,"0") + " " + $dtNow.Hour.ToString().PadLeft(2,"0")+":"+$dtNow.Minute.ToString().PadLeft(2,"0")+":"+$dtNow.Second.ToString().PadLeft(2,"0")
	return 	$dtNowS
}
function get-FrendlyDateLog($dtNow){
	$dtNowS = $dtNow.Year.ToString() + "-" +$dtNow.Month.ToString().PadLeft(2,"0") + "-"+$dtNow.Day.ToString().PadLeft(2,"0") + "-" + $dtNow.Hour.ToString().PadLeft(2,"0")+"-"+$dtNow.Minute.ToString().PadLeft(2,"0")+"-"+$dtNow.Second.ToString().PadLeft(2,"0")
	return 	$dtNowS
}
function get-ScrptFullPath($scriptX ){
	$fileScr = get-Item $scriptX
	return $fileScr.DirectoryName
}
function Get-XmlObj($xmlFileName){
	$obj = "" | Select SPSource
	$oParams = @()
	$SPSource  = "" | Select ListUrl,ListName,FieldName
	# $xmlFile = Get-Content $xmlFileName -raw
	$xmlFile = [IO.File]::ReadAllText($xmlFileName)
	$isXML = [bool](($xmlFile) -as [xml])
	if ($isXML){
			#$xmlNodeData = Select-Xml -Path $wrkFileName -XPath "/Config/application/control" | ForEach-Object 
			              #{$_.Node.Data}
						  
		$xmlDoc = [xml]$xmlFile
		$xmlOSPSource = $xmlDoc.SelectNodes("//SPSource")
		foreach($spSrc in $xmlOSPSource){
			$SPSource.ListUrl = $spSrc.ListUrl
			$SPSource.ListName = $spSrc.ListName
			$SPSource.FieldName = $spSrc.StatusFieldName
			
			break
		}

		$obj.SPSource = $SPSource
		
	}	
	return $obj
}

function get-ContactorsListItems($xObj){
	
	$listofIDs =  @()
	$outObj = "" | Select  ListOfIDs
	$currentSite = $xObj.SPSource.ListUrl
	$spWeb = Get-SPWeb $currentSite

	if ($spWeb){
		Write-Host "Opened $currentSite" -f Cyan
		$currentList = $xObj.SPSource.ListName
		$list = $spWeb.Lists[$currentList]
		#$Fields = $list.Fields
		
		if ($list){
			Write-Host "Opened List: $currentList" -f Cyan
			#$listSchema = get-ListSchema $currentSite  $currentList
			#$xmlFile =   "Schema-"+$currentList+".xml"
			#$listSchema | out-file $xmlFile -encoding Default
			#write-host "$xmlFile was written" -f Yellow
			
			#Write-Host "Check for : $runColumn" -f Cyan
			$statusFldName = $xObj.SPSource.FieldName
			$query=New-Object Microsoft.SharePoint.SPQuery
			<#
			$sQry = 	"<Where>"+
							"<And>"+
								"<Eq>"+
									"<FieldRef Name='$statusFldName' />"+
									"<Value Type='Choice'>ממתין</Value>"+
								"</Eq>"+
								"<IsNull>"+
									"<FieldRef Name='$reminderField' />"+
								"</IsNull>"+
							"</And>"+
						"</Where>"
			#>			
			$sQry = "<Where>"+
						"<And>"+
							"<Eq>"+
								"<FieldRef Name='$statusFldName' />"+
								"<Value Type='Choice'>ממתין</Value>"+
							"</Eq>"+
							"<And>"+
								"<IsNull>"+
									"<FieldRef Name='$reminderField' />"+
								"</IsNull>"+
								"<IsNotNull>"+
									"<FieldRef Name='email' />"+
								"</IsNotNull>"+
							"</And>"+
						"</And>"+
					"</Where>"


			Write-Host 	$sQry				
						
			$query.Query = $sQry
			$SPListItemCollection = $list.GetItems($query)
			$itmsCount = 0
			if ($SPListItemCollection){
                			
					foreach($listItem in $SPListItemCollection){
						$Submitted = $listItem["submit"]
						$dtBegin = Get-Date $dtBeginStr
						#write-host "We begin at :" $dtBegin
						#write-host "Item Modified at: " $listItem["Modified"] 
						$canBegin = $listItem["Modified"] -gt $dtBegin
						#$canBegin = $true
						
						if ($canBegin){

							# is two week passed from last update?
							if (!$Submitted){
								$isPDFChanged = Check-FileChanged $currentSite $listItem["folderLink"]
								#$isPDFChanged = 0 # File  Not Changed during 2 weeks
								#$isPDFChanged = 1 # no Student Library Found	
								#$isPDFChanged = 2 # File Changed not later than 2 weeks

								if ($isPDFChanged -lt 2){
									$DeltaMinutes = [int]$($dtNow - $listItem["Modified"]).TotalMinutes
									#write-host "284 Can We Begin: $canBegin"
									
									#studend library does not exist
									if ($DeltaMinutes -gt $TwoWeeksInMinutes){
									
										write-host "285 Delta: $DeltaMinutes"
										# item not changed/ Add to list
										$itmsCount++
										
										$idItem = "" | Select ID,Url
										$idItem.ID = $listItem.ID
										$idItem.Url = $currentSite + "/Lists/" + $currentList + "/EditForm.aspx?ID="+$listItem.ID
										$listofIDs += $idItem
									}
								}
							}
						}
							
					}	
					
				
				# https://gss2.ekmd.huji.ac.il/home/SocialSciences/SOC23-2019/Lists/Murshe/EditForm.aspx?ID=3143
				Write-Host "Found $itmsCount items." -f Yellow
				
			}

		}

	}  # endif
	
	$outObj.ListOfIDs = $listofIDs
	
	return $outObj
}
function Send-LogFile($logFile,$OutPath,$sendTo="",$msgSubj="",$sendToError="supportsp@savion.huji.ac.il",$errSubj=""){
	
	$gzFile = get-Item $logFile
	$lge = Get-Content $gzFile -raw
	$isLogError = $lge.ToLower().Contains("error")
	$scriptName = $MyInvocation.InvocationName
	
	#$outGzPath = "\\ekekfls00\data$\scriptFolders\LOGS\TSSReminder"
	#write-host "Copy log to: " $OutPath
	copy-item $gzFile $OutPath

	#write-host "Send $gzFile to: supportsp@savion.huji.ac.il" 

	#$msgSubj = "TSS Applicants Reminder txt Log"
	#Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "supportsp@savion.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $outGzPath  -Attachments  $gzFile -smtpserver ekekcas01  -erroraction SilentlyContinue
	#Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "evgeniat@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $outGzPath  -Attachments  $gzFile -smtpserver ekekcas01  -erroraction SilentlyContinue
	#Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "danielkl@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $outGzPath  -Attachments  $gzFile -smtpserver ekekcas01  -erroraction SilentlyContinue
	if (![string]::IsNullOrEmpty($sendTo)){
		if ([string]::IsNullOrEmpty($msgSubj)){
			$msgSubj = $scriptName +" log."
		}
        #write-host "Send $msgSubj to $sendTo"		

		Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To $sendTo   -From $doNotReply  -Subject $msgSubj -body $OutPath  -Attachments  $gzFile -smtpserver ekekcas01  -erroraction SilentlyContinue
	}

	if ($isLogError){
		if ([string]::IsNullOrEmpty($errSubj)){
			$errSubj = $scriptName +" error log."
		}
        #write-host "Send $errSubj to $sendToError"		
		Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To $sendToError   -From $doNotReply  -Subject $errSubj -body $OutPath  -Attachments  $gzFile -smtpserver ekekcas01  -erroraction SilentlyContinue
	}

	start-sleep 2 
	remove-Item $gzFile
	
}
#>
<#
	
#>
Add-PsSnapin Microsoft.SharePoint.PowerShell

#$isDebug = $true
#$isDebug = $false


$crlf = [char][int]13+[char][int]10

# Date we beginning check for contractors
# if date change of item or pdf later this date - as pass it.

$dtBeginStr = "2023-05-29Z20:59:59"
$script=$MyInvocation.InvocationName

$TwoWeeksInMinutes = 20160 # 14 Days 
$TwoWeeksInMinutes = 7200  # 5 Days 
#$TwoWeeksInMinutes = 1000  # 5 Days 

$reminderField = "Reminder_sent"

$cmpName = $ENV:Computername
$scriptDirectory = get-ScrptFullPath $script
Set-Location $scriptDirectory 
$dtNow = Get-Date

$dtNowStrLog 	= get-FrendlyDateLog 	$dtNow
$dtNowStr 		= get-FrendlyDate 		$dtNow

$xmlFiles = @()

# $xmlFileName = "\\ekeksql00\SP_Resources$\WP_Config\SendToRakefet\CRS\crsMursheToSap.xml"
$logFile = $scriptDirectory + "\TSSRemdr-"+$dtNowStrLog+".txt"
$mailTemplateFileName = "\\ekeksql00\SP_Resources$\TSS\Reminders\TSSMailTemplate.txt"
$mailTemplate = Get-Content $mailTemplateFileName -Raw
<#
if ($isDebug){
	$xmlFiles +=  $scriptDirectory+"\TSSReminder.xml"
	$xmlFiles +=  $scriptDirectory+"\TSSReminder1.xml"
	#$xmlFileName = $scriptDirectory+"\crsMursheToSap-prod.xml"
	$logFile = $scriptDirectory + "\AS-ContrRemdr.txt"
}
else{
#>	
	$xmlFiles += "\\ekeksql00\SP_Resources$\TSS\Reminders\TSS-ARS10.xml"
	$xmlFiles += "\\ekeksql00\SP_Resources$\TSS\Reminders\TSS-ARS11.xml"
	
#}

$sendlogFile = $false
Start-Transcript $logFile


$cultureHE = [System.Globalization.CultureInfo]::CreateSpecificCulture("he-IL")
$cultureEN = [System.Globalization.CultureInfo]::CreateSpecificCulture("en-US") 


write-host
write-host "Script For TSS Reminder version 2023-08-07.1"           
#write-host "Asher Sandler	: mailTo:AsherSa@ekmd.huji.ac.il"           
write-host "Start time		:  <$dtNowStr>"           
write-host "User			:  <$whoami>"        
write-host "Running ON		:  <$cmpName>" 
write-host "Script file		:  <$script>"        
write-host "Mail Template		:  <$mailTemplateFileName>"        
write-host "Log file		:  <$logFile>"
write-host "Script Directory	:  <$scriptDirectory>"

forEach($xmlFileName in $xmlFiles){
	$sapIsEmpty = $true

	write-host "XML File		:  <$xmlFileName>"        
	write-host 

	$xmlRakfObj = get-XmlObj $xmlFileName

	$JsonFile =   $scriptDirectory + "\xmlObj.json"
	$xmlRakfObj | ConvertTo-Json -Depth 100 | out-file $JsonFile
	$oSap = get-ContactorsListItems $xmlRakfObj
	# Send "TSSRemindr.json"
	$JsonFile =   "TSSRemindr-"+$xmlRakfObj.SPSource.ListName+".json"
	$oSap | ConvertTo-Json -Depth 100 | out-file $JsonFile
	$ts = gc $JsonFile -raw 
	$msgSubj = "TSS Reminder json: "+$(Get-Date).ToString("yyyy-MM-dd HH:mm")
	
	Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersan@savion.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction SilentlyContinue
	

	forEach($itm in $oSap.ListOfIDs){
		$sapIsEmpty = $false
		$sendlogFile = $true
		break
	}
	#$sapIsEmpty = $true
	if (!$sapIsEmpty){
		$currentSite = $xmlRakfObj.SPSource.ListUrl
		$currentList = $xmlRakfObj.SPSource.ListName

	#if (!$isDebug){
		Send-MailToSapak $currentSite $currentList $oSap.ListOfIDs 
		Update-Contractor $currentSite $currentList $oSap.ListOfIDs 
	#}


	}
}
Stop-Transcript
$sendlogFile = $true
$outPath     = "\\ekekfls00\data$\scriptFolders\LOGS\TSSReminder"
$sendTo      = "ashersan@savion.huji.ac.il"
$msgSubj     = "TSS Applicants Reminder txt Log"
$sendToError = "supportsp@savion.huji.ac.il"
$errSubj     = "TSS Applicants Reminder error Log"

Send-LogFile $logFile $OutPath $sendTo $msgSubj $sendToError $errSubj
<#
if ($sendlogFile){


	$gzipexec = $scriptDirectory + "\Utils\gzip"	

	write-host "$gzipexec $logFile -f"
	#& $gzipexec $logFile -f #| Out-Null
	#$gzLogFile = $logFile.Replace("txt","txt.gz")

	$gzFile = get-Item $logFile
	write-host "Copy log to: " $outGzPath
	copy-item $gzFile $outGzPath

	write-host "Send $gzFile to: supportsp@savion.huji.ac.il" 

	#Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "supportsp@savion.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $outGzPath  -Attachments  $gzFile -smtpserver ekekcas01  -erroraction SilentlyContinue
	#Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "evgeniat@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $outGzPath  -Attachments  $gzFile -smtpserver ekekcas01  -erroraction SilentlyContinue
	#Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "danielkl@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $outGzPath  -Attachments  $gzFile -smtpserver ekekcas01  -erroraction SilentlyContinue

	Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersan@savion.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $outGzPath  -Attachments  $gzFile -smtpserver ekekcas01  -erroraction SilentlyContinue

	start-sleep 2 
	remove-Item $gzFile
	
}
else
{
	$lgFile = Get-Item $logFile
	remove-Item $lgFile
}
#>
