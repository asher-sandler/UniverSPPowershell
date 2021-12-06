function log($message, $filename){
	write-host $message -f Cyan
}
white
$myHelp=@"
Runs updating queries on SQL database (grs_users).
Then populates panding_actions table.

------------------- Sergey Rubin Dec 2020 -------------------
"@

#region variables and constants Block 
$asherTest=$true

$timeStampform = "dd-MMM-yyyy@HH-mm-ss"

$noerrors = $true # flag for good running
$timeStamp = Get-Date -format $timeStampform # for files
If ($args[0] -eq "?") {yellow;$myhelp;white;exit}

$sourceFilePath = "\\ekekfls00\data$\ftpRoot\ibts" # the ftp puts the original file here
$sourceFileName = "MOSMAH_EKMD_2022.DAT"                       # the TEST for dev  file's name
$inputFilePath = "\\ekekfls00\data$\scriptFolders\DATA\"
$logFilePath = "\\ekekfls00\data$\scriptFolders\LOGS\"
$ConnString ="Data Source=EKEKSQL00;Initial Catalog=GRS_users;Integrated"


if ($asherTest){

	$sourceFilePath = "C:\MOSS_Batches" # the ftp puts the original file here
	$inputFilePath = "C:\MOSS_Batches\DATA"
	$logFilePath = "C:\MOSS_Batches\LOGS"
	$ConnString = "Data Source=ekekaiosp05;Initial Catalog=GRS_users;Integrated Security=SSPI;"
	
}



$sourceFile = "$sourceFilePath\$sourceFileName"
$inputFileName= $sourceFileName+"_$timeStamp.txt"        # original file is copied and renamed with timestam
$inputFile = "$inputFilePath\$inputFilename"
$logFileName = $sourceFileName+"_flag_$timeStamp.log"        #log file per each run using same time stamp
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

#endregion variables

		#Inserting new records
	try
	{
		$conn = New-Object System.Data.SqlClient.SqlConnection
		$conn.ConnectionString = $ConnString
		$conn.Open()
		$cmd = New-Object System.Data.SqlClient.SqlCommand
		$cmd.connection = $conn
$cmd.commandtext=@"
INSERT INTO [dbo].[production_users_1] SELECT * FROM [dbo].[temp_users_1]
WHERE f_appended = 1
"@
		$cmd.executenonquery()
		start-sleep 1
		$conn.Close()
		g; log "New records appended successfully" $logFileName;w
	}
	catch
	{
		$err=$Error[0].exception.message
		$conn.close()
		red;log " FAILED to insert new records into users table `n $err " $logFileName;w
		$noerrors = $false
		return $noerrors; exit
	}

			#Inserting action items for new records into pending_actions table.
	try
	{
		$conn = New-Object System.Data.SqlClient.SqlConnection
		$conn.ConnectionString = $ConnString
		$conn.Open()
		$cmd = New-Object System.Data.SqlClient.SqlCommand
		$cmd.connection = $conn
$cmd.commandtext=@"
INSERT INTO [dbo].[production_Pending_Actions_1] 
SELECT [ZEHUT], '1' as ACTION_TYPE_ID,Null as ACTION_RESULT_ID, Null as f_performed, Null as f_performed_date FROM [dbo].[temp_users_1]
WHERE f_appended = 1;
"@
		$cmd.executenonquery()
		start-sleep 1
		$conn.Close()
		g; log "Action items for new records appended successfully" $logFileName;w
	}
	catch
	{
		$err=$Error[0].exception.message
		$conn.close()
		red;log " FAILED to append action items for new records `n $err " $logFileName;w
		$noerrors = $false
		return $noerrors; exit
	}

		#Performing personal data update
	try
	{
		$conn = New-Object System.Data.SqlClient.SqlConnection
		$conn.ConnectionString = $ConnString
		$conn.Open()
		$cmd = New-Object System.Data.SqlClient.SqlCommand
		$cmd.connection = $conn
$cmd.commandtext=@"
UPDATE [dbo].[production_users_1] 
SET 
[f_updated] = 1, 
[f_updated_date] = GETDATE(),
[ZEHUT_KODEMET]= t.[ZEHUT_KODEMET], 
[SUG_ZEHUT]= t.[SUG_ZEHUT] , 
[FAMILY]= t.[FAMILY] , 
[NAME]= t.[NAME], 
[ADDRESS]= t.[ADDRESS], 
[MIKUD]= t.[MIKUD], 
[E_MAIL]= t.[E_MAIL], 
[YSHUV]= t.[YSHUV], 
[TELEPHON]= t.[TELEPHON], 
[KIDOMET]= t.[KIDOMET], 
[TELEPHON_SELUL]= t.[TELEPHON_SELUL], 
[KIDOMET_SELUL]= t.[KIDOMET_SELUL], 
[RISHUM]= t.[RISHUM], 
[CHATIMA]= t.[CHATIMA], 
[SHANA]= t.[SHANA], 
[SEMESTER]= t.[SEMESTER], 
[DATE_RISHUM]= t.[DATE_RISHUM], 
[HUG_TOAR1]= t.[HUG_TOAR1], 
[MEMUZA1]= t.[MEMUZA1], 
[HUG_TOAR2]= t.[HUG_TOAR2], 
[MEMUZA2]= t.[MEMUZA2], 
[MEM_TOAR]= t.[MEM_TOAR], 
[HUG_LIMUD1]= t.[HUG_LIMUD1], 
[MEMUZA_HUG1]= t.[MEMUZA_HUG1], 
[HUG_LIMUD2]= t.[HUG_LIMUD2], 
[MEMUZA_HUG2]= t.[MEMUZA_HUG2], 
[MOSAD]= t.[MOSAD], 
[FACULTA]= t.[FACULTA], 
[RAMAT_IVRIT]= t.[RAMAT_IVRIT], 
[RAMAT_ANGLIT]= t.[RAMAT_ANGLIT], 
[OLD_E_MAIL]= t.[OLD_E_MAIL], 
[L_FAMILY]= t.[L_FAMILY], 
[LNAME]= t.[LNAME], 
[VATIK]= t.[VATIK]
FROM [dbo].[temp_users_1] t INNER JOIN [dbo].[production_users_1] p ON t.ZEHUT = p.ZEHUT
WHERE t.[f_updated] = 1
;
"@
		$cmd.executenonquery()
		start-sleep 1
		$conn.Close()
		g; log "personal data update records successfully modified in users table" $logFileName;w
	}
	catch
	{
		$err=$Error[0].exception.message
		$conn.close()
		red;log " FAILED to modify personal data update records in users table `n $err " $logFileName;w
		$noerrors = $false
		return $noerrors; exit
	}

			#Inserting action items for personal data update records into pending_actions table.
	try
	{
		$conn = New-Object System.Data.SqlClient.SqlConnection
		$conn.ConnectionString = $ConnString
		$conn.Open()
		$cmd = New-Object System.Data.SqlClient.SqlCommand
		$cmd.connection = $conn
$cmd.commandtext=@"
INSERT INTO [dbo].[production_Pending_Actions_1] 
SELECT [ZEHUT], '3' as ACTION_TYPE_ID,Null as ACTION_RESULT_ID, Null as f_performed, Null as f_performed_date FROM [dbo].[temp_users_1]
WHERE [f_updated] = 1;
"@
		$cmd.executenonquery()
		start-sleep 1
		$conn.Close()
		g; log "Action items for personal data update records appended successfully" $logFileName;w
	}
	catch
	{
		$err=$Error[0].exception.message
		$conn.close()
		red;log " FAILED to append action items for personal data update records `n $err " $logFileName;w
		$noerrors = $false
		return $noerrors; exit
	}

		#Performing registration data update
	try
	{
		$conn = New-Object System.Data.SqlClient.SqlConnection
		$conn.ConnectionString = $ConnString
		$conn.Open()
		$cmd = New-Object System.Data.SqlClient.SqlCommand
		$cmd.connection = $conn
$cmd.commandtext=@"
UPDATE [dbo].[production_users_1] 
SET 
[f_regchange] = 1, 
[f_regchange_date] = GETDATE(),
[A1_MIS_BAKASHA] = t.[A1_MIS_BAKASHA], 
[A1_HUG_MEVUKASH] = t.[A1_HUG_MEVUKASH], 
[A1_RAMA] = t.[A1_RAMA], 
[A1_B_DATE] = t.[A1_B_DATE], 
[A1_B_BAKASHA] = t.[A1_B_BAKASHA], 
[A2_MIS_BAKASHA] = t.[A2_MIS_BAKASHA], 
[A2_HUG_MEVUKASH] = t.[A2_HUG_MEVUKASH], 
[A2_RAMA] = t.[A2_RAMA], 
[A2_B_DATE] = t.[A2_B_DATE], 
[A2_B_BAKASHA] = t.[A2_B_BAKASHA], 
[A3_MIS_BAKASHA] = t.[A3_MIS_BAKASHA], 
[A3_HUG_MEVUKASH] = t.[A3_HUG_MEVUKASH], 
[A3_RAMA] = t.[A3_RAMA], 
[A3_B_DATE] = t.[A3_B_DATE], 
[A3_B_BAKASHA] = t.[A3_B_BAKASHA], 
[A4_MIS_BAKASHA] = t.[A4_MIS_BAKASHA], 
[A4_HUG_MEVUKASH] = t.[A4_HUG_MEVUKASH], 
[A4_RAMA] = t.[A4_RAMA], 
[A4_B_DATE] = t.[A4_B_DATE], 
[A4_B_BAKASHA] = t.[A4_B_BAKASHA], 
[A5_MIS_BAKASHA] = t.[A5_MIS_BAKASHA], 
[A5_HUG_MEVUKASH] = t.[A5_HUG_MEVUKASH], 
[A5_RAMA] = t.[A5_RAMA], 
[A5_B_DATE] = t.[A5_B_DATE], 
[A5_B_BAKASHA] = t.[A5_B_BAKASHA]
FROM [dbo].[temp_users_1] t INNER JOIN [dbo].[production_users_1] p ON t.ZEHUT = p.ZEHUT
WHERE 
t.[f_regchange] = 1
;
"@
		$cmd.executenonquery()
		start-sleep 1
		$conn.Close()
		g; log "Registration data update records successfully modified in users table" $logFileName;w
	}
	catch
	{
		$err=$Error[0].exception.message
		$conn.close()
		red;log " FAILED to modify registration data update records in users table `n $err " $logFileName;w
		$noerrors = $false
		return $noerrors; exit
	}

			#Inserting action items for registration data update records into pending_actions table.
	# Has to be changed. I have to add parameter column into action table.
	# Have to determine which registration has to be cancelled
	# and which registration has to be added !!!!!
	# all this before I do update production users table (previous step)
	
	try
	{
		$conn = New-Object System.Data.SqlClient.SqlConnection
		$conn.ConnectionString = $ConnString
		$conn.Open()
		$cmd = New-Object System.Data.SqlClient.SqlCommand
		$cmd.connection = $conn
$cmd.commandtext=@"
INSERT INTO [dbo].[production_Pending_Actions_1] 
SELECT [ZEHUT], '4' as ACTION_TYPE_ID,Null as ACTION_RESULT_ID, Null as f_performed, Null as f_performed_date FROM [dbo].[temp_users_1]
WHERE [f_regchange] = 1;
"@
		$cmd.executenonquery()
		start-sleep 1
		$conn.Close()
		g; log "Action items for registration data update records appended successfully" $logFileName;w
	}
	catch
	{
		$err=$Error[0].exception.message
		$conn.close()
		red;log " FAILED to append action items for registration data update records `n $err " $logFileName;w
		$noerrors = $false
		return $noerrors; exit
	}

g; log "Database updating phase is finished" $logFileName;w
return $noerrors; exit
