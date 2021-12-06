
function log($message, $filename) {
	write-host $message -f Cyan
}
function logts($message, $filename) {
	write-host $message -f Green
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
write-host "SEMESTER:  1"           #$logFileName
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

$homeweb = Get-SPWeb $homewebURL
$tsite = Get-spsite $homewebURL

$xyzlist = $homeweb.Lists[$xyzlistname]

if (!$xyzlist) { 
	logts "Unable to open $xyzlistname. Exiting." $logFileName; 
	exit;
}
else
{
	logts "Open SP List $xyzlistname." $logFileName;
    $xyzArr = @()
	forEach($listItem in $xyzlist.Items){
		$itemObj = "" | Select-Object EKMD, deadline
		$itemObj.EKMD = $listItem["relativeURL"]
		$itemObj.deadline =   $listItem["deadline"]
		$xyzArr += $itemObj
		
	}
	#$xyzArr
	
	logts "Open SQL HUG Table." $logFileName;
	$conn = New-Object System.Data.SqlClient.SqlConnection
	$conn.ConnectionString = $ConnString
	$conn.Open()
	$cmd = New-Object System.Data.SqlClient.SqlCommand
	$cmd.connection = $conn
	$cmd.commandtext = "select * from [dbo].[production_HUG];"
	$result = $cmd.ExecuteReader()
	$table = new-object "System.Data.DataTable"
	$table.Load($result); start-sleep 1
	#$conn.Close()
	$table.Rows.Count

    $sqlArr = @() 
	foreach ($sqlRow in $table.Rows) {
       		
	   $xItem = "" | Select-Object ID, EKMD, DeadLine
	   $xItem.ID  = $sqlRow["ID"]
	   $xItem.EKMD  = $sqlRow["EKMD"]
	   $xItem.DeadLine  = $sqlRow["DEADLINE"]
	   #write-host $sqlRow.ID
	   #write-host $sqlRow.EKMD
	   #write-host $sqlRow.DEADLINE
	   
	   #write-host $sqlRow.ID
	   $sqlArr += $xItem
	   
	}
	$sqlTempl = "UPDATE [dbo].[production_HUG]
 SET DeadLine = CAST('{DeadLine}' AS DATETIME)
 WHERE ID = {ID};"
    $sqlString = ""
	forEach ($spItem in $xyzArr){
		#$foundInSQLList = $false
		forEach($sqlItm in $sqlArr){
			if ($spItem.EKMD.toUpper().Trim() -eq $sqlItm.EKMD.toUpper().Trim()){
				$dln = $($spItem.deadline).Year.ToString()+"-"+$($spItem.deadline).Month.ToString().PadLeft(2,"0")+"-"+$($spItem.deadline).Day.ToString().PadLeft(2,"0")
				$xSqlSt = $sqlTempl -Replace "{DeadLine}",$dln
				$xSqlSt = $xSqlSt -Replace "{ID}",$($sqlItm.ID)
				$sqlString += $xSqlSt
				break
			}
		}
		# write-Host "$($aItem.ID) ; $($aItem.EKMD); $($aItem.DEADLINE)"
	}
	$cmd.commandtext = $sqlString
	$cmd.executenonquery()
	start-sleep 1
	$conn.Close()	
	#write-Host $sqlString
}

