white
$myHelp=@"
Runs perform registration action based on pending actions table in SQL database (grs_users).

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
$logFileName = $sourceFileName+"_action03_$timeStamp.log"        #log file per each run using same time stamp
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
$pURLcc = "https://pm.cc.huji.ac.il/pwm/public/landing.jsp"
#$pURLekmd = "http://ekmdpwd.ekmd.huji.ac.il"
$pURLekmdEn = "https://grs2.ekmd.huji.ac.il/Pages/pwdChange.aspx"
$pURLekmdHe = "https://grs2.ekmd.huji.ac.il/Pages/pwdChange.aspx"
$ADurl = "http://ca.huji.ac.il/book/%D7%97%D7%A9%D7%91%D7%95%D7%9F-active-directory-ad"
$emailfile = $inputFilePath + "mailenablex.dat"
$emailTitlestr = "Username,Email"
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
		#Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To $target -From $doNotReply -Subject $subj -body $newtext -BodyAsHtml -smtpserver "ekekcas01"  -erroraction Stop
		Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To $target -From $doNotReply -cc "support@ekmd.huji.ac.il" -Subject $subj -body $newtext -BodyAsHtml -smtpserver "ekekcas01"  -erroraction Stop
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
#$xyzlist.Itemcount
if(!$xyzlist){logts "Unable to open $xyzlistname. Exiting." $logFileName;exit}

	$conn = New-Object System.Data.SqlClient.SqlConnection
	$conn.ConnectionString = "Data Source=EKEKSQL00;Initial Catalog=GRS_users;Integrated Security=SSPI;"
	$conn.Open()
	$cmd = New-Object System.Data.SqlClient.SqlCommand
	$cmd.connection = $conn
	$cmd.commandtext = "select * from [dbo].[production_Pending_Actions] WHERE ([f_performed] =0 Or [f_performed] Is Null) And [ACTION_TYPE_ID] ='3' ;"
	$result = $cmd.ExecuteReader()
	$table = new-object "System.Data.DataTable"
	$table.Load($result); start-sleep 1
	$conn.Close()
	$table.Rows.Count

#region main loop
	foreach($myrow in $table.Rows)
	{
		$mystr="";$mystr=$myrow.ID.ToString() + " - " + $myrow.ZEHUT + " - " + $myrow.ACTION_TYPE_ID; Write-host $mystr
		$myAction = "";$myAction = $myrow.ACTION_TYPE_ID.Trim()
		$myTZ = "";$myTZ = $myrow.ZEHUT.Trim()
		$myId = ""; $myId = $myTZ.Replace("-",""); $myId8=""; $myId8=$myId.Substring(0,8)
		$taskId = $null; $taskId = $myrow.ID; $resultId = "Task complete"
		$appUserName = ""; $securePWD_ClearText = ""
		$noerrors = $true;$completed = $false; $isnewuser= $false
		switch ($myAction)
		{
			"3"
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
				if($table2.Rows.Count -gt 1){logts "$myTZ inconsistend data. more than one record in users table.Skipping record." $logFileName; $noerrors = $false; $resultId = "Many Records for one TZ"; updaction $taskId $resultId; continue}
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
				if($urlfound -eq $false){logts "Sites for registration not found in $xyzlistname for $myTZ. Skipping" $logFileName; $noerrors = $false; $resultId = "No site in GRSlist"; updaction $taskId $resultId; continue}
				
				Foreach($rec in $UrlsArray)
				{
					# Get Target web
					$wurl=""; $wurl = $rec.Url
					$web = $null; $web = Get-SPWeb $wurl
					if(!$web){logts "Unable to get web $wurl" $logFileName; $noerrors = $false; $resultId ="Unable to get web"; updaction $taskId $resultId; continue}
					$applistrow="";$applistrow=$rec.DestinationList.Split(";")
					foreach($applistname in $applistrow)
					{
						$applist=$null; $applist=$web.Lists[$applistname]
						if(!$applist){logts "Unable to access the applicants list $applistname in $wurl " $logFileName; $noerrors = $false; $resultId = "unable to access the applicants list"; updaction $taskId $resultId ; continue}
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
									#$myitem["A"] = 1; 
									#$NewItem["deadline"] = $mywebrecord["deadline"]; 
									$myitem.Update(); start-sleep -milliseconds 200
									Write-host "U"
							}
							else 
							{logts "applicants record $myId missing in $applistname on $wurl. Consider to register." $logFileName }
						} # End if(!$applist)
					} #End foreach($applistname in $applistrow)
				} #End Foreach($rec in $UrlsArray)
			break
			} # end 3 - personal data update case
			
			"4"
			{
				log "Update registration data proc" $logFileName
			}# end 4 - Registration Data Update case
		} # end switch ($myrow.ACTION_TYPE_ID)

		# Update Action Item row
		if($noerrors -eq $true){$resultId = "Task complete"}; updaction $taskId $resultId

	} #end foreach($myrow in $table.Rows)

#endregion main loop
return $noerrors; 

exit

