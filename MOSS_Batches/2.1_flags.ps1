function log($message, $filename){
	write-host $message -f Cyan
}
white
$myHelp=@"
Runs flagging queries on SQL database (grs_users).

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

log " Script is starting " $logFileName
		#Flagging new records
	try
	{
		$conn = New-Object System.Data.SqlClient.SqlConnection
		$conn.ConnectionString = $ConnString
		$conn.Open()
		$cmd = New-Object System.Data.SqlClient.SqlCommand
		$cmd.connection = $conn
		
$cmd.commandtext=@"
UPDATE [dbo].[temp_users_1]
SET f_appended = 1, f_appended_date = GETDATE()
WHERE [ZEHUT] NOT IN (SELECT t.ZEHUT FROM [dbo].[temp_users_1] t INNER JOIN [dbo].[production_users_1] p ON t.ZEHUT = p.ZEHUT);
"@
		$cmd.executenonquery()
		start-sleep 1
		$conn.close()
		g; log "Flagged new records successfully" $logFileName;w
}
	catch
	{
		$err=$Error[0].exception.message
		red;log " FAILED to flag new records  in the input table `n $err " $logFileName;w
		$conn.close()
		$noerrors = $false
		return $noerrors; exit
	}

		#Flagging cancelled records
	try
	{
		$conn = New-Object System.Data.SqlClient.SqlConnection
		$conn.ConnectionString = $ConnString
		$conn.Open()
		$cmd = New-Object System.Data.SqlClient.SqlCommand
		$cmd.connection = $conn
$cmd.commandtext=@"
UPDATE [dbo].[production_users_1]
SET f_cancelled = 1, f_cancelled_date = GETDATE()
WHERE ([f_cancelled] IS NULL Or [f_cancelled] = 0 ) AND [ZEHUT] NOT IN (SELECT p.ZEHUT FROM [dbo].[production_users_1] p INNER JOIN [dbo].[temp_users_1] t ON p.ZEHUT = t.ZEHUT);
"@
		$cmd.executenonquery()
		start-sleep 1
		$conn.close()
		g; log "Flagged cancelled records successfully" $logFileName;w
}
	catch
	{
		$err=$Error[0].exception.message
		red;log " FAILED to flag cancelled records  in the users table `n $err " $logFileName;w
		$conn.close()
		$noerrors = $false
		return $noerrors; exit
	}

			#Inserting action items for cancelled records into pending_actions table.
	try
	{
		$conn = New-Object System.Data.SqlClient.SqlConnection
		$conn.ConnectionString = $ConnString
		$conn.Open()
		$cmd = New-Object System.Data.SqlClient.SqlCommand
		$cmd.connection = $conn
$cmd.commandtext=@"
INSERT INTO [dbo].[production_Pending_Actions_1] 
SELECT [ZEHUT], '2' as ACTION_TYPE_ID,Null as ACTION_RESULT_ID, Null as f_performed, Null as f_performed_date  FROM [dbo].[production_users_1] 
WHERE ZEHUT NOT IN (SELECT p.ZEHUT FROM [dbo].[production_users_1] p INNER JOIN [dbo].[temp_users_1] t ON p.ZEHUT = t.ZEHUT);
"@
		$cmd.executenonquery()
		start-sleep 1
		$conn.Close()
		g; log "Action items for cancelled records appended successfully" $logFileName;w
	}
	catch
	{
		$err=$Error[0].exception.message
		$conn.close()
		red;log " FAILED to append action items for cancelled records `n $err " $logFileName;w
		$noerrors = $false
		return $noerrors; exit
	}

		#Flagging records of personal data update

	try
	{
		$conn = New-Object System.Data.SqlClient.SqlConnection
		$conn.ConnectionString = $ConnString
		$conn.Open()
		$cmd = New-Object System.Data.SqlClient.SqlCommand
		$cmd.connection = $conn
$cmd.commandtext=@"
UPDATE [dbo].[temp_users_1]  
SET [f_updated] = 1, [f_updated_date] = GETDATE()
FROM [dbo].[temp_users_1] t INNER JOIN [dbo].[production_users_1] p ON t.ZEHUT = p.ZEHUT
WHERE 
t.[ZEHUT_KODEMET] <> p.[ZEHUT_KODEMET] OR 
t.[SUG_ZEHUT]  <> p.[SUG_ZEHUT]  OR 
t.[FAMILY]  <> p.[FAMILY]  OR 
t.[NAME] <> p.[NAME] OR 
t.[ADDRESS] <> p.[ADDRESS] OR 
t.[MIKUD] <> p.[MIKUD] OR 
t.[E_MAIL] <> p.[E_MAIL] OR 
t.[YSHUV] <> p.[YSHUV] OR 
t.[TELEPHON] <> p.[TELEPHON] OR 
t.[KIDOMET] <> p.[KIDOMET] OR 
t.[TELEPHON_SELUL] <> p.[TELEPHON_SELUL] OR 
t.[KIDOMET_SELUL] <> p.[KIDOMET_SELUL] OR 
t.[RISHUM] <> p.[RISHUM] OR 
t.[CHATIMA] <> p.[CHATIMA] OR 
t.[SHANA] <> p.[SHANA] OR 
t.[SEMESTER] <> p.[SEMESTER] OR 
t.[DATE_RISHUM] <> p.[DATE_RISHUM] OR 
t.[HUG_TOAR1] <> p.[HUG_TOAR1] OR 
t.[MEMUZA1] <> p.[MEMUZA1] OR 
t.[HUG_TOAR2] <> p.[HUG_TOAR2] OR 
t.[MEMUZA2] <> p.[MEMUZA2] OR 
t.[MEM_TOAR] <> p.[MEM_TOAR] OR 
t.[HUG_LIMUD1] <> p.[HUG_LIMUD1] OR 
t.[MEMUZA_HUG1] <> p.[MEMUZA_HUG1] OR 
t.[HUG_LIMUD2] <> p.[HUG_LIMUD2] OR 
t.[MEMUZA_HUG2] <> p.[MEMUZA_HUG2] OR 
t.[MOSAD] <> p.[MOSAD] OR 
t.[FACULTA] <> p.[FACULTA] OR 
t.[RAMAT_IVRIT] <> p.[RAMAT_IVRIT] OR 
t.[RAMAT_ANGLIT] <> p.[RAMAT_ANGLIT] OR 
t.[OLD_E_MAIL] <> p.[OLD_E_MAIL] OR 
t.[L_FAMILY] <> p.[L_FAMILY] OR 
t.[LNAME] <> p.[LNAME] OR 
t.[VATIK] <> p.[VATIK]
;
"@
		$cmd.executenonquery()
		start-sleep 1
		$conn.close()
		g; log "Flagged personal data update records successfully" $logFileName;w
}
	catch
	{
		$err=$Error[0].exception.message
		red;log " FAILED to flag personal data update records in the input table `n $err " $logFileName;w
		$conn.close()
		$noerrors = $false
		return $noerrors; exit
	}

		#Flagging records of registration data update
	try
	{
		$conn = New-Object System.Data.SqlClient.SqlConnection
		$conn.ConnectionString = $ConnString
		$conn.Open()
		$cmd = New-Object System.Data.SqlClient.SqlCommand
		$cmd.connection = $conn
$cmd.commandtext=@"
UPDATE [dbo].[temp_users_1] 
SET [f_regchange] = 1, [f_regchange_date] = GETDATE()
FROM [dbo].[temp_users_1] t INNER JOIN [dbo].[production_users_1] p ON t.ZEHUT = p.ZEHUT
WHERE 
t.[A1_MIS_BAKASHA] <> p.[A1_MIS_BAKASHA] OR 
t.[A1_HUG_MEVUKASH] <> p.[A1_HUG_MEVUKASH] OR 
t.[A2_MIS_BAKASHA] <> p.[A2_MIS_BAKASHA] OR 
t.[A2_HUG_MEVUKASH] <> p.[A2_HUG_MEVUKASH] OR 
t.[A3_MIS_BAKASHA] <> p.[A3_MIS_BAKASHA] OR 
t.[A3_HUG_MEVUKASH] <> p.[A3_HUG_MEVUKASH] OR 
t.[A4_MIS_BAKASHA] <> p.[A4_MIS_BAKASHA] OR 
t.[A4_HUG_MEVUKASH] <> p.[A4_HUG_MEVUKASH] OR 
t.[A5_MIS_BAKASHA] <> p.[A5_MIS_BAKASHA] OR 
t.[A5_HUG_MEVUKASH] <> p.[A5_HUG_MEVUKASH] OR
t.[A1_RAMA] <> p.[A1_RAMA] OR 
t.[A2_RAMA] <> p.[A2_RAMA] OR 
t.[A3_RAMA] <> p.[A3_RAMA] OR 
t.[A4_RAMA] <> p.[A4_RAMA] OR 
t.[A5_RAMA] <> p.[A5_RAMA]
;
"@
		$cmd.executenonquery()
		start-sleep 1
		$conn.close()
		g; log "Flagged registration data update records successfully" $logFileName;w
}
	catch
	{
		$err=$Error[0].exception.message
		red;log " FAILED to flag registration data update records in the input table `n $err " $logFileName;w
		$conn.close()
		$noerrors = $false
		return $noerrors; exit
	}

return $noerrors; exit