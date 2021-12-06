white
$myHelp=@"
Runs the sequense of ps scripts 
ps_grs_importsx00.ps1 - Reads input file of Gradual students and insert records into SQL database.
ps_grs_sql_flags00.ps1 - Analizes input changes and set flags in the input table.
ps_grs_sql_updates00.ps1 - Update changes to production table.
ps_grs_sql_actionitems00.ps1 - reading the actions table and performing them.

 1) ftp source file is \\ekekfls00\data$\ftpRoot\ibts\MOSMAH_EKMD_2022.DAT
 2) it is copied to    \\ekekfls00\data$\scriptFolders\DATA\MOSMAH_EKMD_2022.DAT_timeStamp.txt

------------------- Sergey Rubin Dec 2020 -------------------
"@

#region variables and constants Block 
$timeStamp = Get-Date -format $timeStampform # for files
If ($args[0] -eq "?") {yellow;$myhelp;white;exit}
$logFilePath = "\\ekekfls00\data$\scriptFolders\LOGS\"
$logFileName = "ps_grs_main" + "_$timeStamp.log"        #log file per each run using same time stamp
$logFile = "$logFilePath\$logFileName"
$today = Get-Date

#endregion variables
cd "c:\Moss_Batches"

logts "Start processing input file" $logFileName
$inputfiledone = $false; $inputfiledone = ps_grs_importsx00 # invoking input file processing script
if($inputfiledone -eq $false)
{
	logts "Failure processing input file. Check its log." $logFileName; exit
}
else
{
	logts "Input file imported successfully." $logFileName
	logts "Flagging script is starting." $logFileName
	$flagsdone = $false; $flagsdone = ps_grs_sql_flags00 #invoking flagging script
	if($flagsdone -eq $false)
	{
		logts "Failure processing Flagging script. Check its log." $logFileName; exit
	}
	else
	{
		logts "Flagging script finished successfully." $logFileName
		logts "Updating script is starting." $logFileName
		$updatesdone = $false; $updatesdone = ps_grs_sql_updates00 #invoking Updating script
		if($updatesdone -eq $false)
		{
			logts "Failure processing Updating script. Check its log." $logFileName; exit
		}
		else
		{
			logts "Updating script finished successfully." $logFileName
			#logts "ActionItems script is starting." $logFileName
			#$actionsdone = $false; $actionsdone = ps_grs_sql_actionitems00 #invoking ActionItems script
			if($actionsdone -eq $false)
			{
				logts "Failure processing ActionItems script. Check its log." $logFileName; exit
			}
			else {logts "ActionItems script finished successfully. Everything is done." $logFileName; exit} #end if($actionsdone -eq $false)
		} #end if($updatesdone -eq $false)
	} #end if($flagsdone -eq $false)
} #end if($inputfiledone -eq $false)
exit

