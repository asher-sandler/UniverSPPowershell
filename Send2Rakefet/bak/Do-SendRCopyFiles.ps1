function get-ScrptFullPath($scriptX ){
	$fileScr = get-Item $scriptX
	return $fileScr.DirectoryName
}
function get-FrendlyDateLog($dtNow){
	$dtNowS = $dtNow.Year.ToString() + "-" +$dtNow.Month.ToString().PadLeft(2,"0") + "-"+$dtNow.Day.ToString().PadLeft(2,"0") + "-" + $dtNow.Hour.ToString().PadLeft(2,"0")+"-"+$dtNow.Minute.ToString().PadLeft(2,"0")+"-"+$dtNow.Second.ToString().PadLeft(2,"0")
	return 	$dtNowS
}
$script=$MyInvocation.InvocationName
$scriptDirectory = get-ScrptFullPath $script

$dtNow = Get-Date
$dtNowStrLog 	= get-FrendlyDateLog 	$dtNow
$logFile = $scriptDirectory + "\AS-SendSapCopyFiles-"+$dtNowStrLog+".txt"
Write-Host $logFile
Start-Transcript $logFile
$copyDone = $false

Set-Location $scriptDirectory

$sourceFileName = "NEW_VENDOR.csv"
$src = "\\ekekfls00\data$\ftpRoot\ibts\$sourceFileName"
#$src = $scriptDirectory+"\"+$sourceFileName

# Path to PDF
#\\ekekfls00\data$\scriptFolders\FilesToSap

$timeStamp = Get-Date -format "yyyy-MM-dd_HH-mm-ss"
$tgtFileName = $sourceFileName.Replace(".csv","")+"_$timeStamp.csv"

$tgtDir = "\\ekekfls00\data$\ftpRoot\ibts\crsToSap"
$tgtFile = $tgtDir+"\"+$tgtFileName

$tgtDir2 = "\\vscifs.cc.huji.ac.il\sapinterface\NON_PO_interfaces\PRD\FI\I_OPEN_VENDOR"
$tgtFile2 = $tgtDir2+"\"+$tgtFileName

if (Test-Path $src){
	if (Test-Path $tgtDir){
		Copy-Item $src $tgtFile -Force -Confirm:$false
	}
	if (Test-Path $tgtDir2){
		Copy-Item $src $tgtFile2 -Force -Confirm:$false
	}

	start-sleep 2

	Remove-Item $src -Force -Confirm:$false
	$copyDone = $true
}

# pdf
#$pdfSourcePath = "\\ekekfls00\data$\scriptFolders\FilesToSap"
$pdfSourcePath = "\\ekekfls00\data$\ftpRoot\ibts\FilesToSap"


$FilesPDF = Get-ChildItem -Path $pdfSourcePath -Filter "*.pdf"
$tgtPDFDir = "\\vscifs.cc.huji.ac.il\sapinterface\NON_PO_interfaces\PRD\FI\I_OPEN_VENDOR\Attachments"
foreach($fPDF in $FilesPDF){
	Copy-Item $fPDF.FullName $tgtPDFDir
}

foreach($fPDF in $FilesPDF){
	Remove-Item $fPDF.FullName
}
Stop-Transcript
if ($copyDone){
	$gzipexec =  "c:\gzip\gzip"

	write-host "$gzipexec $logFile -f"
	& $gzipexec $logFile -f #| Out-Null
	$gzLogFile = $logFile.Replace("txt","txt.gz")

	$gzFile = get-Item $gzLogFile
	$outGzPath = "\\ekekfls00\data$\scriptFolders\LOGS\SAPExport"
	write-host "Copy gzip log to: " $outGzPath
	copy-item $gzFile $outGzPath

	write-host "Send $gzFile to: supportsp@savion.huji.ac.il"

	$msgSubj = "Copy NEW_VENDOR.csv and PDF Log gz"
	Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "supportsp@savion.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $outGzPath  -Attachments  $gzFile -smtpserver ekekcas01  -erroraction SilentlyContinue
	#Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "evgeniat@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $outGzPath  -Attachments  $gzFile -smtpserver ekekcas01  -erroraction SilentlyContinue
	#Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "danielkl@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $outGzPath  -Attachments  $gzFile -smtpserver ekekcas01  -erroraction SilentlyContinue
	start-sleep 2
	remove-Item $gzFile
}
else
{
	$lgFile = Get-Item $logFile
	remove-Item $lgFile
}
exit

