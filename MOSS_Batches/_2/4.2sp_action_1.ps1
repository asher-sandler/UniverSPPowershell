
function log($message, $filename) {
	write-host $message -f Cyan
}
function logts($message, $filename) {
	write-host $message -f Magenta
}
Add-PsSnapin Microsoft.SharePoint.PowerShell
white
$myHelp = @"
Runs perform registration action based on pending actions table in SQL database (grs_users).

------------------- Sergey Rubin Dec 2020 -------------------
"@

$asherTest=$true

#region variables and constants Block 
$server = "ekekdc04" # used for debug

$noerrors = $true # flag for good running


$timeStampform = "dd-MMM-yyyy@HH-mm-ss"
$timeStamp = Get-Date -format $timeStampform # for files
If ($args[0] -eq "?") { yellow; $myhelp; white; exit }
#$sourceFilePath = "\\ekekfls00\data$\ftpRoot\ibts" # the ftp puts the original file here



$sourceFilePath = "\\ekekfls00\data$\ftpRoot\ibts" # the ftp puts the original file here
$inputFilePath = "\\ekekfls00\data$\scriptFolders\DATA\"
$logFilePath = "\\ekekfls00\data$\scriptFolders\LOGS\"
$ConnString ="Data Source=EKEKSQL00;Initial Catalog=GRS_users;Integrated"

$sourceFileName = "MOSMAH_EKMD_2022.DAT"                       # the TEST for dev  file's name


#Sharepoint Settings
$homewebURL = "https://grs.ekmd.huji.ac.il/home"
$xyzlistname = "availableGRSList"
$LinkField = "folderLink"
$SPFPermission = "Full Control"
$SPFPermissionHe = "שליטה מלאה"
$SPRPermission = "Read"
$SPRPermissionHe = "קריאה"
$SPCPermission = "Contribute"
$SPCPermissionHe = "השתתפות"
$cultureHE = [System.Globalization.CultureInfo]::CreateSpecificCulture("he-IL")
$cultureEN = [System.Globalization.CultureInfo]::CreateSpecificCulture("en-US") 



$Gen1UsersOU = "OU=Gen1App_Users,OU=app_users,OU=EKusers,DC=ekmd,DC=huji,DC=uni"
$UG2 = "GRS_usersUG"
$pURLcc = "https://pm.cc.huji.ac.il/pwm/public/landing.jsp"
#$pURLekmd = "http://ekmdpwd.ekmd.huji.ac.il"
$pURLekmdEn = "https://grs2.ekmd.huji.ac.il/Pages/pwdChange.aspx"
$pURLekmdHe = "https://grs2.ekmd.huji.ac.il/Pages/pwdChange.aspx"
$prURLekmdEn = "https://grs.ekmd.huji.ac.il/Pages/PasswordReset.aspx"
$prURLekmdHe = "https://grs.ekmd.huji.ac.il/Pages/PasswordResetHe.aspx"
$ADurl = "http://ca.huji.ac.il/book/%D7%97%D7%A9%D7%91%D7%95%D7%9F-active-directory-ad"
$emailfile = $inputFilePath + "\mailenablex.dat"
$emailTitlestr = "Username,Email"
$smtpserverName = "ekekcas01"
$supportEmail  = "support@ekmd.huji.ac.il"
$helpdeskEmail = "helpdesk@ekmd.huji.ac.il"

$OnQuickLaunchShow = $false


if ($asherTest){
	# Send-MailMessage -SmtpServer ekekaiosp05.loc -From a@b.com -To ashersa@ekekaiosp05.loc -Subject test

	$sourceFilePath = "C:\MOSS_Batches" # the ftp puts the original file here
	$inputFilePath = "C:\MOSS_Batches\DATA"
	$logFilePath = "C:\MOSS_Batches\LOGS"
	$ConnString = "Data Source=ekekaiosp05;Initial Catalog=GRS_users;Integrated Security=SSPI;"


	$homewebURL = "https://gss.ekmd.huji.ac.il/home"
	$xyzlistname = "availableGssList"
	
	$UG2 = "GSS_usersUG"
	$emailfile = $inputFilePath + "\mailenablex.dat"
	
	$pURLekmdEn = "https://gss2.ekmd.huji.ac.il/Pages/pwdChange.aspx"
	$pURLekmdHe = "https://gss2.ekmd.huji.ac.il/Pages/pwdChange.aspx"
	$prURLekmdEn = "https://gss.ekmd.huji.ac.il/Pages/PasswordReset.aspx"
	$prURLekmdHe = "https://gss.ekmd.huji.ac.il/Pages/PasswordResetHe.aspx"

	$smtpserverName  = "ekekaiosp05.loc"
	$supportEmail    = "support@ekekaiosp05.loc"	
	$helpdeskEmail   = "helpdesk@ekekaiosp05.loc"	


	$doNotReply		= "do-not-reply@ekekaiosp05.loc"
	$helpdesk		= "helpdesk@ekekaiosp05.loc"
	$systemgrp		= "systemgrpug@ekekaiosp05.loc"
	$ekcc			= "ekcc@ekekaiosp05.loc"
	$roys			= "roys@ekekaiosp05.loc"
	$OnQuickLaunchShow = $false	
		
}



$sourceFile = "$sourceFilePath\$sourceFileName"
$inputFileName = $sourceFileName + "_$timeStamp.txt"        # original file is copied and renamed with timestam
$inputFile = "$inputFilePath\$inputFilename"
$logFileName = $sourceFileName + "_action01_$timeStamp.log"        #log file per each run using same time stamp
$logFile = "$logFilePath\$logFileName"


$today = Get-Date



$startDateTime = Get-Date -Format "dd.MM.yyyy HH:mm:ss"
$script=$MyInvocation.InvocationName
write-host "SEMESTER:  2"           #$logFileName
write-host "Start time:  <$startDateTime>"           #$logFileName
write-host "User:        <$whoami>"        #$logFileName
write-host "Running ON:  <$ENV:Computername>" #$logFileName
write-host "Script file: <$script>"        #$logFileName
#write-host "sourceFile:  <$sourceFile>"    #$logfileName
#write-host "inputFile:   <$inputFile>"     #$logfileName
#write-host "logFile:     <$logFile>"     #$logfileName
write-host "----------------------------"  #$logFileName
if ($asherTest){
	#write-host "Press key..."
	#read-host
}

#endregion variables

#region FUNCTIONS
################ START Functions Block ##################################
function updaction ($taskId, $resultId) {
	try {
		$conn = New-Object System.Data.SqlClient.SqlConnection
		$conn.ConnectionString = $ConnString
		$conn.Open()
		$cmd = New-Object System.Data.SqlClient.SqlCommand
		$cmd.connection = $conn
		$cmd.Parameters.AddWithValue("@ID", $taskId) | Out-Null
		$cmd.Parameters.AddWithValue("@RESULT_ID", $resultId) | Out-Null
		$cmd.commandtext = @"
UPDATE [dbo].[production_Pending_Actions_2]
SET f_performed = 1, f_performed_date = GETDATE(), ACTION_RESULT_ID = @RESULT_ID
WHERE ID =@ID;
"@
		$cmd.executenonquery()
		start-sleep -milliseconds 200
		$conn.close()
		g; logts "Action with ID $taskId was processed with result $resultId ." $logFileName; w
		#return $true
	}
	catch {
		$err = $Error[0].exception.message
		red; logts " FAILED to update record of task with ID $taskId with result $resultId  `n $err " $logFileName; w
		$conn.close()
		#return $false
	}
}

function fncAccExpirationDate ($age = 1095, $deltaDays = 30) {
	$daysFromNow = get-random -minimum ($age - $deltaDays) -maximum ($age + $deltaDays)
	$newXdate = (get-date).addDays($daysFromNow) #-f "MM/dd/yyyy" 
	return $newXdate
}

####################
function createUniqueUserName ($newGN, $newSN) {
 $a = $newSN.length
 set-variable -Name cntStep -value 0
 for ($i = 0; $i -le ($newSN.length) - 1; $i++) { 
  $suffix += $newSN[$i]
  $newN = $newGN + $suffix
  $result = Get-ADuser -Filter 'CN -eq $newN' 
  If ($result -ne $null) {} # found such a username - continue
  else {
			# no such user so this is a good name and we exit 
   return $newN
  }
 } # end of for
} 

####################################################
function normalizeDCs ($targetObj, [int]$repeats, $logfileName) {
	# verifies obj exists on both DCS before exiting
	# insert in script after creating an obj user and befor manipulating it to avoid random fails
	# can take 1-5 secs
	#if (!$targetObj){exit} # we always call this with an object
	$time	= $repeats
	#Yellow;write-host -NoNewline ".";w
	$DcList	= Get-ADDomainController -filter * | name
	$cntDCs	= $DcList.count
	$counter = 0
	$syncresult = $false
	while ($syncresult -ne $true) {
		# continuous loop with 500mSec delay
		$cntLoops++
		# for each DC
		for ($i = 0; $i -le $cntDCs - 1; $i++) {
			$srv	= $DcList[$i]#.hostname
			#w; log "Verifying Object <$targetObj> on DC <$srv>" $logfileName
			try {
    $ans = Get-ADobject -filter 'name -eq $targetObj' -Server $srv -ea silentlycontinue
   }
			catch
   {}
			If ($ans -ne $null) { $counter++; g; Write-host "<$targetobj> found on DC <$srv>"; w } else { red; Write-host "<$targetobj> Not found on DC <$srv>"; w }
		}
 
		if ($counter -eq $cntDCs) { g; log "<$targetobj> normalized on EKMD DCs" $logfileName; w; $syncresult = $true } else { Yellow; Write-host "<$targetobj> NOT Normalized on EKMD DCs, trying again"; w; $counter = 0 }
		if ($cntLoops -eq $repeats) { red; log "Object <$targetobj> NOT normalized after <$time> seconds. Aborting this user " $logfileName; $syncresult = $true }
		sleep -Milliseconds 1000
	}

} # end of function

function sendHebMail($textBody, $target, $subj) {
	$newtext = @"
 <!DOCTYPE html>
 <html lang="en" xmlns="http://www.w3.org/1999/xhtml">
 <head>
 <meta charset="utf-8" />
 <title></title>
 </head> 
 <body>
  <div style="direction:rtl;font-family:Arial;color:#000099;">
   $textBody
  </div>
 </body>
 </html>
"@
	
	try {
		#Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To $target -From $doNotReply -Subject $subj -body $newtext -BodyAsHtml -smtpserver $smtpServerName  -erroraction Stop
		Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To $target -From $doNotReply -cc $supportEmail -Subject $subj -body $newtext -BodyAsHtml -smtpserver $smtpServerName  -erroraction Stop
		g; log "Successfuly sent Hebrew mail" $logFileName ; w
	}
	catch {
		red; log "Failed Hebrew mail Send `n$error[0]" $logFileName ; w
	}
	
} #end function


################ END Functions Block ##################################
#endregion FUNCTIONS

################  START MAIN Block   ##################################
# Get AvailableGRSList
$homeweb = Get-SPWeb $homewebURL
$tsite = Get-spsite $homewebURL

$xyzlist = $homeweb.Lists[$xyzlistname]
#$xyzlist.Itemcount
if (!$xyzlist) { logts "Unable to open $xyzlistname. Exiting." $logFileName; exit }

$conn = New-Object System.Data.SqlClient.SqlConnection
$conn.ConnectionString = $ConnString
$conn.Open()
$cmd = New-Object System.Data.SqlClient.SqlCommand
$cmd.connection = $conn
$cmd.commandtext = "select * from [dbo].[production_Pending_Actions_2] WHERE ([f_performed] =0 Or [f_performed] Is Null) And [ACTION_TYPE_ID] ='1' ;"
$result = $cmd.ExecuteReader()
$table = new-object "System.Data.DataTable"
$table.Load($result); start-sleep 1
$conn.Close()
$table.Rows.Count
if (!$table -or $table.Rows.Count -eq 0) { logts "No new registration requests. Exiting." $logFileName; exit }

#region main loop
foreach ($myrow in $table.Rows) {
	logts "--------------------------------------------------------------------------------" $logFileName
	$mystr = ""; $mystr = $myrow.ID.ToString() + " - " + $myrow.ZEHUT + " - " + $myrow.ACTION_TYPE_ID; 
	logts $mystr $logFileName
	$myAction = ""; $myAction = $myrow.ACTION_TYPE_ID.Trim()
	
	$myTZ = ""; 
	$myTZ = $myrow.ZEHUT.Trim()
	
	$myId = ""; 
	$myId = $myTZ.Replace("-", ""); 
	
	$myId8 = ""; 
	$myId8 = $myId.Substring(0, 8)
	
	$taskId = $null; 
	$taskId = $myrow.ID; 
	
	$resultId = "Task complete"
	$appUserName = ""; 
	
	$securePWD_ClearText = ""
	$noerrors = $true; 
	$completed = $false; 
	$isnewuser = $false
		
	switch ($myAction) {
		"1" {
			# Get user data from Database
			$conn2 = New-Object System.Data.SqlClient.SqlConnection
			$conn2.ConnectionString = $ConnString
			$conn2.Open()
			$cmd2 = New-Object System.Data.SqlClient.SqlCommand
			$cmd2.connection = $conn2
			$cmd2.Parameters.AddWithValue("@ZEHUT", $myTZ) | Out-Null
			# Asher Change  --> AND HUG_SEMESTER = 2
			$cmd2.commandtext = "select * from [dbo].[production_users_view_2] WHERE ZEHUT = @ZEHUT AND HUG_SEMESTER = 2;"
			$result2 = $cmd2.ExecuteReader()
			$table2 = new-object "System.Data.DataTable"
			$table2.Load($result2); start-sleep 1
			$conn2.Close()
			write-host "TZ : $myTZ" -f Yellow
			write-host "Number of Records in Table : $($table2.Rows.Count)" -f Yellow
			if ($table2.Rows.Count -gt 1) { logts "$myTZ inconsistend data. more than one record in users table.Skipping record." $logFileName; $noerrors = $false; $resultId = "Many Records for one TZ"; updaction $taskId $resultId; continue }
			$myrow2 = $table2.Rows[0]
			$myrow2
			$ccuname = ""; $ccuname = $myrow2.CC_USERNAME
				
			# Get Target web names
			$websArray = @()
			$w1 = ""; if (!($myrow2.A1_H_EKMD -is [System.DBNull] -or $myrow2.A1_H_EKMD -eq $null)) { $w1 = $myrow2.A1_H_EKMD.Trim() } 
			if ($w1 -ne "") { $websArray += $w1 }
			$w2 = ""; if (!($myrow2.A2_H_EKMD -is [System.DBNull] -or $myrow2.A2_H_EKMD -eq $null)) { $w2 = $myrow2.A2_H_EKMD.Trim() } 
			if ($w2 -ne "") { $websArray += $w2 }
			$w3 = ""; if (!($myrow2.A3_H_EKMD -is [System.DBNull] -or $myrow2.A3_H_EKMD -eq $null)) { $w3 = $myrow2.A3_H_EKMD.Trim() } 
			if ($w3 -ne "") { $websArray += $w3 }
			$w4 = ""; if (!($myrow2.A4_H_EKMD -is [System.DBNull] -or $myrow2.A4_H_EKMD -eq $null)) { $w4 = $myrow2.A4_H_EKMD.Trim() } 
			if ($w4 -ne "") { $websArray += $w4 }
			$w5 = ""; if (!($myrow2.A5_H_EKMD -is [System.DBNull] -or $myrow2.A5_H_EKMD -eq $null)) { $w5 = $myrow2.A5_H_EKMD.Trim() } 
			if ($w5 -ne "") { $websArray += $w5 }
			# Get Target web record from AvailableGRSList
			$urlfound = $false
				
			# UrlsArray has to be properly initialized !!!!!
			$UrlsArray = @(); $it = [PSCustomObject] @{Url = "www.google.com"; DestinationList = "applicants"; }
			$UrlsArray += $it; $UrlsArray += $it; $UrlsArray = @()
				
			Foreach ($aweb in $websArray) {
				$mywebrecord = $null; $mywebrecord = $xyzlist.Items | where { $_["relativeURL"] -eq $aweb }
				if ($mywebrecord) {
					$myurl = ""; $myurl = $mywebrecord["url"]
					if ($myurl -and $myurl -ne "") {
						$it = [PSCustomObject] @{Url = $myurl.Trim(); DestinationList = $mywebrecord["destinationList"]; }
						$UrlsArray += $it; $urlfound = $true
					}
				}
			}
			if ($urlfound -eq $false) { logts "Sites for registration not found in $xyzlistname for $myTZ. Skipping" $logFileName; $noerrors = $false; $resultId = "No site in GRSlist"; updaction $taskId $resultId; continue }
				
			#Foreach($rec in $UrlsArray) {$rec}
			Foreach ($rec in $UrlsArray) {
				# Get Target web
				$wurl = ""; $wurl = $rec.Url
				log "Open SPWeb $wurl" 
				$web = $null; $web = Get-SPWeb $wurl
				$DocLibDone = $false
				$isnewuser = $false
				if (!$web) { logts "Unable to get web $wurl" $logFileName; $noerrors = $false; $resultId = "Unable to get web"; updaction $taskId $resultId; continue }
				$mywebrecord = $null; $mywebrecord = $xyzlist.Items | where { $_["url"] -eq $wurl }
				$applistrow = ""; $applistrow = $rec.DestinationList.Split(";")
				foreach ($applistname in $applistrow) {
					write-host "ApplistName : $applistname"
					$applist = $null; $applist = $web.Lists[$applistname]
					if (!$applist) { logts "Unable to access the applicants list $applistname in $wurl " $logFileName; $noerrors = $false; $resultId = "unable to access the applicants list"; updaction $taskId $resultId ; continue }
					else {
						# Check if this ID is present in destination lists 
						$myitem = $null; $myitem = $applist.Items | where { ($_["studentId"] -eq $myId) -or ($_["studentId"] -eq $myId.Substring(0, 8)) } # condition updated to catch 8 digits tz
						Write-host "Looking for studentId : $myId"
						if ($myitem) {
							Write-host "studentId : $myId was Found"
							# applicant record exist - personal data update needed.
							if ($myitem.Count -gt 1) { $myitem = $myitem[0] }
							$myitem["Title"] = "Applicant"; 
							$myitem["firstName"] = $myrow2.LNAME; 
							$myitem["surname"] = $myrow2.L_FAMILY; 
							$myitem["email"] = $myrow2.E_MAIL; 
							$myitem["homePhone"] = $myrow2.PHONE; 
							$myitem["mobile"] = $myrow2.MOBILE; 
							$myitem["firstNameHe"] = $myrow2.NAME; 
							$myitem["surnameHe"] = $myrow2.FAMILY; 
							$myitem["addressHe"] = $myrow2.ADDRESS; 
							$myitem["cityHe"] = $myrow2.YSH; 
							$myitem["zipHe"] = $myrow2.MIKUD; 
							$myitem["studentId"] = $myId; 
							#$myitem["A"] = 1; 
							#$NewItem["deadline"] = $mywebrecord["deadline"]; 
							$myitem.Update(); start-sleep -milliseconds 200
							log "Applicant record exists and personal data are updated in the list $applistname in $wurl " $logFileName
							#Write-host "U"
						}
						else {
							Write-host "studentId : $myId was Not Found"
							# applicant record is missing - need to register.
							# Check CC\username
							if ($ccuname -and $ccuname -ne "") {
								#CC username exist
								log "Proceeding registration of $ccuname in the list $applistname in $wurl " $logFileName
								# create DocLib
								if (!$DocLibDone) {
									write-host "create DocLib" -f Yellow
									$tmpName = $mywebrecord["template"]
									$listTemplates = $tsite.GetCustomListTemplates($web)
									$ListTemplate = $listTemplates[$tmpName]
									#$ListTemplate -eq $null
									if ($ListTemplate -eq $null) { logts "Unable to get library template $tmpName - Skipping register " $logFileName; $noerrors = $false; $resultId = "Unable to get library template $tmpName"; updaction $taskId $resultId ; continue }
									$tLibraryName = ""; $tLibraryName = $ccuname.Replace("\", ""); 
									if ($mywebrecord["language"] -eq "He")
									{ $tDescription = ""; $tDescription = $mywebrecord["folderName"] + " " + $myrow2.LNAME + " " + $myrow2.L_FAMILY + " " + $myId }
									else
									{ $tDescription = ""; $tDescription = $mywebrecord["folderName"] + " " + $myrow2.LNAME + " " + $myrow2.L_FAMILY + " " + $myId }
									# Create $tLibrary
									$Web.Lists.Add($tLibraryName, $tDescription, $ListTemplate) > Null
									start-sleep 2
									$tLibrary = $null; $tLibrary = $Web.Lists[$tLibraryName]; $tLibrary.OnQuickLaunch = $false
									# remove permissions
									$tLibrary.BreakRoleInheritance($true, $true) 
									$i = 0
									do {
										if ($tLibrary.RoleAssignments[$i].Member.GetType().Name -eq "SPUser") {
											# remove user
											$account = $web.EnsureUser($tLibrary.RoleAssignments[$i].member.LoginName)
											$tLibrary.RoleAssignments.Remove($account); start-sleep -milliseconds 400
										}
										else {
											#remove group
											$myname = $tLibrary.RoleAssignments[$i].Member.Name
											$tLibrary.RoleAssignments.Remove($tLibrary.RoleAssignments[$i].Member); Start-Sleep -Seconds 1
										}
										$tLibrary.Update(); start-sleep -milliseconds 400
									}while ($tLibrary.RoleAssignments.Count -gt $i)
									# set permissions for applicant
									$GroupRole = $null; [void] ($GroupRole = $web.RoleDefinitions[$SPCPermission] )
									if (!$GroupRole) { $GroupRole = $web.RoleDefinitions[$SPCPermissionHe] }
									log "The Group Role is - $GroupRole ." $logFileName 
									try {
										$uaccount = $null; $uaccount = $web.EnsureUser($ccuname)
										$uaname = $null; start-sleep -milliseconds 200; $uaname = $uaccount.Name
										log "The ensured account name is - $uaname ." $logFileName
										#strange error - user not found can occur. 
										$Newassignment = New-Object Microsoft.SharePoint.SPRoleAssignment($uaccount)
										$Newassignment.RoleDefinitionBindings.Add($GroupRole)
										$tLibrary.RoleAssignments.Add($Newassignment); start-sleep -milliseconds 400 #new permission is added
									}
									catch {
										logts "Failed to set folder permissions for applicant $ccuname on site $wurl." $logFileName; 
										$noerrors = $false; $resultId = "Failed to set folder permissions"
										Send-MailMessage -To $supportEmail -From $helpdesk -Subject " (GRS)FAILED set folder permissions for <$ccuname> on $wurl " -body $err -smtpserver $smtpServerName 
									}

									# set permissions for admin group
									$GroupRole = $null; [void] ($GroupRole = $web.RoleDefinitions[$SPFPermission] )
									if (!$GroupRole) { $GroupRole = $web.RoleDefinitions[$SPFPermissionHe] }
									$uaccount = $web.EnsureUser($mywebrecord["adminGroup"])
									try {
										$uaccount = $null; $uaccount = $web.EnsureUser($mywebrecord["adminGroup"])
										$Newassignment = New-Object Microsoft.SharePoint.SPRoleAssignment($uaccount)
										$Newassignment.RoleDefinitionBindings.Add($GroupRole)
										$tLibrary.RoleAssignments.Add($Newassignment); start-sleep -milliseconds 400 #new permission is added
									}
									catch { logts "Failed to set folder permissions for admin group for applicant $ccuname on site $wurl." $logFileName; $noerrors = $false; $resultId = "Failed to set folder permissions" }

									#Title update
									$tLibrary.Title = $tDescription; $tLibrary.Update()
									$tLibrary.TitleResource.SetValueForUICulture($cultureHE, $tDescription)
									$tLibrary.TitleResource.SetValueForUICulture($cultureEN, $tDescription)
									$tLibrary.TitleResource.Update()
									$tLibrary.OnQuickLaunch = $OnQuickLaunchShow
									# Creating folder contact
									$newalias = ""; $newalias = $mywebrecord["mailSuffix"] + "-" + $tLibraryName
									$tLibrary.RootFolder.Properties["vti_emailusesecurity"] = 0; $tLibrary.RootFolder.Properties["vti_emailattachmentfolders"] = "root"
									$tLibrary.RootFolder.Properties["vti_emailoverwrite"] = 1; $tLibrary.RootFolder.Properties["vti_emailsaveoriginal"] = 0
									$tLibrary.RootFolder.Properties["vti_emailsavemeetings"] = 0; start-sleep -milliseconds 400
									$tLibrary.RootFolder.Update(); $tLibrary.EmailAlias = $newalias; start-sleep -milliseconds 400; 
									$tLibrary.Update()
										
									log "Applicant folder is created  with specific permissions in $wurl " $logFileName
									# Adding cc user to applicants AD Group
									#this action is made only once per site so it is placed together with doclib operations
									$UG = ""; $UG = $mywebrecord["applicantsGroup"]; $appUserName = ""; $appUserName = $ccuname.Replace("CC\", "")
									try {
										$usr = $null; $usr = Get-ADUser -Identity $appUserName -Server "hustaff.huji.local"
										$grp = $null; $grp = Get-ADGroup -Identity $UG -Server "ekmd.huji.uni"
										$gresult = add-adgroupmember -Identity $grp -Members $usr -ea stop
									}
									catch {
										$err = $Error[0].exception.message
										red; log " (430)FAILED to add <$ccuname> to <$UG>`n $err " $logFileName; w
										$noerrors = $false; $resultId = "FAILED to add $ccuname to $UG"
										#Send-MailMessage -To "sergeyr@ekmd.huji.ac.il" -From $helpdesk -Subject " (GRS)FAILED to add <$ccuname> to <$UG>" -body $err -smtpserver $smtpServerName 
									}
									$DocLibDone = $true
								} #End if(!$DocLibDone)

								# add record to destination list
								$NewItem = $applist.AddItem()
								$NewItem["Title"] = "Applicant"; 
								$NewItem["firstName"] = $myrow2.LNAME; 
								$NewItem["surname"] = $myrow2.L_FAMILY; 
								$NewItem["email"] = $myrow2.E_MAIL; 
								$NewItem["homePhone"] = $myrow2.PHONE; 
								$NewItem["mobile"] = $myrow2.MOBILE; 
								$NewItem["firstNameHe"] = $myrow2.NAME; 
								$NewItem["surnameHe"] = $myrow2.FAMILY; 
								$NewItem["addressHe"] = $myrow2.ADDRESS; 
								$NewItem["cityHe"] = $myrow2.YSH; 
								$NewItem["zipHe"] = $myrow2.MIKUD; 
								$NewItem["userName"] = $ccuname; 
								$NewItem["folderMail"] = $newalias + "@ekmd.huji.ac.il"; 
								$NewItem["folderName"] = $tDescription; 
								$NewItem["studentId"] = $myId; 
								$NewItem["A"] = 1; 
								#$NewItem["deadline"] = $mywebrecord["deadline"]; 
								$NewItem["submit"] = $false; 
								$tlink = $null; $tlink = new-object Microsoft.SharePoint.SPFieldUrlValue($NewItem["folderLink"])
								$tlink.Description = "Files " + $myrow2.L_FAMILY + " " + $myrow2.LNAME; $tlink.Url = $tLibrary.RootFolder.ServerRelativeUrl
								$NewItem["folderLink"] = $tlink.ToString(); 
								$NewItem.Update(); start-sleep -milliseconds 200
								log "Applicant record added to list $applistname in $wurl." $logFileName
								#Write-host "A"
									
								#Email to CC applicant
								$displaynameHe = ""; $displaynameHe = $myrow2.NAME + " " + $myrow2.FAMILY
								$displaynameEn = ""; $displaynameEn = $myrow2.LNAME + " " + $myrow2.L_FAMILY
								$SiteTitle = ""; $SiteTitle = $mywebrecord["SiteTitle"]
								$email = ""; $email = $myrow2.E_MAIL
								$welcomMsgText = @"
<div style="direction:ltr;font-family:Arial;color:#000099;"><b>An English version follows the Hebrew</b></div>
<br></br>
<div>שלום $displaynameHe,</div>
<br>
<div>להשלמת הרשמתך ל$SiteTitle אנא לחצו <a href=$wurl> כאן </a>.</div>
<br>
<div>ההתחברות למערכת היא באמצעות חשבון ההתחברות למחשבי חוות המחשבים/ספריות/365 – <a href=$ADurl>חשבון (AD) Active Directory</a> – עבודה במחשוב הציבורי.</div>
<div>יש לשים לב להקליד \cc לפני שם המשתמש, בצורה הבאה:</div>
<div>$ccuname</div>
<br>
<div> אפשר לשחזר את פרטי החשבון <a href=$pURLcc> כאן </a></div>

<div>אנא, יש לשים לב להקליד את הסיסמא עם הבדלים בין אותיות גדולות וקטנות.</div>
<div>תמיכה בחשבון CC אפשר לקבל בשירות לקוחות בטלפון 02-5883450</div>
<div>וואטצאפ  052-588-6733</div>
<div>לתמיכה טכנית פנו אל: <a href="mailto:support@ekmd.huji.ac.il">support@ekmd.huji.ac.il</a> </div>
<br>
<div>בברכה,</div>
<br>
<div>צוות EKMD,</div>
<div>אגף המחשוב,</div>
<div>האוניברסיטה העברית בירושלים.</div>
<br>
<br><div>--------------</div></br>
<div style="direction:ltr;font-family:Arial;color:#000099;">
<p>Welcome $displaynameEn ,
<p>For completing the registration to the Hebrew University of Jerusalem please <a href=$wurl>click here</a>.
</p>
<p>Please sign in to the system using the account you are using to log in to the computers in the computer centers\libraries- 365 <a href=$ADurl>Active Directory account</a>. 
<br/>Please be sure to type cc\ before your username:
<br/>cc\[username]
</p>
<div>You can recover your account details <a href=$pURLcc>here</a>.</div>
<p>For support regarding the CC account please contact the customer support unit by phone at 02-5883450 or WhatsApp 052-588-6733
</p>
<div>Support: <a href="mailto:support@ekmd.huji.ac.il">support@ekmd.huji.ac.il</a></div>
<br></br>
<p>Thank You,<br/> <br/>The EKMD Team,<br/> The IT Division,<br/> The Hebrew University of Jerusalem.</p>
</div>
"@
								$body = $welcomMsgText | Out-String
								try {
									$subj = "הרשמה לאוניברסיטה העברית בירושלים"
									#sendHebMail $welcomMsgText "sergeyr@ekmd.huji.ac.il" $subj
									sendHebMail $welcomMsgText $email $subj
									g; log "Successfully sent mail to smtp <$email> and support" $logFileName; w
								}
								catch {
									$err = $Error[0]
									red; log "(541) Failed to send mail to smtp <$email> and support`n $err" $logFileName; w
								}
							}
							else {
								Write-host "studentId : $myId checking / creating  EKMD GRS"
								#CC username not exist - checking / creating  EKMD GRS user 
								$ekmduname = ""
								$user = $null; $user = get-ADUser -Properties employeeID -Filter 'employeeID -like $myId' 
								if (!$user) {
									Write-host "studentId : $myId Not Found in AD"
									$user8 = $null; $user = get-ADUser -Properties employeeID -Filter 'employeeID -like $myId8' 
									
									if (!$user8)
									{ 
									Write-host "studentId : $myId Not Found in AD 8"
									$ekmduname = "" 
									}
									else {
										if ($user8 -is [array]) { $logonName = ""; log "There are many EKMD users with ID $myId8. Skipping" $logFileName; $noerrors = $false; $resultId = "many EKMD users ID $myId8"; updaction $taskId $resultId ; continue }
										else { $ekmduname = "EKMD\" + $user8.Name; log "Found 8 digits EKMD user with ID $myId8. for $wurl. Consider changeidx " $logFileName; $ekmduname }
									}
								}
								else {
									if ($user -is [array]) { $logonName = ""; log "There are many EKMD users with ID $myId. Skipping" $logFileName; $noerrors = $false; $resultId = "many EKMD users ID $myId"; updaction $taskId $resultId; continue }
									else { $ekmduname = "EKMD\" + $user.Name; $ekmduname }
								} # End if(!$user)
									
								$email = ""; $email = $myrow2.E_MAIL
								write-host "Email is : $email"
								if ($ekmduname -eq "") {
									write-host "creating EKMD user"
									# creating EKMD user
									$isnewuser = $true
									$GN = ""; $GN = $myrow2.LNAME; $GN = $GN.ToLower(); $GN = cap $GN
									$SN = ""; $SN = $myrow2.L_FAMILY; $SN = $SN.ToLower(); $SN = cap $SN
									[string]$SN4NameGen = ""; [string]$SN4NameGen = $SN.replace("-", "") # we keep hyphens but jump over them for name generation
									$appUserName = createUniqueUserName $GN $SN4NameGen
									$appUserName
										
									if (($appUserName -eq $null) -Or ($appUserName -eq "")) {
										red; log "Failed to Generate username for  $GN $SN4NameGen " $logFileName; w
										Send-MailMessage -To $helpdeskEmail -From $donotreply -Subject "MakeUsers4GRS. Failed to Generate username for $GN $SN4NameGen." -body $myrow2 -smtpserver $smtpServerName 
										$resultId = "Failed to Generate username for $GN $SN4NameGen" 
										updaction $taskId $resultId ; continue
									}
									[string]$newUserUPN = "$appUserName@ekmd"
									[string]$DisplayName = ""; $DisplayName = "$GN $SN"
									$Description = "HUJI Studies Registration System"
									$securePWD_ClearText = genPwdx 8 0
									Yellow; log "Generated the Initial password <$securePWD_ClearText> for $myId" $logFileName; w
									$securePWD = convertto-securestring $securePWD_ClearText -asplaintext -force
									$xDate = fncAccExpirationDate
										
									try {
										if (!$asherTest){
										New-ADUser -Server $server -name $appUserName -samAccountName $appUserName -Path $Gen1UsersOU -EmployeeID $myId `
											-UserPrincipalName $newUserUPN -DisplayName $DisplayName -ChangePasswordAtLogon $false -GivenName $GN `
											-Description $Description -Enabled $true -PasswordNotRequired $false -Surname $SN `
											-AccountPassword $securePWD -PasswordNeverExpires $false -HomePhone $myrow2.PHONE  -MobilePhone $myrow2.MOBILE `
											-AccountExpirationDate $xDate -EmailAddress $email -ErrorAction Stop 
										}
										g; log "Successfully created NEW User= <$appUserName>" $logFileName; w
										$ekmduname = "EKMD\" + $appUserName
									}
									catch {
										$err = $Error[0] #.exception.message
										red; log " (517) Failed to create NEW user <$appUserName>  `n$err " $logFileName; w
										$resultId = "Failed to create NEW user <$appUserName>"; updaction $taskId $resultId; continue
									}
									## this code is important as without it next actions may fail inconsistantly - probably DC sync issues per load
									if (!$asherTest){
										Yellow; normalizeDCs $appUserName 30 $logfileName; w
									}	
									# Adding EKMD user to GRS_usersUG Group
									try { 
										if (!$asherTest){
											$gresult = add-adgroupmember $UG2 $appUserName -ea stop 
										}
									}
									catch {
										$err = $Error[0].exception.message
										red; log " (615)FAILED to add <$ekmduname> to <$UG2>`n $err " $logFileName; w
										$noerrors = $false; $resultId = "FAILED to add $ekmduname to $UG2"
									}

									#Set email address async mode on mng server
									$mystr = ""; $mystr = $appUserName + "," + $email
									if ((Test-Path $emailfile) -eq $false) { Add-Content -Value $emailTitlestr -Path $emailfile }
									Add-Content -Value $mystr -Path $emailfile
										
								} #End if($ekmduname -eq "")

								# continue register $ekmduname
								$ekmduname2 = ""; $ekmduname2 = $ekmduname.Replace("EKMD\", "")
								log "Proceeding registration of $ekmduname in the list $applistname in $wurl " $logFileName
								if (!$DocLibDone) {
									$tmpName = $mywebrecord["template"]
									$listTemplates = $tsite.GetCustomListTemplates($web)
									$ListTemplate = $listTemplates[$tmpName]
									if ($ListTemplate -eq $null) { logts "Unable to get library template $tmpName - Skipping register " $logFileName; $noerrors = $false; $resultId = "Unable to get library template $tmpName"; updaction $taskId $resultId; continue }
									$tLibraryName = ""; $tLibraryName = $ekmduname.Replace("\", ""); 
									if ($mywebrecord["language"] -eq "He")
									{ $tDescription = ""; $tDescription = $mywebrecord["folderName"] + " " + $myrow2.LNAME + " " + $myrow2.L_FAMILY + " " + $myId }
									else
									{ $tDescription = ""; $tDescription = $mywebrecord["folderName"] + " " + $myrow2.LNAME + " " + $myrow2.L_FAMILY + " " + $myId }
									# Create $tLibrary
									$Web.Lists.Add($tLibraryName, $tDescription, $ListTemplate) > Null
									start-sleep 2
									$tLibrary = $null; $tLibrary = $Web.Lists[$tLibraryName]; $tLibrary.OnQuickLaunch = $false
									# remove permissions
									$tLibrary.BreakRoleInheritance($true, $true) 
									$i = 0
									do {
										if ($tLibrary.RoleAssignments[$i].Member.GetType().Name -eq "SPUser") {
											# remove user
											$account = $web.EnsureUser($tLibrary.RoleAssignments[$i].member.LoginName)
											$tLibrary.RoleAssignments.Remove($account); start-sleep -milliseconds 400
										}
										else {
											#remove group
											$myname = $tLibrary.RoleAssignments[$i].Member.Name
											$tLibrary.RoleAssignments.Remove($tLibrary.RoleAssignments[$i].Member); Start-Sleep -Seconds 1
										}
										$tLibrary.Update(); start-sleep -milliseconds 400
									}while ($tLibrary.RoleAssignments.Count -gt $i)
									# set permissions for applicant
									$GroupRole = $null; [void] ($GroupRole = $web.RoleDefinitions[$SPCPermission] )
									if (!$GroupRole) { 
										$GroupRole = $web.RoleDefinitions[$SPCPermissionHe] 
									}
									log "The Group Role is - $GroupRole ." $logFileName 
									try {
										if (!$asherTest){
										$uaccount = $null; $uaccount = $web.EnsureUser($ekmduname)
										$uaname = $null; start-sleep -milliseconds 200; $uaname = $uaccount.Name
										log "The ensured account name is - $uaname ." $logFileName
										$Newassignment = New-Object Microsoft.SharePoint.SPRoleAssignment($uaccount)
										$Newassignment.RoleDefinitionBindings.Add($GroupRole)
										$tLibrary.RoleAssignments.Add($Newassignment); start-sleep -milliseconds 400 #new permission is added
										}
									}
									catch {
										logts "Failed to set folder permissions for applicant $ekmduname on site $wurl." $logFileName; 
										$noerrors = $false; $resultId = "Failed to set folder permissions"
										Send-MailMessage -To $supportEmail -From $helpdesk -Subject " (GRS)FAILED set folder permissions for <$ekmduname> on $wurl " -body $err -smtpserver $smtpServerName 
									}

									# set permissions for admin group
									$GroupRole = $null; [void] ($GroupRole = $web.RoleDefinitions[$SPFPermission] )
									if (!$GroupRole) { $GroupRole = $web.RoleDefinitions[$SPFPermissionHe] }
									$uaccount = $web.EnsureUser($mywebrecord["adminGroup"])
									try {
										$uaccount = $null; $uaccount = $web.EnsureUser($mywebrecord["adminGroup"])
										$Newassignment = New-Object Microsoft.SharePoint.SPRoleAssignment($uaccount)
										$Newassignment.RoleDefinitionBindings.Add($GroupRole)
										$tLibrary.RoleAssignments.Add($Newassignment); start-sleep -milliseconds 400 #new permission is added
									}
									catch { logts "Failed to set folder permissions for admin group for applicant $ekmduname on site $wurl." $logFileName; $noerrors = $false; $resultId = "Failed to set folder permissions" }

									#Title update
									$tLibrary.Title = $tDescription; $tLibrary.Update()
									$tLibrary.TitleResource.SetValueForUICulture($cultureHE, $tDescription)
									$tLibrary.TitleResource.SetValueForUICulture($cultureEN, $tDescription)
									$tLibrary.TitleResource.Update()
									$tLibrary.OnQuickLaunch = $OnQuickLaunchShow
									# Creating folder contact
									$newalias = ""; $newalias = $mywebrecord["mailSuffix"] + "-" + $tLibraryName
									$tLibrary.RootFolder.Properties["vti_emailusesecurity"] = 0; $tLibrary.RootFolder.Properties["vti_emailattachmentfolders"] = "root"
									$tLibrary.RootFolder.Properties["vti_emailoverwrite"] = 1; $tLibrary.RootFolder.Properties["vti_emailsaveoriginal"] = 0
									$tLibrary.RootFolder.Properties["vti_emailsavemeetings"] = 0; start-sleep -milliseconds 400
									$tLibrary.RootFolder.Update(); $tLibrary.EmailAlias = $newalias; start-sleep -milliseconds 400; 
									$tLibrary.Update()
									log "Applicant folder is created  with specific permissions in $wurl " $logFileName
										
									# Adding EKMD user to applicants AD Group
									#this action is made only once per site so it is placed together with doclib operations
									$UG = ""; $UG = $mywebrecord["applicantsGroup"]; 
									try { $gresult = add-adgroupmember $UG $ekmduname2 -ea stop }
									catch {
										$err = $Error[0].exception.message
										red; log " (608)FAILED to add <$ekmduname> to <$UG>`n $err " $logFileName; w
										$noerrors = $false; $resultId = "FAILED to add $ekmduname to $UG"
									}
									$DocLibDone = $true
								} #End if(!$DocLibDone)

								# add record to destination list
								$NewItem = $applist.AddItem()
								$NewItem["Title"] = "Applicant"; 
								$NewItem["firstName"] = $myrow2.LNAME; 
								$NewItem["surname"] = $myrow2.L_FAMILY; 
								$NewItem["email"] = $email; 
								$NewItem["homePhone"] = $myrow2.PHONE; 
								$NewItem["mobile"] = $myrow2.MOBILE; 
								$NewItem["firstNameHe"] = $myrow2.NAME; 
								$NewItem["surnameHe"] = $myrow2.FAMILY; 
								$NewItem["addressHe"] = $myrow2.ADDRESS; 
								$NewItem["cityHe"] = $myrow2.YSH; 
								$NewItem["zipHe"] = $myrow2.MIKUD; 
								$NewItem["userName"] = $ekmduname; 
								$NewItem["folderMail"] = $newalias + "@ekmd.huji.ac.il"; 
								$NewItem["folderName"] = $tDescription; 
								$NewItem["studentId"] = $myId; 
								$NewItem["A"] = 1; 
								#$NewItem["deadline"] = $mywebrecord["deadline"]; 
								$NewItem["submit"] = $false; 
								$tlink = $null; $tlink = new-object Microsoft.SharePoint.SPFieldUrlValue($NewItem["folderLink"])
								$tlink.Description = "Files " + $myrow2.L_FAMILY + " " + $myrow2.LNAME; $tlink.Url = $tLibrary.RootFolder.ServerRelativeUrl
								$NewItem["folderLink"] = $tlink.ToString(); 
								$NewItem.Update(); start-sleep -milliseconds 200
								log "Applicant record added to list $applistname in $wurl." $logFileName
								#Write-host "A"
									
								#Email to EKMD applicant
								$displaynameHe = ""; $displaynameHe = $myrow2.NAME + " " + $myrow2.FAMILY
								$displaynameEn = ""; $displaynameEn = $myrow2.LNAME + " " + $myrow2.L_FAMILY
								$SiteTitle = ""; $SiteTitle = $mywebrecord["SiteTitle"]
								if ($isnewuser -eq $true) {
									$welcomMsgText = @"
<div style="direction:ltr;font-family:Arial;color:#000099;"><b>An English version follows the Hebrew</b></div>
<br></br>
<div>שלום $displaynameHe,</div>
<br>
<div>להשלמת הרשמתך ל$SiteTitle אנא לחצו <a href=$wurl> כאן </a>.</div>
<br>
<div>ההתחברות למערכת היא באמצעות פרטי חשבון הבאים:</div>
<div>שם המשתמש:  <b>$appUserName</b> </div>
<div>סיסמתך היא  <b>$securePWD_ClearText</b></div>
<br>
<div>אנא, יש לשים לב להקליד את הסיסמא עם הבדלים בין אותיות גדולות וקטנות.</div>
<div> החלפת סיסמא ניתן לבצע <a href=$pURLekmdHe> כאן </a></div>
<br></br>
<div>לתמיכה טכנית פנו אל: <a href="mailto:support@ekmd.huji.ac.il">support@ekmd.huji.ac.il</a> </div>
<br>
<div>בברכה,</div>
<br>
<div>צוות EKMD,</div>
<div>אגף המחשוב,</div>
<div>האוניברסיטה העברית בירושלים.</div>
<br>
<br><div>--------------</div></br>
<div style="direction:ltr;font-family:Arial;color:#000099;">
<p>Welcome $displaynameEn ,
<p>For completing the registration to the Hebrew University of Jerusalem please <a href=$wurl>click here</a>.
</p>
<p>UserName: <b>$appUserName</b><br/>
   Password:   <b>$securePWD_ClearText</b></p>
<div> To change your password     <a href=$pURLekmdEn>click here</a>.</div>
<br></br>
<div>Support: <a href="mailto:support@ekmd.huji.ac.il">support@ekmd.huji.ac.il</a></div>
<br></br>
<p>Thank You,<br/> <br/>The EKMD Team,<br/> The IT Division,<br/> The Hebrew University of Jerusalem.</p>
</div>
"@
								}
								else {
									$welcomMsgText = @"
<div style="direction:ltr;font-family:Arial;color:#000099;"><b>An English version follows the Hebrew</b></div>
<br></br>
<div>שלום $displaynameHe,</div>
<br>
<div>להשלמת הרשמתך ל$SiteTitle אנא לחצו <a href=$wurl> כאן </a>.</div>
<br>
<div>ההתחברות למערכת היא באמצעות</div>
<div>שם המשתמש:  <b>$ekmduname2</b> </div>
<br>
<div> איפוס סיסמא ניתן לבצע <a href=$prURLekmdHe> כאן </a></div>
<br></br>
<div>לתמיכה טכנית פנו אל: <a href="mailto:support@ekmd.huji.ac.il">support@ekmd.huji.ac.il</a> </div>
<br>
<div>בברכה,</div>
<br>
<div>צוות EKMD,</div>
<div>אגף המחשוב,</div>
<div>האוניברסיטה העברית בירושלים.</div>
<br>
<br><div>--------------</div></br>
<div style="direction:ltr;font-family:Arial;color:#000099;">
<p>Welcome $displaynameEn ,
<p>For completing the registration to the Hebrew University of Jerusalem please <a href=$wurl>click here </a>.
</p>
<p>UserName: <b>$ekmduname2</b><br/></p>
<div> To reset your password     <a href=$prURLekmdEn>click here</a>.</div>
<br></br>
<div>Support: <a href="mailto:support@ekmd.huji.ac.il">support@ekmd.huji.ac.il</a></div>
<br></br>
<p>Thank You,<br/> <br/>The EKMD Team,<br/> The IT Division,<br/> The Hebrew University of Jerusalem.</p>
</div>
"@
									
								}
								$body = $welcomMsgText | Out-String
								try {
									$subj = "הרשמה לאוניברסיטה העברית בירושלים"
									#sendHebMail $welcomMsgText "sergeyr@ekmd.huji.ac.il" $subj
									sendHebMail $welcomMsgText $email $subj
									g; log "Successfully sent mail to smtp <$email> and support" $logFileName; w
								}
								catch {
									$err = $Error[0]
									red; log "(795) Failed to send mail to smtp <$email> and support`n $err" $logFileName; w
								}
									
							} #End if($ccuname -and $ccuname -ne "")
						} # End if($myitem)
					} # End if(!$applist)
				} #End foreach($applistname in $applistrow)
			} #End Foreach($rec in $UrlsArray)
			break
		} # end 1 - new record case
			
		"3" {
			log "Update personal data proc" $logFileName
		} # end 3 - Personal Data Update case
	} # end switch ($myrow.ACTION_TYPE_ID)

	# Update Action Item row
	if ($noerrors -eq $true) { $resultId = "Task complete" }; updaction $taskId $resultId

} #end foreach($myrow in $table.Rows)

#endregion main loop
return $noerrors; exit

