#cd c:\Windows
function log($message, $filename){
	write-host $message -f Cyan
}
white
$myHelp=@"
Reads input file of Gradual students and insert records into SQL database.

 1) ftp source file is \\ekekfls00\data$\ftpRoot\ibts\MOSMAH_EKMD_2022.DAT
 2) it is copied to    \\ekekfls00\data$\scriptFolders\DATA\MOSMAH_EKMD_2022.DAT_timeStamp.txt
 3) MOSMAH_EKMD_2021.DAT_timeStamp.txt is the input file for this script

Example input line:
------------------- Sergey Rubin Dec 2020 -------------------
"@

$asherTest=$true

$timeStampform = "dd-MMM-yyyy@HH-mm-ss"
$checkccusername = $true # flag for CC username lookup
$noerrors = $true # flag for good running
$emptyinputtable = $true # flag to delete records from input table
$inputArray=@()
$timeStamp = Get-Date -format $timeStampform # for files
If ($args[0] -eq "?") {yellow;$myhelp;white;exit}
$sourceFilePath = "\\ekekfls00\data$\ftpRoot\ibts" # the ftp puts the original file here
$sourceFileName = "MOSMAH_EKMD_2022.DAT"                       # the TEST for dev  file's name
$inputFilePath = "\\ekekfls00\data$\scriptFolders\DATA\"
$logFilePath = "\\ekekfls00\data$\scriptFolders\LOGS\"
$titleFileName = "MOSMAH_EKMD_2021_title.txt"
$today = Get-Date
$mossserver = "ekekspapp10"
$ConnString ="Data Source=EKEKSQL00;Initial Catalog=GRS_users;Integrated"



if ($asherTest){

	$sourceFilePath = "C:\MOSS_Batches" # the ftp puts the original file here
	$inputFilePath = "C:\MOSS_Batches\DATA"
	$logFilePath = "C:\MOSS_Batches\LOGS"
	$ConnString = "Data Source=ekekaiosp05;Initial Catalog=GRS_users;Integrated Security=SSPI;"
	
}

$sourceFile = "$sourceFilePath\$sourceFileName"
$inputFileName= $sourceFileName+"_$timeStamp.txt"        # original file is copied and renamed
$logFileName = $sourceFileName+"_$timeStamp.log"        #log file per each run using same time stamp
$logFile = "$logFilePath\$logFileName"
$inputFile = "$inputFilePath\$inputFilename"
$titleFile = "$inputFilePath\$titleFileName"

$timeCSV = Get-Date -format "yyyy-MM-dd@HH-mm-ss"
$outCSV = "$inputFilePath\$timeCSV.csv"



#endregion variables

#region FUNCTIONS
################ START Functions Block ##################################
################ END Functions Block ##################################
#endregion FUNCTIONS
################  START MAIN Block   ##################################

#region READING INPUT FILE
if ((Test-Path $sourceFile) -eq $false) {y;"No input file $sourceFile";w;exit} # testing if file exists
$script=$MyInvocation.InvocationName
write-host "SEMESTER:  2"           #$logFileName
write-host "Start time:  <$now>"           #$logFileName
write-host "User:        <$whoami>"        #$logFileName
write-host "Running ON:  <$ENV:Computername>" #$logFileName
write-host "Script file: <$script>"        #$logFileName
write-host "sourceFile:  <$sourceFile>"    #$logfileName
write-host "inputFile:   <$inputFile>"     #$logfileName
write-host "Out CSV:     <$outCSV>"        #$logfileName
write-host "----------------------------"  #$logFileName

# copying the source file to working (transient) file
try
{
 Copy-Item  $sourceFile $inputFile -ea stop
 g;log "Success copy of sourceFile to inputFile" $logFileName
 } 
catch
{
 $err=$error[0] | Out-string
 red; log " (184) Failed Copy sourceFile --> inputFile -  Aborting" $logFileName ; w
 Send-MailMessage -To "ashersa@ekmd.huji.ac.il" -From $donotreply -Subject "Failed Copy sourceFile --> inputFile -  Aborting" -body $err -smtpserver "ekekcas01" 
 break
 exit
}

#converting input file to Unicode
$myf = Get-Content -Path $titleFile, $sourceFile 
$myf | Set-Content -Path $inputFile -Encoding Unicode

#reading input file
$inputArray = Import-CSV $inputFile -Delimiter "&"
$inputArray | Export-CSV $outCSV -NoTypeInfo -Encoding UTF8
$linesCount=$inputArray.Count
log "<$linesCount> Lines in Input File" $logFileName
if ($asherTest){
	write-host "Press key..."
	read-host
}
#$inputArray[0] |fl

#endregion READING INPUT FILE

#region empty the input table
if($emptyinputtable)
{
	try
	{
		#creating connection to SQL database
		$conn = New-Object System.Data.SqlClient.SqlConnection
		$conn.ConnectionString = $ConnString
		$conn.Open()
		
		#Deleting all records
		$cmd = New-Object System.Data.SqlClient.SqlCommand
		$cmd.connection = $conn
		$cmd.commandtext="DELETE from [dbo].[temp_users_2]"
		$cmd.executenonquery()
		g; log "Deleting all records" $logFileName;w
		start-sleep 2
		$conn.Close()
	}
	catch
	{
	$err=$Error[0].exception.message
	red;log " FAILED to empty the input table in the Database `n $err " $logFileName;w
	$conn.close()
	}
}

#endregion empty the input table
#############################################################
##### main loop processing line by line
$cntLines=0
#y;$inputarray.count;w
foreach ($line in $inputArray)
{ 
	#$mycolumns = $inputarray |gm -membertype NoteProperty | select -expand Name
	#$line=$inputArray[0]
	#READING LINE DATA
	$cntLines++; 
	#log "LINE($cntLines): <$line>`n" $logFileName
	
		#[ZEHUT] [nvarchar](50) NOT NULL,
		[string]$tmp=$line.ZEHUT
		if(!$tmp -or $tmp -eq "")
		{log "ZEHUT is missing. Skipping the line" $logFileName;continue }
		else
		{
			$tmp=$tmp.Trim()
			$userUniqueID = ""; $vZEHUT = "";$userUniqueID8 = ""; 
			if ($tmp.length -gt 16) {[string]$vZEHUT=$tmp.Substring(0,16)} else {[string]$vZEHUT=$tmp} # read 1st 16 chars only
			$userUniqueID = $vZEHUT.replace("-","");$userUniqueID8 = $userUniqueID.Substring(0,8)
		}
		#[ZEHUT_KODEMET] [nvarchar](50) NOT NULL,
		[string]$vZEHUT_KODEMET = ""; [string]$vZEHUT_KODEMET =$line.ZEHUT_KODEMET
		if($vZEHUT_KODEMET -ne $null){$vZEHUT_KODEMET = $vZEHUT_KODEMET.trim()}
		#[SUG_ZEHUT] [nchar](10) NULL,
		[string]$vSUG_ZEHUT = ""; [string]$vSUG_ZEHUT =$line.SUG_ZEHUT
		if($vSUG_ZEHUT -ne $null){$vSUG_ZEHUT = $vSUG_ZEHUT.trim()}
		#[FAMILY] [nvarchar](50) NULL,
		[string]$str = "";[string]$str = $line.FAMILY
		if(!$str -or $str -eq "")
		{log "HEB_FAMILY is missing. Continue" $logFileName}
		else
		{
			$vFAMILY = ""; $vFAMILY = ([regex]::Matches($str,'.','RightToLeft') | ForEach {$_.value}) -join ''
			$vFAMILY = $vFAMILY.trim()
			$vFAMILY = ((((($vFAMILY.replace("'","")).replace(".","")).replace("-","")).replace(",","")).replace("?","")).replace(" ","-")
		}
		#[NAME] [nvarchar](50) NULL,
		[string]$str = "";[string]$str = $line.NAME
		if(!$str -or $str -eq "")
		{log "HEB_NAME is missing. Continue" $logFileName}
		else
		{
			$vNAME = ""; $vNAME = ([regex]::Matches($str,'.','RightToLeft') | ForEach {$_.value}) -join ''
			$vNAME = $vNAME.trim()
			$vNAME = (((((($vNAME.replace("'","")).replace(" ","")).replace("  ","")).replace(".","")).replace("-","")).replace(",","")).replace("?","")
		}
		#[ADDRESS] [nvarchar](100) NULL,
		[string]$str = "";[string]$str = $line.ADDRESS
		if(!$str -or $str -eq "")
		{$vADDRESS = ""}
		else
		{
			$vADDRESS = ""; $vADDRESS = ([regex]::Matches($str,'.','RightToLeft') | ForEach {$_.value}) -join ''
			$vADDRESS = $vADDRESS.trim()
			$vADDRESS = ($vADDRESS.replace("'","")).replace("?","")
		}
		#[MIKUD] [nvarchar](50) NULL,
		[string]$vMIKUD = ""; [string]$vMIKUD =$line.MIKUD
		if($vMIKUD -ne $null){$vMIKUD = $vMIKUD.trim()}
		#[E_MAIL] [nvarchar](100) NULL,
		[string]$vE_MAIL = ""; [string]$vE_MAIL =$line.E_MAIL
		if(!$vE_MAIL -or $vE_MAIL -eq ""){log "E_MAIL is missing. Skipping the line" $logFileName;continue } else {$vE_MAIL=$vE_MAIL.Trim()}
		#[YSHUV] [nvarchar](50) NULL,
		[string]$vYSHUV = ""; [string]$vYSHUV =$line.YSHUV
		if($vYSHUV -ne $null){$vYSHUV = $vYSHUV.trim()}
		#[TELEPHON] [nvarchar](50) NULL,
		[string]$vTELEPHON = ""; [string]$vTELEPHON =$line.TELEPHON
		if($vTELEPHON -ne $null){$vTELEPHON = $vTELEPHON.trim()}
		#[KIDOMET] [nvarchar](50) NULL,
		[string]$vKIDOMET = ""; [string]$vKIDOMET =$line.KIDOMET
		if($vKIDOMET -ne $null){$vKIDOMET = $vKIDOMET.trim()}
		#[TELEPHON_SELUL] [nvarchar](50) NULL,
		[string]$vTELEPHON_SELUL = ""; [string]$vTELEPHON_SELUL =$line.TELEPHON_SELUL
		if($vTELEPHON_SELUL -ne $null){$vTELEPHON_SELUL = $vTELEPHON_SELUL.trim()}
		#[KIDOMET_SELUL] [nvarchar](50) NULL,
		[string]$vKIDOMET_SELUL = ""; [string]$vKIDOMET_SELUL =$line.KIDOMET_SELUL
		if($vKIDOMET_SELUL -ne $null){$vKIDOMET_SELUL = $vKIDOMET_SELUL.trim()}
		#[RISHUM] [nchar](10) NULL,
		[string]$vRISHUM = ""; [string]$vRISHUM =$line.RISHUM
		if($vRISHUM -ne $null){$vRISHUM = $vRISHUM.trim()}
		#[CHATIMA] [nchar](10) NULL, - not present in the input file
		#[SHANA] [nchar](10) NULL,
		[string]$vSHANA = ""; [string]$vSHANA =$line.SHANA
		if($vSHANA -ne $null){$vSHANA = $vSHANA.trim()}
		#[SEMESTER] [nchar](10) NULL,
		[string]$vSEMESTER = ""; [string]$vSEMESTER =$line.SEMESTER
		if($vSEMESTER -ne $null){$vSEMESTER = $vSEMESTER.trim()}

		# Skipping wrong SEMESTER lines !!!!!
		# Check For SEMESTER
		if($vSEMESTER -ne '2'){
			#log ". SEMESTER is not 2. ($vSEMESTER) Skipping the line" $logFileName;
			continue 
		}

		#[DATE_RISHUM] [datetime] NULL, - ddouble check - working with datetime data type in sql
		[string]$str = ""; [string]$str =$line.DATE_RISHUM
		if(!$str -or $str -eq "" -or $str -eq "00000000"){$vDATE_RISHUM = ""} else {$str = $str.trim(); $vDATE_RISHUM = ""; $vDATE_RISHUM = [datetime]::parseexact($str, 'ddMMyyyy', $null).ToString('yyyyMMdd')}
		#$vDATE_RISHUM
		#[HUG_TOAR1] [nchar](10) NULL,
		[string]$vHUG_TOAR1 = ""; [string]$vHUG_TOAR1 =$line.HUG_TOAR1
		if($vHUG_TOAR1 -ne $null){$vHUG_TOAR1 = $vHUG_TOAR1.trim()}
		#[MEMUZA1] [nchar](10) NULL,
		[string]$vMEMUZA1 = ""; [string]$vMEMUZA1 =$line.MEMUZA1
		if($vMEMUZA1 -ne $null){$vMEMUZA1 = $vMEMUZA1.trim()}
		#[HUG_TOAR2] [nchar](10) NULL,
		[string]$vHUG_TOAR2 = ""; [string]$vHUG_TOAR2 =$line.HUG_TOAR2
		if($vHUG_TOAR2 -ne $null){$vHUG_TOAR2 = $vHUG_TOAR2.trim()}
		#[MEMUZA2] [nchar](10) NULL,
		[string]$vMEMUZA2 = ""; [string]$vMEMUZA2 =$line.MEMUZA2
		if($vMEMUZA2 -ne $null){$vMEMUZA2 = $vMEMUZA2.trim()}
		#[MEM_TOAR] [nchar](10) NULL,
		[string]$vMEM_TOAR = ""; [string]$vMEM_TOAR =$line.MEM_TOAR
		if($vMEM_TOAR -ne $null){$vMEM_TOAR = $vMEM_TOAR.trim()}
		#[HUG_LIMUD1] [nchar](10) NULL,
		[string]$vHUG_LIMUD1 = ""; [string]$vHUG_LIMUD1 =$line.HUG_LIMUD1
		if($vHUG_LIMUD1 -ne $null){$vHUG_LIMUD1 = $vHUG_LIMUD1.trim()}
		#[MEMUZA_HUG1] [nchar](10) NULL,
		[string]$vMEMUZA_HUG1 = ""; [string]$vMEMUZA_HUG1 =$line.MEMUZA_HUG1
		if($vMEMUZA_HUG1 -ne $null){$vMEMUZA_HUG1 = $vMEMUZA_HUG1.trim()}
		#[HUG_LIMUD2] [nchar](10) NULL,
		[string]$vHUG_LIMUD2 = ""; [string]$vHUG_LIMUD2 =$line.HUG_LIMUD2
		if($vHUG_LIMUD2 -ne $null){$vHUG_LIMUD2 = $vHUG_LIMUD2.trim()}
		#[MEMUZA_HUG2] [nchar](10) NULL,
		[string]$vMEMUZA_HUG2 = ""; [string]$vMEMUZA_HUG2 =$line.MEMUZA_HUG2
		if($vMEMUZA_HUG2 -ne $null){$vMEMUZA_HUG2 = $vMEMUZA_HUG2.trim()}
		#[MOSAD] [nchar](10) NULL,
		[string]$vMOSAD = ""; [string]$vMOSAD =$line.MOSAD
		if($vMOSAD -ne $null){$vMOSAD = $vMOSAD.trim()}
		#[FACULTA] [nchar](10) NULL,
		[string]$vFACULTA = ""; [string]$vFACULTA =$line.FACULTA
		if($vFACULTA -ne $null){$vFACULTA = $vFACULTA.trim()}
		#[YEAR_LIMUD] [nchar](10) NULL,
		[string]$vYEAR_LIMUD = ""; [string]$vYEAR_LIMUD =$line.YEAR_LIMUD
		if($vYEAR_LIMUD -ne $null){$vYEAR_LIMUD = $vYEAR_LIMUD.trim()}

		#[A1_MIS_BAKASHA] [nchar](10) NULL,
		[string]$vA1_MIS_BAKASHA = ""; [string]$vA1_MIS_BAKASHA =$line.A1_MIS_BAKASHA
		if($vA1_MIS_BAKASHA -ne $null){$vA1_MIS_BAKASHA = $vA1_MIS_BAKASHA.trim()}
		#[A1_HUG_MEVUKASH] [nchar](10) NULL,
		[string]$vA1_HUG_MEVUKASH = ""; [string]$vA1_HUG_MEVUKASH =$line.A1_HUG_MEVUKASH
		if($vA1_HUG_MEVUKASH -ne $null){$vA1_HUG_MEVUKASH = $vA1_HUG_MEVUKASH.trim()}
		#[A1_RAMA] [nchar](10) NULL,
		[string]$vA1_RAMA = ""; [string]$vA1_RAMA =$line.A1_RAMA
		if($vA1_RAMA -ne $null){$vA1_RAMA = $vA1_RAMA.trim()}
		#[A1_B_DATE] [datetime] NULL,
		[string]$str = ""; [string]$str =$line.A1_B_DATE
		if(!$str -or $str -eq "" -or $str -eq "00000000"){$vA1_B_DATE = ""} else {$str = $str.trim(); $vA1_B_DATE = ""; $vA1_B_DATE = [datetime]::parseexact($str, 'ddMMyyyy', $null).ToString('yyyyMMdd')}
		#[A1_B_BAKASHA] [datetime] NULL,
		[string]$str = ""; [string]$str =$line.A1_B_BAKASHA
		if(!$str -or $str -eq "" -or $str -eq "00000000"){$vA1_B_BAKASHA = ""} else {$str = $str.trim(); $vA1_B_BAKASHA = ""; $vA1_B_BAKASHA = [datetime]::parseexact($str, 'ddMMyyyy', $null).ToString('yyyyMMdd')}

		#[A2_MIS_BAKASHA] [nchar](10) NULL,
		[string]$vA2_MIS_BAKASHA = ""; [string]$vA2_MIS_BAKASHA =$line.A2_MIS_BAKASHA
		if($vA2_MIS_BAKASHA -ne $null){$vA2_MIS_BAKASHA = $vA2_MIS_BAKASHA.trim()}
		#[A2_HUG_MEVUKASH] [nchar](10) NULL,
		[string]$vA2_HUG_MEVUKASH = ""; [string]$vA2_HUG_MEVUKASH =$line.A2_HUG_MEVUKASH
		if($vA2_HUG_MEVUKASH -ne $null){$vA2_HUG_MEVUKASH = $vA2_HUG_MEVUKASH.trim()}
		#[A2_RAMA] [nchar](10) NULL,
		[string]$vA2_RAMA = ""; [string]$vA2_RAMA =$line.A2_RAMA
		if($vA2_RAMA -ne $null){$vA2_RAMA = $vA2_RAMA.trim()}
		#[A2_B_DATE] [datetime] NULL,
		[string]$str = ""; [string]$str =$line.A2_B_DATE
		if(!$str -or $str -eq "" -or $str -eq "00000000"){$vA2_B_DATE = ""} else {$str = $str.trim(); $vA2_B_DATE = ""; $vA2_B_DATE = [datetime]::parseexact($str, 'ddMMyyyy', $null).ToString('yyyyMMdd')}
		#[A2_B_BAKASHA] [datetime] NULL,
		[string]$str = ""; [string]$str =$line.A2_B_BAKASHA
		if(!$str -or $str -eq "" -or $str -eq "00000000"){$vA2_B_BAKASHA = ""} else {$str = $str.trim(); $vA2_B_BAKASHA = ""; $vA2_B_BAKASHA = [datetime]::parseexact($str, 'ddMMyyyy', $null).ToString('yyyyMMdd')}

		#[A3_MIS_BAKASHA] [nchar](10) NULL,
		[string]$vA3_MIS_BAKASHA = ""; [string]$vA3_MIS_BAKASHA =$line.A3_MIS_BAKASHA
		if($vA3_MIS_BAKASHA -ne $null){$vA3_MIS_BAKASHA = $vA3_MIS_BAKASHA.trim()}
		#[A3_HUG_MEVUKASH] [nchar](10) NULL,
		[string]$vA3_HUG_MEVUKASH = ""; [string]$vA3_HUG_MEVUKASH =$line.A3_HUG_MEVUKASH
		if($vA3_HUG_MEVUKASH -ne $null){$vA3_HUG_MEVUKASH = $vA3_HUG_MEVUKASH.trim()}
		#[A3_RAMA] [nchar](10) NULL,
		[string]$vA3_RAMA = ""; [string]$vA3_RAMA =$line.A3_RAMA
		if($vA3_RAMA -ne $null){$vA3_RAMA = $vA3_RAMA.trim()}
		#[A3_B_DATE] [datetime] NULL,
		[string]$str = ""; [string]$str =$line.A3_B_DATE
		if(!$str -or $str -eq "" -or $str -eq "00000000"){$vA3_B_DATE = ""} else {$str = $str.trim(); $vA3_B_DATE = ""; $vA3_B_DATE = [datetime]::parseexact($str, 'ddMMyyyy', $null).ToString('yyyyMMdd')}
		#[A3_B_BAKASHA] [datetime] NULL,
		[string]$str = ""; [string]$str =$line.A3_B_BAKASHA
		if(!$str -or $str -eq "" -or $str -eq "00000000"){$vA3_B_BAKASHA = ""} else {$str = $str.trim(); $vA3_B_BAKASHA = ""; $vA3_B_BAKASHA = [datetime]::parseexact($str, 'ddMMyyyy', $null).ToString('yyyyMMdd')}

		#[A4_MIS_BAKASHA] [nchar](10) NULL,
		[string]$vA4_MIS_BAKASHA = ""; [string]$vA4_MIS_BAKASHA =$line.A4_MIS_BAKASHA
		if($vA4_MIS_BAKASHA -ne $null){$vA4_MIS_BAKASHA = $vA4_MIS_BAKASHA.trim()}
		#[A4_HUG_MEVUKASH] [nchar](10) NULL,
		[string]$vA4_HUG_MEVUKASH = ""; [string]$vA4_HUG_MEVUKASH =$line.A4_HUG_MEVUKASH
		if($vA4_HUG_MEVUKASH -ne $null){$vA4_HUG_MEVUKASH = $vA4_HUG_MEVUKASH.trim()}
		#[A4_RAMA] [nchar](10) NULL,
		[string]$vA4_RAMA = ""; [string]$vA4_RAMA =$line.A4_RAMA
		if($vA4_RAMA -ne $null){$vA4_RAMA = $vA4_RAMA.trim()}
		#[A4_B_DATE] [datetime] NULL,
		[string]$str = ""; [string]$str =$line.A4_B_DATE
		if(!$str -or $str -eq "" -or $str -eq "00000000"){$vA4_B_DATE = ""} else {$str = $str.trim(); $vA4_B_DATE = ""; $vA4_B_DATE = [datetime]::parseexact($str, 'ddMMyyyy', $null).ToString('yyyyMMdd')}
		#[A4_B_BAKASHA] [datetime] NULL,
		[string]$str = ""; [string]$str =$line.A4_B_BAKASHA
		if(!$str -or $str -eq "" -or $str -eq "00000000"){$vA4_B_BAKASHA = ""} else {$str = $str.trim(); $vA4_B_BAKASHA = ""; $vA4_B_BAKASHA = [datetime]::parseexact($str, 'ddMMyyyy', $null).ToString('yyyyMMdd')}

		#[A5_MIS_BAKASHA] [nchar](10) NULL,
		[string]$vA5_MIS_BAKASHA = ""; [string]$vA5_MIS_BAKASHA =$line.A5_MIS_BAKASHA
		if($vA5_MIS_BAKASHA -ne $null){$vA5_MIS_BAKASHA = $vA5_MIS_BAKASHA.trim()}
		#[A5_HUG_MEVUKASH] [nchar](10) NULL,
		[string]$vA5_HUG_MEVUKASH = ""; [string]$vA5_HUG_MEVUKASH =$line.A5_HUG_MEVUKASH
		if($vA5_HUG_MEVUKASH -ne $null){$vA5_HUG_MEVUKASH = $vA5_HUG_MEVUKASH.trim()}
		#[A5_RAMA] [nchar](10) NULL,
		[string]$vA5_RAMA = ""; [string]$vA5_RAMA =$line.A5_RAMA
		if($vA5_RAMA -ne $null){$vA5_RAMA = $vA5_RAMA.trim()}
		#[A5_B_DATE] [datetime] NULL,
		[string]$str = ""; [string]$str =$line.A5_B_DATE
		if(!$str -or $str -eq "" -or $str -eq "00000000"){$vA5_B_DATE = ""} else {$str = $str.trim(); $vA5_B_DATE = ""; $vA5_B_DATE = [datetime]::parseexact($str, 'ddMMyyyy', $null).ToString('yyyyMMdd')}
		#[A5_B_BAKASHA] [datetime] NULL,
		[string]$str = ""; [string]$str =$line.A5_B_BAKASHA
		if(!$str -or $str -eq "" -or $str -eq "00000000"){$vA5_B_BAKASHA = ""} else {$str = $str.trim(); $vA5_B_BAKASHA = ""; $vA5_B_BAKASHA = [datetime]::parseexact($str, 'ddMMyyyy', $null).ToString('yyyyMMdd')}

		#[RAMAT_IVRIT] [nchar](10) NULL,
		[string]$vRAMAT_IVRIT = ""; [string]$vRAMAT_IVRIT =$line.RAMAT_IVRIT
		if($vRAMAT_IVRIT -ne $null){$vRAMAT_IVRIT = $vRAMAT_IVRIT.trim()}
		#[RAMAT_ANGLIT] [nchar](10) NULL,
		[string]$vRAMAT_ANGLIT = ""; [string]$vRAMAT_ANGLIT =$line.RAMAT_ANGLIT
		if($vRAMAT_ANGLIT -ne $null){$vRAMAT_ANGLIT = $vRAMAT_ANGLIT.trim()}
		#[OLD_E_MAIL] [nvarchar](100) NULL,
		[string]$vOLD_E_MAIL = ""; [string]$vOLD_E_MAIL =$line.OLD_E_MAIL
		if($vOLD_E_MAIL -ne $null){$vOLD_E_MAIL = $vOLD_E_MAIL.trim()}
		#[L_FAMILY] [nvarchar](50) NULL,
		[string]$vL_FAMILY = ""; [string]$vL_FAMILY =$line.L_FAMILY
		if(!$vL_FAMILY -or $vL_FAMILY -eq "")
		{log "ENG_FAMILY is missing. Skipping the line" $logFileName;continue }
		else
		{
			$vL_FAMILY = $vL_FAMILY.trim()
			$vL_FAMILY = ((((($vL_FAMILY.replace("'","")).replace(".","")).replace("-","")).replace(",","")).replace("?","")).replace(" ","-")
			#$vL_FAMILY
			[string]$newUserSN = $vL_FAMILY
			[string]$SN4NameGen=$newUserSN.replace("-", "") # we keep hyphens but jump over them for name generation
			[string]$newUserSN=cap $newUserSN
		}
		#[LNAME] [nvarchar](50) NULL,
		[string]$vLNAME = ""; [string]$vLNAME =$line.LNAME
		if(!$vLNAME -or ($vLNAME -eq ""))
		{log "ENG_NAME is missing. Skipping the line" $logFileName;continue  } 
		else
		{
			$vLNAME = $vLNAME.trim()
			$vLNAME = (((((($vLNAME.replace("'","")).replace(" ","")).replace("  ","")).replace(".","")).replace("-","")).replace(",","")).replace("?","")
			[string]$newUserGN =       cap $vLNAME
		}
		#[VATIK] [nchar](10) NULL,
		[string]$vVATIK = ""; [string]$vVATIK =$line.VATIK
		if($vVATIK -ne $null){$vVATIK = $vVATIK.trim()}
		#[HUL] [nchar](10) NULL,
		[string]$vHUL = ""; [string]$vHUL =$line.HUL
		if($vHUL -ne $null){$vHUL = $vHUL.trim()}
		## Columns from file are ended here
		# LOGGING LINE DATA is omitted
		# Lookup for CC username
		$logonName = ""
		if($checkccusername)
		{
			$user = $null; $user = get-ADUser -Properties employeeID -Filter 'employeeID -like $userUniqueID8' -Server hustaff.huji.local
			if(!$user)
			{$logonName = ""}
			else
			{
				if($user -is [array]) {$logonName = ""; log "There are many CC users with ID $userUniqueID" $logFileName}
				else {$logonName = "CC\" + $user.Name; $logonName}
			}
		}


	# ADDING TO SQL TABLE
	try
	{
		#creating connection to SQL database
		$conn = New-Object System.Data.SqlClient.SqlConnection
		$conn.ConnectionString = $ConnString
		$conn.Open()
		
		$cmd = New-Object System.Data.SqlClient.SqlCommand
		$cmd.connection = $conn
		
		#setting parameters
		$cmd.Parameters.AddWithValue("@ZEHUT",$vZEHUT) | Out-Null
		$cmd.Parameters.AddWithValue("@ZEHUT_KODEMET",$vZEHUT_KODEMET) | Out-Null
		$cmd.Parameters.AddWithValue("@SUG_ZEHUT",$vSUG_ZEHUT) | Out-Null
		$cmd.Parameters.AddWithValue("@FAMILY",$vFAMILY) | Out-Null
		$cmd.Parameters.AddWithValue("@NAME",$vNAME) | Out-Null
		$cmd.Parameters.AddWithValue("@ADDRESS",$vADDRESS) | Out-Null
		$cmd.Parameters.AddWithValue("@MIKUD",$vMIKUD) | Out-Null
		$cmd.Parameters.AddWithValue("@E_MAIL",$vE_MAIL) | Out-Null
		$cmd.Parameters.AddWithValue("@YSHUV",$vYSHUV) | Out-Null
		$cmd.Parameters.AddWithValue("@TELEPHON",$vTELEPHON) | Out-Null
		$cmd.Parameters.AddWithValue("@KIDOMET",$vKIDOMET) | Out-Null
		$cmd.Parameters.AddWithValue("@TELEPHON_SELUL",$vTELEPHON_SELUL) | Out-Null
		$cmd.Parameters.AddWithValue("@KIDOMET_SELUL",$vKIDOMET_SELUL) | Out-Null
		$cmd.Parameters.AddWithValue("@RISHUM",$vRISHUM) | Out-Null
		$cmd.Parameters.AddWithValue("@SHANA",$vSHANA) | Out-Null
		$cmd.Parameters.AddWithValue("@SEMESTER",$vSEMESTER) | Out-Null
		$cmd.Parameters.AddWithValue("@DATE_RISHUM",$vDATE_RISHUM) | Out-Null
		$cmd.Parameters.AddWithValue("@HUG_TOAR1",$vHUG_TOAR1) | Out-Null
		$cmd.Parameters.AddWithValue("@MEMUZA1",$vMEMUZA1) | Out-Null
		$cmd.Parameters.AddWithValue("@HUG_TOAR2",$vHUG_TOAR2) | Out-Null
		$cmd.Parameters.AddWithValue("@MEMUZA2",$vMEMUZA2) | Out-Null
		$cmd.Parameters.AddWithValue("@MEM_TOAR",$vMEM_TOAR) | Out-Null
		$cmd.Parameters.AddWithValue("@HUG_LIMUD1",$vHUG_LIMUD1) | Out-Null
		$cmd.Parameters.AddWithValue("@MEMUZA_HUG1",$vMEMUZA_HUG1) | Out-Null
		$cmd.Parameters.AddWithValue("@HUG_LIMUD2",$vHUG_LIMUD2) | Out-Null
		$cmd.Parameters.AddWithValue("@MEMUZA_HUG2",$vMEMUZA_HUG2) | Out-Null
		$cmd.Parameters.AddWithValue("@MOSAD",$vMOSAD) | Out-Null
		$cmd.Parameters.AddWithValue("@FACULTA",$vFACULTA) | Out-Null
		$cmd.Parameters.AddWithValue("@YEAR_LIMUD",$vYEAR_LIMUD) | Out-Null

		$cmd.Parameters.AddWithValue("@A1_MIS_BAKASHA",$vA1_MIS_BAKASHA) | Out-Null
		$cmd.Parameters.AddWithValue("@A1_HUG_MEVUKASH",$vA1_HUG_MEVUKASH) | Out-Null
		$cmd.Parameters.AddWithValue("@A1_RAMA",$vA1_RAMA) | Out-Null
		$cmd.Parameters.AddWithValue("@A1_B_DATE",$vA1_B_DATE) | Out-Null
		$cmd.Parameters.AddWithValue("@A1_B_BAKASHA",$vA1_B_BAKASHA) | Out-Null
		$cmd.Parameters.AddWithValue("@A2_MIS_BAKASHA",$vA2_MIS_BAKASHA) | Out-Null
		$cmd.Parameters.AddWithValue("@A2_HUG_MEVUKASH",$vA2_HUG_MEVUKASH) | Out-Null
		$cmd.Parameters.AddWithValue("@A2_RAMA",$vA2_RAMA) | Out-Null
		$cmd.Parameters.AddWithValue("@A2_B_DATE",$vA2_B_DATE) | Out-Null
		$cmd.Parameters.AddWithValue("@A2_B_BAKASHA",$vA2_B_BAKASHA) | Out-Null
		$cmd.Parameters.AddWithValue("@A3_MIS_BAKASHA",$vA3_MIS_BAKASHA) | Out-Null
		$cmd.Parameters.AddWithValue("@A3_HUG_MEVUKASH",$vA3_HUG_MEVUKASH) | Out-Null
		$cmd.Parameters.AddWithValue("@A3_RAMA",$vA3_RAMA) | Out-Null
		$cmd.Parameters.AddWithValue("@A3_B_DATE",$vA3_B_DATE) | Out-Null
		$cmd.Parameters.AddWithValue("@A3_B_BAKASHA",$vA3_B_BAKASHA) | Out-Null
		$cmd.Parameters.AddWithValue("@A4_MIS_BAKASHA",$vA4_MIS_BAKASHA) | Out-Null
		$cmd.Parameters.AddWithValue("@A4_HUG_MEVUKASH",$vA4_HUG_MEVUKASH) | Out-Null
		$cmd.Parameters.AddWithValue("@A4_RAMA",$vA4_RAMA) | Out-Null
		$cmd.Parameters.AddWithValue("@A4_B_DATE",$vA4_B_DATE) | Out-Null
		$cmd.Parameters.AddWithValue("@A4_B_BAKASHA",$vA4_B_BAKASHA) | Out-Null
		$cmd.Parameters.AddWithValue("@A5_MIS_BAKASHA",$vA5_MIS_BAKASHA) | Out-Null
		$cmd.Parameters.AddWithValue("@A5_HUG_MEVUKASH",$vA5_HUG_MEVUKASH) | Out-Null
		$cmd.Parameters.AddWithValue("@A5_RAMA",$vA5_RAMA) | Out-Null
		$cmd.Parameters.AddWithValue("@A5_B_DATE",$vA5_B_DATE) | Out-Null
		$cmd.Parameters.AddWithValue("@A5_B_BAKASHA",$vA5_B_BAKASHA) | Out-Null

		$cmd.Parameters.AddWithValue("@RAMAT_IVRIT",$vRAMAT_IVRIT) | Out-Null
		$cmd.Parameters.AddWithValue("@RAMAT_ANGLIT",$vRAMAT_ANGLIT) | Out-Null
		$cmd.Parameters.AddWithValue("@OLD_E_MAIL",$vOLD_E_MAIL) | Out-Null
		$cmd.Parameters.AddWithValue("@L_FAMILY",$vL_FAMILY) | Out-Null
		$cmd.Parameters.AddWithValue("@LNAME",$vLNAME) | Out-Null
		$cmd.Parameters.AddWithValue("@VATIK",$vVATIK) | Out-Null
		$cmd.Parameters.AddWithValue("@HUL",$vHUL) | Out-Null
		$cmd.Parameters.AddWithValue("@STUDENT_ID",$userUniqueID) | Out-Null
		$cmd.Parameters.AddWithValue("@CC_USERNAME",$logonName) | Out-Null

$cmd.commandtext=@"
INSERT INTO [dbo].[temp_users_2] (
ZEHUT,ZEHUT_KODEMET,SUG_ZEHUT,FAMILY,NAME,ADDRESS,
MIKUD,E_MAIL,YSHUV,TELEPHON,KIDOMET,TELEPHON_SELUL,KIDOMET_SELUL,
RISHUM,SHANA,SEMESTER,DATE_RISHUM,HUG_TOAR1,MEMUZA1,HUG_TOAR2,MEMUZA2,MEM_TOAR,HUG_LIMUD1,MEMUZA_HUG1,
HUG_LIMUD2,MEMUZA_HUG2,MOSAD,FACULTA,YEAR_LIMUD,
A1_MIS_BAKASHA,A1_HUG_MEVUKASH,A1_RAMA,A1_B_DATE,A1_B_BAKASHA,
A2_MIS_BAKASHA,A2_HUG_MEVUKASH,A2_RAMA,A2_B_DATE,A2_B_BAKASHA,
A3_MIS_BAKASHA,A3_HUG_MEVUKASH,A3_RAMA,A3_B_DATE,A3_B_BAKASHA,
A4_MIS_BAKASHA,A4_HUG_MEVUKASH,A4_RAMA,A4_B_DATE,A4_B_BAKASHA,
A5_MIS_BAKASHA,A5_HUG_MEVUKASH,A5_RAMA,A5_B_DATE,A5_B_BAKASHA,
RAMAT_IVRIT,RAMAT_ANGLIT,OLD_E_MAIL,L_FAMILY,LNAME,VATIK,HUL,STUDENT_ID,CC_USERNAME) 
VALUES(
@ZEHUT,@ZEHUT_KODEMET,@SUG_ZEHUT,@FAMILY,@NAME,@ADDRESS,
@MIKUD,@E_MAIL,@YSHUV,@TELEPHON,@KIDOMET,@TELEPHON_SELUL,@KIDOMET_SELUL,
@RISHUM,@SHANA,@SEMESTER,@DATE_RISHUM,@HUG_TOAR1,@MEMUZA1,@HUG_TOAR2,@MEMUZA2,@MEM_TOAR,@HUG_LIMUD1,@MEMUZA_HUG1,
@HUG_LIMUD2,@MEMUZA_HUG2,@MOSAD,@FACULTA,@YEAR_LIMUD,
@A1_MIS_BAKASHA,@A1_HUG_MEVUKASH,@A1_RAMA,@A1_B_DATE,@A1_B_BAKASHA,
@A2_MIS_BAKASHA,@A2_HUG_MEVUKASH,@A2_RAMA,@A2_B_DATE,@A2_B_BAKASHA,
@A3_MIS_BAKASHA,@A3_HUG_MEVUKASH,@A3_RAMA,@A3_B_DATE,@A3_B_BAKASHA,
@A4_MIS_BAKASHA,@A4_HUG_MEVUKASH,@A4_RAMA,@A4_B_DATE,@A4_B_BAKASHA,
@A5_MIS_BAKASHA,@A5_HUG_MEVUKASH,@A5_RAMA,@A5_B_DATE,@A5_B_BAKASHA,
@RAMAT_IVRIT,@RAMAT_ANGLIT,@OLD_E_MAIL,@L_FAMILY,@LNAME,@VATIK,@HUL,@STUDENT_ID,@CC_USERNAME
) 
"@

		$cmd.executenonquery()
		$conn.close()
		log "LINE($cntLines): <$line>`n" $logFileName
		g; log "Adding user record to Database" $logFileName;w
	}
	catch
	{
	$err=$Error[0].exception.message
	red;log " (422) FAILED to add  Id <$userUniqueID> record to Database `n $err " $logFileName;w
	$conn.close()
	$noerrors = $false; break
	}

} # end foreach ($line in $inputArray)

return $noerrors
exit

#########################################################
