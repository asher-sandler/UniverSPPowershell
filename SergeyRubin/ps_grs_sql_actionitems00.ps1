white
$myHelp=@"
Runs flagging queries on SQL database (grs_users).

------------------- Sergey Rubin Dec 2020 -------------------
"@

#region variables and constants Block 
$server="ekekdc04" # used for debug
$noerrors = $true # flag for good running
$timeStamp = Get-Date -format $timeStampform # for files
If ($args[0] -eq "?") {yellow;$myhelp;white;exit}
$sourceFilePath = "\\ekekfls00\data$\ftpRoot\ibts" # the ftp puts the original file here
$sourceFileName = "MOSMAH_EKMD_2022.DAT"                       # the TEST for dev  file's name
$sourceFile = "$sourceFilePath\$sourceFileName"
$inputFilePath = "\\ekekfls00\data$\scriptFolders\DATA\"
$logFilePath = "\\ekekfls00\data$\scriptFolders\LOGS\"
$inputFileName= $sourceFileName+"_$timeStamp.txt"        # original file is copied and renamed with timestam
$inputFile = "$inputFilePath\$inputFilename"
$logFileName = $sourceFileName+"_update_$timeStamp.log"        #log file per each run using same time stamp
$logFile = "$logFilePath\$logFileName"
$today = Get-Date
$homewebURL = "https://grs.ekmd.huji.ac.il/home"
$xyzlistname = "availableGRSList"
$LinkField = "folderLink"
$SPFPermission = "Full Control"
$SPFPermissionHe = "שליטה מלאה"
$SPRPermission = "Read"
$SPRPermissionHe = "קריאה"
$SPCPermission = "Contribute"
$SPCPermissionHe = "השתתפות"
$cultureHE=[System.Globalization.CultureInfo]::CreateSpecificCulture("he-IL")
$cultureEN=[System.Globalization.CultureInfo]::CreateSpecificCulture("en-US") 
$Gen1UsersOU= "OU=Gen1App_Users,OU=app_users,OU=EKusers,DC=ekmd,DC=huji,DC=uni"
$UG2 = "GRS_usersUG"
$pURL = "https://pm.cc.huji.ac.il/pwm/public/landing.jsp"
$ADurl = "http://ca.huji.ac.il/book/%D7%97%D7%A9%D7%91%D7%95%D7%9F-active-directory-ad"
#endregion variables

#region FUNCTIONS
################ START Functions Block ##################################
function updaction ($taskId,$resultId)
{
	try
	{
		$conn = New-Object System.Data.SqlClient.SqlConnection
		$conn.ConnectionString = "Data Source=EKEKSQL00;Initial Catalog=GRS_users;Integrated Security=SSPI;"
		$conn.Open()
		$cmd = New-Object System.Data.SqlClient.SqlCommand
		$cmd.connection = $conn
		$cmd.Parameters.AddWithValue("@ID",$taskId) | Out-Null
		$cmd.Parameters.AddWithValue("@RESULT_ID",$resultId) | Out-Null
$cmd.commandtext=@"
UPDATE [dbo].[production_Pending_Actions]
SET f_performed = 1, f_performed_date = GETDATE(), ACTION_RESULT_ID = @RESULT_ID
WHERE ID =@ID;
"@
		$cmd.executenonquery()
		start-sleep -milliseconds 200
		$conn.close()
		g; logts "Action with ID $taskId was processed with result $resultId ." $logFileName;w
		return $true
	}
	catch
	{
		$err=$Error[0].exception.message
		red;logts " FAILED to update record of task with ID $taskId with result $resultId  `n $err " $logFileName;w
		$conn.close()
		return $false
	}


}

function fncAccExpirationDate ($age=1095, $deltaDays=30)
 {
  $daysFromNow=get-random -minimum ($age-$deltaDays) -maximum ($age+$deltaDays)
  $newXdate=(get-date).addDays($daysFromNow) #-f "MM/dd/yyyy" 
  return $newXdate
 }

####################
function createUniqueUserName ($newGN,$newSN)
{
 $a=$newSN.length
 set-variable -Name cntStep -value 0
 for ($i=0;$i -le ($newSN.length)-1;$i++) 
 { 
  $suffix+=$newSN[$i]
  $newN=$newGN+$suffix
  $result=Get-ADuser -Filter 'CN -eq $newN' 
  If ($result -ne $null) {} # found such a username - continue
  else  # no such user so this is a good name and we exit
  { 
   return $newN
  }
 } # end of for
} 

####################################################
function normalizeDCs ($targetObj,[int]$repeats,$logfileName)
{
# verifies obj exists on both DCS before exiting
# insert in script after creating an obj user and befor manipulating it to avoid random fails
# can take 1-5 secs
#if (!$targetObj){exit} # we always call this with an object
$time	= $repeats
#y;write-host -NoNewline ".";w
$DcList	= Get-ADDomainController -filter * | name
$cntDCs	= $DcList.count
$counter=0
while ($result -ne $true)  # continuous loop with 500mSec delay
{
 $cntLoops++
 # for each DC
 for ($i=0;$i -le $cntDCs-1;$i++)
 {
  $srv	= $DcList[$i]#.hostname
  #w; log "Verifying Object <$targetObj> on DC <$srv>" $logfileName
  try
   {
    $ans=Get-ADobject -filter 'name -eq $targetObj' -Server $srv -ea silentlycontinue
   }
  catch
   {}
  If ($ans -ne $null) {$counter++;g;log "<$targetobj> found on DC <$srv>" $logfilename;w} else {red;log "<$targetobj> Not found on DC <$srv>" $logfilename;w}
 }
 
 if ($counter -eq $cntDCs){g;log "<$targetobj> normalized on EKMD DCs" $logfileName;w;$result=$true} else {y;"<$targetobj> NOT Normalized on EKMD DCs, trying again";w;$counter = 0}
 if ($cntLoops -eq $repeats){red;log "Object <$targetobj> NOT normalized after <$time> seconds. Aborting this user " $logfileName;$result = $true}
 sleep -Milliseconds 1000
}

} # end of function
function sendEngMail($textBody, $target, $subj)
{
	$newtext =@"
 <!DOCTYPE html>
 <html lang="en" xmlns="http://www.w3.org/1999/xhtml">
 <head>
 <meta charset="utf-8" />
 <title></title>
 </head> 
 <body>
  <div style="font-family:Arial;color:#000099;">
   $textBody
  </div>
 </body>
 </html>
"@
	
	try
	{
		Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To $target -From "huji-app@ekmd.huji.ac.il" -cc $helpdesk -Subject $subj -body $newtext -smtpserver "ekekcas01" -BodyAsHtml -erroraction Stop
		g; log "Successfuly sent Eng mail" $logFileName ;w
	}
	catch
	{
		red; log "Failed Eng mail Send `n$error[0]" $logFileName ; w
	}
	
} #end function

function sendHebMail($textBody, $target, $subj)
{
	$newtext =@"
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
	
	try
	{
		Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To $target -From $doNotReply -Subject $subj -body $newtext -BodyAsHtml -smtpserver "ekekcas01"  -erroraction Stop
		#Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To $target -From $doNotReply -cc $helpdesk -Subject $subj -body $newtext -BodyAsHtml -smtpserver "ekekcas01"  -erroraction Stop
		g; log "Successfuly sent Hebrew mail" $logFileName ;w
	}
	catch
	{
		red; log "Failed Hebrew mail Send `n$error[0]" $logFileName ; w
	}
	
} #end function

function sendHebDuplicateMail($textBody, $target, $subj)
{
	$newtext =@"
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
	
	try
	{
		Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To $target -From $doNotReply -cc $helpdesk -Subject $subj -body $newtext -smtpserver "ekekcas01" -BodyAsHtml -erroraction Stop
		g; log "Successfuly sent Hebrew mail" $logFileName ;w
	}
	catch
	{
		red; log "Failed Hebrew mail Send `n$error[0]" $logFileName ; w
	}
	
} #end function


################ END Functions Block ##################################
#endregion FUNCTIONS

################  START MAIN Block   ##################################
# Get AvailableGRSList
$homeweb = Get-SPWeb $homewebURL
$tsite= Get-spsite $homewebURL

$xyzlist = $homeweb.Lists[$xyzlistname]
$xyzlist.Itemcount
if(!$xyzlist){logts "Unable to open $xyzlistname. Exiting." $logFileName;exit}

	$conn = New-Object System.Data.SqlClient.SqlConnection
	$conn.ConnectionString = "Data Source=EKEKSQL00;Initial Catalog=GRS_users;Integrated Security=SSPI;"
	$conn.Open()
	$cmd = New-Object System.Data.SqlClient.SqlCommand
	$cmd.connection = $conn
	$cmd.commandtext = "select * from [dbo].[production_Pending_Actions] WHERE [f_performed] IS NULL;"
	$result = $cmd.ExecuteReader()
	$table = new-object "System.Data.DataTable"
	$table.Load($result); start-sleep 1
	$conn.Close()

#region main loop
	foreach($myrow in $table.Rows)
	{
		# first row
		$myrow = $table.Rows[0] 
		$mystr="";$mystr=$myrow.ID.ToString() + " - " + $myrow.ZEHUT + " - " + $myrow.ACTION_TYPE_ID; Write-host $mystr
		$myAction = "";$myAction = $myrow.ACTION_TYPE_ID.Trim()
		$myTZ = "";$myTZ = $myrow.ZEHUT.Trim()
		$myId = ""; $myId = $myTZ.Replace("-",""); $myId8=""; $myId8=$myId.Substring(0,8)
		$taskId = $null; $taskId = $myrow.ID; $resultId = "Completed"
		$noerrors = $true;$completed = $false
		switch ($myAction)
		{
			"1"
			{
				# Get user data from Database
				$conn2 = New-Object System.Data.SqlClient.SqlConnection
				$conn2.ConnectionString = "Data Source=EKEKSQL00;Initial Catalog=GRS_users;Integrated Security=SSPI;"
				$conn2.Open()
				$cmd2 = New-Object System.Data.SqlClient.SqlCommand
				$cmd2.connection = $conn2
				$cmd2.Parameters.AddWithValue("@ZEHUT",$myTZ) | Out-Null
				$cmd2.commandtext = "select * from [dbo].[production_users_view] WHERE ZEHUT = @ZEHUT;"
				$result2 = $cmd2.ExecuteReader()
				$table2 = new-object "System.Data.DataTable"
				$table2.Load($result2); start-sleep 1
				$conn2.Close()
				if($table2.Rows.Count -gt 1){logts "$myTZ inconsistend data. more than one record in users table.Skipping record." $logFileName; $noerrors = $false; updaction ($taskId,"Many Records for one TZ"); continue}
				$myrow2 = $table2.Rows[0]
				$myrow2
				$ccuname = ""; $ccuname = $myrow2.CC_USERNAME
				
				# Get Target web names
				$websArray=@()
				#$w1="";if($myrow2.A1_H_EKMD -ne $null){$w1=$myrow2.A1_H_EKMD; $w1=$w1.Trim()}
				$w1="";if(!($myrow2.A1_H_EKMD -is [System.DBNull] -or $myrow2.A1_H_EKMD -eq $null)){$w1=$myrow2.A1_H_EKMD.Trim()} 
				if($w1 -ne ""){$websArray += $w1}
				$w2="";if(!($myrow2.A2_H_EKMD -is [System.DBNull] -or $myrow2.A2_H_EKMD -eq $null)){$w2=$myrow2.A2_H_EKMD.Trim()} 
				if($w2 -ne ""){$websArray += $w2}
				$w3="";if(!($myrow2.A3_H_EKMD -is [System.DBNull] -or $myrow2.A3_H_EKMD -eq $null)){$w3=$myrow2.A3_H_EKMD.Trim()} 
				if($w3 -ne ""){$websArray += $w3}
				$w4="";if(!($myrow2.A4_H_EKMD -is [System.DBNull] -or $myrow2.A4_H_EKMD -eq $null)){$w4=$myrow2.A4_H_EKMD.Trim()} 
				if($w4 -ne ""){$websArray += $w4}
				$w5="";if(!($myrow2.A5_H_EKMD -is [System.DBNull] -or $myrow2.A5_H_EKMD -eq $null)){$w5=$myrow2.A5_H_EKMD.Trim()} 
				if($w5 -ne ""){$websArray += $w5}
				# Get Target web record from AvailableGRSList
				$urlfound = $false
				
				# UrlsArray has to be properly initialized !!!!!
				$UrlsArray=@(); $it = [PSCustomObject] @{Url = "www.google.com"; DestinationList = "applicants";}
				$UrlsArray += $it; $UrlsArray += $it; $UrlsArray=@()
				
				Foreach($aweb in $websArray)
				{
					#$aweb = $websArray[0]
					$mywebrecord = $null; $mywebrecord = $xyzlist.Items |where {$_["relativeURL"] -eq $aweb}
					if($mywebrecord)
					{
						$myurl = ""; $myurl = $mywebrecord["url"]
						if($myurl -and $myurl -ne "")
						{
							$it = [PSCustomObject] @{Url = $myurl.Trim(); DestinationList = $mywebrecord["destinationList"];}
							$UrlsArray += $it;$urlfound=$true
						}
					}
				}
				if($urlfound -eq $false){logts "Sites for registration not found in $xyzlistname for $myTZ. Skipping" $logFileName; $noerrors = $false; updaction ($taskId,"No site in GRSlist"); continue}
				
				#Foreach($rec in $UrlsArray) {$rec}
				Foreach($rec in $UrlsArray)
				{
					$rec = $UrlsArray[0]
					# Get Target web
					$wurl=""; $wurl = $rec.Url
					$web = $null; $web = Get-SPWeb $wurl
					$DocLibDone = $false
					if(!$web){logts "Unable to get web $wurl" $logFileName; $noerrors = $false ;updaction ($taskId,"Unable to get web"); continue}
					$applistrow="";$applistrow=$rec.DestinationList.Split(";")
					foreach($applistname in $applistrow)
					{
						$applist=$null; $applist=$web.Lists[$applistname]
						if(!$applist){logts "Unable to access the applicants list $applistname in $wurl " $logFileName; $noerrors = $false; updaction ($taskId,"unable to access the applicants list"); continue}
						else
						{
							# Check if this ID is present in destination lists 
							$myitem =$null; $myitem =$applist.Items | where{$_["studentId"] -eq $myId} 
							if($myitem)
							{
								# applicant record exist - personal data update needed.
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
									$myitem["A"] = 1; 
									#$NewItem["deadline"] = $mywebrecord["deadline"]; 
									$myitem.Update(); start-sleep -milliseconds 200
									Write-host "U"
							}
							else
							{
								# applicant record is missing - need to register.
								# Check CC\username
								if($ccuname -and $ccuname -ne "")
								{
									#CC username exist
									# create DocLib
									if(!$DocLibDone)
									{
										$tmpName = $mywebrecord["template"]
										$listTemplates=$tsite.GetCustomListTemplates($web)
										$ListTemplate=$listTemplates[$tmpName]
										#$ListTemplate -eq $null
										if($ListTemplate -eq $null){logts "Unable to get library template $tmpName - Skipping register " $logFileName; $noerrors = $false; updaction ($taskId,"Unable to get library template $tmpName"); continue}
										$tLibraryName = ""; $tLibraryName = $ccuname.Replace("\",""); 
										if($mywebrecord["language"] -eq "He")
										{$tDescription = ""; $tDescription = $mywebrecord["folderName"] + " " + $myrow2.NAME + " " + $myrow2.FAMILY + " " + $myId}
										else
										{$tDescription = ""; $tDescription = $mywebrecord["folderName"] + " " + $myrow2.LNAME + " " + $myrow2.LFAMILY + " " + $myId}
										# Create $tLibrary
										$Web.Lists.Add($tLibraryName,$tDescription,$ListTemplate) > Null
										start-sleep 2
										$tLibrary =  $null; $tLibrary =  $Web.Lists[$tLibraryName]; $tLibrary.OnQuickLaunch = $false
										# remove permissions
										$tLibrary.BreakRoleInheritance($true,$true) 
										$i=0
										#foreach($ra in $tLibrary.RoleAssignments){$ra..member.LoginName}
										do{
											if($tLibrary.RoleAssignments[$i].Member.GetType().Name -eq "SPUser")
											{
												# remove user
												$account=$web.EnsureUser($tLibrary.RoleAssignments[$i].member.LoginName)
												$tLibrary.RoleAssignments.Remove($account); start-sleep -milliseconds 400
											}
											else
											{
												#remove group
												$myname = $tLibrary.RoleAssignments[$i].Member.Name
												$tLibrary.RoleAssignments.Remove($tLibrary.RoleAssignments[$i].Member);Start-Sleep -Seconds 1
											}
											#$tLibrary.OnQuickLaunch = $false
											$tLibrary.Update();start-sleep -milliseconds 400
										}while($tLibrary.RoleAssignments.Count -gt $i)
										# set permissions for applicant
										$GroupRole = $null; [void] ($GroupRole = $web.RoleDefinitions[$SPCPermission] )
										if(!$GroupRole){$GroupRole = $web.RoleDefinitions[$SPCPermissionHe]}
										try
										{
											$uaccount=$null; $uaccount=$web.EnsureUser($ccuname)
											#strange error - user not found can occur. 
											$Newassignment = New-Object Microsoft.SharePoint.SPRoleAssignment($uaccount)
											$Newassignment.RoleDefinitionBindings.Add($GroupRole)
											$tLibrary.RoleAssignments.Add($Newassignment); start-sleep -milliseconds 400 #new permission is added
										}
										catch{logts "Failed to set folder permissions for applicant $ccuname on site $wurl." $logFileName; $noerrors = $false; $resultId = "Failed to set folder permissions"}

										# set permissions for admin group
										$GroupRole = $null; [void] ($GroupRole = $web.RoleDefinitions[$SPFPermission] )
										if(!$GroupRole){$GroupRole = $web.RoleDefinitions[$SPFPermissionHe]}
										$uaccount=$web.EnsureUser($mywebrecord["adminGroup"])
										try
										{
											$uaccount=$null; $uaccount=$web.EnsureUser($mywebrecord["adminGroup"])
											$Newassignment = New-Object Microsoft.SharePoint.SPRoleAssignment($uaccount)
											$Newassignment.RoleDefinitionBindings.Add($GroupRole)
											$tLibrary.RoleAssignments.Add($Newassignment); start-sleep -milliseconds 400 #new permission is added
										}
										catch{logts "Failed to set folder permissions for admin group for applicant $ccuname on site $wurl." $logFileName; $noerrors = $false; $resultId = "Failed to set folder permissions"}

										#Title update
										$tLibrary.Title = $tDescription; $tLibrary.Update()
										$tLibrary.TitleResource.SetValueForUICulture($cultureHE, $tDescription)
										$tLibrary.TitleResource.SetValueForUICulture($cultureEN, $tDescription)
										$tLibrary.TitleResource.Update()
										$tLibrary.OnQuickLaunch = $true
										# Creating folder contact
										$newalias = ""; $newalias = $mywebrecord["mailSuffix"] + "-" + $tLibraryName
										$tLibrary.RootFolder.Properties["vti_emailusesecurity"]= 0; $tLibrary.RootFolder.Properties["vti_emailattachmentfolders"] = "root"
										$tLibrary.RootFolder.Properties["vti_emailoverwrite"] = 1; $tLibrary.RootFolder.Properties["vti_emailsaveoriginal"] = 0
										$tLibrary.RootFolder.Properties["vti_emailsavemeetings"] = 0; start-sleep -milliseconds 400
										$tLibrary.RootFolder.Update(); $tLibrary.EmailAlias = $newalias; start-sleep -milliseconds 400; 
										$tLibrary.Update()
										
										# Adding cc user to applicants AD Group
										#this action is made only once per site so it is placed together with doclib operations
										$UG = ""; $UG = $mywebrecord["applicantsGroup"]; $appUserName = ""; $appUserName =$ccuname.Replace("CC\","")
										try
										{
											$usr = $null; $usr = Get-ADUser -Identity $appUserName -Server "hustaff.huji.local"
											$grp = $null; $grp = Get-ADGroup -Identity $UG -Server "ekmd.huji.uni"
											$result = add-adgroupmember -Identity $grp -Members $usr -ea stop
										}
										 catch
										{
											$err=$Error[0].exception.message
											red;log " (430)FAILED to add <$ccuname> to <$UG>`n $err " $logFileName;w
											$noerrors = $false; $resultId = "FAILED to add $ccuname to $UG"
											#Send-MailMessage -To "sergeyr@ekmd.huji.ac.il" -From $helpdesk -Subject " (GRS)FAILED to add <$ccuname> to <$UG>" -body $err -smtpserver "ekekcas01" 
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
									$tlink=$null; $tlink= new-object Microsoft.SharePoint.SPFieldUrlValue($NewItem["folderLink"])
									$tlink.Description = $myrow2.L_FAMILY + " " + $myrow2.LNAME; $tlink.Url = $tLibrary.RootFolder.ServerRelativeUrl
									$NewItem["folderLink"] = $tlink.ToString(); 
									$NewItem.Update(); start-sleep -milliseconds 200
									Write-host "A"
									
									#Email to CC applicant
									$displaynameHe="";$displaynameHe=$myrow2.NAME + " " + $myrow2.FAMILY
									$displaynameEn="";$displaynameEn=$myrow2.LNAME + " " + $myrow2.L_FAMILY
									$SiteTitle = ""; $SiteTitle = $mywebrecord["SiteTitle"]
									$email= ""; $email = $myrow2.E_MAIL
$welcomMsgText=@"
<div style="direction:ltr;font-family:Arial;color:#000099;"><b>An English version follows the Hebrew</b></div>
<br></br>
<div>שלום $displaynameHe,</div>
<br>
<div>השלמת הרשמתך ל [$SiteTitle] מתבצעת באתר [<a href=$wurl>$wurl</a>].</div>
<br>
<div>ההתחברות למערכת היא באמצעות חשבון ההתחברות למחשבי חוות המחשבים/ספריות/365 – <a href=$ADurl>חשבון (AD) Active Directory</a> – עבודה במחשוב הציבורי.</div>
<div>יש לשים לב להקליד cc\ לפני שם המשתמש, בצורה הבאה:</div>
<div>$ccuname</div>
<br>
<div> אפשר לשחזר את פרטי החשבון <a href=$pURL> כאן </a></div>

<div>אנא, יש לשים לב להקליד את הסיסמא עם הבדלים בין אותיות גדולות וקטנות.</div>
<div>תמיכה בחשבון CC אפשר לקבל בשירות לקוחות בטלפון 02-5883450</div>
<div>וואטצאפ  052-588-6733</div>
<div> כתובת מערכת השלמת הרשמה לאוניברסיטה :[ <a href=$wurl>$wurl</a> ]</div>
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
<p>Completing the registration to the Hebrew University of Jerusalem is carried out on the site <a href=$wurl>$wurl</a>
</p>
<p>Please sign in to the system using the account you are using to log in to the computers in the computer centers\libraries- 365 <a href=$ADurl>Active Directory account</a>. 
<br/>Please be sure to type cc\ before your username:
<br/>cc\[username]
</p>
<div>You can recover your account details <a href=$pURL>here</a>.</div>
<p>For support regarding the CC account please contact the customer support unit by phone at 02-5883450 or WhatsApp 052-588-6733
</p>
<div>    Sign in  <a href="$wurl"> $SiteTitle </a>.</div>
<div>Support: <a href="mailto:support@ekmd.huji.ac.il">support@ekmd.huji.ac.il</a></div>
<br></br>
<p>Thank You,<br/> <br/>The EKMD Team,<br/> The IT Division,<br/> The Hebrew University of Jerusalem.</p>
</div>
"@
									$body = $welcomMsgText | Out-String
									try
									{
										$subj = "הרשמה לאוניברסיטה העברית בירושלים"
										#sendHebMail $welcomMsgText "sergeyr@ekmd.huji.ac.il" $subj
										sendHebMail $welcomMsgText $email $subj
										g; log "Successfully sent mail to smtp <$email> and $helpdesk" $logFileName; w
									}
									catch
									{
										$err=$Error[0]
										red;log "(541) Failed to send mail to smtp <$email> and helpdesk`n $err" $logFileName;w
									}

								}
								else
								{
									#CC username not exist - checking / creating  EKMD GRS user 
									$ekmduname = ""
									$user = $null; $user = get-ADUser -Properties employeeID -Filter 'employeeID -like $myId' 
									if(!$user)
									{
										$user8 = $null; $user = get-ADUser -Properties employeeID -Filter 'employeeID -like $myId8' 
										if(!$user8)
											{$ekmduname = ""}
										else
										{
											if($user8 -is [array]) {$logonName = ""; log "There are many EKMD users with ID $myId8. Skipping" $logFileName; $noerrors = $false; updaction ($taskId,"many EKMD users ID $myId8"); continue}
											else {$ekmduname = "EKMD\" + $user8.Name; log "Found 8 digits EKMD user with ID $myId8. for $wurl. Consider changeidx " $logFileName}
										}
									}
									else
									{
										if($user -is [array]) {$logonName = ""; log "There are many EKMD users with ID $myId. Skipping" $logFileName;$noerrors = $false; updaction ($taskId,"many EKMD users ID $myId"); continue}
										else {$ekmduname = "EKMD\" + $user.Name; $ekmduname}
									} # End if(!$user)
									
									if($ekmduname -eq "")
									{
										# creating EKMD user
										
										$GN = $myrow2.LNAME; $GN = cap $GN
										$SN = $myrow2.LFAMILY; $SN = cap $SN
										[string]$SN4NameGen=$SN.replace("-", "") # we keep hyphens but jump over them for name generation
										$appUserName = createUniqueUserName $GN $SN4NameGen
										if(($appUserName is $null) -Or ($appUserName -eq""))
										{
											red;log "Failed to Generate username for  $GN $SN4NameGen " $logFileName;w
											Send-MailMessage -To "helpdesk@ekmd.huji.ac.il" -From $donotreply -Subject "MakeUsers4GRS. Failed to Generate username for $GN $SN4NameGen." -body $myrow2 -smtpserver "ekekcas01" 
											updaction ($taskId,"Failed to Generate username for $GN $SN4NameGen"); continue
										}
										[string]$newUserUPN="$appUserName@ekmd"
										[string]$DisplayName = ""; $DisplayName = "$GN $SN"
										$Description = "HUJI Studies Registration System"
										$securePWD_ClearText=genPwdx 8 0
										y;log "Generated the Initial password <$securePWD_ClearText> for $myId" $logFileName;w
										$securePWD= convertto-securestring $securePWD_ClearText -asplaintext -force
										$xDate= fncAccExpirationDate
										try
										{
New-ADUser -Server $server -name $appUserName -samAccountName $appUserName -Path $Gen1UsersOU -EmployeeID $myId `
-UserPrincipalName $newUserUPN -DisplayName $DisplayName -ChangePasswordAtLogon $false -GivenName $GN `
-Description $Description -Enabled $true -PasswordNotRequired $false -Surname $SN `
-AccountPassword $securePWD -PasswordNeverExpires $false -HomePhone $myrow2.PHONE  -MobilePhone $myrow2.MOBILE `
-AccountExpirationDate $xDate -ErrorAction Stop 



New-ADUser -Server "ekekdc04" -name "govardhanah" -samAccountName "govardhanah" -Path $Gen1UsersOU -EmployeeID "1q3w5e7r9" `
-UserPrincipalName "govardhanah@ekmd" -DisplayName "govardhanah" -ChangePasswordAtLogon $false -GivenName "govardhanah" `
-Description $Description -Enabled $true -PasswordNotRequired $false -Surname "govardhanah" `
-AccountPassword $securePWD -PasswordNeverExpires $false -AccountExpirationDate $xDate -EmailAddress "govardhanah@gmail.com" -ErrorAction Stop 







											g; log "Successfully created NEW User= <$appUserName>" $logFileName;w
											$ekmduname = "EKMD\" + $appUserName
										}
										catch
										{
											$err=$Error[0] #.exception.message
											red;log " (517) Failed to create NEW user <$appUserName>  `n$err " $logFileName;w
											updaction ($taskId,"Failed to create NEW user <$appUserName>"); continue
										}
										## this code is important as without it next actions may fail inconsistantly - probably DC sync issues per load
										y;normalizeDCs $appUserName 30 $logfileName;w
										
										# Adding cc user to GRS_usersUG Group
										try {$result = add-adgroupmember $UG2 $appUserName -ea stop}
										catch
										{
											$err=$Error[0].exception.message
											red;log " (615)FAILED to add <$ekmduname> to <$UG2>`n $err " $logFileName;w
											$noerrors = $false; $resultId = "FAILED to add $ekmduname to $UG2"
										}

										#Set email address
										
										
										
									} #End if($ekmduname -eq "")

									# continue register $ekmduname
									if(!$DocLibDone)
									{
										$tmpName = $mywebrecord["template"]
										$listTemplates=$tsite.GetCustomListTemplates($web)
										$ListTemplate=$listTemplates[$tmpName]
										#$ListTemplate -eq $null
										if($ListTemplate -eq $null){logts "Unable to get library template $tmpName - Skipping register " $logFileName; $noerrors = $false; updaction ($taskId,"Unable to get library template $tmpName"); continue}
										$tLibraryName = ""; $tLibraryName = $ekmduname.Replace("\",""); 
										if($mywebrecord["language"] -eq "He")
										{$tDescription = ""; $tDescription = $mywebrecord["folderName"] + " " + $myrow2.NAME + " " + $myrow2.FAMILY + " " + $myId}
										else
										{$tDescription = ""; $tDescription = $mywebrecord["folderName"] + " " + $myrow2.LNAME + " " + $myrow2.LFAMILY + " " + $myId}
										# Create $tLibrary
										$Web.Lists.Add($tLibraryName,$tDescription,$ListTemplate) > Null
										start-sleep 2
										$tLibrary =  $null; $tLibrary =  $Web.Lists[$tLibraryName]; $tLibrary.OnQuickLaunch = $false
										# remove permissions
										$tLibrary.BreakRoleInheritance($true,$true) 
										$i=0
										do{
											if($tLibrary.RoleAssignments[$i].Member.GetType().Name -eq "SPUser")
											{
												# remove user
												$account=$web.EnsureUser($tLibrary.RoleAssignments[$i].member.LoginName)
												$tLibrary.RoleAssignments.Remove($account); start-sleep -milliseconds 400
											}
											else
											{
												#remove group
												$myname = $tLibrary.RoleAssignments[$i].Member.Name
												$tLibrary.RoleAssignments.Remove($tLibrary.RoleAssignments[$i].Member);Start-Sleep -Seconds 1
											}
											#$tLibrary.OnQuickLaunch = $false
											$tLibrary.Update();start-sleep -milliseconds 400
										}while($tLibrary.RoleAssignments.Count -gt $i)
										# set permissions for applicant
										$GroupRole = $null; [void] ($GroupRole = $web.RoleDefinitions[$SPCPermission] )
										if(!$GroupRole){$GroupRole = $web.RoleDefinitions[$SPCPermissionHe]}
										try
										{
											$uaccount=$null; $uaccount=$web.EnsureUser($ekmduname)
											$Newassignment = New-Object Microsoft.SharePoint.SPRoleAssignment($uaccount)
											$Newassignment.RoleDefinitionBindings.Add($GroupRole)
											$tLibrary.RoleAssignments.Add($Newassignment); start-sleep -milliseconds 400 #new permission is added
										}
										catch{logts "Failed to set folder permissions for applicant $ekmduname on site $wurl." $logFileName; $noerrors = $false; $resultId = "Failed to set folder permissions"}

										# set permissions for admin group
										$GroupRole = $null; [void] ($GroupRole = $web.RoleDefinitions[$SPFPermission] )
										if(!$GroupRole){$GroupRole = $web.RoleDefinitions[$SPFPermissionHe]}
										$uaccount=$web.EnsureUser($mywebrecord["adminGroup"])
										try
										{
											$uaccount=$null; $uaccount=$web.EnsureUser($mywebrecord["adminGroup"])
											$Newassignment = New-Object Microsoft.SharePoint.SPRoleAssignment($uaccount)
											$Newassignment.RoleDefinitionBindings.Add($GroupRole)
											$tLibrary.RoleAssignments.Add($Newassignment); start-sleep -milliseconds 400 #new permission is added
										}
										catch{logts "Failed to set folder permissions for admin group for applicant $ekmduname on site $wurl." $logFileName; $noerrors = $false; $resultId = "Failed to set folder permissions"}

										#Title update
										$tLibrary.Title = $tDescription; $tLibrary.Update()
										$tLibrary.TitleResource.SetValueForUICulture($cultureHE, $tDescription)
										$tLibrary.TitleResource.SetValueForUICulture($cultureEN, $tDescription)
										$tLibrary.TitleResource.Update()
										$tLibrary.OnQuickLaunch = $true
										# Creating folder contact
										$newalias = ""; $newalias = $mywebrecord["mailSuffix"] + "-" + $tLibraryName
										$tLibrary.RootFolder.Properties["vti_emailusesecurity"]= 0; $tLibrary.RootFolder.Properties["vti_emailattachmentfolders"] = "root"
										$tLibrary.RootFolder.Properties["vti_emailoverwrite"] = 1; $tLibrary.RootFolder.Properties["vti_emailsaveoriginal"] = 0
										$tLibrary.RootFolder.Properties["vti_emailsavemeetings"] = 0; start-sleep -milliseconds 400
										$tLibrary.RootFolder.Update(); $tLibrary.EmailAlias = $newalias; start-sleep -milliseconds 400; 
										$tLibrary.Update()
										
										# Adding EKMD user to applicants AD Group
										#this action is made only once per site so it is placed together with doclib operations
										$UG = ""; $UG = $mywebrecord["applicantsGroup"]; 
										try {$result = add-adgroupmember $UG $appUserName -ea stop}
										catch
										{
											$err=$Error[0].exception.message
											red;log " (608)FAILED to add <$ekmduname> to <$UG>`n $err " $logFileName;w
											$noerrors = $false; $resultId = "FAILED to add $ekmduname to $UG"
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
									$NewItem["userName"] = $ekmduname; 
									$NewItem["folderMail"] = $newalias + "@ekmd.huji.ac.il"; 
									$NewItem["folderName"] = $tDescription; 
									$NewItem["studentId"] = $myId; 
									$NewItem["A"] = 1; 
									#$NewItem["deadline"] = $mywebrecord["deadline"]; 
									$NewItem["submit"] = $false; 
									$tlink=$null; $tlink= new-object Microsoft.SharePoint.SPFieldUrlValue($NewItem["folderLink"])
									$tlink.Description = $myrow2.L_FAMILY + " " + $myrow2.LNAME; $tlink.Url = $tLibrary.RootFolder.ServerRelativeUrl
									$NewItem["folderLink"] = $tlink.ToString(); 
									$NewItem.Update(); start-sleep -milliseconds 200
									Write-host "A"
									
									#Email to EKMD applicant
									$displaynameHe="";$displaynameHe=$myrow2.NAME + " " + $myrow2.FAMILY
									$displaynameEn="";$displaynameEn=$myrow2.LNAME + " " + $myrow2.L_FAMILY
									$SiteTitle = ""; $SiteTitle = $mywebrecord["SiteTitle"]
									$email= ""; $email = $myrow2.E_MAIL
$welcomMsgText=@"
<div style="direction:ltr;font-family:Arial;color:#000099;"><b>An English version follows the Hebrew</b></div>
<br></br>
<div>שלום $displaynameHe,</div>
<br>
<div>השלמת הרשמתך ל [$SiteTitle] מתבצעת באתר [<a href=$wurl>$wurl</a>].</div>
<br>
<div>ההתחברות למערכת היא באמצעות חשבון ההתחברות למחשבי חוות המחשבים/ספריות/365 – <a href=$ADurl>חשבון (AD) Active Directory</a> – עבודה במחשוב הציבורי.</div>
<div>יש לשים לב להקליד cc\ לפני שם המשתמש, בצורה הבאה:</div>
<div>$ccuname</div>
<br>
<div> אפשר לשחזר את פרטי החשבון <a href=$pURL> כאן </a></div>

<div>אנא, יש לשים לב להקליד את הסיסמא עם הבדלים בין אותיות גדולות וקטנות.</div>
<div>תמיכה בחשבון CC אפשר לקבל בשירות לקוחות בטלפון 02-5883450</div>
<div>וואטצאפ  052-588-6733</div>
<div> כתובת מערכת השלמת הרשמה לאוניברסיטה :[ <a href=$wurl>$wurl</a> ]</div>
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
<p>Completing the registration to the Hebrew University of Jerusalem is carried out on the site <a href=$wurl>$wurl</a>
</p>
<p>Please sign in to the system using the account you are using to log in to the computers in the computer centers\libraries- 365 <a href=$ADurl>Active Directory account</a>. 
<br/>Please be sure to type cc\ before your username:
<br/>cc\[username]
</p>
<div>You can recover your account details <a href=$pURL>here</a>.</div>
<p>For support regarding the CC account please contact the customer support unit by phone at 02-5883450 or WhatsApp 052-588-6733
</p>
<div>    Sign in  <a href="$wurl"> $SiteTitle </a>.</div>
<div>Support: <a href="mailto:support@ekmd.huji.ac.il">support@ekmd.huji.ac.il</a></div>
<br></br>
<p>Thank You,<br/> <br/>The EKMD Team,<br/> The IT Division,<br/> The Hebrew University of Jerusalem.</p>
</div>
"@
									$body = $welcomMsgText | Out-String
									try
									{
										$subj = "הרשמה לאוניברסיטה העברית בירושלים"
										#sendHebMail $welcomMsgText "sergeyr@ekmd.huji.ac.il" $subj
										sendHebMail $welcomMsgText $email $subj
										g; log "Successfully sent mail to smtp <$email> and $helpdesk" $logFileName; w
									}
									catch
									{
										$err=$Error[0]
										red;log "(541) Failed to send mail to smtp <$email> and helpdesk`n $err" $logFileName;w
									}


									
									
								} #End if($ccuname -and $ccuname -ne "")
							} # End if($myitem)
						} # End if(!$applist)
					} #End foreach($applistname in $applistrow)
					
					
					
					
					
				} #End Foreach($rec in $UrlsArray)
				
			} # end 1 - new record case
			
			"2"
			{
				log "Cancel registration proc" $logFileName
			} # end 2 - cancelled record case
			
			"3"
			{
				log "Update personal data proc" $logFileName
			} # end 3 - Personal Data Update case
			
			"4"
			{
				log "Update registration data proc" $logFileName
			}# end 4 - Registration Data Update case
		} # end switch ($myrow.ACTION_TYPE_ID)

		# Update Action Item row
		# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		#
		updaction($taskId, $resultId)


	} #end foreach($myrow in $table.Rows)

#endregion main loop
return $noerrors; exit

